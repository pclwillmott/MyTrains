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
  
  // internal var datagramsAwaitingReceipt : [UInt32:OpenLCBMessage] = [:]
  
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
  
  
  @objc func waitTimerTick() {
    stopWaitTimer()
//    processQueues()
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
        debugLog(message: "Producer Consumer Event Report without Event Id")
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
    debugLog(message: "\(serialPort.path)")
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
    debugLog(message: "\(serialPort.path)")
    #endif
    self.serialPort = nil
  }
  
  public func serialPortWasClosed(_ serialPort: MTSerialPort) {
    #if DEBUG
    debugLog(message: "\(serialPort.path)")
    #endif
    self.serialPort = nil
  }

  public func serialPortWasAdded(_ serialPort: MTSerialPort) {
    #if DEBUG
    debugLog(message: "\(serialPort.path)")
    #endif
    if !isOpen {
      resetReboot()
    }
  }

}
