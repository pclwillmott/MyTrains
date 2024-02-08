//
//  SwitchboardItemNode.swift
//  MyTrains
//
//  Created by Paul Willmott on 11/01/2024.
//

import Foundation

public class SwitchboardItemNode : OpenLCBNodeVirtual {

  public init(nodeId:UInt64, layoutNodeId:UInt64 = 0) {

    configuration = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, defaultMemorySize: 155, isReadOnly: false, description: "")
    
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
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressTrackPart)
    
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
  internal let addressTrackPart                    : Int = 88 // 90
  internal let addressTrackGauge                   : Int = 90 // 91
  internal let addressDimensionA                   : Int = 91 // 99
  internal let addressDimensionB                   : Int = 99 // 107
  internal let addressDimensionC                   : Int = 107 // 115
  internal let addressDimensionD                   : Int = 115 // 123
  internal let addressDimensionE                   : Int = 123 // 131
  internal let addressDimensionF                   : Int = 131 // 139
  internal let addressDimensionG                   : Int = 139 // 147
  internal let addressDimensionH                   : Int = 147 // 155

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

  public var trackPart : TrackPart {
    get {
      return TrackPart(rawValue: configuration.getUInt16(address: addressTrackPart)!)!
    }
    set(value) {
      configuration.setUInt(address: addressTrackPart, value: value.rawValue)
      initCDI()
    }
  }

  public var dimensionA : Float32 {
    get {
      return configuration.getFloat(address: addressDimensionA)!
    }
    set(value) {
      configuration.setFloat(address: addressDimensionA, value: value)
    }
  }

  public var dimensionB : Float32 {
    get {
      return configuration.getFloat(address: addressDimensionB)!
    }
    set(value) {
      configuration.setFloat(address: addressDimensionB, value: value)
    }
  }

  public var dimensionC : Float32 {
    get {
      return configuration.getFloat(address: addressDimensionC)!
    }
    set(value) {
      configuration.setFloat(address: addressDimensionC, value: value)
    }
  }

  public var dimensionD : Float32 {
    get {
      return configuration.getFloat(address: addressDimensionD)!
    }
    set(value) {
      configuration.setFloat(address: addressDimensionD, value: value)
    }
  }

  public var dimensionE : Float32 {
    get {
      return configuration.getFloat(address: addressDimensionE)!
    }
    set(value) {
      configuration.setFloat(address: addressDimensionE, value: value)
    }
  }

  public var dimensionF : Float32 {
    get {
      return configuration.getFloat(address: addressDimensionF)!
    }
    set(value) {
      configuration.setFloat(address: addressDimensionF, value: value)
    }
  }

  public var dimensionG : Float32 {
    get {
      return configuration.getFloat(address: addressDimensionG)!
    }
    set(value) {
      configuration.setFloat(address: addressDimensionG, value: value)
    }
  }

  public var dimensionH : Float32 {
    get {
      return configuration.getFloat(address: addressDimensionH)!
    }
    set(value) {
      configuration.setFloat(address: addressDimensionH, value: value)
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
    
    trackPart = .custom
    
    dimensionA = 0.0
    dimensionB = 0.0
    dimensionC = 0.0
    dimensionD = 0.0
    dimensionE = 0.0
    dimensionF = 0.0
    dimensionG = 0.0
    dimensionH = 0.0

    saveMemorySpaces()

  }
  
  override internal func customizeDynamicCDI(cdi:String) -> String {
 
    var result = SwitchBoardItemType.insertMap(cdi: cdi)
    result = Orientation.insertMap(cdi: result)
    result = BlockDirection.insertMap(cdi: result)
    result = YesNo.insertMap(cdi: result)
    result = TrackElectrificationType.insertMap(cdi: result)
    result = TrackPart.insertMap(cdi: result, itemType: itemType, layout: layoutNode)
    result = TrackGauge.insertMap(cdi: result, layout: layoutNode)
    result = TurnoutMotorType.insertMap(cdi: result)

    if let app = networkLayer?.myTrainsNode {
      result = app.insertPanelMap(cdi: result, layoutId: layoutNodeId)
      result = app.insertGroupMap(cdi: result, layoutId: layoutNodeId)
    }

    return result
    
  }

  public override func variableChanged(space: OpenLCBMemorySpace, address: Int) {
    
    if space.space == configuration.space {
      
      switch address {
      case addressItemType:
        initCDI()
      default:
        break
      }

    }

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

        case .rebuildCDI:
          
          if message.sourceNodeId! == layoutNodeId {
            initCDI()
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
