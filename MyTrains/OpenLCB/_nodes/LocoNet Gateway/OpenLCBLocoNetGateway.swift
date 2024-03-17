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
    
    super.init(nodeId: nodeId)
    
    var configurationSize = 0

    initSpaceAddress(&addressDevicePath, 256, &configurationSize)
    initSpaceAddress(&addressBlockAllMessages, 1, &configurationSize)

    configuration = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, defaultMemorySize: configurationSize, isReadOnly: false, description: "")
    
    if let configuration {
      
      virtualNodeType = MyTrainsVirtualNodeType.locoNetGatewayNode
      
      isFullProtocolRequired = true
      
      configuration.delegate = self
      
      memorySpaces[configuration.space] = configuration
      
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressDevicePath)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressBlockAllMessages)
      
      isLocoNetGatewayProtocolSupported = true
      
      datagramTypesSupported.insert(.sendLocoNetMessageCompleteCommand)
      datagramTypesSupported.insert(.sendLocoNetMessageFirstPartCommand)
      datagramTypesSupported.insert(.sendLocoNetMessageFinalPartCommand)

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
      
      eventsToSendAtStartup = [
        OpenLCBWellKnownEvent.nodeIsALocoNetGateway.rawValue,
      ]
      
      cdiFilename = "MyTrains LocoNet Gateway"
      
    }
    
  }
  
  // MARK: Private Properties
  
  // Configuration varaible addresses
  
  internal var addressDevicePath       = 0
  internal var addressBlockAllMessages = 0

  private var blockAllMessages : Bool {
    get {
      return configuration!.getUInt8(address: addressBlockAllMessages)! != 0
    }
    set(value) {
      configuration!.setUInt(address: addressBlockAllMessages, value: value ? UInt8(1) : UInt8(0))
    }
  }
  
  internal var isStopping : Bool = false

  internal var serialPort : MTSerialPort?
  
  internal var buffer : [UInt8] = []
  
  internal var sendToSerialPortPipe : MTPipe?
  
  internal var isOpen : Bool {
    guard let port = serialPort else {
      return false
    }
    return port.isOpen
  }

  private var queue : [QueueItem] = []
  
  private var queueLock = NSLock()
  
  private var timeoutTimer : Timer?
  
  private var currentItem : QueueItem?
  
  private var datagramBuffer : [UInt64:[UInt8]] = [:]
  
  // MARK: Public Properties
  
  public var devicePath : String {
    get {
      return configuration!.getString(address: addressDevicePath, count: 256)!
    }
    set(value) {
      configuration!.setString(address: addressDevicePath, value: value, fieldSize: 256)
    }
  }
  
  // MARK: Private Methods
  
  internal override func resetToFactoryDefaults() {
    
    super.resetToFactoryDefaults()
    
    configuration?.zeroMemory()
    
    saveMemorySpaces()
    
  }
  
  internal override func customizeDynamicCDI(cdi:String) -> String {
    return MTSerialPortManager.insertMap(cdi: cdi)
  }
  
  internal func close() {
    sendToSerialPortPipe?.close()
    serialPort?.close()
    serialPort = nil
  }

  private func send(data: [UInt8]) {
    sendToSerialPortPipe?.write(data: data)
  }

  // This is running in the serial port's background thread
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
        length = (buffer.count > 1) ? (buffer[1] == 0) ? 128 : buffer[1] : 0xff
      }
      
      if length == 0xff || buffer.count < length {
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
          DispatchQueue.main.async {
            self.sendLocoNetMessageReply(destinationNodeId: item.nodeId)
            self.currentItem = nil
            self.sendNext()
          }
        }
        
        if !blockAllMessages {
          DispatchQueue.main.async {
            self.sendLocoNetMessageReceived(locoNetMessage: message)
          }
        }
        
      }

    }
    
  }
  
  private func sendNext() {
    
    queueLock.lock()
    
    var sendMessage = false
    
    if currentItem == nil && !queue.isEmpty {
      currentItem = queue.removeFirst()
      sendMessage = true
    }

    queueLock.unlock()
    
    if sendMessage {
      startTimeoutTimer(interval: 1.0)
      send(data: currentItem!.message.message)
    }

  }
  
  @objc func timeoutTimerAction() {
    stopTimeoutTimer()
    if let item = currentItem {
      sendLocoNetMessageReplyFailure(destinationNodeId: item.nodeId, errorCode: .temporaryErrorLocoNetCollision)
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
    
    setupConfigurationOptions()

    if let port = MTSerialPort(path: devicePath) {
      
      serialPort = port
      port.baudRate = .br125000
      port.numberOfDataBits = 8
      port.numberOfStopBits = 1
      port.parity = .none
      port.usesRTSCTSFlowControl = false
      port.delegate = self
      port.open()
      
      if isOpen {
        sendToSerialPortPipe = MTPipe(name: MTSerialPort.pipeName(path: devicePath))
        sendToSerialPortPipe?.open()
        startComplete()
      }
      
    }
    
    if !isOpen {
      #if DEBUG
      debugLog("serial port did not open")
      #endif
      networkLayer?.nodeDidInitialize(node: self)
      networkLayer?.nodeDidStart(node: self)
    }

  }
  
  public override func stop() {
    
    isStopping = true
    
    // If there is anything left in the output queue send the data and
    // don't worry about the replies to the sender as they will have
    // closed by now.
    
    timeoutTimer?.invalidate()
    timeoutTimer = nil
    
    var data : [UInt8] = []
    for item in queue {
      data.append(contentsOf: item.message.message)
    }
    send(data: data)
    
    currentItem = nil
    queue.removeAll()
    datagramBuffer.removeAll()

    if let serialPort {
      sendToSerialPortPipe?.close()
      sendToSerialPortPipe = nil
      serialPort.close()
    }
    else {
      buffer.removeAll()
      super.stop()
    }
    
  }
  
  // MARK: OpenLCBNetworkLayerDelegate Methods
  
  // This is running in the main thread
  public override func openLCBMessageReceived(message: OpenLCBMessage) {
 
    super.openLCBMessageReceived(message: message)
    
    guard state == .permitted else {
      return
    }
    
    switch message.messageTypeIndicator {
      
    case .datagram:

      let sourceNodeId = message.sourceNodeId!

      switch message.datagramType {
        
      case .sendLocoNetMessageCompleteCommand:
        
        let locoNetMessage = LocoNetMessage(data: [UInt8](message.payload.suffix(message.payload.count - 2)))
        
        if locoNetMessage.isCheckSumOK {

          sendDatagramReceivedOK(destinationNodeId: sourceNodeId, timeOut: .replyPendingNoTimeout)
          
          queue.append((nodeId:sourceNodeId, message:locoNetMessage))
          
          sendNext()
          
        }
        else {
          
          sendDatagramRejected(destinationNodeId: sourceNodeId, errorCode: .permanentErrorInvalidArguments)

        }
        
      case .sendLocoNetMessageFirstPartCommand:
        
        if datagramBuffer.keys.contains(sourceNodeId) {
          
          datagramBuffer.removeValue(forKey: sourceNodeId)
          
          sendDatagramRejected(destinationNodeId: sourceNodeId, errorCode: .temporaryErrorOutOfOrderFirstPartOfLocoNetMessageBeforeFinishingPreviousMessage)
          
        }
        else {
          
          datagramBuffer[sourceNodeId] = [UInt8](message.payload.suffix(message.payload.count - 2))
          
          sendDatagramReceivedOK(destinationNodeId: sourceNodeId, timeOut: .ok)
          
        }
        
      case .sendLocoNetMessageFinalPartCommand:
        
        if !datagramBuffer.keys.contains(sourceNodeId) {
          
          sendDatagramRejected(destinationNodeId: sourceNodeId, errorCode: .temporaryErrorOutOfOrderFinalPartOfLocoNetMessageBeforeFirstPart)
          
        }
        else {
          
          var data = datagramBuffer[sourceNodeId]!
          
          datagramBuffer.removeValue(forKey: sourceNodeId)
          
          data.append(contentsOf: [UInt8](message.payload.suffix(message.payload.count - 2)))
          
          let locoNetMessage = LocoNetMessage(data: data)
          
          if locoNetMessage.isCheckSumOK {

            sendDatagramReceivedOK(destinationNodeId: sourceNodeId, timeOut: .replyPendingNoTimeout)
            
            queue.append((nodeId:sourceNodeId, message:locoNetMessage))

            sendNext()
            
          }
          else {

            sendDatagramRejected(destinationNodeId: sourceNodeId, errorCode: .permanentErrorInvalidArguments)

          }
          
        }
        
      default:
        break
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
  
  //This is running in the main thread
  public func serialPortDidClose(_ serialPort: MTSerialPort) {
    self.serialPort = nil
    buffer.removeAll()
    if isStopping {
      isStopping = false
      super.stop()
    }
    else {
      #if DEBUG
      debugLog("serial port closed unexpectedly ")
      #endif
    }
  }
  
  public func serialPortDidDetach(_ serialPort: MTSerialPort) {

    state = .inhibited
                           
    // There is no serial port connection so reset everything to
    // start-up state.

    timeoutTimer?.invalidate()
    timeoutTimer = nil

    currentItem = nil
    queue.removeAll()
    datagramBuffer.removeAll()
    buffer.removeAll()
    isStopping = false

    sendToSerialPortPipe?.close()
    sendToSerialPortPipe = nil
                           
    self.serialPort = nil
                           
    networkLayer?.nodeDidDetach(node: self)
                           
  }

}
