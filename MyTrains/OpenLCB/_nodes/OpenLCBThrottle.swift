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
  case zapped
}

private enum ListenerState {
  case idle
  case awaitingAttachListenerReply
  case listenerAttached
  case attachFailed
}

private enum FDIState {
  case idle
  case gettingFDI
  case done
}

public class OpenLCBThrottle : OpenLCBNodeVirtual, XMLParserDelegate {
 
  // MARK: Constructors & Destructors
  
  public override init(nodeId: UInt64) {
    
    self.throttleId = UInt8(nodeId & 0xff)
    
    super.init(nodeId: nodeId)

    virtualNodeType = MyTrainsVirtualNodeType.throttleNode
    
    isFullProtocolRequired = true
    
    if !memorySpacesInitialized {
      resetToFactoryDefaults()
    }
    
  }
  
  deinit {
    
    searchResults.removeAll()
    
    xmlParser = nil
    
    fdi.removeAll()

    timeoutTimer?.invalidate()
    timeoutTimer = nil
    
    _delegate = nil
    
    _trainNode = nil
    
    fdiItems.removeAll()

  }
  
  // MARK: Private Properties
  
  private var searchResults : [UInt64:OpenLCBNode] = [:]
  
  private var searchEventId : UInt64 = 0
  
  private var _speed : Float = 0.0
  
  private var _globalEmergencyStop : Bool = false
  
  private var _globalEmergencyOff : Bool = false
  
  private var xmlParser : XMLParser?
  
  private var fdiItem : OpenLCBFDIItem = (number:0, kind:.binary, name:"")

  private var inFunction = false

  private var inName = false

  private var inNumber = false
  
  private var controllerState : ControllerState = .idle {
    didSet {
      
      if controllerState == .controllerAssigned {
        _throttleState = .activeController
        getSpeedFNX()
      }
      else if controllerState == .zapped && listenerState == .listenerAttached {
        _throttleState = .listener
      }
      else {
        _throttleState = .selected
      }
      
      delegate?.throttleStateChanged?(throttle: self)
      
    }
  }
  
  private var listenerState : ListenerState = .idle {
    didSet {
      
      if controllerState != .controllerAssigned && listenerState == .listenerAttached {
        _throttleState = .listener
        getSpeedFNX()
      }
      
      delegate?.throttleStateChanged?(throttle: self)
      
    }
  }
  
  private var fdiState : FDIState = .idle
  
  private var totalBytesRead = 0
  
  private var nextFDIStartAddress : Int = 0
  
  private var fdi : [UInt8] = []

  private var timeoutTimer : Timer?
  
  private var _throttleState : OpenLCBThrottleState = .idle {
    didSet {
      delegate?.throttleStateChanged?(throttle: self)
    }
  }
  
