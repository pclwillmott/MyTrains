//
//  OpenLCBThrottle.swift
//  MyTrains
//
//  Created by Paul Willmott on 24/06/2023.
//

import Foundation

private enum ControllerState {
  case idle
  case awaitingAssignControllerReply
  case controllerAssigned
  case assignFailed
}

private enum ListenerState {
  case idle
  case awaitingAttachListenerReply
  case listenerAttach
  case attachFailed
}

public class OpenLCBThrottle : OpenLCBNodeVirtual {
 
  // MARK: Constructors & Destructors
  
  public override init(nodeId: UInt64) {
    
    self.throttleId = UInt8(nodeId & 0xff)
    
    super.init(nodeId: nodeId)

    virtualNodeType = MyTrainsVirtualNodeType.throttleNode
    
    if !memorySpacesInitialized {
      resetToFactoryDefaults()
    }
    
  }
  
  // MARK: Private Properties
  
  private var searchResults : [UInt64:OpenLCBNode] = [:]
  
  private var searchEventId : UInt64 = 0
  
  private var _speed : Float = 0.0
  
  private var _globalEmergencyStop : Bool = false
  
  private var _globalEmergencyOff : Bool = false
  
  private var controllerState : ControllerState = .idle {
    didSet {
      
      guard let trainNode, let networkLayer else {
        return
      }
      
      if controllerState == .controllerAssigned {
        
        _throttleState = .activeController
        
        networkLayer.sendQuerySpeedCommand(sourceNodeId: nodeId, destinationNodeId: trainNode.nodeId)
        
        for address : UInt32 in 0...68 {
          networkLayer.sendQueryFunctionCommand(sourceNodeId: nodeId, destinationNodeId: trainNode.nodeId, address: address)
        }
        
      }
      
      delegate?.throttleStateChanged?(throttle: self)
      
    }
  }
  
  private var listenerState : ListenerState = .idle {
    didSet {
      if controllerState != .controllerAssigned && listenerState == .listenerAttach {
        _throttleState = .listener
      }
      delegate?.throttleStateChanged?(throttle: self)
    }
  }
  
  private var timeoutTimer : Timer?
  
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
  
  public var controllerInfo : String {
    get {
      var result = "(\(controllerState))"
      return result
    }
  }
  
  public var speed : Float {
    get {
      return _speed
    }
    set(value) {
      _speed = value
      guard let trainNode, let networkLayer else {
        return
      }
      networkLayer.sendSetSpeedDirection(sourceNodeId: nodeId, destinationNodeId: trainNode.nodeId, setSpeed: _speed, isForwarded: false)
    }
  }
  
  public var globalEmergencyStop : Bool {
    get {
      return _globalEmergencyStop
    }
  }

  public var globalEmergencyOff : Bool {
    get {
      return _globalEmergencyOff
    }
  }

  // MARK: Private Methods
  
  internal override func resetToFactoryDefaults() {
    
    acdiManufacturerSpaceVersion = 4
    
    manufacturerName    = virtualNodeType.manufacturerName
    nodeModelName       = virtualNodeType.name
    nodeHardwareVersion = "v0.1"
    nodeSoftwareVersion = "v0.1"
    
    acdiUserSpaceVersion = 2
    
    userNodeName        = "Throttle #\(throttleId)"
    userNodeDescription = ""
    
    saveMemorySpaces()
    
  }
  
  @objc func timeoutTimerAction() {
    stopTimeoutTimer()
    controllerState = .assignFailed
  }
  
