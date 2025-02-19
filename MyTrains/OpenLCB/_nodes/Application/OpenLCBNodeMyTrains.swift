//
//  OpenLCBNodeMyTrains.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/05/2023.
//

import Foundation
import AppKit
import SGUnitConversion

public class OpenLCBNodeMyTrains : OpenLCBNodeVirtual {
  
  // MARK: Constructors & Destructors
  
  public override init(nodeId:UInt64) {
    
    super.init(nodeId: nodeId)

    var configurationSize = MyTrainsViewType.numberOfTypes * 2
    
    viewOptions = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.viewOptions.rawValue, defaultMemorySize: configurationSize, isReadOnly: false, description: "")
    
    configurationSize = 0
    
    initSpaceAddress(&addressUnitsActualLength,   1, &configurationSize)
    initSpaceAddress(&addressUnitsScaleLength,    1, &configurationSize)
    initSpaceAddress(&addressUnitsActualDistance, 1, &configurationSize)
    initSpaceAddress(&addressUnitsScaleDistance,  1, &configurationSize)
    initSpaceAddress(&addressUnitsActualSpeed,    1, &configurationSize)
    initSpaceAddress(&addressUnitsScaleSpeed,     1, &configurationSize)
    initSpaceAddress(&addressUnitsTime,           1, &configurationSize)
    initSpaceAddress(&addressMaxNumberOfGateways, 1, &configurationSize)
    initSpaceAddress(&addressMaxNodeIdsToCache,   1, &configurationSize)
    initSpaceAddress(&addressMinNodeIdsToCache,   1, &configurationSize)

