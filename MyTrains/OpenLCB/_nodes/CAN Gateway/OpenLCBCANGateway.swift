//
//  OpenLCBCANGateway.swift
//  MyTrains
//
//  Created by Paul Willmott on 09/07/2023.
//

import Foundation

public class OpenLCBCANGateway : OpenLCBNodeVirtual, MTSerialPortDelegate {
 
  // MARK: Constructors & Destructors
  
  public override init(nodeId:UInt64) {
    
    super.init(nodeId: nodeId)

    var configurationSize = 0

    initSpaceAddress(&addressDevicePath, 256, &configurationSize)
    initSpaceAddress(&addressBaudRate, 1, &configurationSize)
    initSpaceAddress(&addressParity, 1, &configurationSize)
    initSpaceAddress(&addressFlowControl, 1, &configurationSize)

    configuration = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, defaultMemorySize: configurationSize, isReadOnly: false, description: "")
    
    if let configuration {
      
      virtualNodeType = MyTrainsVirtualNodeType.canGatewayNode
      
      configuration.delegate = self
      
      memorySpaces[configuration.space] = configuration
      
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressDevicePath)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressBaudRate)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressParity)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressFlowControl)
      
      if !memorySpacesInitialized {
        resetToFactoryDefaults()
      }
      
      cdiFilename = "MyTrains CAN Gateway"
      
    }
    
  }
  
  deinit {
    if isOpen {
      close()
    }
  }

  // MARK: internal Properties
  
  // Configuration varaible addresses
  
  internal var addressDevicePath  = 0
  internal var addressBaudRate    = 0
  internal var addressParity      = 0
  internal var addressFlowControl = 0

  internal var devicePath : String {
    get {
      return configuration!.getString(address: addressDevicePath, count: 256)!
    }
    set(value) {
      configuration!.setString(address: addressDevicePath, value: value, fieldSize: 256)
    }
  }
  
  internal var baudRate : BaudRate {
    get {
      return BaudRate(rawValue: configuration!.getUInt8(address: addressBaudRate)!)!
    }
    set(value) {
      configuration!.setUInt(address: addressBaudRate, value: value.rawValue)
    }
  }

  internal var parity : Parity {
    get {
      return Parity(rawValue: configuration!.getUInt8(address: addressParity)!)!
    }
    set(value) {
      configuration!.setUInt(address: addressBaudRate, value: value.rawValue)
    }
  }
  
  internal var flowControl : FlowControl {
    get {
      return FlowControl(rawValue: configuration!.getUInt8(address: addressFlowControl)!)!
    }
    set(value) {
      configuration!.setUInt(address: addressBaudRate, value: value.rawValue)
    }
  }
  
  // Serial Port Control
  
  internal var serialPort : MTSerialPort?
  
  internal var buffer : [UInt8] = []
  
  internal var isOpen : Bool {
    if let port = serialPort {
      return port.isOpen
    }
    return false
  }

  internal var observers : [Int:OpenLCBCANDelegate] = [:]

  internal var nextObserverId : Int = 0

  internal var initNodeQueue : [OpenLCBTransportLayerAlias] = []
  
  internal var managedNodeIdLookup : [UInt64:OpenLCBTransportLayerAlias] = [:]
  
  internal var managedAliasLookup : [UInt16:OpenLCBTransportLayerAlias] = [:]
  
  internal var stoppedNodesLookup : [UInt64:OpenLCBTransportLayerAlias] = [:]
  
  internal var outputQueue : [OpenLCBMessage] = []
  
  internal var outputQueueLock : NSLock = NSLock()
  
  internal var inputQueue : [OpenLCBMessage] = []
  
  internal var inputQueueLock : NSLock = NSLock()
  
  internal var internalNodes : Set<UInt64> = []
  
  internal var externalConsumedEvents : Set<UInt64> = []
  
  internal var externalConsumedEventRanges : [EventRange] = []
  
  internal var internalConsumedEvents : Set<UInt64> = []
  
  internal var internalConsumedEventRanges : [EventRange] = []
  
  internal let aliasWaitInterval : TimeInterval = 0.2
  
  internal let timeoutInterval : TimeInterval = 3.0
  
  internal var isStopping : Bool = false

  internal var waitTimer : Timer?
  
  internal var aliasTimer : Timer?
  
  internal var aliasLock : NSLock = NSLock()
  
  internal var inGetAlias : Bool = false
    
  internal var aliasLookup : [UInt16:UInt64] = [:]
  
  internal var nodeIdLookup : [UInt64:UInt16] = [:]
  
  internal var splitFrames : [UInt64:LCCCANFrame] = [:]
  
  internal var datagrams : [UInt32:OpenLCBMessage] = [:]
  
  internal var datagramsAwaitingReceipt : [UInt32:OpenLCBMessage] = [:]
  
  internal var isProcessingInputQueue : Bool = false
  internal var isProcessingOutputQueue : Bool = false

  internal var processInputQueueLock : NSLock = NSLock()
  internal var processOutputQueueLock : NSLock = NSLock()

  internal var lastTimeStamp : TimeInterval = 0.0
  
  // MARK: internal Methods
  
  internal override func resetToFactoryDefaults() {
    
    super.resetToFactoryDefaults()
    
    devicePath = ""
    
    baudRate = .br9600
    
    flowControl = .noFlowControl
    
    parity = .none
    
    saveMemorySpaces()
    
  }
  
  internal override func resetReboot() {

    super.resetReboot()
    
    close()
    
    buffer.removeAll()
    
    nodeIdLookup.removeAll()
    
    aliasLookup.removeAll()
    
    internalNodes.removeAll()

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
  
  override internal func customizeDynamicCDI(cdi:String) -> String {
    
    var result = MTSerialPortManager.insertMap(cdi: cdi)
    
    result = BaudRate.insertMap(cdi: result)
    result = Parity.insertMap(cdi: result)
    result = FlowControl.insertMap(cdi: result)
    
    return result
    
  }

  internal func close() {
    serialPort?.close()
    serialPort = nil
  }
  
  internal func processQueues() {
    
    if !initNodeQueue.isEmpty {
      return
    }
    
    processQueueLock.lock()
    let ok = !inProcessQueue
    if ok {
      inProcessQueue = true
    }
    processQueueLock.unlock()
    
    if !ok {
      return
    }
    
    // Input Queue
    
    let referenceDate = Date.timeIntervalSinceReferenceDate
    
    if !inputQueue.isEmpty {
      
      var sendQuery = false
      
      var index = 0
      
      while index < inputQueue.count {
        
        let message = inputQueue[index]
        
        if message.sourceNodeId == nil, let alias = message.sourceNIDAlias {
          if let id = aliasLookup[alias] {
            message.sourceNodeId = id
          }
          else {
            sendQuery = true
          }
        }
        
        if (message.messageTypeIndicator.isAddressPresent || message.messageTypeIndicator == .datagram) && message.destinationNodeId == nil, let alias = message.destinationNIDAlias {
          if let id = aliasLookup[alias] {
            message.destinationNodeId = id
          }
          else {
            sendQuery = true
          }
        }
        
        var delete = false
        
        if message.isMessageComplete {
          
          var route = true
          
          switch message.messageTypeIndicator {
            
          case .initializationCompleteSimpleSetSufficient, .initializationCompleteFullProtocolRequired:
            
            for (key, datagram) in datagramsAwaitingReceipt {
              if datagram.destinationNodeId == message.sourceNodeId {
                datagramsAwaitingReceipt.removeValue(forKey: key)
              }
            }
            
          case .datagramReceivedOK:
            
            datagramsAwaitingReceipt.removeValue(forKey: message.datagramIdReversed)
            
          case .datagramRejected:
            
            if let datagram = datagramsAwaitingReceipt[message.datagramIdReversed] {
              datagramsAwaitingReceipt.removeValue(forKey: message.datagramIdReversed)
              if message.errorCode.isTemporary {
                addToOutputQueue(message: datagram)
              }
            }
            
          case .consumerIdentifiedAsCurrentlyValid, .consumerIdentifiedAsCurrentlyInvalid, .consumerIdentifiedWithValidityUnknown:
            
            externalConsumedEvents.insert(message.eventId!)

          case .consumerRangeIdentified:
            
            if let range = message.eventRange {
              
              var found = false
              
              for r in externalConsumedEventRanges {
                if r.eventId == range.eventId {
                  found = true
                  break
                }
              }
              
              if !found {
                externalConsumedEventRanges.append(range)
              }
              
            }

          case .producerConsumerEventReport:
            
            if let eventId = message.eventId {
              
              if !(message.isAutomaticallyRoutedEvent || internalConsumedEvents.contains(eventId)) {
                
                var found = false
                
                for range in internalConsumedEventRanges {
                  if eventId >= range.startId && eventId <= range.endId {
                    found = true
                    break
                  }
                }
                
                if !found {
                  route = false
                }
                
              }
              
            }
            else {
              #if DEBUG
              print("OpenLCBCANGateway.processQueues: producerConsumerEventReport without eventId")
              #endif
            }

          default:
            break
          }

          if route {
            networkLayer?.sendMessage(gatewayNodeId: nodeId, message: message)
          }
          
          delete = true
          
        }
        else if (referenceDate - message.timeStamp) > timeoutInterval {
       //   delete = true
        }
        
        if delete {
          inputQueueLock.lock()
          inputQueue.remove(at: index)
          inputQueueLock.unlock()
        }
        else {
          index += 1
        }
        
      }
      
      if sendQuery, let alias = nodeIdLookup[nodeId] {
        sendAliasMappingEnquiryFrame(alias: alias)
      }
            
    }
    
    // Output Queue
    
    if !outputQueue.isEmpty {
      
      var index = 0
      
      while index < outputQueue.count {
        
        let message = outputQueue[index]
        
        if let alias = nodeIdLookup[message.sourceNodeId!] {
          
          message.sourceNIDAlias = alias
          
          if (message.messageTypeIndicator == .datagram ) || message.messageTypeIndicator.isAddressPresent, let destinationNodeId = message.destinationNodeId {
            
            if let alias = nodeIdLookup[destinationNodeId] {
              message.destinationNIDAlias = alias
            }
            else {
              sendAliasMappingEnquiryFrame(nodeId: destinationNodeId, alias: alias)
            }
            
          }
          
        }
        else {
          #if DEBUG
          print("OpenLCBCANGateway.processQueues: send source alias not found: \(message.sourceNodeId!.toHexDotFormat(numberOfBytes: 6))")
          #endif
        }
        
        var delete = false
        
        if message.isMessageComplete {
          
          if message.messageTypeIndicator == .datagram {

            datagramsAwaitingReceipt[message.datagramId] = message

            if message.payload.count <= 8 {
              if let frame = LCCCANFrame(message: message, canFrameType: .datagramCompleteInFrame, data: message.payload) {
                send(data: frame.message)
              }
            }
            else {
              
              let numberOfFrames = message.payload.count == 0 ? 1 : 1 + (message.payload.count - 1) / 8
              
              for frameNumber in 1...numberOfFrames {
                
                var canFrameType : OpenLCBMessageCANFrameType = .datagramMiddleFrame
                
                if frameNumber == 1 {
                  canFrameType = .datagramFirstFrame
                }
                else if frameNumber == numberOfFrames {
                  canFrameType = .datagramFinalFrame
                }
                
                var data : [UInt8] = []
                
                var index = (frameNumber - 1) * 8
                
                var count = 0
                
                while index < message.payload.count && count < 8 {
                  data.append(message.payload[index])
                  index += 1
                  count += 1
                }
                
                if let frame = LCCCANFrame(message: message, canFrameType: canFrameType, data: data) {
                  send(data: frame.message)
                }
                
              }
              
            }
            
            delete = true
            
          }
          else if message.messageTypeIndicator == .producerConsumerEventReport {
            
            var data : [UInt8] = []
            
            data.append(contentsOf: message.eventId!.bigEndianData)
            data.append(contentsOf: message.payload)
            
            let numberOfFrames = 1 + (data.count - 1) / 8
            
            if numberOfFrames == 1 {
              if let frame = LCCCANFrame(message: message) {
                send(data: frame.message)
              }
            }
            else {
              
              for frameNumber in 1 ... numberOfFrames {
                
                switch frameNumber {
                case 1:
                  message.messageTypeIndicator = .producerConsumerEventReportWithPayloadFirstFrame
                case numberOfFrames:
                  message.messageTypeIndicator = .producerConsumerEventReportWithPayloadLastFrame
                default:
                  message.messageTypeIndicator = .producerConsumerEventReportWithPayloadMiddleFrame
                }
                
                let payload : [UInt8] = [UInt8](data.prefix(8))
                
                data.removeFirst(payload.count)
                
                if let frame = LCCCANFrame(pcerMessage: message, payload: payload) {
                  send(data: frame.message)
                }
              
              }
              
            }
            
            delete = true
            
          }
          else if message.messageTypeIndicator.isAddressPresent {
            
            if let frame = LCCCANFrame(message: message) {
              
              if frame.data.count <= 8 {
                send(data: frame.message)
              }
              else {
                
                let numberOfFrames = 1 + (frame.data.count - 3 ) / 6
                
                for frameNumber in 1...numberOfFrames {
                  
                  var flags : OpenLCBCANFrameFlag = .middleFrame
                  
                  if frameNumber == 1 {
                    flags = .firstFrame
                  }
                  else if frameNumber == numberOfFrames {
                    flags = .lastFrame
                  }
                  
                  if let frame = LCCCANFrame(message: message, flags: flags, frameNumber: frameNumber) {
                    send(data: frame.message)
                  }
                  
                }
                
              }
              
            }
            
            delete = true
            
          }
          else if let frame = LCCCANFrame(message: message) {
            send(data: frame.message)
            delete = true
          }
          
        }
        else if (referenceDate - message.timeStamp) > timeoutInterval {
   //       delete = true
        }
        
        if delete {
          outputQueueLock.lock()
          outputQueue.remove(at: index)
          outputQueueLock.unlock()
        }
        else {
          index += 1
        }
        
      }
      
    }

    if !inputQueue.isEmpty || !outputQueue.isEmpty {
      startWaitTimer(interval: aliasWaitInterval)
    }
    else if isStopping {
      close()
    }
    
    inProcessQueue = false
    
  }
  
  @objc func waitTimerTick() {
    stopWaitTimer()
    processQueues()
  }
  
  internal func startWaitTimer(interval: TimeInterval) {
    waitTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(waitTimerTick), userInfo: nil, repeats: false)
    RunLoop.current.add(waitTimer!, forMode: .common)
  }
  
  internal func stopWaitTimer() {
    waitTimer?.invalidate()
    waitTimer = nil
  }

  // MARK: Public Methods
  
  public override func start() {
    super.start()
  }
  
  public override func stop() {
    
    var nodeIds : [UInt64] = []
    
    for (nodeId, _) in nodeIdLookup {
      nodeIds.append(nodeId)
    }
    
    while !nodeIds.isEmpty {
      let nodeId = nodeIds.removeFirst()
      removeNodeIdAliasMapping(nodeId: nodeId)
    }
    
    close()
    
    super.stop()
    
  }
  
  public func addObserver(observer:OpenLCBCANDelegate) -> Int {
    let id = nextObserverId
    nextObserverId += 1
    observers[id] = observer
    return id
  }
  
  public func removeObserver(id:Int) {
    observers.removeValue(forKey: id)
  }
  
  // MARK: OpenLCBNetworkLayerDelegate Methods
  
  public override func openLCBMessageReceived(message: OpenLCBMessage) {
 
    super.openLCBMessageReceived(message: message)
    
    if let sourceNodeId = message.sourceNodeId, !internalNodes.contains(sourceNodeId) {
      
      internalNodes.insert(sourceNodeId)
      
      let alias = OpenLCBTransportLayerAlias(nodeId: sourceNodeId)
      
      initNodeQueue.append(alias)
      
      getAlias()

    }

    if let destinationNodeId = message.destinationNodeId, destinationNodeId == networkLayerNodeId {
      return
    }
    if let sourceNodeId = message.sourceNodeId, sourceNodeId == networkLayerNodeId {
      return
    }

    switch message.messageTypeIndicator {
      
    case .producerConsumerEventReport:
      
      if let eventId = message.eventId {
        
        if !(message.isAutomaticallyRoutedEvent || externalConsumedEvents.contains(eventId)) {
          
          var found = false
          
          for range in externalConsumedEventRanges {
            if eventId >= range.startId && eventId <= range.endId {
              found = true
              break
            }
          }
          
          if !found {
            return
          }
          
        }
        
      }
      else {
        #if DEBUG
        print("OpenLCBCANGateway.openLCBMessageReceived: producerConsumerEventReport without eventId")
        #endif
      }
      
    case .consumerIdentifiedAsCurrentlyValid, .consumerIdentifiedAsCurrentlyInvalid, .consumerIdentifiedWithValidityUnknown:
      
      internalConsumedEvents.insert(message.eventId!)
      
    case .consumerRangeIdentified:
      
      if let range = message.eventRange {
        
        var found = false
        
        for r in internalConsumedEventRanges {
          if r.eventId == range.eventId {
            found = true
            break
          }
        }
        
        if !found {
          internalConsumedEventRanges.append(range)
        }

      }
      
    default:
      break
    }
    
    addToOutputQueue(message: message)
    
  }


  // MARK: MTSerialPortDelegate Methods
  
  public func serialPort(_ serialPort: MTSerialPort, didReceive data: [UInt8]) {
    buffer.append(contentsOf: data)
    parseInput()
  }
  
  public func serialPortWasOpened(_ serialPort: MTSerialPort) {

    #if DEBUG
    print("serial port was opened: \(serialPort.path)")
    #endif
    
    if !internalNodes.contains(nodeId) {
      
      internalNodes.insert(nodeId)
      
      let alias = OpenLCBTransportLayerAlias(nodeId: nodeId)
      
      initNodeQueue.append(alias)
      
      getAlias()
      
    }

  }
  
  public func serialPortWasRemovedFromSystem(_ serialPort: MTSerialPort) {
    #if DEBUG
    print("serial port was removed from system: \(serialPort.path)")
    #endif
    self.serialPort = nil
  }
  
  public func serialPortWasClosed(_ serialPort: MTSerialPort) {
    #if DEBUG
    print("serial port was closed: \(serialPort.path)")
    #endif
    self.serialPort = nil
  }

  public func serialPortWasAdded(_ serialPort: MTSerialPort) {
    if !isOpen {
      resetReboot()
    }
  }

}
