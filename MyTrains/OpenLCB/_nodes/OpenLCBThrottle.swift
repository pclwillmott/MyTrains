//
//  OpenLCBThrottle.swift
//  MyTrains
//
//  Created by Paul Willmott on 24/06/2023.
//

import Foundation

public class OpenLCBThrottle : OpenLCBNodeVirtual {
 
  // MARK: Constructors & Destructors
  
  public init(throttleId:UInt8) {
    
    self.throttleId = throttleId
    
    let nodeId = 0x0801000dff00 + UInt64(throttleId)

    super.init(nodeId: nodeId)
    
    if !memorySpacesInitialized {
      resetToFactoryDefaults()
    }
    
  }
  
  // MARK: Private Properties
  
  private var searchResults : [UInt64:OpenLCBNode] = [:]
  
  private var searchEventId : UInt64 = 0
  
  private var _throttleState : OpenLCBThrottleState = .idle {
    didSet {
      delegate?.throttleStateChanged?(throttle: self)
    }
  }
  
  private var _delegate : OpenLCBThrottleDelegate?
  
  private var _trainNode : OpenLCBNode? {
    didSet {
      delegate?.throttleStateChanged?(throttle: self)
    }
  }
  
  // MARK: Public Properties
  
  public var throttleId : UInt8
  
  public var delegate : OpenLCBThrottleDelegate? {
    get {
      return _delegate
    }
    set(value) {
      _delegate = value
      _delegate?.throttleStateChanged?(throttle: self)
    }
  }
  
  public var throttleState : OpenLCBThrottleState {
    get {
      return _throttleState
    }
  }
  
  public var trainNode : OpenLCBNode? {
    get {
      return _trainNode
    }
  }
  
  // MARK: Private Methods
  
  internal override func resetToFactoryDefaults() {
    
    acdiManufacturerSpaceVersion = 4
    
    manufacturerName    = "Paul Willmott"
    nodeModelName       = "MyTrains Throttle"
    nodeHardwareVersion = "v0.1"
    nodeSoftwareVersion = "v0.1"
    
    acdiUserSpaceVersion = 2
    
    userNodeName        = "Throttle #\(throttleId)"
    userNodeDescription = ""
    
    saveMemorySpaces()
    
  }
  
  // MARK: Public Methods
  
  public func selectLocomotive(locomotiveNodeId:UInt64) {
    if let loco = searchResults[locomotiveNodeId] {
      _trainNode = loco
    }
    else {
      _trainNode = OpenLCBNode(nodeId: locomotiveNodeId)
    }
    _throttleState = .selected
    // TODO: Sort out releasing existing
  }
  
  public func trainSearch(searchString : String, searchType:OpenLCBSearchType, searchMatchType:OpenLCBSearchMatchType, searchMatchTarget:OpenLCBSearchMatchTarget, trackProtocol:OpenLCBTrackProtocol) {
    
    searchResults = [:]
    
    delegate?.trainSearchResultsReceived?(throttle: self, results: [:])
    
    var eventId : UInt64 = 0x090099ff00000000
    
    var numbers : [String] = []
    var temp : String = ""
    for char in searchString {
      switch char {
      case "0"..."9":
        temp += String(char)
      default:
        if !temp.isEmpty {
          numbers.append(temp)
          temp = ""
        }
      }
    }
    if !temp.isEmpty {
      numbers.append(temp)
    }
    
    var nibbles : [UInt8] = []
    
    for number in numbers {
      for digit in number {
        nibbles.append(UInt8(String(digit))!)
      }
      nibbles.append(0x0f)
    }
    
    while nibbles.count < 6 {
      nibbles.append(0x0f)
    }
    
    while nibbles.count > 6 {
      nibbles.removeLast()
    }
    
    var shift = 28
    for nibble in nibbles {
      eventId |= UInt64(nibble) << shift
      shift -= 4
    }
    
    eventId |= UInt64(searchType.rawValue | searchMatchType.rawValue | searchMatchTarget.rawValue | trackProtocol.rawValue)
    
    searchEventId = eventId
    
    networkLayer?.sendIdentifyProducer(sourceNodeId: nodeId, eventId: eventId)
    
  }

  // MARK: OpenLCBNetworkLayerDelegate Methods
  
  public override func openLCBMessageReceived(message: OpenLCBMessage) {
    
    super.openLCBMessageReceived(message: message)
   
    switch message.messageTypeIndicator {
    case .producerIdentifiedAsCurrentlyValid, .producerIdentifiedAsCurrentlyInvalid, .producerIdentifiedWithValidityUnknown:
      if message.eventId! == searchEventId {
        if let _ = searchResults[message.sourceNodeId!] {} else {
          let newNode = OpenLCBNode(nodeId: message.sourceNodeId!)
          searchResults[newNode.nodeId] = newNode
          networkLayer?.sendSimpleNodeInformationRequest(sourceNodeId: nodeId, destinationNodeId: newNode.nodeId)
        }
      }
    case .simpleNodeIdentInfoReply:
      if message.destinationNodeId! == nodeId, let newNode = searchResults[message.sourceNodeId!] {
        newNode.encodedNodeInformation = message.payload
        var results : [UInt64:String] = [:]
        for (_, node) in searchResults {
          var name = "\(node.manufacturerName) \(node.nodeModelName)"
          if !node.userNodeName.isEmpty {
            name = node.userNodeName
          }
          if !name.trimmingCharacters(in: .whitespaces).isEmpty {
            results[node.nodeId] = name
          }
        }
        if !results.isEmpty {
          delegate?.trainSearchResultsReceived?(throttle: self, results: results)
        }
      }
    default:
      break
    }
    
  }

}