    configuration = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, defaultMemorySize: configurationSize, isReadOnly: false, description: "")

    if let configuration {
      
      virtualNodeType = MyTrainsVirtualNodeType.applicationNode
      
      isFullProtocolRequired = true
      
      eventsConsumed = [
        OpenLCBWellKnownEvent.nodeIsAMyTrainsLayout.rawValue,
        OpenLCBWellKnownEvent.nodeIsATrain.rawValue,
      ]
      
      eventsProduced = [
      ]
      
      configuration.delegate = self
      memorySpaces[configuration.space] = configuration

      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressUnitsActualLength)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressUnitsScaleLength)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressUnitsActualDistance)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressUnitsScaleDistance)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressUnitsActualSpeed)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressUnitsScaleSpeed)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressUnitsTime)

      viewOptions?.delegate = self
      memorySpaces[viewOptions!.space] = viewOptions!

      if !memorySpacesInitialized {
        resetToFactoryDefaults()
      }
      
      cdiFilename = "MyTrains Application"
      
    }
    
  }
  
  deinit {
    nodeIdCacheTimer?.invalidate()
    nodeIdCacheTimer = nil
    nodeIdCacheLock = nil
    nodeIdCache.removeAll()
    layoutList.removeAll()
//    observers.removeAll()
    viewOptions = nil
  }
  
  // MARK: Private Properties
  
  // Configuration variable addresses
  
  internal var addressUnitsActualLength   = 0
  internal var addressUnitsScaleLength    = 0
  internal var addressUnitsActualDistance = 0
  internal var addressUnitsScaleDistance  = 0
  internal var addressUnitsActualSpeed    = 0
  internal var addressUnitsScaleSpeed     = 0
  internal var addressUnitsTime           = 0
  internal var addressMaxNumberOfGateways = 0
  internal var addressMaxNodeIdsToCache   = 0
  internal var addressMinNodeIdsToCache   = 0

  private var nodeIdCacheTimer : Timer?
  
  private var nodeIdCacheLock : NSLock? = NSLock()
  
  private var nodeIdCache : [UInt64:(nodeId:UInt64, timeStamp:TimeInterval)] = [:]
  
  internal var layoutList : [UInt64:LayoutListItem] = [:]
  
  internal var locomotiveList : [UInt64:String] = [:]
  
  internal var nextObserverId : Int = 0
  
  internal var observers : [Int:MyTrainsAppDelegate] = [:]
  
  internal var _speedProfilerBlocks : [UInt64:SwitchboardItemNode]?
  
  internal var nextUniqueNodeIdCandidate : UInt64 {
    
    let seed = nextUniqueNodeIdSeed
    
    var lfsr1 = UInt32(seed >> 24)
    
    var lfsr2 = UInt32(seed & 0xffffff)

    // The PRNG state is stored in two 32-bit quantities:
    // uint32_t lfsr1, lfsr2; // sequence value: lfsr1 is upper 24 bits, lfsr2 lower
    
    // The 6-byte unique Node ID is stored in the nid[0:5] array.
    
    // To load the PRNG from the Node ID:
    // lfsr1 = (nid[0] << 16) | (nid[1] << 8) | nid[2]; // upper bits
    // lfsr2 = (nid[3] << 16) | (nid[4] << 8) | nid[5];

    // Form a 12-bit alias from the PRNG state:
    
    // To step the PRNG:
    // First, form 2^9*val
    
    let temp1 : UInt32 = ((lfsr1 << 9) | ((lfsr2 >> 15) & 0x1FF)) & 0xffffff
    let temp2 : UInt32 = (lfsr2 << 9) & 0xffffff
    
    // add
    
    lfsr2 += temp2 + 0x7a4ba9
    
    lfsr1 += temp1 + 0x1b0ca3
    
    // carry
    
    lfsr1 = (lfsr1 & 0xffffff) + ((lfsr2 & 0xff000000) >> 24)
    lfsr2 &= 0xffffff
    
    let result : UInt64 = UInt64(lfsr1) << 24 | UInt64(lfsr2)
    
    nextUniqueNodeIdSeed = result
    
    return (result & 0x0000ffffffff) | 0x08ff00000000

  }
  
  // MARK: Public Properties
  
  public var layout : LayoutNode? {
    guard let appLayoutId else {
      return nil
    }
    return appDelegate.networkLayer?.virtualNodeLookup[appLayoutId] as? LayoutNode
  }
  
  public var locoNetGateways : [UInt64:LocoNetGateway] {
    var result : [UInt64:LocoNetGateway] = [:]
    guard let networkLayer = appDelegate.networkLayer else {
      return result
    }
    for (key, node) in networkLayer.virtualNodeLookup {
      if let gateway = node as? LocoNetGateway {
        result[key] = gateway
      }
    }
    return result
  }
  
  public var panelList : [UInt64:SwitchboardPanelNode] {
    var result : [UInt64:SwitchboardPanelNode] = [:]
    for (_, node) in appDelegate.networkLayer!.virtualNodeLookup {
      if let panel = node as? SwitchboardPanelNode, let appLayoutId, panel.layoutNodeId == appLayoutId {
        result[panel.nodeId] = panel
      }
    }
    return result
  }
  
  public var switchboardItemList : [UInt64:SwitchboardItemNode] {
    if let _switchboardItemList {
      return _switchboardItemList
    }
    _switchboardItemList = [:]
    for (_, node) in appDelegate.networkLayer!.virtualNodeLookup {
      if let item = node as? SwitchboardItemNode, let appLayoutId, item.layoutNodeId == appLayoutId {
        _switchboardItemList![item.nodeId] = item
      }
    }
    for (_, panel) in panelList {
      panel._switchboardItems = nil
    }
    return _switchboardItemList!
  }
  
  public var _switchboardItemList : [UInt64:SwitchboardItemNode]? {
    didSet {
      _speedProfilerBlocks = nil
    }
  }
  
  public var speedProfilerBlocks : [UInt64:SwitchboardItemNode] {
    if let _speedProfilerBlocks {
      return _speedProfilerBlocks
    }
    var temp : [UInt64:SwitchboardItemNode] = [:]
    for (key, item) in switchboardItemList {
      if item.itemType.isGroup && !item.doNotUseForSpeedProfiling {
        temp[key] = item
      }
    }
    _speedProfilerBlocks = temp
    return temp
  }

  public var viewOptions : OpenLCBMemorySpace?
  
  public var unitsActualLength : SGUnitLength {
    get {
      return SGUnitLength(rawValue: configuration!.getUInt8(address: addressUnitsActualLength)!)!
    }
    set(value) {
      configuration!.setUInt(address: addressUnitsActualLength, value: value.rawValue)
    }
  }

  public var unitsScaleLength : SGUnitLength {
    get {
      return SGUnitLength(rawValue: configuration!.getUInt8(address: addressUnitsScaleLength)!)!
    }
    set(value) {
      configuration!.setUInt(address: addressUnitsScaleLength, value: value.rawValue)
    }
  }

  public var unitsActualDistance : SGUnitLength {
    get {
      return SGUnitLength(rawValue: configuration!.getUInt8(address: addressUnitsActualDistance)!)!
    }
    set(value) {
      configuration!.setUInt(address: addressUnitsActualDistance, value: value.rawValue)
    }
  }

  public var unitsScaleDistance : SGUnitLength {
    get {
      return SGUnitLength(rawValue: configuration!.getUInt8(address: addressUnitsScaleDistance)!)!
    }
    set(value) {
      configuration!.setUInt(address: addressUnitsScaleDistance, value: value.rawValue)
    }
  }

  public var unitsActualSpeed : SGUnitSpeed {
    get {
      return SGUnitSpeed(rawValue: configuration!.getUInt8(address: addressUnitsActualSpeed)!)!
    }
    set(value) {
      configuration!.setUInt(address: addressUnitsActualSpeed, value: value.rawValue)
    }
  }

  public var unitsScaleSpeed : SGUnitSpeed {
    get {
      return SGUnitSpeed(rawValue: configuration!.getUInt8(address: addressUnitsScaleSpeed)!)!
    }
    set(value) {
      configuration!.setUInt(address: addressUnitsScaleSpeed, value: value.rawValue)
    }
  }
  
  public var unitsTime : SGUnitTime {
    get {
      return SGUnitTime(rawValue: configuration!.getUInt8(address: addressUnitsTime)!)!
    }
    set(value) {
      configuration!.setUInt(address: addressUnitsTime, value: value.rawValue)
    }
  }
  
  public var unitsFrequency : SGUnitFrequency {
    return .hertz
  }
  
  public var unitsTemperature : SGUnitTemperature {
    return .celsius
  }
  
  public var unitsVoltage : SGUnitVoltage {
    return .volts
  }
  
  public var unitsCurrent : SGUnitCurrent {
    return .amps
  }
  
  public var maximumNumberOfGateways : UInt8 {
    get {
      return configuration!.getUInt8(address: addressMaxNumberOfGateways)!
    }
    set(value) {
      configuration!.setUInt(address: addressMaxNumberOfGateways, value: value)
    }
  }

  public var maximumNodeIdsToCache : Int {
    get {
      return Int(configuration!.getUInt8(address: addressMaxNodeIdsToCache)!)
    }
    set(value) {
      configuration!.setUInt(address: addressMaxNodeIdsToCache, value: UInt8(value))
    }
  }
  
  public var minimumNodeIdsToCache : Int {
    get {
      return Int(configuration!.getUInt8(address: addressMinNodeIdsToCache)!)
    }
    set(value) {
      configuration!.setUInt(address: addressMinNodeIdsToCache, value: UInt8(value))
    }
  }
  
  public var nextGatewayNodeId : UInt64? {
    
    let firstGatewayNodeId = nodeId + 2
    
    let nodes = OpenLCBMemorySpace.getVirtualNodes()
    
    var gatewayNodes : [UInt64:OpenLCBCANGateway] = [:]
    
    for node in nodes {
      if let gateway = node as? OpenLCBCANGateway {
        gatewayNodes[gateway.nodeId] = gateway
      }
    }
    
    for candidate in firstGatewayNodeId ... min(nodeId + 0xff, firstGatewayNodeId + UInt64(maximumNumberOfGateways) - 1) {
      if !gatewayNodes.keys.contains(candidate) {
        return candidate
      }
    }
    
    return nil
    
  }
  
  // MARK: Private Methods
  
  internal override func resetToFactoryDefaults() {
    
    super.resetToFactoryDefaults()
    
    configuration?.zeroMemory()
    
    unitsActualLength   = .centimeters
    unitsScaleLength    = .meters
    unitsActualDistance = .centimeters
    unitsScaleDistance  = .kilometers
    unitsActualSpeed    = defaultValueActualSpeed
    unitsScaleSpeed     = defaultValueScaleSpeed
    unitsTime           = defaultValueTime
    
    maximumNumberOfGateways = 1
    
    maximumNodeIdsToCache = 32
    minimumNodeIdsToCache = 8
    
    setViewState(type: .openLCBNetworkView, isOpen: true)
    setViewState(type: .openLCBTrafficMonitor, isOpen: true)
    
    saveMemorySpaces()
    
  }
  
  internal override func customizeDynamicCDI(cdi:String) -> String {
    
    var result = SGUnitLength.insertMap(cdi: cdi)
    result = SGUnitSpeed.insertMap(cdi: result)
    result = SGUnitTime.insertMap(cdi: result)
    result = MyTrainsViewType.insertMap(cdi: result)
    
    let maxPossibleGatewayNodes = 256 - (nodeId & 0xff) - 2
    
    result = result.replacingOccurrences(of: CDI.MAX_GATEWAYS, with: "\(maxPossibleGatewayNodes)")

    return result
    
  }
  
  override internal func sendStartupMessages() {
    sendIdentifyProducer(event: .nodeIsAMyTrainsLayout)
  }
    
  public func getUniqueNodeId() -> UInt64 {
    
    var result : UInt64 = 0
    
    nodeIdCacheLock!.lock()
    
    let now = Date.timeIntervalSinceReferenceDate
    
    for (key, item) in nodeIdCache {
      if now - item.timeStamp > 0.8 {
        nodeIdCache.removeValue(forKey: key)
        result = key
        break
      }
    }
    
    nodeIdCacheLock!.unlock()
    
    updateNodeIdCache()
  
    return result
    
  }
  
  @objc func nodeIdCacheTimerAction() {
    nodeIdCacheTimer = nil
    appDelegate.networkLayer?.nodeIdCacheCompleted()
  }
  
  private func startNodeIdCacheTimer(interval: TimeInterval) {

    nodeIdCacheTimer?.invalidate()
    
    nodeIdCacheTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(nodeIdCacheTimerAction), userInfo: nil, repeats: false)

    if let nodeIdCacheTimer {
      RunLoop.current.add(nodeIdCacheTimer, forMode: .common)
    }
    else {
      #if DEBUG
      debugLog("failed to create nodeIdCacheTimer")
      #endif
    }
    
  }
  
  private func layoutListUpdated() {
    for (_, observer) in observers {
      observer.layoutListUpdated?(appNode: self)
    }
  }

  private func locomotiveListUpdated() {
    for (_, observer) in observers {
      observer.locoNetGatewayListUpdated?(appNode: self)
    }
  }

  private func locoNetGatewayListUpdated() {
    for (_, observer) in observers {
      observer.locoNetGatewayListUpdated?(appNode: self)
    }
  }

  private func speedProfilerBlockListUpdated() {
    for (_, observer) in observers {
      observer.speedProfilerBlockListUpdated?(appNode: self)
    }
  }

  // MARK: Public Methods
  
  public override func stop() {

    nodeIdCacheTimer?.invalidate()
    nodeIdCacheTimer = nil
    nodeIdCache.removeAll()
    layoutList.removeAll()
    observers.removeAll()
    
    super.stop()
    
  }
  
  // At this point the messaging is running.
  
  public func updateNodeIdCache() {
    
    var alreadyInUse = OpenLCBMemorySpace.getVirtualNodeIds()
    
    if nodeIdCache.count < minimumNodeIdsToCache {
      
 //     nodeIdCacheLock.lock()
      while nodeIdCache.count < maximumNodeIdsToCache {
        let candidate = nextUniqueNodeIdCandidate
        if !alreadyInUse.contains(candidate) {
          nodeIdCache[candidate] = (nodeId:candidate, timeStamp:Date.timeIntervalSinceReferenceDate)
          alreadyInUse.insert(candidate)
        }
      }
 //     nodeIdCacheLock.unlock()

      sendVerifyNodeIdGlobal()

      startNodeIdCacheTimer(interval: 1.0)
      
    }
    
  }
  
  public func getViewOption(type:MyTrainsViewType) -> MyTrainsViewOption {
    return MyTrainsViewOption(rawValue: viewOptions!.getUInt8(address: type.rawValue * 2)!)!
  }

  public func setViewOption(type:MyTrainsViewType, option:MyTrainsViewOption) {
    viewOptions?.setUInt(address: type.rawValue * 2, value: option.rawValue)
    saveMemorySpaces()
  }

  public func getViewState(type:MyTrainsViewType) -> Bool {
    return viewOptions!.getUInt8(address: type.rawValue * 2 + 1)! != 0
  }

  public func setViewState(type:MyTrainsViewType, isOpen:Bool) {
    viewOptions?.setUInt(address: type.rawValue * 2 + 1, value: isOpen ? UInt8(1) : UInt8(0))
    saveMemorySpaces()
  }

  public func addObserver(observer:MyTrainsAppDelegate) -> Int {
    
    let id = nextObserverId
    nextObserverId += 1
    observers[id] = observer
    
    observer.layoutListUpdated?(appNode: self)
    observer.locoNetGatewayListUpdated?(appNode: self)
    observer.panelListUpdated?(appNode: self)
    observer.locomotiveListUpdated?(appNode: self)

    return id
    
  }
  
  public func removeObserver(observerId:Int) {
    if observers.keys.contains(observerId) {
      observers.removeValue(forKey: observerId)
    }
  }
  
  public func deletePanel(panel:SwitchboardPanelNode) {
    
    guard let networkLayer = appDelegate.networkLayer else {
      return
    }
  
    let alert = NSAlert()
    
    alert.messageText = String(localized: "Are You Sure?")
    alert.informativeText = String(localized: "Are you sure that you want to delete this switchboard panel?")
    alert.addButton(withTitle: String(localized: "Yes"))
    alert.addButton(withTitle: String(localized: "No"))
    alert.alertStyle = .informational
    
    switch alert.runModal() {
    case .alertFirstButtonReturn:
      break
    default:
      return
    }
    
    if let switchboardItems = panel.switchboardItems {
      for (_, item) in switchboardItems {
        networkLayer.deleteNode(nodeId: item.nodeId)
      }
    }
    
    networkLayer.deleteNode(nodeId: panel.nodeId)
    
  }
  
  public func createPanel() -> SwitchboardPanelNode? {
    
    guard let networkLayer = appDelegate.networkLayer else {
      return nil
    }
    
    if let node = networkLayer.createVirtualNode(virtualNodeType: .switchboardPanelNode) as? SwitchboardPanelNode {

      var index = 0
      var isUnique = true
      var test = ""

      repeat {
        index += 1
        isUnique = true
        test = " #\(index)"
        for (_, item) in panelList {
          if test == item.userNodeName.suffix(test.count) {
            isUnique = false
            break
          }
        }
      } while !isUnique
      
      node.userNodeName = "\(node.userNodeName)\(test)"
      
      node.saveMemorySpaces()
      
      for (_, observer) in observers {
        observer.panelListUpdated?(appNode: self)
      }
      
      return node

    }
    
    return nil

  }
  
  public func panelChanged(panelId:UInt64) {
    guard let panel = appDelegate.networkLayer?.virtualNodeLookup[panelId] as? SwitchboardPanelNode else {
      return
    }
    for (_, observer) in observers {
      observer.panelUpdated?(panel: panel)
      observer.panelListUpdated?(appNode: self)
    }
  }
  
  public func sendGlobalEmergencyStop() {
    sendWellKnownEvent(eventId: .emergencyStopAll)
  }

  public func sendClearGlobalEmergencyStop() {
    sendWellKnownEvent(eventId: .clearEmergencyStopAll)
  }

  public func sendGlobalPowerOff() {
    sendWellKnownEvent(eventId: .emergencyOffAll)
  }
  
  public func sendGlobalPowerOn() {
    sendWellKnownEvent(eventId: .clearEmergencyOffAll)
  }
  
  public func insertLayoutMap(cdi:String) -> String {
    
    var sorted : [(nodeId:UInt64, name:String)] = []

    for (nodeId, item) in layoutList {
      sorted.append((nodeId:nodeId, name:item.layoutName))
    }
    
    sorted.sort {$0.name.sortValue < $1.name.sortValue}

    var layouts = "<map>\n<relation><property>0</property><value>No Layout Selected</value></relation>\n"
    
    for item in sorted {
      layouts += "<relation><property>\(item.nodeId)</property><value>\(item.name)</value></relation>\n"
    }

    layouts += "</map>\n"

    return cdi.replacingOccurrences(of: CDI.LAYOUT_NODES, with: layouts)

  }

  public func insertPanelMap(cdi:String, layoutId:UInt64) -> String {
    
    var sorted : [(nodeId:UInt64, name:String)] = []

    for (nodeId, item) in panelList {
      if item.layoutNodeId == layoutId {
        sorted.append((nodeId:nodeId, name:item.userNodeName))
      }
    }
    
    sorted.sort {$0.name.sortValue < $1.name.sortValue}

    var panels = "<map>\n<relation><property>0</property><value>No Panel Selected</value></relation>\n"
    
    for item in sorted {
      panels += "<relation><property>\(item.nodeId)</property><value>\(item.name)</value></relation>\n"
    }

    panels += "</map>\n"

    return cdi.replacingOccurrences(of: CDI.SWITCHBOARD_PANEL_NODES, with: panels)

  }

  public func populateGroup(comboBox:NSComboBox, panelId:UInt64 = 0) {
  
    let selected = comboBox.objectValueOfSelectedItem
    
    comboBox.deselectItem(at: comboBox.indexOfSelectedItem)
    
    var sorted : [SwitchboardItemNode] = []

    for (_, item) in switchboardItemList {
      if item.itemType.isGroup && (item.panelId == panelId || panelId == 0) {
        sorted.append(item)
      }
    }
    
    sorted.sort {$0.userNodeName.sortValue < $1.userNodeName.sortValue}

    comboBox.isEditable = false
    comboBox.removeAllItems()
    
    for item in sorted {
      comboBox.addItem(withObjectValue: item.userNodeName)
    }
    
    if comboBox.numberOfItems > 0 {
      
      comboBox.selectItem(withObjectValue: selected)
      
      if comboBox.indexOfSelectedItem == -1 {
        comboBox.selectItem(at: 0)
      }
      
    }
    
  }
  
  public func selectGroup(comboBox:NSComboBox, nodeId:UInt64) {
    comboBox.deselectItem(at: comboBox.indexOfSelectedItem)
    guard let node = appDelegate.networkLayer?.virtualNodeLookup[nodeId] else {
      return
    }
    comboBox.selectItem(withObjectValue: node.userNodeName)
  }
  
  public func selectedGroup(comboBox:NSComboBox) -> SwitchboardItemNode? {
    guard let objectValue = comboBox.objectValueOfSelectedItem as? String else {
      return nil
    }
    for (_, item) in switchboardItemList {
      if item.itemType.isGroup && item.userNodeName == objectValue {
        return item
      }
    }
    return nil
  }
  
  public func insertGroupMap(cdi:String, layoutId:UInt64) -> String {
    
    var sorted : [(nodeId:UInt64, name:String)] = []

    for (nodeId, item) in switchboardItemList {
      if item.itemType.isGroup {
        sorted.append((nodeId:nodeId, name:item.userNodeName))
      }
    }
    
    sorted.sort {$0.name.sortValue < $1.name.sortValue}

    var items = "<map>\n<relation><property>0</property><value>No Group Selected</value></relation>\n"
    
    for item in sorted {
      items += "<relation><property>\(item.nodeId)</property><value>\(item.name)</value></relation>\n"
    }

    items += "</map>\n"

    return cdi.replacingOccurrences(of: CDI.SWITCHBOARD_GROUP_NODES, with: items)

  }
  
  public func populateSpeedProfilerBlocks(comboBox:NSComboBox) {
  
    let selected = comboBox.objectValueOfSelectedItem
    
    comboBox.deselectItem(at: comboBox.indexOfSelectedItem)
    
    var sorted : [SwitchboardItemNode] = []

    for (_, item) in speedProfilerBlocks {
      sorted.append(item)
    }
    
    sorted.sort {$0.userNodeName.sortValue < $1.userNodeName.sortValue}

    comboBox.isEditable = false
    comboBox.removeAllItems()
    
    for item in sorted {
      comboBox.addItem(withObjectValue: item.userNodeName)
    }
        
  }
  
  public func selectSpeedProfilerBlock(comboBox:NSComboBox, nodeId:UInt64) {
    comboBox.deselectItem(at: comboBox.indexOfSelectedItem)
    guard let node = appNode?.speedProfilerBlocks[nodeId] else {
      return
    }
    comboBox.selectItem(withObjectValue: node.userNodeName)
  }
  
  public func selectedSpeedProfilerBlock(title:String) -> SwitchboardItemNode? {
    for (_, item) in speedProfilerBlocks {
      if item.userNodeName == title {
        return item
      }
    }
    return nil
  }

  public func populateLink(comboBox:NSComboBox) {
  
    let selected = comboBox.objectValueOfSelectedItem
    
    comboBox.deselectItem(at: comboBox.indexOfSelectedItem)
    
    var sorted : [SwitchboardItemNode] = []

    for (_, item) in switchboardItemList {
      if item.itemType == .link {
        sorted.append(item)
      }
    }
    
    sorted.sort {$0.userNodeName.sortValue < $1.userNodeName.sortValue}

    comboBox.isEditable = false
    comboBox.removeAllItems()
    
    for item in sorted {
      comboBox.addItem(withObjectValue: item.userNodeName)
    }
    
    if comboBox.numberOfItems > 0 {
      comboBox.selectItem(withObjectValue: selected)
    }
    
  }

  public func selectLink(comboBox:NSComboBox, nodeId:UInt64) {
    comboBox.deselectItem(at: comboBox.indexOfSelectedItem)
    guard let node = appDelegate.networkLayer?.virtualNodeLookup[nodeId] else {
      return
    }
    comboBox.selectItem(withObjectValue: node.userNodeName)
  }
  
  public func selectedLink(comboBox:NSComboBox) -> SwitchboardItemNode? {
    guard let objectValue = comboBox.objectValueOfSelectedItem as? String else {
      return nil
    }
    for (_, item) in switchboardItemList {
      if item.itemType == .link && item.userNodeName == objectValue {
        return item
      }
    }
    return nil
  }
  
  public func getLink(name:String) -> SwitchboardItemNode? {
    for (_, item) in switchboardItemList {
      if item.itemType == .link && item.userNodeName == name {
        return item
      }
    }
    return nil
  }

  public func insertLinkMap(cdi:String, layoutId:UInt64, excludeLinkId:UInt64) -> String {
    
    var sorted : [(nodeId:UInt64, name:String)] = []

    for (nodeId, item) in switchboardItemList {
      if item.itemType == .link && item.layoutNodeId == layoutId && item.nodeId != excludeLinkId {
        sorted.append((nodeId:nodeId, name:item.userNodeName))
      }
    }
    
    sorted.sort {$0.name.sortValue < $1.name.sortValue}

    var items = "<map>\n<relation><property>0</property><value>No Link Selected</value></relation>\n"
    
    for item in sorted {
      items += "<relation><property>\(item.nodeId)</property><value>\(item.name)</value></relation>\n"
    }

    items += "</map>\n"

    return cdi.replacingOccurrences(of: CDI.SWITCHBOARD_LINKS, with: items)

  }

  public func insertLocoNetGatewayMap(cdi:String) -> String {
    
    var sorted : [(nodeId:UInt64, name:String)] = []
    
    for (nodeId, node) in locoNetGateways {
      sorted.append((nodeId, node.userNodeName))
    }
    
    sorted.sort {$0.name.sortValue < $1.name.sortValue}
    
    var map = "<map>\n<relation><property>0</property><value>No LocoNet Gateway Selected</value></relation>\n"
    
    for item in sorted {
      map += "<relation><property>\(item.nodeId)</property><value>\(item.name)</value></relation>\n"
    }

    map += "</map>\n"

    return cdi.replacingOccurrences(of: CDI.LOCONET_GATEWAYS, with: map)

  }

  // MARK: OpenLCBNetworkLayerDelegate Methods
  
  public override func openLCBMessageReceived(message: OpenLCBMessage) {

    guard let sourceNodeId = message.sourceNodeId else {
      return
    }
    
    super.openLCBMessageReceived(message: message)
    
    switch message.messageTypeIndicator {
      
    case .verifiedNodeIDSimpleSetSufficient, .verifiedNodeIDFullProtocolRequired, .initializationCompleteSimpleSetSufficient, .initializationCompleteFullProtocolRequired:
      
      if let id = UInt64(bigEndianData: message.payload) {
        nodeIdCacheLock!.lock()
        if nodeIdCache.keys.contains(id) {
          nodeIdCache.removeValue(forKey: id)
        }
        nodeIdCacheLock!.unlock()
        updateNodeIdCache()
      }
      
    case .simpleNodeIdentInfoReply:
      
      if let item = layoutList[sourceNodeId] {
        var layout = item
        let node = OpenLCBNode(nodeId: sourceNodeId)
        node.encodedNodeInformation = message.payload
        layout.layoutName = node.userNodeName
        layoutList[sourceNodeId] = layout
        layoutListUpdated()
      }
      else if let item = locomotiveList[sourceNodeId] {
        let node = OpenLCBNode(nodeId: sourceNodeId)
        node.encodedNodeInformation = message.payload
        locomotiveList[sourceNodeId] = node.userNodeName
        locomotiveListUpdated()
      }

    case .producerConsumerEventReport:
      
      if let event = OpenLCBWellKnownEvent(rawValue: message.eventId!) {
        
        switch event {
        case .nodeIsATrain:

          if !locomotiveList.keys.contains(sourceNodeId) {
            locomotiveList[sourceNodeId] = ""
            sendSimpleNodeInformationRequest(destinationNodeId: sourceNodeId)
          }

        case .nodeIsAMyTrainsLayout:
          
          if !layoutList.keys.contains(sourceNodeId) {
            layoutList[sourceNodeId] = (masterNodeId:0, layoutId:sourceNodeId, layoutName:"", layoutState:.activated)
            sendSimpleNodeInformationRequest(destinationNodeId: sourceNodeId)
          }
          
        default:
          break
        }
        
      }

    case .producerIdentifiedAsCurrentlyValid, .producerIdentifiedAsCurrentlyInvalid, .producerIdentifiedWithValidityUnknown:
      
      if let event = OpenLCBWellKnownEvent(rawValue: message.eventId!) {
        
        switch event {
          
        case .nodeIsATrain:
          
          if !locomotiveList.keys.contains(sourceNodeId) {
            locomotiveList[sourceNodeId] = ""
            sendSimpleNodeInformationRequest(destinationNodeId: sourceNodeId)
          }

        case .nodeIsAMyTrainsLayout:
          
          if !layoutList.keys.contains(sourceNodeId) {
            layoutList[sourceNodeId] = (masterNodeId:0, layoutId:sourceNodeId, layoutName:"", layoutState:.activated)
            sendSimpleNodeInformationRequest(destinationNodeId: sourceNodeId)
          }
          
        default:
          break
        }
        
      }
     
    case .identifyEventsGlobal, .identifyEventsAddressed:
      
      for (nodeId, node) in appDelegate.networkLayer!.virtualNodeLookup {
        if node.visibility == .visibilitySemiPublic {
          sendIdentifyEventsAddressed(destinationNodeId: nodeId)
        }
      }
      
    default:
      break
    }
    
  }

}
