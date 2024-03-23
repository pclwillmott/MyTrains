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
    initSpaceAddress(&addressMaxAliasesToCache, 1, &configurationSize)
    initSpaceAddress(&addressMinAliasesToCache, 1, &configurationSize)

    configuration = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, defaultMemorySize: configurationSize, isReadOnly: false, description: "")
    
    if let configuration {
      
      virtualNodeType = MyTrainsVirtualNodeType.canGatewayNode
      
      isFullProtocolRequired = true
      
      configuration.delegate = self
      
      memorySpaces[configuration.space] = configuration
      
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressDevicePath)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressMaxAliasesToCache)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressMinAliasesToCache)
      
      if !memorySpacesInitialized {
        resetToFactoryDefaults()
      }
      
      cdiFilename = "MyTrains CAN Gateway"
      
    }
    
    #if DEBUG
    addInit()
    #endif
    
  }
  
  deinit {
    
    serialPort = nil
    
    sendToSerialPortPipe = nil
    
    buffer.removeAll()
    
    managedAliases.removeAll()
    
    aliasLock = nil
    
    managedNodeIdLookup.removeAll()
    
    managedAliasLookup.removeAll()
    
    stoppedNodesLookup.removeAll()
    
    aliasLookup.removeAll()
    
    nodeIdLookup.removeAll()
    
    outputQueue.removeAll()
    
    outputQueueLock = nil
    
    inputQueueLock = nil
    
    inputQueue.removeAll()
    
    externalConsumedEventRanges.removeAll()
    
    internalConsumedEvents.removeAll()
    
    internalConsumedEventRanges.removeAll()
    
    waitOutputTimer?.invalidate()
    waitOutputTimer = nil
    
    waitInputTimer?.invalidate()
    waitInputTimer = nil
    
    aliasTimer?.invalidate()
    aliasTimer = nil
    
    splitFrames.removeAll()
    
    datagrams.removeAll()
    
    #if DEBUG
    addDeinit()
    #endif
    
  }
  
  // MARK: internal Properties
  
  // Configuration varaible addresses
  
  internal var addressDevicePath        = 0
  internal var addressMaxAliasesToCache = 0
  internal var addressMinAliasesToCache = 0

  internal var devicePath : String {
    get {
      return configuration!.getString(address: addressDevicePath, count: 256)!
    }
    set(value) {
      configuration!.setString(address: addressDevicePath, value: value, fieldSize: 256)
    }
  }
  
  internal var maxAliasesToCache : UInt8 {
    get {
      return configuration!.getUInt8(address: addressMaxAliasesToCache)!
    }
    set(value) {
      configuration!.setUInt(address: addressMaxAliasesToCache, value: value)
    }
  }
  
  internal var minAliasesToCache : UInt8 {
    get {
      return configuration!.getUInt8(address: addressMinAliasesToCache)!
    }
    set(value) {
      configuration!.setUInt(address: addressMinAliasesToCache, value: value)
    }
  }
  
  // Serial Port Control
  
  internal var serialPort : MTSerialPort?
  
  internal var sendToSerialPortPipe : MTPipe?
  
  internal var buffer : [UInt8] = []
  
  internal var isOpen : Bool {
    guard let port = serialPort else {
      return false
    }
    return port.isOpen
  }

  internal var waitingForNodeId : Set<UInt16> = []

  internal var waitingForAlias : Set<UInt64> = []

  internal var managedAliases : [UInt16:OpenLCBTransportLayerAlias] = [:]
  
  internal var aliasLock : NSLock? = NSLock()
  
  internal var managedNodeIdLookup : [UInt64:OpenLCBTransportLayerAlias] = [:]
  
  internal var managedAliasLookup : [UInt16:OpenLCBTransportLayerAlias] = [:]
  
  internal var stoppedNodesLookup : [UInt64:OpenLCBTransportLayerAlias] = [:]
  
  internal var aliasLookup : [UInt16:UInt64] = [:]
  
  internal var nodeIdLookup : [UInt64:UInt16] = [:]
  
  internal var outputQueue : [OpenLCBMessage] = []
  
  internal var outputQueueLock : NSLock? = NSLock()
  
  internal var inputQueueLock : NSLock? = NSLock()
  
  internal var inputQueue : [OpenLCBMessage] = []
  
  internal var internalNodes : Set<UInt64> = []
  
  internal var externalConsumedEvents : Set<UInt64> = []
  
  internal var externalConsumedEventRanges : [EventRange] = []
  
  internal var internalConsumedEvents : Set<UInt64> = []
  
  internal var internalConsumedEventRanges : [EventRange] = []
  
  internal let aliasWaitInterval : TimeInterval = 0.2
  
  internal var isStopping : Bool = false

  internal var waitOutputTimer : Timer?
  
  internal var waitInputTimer : Timer?
  
  internal var aliasTimer : Timer?
  
  internal var splitFrames : [UInt64:LCCCANFrame] = [:]
  
  internal var datagrams : [UInt32:OpenLCBMessage] = [:]
  
  // MARK: Public Properties
  
  public var gatewayNumber : Int = -1
  
  // MARK: internal Methods
  
  internal override func resetToFactoryDefaults() {
    
    super.resetToFactoryDefaults()
    
    configuration?.zeroMemory()
    
    minAliasesToCache = 16
    
    maxAliasesToCache = 64
    
    saveMemorySpaces()
    
  }
  
  override internal func customizeDynamicCDI(cdi:String) -> String {
    
    var result = MTSerialPortManager.insertMap(cdi: cdi)
    
    result = BaudRate.insertMap(cdi: result)
    result = Parity.insertMap(cdi: result)
    result = FlowControl.insertMap(cdi: result)
    
    return result
    
  }

  @objc func waitOutputTimerTick() {
    processOutputQueue()
  }
  
  internal func startWaitTimer(interval: TimeInterval) {
    waitOutputTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(waitOutputTimerTick), userInfo: nil, repeats: false)
    if let waitOutputTimer {
      RunLoop.current.add(waitOutputTimer, forMode: .common)
    }
    else {
      #if DEBUG
      debugLog("failed to create waitOutputTimer")
      #endif
    }
  }
  
  internal func stopWaitOutputTimer() {
    waitOutputTimer?.invalidate()
    waitOutputTimer = nil
  }

  @objc func waitInputTimerTick() {
    stopWaitInputTimer()
    DispatchQueue.global(qos: .userInteractive).async {
      self.processInputQueue()
    }
    
  }
  
  internal func startWaitInputTimer(interval: TimeInterval) {
    waitInputTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(waitInputTimerTick), userInfo: nil, repeats: false)
    if let waitInputTimer {
      RunLoop.current.add(waitInputTimer, forMode: .common)
    }
    else {
      #if DEBUG
      debugLog("failed to create waitInputTimer")
      #endif
    }
  }
  
  internal func stopWaitInputTimer() {
    waitInputTimer?.invalidate()
    waitInputTimer = nil
  }

  // MARK: Public Methods
  
  // This is running in the main thread
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

        if !internalNodes.contains(nodeId) {
          waitingForAlias.insert(nodeId)
          internalNodes.insert(nodeId)
          aliasTimerAction()
        }
        
      }
      
    }
    
    if !isOpen {
      #if DEBUG
      debugLog("serial port did not open")
      #endif
      appDelegate.networkLayer?.nodeDidInitialize(node: self)
      appDelegate.networkLayer?.nodeDidStart(node: self)
    }

  }
  
  public override func stop() {
 
    isStopping = true

    // There are no nodes left open to deliver a message to, so
    // kill the input queue.
    
    waitInputTimer?.invalidate()
    waitInputTimer = nil
    inputQueue = []
    aliasTimer?.invalidate()
    aliasTimer = nil
    waitingForNodeId = []
    splitFrames = [:]
    datagrams = [:]

    // Last chance to send anything in the output queue.
    
    waitOutputTimerTick()
    outputQueue = []
    waitingForAlias = []

    // Send alias map reset for all managed aliases.
    
    var frames : [LCCCANFrame] = []
    
    for (_, item) in managedAliases {
      frames.append(contentsOf: createAliasMapResetFrame(nodeId: item.nodeId, alias: item.alias))
    }
    
    send(frames: frames, isBackgroundThread: false)
    
    // Reset everything else to start-up state.
    
    managedAliases = [:]
    managedNodeIdLookup = [:]
    managedAliasLookup = [:]
    stoppedNodesLookup = [:]
    aliasLookup = [:]
    nodeIdLookup = [:]
    internalNodes = []
    externalConsumedEvents = []
    externalConsumedEventRanges = []
    internalConsumedEvents = []
    internalConsumedEventRanges = []
    
    // Close the port.
    
    if let serialPort {
      sendToSerialPortPipe?.close()
      sendToSerialPortPipe = nil
      serialPort.close()
    }
    else {
      isStopping = false
      buffer.removeAll()
      super.stop()
    }

  }
  
  // MARK: OpenLCBNetworkLayerDelegate Methods
  
  // This is running in the main thread
  public override func openLCBMessageReceived(message: OpenLCBMessage) {

    if message.sourceNodeId! != nodeId && (message.destinationNodeId == nil || message.destinationNodeId! == nodeId) {
      super.openLCBMessageReceived(message: message)
      if let id = message.destinationNodeId, id == nodeId {
        return
      }
    }
    
    if (state != .permitted) ||
       (message.routing.contains(nodeId) && message.sourceNodeId! != nodeId) ||
       (message.visibility.rawValue < OpenLCBNodeVisibility.visibilitySemiPublic.rawValue) {
      return
    }

    if let appNode, message.visibility == .visibilitySemiPublic {
  
      let validMessageTypes : Set<OpenLCBMTI> = [
        .producerConsumerEventReport,
        .producerIdentifiedAsCurrentlyValid,
        .producerIdentifiedAsCurrentlyInvalid,
        .producerIdentifiedWithValidityUnknown,
        .producerRangeIdentified,
        .consumerIdentifiedAsCurrentlyValid,
        .consumerIdentifiedAsCurrentlyInvalid,
        .consumerIdentifiedWithValidityUnknown,
        .consumerRangeIdentified,
      ]
      
      if !validMessageTypes.contains(message.messageTypeIndicator) {
        return
      }
      
      message.sourceNodeId = appNode.nodeId
      
    }
    
    // A message at this point could have come internally or externally from another gateway
    if let sourceNodeId = message.sourceNodeId, !waitingForAlias.contains(sourceNodeId) && !nodeIdLookup.keys.contains(sourceNodeId) {
      waitingForAlias.insert(sourceNodeId)
      internalNodes.insert(sourceNodeId)
      aliasTimerAction()
    }
    else if !outputQueue.isEmpty {
      aliasTimerAction()
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
        debugLog("Producer Consumer Event Report without Event Id")
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

    outputQueue.append(message)

    processOutputQueue()

  }

  // MARK: MTSerialPortDelegate Methods
  
  // This is running in the serial port's background thread
  public func serialPort(_ serialPort: MTSerialPort, didReceive data: [UInt8]) {
    buffer.append(contentsOf: data)
    parseInput()
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
    
    waitInputTimer?.invalidate()
    waitInputTimer = nil
    waitOutputTimer?.invalidate()
    waitOutputTimer = nil
    aliasTimer?.invalidate()
    aliasTimer = nil
    inputQueueLock!.lock()
    inputQueue = []
    inputQueueLock!.unlock()
    waitingForNodeId = []
    splitFrames = [:]
    datagrams = [:]
    outputQueueLock!.lock()
    outputQueue = []
    outputQueueLock!.unlock()
    waitingForAlias = []
    managedAliases = [:]
    managedNodeIdLookup = [:]
    managedAliasLookup = [:]
    stoppedNodesLookup = [:]
    aliasLookup = [:]
    nodeIdLookup = [:]
    internalNodes = []
    externalConsumedEvents = []
    externalConsumedEventRanges = []
    internalConsumedEvents = []
    internalConsumedEventRanges = []
    buffer.removeAll()
    isStopping = false

    sendToSerialPortPipe?.close()
    sendToSerialPortPipe = nil
    
    self.serialPort = nil
    
    appDelegate.networkLayer?.nodeDidDetach(node: self)
    
  }
  
}
