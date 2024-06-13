//
//  OpenLCBLocoNetGateway.swift
//  MyTrains
//
//  Created by Paul Willmott on 01/07/2023.
//

import Foundation

internal enum LocoNetGatewayMode {

  // MARK: Enumeration
  
  case idle
  case sendingMessage
  case waitingForIMMPacketAck
  case waitingForSetSwAck
  case disconnected
  
}

public class LocoNetGateway : OpenLCBNodeVirtual, MTSerialPortDelegate {
 
  // MARK: Constructors & Destructors
  
  public override init(nodeId:UInt64) {
    
    super.init(nodeId: nodeId)
    
    var configurationSize = 0

    initSpaceAddress(&addressDevicePath, 256, &configurationSize)

    configuration = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, defaultMemorySize: configurationSize, isReadOnly: false, description: "")
    
    if let configuration {
      
      virtualNodeType = MyTrainsVirtualNodeType.locoNetGatewayNode
      
      isFullProtocolRequired = false
      
      configuration.delegate = self
      
      memorySpaces[configuration.space] = configuration
      
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressDevicePath)
      
      if !memorySpacesInitialized {
        resetToFactoryDefaults()
      }
            
      cdiFilename = "MyTrains LocoNet Gateway"
      
    }
    
    #if DEBUG
    addInit()
    #endif
    
  }
  
  deinit {
    serialPort = nil
    buffer.removeAll()
    sendToSerialPortPipe = nil
    queue.removeAll()
    queueLock = nil
    timeoutTimer?.invalidate()
    timeoutTimer = nil
    currentItem = nil
    #if DEBUG
    addDeinit()
    #endif
  }
  
  // MARK: Private Properties
  
  // Configuration varaible addresses
  
  internal var addressDevicePath = 0

  internal var isStopping : Bool = false
  
  internal var mode : LocoNetGatewayMode = .disconnected {
    didSet {
      switch mode {
      case .disconnected:
        for (_, observer) in observers {
          observer.locoNetDisconnected?(gateway: self)
        }
      default:
        break
      }
    }
  }

  internal var serialPort : MTSerialPort?
  
  internal var buffer : [UInt8] = []
  
  internal var sendToSerialPortPipe : MTPipe?
  
  internal var isOpen : Bool {
    guard let port = serialPort else {
      return false
    }
    return port.isOpen
  }

  private var queue : [LocoNetMessage] = []
  
  private var queueLock : NSLock? = NSLock()
  
  private var currentItem : LocoNetMessage?
  
  private var timeoutTimer : Timer?
  
  private var retryCount = 0
  
  private var ackRetryCount = 0
  
  private var lastTimeStamp : TimeInterval = 0
  
  private var observers : [UInt64:LocoNetGatewayDelegate] = [:]
  
  // MARK: Public Properties
  
  public var commandStationType : LocoNetCommandStationType = .standAlone
  
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
        
        let locoNetMessage = LocoNetMessage(data: message)
        locoNetMessage.timeStamp = Date.timeIntervalSinceReferenceDate
        locoNetMessage.timeSinceLastMessage = locoNetMessage.timeStamp - lastTimeStamp
        lastTimeStamp = locoNetMessage.timeStamp

        if let currentItem {
          
          if message == currentItem.message {
            stopTimeoutTimer()
            switch currentItem.messageType {
            case .immPacket:
              mode = .waitingForIMMPacketAck
              startTimeoutTimer(numberOfBytes: 4)
            case .setSwWithAck:
              mode = .waitingForSetSwAck
              startTimeoutTimer(numberOfBytes: 4)
            default:
              DispatchQueue.main.async {
                self.currentItem = nil
                self.sendNext()
              }
            }
          }
          else {
            
            switch mode {
            case .waitingForIMMPacketAck:
              switch locoNetMessage.messageType {
              case .immPacketOK:
                stopTimeoutTimer()
                DispatchQueue.main.async {
                  self.mode = .idle
                  self.currentItem = nil
                  self.sendNext()
                }
              case .immPacketBufferFull:
                stopTimeoutTimer()
                mode = .sendingMessage
                retryCount = 10
                startTimeoutTimer(numberOfBytes: currentItem.message.count)
                send(data: currentItem.message)
              default:
                break
              }
            case .waitingForSetSwAck:
              switch locoNetMessage.messageType {
              case .setSwWithAckAccepted:
                stopTimeoutTimer()
                DispatchQueue.main.async {
                  self.mode = .idle
                  self.currentItem = nil
                  self.sendNext()
                }
              case .setSwWithAckRejected:
                stopTimeoutTimer()
                mode = .sendingMessage
                retryCount = 10
                startTimeoutTimer(numberOfBytes: currentItem.message.count)
                send(data: currentItem.message)
              default:
                break
              }
            default:
              break
            }
          }
          
        }
        
        if locoNetMessage.messageType == .opSwDataAP1 {
          commandStationType = LocoNetCommandStationType(rawValue: UInt16(locoNetMessage.message[11])) ?? .standAlone
        }
      
        DispatchQueue.main.async {
          for (_, observer) in self.observers {
            observer.locoNetMessageReceived?(message: locoNetMessage)
          }
        }

      }

    }
    
  }
  
  private func sendNext() {
    
    guard currentItem == nil, !queue.isEmpty, let queueLock else {
      return
    }
    
    queueLock.lock()
    currentItem = queue.removeFirst()
    queueLock.unlock()
    
    if let currentItem {
      mode = .sendingMessage
      retryCount = 10
      startTimeoutTimer(numberOfBytes: currentItem.message.count)
      send(data: currentItem.message)
    }

  }
  
  internal func addToQueue(message:LocoNetMessage) {
    
    guard let queueLock else {
      return
    }
    
    queueLock.lock()
    queue.append(message)
    queueLock.unlock()
    
    sendNext()
    
  }
  
  @objc func timeoutTimerAction() {
    
    if let currentItem {
      
      switch mode {
      case .sendingMessage:
        retryCount -= 1
        if retryCount == 0 {
          self.currentItem = nil
          sendNext()
        }
        else {
          startTimeoutTimer(numberOfBytes: currentItem.message.count)
          send(data: currentItem.message)
        }
      default:
        self.currentItem = nil
        sendNext()
      }
      
    }
    
  }
  
  private func startTimeoutTimer(numberOfBytes:Int) {
    let interval: TimeInterval = Double(numberOfBytes * 10) / 16660.0 * 3.0
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
        mode = .idle
        for (_, observer) in observers {
          observer.locoNetConnected?(gateway: self)
        }
        
        getOpSwDataAP1()

      }
      
    }
    
    if !isOpen {
      #if DEBUG
      debugLog("serial port did not open")
      #endif
      appDelegate.networkLayer?.nodeDidInitialize(node: self)
      appDelegate.networkLayer?.nodeDidStart(node: self)
      mode = .disconnected
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
      data.append(contentsOf: item.message)
    }
    send(data: data)
    
    currentItem = nil
    queue.removeAll()
    
    mode = .disconnected

    if let serialPort {
      sendToSerialPortPipe?.close()
      sendToSerialPortPipe = nil
      serialPort.close()
    }
    else {
      buffer.removeAll()
      super.stop()
    }
    
    observers.removeAll()
        
  }
  
  public func addObserver(observer:LocoNetGatewayDelegate) {
    observers[observer.nodeId] = observer
  }
  
  public func removeObserver(observer:LocoNetGatewayDelegate) {
    observers.removeValue(forKey: observer.nodeId)
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
    
    mode = .disconnected
                           
    // There is no serial port connection so reset everything to
    // start-up state.

    timeoutTimer?.invalidate()
    timeoutTimer = nil

    currentItem = nil
    
    queue.removeAll()
    buffer.removeAll()
    isStopping = false

    sendToSerialPortPipe?.close()
    sendToSerialPortPipe = nil
                           
    self.serialPort = nil
                           
    appDelegate.networkLayer?.nodeDidDetach(node: self)
                           
  }

}
