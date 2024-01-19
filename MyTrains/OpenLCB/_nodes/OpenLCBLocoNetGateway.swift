//
//  OpenLCBLocoNetGateway.swift
//  MyTrains
//
//  Created by Paul Willmott on 01/07/2023.
//

import Foundation

private typealias QueueItem = (nodeId:UInt64, message:LocoNetMessage)

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

    isLocoNetGatewayProtocolSupported = true
    
    datagramTypesSupported.insert(.sendlocoNetMessage)
    
    if !memorySpacesInitialized {
      resetToFactoryDefaults()
    }

    cdiFilename = "MyTrains LocoNet Gateway"

  }
  
  deinit {
    if isOpen {
      close()
    }
  }

  // MARK: Private Properties
  
  // Serial Port Control
  
  internal var serialPort : MTSerialPort?
  
  internal var buffer : [UInt8] = []
  
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
      return BaudRate(rawValue: configuration.getUInt8(address: addressBaudRate)!)!
    }
    set(value) {
      configuration.setUInt(address: addressBaudRate, value: value.rawValue)
    }
  }
  
  private var parity : Parity {
    get {
      return Parity(rawValue: configuration.getUInt8(address: addressParity)!)!
    }
    set(value) {
      configuration.setUInt(address: addressBaudRate, value: value.rawValue)
    }
  }
  
  private var flowControl : FlowControl {
    get {
      return FlowControl(rawValue: configuration.getUInt8(address: addressFlowControl)!)!
    }
    set(value) {
      configuration.setUInt(address: addressBaudRate, value: value.rawValue)
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
  
  private var consumerIdentified : Bool = false
  
  private var queue : [QueueItem] = []
  
  private var timeoutTimer : Timer?
  
  private var currentItem : QueueItem?
  
  // MARK: Public Properties
  
  public var configuration : OpenLCBMemorySpace

  // MARK: Private Methods
  
  internal override func resetToFactoryDefaults() {
    
    super.resetToFactoryDefaults()
    
    devicePath = ""
    
    baudRate = .br9600
    
    flowControl = .noFlowControl
    
    parity = .none
    
    blockAllMessages = false
    
    saveMemorySpaces()
    
  }
  
  internal override func resetReboot() {

    super.resetReboot()
    
    close()
    
    buffer.removeAll()
    
    queue.removeAll()
    
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
    
    networkLayer?.sendProducerIdentified(sourceNodeId: nodeId, wellKnownEvent: .nodeIsALocoNetGateway, validity: .valid)

    networkLayer?.sendWellKnownEvent(sourceNodeId: nodeId, eventId: .nodeIsALocoNetGateway)

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
        
        if let item = currentItem, message == item.message.message {
          stopTimeoutTimer()
          networkLayer?.sendLocoNetMessageReply(sourceNodeId: nodeId, destinationNodeId: item.nodeId, errorCode: .success)
          currentItem = nil
          sendNext()
        }
        
        if !blockAllMessages {
          networkLayer?.sendLocoNetMessageReceived(sourceNodeId: nodeId, locoNetMessage: message)
        }
        
      }

    }
    
  }
  
  private func sendNext() {
    
    guard currentItem == nil && !queue.isEmpty else {
      return
    }
    
    currentItem = queue.removeFirst()
    
    startTimeoutTimer(interval: 1.0)
    
    send(data: currentItem!.message.message)
    
  }
  
  @objc func timeoutTimerAction() {
    stopTimeoutTimer()
    if let item = currentItem {
      networkLayer?.sendLocoNetMessageReply(sourceNodeId: nodeId, destinationNodeId: item.nodeId, errorCode: .temporaryErrorLocoNetCollision)
    }
    currentItem = nil
    sendNext()
  }
  
  private func startTimeoutTimer(interval: TimeInterval) {
    timeoutTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(timeoutTimerAction), userInfo: nil, repeats: false)
    RunLoop.current.add(timeoutTimer!, forMode: .common)
  }
  
  private func stopTimeoutTimer() {
    timeoutTimer?.invalidate()
    timeoutTimer = nil
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
      
      if message.eventId == OpenLCBWellKnownEvent.nodeIsALocoNetGateway.rawValue {
        networkLayer?.sendProducerIdentified(sourceNodeId: nodeId, wellKnownEvent: .nodeIsALocoNetGateway, validity: .valid)
      }
    
    case .consumerIdentifiedAsCurrentlyValid, .consumerIdentifiedAsCurrentlyInvalid, .consumerIdentifiedWithValidityUnknown:
      
      if message.eventId == OpenLCBWellKnownEvent.nodeIsALocoNetGateway.rawValue {
        consumerIdentified = true
      }
      
    case .datagram:
      
      if let datagramType = message.datagramType, datagramType == .sendlocoNetMessage, message.destinationNodeId! == nodeId, let sourceNodeId = message.sourceNodeId {

        if !isOpen {
          networkLayer?.sendDatagramRejected(sourceNodeId: nodeId, destinationNodeId: sourceNodeId, errorCode: .permanentErrorNoConnection)
        }
        else if queue.count == 100 {
          networkLayer?.sendDatagramRejected(sourceNodeId: nodeId, destinationNodeId: sourceNodeId, errorCode: .temporaryErrorBufferUnavailable)
        }
        else {
          
          var data = message.payload
          data.removeFirst(2)

          if let locoNetMessage = LocoNetMessage(payload: data) {
            queue.append((nodeId:message.sourceNodeId!, message:locoNetMessage))
            networkLayer?.sendDatagramReceivedOK(sourceNodeId: nodeId, destinationNodeId: sourceNodeId, timeOut: .replyPending2s)
            sendNext()
          }
          else {
            networkLayer?.sendDatagramRejected(sourceNodeId: nodeId, destinationNodeId: sourceNodeId, errorCode: .permanentErrorInvalidArguments)
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
    print("serial port was removed from system: \(serialPort.path)")
    self.serialPort = nil
  }
  
  public func serialPortWasOpened(_ serialPort: MTSerialPort) {
    print("serial port was opened: \(serialPort.path)")
  }
  
  public func serialPortWasClosed(_ serialPort: MTSerialPort) {
    print("serial port was closed: \(serialPort.path)")
    self.serialPort = nil
  }

  public func serialPortWasAdded(_ serialPort: MTSerialPort) {
    if !isOpen {
      resetReboot()
    }
  }
  
}
