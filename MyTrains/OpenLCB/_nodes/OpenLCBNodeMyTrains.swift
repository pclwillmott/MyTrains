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
    
    configuration = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, defaultMemorySize: 6, isReadOnly: false, description: "")
    
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
    
    if !memorySpacesInitialized {
      resetToFactoryDefaults()
    }
    
    cdiFilename = "MyTrains Application"

  }
  
  // MARK: Private Properties
  
  // Configuration variable addresses
  
  internal let addressUnitsActualLength   : Int =  0
  internal let addressUnitsScaleLength    : Int =  1
  internal let addressUnitsActualDistance : Int =  2
  internal let addressUnitsScaleDistance  : Int =  3
  internal let addressUnitsActualSpeed    : Int =  4
  internal let addressUnitsScaleSpeed     : Int =  5

  internal var configuration : OpenLCBMemorySpace

  internal typealias getUniqueNodeIdQueueItem = (requester:UInt64, candidate:UInt64)
  
  internal var getUniqueNodeIdQueue : [getUniqueNodeIdQueueItem] = []
  
  internal var getUniqueNodeIdInProgress = false
  
  internal var timeoutTimer : Timer?
  
  internal var layoutList : [LayoutListItem] = []
  
  internal var panelList : [PanelListItem] = []
  
  internal var switchboardItemList : [SwitchboardItemListItem] = []
  
  internal var nextObserverId : Int = 0
  
  internal var observers : [Int:MyTrainsAppDelegate] = [:]
  
  // MARK: Public Properties
  
  public var unitsActualLength : UnitLength {
    get {
      return UnitLength(rawValue: Int(configuration.getUInt8(address: addressUnitsActualLength)!))!
    }
    set(value) {
      configuration.setUInt(address: addressUnitsActualLength, value: UInt8(value.rawValue))
    }
  }

  public var unitsScaleLength : UnitLength {
    get {
      return UnitLength(rawValue: Int(configuration.getUInt8(address: addressUnitsScaleLength)!))!
    }
    set(value) {
      configuration.setUInt(address: addressUnitsScaleLength, value: UInt8(value.rawValue))
    }
  }

  public var unitsActualDistance : UnitLength {
    get {
      return UnitLength(rawValue: Int(configuration.getUInt8(address: addressUnitsActualDistance)!))!
    }
    set(value) {
      configuration.setUInt(address: addressUnitsActualDistance, value: UInt8(value.rawValue))
    }
  }

  public var unitsScaleDistance : UnitLength {
    get {
      return UnitLength(rawValue: Int(configuration.getUInt8(address: addressUnitsScaleDistance)!))!
    }
    set(value) {
      configuration.setUInt(address: addressUnitsScaleDistance, value: UInt8(value.rawValue))
    }
  }

  public var unitsActualSpeed : UnitSpeed {
    get {
      return UnitSpeed(rawValue: Int(configuration.getUInt8(address: addressUnitsActualSpeed)!))!
    }
    set(value) {
      configuration.setUInt(address: addressUnitsActualSpeed, value: UInt8(value.rawValue))
    }
  }

  public var unitsScaleSpeed : UnitSpeed {
    get {
      return UnitSpeed(rawValue: Int(configuration.getUInt8(address: addressUnitsScaleSpeed)!))!
    }
    set(value) {
      configuration.setUInt(address: addressUnitsScaleSpeed, value: UInt8(value.rawValue))
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
    
    unitsActualLength   = .centimeters
    unitsScaleLength    = .meters
    unitsActualDistance = .centimeters
    unitsScaleDistance  = .kilometers
    unitsActualSpeed    = .centimetersPerSecond
    unitsScaleSpeed     = .kilometersPerHour
    
    saveMemorySpaces()
    
  }
  
  internal override func resetReboot() {
    
    super.resetReboot()
    
    layoutList = []
    
    panelList = []
    
    switchboardItemList = []
    
    networkLayer?.sendIdentifyConsumer(sourceNodeId: nodeId, event: .identifyMyTrainsLayouts)
    
    networkLayer?.sendIdentifyConsumer(sourceNodeId: nodeId, event: .identifyMyTrainsSwitchboardPanels)
    
    networkLayer?.sendIdentifyConsumer(sourceNodeId: nodeId, event: .identifyMyTrainsSwitchboardItems)
    
    networkLayer?.sendIdentifyProducer(sourceNodeId: nodeId, event: .myTrainsLayoutActivated)
    
    networkLayer?.sendIdentifyProducer(sourceNodeId: nodeId, event: .myTrainsLayoutDeactivated)
    
    networkLayer?.sendIdentifyProducer(sourceNodeId: nodeId, event: .myTrainsLayoutDeleted)
    
    networkLayer?.sendIdentifyProducer(sourceNodeId: nodeId, event: .nodeIsASwitchboardPanel)
    
    networkLayer?.sendIdentifyProducer(sourceNodeId: nodeId, event: .nodeIsASwitchboardItem)
    
    networkLayer?.sendWellKnownEvent(sourceNodeId: nodeId, eventId: .identifyMyTrainsLayouts)
    
    networkLayer?.sendWellKnownEvent(sourceNodeId: nodeId, eventId: .identifyMyTrainsSwitchboardPanels)
    
    networkLayer?.sendWellKnownEvent(sourceNodeId: nodeId, eventId: .identifyMyTrainsSwitchboardItems)
    
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
      observer.layoutListUpdated(layoutList: layoutList)
    }
  }

  private func panelListUpdated() {
    for (_, observer) in observers {
      observer.panelListUpdated(panelList: panelList)
    }
  }

  private func switchboardItemListUpdated() {
    for (_, observer) in observers {
      observer.switchboardItemListUpdated(switchboardItemList: switchboardItemList)
    }
  }

  // MARK: Public Methods
  
  public func addObserver(observer:MyTrainsAppDelegate) -> Int {
    let id = nextObserverId
    nextObserverId += 1
    observers[id] = observer
    layoutListUpdated()
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

    for item in layoutList {
      if item.masterNodeId == nodeId {
        sorted.append((nodeId:item.layoutId, name:item.layoutName))
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

    for item in panelList {
      if item.layoutId == layoutId {
        sorted.append((nodeId:item.panelId, name:item.panelName))
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

    for item in switchboardItemList {
      if item.layoutId == layoutId && item.itemType.isGroup {
        sorted.append((nodeId:item.itemId, name:item.itemName))
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
      
      var found = false
      
      var index = 0
      while index < layoutList.count {
        if layoutList[index].layoutId == message.sourceNodeId! {
          let layoutNode = OpenLCBNode(nodeId: message.sourceNodeId!)
          layoutNode.encodedNodeInformation = message.payload
          layoutList[index].layoutName = layoutNode.userNodeName
          found = true
          break
        }
        index += 1
      }
      
      if found {
        layoutList.sort {$0.layoutName < $1.layoutName}
        layoutListUpdated()
      }
      else {

        index = 0
        while index < panelList.count {
          if panelList[index].panelId == message.sourceNodeId! {
            let panelNode = OpenLCBNode(nodeId: message.sourceNodeId!)
            panelNode.encodedNodeInformation = message.payload
            panelList[index].panelName = panelNode.userNodeName
            found = true
            break
          }
          index += 1
        }

        if found {
          panelList.sort {$0.panelName < $1.panelName}
          panelListUpdated()
        }
        else {
          
          index = 0
          while index < switchboardItemList.count {
            if switchboardItemList[index].itemId == message.sourceNodeId! {
              let itemNode = OpenLCBNode(nodeId: message.sourceNodeId!)
              itemNode.encodedNodeInformation = message.payload
              switchboardItemList[index].itemName = itemNode.userNodeName
              found = true
              break
            }
            index += 1
          }

          if found {
            switchboardItemList.sort {$0.itemName < $1.itemName}
            switchboardItemListUpdated()
          }

        }

      }
      
    case .producerConsumerEventReport:
      
      if let event = OpenLCBWellKnownEvent(rawValue: message.eventId!) {
        
        switch event {
         
        case .myTrainsLayoutDeleted:

          if message.sourceNodeId! == appLayoutId {
            networkLayer?.layoutNodeId = nil
          }

          var index = 0
          while index < layoutList.count {
            if layoutList[index].layoutId == message.sourceNodeId! {
              layoutList.remove(at: index)
              layoutListUpdated()
              break
            }
            index += 1
          }

        case .myTrainsLayoutActivated, .myTrainsLayoutDeactivated:
          
          let tempNodeId = message.sourceNodeId!
          
          let layoutState : LayoutState = message.eventId! == OpenLCBWellKnownEvent.myTrainsLayoutActivated.rawValue ? .activated : .deactivated
          
          let masterNodeId = UInt64(bigEndianData: message.payload)!

          if layoutState == .activated {
            networkLayer?.layoutNodeId = tempNodeId
          }
          else if let appLayoutId, appLayoutId == tempNodeId {
            networkLayer?.layoutNodeId = nil
          }

          var found = false
          
          var index = 0
          while index < layoutList.count {
            if layoutList[index].layoutId == tempNodeId {
              found = true
              layoutList[index].layoutState = layoutState
              layoutListUpdated()
            }
            index += 1
          }
          
          if !found {
            layoutList.append((masterNodeId:appNodeId!, layoutId:tempNodeId, layoutName:"", layoutState:layoutState))
            networkLayer?.sendSimpleNodeInformationRequest(sourceNodeId: nodeId, destinationNodeId: tempNodeId)
          }

        case .nodeIsASwitchboardPanel:
          
          let tempNodeId = message.sourceNodeId!
          
          let layoutNodeId = UInt64(bigEndianData: message.payload)!

          var found = false
          
          var index = 0
          while index < panelList.count {
            if panelList[index].panelId == tempNodeId {
              found = true
            }
            index += 1
          }
          
          if !found {
            panelList.append((layoutId:layoutNodeId, panelId: tempNodeId, panelName:""))
            networkLayer?.sendSimpleNodeInformationRequest(sourceNodeId: nodeId, destinationNodeId: tempNodeId)
          }

        case .nodeIsASwitchboardItem:
          
          let tempNodeId = message.sourceNodeId!
          
          print(message.payload)
          let itemType = SwitchBoardItemType(rawValue: UInt16(bigEndianData: [message.payload[6], message.payload[7]])!)!
          
          message.payload.removeLast(2)
          
          let layoutNodeId = UInt64(bigEndianData: message.payload)!

          var found = false
          
          var index = 0
          while index < switchboardItemList.count {
            if switchboardItemList[index].itemId == tempNodeId {
              found = true
            }
            index += 1
          }
          
          if !found {
            switchboardItemList.append((layoutId:layoutNodeId, itemId: tempNodeId, itemName:"", itemType:itemType))
            networkLayer?.sendSimpleNodeInformationRequest(sourceNodeId: nodeId, destinationNodeId: tempNodeId)
          }

        default:
          break
        }
        
      }

      
    case .identifyConsumer:
      
      if let event = OpenLCBWellKnownEvent(rawValue: message.eventId!) {
        
        switch event {
        
        case .nodeIsASwitchboardPanel, .nodeIsASwitchboardItem:
          
          networkLayer?.sendConsumerIdentified(sourceNodeId: nodeId, eventId: message.eventId!, validity: .unknown)

        case .myTrainsLayoutDeleted:
          
          networkLayer?.sendConsumerIdentified(sourceNodeId: nodeId, eventId: message.eventId!, validity: .unknown)

        case .myTrainsLayoutActivated:
          
          var found = false
          
          for item in layoutList {
            if item.layoutId == message.sourceNodeId! {
              let validity : OpenLCBValidity = item.layoutState == .activated ? .valid : .invalid
              networkLayer?.sendConsumerIdentified(sourceNodeId: nodeId, eventId: message.eventId!, validity: validity)
              found = true
              break
            }
          }
          
          if !found {
            networkLayer?.sendConsumerIdentified(sourceNodeId: nodeId, eventId: message.eventId!, validity: .unknown)
          }
          
        case .myTrainsLayoutDeactivated:
          
          var found = false
          
          for item in layoutList {
            if item.layoutId == message.sourceNodeId! {
              let validity : OpenLCBValidity = item.layoutState == .deactivated ? .valid : .invalid
              networkLayer?.sendConsumerIdentified(sourceNodeId: nodeId, eventId: message.eventId!, validity: validity)
              found = true
              break
            }
          }
          
          if !found {
            networkLayer?.sendConsumerIdentified(sourceNodeId: nodeId, eventId: message.eventId!, validity: .unknown)
          }
          
        default:
          break
        }
        
      }

    case .identifyProducer:
      
      if let event = OpenLCBWellKnownEvent(rawValue: message.eventId!) {
        
        switch event {
          
        case .identifyMyTrainsLayouts, .identifyMyTrainsSwitchboardItems, .identifyMyTrainsSwitchboardPanels:
          
          networkLayer?.sendProducerIdentified(sourceNodeId: nodeId, eventId: message.eventId!, validity: .valid)
          
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
