//
//  OpenLCBNodeMyTrains.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/05/2023.
//

import Foundation

public class OpenLCBNodeMyTrains : OpenLCBNodeVirtual {
  
  // MARK: Constructors
  
  public override init(nodeId:UInt64) {
    
    var configurationSize = MyTrainsViewType.numberOfTypes * 2
    
    viewOptions = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.viewOptions.rawValue, defaultMemorySize: configurationSize, isReadOnly: false, description: "")
    
    super.init(nodeId: nodeId)

    configurationSize = 0
    
    initSpaceAddress(&addressUnitsActualLength,   1, &configurationSize)
    initSpaceAddress(&addressUnitsScaleLength,    1, &configurationSize)
    initSpaceAddress(&addressUnitsActualDistance, 1, &configurationSize)
    initSpaceAddress(&addressUnitsScaleDistance,  1, &configurationSize)
    initSpaceAddress(&addressUnitsActualSpeed,    1, &configurationSize)
    initSpaceAddress(&addressUnitsScaleSpeed,     1, &configurationSize)
    initSpaceAddress(&addressUnitsTime,           1, &configurationSize)
    initSpaceAddress(&addressMaxNumberOfGateways, 1, &configurationSize)

    configuration = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, defaultMemorySize: configurationSize, isReadOnly: false, description: "")

    if let configuration {
      
      virtualNodeType = MyTrainsVirtualNodeType.applicationNode
      
      isFullProtocolRequired = true
      
      eventsConsumed = [
        OpenLCBWellKnownEvent.myTrainsLayoutActivated.rawValue,
        OpenLCBWellKnownEvent.myTrainsLayoutDeactivated.rawValue,
        OpenLCBWellKnownEvent.myTrainsLayoutDeleted.rawValue,
        OpenLCBWellKnownEvent.nodeIsASwitchboardPanel.rawValue,
        OpenLCBWellKnownEvent.nodeIsASwitchboardItem.rawValue,
        OpenLCBWellKnownEvent.nodeIsALocoNetGateway.rawValue,
      ]
      
      eventsProduced = [
        OpenLCBWellKnownEvent.identifyMyTrainsLayouts.rawValue,
        OpenLCBWellKnownEvent.identifyMyTrainsSwitchboardPanels.rawValue,
        OpenLCBWellKnownEvent.identifyMyTrainsSwitchboardItems.rawValue,
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

      viewOptions.delegate = self
      memorySpaces[viewOptions.space] = viewOptions

      if !memorySpacesInitialized {
        resetToFactoryDefaults()
      }
      
      cdiFilename = "MyTrains Application"
      
    }
    
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
  
  private var getUniqueNodeIdQueue : [UInt64] = []
  
  private var timeoutTimer : Timer?
  
  internal var layoutList : [UInt64:LayoutListItem] = [:]
  
  internal var panelList : [UInt64:PanelListItem] = [:]
  
  internal var switchboardItemList : [UInt64:SwitchboardItemListItem] = [:]
  
  internal var nextObserverId : Int = 0
  
  internal var observers : [Int:MyTrainsAppDelegate] = [:]
  
  // MARK: Public Properties
  
  public var locoNetGateways : [UInt64:String] = [:]

  public var viewOptions : OpenLCBMemorySpace
  
  public var unitsActualLength : UnitLength {
    get {
      return UnitLength(rawValue: configuration!.getUInt8(address: addressUnitsActualLength)!)!
    }
    set(value) {
      configuration!.setUInt(address: addressUnitsActualLength, value: value.rawValue)
    }
  }

  public var unitsScaleLength : UnitLength {
    get {
      return UnitLength(rawValue: configuration!.getUInt8(address: addressUnitsScaleLength)!)!
    }
    set(value) {
      configuration!.setUInt(address: addressUnitsScaleLength, value: value.rawValue)
    }
  }

  public var unitsActualDistance : UnitLength {
    get {
      return UnitLength(rawValue: configuration!.getUInt8(address: addressUnitsActualDistance)!)!
    }
    set(value) {
      configuration!.setUInt(address: addressUnitsActualDistance, value: value.rawValue)
    }
  }

  public var unitsScaleDistance : UnitLength {
    get {
      return UnitLength(rawValue: configuration!.getUInt8(address: addressUnitsScaleDistance)!)!
    }
    set(value) {
      configuration!.setUInt(address: addressUnitsScaleDistance, value: value.rawValue)
    }
  }

  public var unitsActualSpeed : UnitSpeed {
    get {
      return UnitSpeed(rawValue: configuration!.getUInt8(address: addressUnitsActualSpeed)!)!
    }
    set(value) {
      configuration!.setUInt(address: addressUnitsActualSpeed, value: value.rawValue)
    }
  }

  public var unitsScaleSpeed : UnitSpeed {
    get {
      return UnitSpeed(rawValue: configuration!.getUInt8(address: addressUnitsScaleSpeed)!)!
    }
    set(value) {
      configuration!.setUInt(address: addressUnitsScaleSpeed, value: value.rawValue)
    }
  }
  
  public var unitsTime : UnitTime {
    get {
      return UnitTime(rawValue: configuration!.getUInt8(address: addressUnitsTime)!)!
    }
    set(value) {
      configuration!.setUInt(address: addressUnitsTime, value: value.rawValue)
    }
  }
  
  public var maximumNumberOfGateways : UInt8 {
    get {
      return configuration!.getUInt8(address: addressMaxNumberOfGateways)!
    }
    set(value) {
      configuration!.setUInt(address: addressMaxNumberOfGateways, value: value)
    }
  }

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
  
  public var nextGatewayNodeId : UInt64? {
    
    guard let networkLayer else {
      return nil
    }
    
    let firstGatewayNodeId = nodeId + 2
    
    for candidate in firstGatewayNodeId ... min(nodeId + 0xff, firstGatewayNodeId + UInt64(maximumNumberOfGateways) - 1) {
      if !networkLayer.virtualNodeLookup.keys.contains(candidate) {
        return candidate
      }
    }
    
    return nil
    
  }
  
  // MARK: Private Methods
  
  internal override func resetToFactoryDefaults() {
    
    super.resetToFactoryDefaults()
    
    unitsActualLength   = UnitLength.defaultValueActualLength
    unitsScaleLength    = UnitLength.defaultValueScaleLength
    unitsActualDistance = UnitLength.defaultValueActualDistance
    unitsScaleDistance  = UnitLength.defaultValueScaleDistance
    unitsActualSpeed    = UnitSpeed.defaultValueActualSpeed
    unitsScaleSpeed     = UnitSpeed.defaultValueScaleSpeed
    unitsTime           = UnitTime.defaultValue
    
    maximumNumberOfGateways = 1
    
    setViewOption(type: .openLCBNetworkView, option: .open)
    setViewOption(type: .openLCBTrafficMonitor, option: .open)

    saveMemorySpaces()
    
  }
  
  internal override func resetReboot() {
    
    super.resetReboot()
    
    layoutList.removeAll()
    
    panelList.removeAll()
    
    switchboardItemList.removeAll()
    
    locoNetGateways.removeAll()
    
  }
  
  internal override func customizeDynamicCDI(cdi:String) -> String {
    
    var result = UnitLength.insertMap(cdi: cdi)
    result = UnitSpeed.insertMap(cdi: result)
    result = UnitTime.insertMap(cdi: result)
    result = MyTrainsViewType.insertMap(cdi: result)
    
    let maxPossibleGatewayNodes = 256 - (nodeId & 0xff) - 2
    
    result = result.replacingOccurrences(of: CDI.MAX_GATEWAYS, with: "\(maxPossibleGatewayNodes)")

    return result
    
  }
  
  private func tryCandidate() {
    
    guard !getUniqueNodeIdQueue.isEmpty && timeoutTimer == nil else {
      return
    }
    
    startTimeoutTimer(interval: 0.8)
    
    sendVerifyNodeIdAddressed(destinationNodeId: getUniqueNodeIdQueue[0])
    
  }
  
  public func getUniqueNodeId() {
    getUniqueNodeIdQueue.append(nextUniqueNodeIdCandidate)
    tryCandidate()
  }
  

  @objc func timeoutTimerAction() {

    stopTimeoutTimer()

    if !getUniqueNodeIdQueue.isEmpty {
      let newNodeId = getUniqueNodeIdQueue.removeFirst()
      networkLayer?.createVirtualNode(newNodeId: newNodeId)
      tryCandidate()
    }
    
  }
  
  private func startTimeoutTimer(interval: TimeInterval) {

    stopTimeoutTimer()
    
    timeoutTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(timeoutTimerAction), userInfo: nil, repeats: false)

    if let timeoutTimer {
      RunLoop.current.add(timeoutTimer, forMode: .common)
    }
    else {
      #if DEBUG
      debugLog("failed to create timeoutTimer")
      #endif
    }
    
  }
  
  private func stopTimeoutTimer() {
    timeoutTimer?.invalidate()
    timeoutTimer = nil
  }
  
  private func layoutListUpdated() {
    for (_, observer) in observers {
      observer.layoutListUpdated?(appNode: self)
    }
  }

  private func panelListUpdated() {
    for (_, observer) in observers {
      observer.panelListUpdated?(appNode: self)
    }
  }

  private func switchboardItemListUpdated() {
    for (_, observer) in observers {
      observer.switchboardItemListUpdated?(appNode: self)
    }
  }

  private func locoNetGatewayListUpdated() {
    for (_, observer) in observers {
      observer.locoNetGatewayListUpdated?(appNode: self)
    }
  }

  // MARK: Public Methods
  
  public func getViewOption(type:MyTrainsViewType) -> MyTrainsViewOption {
    return MyTrainsViewOption(rawValue: viewOptions.getUInt8(address: type.rawValue * 2)!)!
  }

  public func setViewOption(type:MyTrainsViewType, option:MyTrainsViewOption) {
    viewOptions.setUInt(address: type.rawValue * 2, value: option.rawValue)
    saveMemorySpaces()
  }

  public func getViewState(type:MyTrainsViewType) -> Bool {
    return viewOptions.getUInt8(address: type.rawValue * 2 + 1)! != 0
  }

  public func setViewState(type:MyTrainsViewType, isOpen:Bool) {
    viewOptions.setUInt(address: type.rawValue * 2 + 1, value: isOpen ? UInt8(1) : UInt8(0))
    saveMemorySpaces()
  }

  public func addObserver(observer:MyTrainsAppDelegate) -> Int {
    
    let id = nextObserverId
    nextObserverId += 1
    observers[id] = observer
    
    for (_, observer) in observers {
      observer.layoutListUpdated?(appNode: self)
      observer.switchboardItemListUpdated?(appNode: self)
      observer.switchboardItemListUpdated?(appNode: self)
      observer.locoNetGatewayListUpdated?(appNode: self)
    }
    
    return id
    
  }
  
  public func removeObserver(observerId:Int) {
    observers.removeValue(forKey: observerId)
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
      if item.masterNodeId == self.nodeId {
        sorted.append((nodeId:nodeId, name:item.layoutName))
      }
    }
    
    sorted.sort {$0.name < $1.name}

    var layouts = "<map>\n<relation><property>00.00.00.00.00.00.00.00</property><value>No Layout Selected</value></relation>\n"
    
    for item in sorted {
      layouts += "<relation><property>\(item.nodeId.toHexDotFormat(numberOfBytes: 8))</property><value>\(item.name)</value></relation>\n"
    }

    layouts += "</map>\n"

    return cdi.replacingOccurrences(of: CDI.LAYOUT_NODES, with: layouts)

  }

  public func insertPanelMap(cdi:String, layoutId:UInt64) -> String {
    
    var sorted : [(nodeId:UInt64, name:String)] = []

    for (nodeId, item) in panelList {
      if item.layoutId == layoutId {
        sorted.append((nodeId:nodeId, name:item.panelName))
      }
    }
    
    sorted.sort {$0.name < $1.name}

    var panels = "<map>\n<relation><property>00.00.00.00.00.00.00.00</property><value>No Panel Selected</value></relation>\n"
    
    for item in sorted {
      panels += "<relation><property>\(item.nodeId.toHexDotFormat(numberOfBytes: 8))</property><value>\(item.name)</value></relation>\n"
    }

    panels += "</map>\n"

    return cdi.replacingOccurrences(of: CDI.SWITCHBOARD_PANEL_NODES, with: panels)

  }

  public func insertGroupMap(cdi:String, layoutId:UInt64) -> String {
    
    var sorted : [(nodeId:UInt64, name:String)] = []

    for (nodeId, item) in switchboardItemList {
      if item.layoutId == layoutId && item.itemType.isGroup {
        sorted.append((nodeId:nodeId, name:item.itemName))
      }
    }
    
    sorted.sort {$0.name < $1.name}

    var items = "<map>\n<relation><property>00.00.00.00.00.00.00.00</property><value>No Group Selected</value></relation>\n"
    
    for item in sorted {
      items += "<relation><property>\(item.nodeId.toHexDotFormat(numberOfBytes: 8))</property><value>\(item.name)</value></relation>\n"
    }

    items += "</map>\n"

    return cdi.replacingOccurrences(of: CDI.SWITCHBOARD_GROUP_NODES, with: items)

  }

  public func insertLinkMap(cdi:String, layoutId:UInt64, excludeLinkId:UInt64) -> String {
    
    var sorted : [(nodeId:UInt64, name:String)] = []

    for (nodeId, item) in switchboardItemList {
      if item.itemType == .link && item.layoutId == layoutId && item.itemId != excludeLinkId {
        sorted.append((nodeId:nodeId, name:item.itemName))
      }
    }
    
    sorted.sort {$0.name < $1.name}

    var items = "<map>\n<relation><property>00.00.00.00.00.00.00.00</property><value>No Link Selected</value></relation>\n"
    
    for item in sorted {
      items += "<relation><property>\(item.nodeId.toHexDotFormat(numberOfBytes: 8))</property><value>\(item.name)</value></relation>\n"
    }

    items += "</map>\n"

    return cdi.replacingOccurrences(of: CDI.SWITCHBOARD_LINKS, with: items)

  }

  public func insertLocoNetGatewayMap(cdi:String) -> String {
    
    var sorted : [(nodeId:UInt64, name:String)] = []
    
    for (nodeId, name) in locoNetGateways {
      sorted.append((nodeId, name))
    }
    
    sorted.sort {$0.name < $1.name}
    
    var map = "<map>\n<relation><property>00.00.00.00.00.00.00.00</property><value>No LocoNet Gateway Selected</value></relation>\n"
    
    for item in sorted {
      map += "<relation><property>\(item.nodeId.toHexDotFormat(numberOfBytes: 8))</property><value>\(item.name)</value></relation>\n"
    }

    map += "</map>\n"

    return cdi.replacingOccurrences(of: CDI.LOCONET_GATEWAYS, with: map)

  }

  // MARK: OpenLCBNetworkLayerDelegate Methods
  
  public override func openLCBMessageReceived(message: OpenLCBMessage) {

    guard let networkLayer, let sourceNodeId = message.sourceNodeId else {
      return
    }
    
    super.openLCBMessageReceived(message: message)
    
    switch message.messageTypeIndicator {
      
    case .verifiedNodeIDSimpleSetSufficient, .verifiedNodeIDFullProtocolRequired:
      
      if !getUniqueNodeIdQueue.isEmpty, let id = UInt64(bigEndianData: message.payload) {
        
        if (id & 0x0000ffffffffffff) == getUniqueNodeIdQueue[0] {
          stopTimeoutTimer()
          getUniqueNodeIdQueue[0] = nextUniqueNodeIdCandidate
          tryCandidate()
        }
        
      }
      
    case .simpleNodeIdentInfoReply:
      
      let node = OpenLCBNode(nodeId: sourceNodeId)
      node.encodedNodeInformation = message.payload
      
      if let item = layoutList[sourceNodeId] {
        var layout = item
        layout.layoutName = node.userNodeName
        layoutList[sourceNodeId] = layout
        layoutListUpdated()
      }
      else if let item = panelList[sourceNodeId] {
        var panel = item
        panel.panelName = node.userNodeName
        panelList[sourceNodeId] = panel
        panelListUpdated()
      }
      else if let item = switchboardItemList[sourceNodeId] {
        var switchboardItem = item
        switchboardItem.itemName = node.userNodeName
        switchboardItemList[sourceNodeId] = switchboardItem
        switchboardItemListUpdated()
      }
      else if let _ = locoNetGateways[sourceNodeId] {
        locoNetGateways[sourceNodeId] = node.userNodeName
        locoNetGatewayListUpdated()
      }

    case .producerConsumerEventReport:
      
      if let event = OpenLCBWellKnownEvent(rawValue: message.eventId!) {
        
        switch event {
         
        case .myTrainsLayoutDeleted:

          if sourceNodeId == appLayoutId {
            networkLayer.layoutNodeId = nil
          }
          
          layoutList.removeValue(forKey: sourceNodeId)
          
          layoutListUpdated()

        case .myTrainsLayoutActivated, .myTrainsLayoutDeactivated:
          
          let layoutState : LayoutState = (event == .myTrainsLayoutActivated) ? .activated : .deactivated
          
          if layoutState == .activated {
            networkLayer.layoutNodeId = sourceNodeId
          }
          else if let appLayoutId, appLayoutId == sourceNodeId {
            networkLayer.layoutNodeId = nil
          }
          
          if let item = layoutList[sourceNodeId] {
            var layout = item
            layout.layoutState = layoutState
            layoutList[sourceNodeId] = layout
            layoutListUpdated()
          }
          else {
            let masterNodeId = UInt64(bigEndianData: message.payload)!
            layoutList[sourceNodeId] = (masterNodeId:masterNodeId, layoutId:sourceNodeId, layoutName:"", layoutState:layoutState)
            sendSimpleNodeInformationRequest(destinationNodeId: sourceNodeId)
          }

        case .nodeIsASwitchboardPanel:
          
          if let layoutNodeId = UInt64(bigEndianData: message.payload) {
            
            if let _ = panelList[sourceNodeId] {} else {
              panelList[sourceNodeId] = (layoutId:layoutNodeId, panelId: sourceNodeId, panelName:"")
              sendSimpleNodeInformationRequest(destinationNodeId: sourceNodeId)
            }
            
          }
          
        case .nodeIsASwitchboardItem:
          
          if let itemType = SwitchBoardItemType(rawValue: UInt16(bigEndianData: [message.payload[6], message.payload[7]])!), let layoutNodeId = UInt64(bigEndianData: [message.payload[0], message.payload[1], message.payload[2], message.payload[3], message.payload[4], message.payload[5]]) {
            
            if let item = switchboardItemList[sourceNodeId] {
              var modifiedItem = item
              modifiedItem.itemType = itemType
              switchboardItemList[sourceNodeId] = modifiedItem
            }
            else {
              switchboardItemList[sourceNodeId] = (layoutId:layoutNodeId, itemId: sourceNodeId, itemName:"", itemType:itemType)
            }
            sendSimpleNodeInformationRequest(destinationNodeId: sourceNodeId)

          }
          
        case .nodeIsALocoNetGateway:
          
          if let _ = locoNetGateways[sourceNodeId] {} else {
            locoNetGateways[sourceNodeId] = ""
            sendSimpleNodeInformationRequest(destinationNodeId: sourceNodeId)
          }
          
        default:
          break
        }
        
      }

    case .producerIdentifiedAsCurrentlyValid, .producerIdentifiedAsCurrentlyInvalid, .producerIdentifiedWithValidityUnknown:
      
      if let event = OpenLCBWellKnownEvent(rawValue: message.eventId!) {
        
        switch event {
          
        case .nodeIsALocoNetGateway:
          
          if let _ = locoNetGateways[sourceNodeId] {} else {
            locoNetGateways[sourceNodeId] = ""
            sendSimpleNodeInformationRequest(destinationNodeId: sourceNodeId)
          }

        default:
          break
        }
        
      }
     
    case .identifyEventsGlobal, .identifyEventsAddressed:
      
      for (nodeId, node) in networkLayer.virtualNodeLookup {
        if node.visibility == .visibilitySemiPublic {
          sendIdentifyEventsAddressed(destinationNodeId: nodeId)
        }
      }
      
    default:
      break
    }
    
  }

}