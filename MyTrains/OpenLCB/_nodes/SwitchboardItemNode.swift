//
//  SwitchboardItemNode.swift
//  MyTrains
//
//  Created by Paul Willmott on 11/01/2024.
//

import Foundation

public class SwitchboardItemNode : OpenLCBNodeVirtual {

  public init(nodeId:UInt64, layoutNodeId:UInt64 = 0) {

    configuration = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, defaultMemorySize: 285, isReadOnly: false, description: "")
    
    super.init(nodeId: nodeId)
    
    virtualNodeType = MyTrainsVirtualNodeType.switchboardItemNode
    
    if layoutNodeId != 0 {
      self.layoutNodeId = layoutNodeId
    }
    
    configuration.delegate = self

    memorySpaces[configuration.space] = configuration

    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressPanelId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressItemType)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressXPos)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressYPos)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressOrientation)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressGroupId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressDirectionality)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressAllowShunt)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressElectrificationType)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressIsCriticalSection)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressIsHiddenSection)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressEnterDetectionZoneEventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressExitDetectionZoneEventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressEnterTranspondingZoneEventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressExitTranspondingZoneEventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressTrackFaultEventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressTrackFaultClearedEventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressLocationServicesEventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressTrackGauge)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressTrackGradient)
    
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressDimensionA)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressDimensionB)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressDimensionC)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressDimensionD)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressDimensionE)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressDimensionF)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressDimensionG)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressDimensionH)
    
    configuration.registerUnitConversion(address: addressDimensionA, unitConversionType: .actualLength8)
    configuration.registerUnitConversion(address: addressDimensionB, unitConversionType: .actualLength8)
    configuration.registerUnitConversion(address: addressDimensionC, unitConversionType: .actualLength8)
    configuration.registerUnitConversion(address: addressDimensionD, unitConversionType: .actualLength8)
    configuration.registerUnitConversion(address: addressDimensionE, unitConversionType: .actualLength8)
    configuration.registerUnitConversion(address: addressDimensionF, unitConversionType: .actualLength8)
    configuration.registerUnitConversion(address: addressDimensionG, unitConversionType: .actualLength8)
    configuration.registerUnitConversion(address: addressDimensionH, unitConversionType: .actualLength8)

    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSW1TurnoutMotorType)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSW1ThrowEventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSW1ThrownEventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSW1CloseEventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSW1ClosedEventId)

    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSW2TurnoutMotorType)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSW2ThrowEventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSW2ThrownEventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSW2CloseEventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSW2ClosedEventId)

    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSW3TurnoutMotorType)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSW3ThrowEventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSW3ThrownEventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSW3CloseEventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSW3ClosedEventId)

    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSW4TurnoutMotorType)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSW4ThrowEventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSW4ThrownEventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSW4CloseEventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSW4ClosedEventId)

    if !memorySpacesInitialized {
      resetToFactoryDefaults()
    }

    cdiFilename = "MyTrains Switchboard Item"

  }

  // MARK: Private Properties

  // Configuration varaible addresses
  
  internal let addressPanelId                      : Int =  0 // 8
  internal let addressItemType                     : Int =  8 // 10
  internal let addressXPos                         : Int = 10 // 12
  internal let addressYPos                         : Int = 12 // 14
  internal let addressOrientation                  : Int = 14 // 15
  internal let addressGroupId                      : Int = 15 // 23
  internal let addressDirectionality               : Int = 23 // 24
  internal let addressAllowShunt                   : Int = 24 // 25
  internal let addressElectrificationType          : Int = 25 // 26
  internal let addressIsCriticalSection            : Int = 26 // 27
  internal let addressIsHiddenSection              : Int = 27 // 28
  internal let addressEnterDetectionZoneEventId    : Int = 28 // 36
  internal let addressExitDetectionZoneEventId     : Int = 36 // 44
  internal let addressEnterTranspondingZoneEventId : Int = 44 // 52
  internal let addressExitTranspondingZoneEventId  : Int = 52 // 60
  internal let addressTrackFaultEventId            : Int = 60 // 68
  internal let addressTrackFaultClearedEventId     : Int = 68 // 76
  internal let addressLocationServicesEventId      : Int = 76 // 84
  internal let addressTrackGradient                : Int = 84 // 88
  internal let addressTrackGauge                   : Int = 88 // 89
  internal let addressDimensionA                   : Int = 89 // 97
  internal let addressDimensionB                   : Int = 97 // 105
  internal let addressDimensionC                   : Int = 105 // 113
  internal let addressDimensionD                   : Int = 113 // 121
  internal let addressDimensionE                   : Int = 121 // 129
  internal let addressDimensionF                   : Int = 129 // 137
  internal let addressDimensionG                   : Int = 137 // 145
  internal let addressDimensionH                   : Int = 145 // 153
  internal let addressSW1TurnoutMotorType          : Int = 153 // 154
  internal let addressSW1ThrowEventId              : Int = 154 // 162
  internal let addressSW1CloseEventId              : Int = 162 // 170
  internal let addressSW1ThrownEventId             : Int = 170 // 178
  internal let addressSW1ClosedEventId             : Int = 178 // 186
  internal let addressSW2TurnoutMotorType          : Int = 186 // 187
  internal let addressSW2ThrowEventId              : Int = 187 // 195
  internal let addressSW2CloseEventId              : Int = 195 // 203
  internal let addressSW2ThrownEventId             : Int = 203 // 211
  internal let addressSW2ClosedEventId             : Int = 211 // 219
  internal let addressSW3TurnoutMotorType          : Int = 219 // 220
  internal let addressSW3ThrowEventId              : Int = 220 // 228
  internal let addressSW3CloseEventId              : Int = 228 // 236
  internal let addressSW3ThrownEventId             : Int = 236 // 244
  internal let addressSW3ClosedEventId             : Int = 244 // 252
  internal let addressSW4TurnoutMotorType          : Int = 252 // 253
  internal let addressSW4ThrowEventId              : Int = 253 // 261
  internal let addressSW4CloseEventId              : Int = 261 // 269
  internal let addressSW4ThrownEventId             : Int = 269 // 277
  internal let addressSW4ClosedEventId             : Int = 277 // 285

  private var configuration : OpenLCBMemorySpace
  
  private var layoutNode : LayoutNode? {
    return networkLayer!.virtualNodeLookup[layoutNodeId] as? LayoutNode
  }

  // MARK: Public Properties
  
  public var panelId : UInt64 {
    get {
      return configuration.getUInt64(address: addressPanelId)!
    }
    set(value) {
      configuration.setUInt(address: addressPanelId, value: value)
    }
  }

  public var itemType : SwitchBoardItemType {
    get {
      return SwitchBoardItemType(rawValue: configuration.getUInt16(address: addressItemType)!)!
    }
    set(value) {
      configuration.setUInt(address: addressPanelId, value: value.rawValue)
    }
  }

  public var xPos : UInt16 {
    get {
      return configuration.getUInt16(address: addressXPos)!
    }
    set(value) {
      configuration.setUInt(address: addressXPos, value: value)
    }
  }

  public var yPos : UInt16 {
    get {
      return configuration.getUInt16(address: addressYPos)!
    }
    set(value) {
      configuration.setUInt(address: addressYPos, value: value)
    }
  }

  public var orientation : Orientation {
    get {
      return Orientation(rawValue: configuration.getUInt8(address: addressOrientation)!)!
    }
    set(value) {
      configuration.setUInt(address: addressOrientation, value: value.rawValue)
    }
  }

  public var groupId : UInt64 {
    get {
      return configuration.getUInt64(address: addressGroupId)!
    }
    set(value) {
      configuration.setUInt(address: addressGroupId, value: value)
    }
  }

  public var directionality : BlockDirection {
    get {
      return BlockDirection(rawValue: configuration.getUInt8(address: addressDirectionality)!)!
    }
    set(value) {
      configuration.setUInt(address: addressDirectionality, value: value.rawValue)
    }
  }

  public var isReverseShuntAllowed : Bool {
    get {
      return configuration.getUInt8(address: addressAllowShunt)! == 1
    }
    set(value) {
      configuration.setUInt(address: addressAllowShunt, value: value ? UInt8(1) : UInt8(0))
    }
  }

  public var trackElectrificationType : TrackElectrificationType {
    get {
      return TrackElectrificationType(rawValue: configuration.getUInt8(address: addressElectrificationType)!)!
    }
    set(value) {
      configuration.setUInt(address: addressElectrificationType, value: value.rawValue)
    }
  }

  public var isCriticalSection : Bool {
    get {
      return configuration.getUInt8(address: addressIsCriticalSection)! == 1
    }
    set(value) {
      configuration.setUInt(address: addressIsCriticalSection, value: value ? UInt8(1) : UInt8(0))
    }
  }

  public var isHiddenSection : Bool {
    get {
      return configuration.getUInt8(address: addressIsHiddenSection)! == 1
    }
    set(value) {
      configuration.setUInt(address: addressIsHiddenSection, value: value ? UInt8(1) : UInt8(0))
    }
  }

  public var enterDetectionZoneEventId : UInt64 {
    get {
      return configuration.getUInt64(address: addressEnterDetectionZoneEventId)!
    }
    set(value) {
      configuration.setUInt(address: addressEnterDetectionZoneEventId, value: value)
    }
  }

  public var exitDetectionZoneEventId : UInt64 {
    get {
      return configuration.getUInt64(address: addressExitDetectionZoneEventId)!
    }
    set(value) {
      configuration.setUInt(address: addressExitDetectionZoneEventId, value: value)
    }
  }

  public var enterTranspondingZoneEventId : UInt64 {
    get {
      return configuration.getUInt64(address: addressEnterTranspondingZoneEventId)!
    }
    set(value) {
      configuration.setUInt(address: addressEnterTranspondingZoneEventId, value: value)
    }
  }

  public var exitTranspondingZoneEventId : UInt64 {
    get {
      return configuration.getUInt64(address: addressExitTranspondingZoneEventId)!
    }
    set(value) {
      configuration.setUInt(address: addressExitTranspondingZoneEventId, value: value)
    }
  }

  public var trackFaultEventId : UInt64 {
    get {
      return configuration.getUInt64(address: addressTrackFaultEventId)!
    }
    set(value) {
      configuration.setUInt(address: addressTrackFaultEventId, value: value)
    }
  }

  public var trackFaultClearedEventId : UInt64 {
    get {
      return configuration.getUInt64(address: addressTrackFaultClearedEventId)!
    }
    set(value) {
      configuration.setUInt(address: addressTrackFaultClearedEventId, value: value)
    }
  }

  public var locationServicesEventId : UInt64 {
    get {
      return configuration.getUInt64(address: addressLocationServicesEventId)!
    }
    set(value) {
      configuration.setUInt(address: addressLocationServicesEventId, value: value)
    }
  }

  public var trackGauge : TrackGauge {
    get {
      return TrackGauge(rawValue: configuration.getUInt8(address: addressTrackGauge)!)!
    }
    set(value) {
      configuration.setUInt(address: addressTrackGauge, value: value.rawValue)
    }
  }

  public var trackGradient : Float32 {
    get {
      return configuration.getFloat(address: addressTrackGradient)!
    }
    set(value) {
      configuration.setFloat(address: addressTrackGradient, value: value)
    }
  }

  // MARK: Private Methods

  internal override func resetToFactoryDefaults() {

    super.resetToFactoryDefaults()
    
    panelId = 0
    
    itemType = .straight
    
    xPos = 1
    yPos = 1
    
    orientation = .deg0
    
    groupId = 0
    
    directionality = .bidirectional
    
    isReverseShuntAllowed = false
    
    trackElectrificationType = .notElectrified
    
    isCriticalSection = false
    
    isHiddenSection = false
    
    enterDetectionZoneEventId = 0
    exitDetectionZoneEventId = 0
    enterTranspondingZoneEventId = 0
    exitTranspondingZoneEventId = 0
    trackFaultEventId = 0
    trackFaultClearedEventId = 0
    locationServicesEventId = 0
    
    trackGauge = .ho
    
    trackGradient = 0.0
    
    for routeNumber in 1...8 {
      setDimension(routeNumber: routeNumber, value: 0.0)
    }
    
    for turnoutNumber in 1...4 {
      setTurnoutMotorType(turnoutNumber: turnoutNumber, motorType: .manual)
      setTurnoutThrowEventId(turnoutNumber: turnoutNumber, eventId: 0)
      setTurnoutThrownEventId(turnoutNumber: turnoutNumber, eventId: 0)
      setTurnoutCloseEventId(turnoutNumber: turnoutNumber, eventId: 0)
      setTurnoutClosedEventId(turnoutNumber: turnoutNumber, eventId: 0)
    }

    saveMemorySpaces()

  }
  
  override internal func customizeDynamicCDI(cdi:String) -> String {
 
    var result = SwitchBoardItemType.insertMap(cdi: cdi)
    result = Orientation.insertMap(cdi: result)
    result = BlockDirection.insertMap(cdi: result)
    result = YesNo.insertMap(cdi: result)
    result = TrackElectrificationType.insertMap(cdi: result)
    result = TrackGauge.insertMap(cdi: result, layout: layoutNode)

    if let app = networkLayer?.myTrainsNode {
      result = app.insertPanelMap(cdi: result, layoutId: layoutNodeId)
      result = app.insertGroupMap(cdi: result, layoutId: layoutNodeId)
    }
    
    var routes = ""
    
    if itemType.numberOfDimensionsRequired > 0 {
      
      for route in 1 ... itemType.numberOfDimensionsRequired {
        routes += "<float size='8'>\n"
        if itemType.isBlock {
          routes += "<name>Length of Block (%%ACTUAL_LENGTH_UNITS%%)</name>\n"
        }
        else {
          routes += "<name>Length of Route #\(route) (%%ACTUAL_LENGTH_UNITS%%)</name>\n"
        }
        routes += "<min>0.0</min>\n"
        routes += "</float>\n\n"
      }
      
    }
    
    if itemType.numberOfDimensionsRequired < 8 {
      for route in itemType.numberOfDimensionsRequired + 1 ... 8 {
        routes += "<group offset='8'/>\n"
      }
    }
    
    result = result.replacingOccurrences(of: CDI.ROUTE_DIMENSION, with: routes)

    var turnouts = ""
    
    if itemType.numberOfTurnoutSwitches > 0 {
 
      turnouts += "<group replication='\(itemType.numberOfTurnoutSwitches)'>\n"
      turnouts += "  <name>Switch Configuration</name>\n"
      turnouts += "  <repname>Switch #</repname>\n"

      turnouts += "<int size='1'>\n"
      turnouts += "  <name>Turnout Motor Type</name>\n"
      turnouts += "  %%TURNOUT_MOTOR_TYPE%%"
      turnouts += "</int>\n"

      turnouts += "<eventid>\n"
      turnouts += "  <name>Throw Switch Event ID</name>\n"
      turnouts += "</eventid>\n"

      turnouts += "<eventid>"
      turnouts += "  <name>Close Switch Event ID</name>\n"
      turnouts += "</eventid>\n"

      turnouts += "<eventid>\n"
      turnouts += "  <name>Switch Thrown Confirmation Event ID</name>\n"
      turnouts += "</eventid>\n"

      turnouts += "<eventid>\n"
      turnouts += "  <name>Switch Closed Confirmation Event ID</name>\n"
      turnouts += "</eventid>\n"

      turnouts += "</group>\n"

    }
    
    if itemType.numberOfTurnoutSwitches < 4 {
      for route in itemType.numberOfTurnoutSwitches + 1 ... 4 {
        turnouts += "<group offset='33'/>\n"
      }
    }

    result = result.replacingOccurrences(of: CDI.TURNOUT_SWITCHES, with: turnouts)

    result = TurnoutMotorType.insertMap(cdi: result)

    return result
    
  }

  internal override func resetReboot() {
    
    super.resetReboot()
    
    networkLayer?.sendIdentifyProducer(sourceNodeId: nodeId, event: .identifyMyTrainsSwitchboardItems)
    
    networkLayer?.sendIdentifyConsumer(sourceNodeId: nodeId, event: .nodeIsASwitchboardItem)
    
    var payload = layoutNodeId.bigEndianData
    payload.removeFirst(2)
    payload.append(contentsOf: itemType.rawValue.bigEndianData)
    
    networkLayer?.sendWellKnownEvent(sourceNodeId: nodeId, eventId: .nodeIsASwitchboardItem, payload: payload)

  }

 // MARK: Public Methods
  
  public func getDimension(routeNumber:Int) -> Double?
  {
    guard routeNumber > 0 && routeNumber <= 8 else {
      return nil
    }
    return configuration.getDouble(address: addressDimensionA + (routeNumber - 1) * 8)!
  }
  
  public func setDimension(routeNumber:Int, value:Double) {
    if routeNumber > 0 && routeNumber <= 8 {
      configuration.setDouble(address: addressDimensionA + (routeNumber - 1) * 8, value: value)
    }
  }
  
  public func getTurnoutMotorType(turnoutNumber:Int) -> TurnoutMotorType? {
    guard turnoutNumber > 0 && turnoutNumber <= 4 else {
      return nil
    }
    return TurnoutMotorType(rawValue: configuration.getUInt8(address: addressSW1TurnoutMotorType + (turnoutNumber - 1) * 33)!)
  }
  
  public func setTurnoutMotorType(turnoutNumber:Int, motorType:TurnoutMotorType) {
    if turnoutNumber > 0 && turnoutNumber <= 4 {
      configuration.setUInt(address: addressSW1TurnoutMotorType + (turnoutNumber - 1) * 33, value: motorType.rawValue)
    }
  }
  
  public func getTurnoutThrowEventId(turnoutNumber:Int) -> UInt64? {
    guard turnoutNumber > 0 && turnoutNumber <= 4 else {
      return nil
    }
    return configuration.getUInt64(address: addressSW1ThrowEventId + (turnoutNumber - 1) * 33)
  }
  
  public func setTurnoutThrowEventId(turnoutNumber:Int, eventId:UInt64) {
    if turnoutNumber > 0 && turnoutNumber <= 4 {
      configuration.setUInt(address: addressSW1ThrowEventId + (turnoutNumber - 1) * 33, value: eventId)
    }
  }
  
  public func getTurnoutThrownEventId(turnoutNumber:Int) -> UInt64? {
    guard turnoutNumber > 0 && turnoutNumber <= 4 else {
      return nil
    }
    return configuration.getUInt64(address: addressSW1ThrownEventId + (turnoutNumber - 1) * 33)
  }
  
  public func setTurnoutThrownEventId(turnoutNumber:Int, eventId:UInt64) {
    if turnoutNumber > 0 && turnoutNumber <= 4 {
      configuration.setUInt(address: addressSW1ThrownEventId + (turnoutNumber - 1) * 33, value: eventId)
    }
  }

  public func getTurnoutCloseEventId(turnoutNumber:Int) -> UInt64? {
    guard turnoutNumber > 0 && turnoutNumber <= 4 else {
      return nil
    }
    return configuration.getUInt64(address: addressSW1CloseEventId + (turnoutNumber - 1) * 33)
  }
  
  public func setTurnoutCloseEventId(turnoutNumber:Int, eventId:UInt64) {
    if turnoutNumber > 0 && turnoutNumber <= 4 {
      configuration.setUInt(address: addressSW1CloseEventId + (turnoutNumber - 1) * 33, value: eventId)
    }
  }
  
  public func getTurnoutClosedEventId(turnoutNumber:Int) -> UInt64? {
    guard turnoutNumber > 0 && turnoutNumber <= 4 else {
      return nil
    }
    return configuration.getUInt64(address: addressSW1ClosedEventId + (turnoutNumber - 1) * 33)
  }
  
  public func setTurnoutClosedEventId(turnoutNumber:Int, eventId:UInt64) {
    if turnoutNumber > 0 && turnoutNumber <= 4 {
      configuration.setUInt(address: addressSW1ClosedEventId + (turnoutNumber - 1) * 33, value: eventId)
    }
  }

  public override func start() {
    super.start()
  }
  
  public override func stop() {
    super.stop()
  }

  // MARK: OpenLCBNetworkLayerDelegate Methods
  
  public override func openLCBMessageReceived(message: OpenLCBMessage) {
    
    super.openLCBMessageReceived(message: message)
    
    switch message.messageTypeIndicator {
     
    case .identifyProducer:
      
      if let eventId = message.eventId, let event = OpenLCBWellKnownEvent(rawValue: eventId) {
          
        switch event {
        case .nodeIsASwitchboardItem:
          networkLayer?.sendProducerIdentified(sourceNodeId: nodeId, wellKnownEvent: .nodeIsASwitchboardItem, validity: .valid)
        default:
          break
        }

      }

    case .identifyConsumer:

      if let eventId = message.eventId, let event = OpenLCBWellKnownEvent(rawValue: eventId) {
      
        switch event {
        case .identifyMyTrainsSwitchboardItems:
          networkLayer?.sendConsumerIdentified(sourceNodeId: nodeId, wellKnownEvent: .identifyMyTrainsSwitchboardItems, validity: .valid)
        default:
          break
        }
        
      }

    case .producerConsumerEventReport:
      
      if let event = OpenLCBWellKnownEvent(rawValue: message.eventId!) {
      
        switch event {
        case .identifyMyTrainsSwitchboardItems:
          
          var payload = layoutNodeId.bigEndianData
          payload.removeFirst(2)
          payload.append(contentsOf: itemType.rawValue.bigEndianData)
          
          networkLayer?.sendWellKnownEvent(sourceNodeId: nodeId, eventId: .nodeIsASwitchboardItem, payload: payload)

        default:
          break
        }
        
      }
      
    default:
      break
    }
    
  }

}
