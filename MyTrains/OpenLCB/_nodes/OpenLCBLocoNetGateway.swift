//
//  OpenLCBLocoNetGateway.swift
//  MyTrains
//
//  Created by Paul Willmott on 01/07/2023.
//

import Foundation

private typealias QueueItem = (nodeId:UInt64, message:[UInt8], spacingDelay:UInt8)

public class OpenLCBLocoNetGateway : OpenLCBNodeVirtual, MTSerialPortDelegate {
 
  // MARK: Constructors & Destructors
  
  public override init(nodeId:UInt64) {
    
    configuration = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, defaultMemorySize: 260, isReadOnly: false, description: "")
    
    super.init(nodeId: nodeId)
    
    virtualNodeType = MyTrainsVirtualNodeType.locoNetGatewayNode
    
    configuration.delegate = self

    memorySpaces[configuration.space] = configuration

    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressDevicePath)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressBaudRate)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressParity)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressFlowControl)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressBlockAllMessages)

    initCDI(filename: "MyTrains LocoNet Gateway", manufacturer: manufacturerName, model: nodeModelName)
    
    isLocoNetGatewayProtocolSupported = true
    
    if !memorySpacesInitialized {
      resetToFactoryDefaults()
    }
    
  }
  
  deinit {
    stopSpacingTimer()
    if isOpen {
      close()
    }
  }

  // MARK: Private Properties
  
  // Serial Port Control
  
  internal var serialPort : MTSerialPort?
  
  internal var buffer : [UInt8] = []
  
  private var outputQueue : [QueueItem] = []
  
  internal var isOpen : Bool {
    if let port = serialPort {
      return port.isOpen
    }
    return false
  }

  // Configuration varaible addresses
  
  internal let addressDevicePath       : Int =  0
  internal let addressBaudRate         : Int =  256
  internal let addressParity           : Int =  257
  internal let addressFlowControl      : Int =  258
  internal let addressBlockAllMessages : Int =  259

  private var devicePath : String {
    get {
      return configuration.getString(address: addressDevicePath, count: 256)!
    }
    set(value) {
      configuration.setString(address: addressDevicePath, value: value, fieldSize: 256)
    }
  }
  
  private var baudRate : BaudRate {
    get {
      return BaudRate(rawValue: Int(configuration.getUInt8(address: addressBaudRate)!))!
    }
    set(value) {
      let uInt : UInt8 = UInt8(value.rawValue & 0xff)
      configuration.setUInt(address: addressBaudRate, value: uInt)
    }
  }
  
  private var parity : Parity {
    get {
      return Parity(rawValue: Int32(configuration.getUInt8(address: addressParity)!))!
    }
    set(value) {
      let uInt : UInt8 = UInt8(value.rawValue & 0xff)
      configuration.setUInt(address: addressBaudRate, value: uInt)
    }
  }
  
  private var flowControl : FlowControl {
    get {
      return FlowControl(rawValue: Int(configuration.getUInt8(address: addressFlowControl)!))!
    }
    set(value) {
      let uInt : UInt8 = UInt8(value.rawValue & 0xff)
      configuration.setUInt(address: addressBaudRate, value: uInt)
    }
  }
  
  private var blockAllMessages : Bool {
    get {
      return configuration.getUInt8(address: addressBlockAllMessages)! != 0
    }
    set(value) {
      let uInt : UInt8 = value ? 1 : 0
      configuration.setUInt(address: addressBaudRate, value: uInt)
    }
  }
  
  private var spacingTimer : Timer?
  
  private var consumerIdentified : Bool = false
  
  // MARK: Public Properties
  
  public var configuration : OpenLCBMemorySpace

  // MARK: Private Methods
  
  @objc func spacingTimerAction() {
    
    guard isOpen else {
      return
    }
    
    while !outputQueue.isEmpty {
      
      let item = outputQueue.removeFirst()
      
      send(data: item.message)
      
    }
    
//    startSpacingTimer(spacingDelay: item.spacingDelay)

  }
  
  func startSpacingTimer(spacingDelay:UInt8) {
    
    guard isOpen else {
      return
    }
    
    let timeInterval : TimeInterval = Double(spacingDelay) / 1000.0
    
    spacingTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(spacingTimerAction), userInfo: nil, repeats: false)
    
    RunLoop.current.add(spacingTimer!, forMode: .common)
    
  }
  
  func stopSpacingTimer() {
    spacingTimer?.invalidate()
    spacingTimer = nil
  }

  internal override func resetToFactoryDefaults() {
    
    acdiManufacturerSpaceVersion = 4
    
    manufacturerName    = virtualNodeType.manufacturerName
    nodeModelName       = virtualNodeType.name
    nodeHardwareVersion = "v0.1"
    nodeSoftwareVersion = "v0.1"
    
    acdiUserSpaceVersion = 2
    
    userNodeName        = ""
    userNodeDescription = ""
    
    devicePath = ""
    
    baudRate = .br9600
    
    flowControl = .noFlowControl
    
    parity = .none
    
    blockAllMessages = false
    
    saveMemorySpaces()
    
  }
  
  internal override func resetReboot() {

    close()
    
    buffer.removeAll()
    
    outputQueue.removeAll()
    
    consumerIdentified = false
    
    if let port = MTSerialPort(path: devicePath) {
      serialPort = port
      port.baudRate = baudRate
      port.numberOfDataBits = 8
      port.numberOfStopBits = 1
      port.parity = parity
      port.usesRTSCTSFlowControl = flowControl == .rtsCts
      port.delegate = self
      port.open()
    }

  }
  
  private func close() {
    serialPort?.close()
    serialPort = nil
  }
  
  private func send(data: [UInt8]) {
    self.serialPort?.write(data:data)
  }

  internal func addToInputBuffer(data:[UInt8]) {
    
    buffer.append(contentsOf: data)

    while !buffer.isEmpty {
      
      // find the start of a message
      
      let maskOpCode : UInt8 = 0x80
      
      var opCodeFound = false
      
      while let cc = buffer.first {
        if ((cc & maskOpCode) == maskOpCode) {
          opCodeFound = true
          break
        }
        buffer.removeFirst()
      }
      
      if !opCodeFound {
        break
      }
      
      var length : UInt8
      
      switch buffer.first! & 0b01100000 {
      case 0b00000000 :
        length = 2
      case 0b00100000 :
        length = 4
      case 0b01000000 :
        length = 6
      default :
        length = buffer.count > 1 ? buffer[1] : 0xff
      }
      
      if length >= 0x80 || buffer.count < length {
        break
      }
      
      var message : [UInt8] = []
       
      var restart = false
      
      for index in 1 ... length {
        
        let cc = buffer.first!
        
        if index > 1 && ((cc & maskOpCode) == maskOpCode) {
          restart = true
          break
        }
        
        message.append(cc)
        
        buffer.removeFirst()
        
      }
      
      // Process message if no high bits set in data
        
      if !restart {
        
        if !blockAllMessages && consumerIdentified {
          networkLayer?.sendLocoNetMessageReceived(sourceNodeId: nodeId, locoNetMessage: message)
        }
        
      }

    }
    
  }

  // MARK: Public Methods
  
  public override func start() {
    super.start()
  }
  
  public override func stop() {
    close()
    super.stop()
  }
  
  // MARK: OpenLCBNetworkLayerDelegate Methods
  
  public override func openLCBMessageReceived(message: OpenLCBMessage) {
 
    super.openLCBMessageReceived(message: message)
    
    switch message.messageTypeIndicator {
    case .identifyProducer:
      
      if message.eventId == OpenLCBWellKnownEvent.locoNetMessage.rawValue {
        networkLayer?.sendProducerIdentifiedValid(sourceNodeId: nodeId, wellKnownEvent: .locoNetMessage)
      }
      
    case .consumerIdentifiedAsCurrentlyValid, .consumerIdentifiedAsCurrentlyInvalid, .consumerIdentifiedWithValidityUnknown:
      
      if message.eventId == OpenLCBWellKnownEvent.locoNetMessage.rawValue {
        consumerIdentified = true
      }
      
    case .sendLocoNetMessage:
      
      if message.destinationNodeId! == nodeId {
        
        if !isOpen {
          networkLayer?.sendTerminateDueToError(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, errorCode: .permanentErrorNoConnection)
        }
        else {
          
          var data = message.payload
          
          let locoNetMessage = LocoNetMessage(data: data)
          
          let length = locoNetMessage.messageLength
          
          var spacingDelay : UInt8 = 0
          
          if message.payload.count == length + 1 {
            spacingDelay = locoNetMessage.message.removeLast()
          }
          
          if locoNetMessage.checkSumOK {
            
            if outputQueue.count == 99 {
              networkLayer?.sendTerminateDueToError(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, errorCode: .temporaryErrorBufferUnavailable)
            }
            else {
              
              outputQueue.append((nodeId: message.sourceNodeId!, message: locoNetMessage.message, spacingDelay: spacingDelay))
              
              if outputQueue.count == 1 {
                spacingTimerAction()
              }
              
            }
            
          }
          else {
            networkLayer?.sendTerminateDueToError(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, errorCode: .permanentErrorInvalidArguments)
          }
          
        }
        
      }
    default:
      break
    }
 
  }

  // MARK: MTSerialPortDelegate Methods
  
  public func serialPort(_ serialPort: MTSerialPort, didReceive data: [UInt8]) {
    addToInputBuffer(data: data)
  }
  
  public func serialPortWasRemovedFromSystem(_ serialPort: MTSerialPort) {
    self.serialPort = nil
//    print("port was removed from system")
  }
  
  public func serialPortWasOpened(_ serialPort: MTSerialPort) {
 //   print("port was opened")
    networkLayer?.sendProducerIdentifiedValid(sourceNodeId: nodeId, wellKnownEvent: .locoNetMessage)
  }
  
  public func serialPortWasClosed(_ serialPort: MTSerialPort) {
 //   print("port was closed")
    self.serialPort = nil
  }

}
