//
//  OpenLCBLocoNetGateway.swift
//  MyTrains
//
//  Created by Paul Willmott on 01/07/2023.
//

import Foundation

private typealias QueueItem = (nodeId:UInt64, message:LocoNetMessage)

public class OpenLCBLocoNetGateway : OpenLCBNodeVirtual, MTSerialPortDelegate, MTSerialPortManagerDelegate {
 
  // MARK: Constructors & Destructors
  
  public override init(nodeId:UInt64) {
    
    super.init(nodeId: nodeId)
    
    var configurationSize = 0

    initSpaceAddress(&addressDevicePath, 256, &configurationSize)
    initSpaceAddress(&addressBaudRate, 1, &configurationSize)
    initSpaceAddress(&addressParity, 1, &configurationSize)
    initSpaceAddress(&addressFlowControl, 1, &configurationSize)
    initSpaceAddress(&addressBlockAllMessages, 1, &configurationSize)

    configuration = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, defaultMemorySize: configurationSize, isReadOnly: false, description: "")
    
    if let configuration {
      
      virtualNodeType = MyTrainsVirtualNodeType.locoNetGatewayNode
      
      isFullProtocolRequired = true
      
      configuration.delegate = self
      
      memorySpaces[configuration.space] = configuration
      
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressDevicePath)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressBaudRate)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressParity)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressFlowControl)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressBlockAllMessages)
      
      isLocoNetGatewayProtocolSupported = true
      
      datagramTypesSupported.insert(.sendLocoNetMessage)
      
      if !memorySpacesInitialized {
        resetToFactoryDefaults()
      }
      
      eventsConsumed = [
      ]
      
      eventsProduced = [
        OpenLCBWellKnownEvent.nodeIsALocoNetGateway.rawValue,
      ]
      
      eventRangesProduced = [
        EventRange(startId: OpenLCBWellKnownEvent.locoNetMessage.rawValue, mask: 0x0000ffffffffffff)!
      ]
      
      cdiFilename = "MyTrains LocoNet Gateway"
      
    }
    
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
  
  internal var sendToSerialPortPipe : MTPipe?
  
  internal var isOpen : Bool {
    if let port = serialPort {
      return port.isOpen
    }
    return false
  }

  // Configuration varaible addresses
  
  internal var addressDevicePath       = 0
  internal var addressBaudRate         = 0
  internal var addressParity           = 0
  internal var addressFlowControl      = 0
  internal var addressBlockAllMessages = 0

  private var devicePath : String {
    get {
      return configuration!.getString(address: addressDevicePath, count: 256)!
    }
    set(value) {
      configuration!.setString(address: addressDevicePath, value: value, fieldSize: 256)
    }
  }
  
  private var baudRate : BaudRate {
    get {
      return BaudRate(rawValue: configuration!.getUInt8(address: addressBaudRate)!)!
    }
    set(value) {
      configuration!.setUInt(address: addressBaudRate, value: value.rawValue)
    }
  }
  
  private var parity : Parity {
    get {
      return Parity(rawValue: configuration!.getUInt8(address: addressParity)!)!
    }
    set(value) {
      configuration!.setUInt(address: addressBaudRate, value: value.rawValue)
    }
  }
  
  private var flowControl : FlowControl {
    get {
      return FlowControl(rawValue: configuration!.getUInt8(address: addressFlowControl)!)!
    }
    set(value) {
      configuration!.setUInt(address: addressBaudRate, value: value.rawValue)
    }
  }
  
  private var blockAllMessages : Bool {
    get {
      return configuration!.getUInt8(address: addressBlockAllMessages)! != 0
    }
    set(value) {
      let uInt : UInt8 = value ? 1 : 0
      configuration!.setUInt(address: addressBaudRate, value: uInt)
    }
  }
  
  private var consumerIdentified : Bool = false
  
  private var queue : [QueueItem] = []
  
  private var timeoutTimer : Timer?
  
  private var currentItem : QueueItem?
  
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
  
  internal func openSerialPort() {
    
    if let port = MTSerialPort(path: devicePath) {
      
      serialPort = port
      port.baudRate = baudRate
      port.numberOfDataBits = 8
      port.numberOfStopBits = 1
      port.parity = parity
      port.usesRTSCTSFlowControl = flowControl == .rtsCts
      port.delegate = self
      port.open()
      
      if port.isOpen {
        
        if sendToSerialPortPipe == nil {
          sendToSerialPortPipe = MTPipe(name: MTSerialPort.pipeName(path: devicePath))
          sendToSerialPortPipe?.open()
        }
        
      }
      
    }

  }
  internal override func resetReboot() {

    super.resetReboot()
    
    close()
    
    buffer.removeAll()
    
    queue.removeAll()
    
    consumerIdentified = false
    
    openSerialPort()
    
  }
  
  internal override func completeStartUp() {
    sendWellKnownEvent(eventId: .nodeIsALocoNetGateway)
  }
  
  internal override func customizeDynamicCDI(cdi:String) -> String {
    
    var result = MTSerialPortManager.insertMap(cdi: cdi)
    result = BaudRate.insertMap(cdi: result)
    result = Parity.insertMap(cdi: result)
    result = FlowControl.insertMap(cdi: result)
    return result
    
  }
  
  internal func close() {
    sendToSerialPortPipe?.close()
    serialPort?.close()
    serialPort = nil
  }

  private func send(data: [UInt8]) {
    sendToSerialPortPipe?.write(data: data)
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
          sendLocoNetMessageReply(destinationNodeId: item.nodeId, errorCode: .success)
          currentItem = nil
          sendNext()
        }
        
        if !blockAllMessages {
          sendLocoNetMessageReceived(locoNetMessage: message)
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
      sendLocoNetMessageReply(destinationNodeId: item.nodeId, errorCode: .temporaryErrorLocoNetCollision)
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
      
    case .consumerIdentifiedAsCurrentlyValid, .consumerIdentifiedAsCurrentlyInvalid, .consumerIdentifiedWithValidityUnknown:
      
      if message.eventId == OpenLCBWellKnownEvent.nodeIsALocoNetGateway.rawValue {
        consumerIdentified = true
      }
      
    case .datagram:
      
      if let datagramType = message.datagramType, datagramType == .sendLocoNetMessage, let sourceNodeId = message.sourceNodeId {

        if !isOpen {
          sendDatagramRejected(destinationNodeId: sourceNodeId, errorCode: .permanentErrorNoConnection)
        }
        else if queue.count == 100 {
          sendDatagramRejected(destinationNodeId: sourceNodeId, errorCode: .temporaryErrorBufferUnavailable)
        }
        else {
          
          var data = message.payload
          data.removeFirst(2)

          if let locoNetMessage = LocoNetMessage(payload: data) {
            queue.append((nodeId:message.sourceNodeId!, message:locoNetMessage))
            sendDatagramReceivedOK(destinationNodeId: sourceNodeId, timeOut: .replyPending2s)
            sendNext()
          }
          else {
            sendDatagramRejected(destinationNodeId: sourceNodeId, errorCode: .permanentErrorInvalidArguments)
          }
          
        }
        
      }
      
    default:
      break
    }
 
  }

  // MARK: MTSerialPortDelegate Methods
  
  // This is running in the serial port's background thread
  public func serialPort(_ serialPort: MTSerialPort, didReceive data: [UInt8]) {
    addToInputBuffer(data: data)
  }
  
  // MARK: MTSerialPortManagerDelegate Methods
  
  @objc public func serialPortWasAdded(path:String) {
    
    guard path == devicePath, serialPort == nil else {
      return
    }
    
    openSerialPort()
    
  }

}
