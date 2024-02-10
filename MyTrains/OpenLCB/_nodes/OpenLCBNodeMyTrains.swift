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
    
    var configurationSize = 0
    
    initSpaceAddress(&addressUnitsActualLength,   1, &configurationSize)
    initSpaceAddress(&addressUnitsScaleLength,    1, &configurationSize)
    initSpaceAddress(&addressUnitsActualDistance, 1, &configurationSize)
    initSpaceAddress(&addressUnitsScaleDistance,  1, &configurationSize)
    initSpaceAddress(&addressUnitsActualSpeed,    1, &configurationSize)
    initSpaceAddress(&addressUnitsScaleSpeed,     1, &configurationSize)
    initSpaceAddress(&addressUnitsTime,           1, &configurationSize)

    configuration = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, defaultMemorySize: configurationSize, isReadOnly: false, description: "")
    
    super.init(nodeId: nodeId)

    virtualNodeType = MyTrainsVirtualNodeType.applicationNode

    configuration.delegate = self

    memorySpaces[configuration.space] = configuration

    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressUnitsActualLength)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressUnitsScaleLength)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressUnitsActualDistance)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressUnitsScaleDistance)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressUnitsActualSpeed)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressUnitsScaleSpeed)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressUnitsTime)

    if !memorySpacesInitialized {
      resetToFactoryDefaults()
    }
    
    cdiFilename = "MyTrains Application"

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

  internal var configuration : OpenLCBMemorySpace

  internal typealias getUniqueNodeIdQueueItem = (requester:UInt64, candidate:UInt64)
  
  internal var getUniqueNodeIdQueue : [getUniqueNodeIdQueueItem] = []
  
  internal var getUniqueNodeIdInProgress = false
  
  internal var timeoutTimer : Timer?
  
  internal var layoutList : [UInt64:LayoutListItem] = [:]
  
  internal var panelList : [UInt64:PanelListItem] = [:]
  
  internal var switchboardItemList : [UInt64:SwitchboardItemListItem] = [:]
  
  internal var nextObserverId : Int = 0
  
  internal var observers : [Int:MyTrainsAppDelegate] = [:]
  
  // MARK: Public Properties
  
  public var locoNetGateways : [UInt64:String] = [:]

  public var unitsActualLength : UnitLength {
    get {
      return UnitLength(rawValue: configuration.getUInt8(address: addressUnitsActualLength)!)!
    }
    set(value) {
      configuration.setUInt(address: addressUnitsActualLength, value: value.rawValue)
    }
  }

  public var unitsScaleLength : UnitLength {
    get {
      return UnitLength(rawValue: configuration.getUInt8(address: addressUnitsScaleLength)!)!
    }
    set(value) {
      configuration.setUInt(address: addressUnitsScaleLength, value: value.rawValue)
    }
  }

  public var unitsActualDistance : UnitLength {
    get {
      return UnitLength(rawValue: configuration.getUInt8(address: addressUnitsActualDistance)!)!
    }
    set(value) {
      configuration.setUInt(address: addressUnitsActualDistance, value: value.rawValue)
    }
  }

  public var unitsScaleDistance : UnitLength {
    get {
      return UnitLength(rawValue: configuration.getUInt8(address: addressUnitsScaleDistance)!)!
    }
    set(value) {
      configuration.setUInt(address: addressUnitsScaleDistance, value: value.rawValue)
    }
  }

  public var unitsActualSpeed : UnitSpeed {
    get {
      return UnitSpeed(rawValue: configuration.getUInt8(address: addressUnitsActualSpeed)!)!
    }
    set(value) {
      configuration.setUInt(address: addressUnitsActualSpeed, value: value.rawValue)
    }
  }

  public var unitsScaleSpeed : UnitSpeed {
    get {
      return UnitSpeed(rawValue: configuration.getUInt8(address: addressUnitsScaleSpeed)!)!
    }
    set(value) {
      configuration.setUInt(address: addressUnitsScaleSpeed, value: value.rawValue)
    }
  }
  
  public var unitsTime : UnitTime {
    get {
      return UnitTime(rawValue: configuration.getUInt8(address: addressUnitsTime)!)!
    }
    set(value) {
      configuration.setUInt(address: addressUnitsTime, value: value.rawValue)
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
    
    saveMemorySpaces()
    
  }
  
  internal override func resetReboot() {
    
    super.resetReboot()
    
    layoutList.removeAll()
    
    panelList.removeAll()
    
    switchboardItemList.removeAll()
    
    locoNetGateways.removeAll()
    
    networkLayer?.sendIdentifyConsumer(sourceNodeId: nodeId, event: .identifyMyTrainsLayouts)
    
    networkLayer?.sendIdentifyConsumer(sourceNodeId: nodeId, event: .identifyMyTrainsSwitchboardPanels)
    
    networkLayer?.sendIdentifyConsumer(sourceNodeId: nodeId, event: .identifyMyTrainsSwitchboardItems)
    
    networkLayer?.sendIdentifyProducer(sourceNodeId: nodeId, event: .myTrainsLayoutActivated)
    
    networkLayer?.sendIdentifyProducer(sourceNodeId: nodeId, event: .myTrainsLayoutDeactivated)
    
    networkLayer?.sendIdentifyProducer(sourceNodeId: nodeId, event: .myTrainsLayoutDeleted)
    
    networkLayer?.sendIdentifyProducer(sourceNodeId: nodeId, event: .nodeIsASwitchboardPanel)
    
    networkLayer?.sendIdentifyProducer(sourceNodeId: nodeId, event: .nodeIsASwitchboardItem)
    
    networkLayer?.sendIdentifyProducer(sourceNodeId: nodeId, event: .nodeIsALocoNetGateway)
    
    networkLayer?.sendWellKnownEvent(sourceNodeId: nodeId, eventId: .identifyMyTrainsLayouts)
    
    networkLayer?.sendWellKnownEvent(sourceNodeId: nodeId, eventId: .identifyMyTrainsSwitchboardPanels)
    
    networkLayer?.sendWellKnownEvent(sourceNodeId: nodeId, eventId: .identifyMyTrainsSwitchboardItems)
    
  }

  internal override func customizeDynamicCDI(cdi:String) -> String {
    
    var result = UnitLength.insertMap(cdi: cdi)
    result = UnitSpeed.insertMap(cdi: result)
    result = UnitTime.insertMap(cdi: result)
    
    return result
    
  }
  
  private func tryCandidate() {
    getUniqueNodeIdInProgress = !getUniqueNodeIdQueue.isEmpty
    if let item = getUniqueNodeIdQueue.first {
      getUniqueNodeIdInProgress = true
      startTimeoutTimer(interval: 1.0)
      networkLayer?.sendVerifyNodeIdNumberAddressed(sourceNodeId: nodeId, destinationNodeId: item.candidate)
    }
  }
  
  @objc func timeoutTimerAction() {

    stopTimeoutTimer()

    if getUniqueNodeIdInProgress {
      let item = getUniqueNodeIdQueue.removeFirst()
      networkLayer?.sendGetUniqueNodeIdReply(sourceNodeId: nodeId, destinationNodeId: item.requester, newNodeId: item.candidate)
      tryCandidate()
    }
    
  }
  
  private func startTimeoutTimer(interval: TimeInterval) {

    timeoutTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(timeoutTimerAction), userInfo: nil, repeats: false)

    RunLoop.current.add(timeoutTimer!, forMode: .common)
    
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
    networkLayer?.sendWellKnownEvent(sourceNodeId: nodeId, eventId: .emergencyStopAll)
  }

  public func sendClearGlobalEmergencyStop() {
    networkLayer?.sendWellKnownEvent(sourceNodeId: nodeId, eventId: .clearEmergencyStopAll)
  }

  public func sendGlobalPowerOff() {
    networkLayer?.sendWellKnownEvent(sourceNodeId: nodeId, eventId: .emergencyOffAll)
  }
  
  public func sendGlobalPowerOn() {
    networkLayer?.sendWellKnownEvent(sourceNodeId: nodeId, eventId: .clearEmergencyOffAll)
  }
  
  public func insertLayoutMap(cdi:String) -> String {
    
    var sorted : [(nodeId:UInt64, name:String)] = []

    for (nodeId, item) in layoutList {
      if item.masterNodeId == nodeId {
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

  // MARK: OpenLCBMemorySpaceDelegate Methods
  
  // MARK: OpenLCBNetworkLayerDelegate Methods
  
  public override func openLCBMessageReceived(message: OpenLCBMessage) {
    
    super.openLCBMessageReceived(message: message)
    
    switch message.messageTypeIndicator {
      
    case .verifiedNodeIDNumberSimpleSetSufficient, .verifiedNodeIDNumberFullProtocolRequired:
      
      if getUniqueNodeIdInProgress, let id = UInt64(bigEndianData: message.payload) {
        
        if (id & 0x0000ffffffffffff) == getUniqueNodeIdQueue[0].candidate {
          stopTimeoutTimer()
          getUniqueNodeIdQueue[0].candidate = nextUniqueNodeIdCandidate
          tryCandidate()
        }
        
      }
      
    case .simpleNodeIdentInfoReply:
      
      let node = OpenLCBNode(nodeId: message.sourceNodeId!)
      node.encodedNodeInformation = message.payload
      
      if let item = layoutList[node.nodeId] {
        var layout = item
        layout.layoutName = node.userNodeName
        layoutList[node.nodeId] = layout
        layoutListUpdated()
      }
      else if let item = panelList[node.nodeId] {
        var panel = item
        panel.panelName = node.userNodeName
        panelList[node.nodeId] = panel
        panelListUpdated()
      }
      else if let item = switchboardItemList[node.nodeId] {
        var switchboardItem = item
        switchboardItem.itemName = node.userNodeName
        switchboardItemList[node.nodeId] = switchboardItem
        switchboardItemListUpdated()
      }
      else if let _ = locoNetGateways[node.nodeId] {
        locoNetGateways[node.nodeId] = node.userNodeName
        locoNetGatewayListUpdated()
      }

    case .producerConsumerEventReport:
      
      if let event = OpenLCBWellKnownEvent(rawValue: message.eventId!) {
        
        switch event {
         
        case .myTrainsLayoutDeleted:

          if let layoutId = message.sourceNodeId {

            if layoutId == appLayoutId {
              networkLayer?.layoutNodeId = nil
            }
            
            layoutList.removeValue(forKey: layoutId)
            
            layoutListUpdated()

          }
          

        case .myTrainsLayoutActivated, .myTrainsLayoutDeactivated:
          
          if let tempNodeId = message.sourceNodeId {
            
            let layoutState : LayoutState = (event == .myTrainsLayoutActivated) ? .activated : .deactivated
            
            if layoutState == .activated {
              networkLayer?.layoutNodeId = tempNodeId
            }
            else if let appLayoutId, appLayoutId == tempNodeId {
              networkLayer?.layoutNodeId = nil
            }
            
            if let item = layoutList[tempNodeId] {
              var layout = item
              layout.layoutState = layoutState
              layoutList[tempNodeId] = layout
              layoutListUpdated()
            }
            else {
              layoutList[tempNodeId] = (masterNodeId:appNodeId!, layoutId:tempNodeId, layoutName:"", layoutState:layoutState)
              networkLayer?.sendSimpleNodeInformationRequest(sourceNodeId: nodeId, destinationNodeId: tempNodeId)
            }
            
          }
          
        case .nodeIsASwitchboardPanel:
          
          if let tempNodeId = message.sourceNodeId, let layoutNodeId = UInt64(bigEndianData: message.payload) {
            
            if let _ = panelList[tempNodeId] {} else {
              panelList[tempNodeId] = (layoutId:layoutNodeId, panelId: tempNodeId, panelName:"")
              networkLayer?.sendSimpleNodeInformationRequest(sourceNodeId: nodeId, destinationNodeId: tempNodeId)
            }
            
          }
          
        case .nodeIsASwitchboardItem:
          
          if let tempNodeId = message.sourceNodeId, let itemType = SwitchBoardItemType(rawValue: UInt16(bigEndianData: [message.payload[6], message.payload[7]])!), let layoutNodeId = UInt64(bigEndianData: [message.payload[0], message.payload[1], message.payload[2], message.payload[3], message.payload[4], message.payload[5]]) {
            
            if let item = switchboardItemList[tempNodeId] {
              var modifiedItem = item
              modifiedItem.itemType = itemType
              switchboardItemList[tempNodeId] = modifiedItem
            }
            else {
              switchboardItemList[tempNodeId] = (layoutId:layoutNodeId, itemId: tempNodeId, itemName:"", itemType:itemType)
            }
            networkLayer?.sendSimpleNodeInformationRequest(sourceNodeId: nodeId, destinationNodeId: tempNodeId)

          }
          
        case .nodeIsALocoNetGateway:
          
          if let tempNodeId = message.sourceNodeId {
            
            if let _ = locoNetGateways[tempNodeId] {} else {
              locoNetGateways[tempNodeId] = ""
              networkLayer?.sendSimpleNodeInformationRequest(sourceNodeId: nodeId, destinationNodeId: tempNodeId)
            }
            
          }
          
        default:
          break
        }
        
      }

    case .producerIdentifiedAsCurrentlyValid, .producerIdentifiedAsCurrentlyInvalid, .producerIdentifiedWithValidityUnknown:
      
      if let event = OpenLCBWellKnownEvent(rawValue: message.eventId!) {
        
        switch event {
        case .nodeIsALocoNetGateway:
          
          if let tempNodeId = message.sourceNodeId {
            
            if let _ = locoNetGateways[tempNodeId] {}
            else {
              locoNetGateways[tempNodeId] = ""
              networkLayer?.sendSimpleNodeInformationRequest(sourceNodeId: nodeId, destinationNodeId: tempNodeId)
            }
            
          }

        default:
          break
        }
        
      }

    case .identifyConsumer:
      
      if let event = OpenLCBWellKnownEvent(rawValue: message.eventId!) {
        
        switch event {
        
        case .nodeIsASwitchboardPanel, .nodeIsASwitchboardItem, .nodeIsALocoNetGateway, .myTrainsLayoutDeleted, .myTrainsLayoutActivated, .myTrainsLayoutDeactivated:
          
          networkLayer?.sendConsumerIdentified(sourceNodeId: nodeId, eventId: message.eventId!, validity: .unknown)
          
        default:
          break
        }
        
      }

    case .datagram:
      
      if message.destinationNodeId! == nodeId, let datagramType = message.datagramType {
        
        switch datagramType {
          
        case .getUniqueNodeIDCommand:
          
          networkLayer?.sendDatagramReceivedOK(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, timeOut: .replyPendingNoTimeout)
          
          let item : getUniqueNodeIdQueueItem = (message.sourceNodeId!, nextUniqueNodeIdCandidate)
          
          getUniqueNodeIdQueue.append(item)
          
          if !getUniqueNodeIdInProgress {
            tryCandidate()
          }
          
        default:
          break
        }
        
      }
      
    default:
      break
    }
    
  }

}
