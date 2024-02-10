//
//  SwitchboardItemNode.swift
//  MyTrains
//
//  Created by Paul Willmott on 11/01/2024.
//

import Foundation

public func initSpaceAddress(_ address: inout Int, _ size:Int, _ nextAddress: inout Int) {
  address = nextAddress
  nextAddress += size
}

public class SwitchboardItemNode : OpenLCBNodeVirtual {

  public init(nodeId:UInt64, layoutNodeId:UInt64 = 0) {

    configurationSize = 0
    initSpaceAddress(&addressPanelId, 8, &configurationSize)
    initSpaceAddress(&addressItemType, 2, &configurationSize)
    initSpaceAddress(&addressXPos, 2, &configurationSize)
    initSpaceAddress(&addressYPos, 2, &configurationSize)
    initSpaceAddress(&addressOrientation, 1, &configurationSize)
    initSpaceAddress(&addressGroupId, 8, &configurationSize)
    initSpaceAddress(&addressDirectionality, 1, &configurationSize)
    initSpaceAddress(&addressAllowShunt, 1, &configurationSize)
    initSpaceAddress(&addressElectrificationType, 1, &configurationSize)
    initSpaceAddress(&addressIsCriticalSection, 1, &configurationSize)
    initSpaceAddress(&addressIsHiddenSection, 1, &configurationSize)
    initSpaceAddress(&addressEnterDetectionZoneEventId, 8, &configurationSize)
    initSpaceAddress(&addressExitDetectionZoneEventId, 8, &configurationSize)
    initSpaceAddress(&addressEnterTranspondingZoneEventId, 8, &configurationSize)
    initSpaceAddress(&addressExitTranspondingZoneEventId, 8, &configurationSize)
    initSpaceAddress(&addressTrackFaultEventId, 8, &configurationSize)
    initSpaceAddress(&addressTrackFaultClearedEventId, 8, &configurationSize)
    initSpaceAddress(&addressLocationServicesEventId, 8, &configurationSize)
    initSpaceAddress(&addressTrackGradient, 4, &configurationSize)
    initSpaceAddress(&addressTrackGauge, 1, &configurationSize)
    initSpaceAddress(&addressDimensionA, 8, &configurationSize)
    initSpaceAddress(&addressDimensionB, 8, &configurationSize)
    initSpaceAddress(&addressDimensionC, 8, &configurationSize)
    initSpaceAddress(&addressDimensionD, 8, &configurationSize)
    initSpaceAddress(&addressDimensionE, 8, &configurationSize)
    initSpaceAddress(&addressDimensionF, 8, &configurationSize)
    initSpaceAddress(&addressDimensionG, 8, &configurationSize)
    initSpaceAddress(&addressDimensionH, 8, &configurationSize)
    initSpaceAddress(&addressSW1TurnoutMotorType, 1, &configurationSize)
    initSpaceAddress(&addressSW1ThrowEventId, 8, &configurationSize)
    initSpaceAddress(&addressSW1CloseEventId, 8, &configurationSize)
    initSpaceAddress(&addressSW1ThrownEventId, 8, &configurationSize)
    initSpaceAddress(&addressSW1ClosedEventId, 8, &configurationSize)
    initSpaceAddress(&addressSW2TurnoutMotorType, 1, &configurationSize)
    initSpaceAddress(&addressSW2ThrowEventId, 8, &configurationSize)
    initSpaceAddress(&addressSW2CloseEventId, 8, &configurationSize)
    initSpaceAddress(&addressSW2ThrownEventId, 8, &configurationSize)
    initSpaceAddress(&addressSW2ClosedEventId, 8, &configurationSize)
    initSpaceAddress(&addressSW3TurnoutMotorType, 1, &configurationSize)
    initSpaceAddress(&addressSW3ThrowEventId, 8, &configurationSize)
    initSpaceAddress(&addressSW3CloseEventId, 8, &configurationSize)
    initSpaceAddress(&addressSW3ThrownEventId, 8, &configurationSize)
    initSpaceAddress(&addressSW3ClosedEventId, 8, &configurationSize)
    initSpaceAddress(&addressSW4TurnoutMotorType, 1, &configurationSize)
    initSpaceAddress(&addressSW4ThrowEventId, 8, &configurationSize)
    initSpaceAddress(&addressSW4CloseEventId, 8, &configurationSize)
    initSpaceAddress(&addressSW4ThrownEventId, 8, &configurationSize)
    initSpaceAddress(&addressSW4ClosedEventId, 8, &configurationSize)
    initSpaceAddress(&addressSensorType, 1, &configurationSize)
    initSpaceAddress(&addressSensorPosition, 8, &configurationSize)
    initSpaceAddress(&addressSensorActivatedEventId, 8, &configurationSize)
    initSpaceAddress(&addressSensorActivateLatency, 8, &configurationSize)
    initSpaceAddress(&addressSensorDeactivatedEventId, 8, &configurationSize)
    initSpaceAddress(&addressSensorDeactivateLatency, 8, &configurationSize)
    initSpaceAddress(&addressSensorLocationServicesEventId, 8, &configurationSize)
    initSpaceAddress(&addressLink, 8, &configurationSize)
    initSpaceAddress(&addressSignalType, 2, &configurationSize)
    initSpaceAddress(&addressSignalRouteDirection, 1, &configurationSize)
    initSpaceAddress(&addressSignalPosition, 8, &configurationSize)
    initSpaceAddress(&addressSignalSetState0EventId, 8, &configurationSize)
    initSpaceAddress(&addressSignalSetState1EventId, 8, &configurationSize)
    initSpaceAddress(&addressSignalSetState2EventId, 8, &configurationSize)
    initSpaceAddress(&addressSignalSetState3EventId, 8, &configurationSize)
    initSpaceAddress(&addressSignalSetState4EventId, 8, &configurationSize)
    initSpaceAddress(&addressSignalSetState5EventId, 8, &configurationSize)
    initSpaceAddress(&addressSignalSetState6EventId, 8, &configurationSize)
    initSpaceAddress(&addressSignalSetState7EventId, 8, &configurationSize)
    initSpaceAddress(&addressSignalSetState8EventId, 8, &configurationSize)
    initSpaceAddress(&addressSignalSetState9EventId, 8, &configurationSize)
    initSpaceAddress(&addressSignalSetState10EventId, 8, &configurationSize)
    initSpaceAddress(&addressSignalSetState11EventId, 8, &configurationSize)
    initSpaceAddress(&addressSignalSetState12EventId, 8, &configurationSize)
    initSpaceAddress(&addressSignalSetState13EventId, 8, &configurationSize)
    initSpaceAddress(&addressSignalSetState14EventId, 8, &configurationSize)
    initSpaceAddress(&addressSignalSetState15EventId, 8, &configurationSize)
    initSpaceAddress(&addressSignalSetState16EventId, 8, &configurationSize)
    initSpaceAddress(&addressSignalSetState17EventId, 8, &configurationSize)
    initSpaceAddress(&addressSignalSetState18EventId, 8, &configurationSize)
    initSpaceAddress(&addressSignalSetState19EventId, 8, &configurationSize)
    initSpaceAddress(&addressSignalSetState20EventId, 8, &configurationSize)
    initSpaceAddress(&addressSignalSetState21EventId, 8, &configurationSize)
    initSpaceAddress(&addressSignalSetState22EventId, 8, &configurationSize)
    initSpaceAddress(&addressSignalSetState23EventId, 8, &configurationSize)
    initSpaceAddress(&addressSignalSetState24EventId, 8, &configurationSize)
    initSpaceAddress(&addressSignalSetState25EventId, 8, &configurationSize)
    initSpaceAddress(&addressSignalSetState26EventId, 8, &configurationSize)
    initSpaceAddress(&addressSignalSetState27EventId, 8, &configurationSize)
    initSpaceAddress(&addressSignalSetState28EventId, 8, &configurationSize)
    initSpaceAddress(&addressSignalSetState29EventId, 8, &configurationSize)
    initSpaceAddress(&addressSignalSetState30EventId, 8, &configurationSize)
    initSpaceAddress(&addressSignalSetState31EventId, 8, &configurationSize)

    configuration = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, defaultMemorySize: configurationSize, isReadOnly: false, description: "")
    
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

    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSensorType)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSensorPosition)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSensorActivatedEventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSensorActivateLatency)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSensorDeactivatedEventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSensorDeactivateLatency)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSensorLocationServicesEventId)

    configuration.registerUnitConversion(address: addressSensorPosition, unitConversionType: .actualLength8)
    configuration.registerUnitConversion(address: addressSensorActivateLatency, unitConversionType: .time8)
    configuration.registerUnitConversion(address: addressSensorDeactivateLatency, unitConversionType: .time8)

    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressLink)

    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSignalType)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSignalRouteDirection)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSignalPosition)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSignalSetState0EventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSignalSetState1EventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSignalSetState2EventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSignalSetState3EventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSignalSetState4EventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSignalSetState5EventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSignalSetState6EventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSignalSetState7EventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSignalSetState8EventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSignalSetState9EventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSignalSetState10EventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSignalSetState11EventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSignalSetState12EventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSignalSetState13EventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSignalSetState14EventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSignalSetState15EventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSignalSetState16EventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSignalSetState17EventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSignalSetState18EventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSignalSetState19EventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSignalSetState20EventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSignalSetState21EventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSignalSetState22EventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSignalSetState23EventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSignalSetState24EventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSignalSetState25EventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSignalSetState26EventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSignalSetState27EventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSignalSetState28EventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSignalSetState29EventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSignalSetState30EventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSignalSetState31EventId)

    if !memorySpacesInitialized {
      resetToFactoryDefaults()
    }

    cdiFilename = "MyTrains Switchboard Item"

  }

  internal func setupConfigurationAddresses() {
    configurationSize = 4
  }
  
  // MARK: Private Properties

  // Configuration varaible addresses
  
  internal var configurationSize : Int
  
  internal var addressPanelId                       = 0
  internal var addressItemType                      = 0
  internal var addressXPos                          = 0
  internal var addressYPos                          = 0
  internal var addressOrientation                   = 0
  internal var addressGroupId                       = 0
  internal var addressDirectionality                = 0
  internal var addressAllowShunt                    = 0
  internal var addressElectrificationType           = 0
  internal var addressIsCriticalSection             = 0
  internal var addressIsHiddenSection               = 0
  internal var addressEnterDetectionZoneEventId     = 0
  internal var addressExitDetectionZoneEventId      = 0
  internal var addressEnterTranspondingZoneEventId  = 0
  internal var addressExitTranspondingZoneEventId   = 0
  internal var addressTrackFaultEventId             = 0
  internal var addressTrackFaultClearedEventId      = 0
  internal var addressLocationServicesEventId       = 0
  internal var addressTrackGradient                 = 0
  internal var addressTrackGauge                    = 0
  internal var addressDimensionA                    = 0
  internal var addressDimensionB                    = 0
  internal var addressDimensionC                    = 0
  internal var addressDimensionD                    = 0
  internal var addressDimensionE                    = 0
  internal var addressDimensionF                    = 0
  internal var addressDimensionG                    = 0
  internal var addressDimensionH                    = 0
  internal var addressSW1TurnoutMotorType           = 0
  internal var addressSW1ThrowEventId               = 0
  internal var addressSW1CloseEventId               = 0
  internal var addressSW1ThrownEventId              = 0
  internal var addressSW1ClosedEventId              = 0
  internal var addressSW2TurnoutMotorType           = 0
  internal var addressSW2ThrowEventId               = 0
  internal var addressSW2CloseEventId               = 0
  internal var addressSW2ThrownEventId              = 0
  internal var addressSW2ClosedEventId              = 0
  internal var addressSW3TurnoutMotorType           = 0
  internal var addressSW3ThrowEventId               = 0
  internal var addressSW3CloseEventId               = 0
  internal var addressSW3ThrownEventId              = 0
  internal var addressSW3ClosedEventId              = 0
  internal var addressSW4TurnoutMotorType           = 0
  internal var addressSW4ThrowEventId               = 0
  internal var addressSW4CloseEventId               = 0
  internal var addressSW4ThrownEventId              = 0
  internal var addressSW4ClosedEventId              = 0
  internal var addressSensorType                    = 0
  internal var addressSensorPosition                = 0
  internal var addressSensorActivatedEventId        = 0
  internal var addressSensorActivateLatency         = 0
  internal var addressSensorDeactivatedEventId      = 0
  internal var addressSensorDeactivateLatency       = 0
  internal var addressSensorLocationServicesEventId = 0
  internal var addressLink                          = 0
  internal var addressSignalType                    = 0
  internal var addressSignalRouteDirection          = 0
  internal var addressSignalPosition                = 0
  internal var addressSignalSetState0EventId        = 0
  internal var addressSignalSetState1EventId        = 0
  internal var addressSignalSetState2EventId        = 0
  internal var addressSignalSetState3EventId        = 0
  internal var addressSignalSetState4EventId        = 0
  internal var addressSignalSetState5EventId        = 0
  internal var addressSignalSetState6EventId        = 0
  internal var addressSignalSetState7EventId        = 0
  internal var addressSignalSetState8EventId        = 0
  internal var addressSignalSetState9EventId        = 0
  internal var addressSignalSetState10EventId       = 0
  internal var addressSignalSetState11EventId       = 0
  internal var addressSignalSetState12EventId       = 0
  internal var addressSignalSetState13EventId       = 0
  internal var addressSignalSetState14EventId       = 0
  internal var addressSignalSetState15EventId       = 0
  internal var addressSignalSetState16EventId       = 0
  internal var addressSignalSetState17EventId       = 0
  internal var addressSignalSetState18EventId       = 0
  internal var addressSignalSetState19EventId       = 0
  internal var addressSignalSetState20EventId       = 0
  internal var addressSignalSetState21EventId       = 0
  internal var addressSignalSetState22EventId       = 0
  internal var addressSignalSetState23EventId       = 0
  internal var addressSignalSetState24EventId       = 0
  internal var addressSignalSetState25EventId       = 0
  internal var addressSignalSetState26EventId       = 0
  internal var addressSignalSetState27EventId       = 0
  internal var addressSignalSetState28EventId       = 0
  internal var addressSignalSetState29EventId       = 0
  internal var addressSignalSetState30EventId       = 0
  internal var addressSignalSetState31EventId       = 0

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

  public var sensorType : SensorType {
    get {
      return SensorType(rawValue: configuration.getUInt8(address: addressSensorType)!)!
    }
    set(value) {
      configuration.setUInt(address: addressTrackGradient, value: value.rawValue)
    }
  }

  public var sensorPosition : Double {
    get {
      return configuration.getDouble(address: addressSensorPosition)!
    }
    set(value) {
      configuration.setDouble(address: addressSensorPosition, value: value)
    }
  }

  public var sensorActivatedEventId : UInt64 {
    get {
      return configuration.getUInt64(address: addressSensorActivatedEventId)!
    }
    set(value) {
      configuration.setUInt(address: addressSensorActivatedEventId, value: value)
    }
  }

  public var sensorActivateLatency : Double {
    get {
      return configuration.getDouble(address: addressSensorActivateLatency)!
    }
    set(value) {
      configuration.setDouble(address: addressSensorActivateLatency, value: value)
    }
  }

  public var sensorDeactivatedEventId : UInt64 {
    get {
      return configuration.getUInt64(address: addressSensorDeactivatedEventId)!
    }
    set(value) {
      configuration.setUInt(address: addressSensorDeactivatedEventId, value: value)
    }
  }

  public var sensorDectivateLatency : Double {
    get {
      return configuration.getDouble(address: addressSensorDeactivateLatency)!
    }
    set(value) {
      configuration.setDouble(address: addressSensorDeactivateLatency, value: value)
    }
  }

  public var sensorLocationServicesEventId : UInt64 {
    get {
      return configuration.getUInt64(address: addressSensorLocationServicesEventId)!
    }
    set(value) {
      configuration.setUInt(address: addressSensorDeactivatedEventId, value: value)
    }
  }

  public var linkId : UInt64 {
    get {
      return configuration.getUInt64(address: addressLink)!
    }
    set(value) {
      configuration.setUInt(address: addressLink, value: value)
    }
  }

  public var signalType : SignalType {
    get {
      return SignalType(rawValue: configuration.getUInt16(address: addressSignalType)!)!
    }
    set(value) {
      configuration.setUInt(address: addressSignalType, value: value.rawValue)
    }
  }

  // MARK: Private Methods

  override public func variableChanged(space:OpenLCBMemorySpace, address:Int) {
    
    guard let spaceId = space.standardSpace else {
      return
    }
    
    switch spaceId {
    case .configuration:
      switch address {
      case addressItemType:
        sendNodeIsASwitchboardItemEvent()
      default:
        break
      }
    case .acdiUser:
      switch address {
      case addressACDIUserNodeName:
        sendNodeIsASwitchboardItemEvent()
      default:
        break
      }
    default:
      break
    }
    
  }

  internal override func resetToFactoryDefaults() {

    super.resetToFactoryDefaults()
 
    configuration.zeroMemory()
    
    xPos = 1
    yPos = 1
    
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
    
    var sub = ""
    
    if itemType.numberOfDimensionsRequired > 0 {
      
      for route in 1 ... itemType.numberOfDimensionsRequired {
        sub += "<float size='8'>\n"
        if itemType.isBlock {
          sub += "<name>Length of Block (\(CDI.ACTUAL_LENGTH_UNITS))</name>\n"
        }
        else {
          sub += "<name>Length of Route #\(route) (\(CDI.ACTUAL_LENGTH_UNITS))</name>\n"
        }
        sub += "<min>0.0</min>\n"
        sub += "</float>\n\n"
      }
      
    }
    
    if itemType.numberOfDimensionsRequired < 8 {
      for route in itemType.numberOfDimensionsRequired + 1 ... 8 {
        sub += "<group offset='8'/>\n"
      }
    }
    
    result = result.replacingOccurrences(of: CDI.ROUTE_DIMENSION, with: sub)

    sub = ""
    
    if itemType.numberOfTurnoutSwitches > 0 {
 
      sub += "<group replication='\(itemType.numberOfTurnoutSwitches)'>\n"
      sub += "  <name>Switch Configuration</name>\n"
      sub += "  <repname>Switch #</repname>\n"

      sub += "<int size='1'>\n"
      sub += "  <name>Turnout Motor Type</name>\n"
      sub += "  \(CDI.TURNOUT_MOTOR_TYPE)"
      sub += "</int>\n"

      sub += "<eventid>\n"
      sub += "  <name>Throw Switch Event ID</name>\n"
      sub += "</eventid>\n"

      sub += "<eventid>"
      sub += "  <name>Close Switch Event ID</name>\n"
      sub += "</eventid>\n"

      sub += "<eventid>\n"
      sub += "  <name>Switch Thrown Confirmation Event ID</name>\n"
      sub += "</eventid>\n"

      sub += "<eventid>\n"
      sub += "  <name>Switch Closed Confirmation Event ID</name>\n"
      sub += "</eventid>\n"

      sub += "</group>\n"

    }
    
    if itemType.numberOfTurnoutSwitches < 4 {
      for route in itemType.numberOfTurnoutSwitches + 1 ... 4 {
        sub += "<group offset='33'/>\n"
      }
    }
    
    result = result.replacingOccurrences(of: CDI.TURNOUT_SWITCHES, with: sub)

    sub = ""
    
    if itemType == .sensor {
      
      sub += "<group>\n"
      sub += "  <name>Sensor Configuration</name>\n"

      sub += "<int size='1'>\n"
      sub += "  <name>Sensor Type</name>\n"
      sub += "  \(CDI.SENSOR_TYPE)"
      sub += "</int>\n"

      sub += "<float size='8'>\n"
      sub += "<name>Position of Sensor (\(CDI.ACTUAL_LENGTH_UNITS))</name>\n"
      sub += "</float>\n\n"

      sub += "<eventid>\n"
      sub += "  <name>Sensor Activated Event ID</name>\n"
      sub += "</eventid>\n"

      sub += "<float size='8'>\n"
      sub += "<name>Sensor Activate Latency (\(CDI.TIME_UNITS))</name>\n"
      sub += "</float>\n\n"

      sub += "<eventid>\n"
      sub += "  <name>Sensor Deactivated Event ID</name>\n"
      sub += "</eventid>\n"

      sub += "<float size='8'>\n"
      sub += "<name>Sensor Deactivate Latency (\(CDI.TIME_UNITS))</name>\n"
      sub += "</float>\n\n"

      sub += "<eventid>\n"
      sub += "  <name>Sensor Location Services Event ID</name>\n"
      sub += "</eventid>\n"

      sub += "</group>\n"

    }
    else {
      sub += "<group offset='49'/>\n"
    }

    result = result.replacingOccurrences(of: CDI.SPECIAL_SENSOR, with: sub)
    
    sub = ""
    
    if itemType == .link {

      sub += "<eventid>\n"
      sub += "  <name>Link ID</name>\n"
      sub += "  \(CDI.SWITCHBOARD_LINKS)"
      sub += "</eventid>\n"

    }
    else {
      sub += "<group offset='8'/>\n"
    }

    result = result.replacingOccurrences(of: CDI.LINK, with: sub)
    
    sub = ""
    
    if let appNode {
      result = appNode.insertLinkMap(cdi: result, layoutId: layoutNodeId, excludeLinkId: nodeId)
    }
    
    if itemType == .signal {
      
      sub += "<group>\n"
      sub += "  <name>Signal Configuration</name>\n"

      sub += "<int size='2'>\n"
      sub += "  <name>Signal Type</name>\n"
      sub += "  \(CDI.SIGNAL_TYPE)"
      sub += "</int>\n"

      sub += "<int size='1'>\n"
      sub += "  <name>Route Direction</name>\n"
      sub += "  \(CDI.ROUTE_DIRECTION)"
      sub += "</int>\n"

      sub += "<float size='8'>\n"
      sub += "<name>Position of Signal (\(CDI.ACTUAL_LENGTH_UNITS))</name>\n"
      sub += "</float>\n\n"

      if signalType.numberOfStates > 0 {
        for index in 1 ... signalType.numberOfStates {
          sub += "<eventid>\n"
          sub += "  <name>Set State #\(index) Event ID</name>\n"
          sub += "</eventid>\n"
        }
      }
      
      if signalType.numberOfStates < 32 {
        let filler = 32 - signalType.numberOfStates
        sub += "<group offset='\(filler * 8)'/>\n"
      }
      
      sub += "</group>\n"

    }
    else {
      sub += "<group offset='267'/>\n"
    }

    result = result.replacingOccurrences(of: CDI.SIGNAL, with: sub)

    result = TurnoutMotorType.insertMap(cdi: result)
    
    result = SensorType.insertMap(cdi: result)
    
    result = RouteDirection.insertMap(cdi: result)
    
    result = SignalType.insertMap(cdi: result, countryCode: layoutNode!.countryCode)
    
    result = result.replacingOccurrences(of: CDI.ACTUAL_LENGTH_UNITS, with: appNode!.unitsActualLength.symbol)
    
    result = result.replacingOccurrences(of: CDI.TIME_UNITS, with: appNode!.unitsTime.symbol)

    return result
    
  }

  internal override func resetReboot() {
    
    super.resetReboot()
    
    networkLayer?.sendIdentifyProducer(sourceNodeId: nodeId, event: .identifyMyTrainsSwitchboardItems)
    
    networkLayer?.sendIdentifyConsumer(sourceNodeId: nodeId, event: .nodeIsASwitchboardItem)
    
    sendNodeIsASwitchboardItemEvent()
    
  }
  
  internal func sendNodeIsASwitchboardItemEvent() {
    
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
