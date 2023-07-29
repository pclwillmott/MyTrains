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
  
  private var xmlParser : XMLParser?
  
  private var fdiItem : OpenLCBFDIItem = (number:0, kind:.binary, name:"")

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
      return "\(throttleState.title)"
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
  
  public var fdiItems : [OpenLCBFDIItem] = []

  // MARK: Private Methods
  
  private func getSpeedFNX() {
  
    guard let trainNode, let networkLayer else {
      return
    }
    
    networkLayer.sendQuerySpeedCommand(sourceNodeId: nodeId, destinationNodeId: trainNode.nodeId)
    
    for address : UInt32 in 0...68 {
      networkLayer.sendQueryFunctionCommand(sourceNodeId: nodeId, destinationNodeId: trainNode.nodeId, address: address)
    }
    
    fdiState = .gettingFDI
    
    totalBytesRead = 0
    
    nextFDIStartAddress = 0
    
    fdi = []
    
    networkLayer.sendNodeMemoryReadRequest(sourceNodeId: nodeId, destinationNodeId: trainNode.nodeId, addressSpace: OpenLCBNodeMemoryAddressSpace.fdi.rawValue, startAddress: nextFDIStartAddress, numberOfBytesToRead: 64)

  }
  
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
    
    guard let trainNode else {
      return
    }
    
    let flags : UInt8 =
    0x80 | // Hide
    0x04 | // Link F0
    0x08   // Link Fn
    
    listenerState = .awaitingAttachListenerReply
    
    networkLayer?.sendAttachListenerCommand(sourceNodeId: nodeId, destinationNodeId: trainNode.nodeId, listenerNodeId: nodeId, flags: flags)

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
    
    switch listenerState {
    case .listenerAttached:
      
      networkLayer.sendDetachListenerCommand(sourceNodeId: nodeId, destinationNodeId: trainNode.nodeId, listenerNodeId: nodeId, flags: 0x00)
      
    default:
      break
    }
    
    listenerState = .idle

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
     
    case .tractionControlCommand:
      
      if message.destinationNodeId! == nodeId, let instruction = OpenLCBTractionControlInstructionType(rawValue: message.payload[0] & 0b01111111) {
        
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
              
              networkLayer?.sendControllerChangedNotifyReply(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, reject: false)
              
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
      
      if message.destinationNodeId! == nodeId, let instruction = OpenLCBTractionControlInstructionType(rawValue: message.payload[0] & 0b01111111) {
        
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
              
              networkLayer?.sendAttachListenerCommand(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, listenerNodeId: nodeId, flags: flags)

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
              networkLayer?.sendTractionManagementNoOp(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!)
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
      
    case .datagram:
      
      if message.destinationNodeId! == nodeId, let datagramType = message.datagramType {
        
 //       print("datagram: \(message.datagramType)")
        
        if fdiState == .gettingFDI {
          
          if datagramType == .readReplyGeneric {
            
            networkLayer?.sendDatagramReceivedOK(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, timeOut: .ok)
          
            var data = message.payload
          
            if let startAddress = UInt32(bigEndianData: [data[2], data[3], data[4], data[5]]), let thisSpace = OpenLCBNodeMemoryAddressSpace(rawValue: data[6]), startAddress == nextFDIStartAddress, thisSpace == .fdi {
              
              data.removeFirst(7)
              
              totalBytesRead += data.count
              
              var isLast = false
              
              for byte in data {
                if byte == 0 {
                  isLast = true
                  fdi.append(byte)
                  break
                }
                fdi.append(byte)
              }
              
              if !isLast {
                
                nextFDIStartAddress += data.count
                
                networkLayer?.sendNodeMemoryReadRequest(sourceNodeId: nodeId, destinationNodeId: trainNode!.nodeId, addressSpace: OpenLCBNodeMemoryAddressSpace.fdi.rawValue, startAddress: nextFDIStartAddress, numberOfBytesToRead: 64)
                
              }
              else {
                
                fdiState = .done

          //      var pdata = fdi
          //      pdata.append(0)
          //      print(String(cString: pdata))
                
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
              //      var pdata = fdi
              //      pdata.append(0)
              //      print(String(cString: pdata))
              let newData : Data = Data(fdi)
              xmlParser = XMLParser(data: newData)
              xmlParser?.delegate = self
              xmlParser?.parse()
            }
            
          }
          
        }
        
      }
      
    default:
      break
    }
    
  }
  
  // MARK: XMLParserDelegate Methods
  
  public func parserDidStartDocument(_ parser: XMLParser) {
//    print("parserDidStartDocument")
  }

  public func parserDidEndDocument(_ parser: XMLParser) {
//    print("parserDidEndDocument")
//    print(fdiItems)
    delegate?.fdiAvailable?(throttle: self)
  }

  public func parser(_ parser: XMLParser, foundNotationDeclarationWithName name: String, publicID: String?, systemID: String?) {
    print("parseFoundNotationDeclarationWithName: \(name)")
  }

  public func parser(_ parser: XMLParser, foundUnparsedEntityDeclarationWithName name: String, publicID: String?, systemID: String?, notationName: String?) {
    print("parseFoundUnparsedEntityDeclarationWithName: \(name)")
  }

  public func parser(_ parser: XMLParser, foundAttributeDeclarationWithName attributeName: String, forElement elementName: String, type: String?, defaultValue: String?) {
    print("parseFoundAttributeDeclarationWithName: \(attributeName)")
  }

  public func parser(_ parser: XMLParser, foundElementDeclarationWithName elementName: String, model: String) {
    print("parseFoundElementDeclarationWithName: \(elementName)")
  }

  public func parser(_ parser: XMLParser, foundInternalEntityDeclarationWithName name: String, value: String?) {
    print("parseFoundInternalEntityDeclarationWithName: \(name)")
  }

  public func parser(_ parser: XMLParser, foundExternalEntityDeclarationWithName name: String, publicID: String?, systemID: String?) {
    print("parseFoundExternalEntityDeclarationWithName: \(name)")
  }
  
  private var inFunction = false
  private var inName = false
  private var inNumber = false
  
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
      print("parse FDI: unknown elemnt - \(elementName)")
    }

  }

  public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    