  private func startTimeoutTimer() {
    let interval : TimeInterval = 3.0
    timeoutTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(timeoutTimerAction), userInfo: nil, repeats: false)
    RunLoop.current.add(timeoutTimer!, forMode: .common)
  }
  
  private func stopTimeoutTimer() {
    timeoutTimer?.invalidate()
    timeoutTimer = nil
  }

  // MARK: Public Methods
  
  public func emergencyStop() {
    guard let trainNode, let networkLayer else {
      return
    }
    networkLayer.sendEmergencyStop(sourceNodeId: nodeId, destinationNodeId: trainNode.nodeId)
  }
  
  public func assignController(trainNodeId:UInt64) {
    
    guard let networkLayer else {
      return
    }
    
    releaseController()
    
    if let trainNode = searchResults[trainNodeId] {
      _trainNode = trainNode
    }
    else {
      _trainNode = OpenLCBNode(nodeId: trainNodeId)
    }
    
    _throttleState = .selected
    
    controllerState = .awaitingAssignControllerReply
    
    startTimeoutTimer()
    
    networkLayer.sendAssignControllerCommand(sourceNodeId: nodeId, destinationNodeId: trainNode!.nodeId)
    
  }
  
  public func setFunction(address:UInt32, value:UInt16) {
    guard let trainNode, let networkLayer else {
      return
    }
    networkLayer.sendSetFunction(sourceNodeId: nodeId, destinationNodeId: trainNode.nodeId, address: address, value: value, isForwarded: false)
  }
  
  public func sendGlobalEmergencyStop() {
    _globalEmergencyStop = true
    networkLayer?.sendWellKnownEvent(sourceNodeId: nodeId, eventId: .emergencyStopAll)
    delegate?.globalEmergencyChanged?(throttle: self)
  }
  
  public func sendClearGlobalEmergencyStop() {
    _globalEmergencyStop = false
    networkLayer?.sendWellKnownEvent(sourceNodeId: nodeId, eventId:.clearEmergencyStopAll )
    delegate?.globalEmergencyChanged?(throttle: self)
  }
  
  public func sendGlobalEmergencyOff() {
    _globalEmergencyOff = true
    networkLayer?.sendWellKnownEvent(sourceNodeId: nodeId, eventId:.emergencyOffAll )
    delegate?.globalEmergencyChanged?(throttle: self)
  }
  
  public func sendClearGlobalEmergencyOff() {
    _globalEmergencyOff = false
    networkLayer?.sendWellKnownEvent(sourceNodeId: nodeId, eventId:.clearEmergencyOffAll )
    delegate?.globalEmergencyChanged?(throttle: self)
  }
  
  public func releaseController() {

    guard let trainNode, let networkLayer else {
      return
    }
    
    switch controllerState {
    case .controllerAssigned:
      networkLayer.sendReleaseControllerCommand(sourceNodeId: nodeId, destinationNodeId: trainNode.nodeId)
    default:
      break
    }
    
    controllerState = .idle

    _trainNode = nil

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
    
    case .producerConsumerEventReport:
      
      if let event = OpenLCBWellKnownEvent(rawValue: message.eventId!) {
        
        switch event {
        case .emergencyOffAll:
          _globalEmergencyOff = true
          delegate?.globalEmergencyChanged?(throttle: self)
        case .clearEmergencyOffAll:
          _globalEmergencyOff = false
          delegate?.globalEmergencyChanged?(throttle: self)
        case .emergencyStopAll:
          _globalEmergencyStop = true
          delegate?.globalEmergencyChanged?(throttle: self)
        case .clearEmergencyStopAll:
          _globalEmergencyStop = false
          delegate?.globalEmergencyChanged?(throttle: self)
        default:
          break
        }
        
      }
      
    case .tractionControlReply:
      
      if message.destinationNodeId! == nodeId, let instruction = OpenLCBTractionControlInstructionType(rawValue: message.payload[0] & 0b01111111) {
        
        switch instruction {
        case .setSpeedDirection:
          break
        case .setFunction:
          break
        case .emergencyStop:
          break
        case .querySpeeds:
          
          if let uint16 = UInt16(bigEndianData: [message.payload[1], message.payload[2]]) {
            
            var f16 = float16_t()
            f16.v = uint16
            _speed = Float(float16: f16)
            
            delegate?.speedChanged?(throttle: self, speed: _speed)
            
          }
          
        case .queryFunction:
          
          let address = UInt32(bigEndianData: [0x00, message.payload[1], message.payload[2], message.payload[3]])
          let value = UInt16(bigEndianData: [message.payload[4], message.payload[5]])
          
          delegate?.functionChanged?(throttle: self, address: address!, value: value!)
          
        case .controllerConfiguration:
          
          if let configurationType = OpenLCBTractionControllerConfigurationType(rawValue: message.payload[1]) {
            
            switch configurationType {
            case .assignController:
              stopTimeoutTimer()
              if message.payload[2] == 0 {
                controllerState = .controllerAssigned
              }
              else {
                controllerState = .assignFailed
              }
              
            case .queryController:
              break
            case .controllerChangingNotify:
              break
            default:
              break
            }
            
          }
          
        case .listenerConfiguration:
          break
          
        case .tractionManagement:
          if let subType = OpenLCBTractionManagementType(rawValue: message.payload[1]), subType == .noopOrHeartbeatRequest {
              networkLayer?.sendTractionManagementNoOp(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!)
          }
        }
        
      }
      
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
