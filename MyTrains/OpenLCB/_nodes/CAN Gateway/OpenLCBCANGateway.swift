//
//  OpenLCBCANGateway.swift
//  MyTrains
//
//  Created by Paul Willmott on 09/07/2023.
//

import Foundation

public class OpenLCBCANGateway : OpenLCBNodeVirtual, MTSerialPortDelegate, MTSerialPortManagerDelegate {
 
  // MARK: Constructors & Destructors
  
  public override init(nodeId:UInt64) {
    
    super.init(nodeId: nodeId)

    var configurationSize = 0

    initSpaceAddress(&addressDevicePath, 256, &configurationSize)
    initSpaceAddress(&addressBaudRate, 1, &configurationSize)
    initSpaceAddress(&addressParity, 1, &configurationSize)
    initSpaceAddress(&addressFlowControl, 1, &configurationSize)
    initSpaceAddress(&addressMaxAliasesToCache, 1, &configurationSize)
    initSpaceAddress(&addressMinAliasesToCache, 1, &configurationSize)

    configuration = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, defaultMemorySize: configurationSize, isReadOnly: false, description: "")
    
    if let configuration {
      
      virtualNodeType = MyTrainsVirtualNodeType.canGatewayNode
      
      isFullProtocolRequired = true
      
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
  
  internal var addressDevicePath        = 0
  internal var addressBaudRate          = 0
  internal var addressParity            = 0
  internal var addressFlowControl       = 0
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
    if let port = serialPort {
      return port.isOpen
    }
    return false
  }
  
  internal var waitingForNodeId : Set<UInt16> = []

  internal var waitingForAlias : Set<UInt64> = []

  internal var managedAliases : [UInt16:OpenLCBTransportLayerAlias] = [:]
  
  internal var aliasLock = NSLock()
  
  internal var managedNodeIdLookup : [UInt64:OpenLCBTransportLayerAlias] = [:]
  
  internal var managedAliasLookup : [UInt16:OpenLCBTransportLayerAlias] = [:]
  
  internal var stoppedNodesLookup : [UInt64:OpenLCBTransportLayerAlias] = [:]
  
  internal var aliasLookup : [UInt16:UInt64] = [:]
  
  internal var nodeIdLookup : [UInt64:UInt16] = [:]
  
  internal var outputQueue : [OpenLCBMessage] = []
  
  internal var outputQueueLock = NSLock()
  
  internal var inputQueueLock = NSLock()
  
  internal var inputQueue : [OpenLCBMessage] = []
  
  internal var internalNodes : Set<UInt64> = []
  
  internal var externalConsumedEvents : Set<UInt64> = []
  
  internal var externalConsumedEventRanges : [EventRange] = []
  
  internal var internalConsumedEvents : Set<UInt64> = []
  
  internal var internalConsumedEventRanges : [EventRange] = []
  
  internal let aliasWaitInterval : TimeInterval = 0.2 /* should be 0.2 but adding some latency */
  
  internal var isStopping : Bool = false

  internal var waitTimer : Timer?
  
  internal var waitInputTimer : Timer?
  
  internal var aliasTimer : Timer?
  
  internal var splitFrames : [UInt64:LCCCANFrame] = [:]
  
  internal var datagrams : [UInt32:OpenLCBMessage] = [:]
  
  // MARK: internal Methods
  
  internal override func resetToFactoryDefaults() {
    
    super.resetToFactoryDefaults()
    
    devicePath = ""
    
    baudRate = .br9600
    
    flowControl = .noFlowControl
    
    parity = .none
    
    minAliasesToCache = 16
    
    maxAliasesToCache = 64
    
    saveMemorySpaces()
    
  }
  
  // This is running in the main thread
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
        
        if !internalNodes.contains(nodeId) {
          
          waitingForAlias.insert(nodeId)
          
          internalNodes.insert(nodeId)
          
          aliasTimerAction()
          
        }
        
      }
      
    }
    else {
      networkLayer?.gatewayIsInitialized(nodeId: nodeId)
    }

  }
  
  public override func completeStartUp() {
    networkLayer?.gatewayIsInitialized(nodeId: nodeId)
  }

  public override func gatewayStart() {
    
    close()
    
    buffer.removeAll()
    
    nodeIdLookup.removeAll()
    
    aliasLookup.removeAll()
    
    internalNodes.removeAll()

    setupConfigurationOptions()

    isConfigurationDescriptionInformationProtocolSupported = true

    openSerialPort()
    
  }
  
  internal override func resetReboot() {

    super.resetReboot()
    
  }
  
  override internal func customizeDynamicCDI(cdi:String) -> String {
    
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
    
  @objc func waitTimerTick() {
    stopWaitTimer()
    processOutputQueue()
  }
  
  internal func startWaitTimer(interval: TimeInterval) {
    waitTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(waitTimerTick), userInfo: nil, repeats: false)
    if let waitTimer {
      RunLoop.current.add(waitTimer, forMode: .common)
    }
    else {
      #if DEBUG
      debugLog("failed to create waitTimer")
      #endif
    }
  }
  
  internal func stopWaitTimer() {
    waitTimer?.invalidate()
    waitTimer = nil
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
  
  // MARK: OpenLCBNetworkLayerDelegate Methods
  
  // This is running in the main thread
  public override func openLCBMessageReceived(message: OpenLCBMessage) {
 
    if state != .permitted {
      return
    }

    // A message might be for the gateway node itself
    if !message.messageTypeIndicator.isAddressPresent || (message.destinationNodeId != nil && message.destinationNodeId! == nodeId) {
      super.openLCBMessageReceived(message: message)
    }
    
    if message.visibility.rawValue < OpenLCBNodeVisibility.visibilitySemiPublic.rawValue {
      return
    }
    else if let appNode, message.visibility == .visibilitySemiPublic {
      
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
  
  // MARK: MTSerialPortManagerDelegate Methods
  
  // This is running in the main thread
  @objc public func serialPortWasAdded(path:String) {
    
    guard path == devicePath, serialPort == nil else {
      return
    }
    
    openSerialPort()
    
  }
  
}
