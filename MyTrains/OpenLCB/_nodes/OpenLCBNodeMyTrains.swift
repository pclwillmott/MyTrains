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
    
    super.init(nodeId: nodeId)

    virtualNodeType = MyTrainsVirtualNodeType.applicationNode
    
    if !memorySpacesInitialized {
      resetToFactoryDefaults()
    }
    
    cdiFilename = "MyTrains Application"

  }
  
  // MARK: Private Properties
  
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
  
  internal typealias getUniqueNodeIdQueueItem = (requester:UInt64, candidate:UInt64)
  
  internal var getUniqueNodeIdQueue : [getUniqueNodeIdQueueItem] = []
  
  internal var getUniqueNodeIdInProgress = false
  
  internal var timeoutTimer : Timer?
  
  internal var layoutList : [LayoutListItem] = []
  
  internal var nextObserverId : Int = 0
  
  internal var observers : [Int:MyTrainsAppDelegate] = [:]
  
  // MARK: Private Methods
  
  internal override func resetToFactoryDefaults() {
    super.resetToFactoryDefaults()
    saveMemorySpaces()
  }
  
  internal override func resetReboot() {
    
    super.resetReboot()
    
    networkLayer?.sendIdentifyConsumer(sourceNodeId: nodeId, event: .identifyMyTrainsLayouts)
    
    networkLayer?.sendIdentifyProducer(sourceNodeId: nodeId, event: .myTrainsLayoutActivated)
    
    networkLayer?.sendIdentifyProducer(sourceNodeId: nodeId, event: .myTrainsLayoutDeactivated)
    
    networkLayer?.sendWellKnownEvent(sourceNodeId: nodeId, eventId: .identifyMyTrainsLayouts)
    
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
      observer.LayoutListUpdated(layoutList: layoutList)
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
      
      var index = 0
      while index < layoutList.count {
        if layoutList[index].layoutId == message.sourceNodeId! {
          let layoutNode = OpenLCBNode(nodeId: message.sourceNodeId!)
          layoutNode.encodedNodeInformation = message.payload
          layoutList[index].layoutName = layoutNode.userNodeName
          break
        }
        index += 1
      }
      
      layoutList.sort {$0.layoutName < $1.layoutName}
      
      layoutListUpdated()
      
    case .producerConsumerEventReport:
      
      if let event = OpenLCBWellKnownEvent(rawValue: message.eventId!) {
        
        switch event {
         
        case .myTrainsLayoutActivated, .myTrainsLayoutDeactivated:
          
          let layoutNodeId = message.sourceNodeId!
          
          let layoutState : LayoutState = message.eventId! == OpenLCBWellKnownEvent.myTrainsLayoutActivated.rawValue ? .activated : .deactivated
          
          let masterNodeId = UInt64(bigEndianData: message.payload)!
          
          var found = false
          
          var index = 0
          while index < layoutList.count {
            if layoutList[index].layoutId == layoutNodeId {
              found = true
              layoutList[index].layoutState = layoutState
              layoutListUpdated()
            }
            index += 1
          }
          
          if !found {
            layoutList.append((masterNodeId:appNodeId!, layoutId:layoutNodeId, layoutName:"", layoutState:layoutState))
            networkLayer?.sendSimpleNodeInformationRequest(sourceNodeId: nodeId, destinationNodeId: layoutNodeId)
          }
          
        default:
          break
        }
        
      }

    case .identifyConsumer:
      
      if let event = OpenLCBWellKnownEvent(rawValue: message.eventId!) {
        
        switch event {
          
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
          
        case .identifyMyTrainsLayouts:
          
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
          
          var item : getUniqueNodeIdQueueItem = (message.sourceNodeId!, nextUniqueNodeIdCandidate)
          
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