//    print("parseDidEndElement: \(elementName)")
    
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
      print("parse FDI: unknown elemnt - \(elementName)")
    }
  }
  
  public func parser(_ parser: XMLParser, didStartMappingPrefix prefix: String, toURI namespaceURI: String) {
    print("parseDidStartMappingPrefix: \(prefix)")
  }

  public func parser(_ parser: XMLParser, didEndMappingPrefix prefix: String) {
    print("parseDidEndMappingPrefix: \(prefix)")
  }

  public func parser(_ parser: XMLParser, foundCharacters string: String) {
//    print("parseFoundCharacters: \(string)")
    if inName {
      fdiItem.name = string
    }
    else if inNumber {
      fdiItem.number = Int(string)!
    }
  }

  public func parser(_ parser: XMLParser, foundIgnorableWhitespace whitespaceString: String) {
    print("foundIgnorableWhiteSpace: \(whitespaceString)")
  }

  public func parser(_ parser: XMLParser, foundProcessingInstructionWithTarget target: String, data: String?) {
    print("parseFoundProcessingInstructionWithTarget: \(target)")
  }

  public func parser(_ parser: XMLParser, foundComment comment: String) {
    print("parseFoundComment: \(comment)")
  }

  public func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
    print("parseFoundCDATA")
  }

  public func parser(_ parser: XMLParser, resolveExternalEntityName name: String, systemID: String?) -> Data? {
    return nil
  }

  public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
    print("parseErrorOccurred: \(parseError)")
  }

  public func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
    print("validationErrorOccurred: \(validationError)")
  }

}