  private weak var _delegate : OpenLCBThrottleDelegate?
  
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
    return _throttleState
  }
  
  public var trainNode : OpenLCBNode? {
    return _trainNode
  }
  
  public var controllerInfo : String {
    return "\(throttleState.title)"
  }
  
  public var speed : Float {
    get {
      return _speed
    }
    set(value) {
      _speed = value
      guard let trainNode else {
        return
      }
      sendSetSpeedDirection(destinationNodeId: trainNode.nodeId, setSpeed: _speed, isForwarded: false)
    }
  }
  
  public var globalEmergencyStop : Bool {
    return _globalEmergencyStop
  }

  public var globalEmergencyOff : Bool {
    return _globalEmergencyOff
  }
  
  public var fdiItems : [OpenLCBFDIItem] = []

  // MARK: Private Methods
  
  private func getSpeedFNX() {
  
    guard let trainNode else {
      return
    }
    
    sendQuerySpeedsCommand(destinationNodeId: trainNode.nodeId)
    
    for address : UInt32 in 0...68 {
      sendQueryFunctionCommand(destinationNodeId: trainNode.nodeId, address: address)
    }
    
    fdiState = .gettingFDI
    
    totalBytesRead = 0
    
    nextFDIStartAddress = 0
    
    fdi = []
    
   sendReadCommand(destinationNodeId: trainNode.nodeId, addressSpace: OpenLCBNodeMemoryAddressSpace.fdi.rawValue, startAddress: nextFDIStartAddress, numberOfBytesToRead: 64)

  }
  
  internal override func resetToFactoryDefaults() {
    super.resetToFactoryDefaults()
    saveMemorySpaces()
  }
  
  @objc func timeoutTimerAction() {
    
    stopTimeoutTimer()
    
    controllerState = .assignFailed
    
    guard let trainNode else {
      return
    }
    
    let flags : UInt8 =
    0x80 | // Hide
    0x04 | // Link F0
    0x08   // Link Fn
    
    listenerState = .awaitingAttachListenerReply
    
    sendAttachListenerCommand(destinationNodeId: trainNode.nodeId, listenerNodeId: nodeId, flags: flags)

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
    guard let trainNode else {
      return
    }
    sendEmergencyStop(destinationNodeId: trainNode.nodeId)
  }
  
  public func assignController(trainNodeId:UInt64) {
    
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
    
    sendAssignControllerCommand(destinationNodeId: trainNode!.nodeId)
    
  }
  
  public func setFunction(address:UInt32, value:UInt16) {
    guard let trainNode else {
      return
    }
    sendSetFunction(destinationNodeId: trainNode.nodeId, address: address, value: value, isForwarded: false)
  }
  
  public func sendSetMove(distance:Float, cruiseSpeed:Float, finalSpeed:Float) {
    guard let trainNode else {
      return
    }
    sendSetMoveCommand(destinationNodeId: trainNode.nodeId, distance: distance, cruiseSpeed: cruiseSpeed, finalSpeed: finalSpeed)
  }
  
  public func sendStartMove(isStealAllowed:Bool, isPositionUpdateRequired:Bool) {
    guard let trainNode else {
      return
    }
    sendStartMoveCommand(destinationNodeId: trainNode.nodeId, isStealAllowed: isStealAllowed, isPositionUpdateRequired: isPositionUpdateRequired)
  }

  public func sendStopMove() {
    guard let trainNode else {
      return
    }
    sendStopMoveCommand(destinationNodeId: trainNode.nodeId)
  }

  public func sendGlobalEmergencyStop() {
    _globalEmergencyStop = true
    sendWellKnownEvent(eventId: .emergencyStopAll)
    delegate?.globalEmergencyChanged?(throttle: self)
  }
  
  public func sendClearGlobalEmergencyStop() {
    _globalEmergencyStop = false
    sendWellKnownEvent(eventId:.clearEmergencyStopAll )
    delegate?.globalEmergencyChanged?(throttle: self)
  }
  
  public func sendGlobalEmergencyOff() {
    _globalEmergencyOff = true
    sendWellKnownEvent(eventId:.emergencyOffAll )
    delegate?.globalEmergencyChanged?(throttle: self)
  }
  
  public func sendClearGlobalEmergencyOff() {
    _globalEmergencyOff = false
    sendWellKnownEvent(eventId:.clearEmergencyOffAll )
    delegate?.globalEmergencyChanged?(throttle: self)
  }
  
  public func releaseController() {

    guard let trainNode else {
      return
    }
    
    switch listenerState {
    case .listenerAttached:
      
      sendDetachListenerCommand(destinationNodeId: trainNode.nodeId, listenerNodeId: nodeId, flags: 0x00)
      
    default:
      break
    }
    
    listenerState = .idle

    switch controllerState {
    case .controllerAssigned:
      sendReleaseControllerCommand(destinationNodeId: trainNode.nodeId)
    default:
      break
    }
    
    controllerState = .idle
    
    _trainNode = nil

  }
  
  public func trainSearch(searchString : String, searchType:OpenLCBSearchType, searchMatchType:OpenLCBSearchMatchType, searchMatchTarget:OpenLCBSearchMatchTarget, trackProtocol:OpenLCBTrackProtocol) {
    
    searchResults = [:]
    
    delegate?.trainSearchResultsReceived?(throttle: self, results: [:])
    
    searchEventId = makeTrainSearchEventId(searchString: searchString, searchType: searchType, searchMatchType: searchMatchType, searchMatchTarget: searchMatchTarget, trackProtocol: trackProtocol)
    
    sendIdentifyProducer(eventId: searchEventId)
    
  }

  // MARK: OpenLCBNetworkLayerDelegate Methods
  
  public override func openLCBMessageReceived(message: OpenLCBMessage) {
    
    switch message.messageTypeIndicator {
    
    case .producerConsumerEventReport:
      
      delegate?.eventReceived?(throttle: self, message: message)

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
     
    case .tractionControlCommand:
      
      if let instruction = OpenLCBTractionControlInstructionType(rawValue: message.payload[0] & 0b01111111) {
        
        switch instruction {
        case .setSpeedDirection:
          
          if let uint16 = UInt16(bigEndianData: [message.payload[1], message.payload[2]]) {
            
            var f16 = float16_t()
            f16.v = uint16
            _speed = Float(float16: f16)
            
            delegate?.speedChanged?(throttle: self, speed: _speed)
            
          }
          
        case .setFunction:
          
          let bed = [
            message.payload[1],
            message.payload[2],
            message.payload[3]
          ]
          
          if let address = UInt32(bigEndianData: bed), let value = UInt16(bigEndianData: [message.payload[4], message.payload[5]]) {
            delegate?.functionChanged?(throttle: self, address: address, value: value)
          }

        case .emergencyStop:
          
          delegate?.emergencyStopChanged?(throttle: self)
          
        case .controllerConfiguration:
          
          if let configurationType = OpenLCBTractionControllerConfigurationType(rawValue: message.payload[1]) {
            
            switch configurationType {
            case .controllerChangingNotify:
              
              sendControllerChangedNotifyReply(destinationNodeId: message.sourceNodeId!, reject: false)
              
              controllerState = .zapped
              
            default:
              break
            }
            
          }
          
        case .listenerConfiguration:
          break
        case .tractionManagement:
          break
        default:
          break
        }
        
      }
      
    case .tractionControlReply:
      
      if let instruction = OpenLCBTractionControlInstructionType(rawValue: message.payload[0] & 0b01111111) {
        
        switch instruction {
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
              
              let flags : UInt8 =
              0x80 | // Hide
              0x04 | // Link F0
              0x08   // Link Fn
              
              listenerState = .awaitingAttachListenerReply
              
              sendAttachListenerCommand(destinationNodeId: message.sourceNodeId!, listenerNodeId: nodeId, flags: flags)

            case .queryController:
              break
            case .controllerChangingNotify:
              break
            default:
              break
            }
            
          }
          
        case .listenerConfiguration:
          
          if let configurationType = OpenLCBTractionListenerConfigurationType(rawValue: message.payload[1]) {
            
            switch configurationType {
              
            case .attachNode:
              
              if listenerState == .awaitingAttachListenerReply {
                
                var data : [UInt8] = message.payload
                data.removeLast(2)
                data.removeFirst(2)
                
                let rdata : [UInt8] = [message.payload[8], message.payload[9]]

                if let ln = UInt64(bigEndianData: data), ln == nodeId, let uint = UInt16(bigEndianData: rdata), let errorCode = OpenLCBErrorCode(rawValue: uint) {
                  
                  if errorCode == .success {
                    listenerState = .listenerAttached
                  }
                  else {
                    listenerState = .attachFailed
                  }
                  
                }
                
              }
          
            default:
              break
            }
            
          }
          
        case .tractionManagement:
          if let subType = OpenLCBTractionManagementType(rawValue: message.payload[1]), subType == .noopOrHeartbeatRequest {
            sendTractionManagementNoOp(destinationNodeId: message.sourceNodeId!)
          }
        default:
          break
        }
        
    }
      
    case .producerIdentifiedAsCurrentlyValid, .producerIdentifiedAsCurrentlyInvalid, .producerIdentifiedWithValidityUnknown:
      
      if message.eventId! == searchEventId {
        if let _ = searchResults[message.sourceNodeId!] {} else {
          let newNode = OpenLCBNode(nodeId: message.sourceNodeId!)
          searchResults[newNode.nodeId] = newNode
          sendSimpleNodeInformationRequest(destinationNodeId: newNode.nodeId)
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
      
    case .datagram:
      
      if let datagramType = message.datagramType {
        
        if fdiState == .gettingFDI {
          
          if datagramType == .readReplyGeneric {
            
            sendDatagramReceivedOK(destinationNodeId: message.sourceNodeId!, timeOut: .ok)
          
            var data = message.payload
          
            if let startAddress = UInt32(bigEndianData: [data[2], data[3], data[4], data[5]]), let thisSpace = OpenLCBNodeMemoryAddressSpace(rawValue: data[6]), startAddress == nextFDIStartAddress, thisSpace == .fdi {
              
              data.removeFirst(7)
              
              totalBytesRead += data.count
              
              var isLast = false
              
              for byte in data {
                if byte == 0 {
                  isLast = true
              //    fdi.append(byte)
                  break
                }
                fdi.append(byte)
              }
              
              if !isLast {
                
                nextFDIStartAddress += data.count
                
                sendReadCommand(destinationNodeId: trainNode!.nodeId, addressSpace: OpenLCBNodeMemoryAddressSpace.fdi.rawValue, startAddress: nextFDIStartAddress, numberOfBytesToRead: 64)
                
              }
              else {
                
                fdiState = .done

                let newData : Data = Data(fdi)
                xmlParser = XMLParser(data: newData)
                xmlParser?.delegate = self
                xmlParser?.parse()
                
              }
              
            }
            
          }
          else if datagramType == .readReplyFailureGeneric {

            fdiState = .done

            if !fdi.isEmpty {
              let newData : Data = Data(fdi)
              xmlParser = XMLParser(data: newData)
              xmlParser?.delegate = self
              xmlParser?.parse()
            }
            
          }
          
        }
        
      }
      
      fallthrough
      
    default:
      super.openLCBMessageReceived(message: message)
    }
    
  }
  
  // MARK: XMLParserDelegate Methods
  
  public func parserDidEndDocument(_ parser: XMLParser) {
//    print("parserDidEndDocument")
//    print(fdiItems)
    delegate?.fdiAvailable?(throttle: self)
  }

  #if DEBUG
  
  public func parserDidStartDocument(_ parser: XMLParser) {
    debugLog("parserDidStartDocument")
  }

  public func parser(_ parser: XMLParser, foundNotationDeclarationWithName name: String, publicID: String?, systemID: String?) {
    debugLog("parseFoundNotationDeclarationWithName: \(name)")
  }

  public func parser(_ parser: XMLParser, foundUnparsedEntityDeclarationWithName name: String, publicID: String?, systemID: String?, notationName: String?) {
    debugLog("parseFoundUnparsedEntityDeclarationWithName: \(name)")
  }

  public func parser(_ parser: XMLParser, foundAttributeDeclarationWithName attributeName: String, forElement elementName: String, type: String?, defaultValue: String?) {
    debugLog("parseFoundAttributeDeclarationWithName: \(attributeName)")
  }

  public func parser(_ parser: XMLParser, foundElementDeclarationWithName elementName: String, model: String) {
    debugLog("parseFoundElementDeclarationWithName: \(elementName)")
  }

  public func parser(_ parser: XMLParser, foundInternalEntityDeclarationWithName name: String, value: String?) {
    debugLog("parseFoundInternalEntityDeclarationWithName: \(name)")
  }

  public func parser(_ parser: XMLParser, foundExternalEntityDeclarationWithName name: String, publicID: String?, systemID: String?) {
    debugLog("parseFoundExternalEntityDeclarationWithName: \(name)")
  }
  
  #endif
  
  public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {

    switch elementName {
    case "function":
      inFunction = true
      if let temp = attributeDict["kind"], let kind = OpenLCBFDIFunctionKind(rawValue: temp) {
        fdiItem.kind = kind
      }
      
    case "name":
      inName = inFunction
    case "segment":
      break
    case "group":
      break
    case "fdi":
      break
    case "number":
      inNumber = inFunction
    default:
      #if DEBUG
      debugLog("parse FDI: unknown elemnt - \(elementName)")
      #endif
    }

  }

  public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    
    switch elementName {
    case "function":
      inFunction = false
      fdiItems.append(fdiItem)
    case "name":
      inName = false
    case "segment":
      break
    case "group":
      break
    case "fdi":
      break
    case "number":
      inNumber = false
    default:
      #if DEBUG
      debugLog("parse FDI: unknown elemnt - \(elementName)")
      #endif
    }
  }
  
  #if DEBUG
  public func parser(_ parser: XMLParser, didStartMappingPrefix prefix: String, toURI namespaceURI: String) {
    debugLog("parseDidStartMappingPrefix: \(prefix)")
  }

  public func parser(_ parser: XMLParser, didEndMappingPrefix prefix: String) {
    debugLog("parseDidEndMappingPrefix: \(prefix)")
  }
  #endif

  public func parser(_ parser: XMLParser, foundCharacters string: String) {
    if inName {
      fdiItem.name = string
    }
    else if inNumber {
      fdiItem.number = Int(string)!
    }
  }

  #if DEBUG
  
  public func parser(_ parser: XMLParser, foundIgnorableWhitespace whitespaceString: String) {
    debugLog("foundIgnorableWhiteSpace: \(whitespaceString)")
  }

  public func parser(_ parser: XMLParser, foundProcessingInstructionWithTarget target: String, data: String?) {
    debugLog("parseFoundProcessingInstructionWithTarget: \(target)")
  }

  public func parser(_ parser: XMLParser, foundComment comment: String) {
    debugLog("parseFoundComment: \(comment)")
  }

  public func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
    debugLog("parseFoundCDATA")
  }
  
  public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
    debugLog("parseErrorOccurred: \(parseError)")
  }

  public func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
    debugLog("validationErrorOccurred: \(validationError)")
  }

  #endif
  
  public func parser(_ parser: XMLParser, resolveExternalEntityName name: String, systemID: String?) -> Data? {
    return nil
  }

}
