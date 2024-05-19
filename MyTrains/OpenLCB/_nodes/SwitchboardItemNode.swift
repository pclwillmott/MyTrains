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

    super.init(nodeId: nodeId)
    
    var configurationSize = 0
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

    initSpaceAddress(&addressSpeedConstraintDPType0, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDPValue0, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDPType1, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDPValue1, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDPType2, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDPValue2, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDPType3, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDPValue3, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDPType4, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDPValue4, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDPType5, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDPValue5, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDPType6, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDPValue6, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDPType7, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDPValue7, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDPType8, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDPValue8, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDPType9, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDPValue9, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDPType10, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDPValue10, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDPType11, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDPValue11, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDPType12, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDPValue12, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDPType13, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDPValue13, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDPType14, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDPValue14, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDPType15, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDPValue15, 2, &configurationSize)

    initSpaceAddress(&addressSpeedConstraintDNType0, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDNValue0, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDNType1, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDNValue1, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDNType2, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDNValue2, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDNType3, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDNValue3, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDNType4, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDNValue4, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDNType5, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDNValue5, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDNType6, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDNValue6, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDNType7, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDNValue7, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDNType8, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDNValue8, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDNType9, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDNValue9, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDNType10, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDNValue10, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDNType11, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDNValue11, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDNType12, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDNValue12, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDNType13, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDNValue13, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDNType14, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDNValue14, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDNType15, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintDNValue15, 2, &configurationSize)

    configuration = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, defaultMemorySize: configurationSize, isReadOnly: false, description: "")
    
    if let configuration {
      
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
      
      configuration.registerUnitConversion(address: addressSensorPosition, unitConversionType: .actualDistance8)
      configuration.registerUnitConversion(address: addressSensorActivateLatency, unitConversionType: .time8)
      configuration.registerUnitConversion(address: addressSensorDeactivateLatency, unitConversionType: .time8)
      
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressLink)
      
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSignalType)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSignalRouteDirection)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSignalPosition)
      
      configuration.registerUnitConversion(address: addressSignalPosition, unitConversionType: .actualDistance8)

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
      
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDPType0)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDPValue0)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDPType1)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDPValue1)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDPType2)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDPValue2)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDPType3)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDPValue3)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDPType4)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDPValue4)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDPType5)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDPValue5)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDPType6)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDPValue6)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDPType7)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDPValue7)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDPType8)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDPValue8)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDPType9)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDPValue9)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDPType10)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDPValue10)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDPType11)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDPValue11)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDPType12)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDPValue12)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDPType13)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDPValue13)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDPType14)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDPValue14)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDPType15)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDPValue15)
      
      configuration.registerUnitConversion(address: addressSpeedConstraintDPValue0, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintDPValue1, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintDPValue2, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintDPValue3, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintDPValue4, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintDPValue5, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintDPValue6, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintDPValue7, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintDPValue8, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintDPValue9, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintDPValue10, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintDPValue11, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintDPValue12, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintDPValue13, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintDPValue14, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintDPValue15, unitConversionType: .scaleSpeed2)
      
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDNType0)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDNValue0)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDNType1)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDNValue1)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDNType2)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDNValue2)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDNType3)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDNValue3)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDNType4)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDNValue4)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDNType5)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDNValue5)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDNType6)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDNValue6)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDNType7)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDNValue7)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDNType8)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDNValue8)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDNType9)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDNValue9)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDNType10)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDNValue10)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDNType11)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDNValue11)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDNType12)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDNValue12)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDNType13)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDNValue13)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDNType14)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDNValue14)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDNType15)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintDNValue15)
      
      configuration.registerUnitConversion(address: addressSpeedConstraintDNValue0, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintDNValue1, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintDNValue2, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintDNValue3, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintDNValue4, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintDNValue5, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintDNValue6, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintDNValue7, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintDNValue8, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintDNValue9, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintDNValue10, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintDNValue11, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintDNValue12, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintDNValue13, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintDNValue14, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintDNValue15, unitConversionType: .scaleSpeed2)
      
      userConfigEventConsumedAddresses = [
        
        addressEnterDetectionZoneEventId,
        addressExitDetectionZoneEventId,
        addressEnterTranspondingZoneEventId,
        addressExitTranspondingZoneEventId,
        addressTrackFaultEventId,
        addressTrackFaultClearedEventId,
        addressLocationServicesEventId,
        
        addressSW1ThrownEventId,
        addressSW1ClosedEventId,
        addressSW2ThrownEventId,
        addressSW2ClosedEventId,
        addressSW3ThrownEventId,
        addressSW3ClosedEventId,
        addressSW4ThrownEventId,
        addressSW4ClosedEventId,
        
        addressSensorActivatedEventId,
        addressSensorDeactivatedEventId,
        addressSensorLocationServicesEventId,
        
      ]
      
      userConfigEventProducedAddresses = [
        
        addressSW1ThrowEventId,
        addressSW1CloseEventId,
        addressSW2ThrowEventId,
        addressSW2CloseEventId,
        addressSW3ThrowEventId,
        addressSW3CloseEventId,
        addressSW4ThrowEventId,
        addressSW4CloseEventId,
        
        addressSignalSetState0EventId,
        addressSignalSetState1EventId,
        addressSignalSetState2EventId,
        addressSignalSetState3EventId,
        addressSignalSetState4EventId,
        addressSignalSetState5EventId,
        addressSignalSetState6EventId,
        addressSignalSetState7EventId,
        addressSignalSetState8EventId,
        addressSignalSetState9EventId,
        addressSignalSetState10EventId,
        addressSignalSetState11EventId,
        addressSignalSetState12EventId,
        addressSignalSetState13EventId,
        addressSignalSetState14EventId,
        addressSignalSetState15EventId,
        addressSignalSetState16EventId,
        addressSignalSetState17EventId,
        addressSignalSetState18EventId,
        addressSignalSetState19EventId,
        addressSignalSetState20EventId,
        addressSignalSetState21EventId,
        addressSignalSetState22EventId,
        addressSignalSetState23EventId,
        addressSignalSetState24EventId,
        addressSignalSetState25EventId,
        addressSignalSetState26EventId,
        addressSignalSetState27EventId,
        addressSignalSetState28EventId,
        addressSignalSetState29EventId,
        addressSignalSetState30EventId,
        addressSignalSetState31EventId,
        
      ]
      
      if !memorySpacesInitialized {
        resetToFactoryDefaults()
      }
      
      cdiFilename = "MyTrains Switchboard Item"
      
    }
    
    #if DEBUG
    addInit()
    #endif
    
  }
  
  #if DEBUG
  deinit {
    addDeinit()
  }
  #endif

  // MARK: Private Properties

  // Configuration varaible addresses
  
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
  internal var addressSpeedConstraintDPType0        = 0
  internal var addressSpeedConstraintDPValue0       = 0
  internal var addressSpeedConstraintDPType1        = 0
  internal var addressSpeedConstraintDPValue1       = 0
  internal var addressSpeedConstraintDPType2        = 0
  internal var addressSpeedConstraintDPValue2       = 0
  internal var addressSpeedConstraintDPType3        = 0
  internal var addressSpeedConstraintDPValue3       = 0
  internal var addressSpeedConstraintDPType4        = 0
  internal var addressSpeedConstraintDPValue4       = 0
  internal var addressSpeedConstraintDPType5        = 0
  internal var addressSpeedConstraintDPValue5       = 0
  internal var addressSpeedConstraintDPType6        = 0
  internal var addressSpeedConstraintDPValue6       = 0
  internal var addressSpeedConstraintDPType7        = 0
  internal var addressSpeedConstraintDPValue7       = 0
  internal var addressSpeedConstraintDPType8        = 0
  internal var addressSpeedConstraintDPValue8       = 0
  internal var addressSpeedConstraintDPType9        = 0
  internal var addressSpeedConstraintDPValue9       = 0
  internal var addressSpeedConstraintDPType10       = 0
  internal var addressSpeedConstraintDPValue10      = 0
  internal var addressSpeedConstraintDPType11       = 0
  internal var addressSpeedConstraintDPValue11      = 0
  internal var addressSpeedConstraintDPType12       = 0
  internal var addressSpeedConstraintDPValue12      = 0
  internal var addressSpeedConstraintDPType13       = 0
  internal var addressSpeedConstraintDPValue13      = 0
  internal var addressSpeedConstraintDPType14       = 0
  internal var addressSpeedConstraintDPValue14      = 0
  internal var addressSpeedConstraintDPType15       = 0
  internal var addressSpeedConstraintDPValue15      = 0
  internal var addressSpeedConstraintDNType0        = 0
  internal var addressSpeedConstraintDNValue0       = 0
  internal var addressSpeedConstraintDNType1        = 0
  internal var addressSpeedConstraintDNValue1       = 0
  internal var addressSpeedConstraintDNType2        = 0
  internal var addressSpeedConstraintDNValue2       = 0
  internal var addressSpeedConstraintDNType3        = 0
  internal var addressSpeedConstraintDNValue3       = 0
  internal var addressSpeedConstraintDNType4        = 0
  internal var addressSpeedConstraintDNValue4       = 0
  internal var addressSpeedConstraintDNType5        = 0
  internal var addressSpeedConstraintDNValue5       = 0
  internal var addressSpeedConstraintDNType6        = 0
  internal var addressSpeedConstraintDNValue6       = 0
  internal var addressSpeedConstraintDNType7        = 0
  internal var addressSpeedConstraintDNValue7       = 0
  internal var addressSpeedConstraintDNType8        = 0
  internal var addressSpeedConstraintDNValue8       = 0
  internal var addressSpeedConstraintDNType9        = 0
  internal var addressSpeedConstraintDNValue9       = 0
  internal var addressSpeedConstraintDNType10       = 0
  internal var addressSpeedConstraintDNValue10      = 0
  internal var addressSpeedConstraintDNType11       = 0
  internal var addressSpeedConstraintDNValue11      = 0
  internal var addressSpeedConstraintDNType12       = 0
  internal var addressSpeedConstraintDNValue12      = 0
  internal var addressSpeedConstraintDNType13       = 0
  internal var addressSpeedConstraintDNValue13      = 0
  internal var addressSpeedConstraintDNType14       = 0
  internal var addressSpeedConstraintDNValue14      = 0
  internal var addressSpeedConstraintDNType15       = 0
  internal var addressSpeedConstraintDNValue15      = 0

  private var layoutNode : LayoutNode? {
    return appDelegate.networkLayer!.virtualNodeLookup[layoutNodeId] as? LayoutNode
  }

  // MARK: Public Properties
  
  public override var visibility : OpenLCBNodeVisibility {
    return itemType.visibility
  }

  public var panelId : UInt64 {
    get {
      return configuration!.getUInt64(address: addressPanelId)!
    }
    set(value) {
      configuration!.setUInt(address: addressPanelId, value: value)
    }
  }

  public var itemType : SwitchBoardItemType {
    get {
      return SwitchBoardItemType(rawValue: configuration!.getUInt16(address: addressItemType)!)!
    }
    set(value) {
      configuration!.setUInt(address: addressItemType, value: value.rawValue)
    }
  }

  public var xPos : UInt16 {
    get {
      return configuration!.getUInt16(address: addressXPos)!
    }
    set(value) {
      configuration!.setUInt(address: addressXPos, value: value)
    }
  }

  public var yPos : UInt16 {
    get {
      return configuration!.getUInt16(address: addressYPos)!
    }
    set(value) {
      configuration!.setUInt(address: addressYPos, value: value)
    }
  }

  public var location : SwitchBoardLocation {
    get {
      return (x: Int(xPos), y: Int(yPos))
    }
    set(value) {
      xPos = UInt16(exactly: value.x)!
      yPos = UInt16(exactly: value.y)!
    }
  }
  
  public var orientation : Orientation {
    get {
      return Orientation(rawValue: configuration!.getUInt8(address: addressOrientation)!)!
    }
    set(value) {
      configuration!.setUInt(address: addressOrientation, value: value.rawValue)
    }
  }

  public var groupId : UInt64 {
    get {
      return configuration!.getUInt64(address: addressGroupId)!
    }
    set(value) {
      configuration!.setUInt(address: addressGroupId, value: value)
    }
  }

  public var directionality : BlockDirection {
    get {
      return BlockDirection(rawValue: configuration!.getUInt8(address: addressDirectionality)!)!
    }
    set(value) {
      configuration!.setUInt(address: addressDirectionality, value: value.rawValue)
    }
  }

  public var isReverseShuntAllowed : Bool {
    get {
      return configuration!.getUInt8(address: addressAllowShunt)! == 1
    }
    set(value) {
      configuration!.setUInt(address: addressAllowShunt, value: value ? UInt8(1) : UInt8(0))
    }
  }

  public var trackElectrificationType : TrackElectrificationType {
    get {
      return TrackElectrificationType(rawValue: configuration!.getUInt8(address: addressElectrificationType)!)!
    }
    set(value) {
      configuration!.setUInt(address: addressElectrificationType, value: value.rawValue)
    }
  }

  public var isCriticalSection : Bool {
    get {
      return configuration!.getUInt8(address: addressIsCriticalSection)! == 1
    }
    set(value) {
      configuration!.setUInt(address: addressIsCriticalSection, value: value ? UInt8(1) : UInt8(0))
    }
  }

  public var isHiddenSection : Bool {
    get {
      return configuration!.getUInt8(address: addressIsHiddenSection)! == 1
    }
    set(value) {
      configuration!.setUInt(address: addressIsHiddenSection, value: value ? UInt8(1) : UInt8(0))
    }
  }

  public var enterDetectionZoneEventId : UInt64 {
    get {
      return configuration!.getUInt64(address: addressEnterDetectionZoneEventId)!
    }
    set(value) {
      configuration!.setUInt(address: addressEnterDetectionZoneEventId, value: value)
    }
  }

  public var exitDetectionZoneEventId : UInt64 {
    get {
      return configuration!.getUInt64(address: addressExitDetectionZoneEventId)!
    }
    set(value) {
      configuration!.setUInt(address: addressExitDetectionZoneEventId, value: value)
    }
  }

  public var enterTranspondingZoneEventId : UInt64 {
    get {
      return configuration!.getUInt64(address: addressEnterTranspondingZoneEventId)!
    }
    set(value) {
      configuration!.setUInt(address: addressEnterTranspondingZoneEventId, value: value)
    }
  }

  public var exitTranspondingZoneEventId : UInt64 {
    get {
      return configuration!.getUInt64(address: addressExitTranspondingZoneEventId)!
    }
    set(value) {
      configuration!.setUInt(address: addressExitTranspondingZoneEventId, value: value)
    }
  }

  public var trackFaultEventId : UInt64 {
    get {
      return configuration!.getUInt64(address: addressTrackFaultEventId)!
    }
    set(value) {
      configuration!.setUInt(address: addressTrackFaultEventId, value: value)
    }
  }

  public var trackFaultClearedEventId : UInt64 {
    get {
      return configuration!.getUInt64(address: addressTrackFaultClearedEventId)!
    }
    set(value) {
      configuration!.setUInt(address: addressTrackFaultClearedEventId, value: value)
    }
  }

  public var locationServicesEventId : UInt64 {
    get {
      return configuration!.getUInt64(address: addressLocationServicesEventId)!
    }
    set(value) {
      configuration!.setUInt(address: addressLocationServicesEventId, value: value)
    }
  }

  public var trackGauge : TrackGauge {
    get {
      return TrackGauge(rawValue: configuration!.getUInt8(address: addressTrackGauge)!)!
    }
    set(value) {
      configuration!.setUInt(address: addressTrackGauge, value: value.rawValue)
    }
  }

  public var trackGradient : Float32 {
    get {
      return configuration!.getFloat(address: addressTrackGradient)!
    }
    set(value) {
      configuration!.setFloat(address: addressTrackGradient, value: value)
    }
  }

  public var sensorType : SensorType {
    get {
      return SensorType(rawValue: configuration!.getUInt8(address: addressSensorType)!)!
    }
    set(value) {
      configuration!.setUInt(address: addressSensorType, value: value.rawValue)
    }
  }

  public var sensorPosition : Double {
    get {
      return configuration!.getDouble(address: addressSensorPosition)!
    }
    set(value) {
      configuration!.setDouble(address: addressSensorPosition, value: value)
    }
  }

  public var sensorActivatedEventId : UInt64 {
    get {
      return configuration!.getUInt64(address: addressSensorActivatedEventId)!
    }
    set(value) {
      configuration!.setUInt(address: addressSensorActivatedEventId, value: value)
    }
  }

  public var sensorActivateLatency : Double {
    get {
      return configuration!.getDouble(address: addressSensorActivateLatency)!
    }
    set(value) {
      configuration!.setDouble(address: addressSensorActivateLatency, value: value)
    }
  }

  public var sensorDeactivatedEventId : UInt64 {
    get {
      return configuration!.getUInt64(address: addressSensorDeactivatedEventId)!
    }
    set(value) {
      configuration!.setUInt(address: addressSensorDeactivatedEventId, value: value)
    }
  }

  public var sensorDeactivateLatency : Double {
    get {
      return configuration!.getDouble(address: addressSensorDeactivateLatency)!
    }
    set(value) {
      configuration!.setDouble(address: addressSensorDeactivateLatency, value: value)
    }
  }

  public var sensorLocationServicesEventId : UInt64 {
    get {
      return configuration!.getUInt64(address: addressSensorLocationServicesEventId)!
    }
    set(value) {
      configuration!.setUInt(address: addressSensorLocationServicesEventId, value: value)
    }
  }

  public var linkId : UInt64 {
    get {
      return configuration!.getUInt64(address: addressLink)!
    }
    set(value) {
      configuration!.setUInt(address: addressLink, value: value)
    }
  }

  public var signalType : SignalType {
    get {
      return SignalType(rawValue: configuration!.getUInt16(address: addressSignalType)!)!
    }
    set(value) {
      configuration!.setUInt(address: addressSignalType, value: value.rawValue)
    }
  }

  public var signalRouteDirection : RouteDirection {
    get {
      return RouteDirection(rawValue: configuration!.getUInt8(address: addressSignalRouteDirection)!)!
    }
    set(value) {
      configuration!.setUInt(address: addressSignalRouteDirection, value: value.rawValue)
    }
  }

  public var signalPosition : Double {
    get {
      return configuration!.getDouble(address: addressSignalPosition)!
    }
    set(value) {
      configuration!.setDouble(address: addressSignalPosition, value: value)
    }
  }

  public var nodeLinks = [SWBNodeLink](repeating: (nil, -1, []), count: 8)

  public var isEliminated : Bool = false

  public var isTurnout : Bool {
    let turnouts : Set<SwitchBoardItemType> = [
      .cross,
      .rightCurvedTurnout,
      .leftCurvedTurnout,
      .turnout3Way,
      .yTurnout,
      .diagonalCross,
      .turnoutLeft,
      .turnoutRight,
      .singleSlip,
      .doubleSlip,
    ]
    return turnouts.contains(itemType)
  }
  
  public var isScenic : Bool {
    let scenics : Set<SwitchBoardItemType> = [
      .platform,
    ]
    return scenics.contains(itemType)
  }

  public var isSensor : Bool {
    get {
      return itemType == .sensor
    }
  }
  
  public var isBlock : Bool {
    get {
      return itemType == .block
    }
  }
  
  public var isLink : Bool {
    get {
      return itemType == .link
    }
  }
  
  public var isOccupied : Bool = false {
    didSet {
   //   layout?.needsDisplay()
    }
  }
  
  public var isTrackFault : Bool = false {
    didSet {
   //   layout?.needsDisplay()
    }
  }
  
  public var isTrack : Bool {
    get {
      let track : Set<SwitchBoardItemType> = [
        .curve,
        .sensor,
        .longCurve,
        .straight,
        .buffer,
      ]
      return track.contains(itemType)
    }
  }

  public func exitPoint(entryPoint:Int) -> [SWBNodeLink] {
    var result : [SWBNodeLink] = []
    for connection in itemType.connections {
      let to = (connection.to + Int(orientation.rawValue)) % 8
      let from = (connection.from + Int(orientation.rawValue)) % 8
      if entryPoint == to {
        result.append(nodeLinks[from])
      }
      else if entryPoint == from {
        result.append(nodeLinks[to])
      }
    }
    return result
  }
  
  public var numberOfConnections : Int {
    return isTurnout ? itemType.connections.count : 0
  }
  
  public var actualTurnoutConnection : Int? {
      
    var state1 : TurnoutSwitchSetting = (switchNumber:1, switchState: .closed)
    
//      if let sw1 = self.sw1 {
//        state1 = (switchNumber:1, switchState: sw1.state)
//      }
    
    var state2 : TurnoutSwitchSetting = (switchNumber:2, switchState: .closed)

//     if let sw2 = self.sw2 {
//       state2 = (switchNumber:1, switchState: sw2.state)
//     }
    
    var index : Int = 0
    
    while index < numberOfConnections {
      
      let switchSettings = itemType.connections[index].switchSettings
              
      switch switchSettings.count {
      case 1:
        
        if switchSettings[0] == state1 {
          return index
        }
        
      case 2:
        
        if switchSettings[0] == state1 && switchSettings[1] == state2 {
          return index
        }
        
      default:
        break
      }

      index += 1
      
    }
    
    return nil

  }
  
  // MARK: Public Methods

  public func getValue(property:LayoutInspectorProperty) -> String {
    
    switch property {
    case .panelId:
      return panelId.toHexDotFormat(numberOfBytes: 6)
    case .panelName:
      let panel = appDelegate.networkLayer!.virtualNodeLookup[panelId]!
      return panel.userNodeName
    case .itemType:
      return itemType.title
    case .itemId:
      return nodeId.toHexDotFormat(numberOfBytes: 6)
    case .name:
      return userNodeName
    case .description:
      return userNodeDescription
    case .xPos:
      return "\(xPos)"
    case .yPos:
      return "\(yPos)"
    case .orientation:
      return orientation.title
    case .groupId:
      if let group = appDelegate.networkLayer?.virtualNodeLookup[groupId] {
        return group.userNodeName
      }
      return ""
    case .directionality:
      return directionality.title
    case .allowShunt:
      return isReverseShuntAllowed ? "true" : "false"
    case .electrification:
      return trackElectrificationType.title
    case .isCriticalSection:
      return isCriticalSection ? "true" : "false"
    case .isHiddenSection:
      return isHiddenSection ? "true" : "false"
    case .trackGradient:
      return "\(trackGradient)"
    case .trackGauge:
      return trackGauge.title
    case .lengthRoute1:
      return "\(UnitLength.convert(fromValue: getDimension(routeNumber: 1)!, fromUnits: UnitLength.defaultValueActualLength, toUnits: appNode!.unitsActualLength))"
    case .lengthRoute2:
      return "\(UnitLength.convert(fromValue: getDimension(routeNumber: 2)!, fromUnits: UnitLength.defaultValueActualLength, toUnits: appNode!.unitsActualLength))"
    case .lengthRoute3:
      return "\(UnitLength.convert(fromValue: getDimension(routeNumber: 3)!, fromUnits: UnitLength.defaultValueActualLength, toUnits: appNode!.unitsActualLength))"
    case .lengthRoute4:
      return "\(UnitLength.convert(fromValue: getDimension(routeNumber: 4)!, fromUnits: UnitLength.defaultValueActualLength, toUnits: appNode!.unitsActualLength))"
    case .lengthRoute5:
      return "\(UnitLength.convert(fromValue: getDimension(routeNumber: 5)!, fromUnits: UnitLength.defaultValueActualLength, toUnits: appNode!.unitsActualLength))"
    case .lengthRoute6:
      return "\(UnitLength.convert(fromValue: getDimension(routeNumber: 6)!, fromUnits: UnitLength.defaultValueActualLength, toUnits: appNode!.unitsActualLength))"
    case .lengthRoute7:
      return "\(UnitLength.convert(fromValue: getDimension(routeNumber: 7)!, fromUnits: UnitLength.defaultValueActualLength, toUnits: appNode!.unitsActualLength))"
    case .lengthRoute8:
      return "\(UnitLength.convert(fromValue: getDimension(routeNumber: 8)!, fromUnits: UnitLength.defaultValueActualLength, toUnits: appNode!.unitsActualLength))"
    case .link:
      if let link = appDelegate.networkLayer?.virtualNodeLookup[linkId] {
        return link.userNodeName
      }
      return ""
    case .turnoutMotorType1:
      return getTurnoutMotorType(turnoutNumber: 1)!.title
    case .turnoutMotorType2:
      return getTurnoutMotorType(turnoutNumber: 2)!.title
    case .turnoutMotorType3:
      return getTurnoutMotorType(turnoutNumber: 3)!.title
    case .turnoutMotorType4:
      return getTurnoutMotorType(turnoutNumber: 4)!.title
    case .sensorType:
      return sensorType.title
    case .sensorPosition:
      return "\(UnitLength.convert(fromValue: sensorPosition, fromUnits: UnitLength.defaultValueActualDistance, toUnits: appNode!.unitsActualDistance))"
    case .sensorActivateLatency:
      return "\(UnitTime.convert(fromValue: sensorActivateLatency, fromUnits: UnitTime.defaultValue, toUnits: appNode!.unitsTime))"
    case .sensorDeactivateLatency:
      return "\(UnitTime.convert(fromValue: sensorDeactivateLatency, fromUnits: UnitTime.defaultValue, toUnits: appNode!.unitsTime))"
    case .signalType:
      return signalType.title
    case .signalRouteDirection:
      return signalRouteDirection.title
    case .signalPosition:
      return "\(UnitLength.convert(fromValue: signalPosition, fromUnits: UnitLength.defaultValueActualDistance, toUnits: appNode!.unitsActualDistance))"
    case .enterDetectionZoneEventId:
      let id = enterDetectionZoneEventId
      return id == 0 ? "" : id.toHexDotFormat(numberOfBytes: 8)
    case .exitDetectionZoneEventId:
      let id = exitDetectionZoneEventId
      return id == 0 ? "" : id.toHexDotFormat(numberOfBytes: 8)
    case .enterTranspondingZoneEventId:
      let id = enterTranspondingZoneEventId
      return id == 0 ? "" : id.toHexDotFormat(numberOfBytes: 8)
    case .exitTranspondingZoneEventId:
      let id = exitTranspondingZoneEventId
      return id == 0 ? "" : id.toHexDotFormat(numberOfBytes: 8)
    case .trackFaultEventId:
      let id = trackFaultEventId
      return id == 0 ? "" : id.toHexDotFormat(numberOfBytes: 8)
    case .trackFaultClearedEventId:
      let id = trackFaultClearedEventId
      return id == 0 ? "" : id.toHexDotFormat(numberOfBytes: 8)
    case .locationServicesEventId:
      let id = locationServicesEventId
      return id == 0 ? "" : id.toHexDotFormat(numberOfBytes: 8)
    case .sw1ThrowEventId:
      let id = getTurnoutThrowEventId(turnoutNumber: 1)!
      return id == 0 ? "" : id.toHexDotFormat(numberOfBytes: 8)
    case .sw1CloseEventId:
      let id = getTurnoutCloseEventId(turnoutNumber: 1)!
      return id == 0 ? "" : id.toHexDotFormat(numberOfBytes: 8)
    case .sw1ThrownEventId:
      let id = getTurnoutThrownEventId(turnoutNumber: 1)!
      return id == 0 ? "" : id.toHexDotFormat(numberOfBytes: 8)
    case .sw1ClosedEventId:
      let id = getTurnoutClosedEventId(turnoutNumber: 1)!
      return id == 0 ? "" : id.toHexDotFormat(numberOfBytes: 8)
    case .sw2ThrowEventId:
      let id = getTurnoutThrowEventId(turnoutNumber: 2)!
      return id == 0 ? "" : id.toHexDotFormat(numberOfBytes: 8)
    case .sw2CloseEventId:
      let id = getTurnoutCloseEventId(turnoutNumber: 2)!
      return id == 0 ? "" : id.toHexDotFormat(numberOfBytes: 8)
    case .sw2ThrownEventId:
      let id = getTurnoutThrownEventId(turnoutNumber: 2)!
      return id == 0 ? "" : id.toHexDotFormat(numberOfBytes: 8)
    case .sw2ClosedEventId:
      let id = getTurnoutClosedEventId(turnoutNumber: 2)!
      return id == 0 ? "" : id.toHexDotFormat(numberOfBytes: 8)
    case .sw3ThrowEventId:
      let id = getTurnoutThrowEventId(turnoutNumber: 3)!
      return id == 0 ? "" : id.toHexDotFormat(numberOfBytes: 8)
    case .sw3CloseEventId:
      let id = getTurnoutCloseEventId(turnoutNumber: 3)!
      return id == 0 ? "" : id.toHexDotFormat(numberOfBytes: 8)
    case .sw3ThrownEventId:
      let id = getTurnoutThrownEventId(turnoutNumber: 3)!
      return id == 0 ? "" : id.toHexDotFormat(numberOfBytes: 8)
    case .sw3ClosedEventId:
      let id = getTurnoutClosedEventId(turnoutNumber: 3)!
      return id == 0 ? "" : id.toHexDotFormat(numberOfBytes: 8)
    case .sw4ThrowEventId:
      let id = getTurnoutThrowEventId(turnoutNumber: 4)!
      return id == 0 ? "" : id.toHexDotFormat(numberOfBytes: 8)
    case .sw4CloseEventId:
      let id = getTurnoutCloseEventId(turnoutNumber: 4)!
      return id == 0 ? "" : id.toHexDotFormat(numberOfBytes: 8)
    case .sw4ThrownEventId:
      let id = getTurnoutThrownEventId(turnoutNumber: 4)!
      return id == 0 ? "" : id.toHexDotFormat(numberOfBytes: 8)
    case .sw4ClosedEventId:
      let id = getTurnoutClosedEventId(turnoutNumber: 4)!
      return id == 0 ? "" : id.toHexDotFormat(numberOfBytes: 8)
    case .sensorActivatedEventId:
      let id = sensorActivatedEventId
      return id == 0 ? "" : id.toHexDotFormat(numberOfBytes: 8)
    case .sensorDeactivatedEventId:
      let id = sensorDeactivatedEventId
      return id == 0 ? "" : id.toHexDotFormat(numberOfBytes: 8)
    case .sensorLocationServicesEventId:
      let id = sensorLocationServicesEventId
      return id == 0 ? "" : id.toHexDotFormat(numberOfBytes: 8)
    case .signalSetState0EventId, .signalSetState1EventId, .signalSetState2EventId, .signalSetState3EventId, .signalSetState4EventId, .signalSetState5EventId, .signalSetState6EventId, .signalSetState7EventId, .signalSetState8EventId, .signalSetState9EventId, .signalSetState10EventId, .signalSetState11EventId, .signalSetState12EventId, .signalSetState13EventId, .signalSetState14EventId, .signalSetState15EventId, .signalSetState16EventId, .signalSetState17EventId, .signalSetState18EventId, .signalSetState19EventId, .signalSetState20EventId, .signalSetState21EventId, .signalSetState22EventId, .signalSetState23EventId, .signalSetState24EventId, .signalSetState25EventId, .signalSetState26EventId, .signalSetState27EventId, .signalSetState28EventId, .signalSetState29EventId, .signalSetState30EventId, .signalSetState31EventId:
      let index = property.rawValue - LayoutInspectorProperty.signalSetState0EventId.rawValue + 1
      let id = getSetSignalAspectEventId(number: index)!
      return id == 0 ? "" : id.toHexDotFormat(numberOfBytes: 8)
    case .speedConstraintDPType0, .speedConstraintDPType1, .speedConstraintDPType2, .speedConstraintDPType3, .speedConstraintDPType4, .speedConstraintDPType5, .speedConstraintDPType6, .speedConstraintDPType7, .speedConstraintDPType8, .speedConstraintDPType9, .speedConstraintDPType10, .speedConstraintDPType11, .speedConstraintDPType12, .speedConstraintDPType13, .speedConstraintDPType14, .speedConstraintDPType15:
      let index = (property.rawValue - LayoutInspectorProperty.speedConstraintDPType0.rawValue) / 2 + 1
      return getSpeedConstraintDPType(number: index)!.title
    case .speedConstraintDPValue0, .speedConstraintDPValue1, .speedConstraintDPValue2, .speedConstraintDPValue3, .speedConstraintDPValue4, .speedConstraintDPValue5, .speedConstraintDPValue6, .speedConstraintDPValue7, .speedConstraintDPValue8, .speedConstraintDPValue9, .speedConstraintDPValue10, .speedConstraintDPValue11, .speedConstraintDPValue12, .speedConstraintDPValue13, .speedConstraintDPValue14, .speedConstraintDPValue15:
      let index = (property.rawValue - LayoutInspectorProperty.speedConstraintDPValue0.rawValue) / 2 + 1
      let value = Double(float16: getSpeedConstraintDPValue(number: index)!)
      return "\(UnitSpeed.convert(fromValue: value, fromUnits: UnitSpeed.defaultValueScaleSpeed, toUnits: appNode!.unitsScaleSpeed))"

    case .speedConstraintDNType0, .speedConstraintDNType1, .speedConstraintDNType2, .speedConstraintDNType3, .speedConstraintDNType4, .speedConstraintDNType5, .speedConstraintDNType6, .speedConstraintDNType7, .speedConstraintDNType8, .speedConstraintDNType9, .speedConstraintDNType10, .speedConstraintDNType11, .speedConstraintDNType12, .speedConstraintDNType13, .speedConstraintDNType14, .speedConstraintDNType15:
      let index = (property.rawValue - LayoutInspectorProperty.speedConstraintDNType0.rawValue) / 2 + 1
      return getSpeedConstraintDNType(number: index)!.title
    case .speedConstraintDNValue0, .speedConstraintDNValue1, .speedConstraintDNValue2, .speedConstraintDNValue3, .speedConstraintDNValue4, .speedConstraintDNValue5, .speedConstraintDNValue6, .speedConstraintDNValue7, .speedConstraintDNValue8, .speedConstraintDNValue9, .speedConstraintDNValue10, .speedConstraintDNValue11, .speedConstraintDNValue12, .speedConstraintDNValue13, .speedConstraintDNValue14, .speedConstraintDNValue15:
      let index = (property.rawValue - LayoutInspectorProperty.speedConstraintDNValue0.rawValue) / 2 + 1
      let value = Double(float16: getSpeedConstraintDNValue(number: index)!)
      return "\(UnitSpeed.convert(fromValue: value, fromUnits: UnitSpeed.defaultValueScaleSpeed, toUnits: appNode!.unitsScaleSpeed))"
    }
    
  }

  public func setValue(property:LayoutInspectorProperty, string:String) {
    
    switch property {
    case .name:
      userNodeName = string
    case .description:
      userNodeDescription = string
    case .xPos:
      xPos = UInt16(string)!
    case .yPos:
      yPos = UInt16(string)!
    case .orientation:
      orientation = Orientation(title: string)!
    case .groupId:
//      if let group = appDelegate.networkLayer?.virtualNodeLookup[groupId] {
//        return group.userNodeName
//      }
      break
    case .directionality:
      directionality = BlockDirection(title: string)!
    case .allowShunt:
      isReverseShuntAllowed = string == "true"
    case .electrification:
      trackElectrificationType = TrackElectrificationType(title: string)!
    case .isCriticalSection:
      isCriticalSection = string == "true"
    case .isHiddenSection:
      isHiddenSection = string == "true"
    case .trackGradient:
      trackGradient = Float32(string)!
    case .trackGauge:
      trackGauge = TrackGauge(title: string)!
    case .lengthRoute1:
      setDimension(routeNumber: 1, value: UnitLength.convert(fromValue: Double(string)!, fromUnits: appNode!.unitsActualLength, toUnits: UnitLength.defaultValueActualLength))
    case .lengthRoute2:
      setDimension(routeNumber: 2, value: UnitLength.convert(fromValue: Double(string)!, fromUnits: appNode!.unitsActualLength, toUnits: UnitLength.defaultValueActualLength))
    case .lengthRoute3:
      setDimension(routeNumber: 3, value: UnitLength.convert(fromValue: Double(string)!, fromUnits: appNode!.unitsActualLength, toUnits: UnitLength.defaultValueActualLength))
    case .lengthRoute4:
      setDimension(routeNumber: 4, value: UnitLength.convert(fromValue: Double(string)!, fromUnits: appNode!.unitsActualLength, toUnits: UnitLength.defaultValueActualLength))
    case .lengthRoute5:
      setDimension(routeNumber: 5, value: UnitLength.convert(fromValue: Double(string)!, fromUnits: appNode!.unitsActualLength, toUnits: UnitLength.defaultValueActualLength))
    case .lengthRoute6:
      setDimension(routeNumber: 6, value: UnitLength.convert(fromValue: Double(string)!, fromUnits: appNode!.unitsActualLength, toUnits: UnitLength.defaultValueActualLength))
    case .lengthRoute7:
      setDimension(routeNumber: 7, value: UnitLength.convert(fromValue: Double(string)!, fromUnits: appNode!.unitsActualLength, toUnits: UnitLength.defaultValueActualLength))
    case .lengthRoute8:
      setDimension(routeNumber: 8, value: UnitLength.convert(fromValue: Double(string)!, fromUnits: appNode!.unitsActualLength, toUnits: UnitLength.defaultValueActualLength))
    case .link:
//      if let link = appDelegate.networkLayer?.virtualNodeLookup[linkId] {
//        return link.userNodeName
//      }
      break
    case .turnoutMotorType1:
      setTurnoutMotorType(turnoutNumber: 1, motorType: TurnoutMotorType(title: string)!)
    case .turnoutMotorType2:
      setTurnoutMotorType(turnoutNumber: 2, motorType: TurnoutMotorType(title: string)!)
    case .turnoutMotorType3:
      setTurnoutMotorType(turnoutNumber: 3, motorType: TurnoutMotorType(title: string)!)
    case .turnoutMotorType4:
      setTurnoutMotorType(turnoutNumber: 4, motorType: TurnoutMotorType(title: string)!)
    case .sensorType:
      sensorType = SensorType(title: string)!
    case .sensorPosition:
      sensorPosition = UnitLength.convert(fromValue: Double(string)!, fromUnits: appNode!.unitsActualDistance, toUnits: UnitLength.defaultValueActualDistance)
    case .sensorActivateLatency:
      sensorActivateLatency = UnitTime.convert(fromValue: Double(string)!, fromUnits: appNode!.unitsTime, toUnits: UnitTime.defaultValue)
    case .sensorDeactivateLatency:
      sensorDeactivateLatency = UnitTime.convert(fromValue: Double(string)!, fromUnits: appNode!.unitsTime, toUnits: UnitTime.defaultValue)
    case .signalType:
      signalType = SignalType(title: string)!
    case .signalRouteDirection:
      signalRouteDirection = RouteDirection(title: string)!
    case .signalPosition:
      signalPosition = UnitLength.convert(fromValue: Double(string)!, fromUnits: appNode!.unitsActualDistance, toUnits: UnitLength.defaultValueActualDistance)
    case .enterDetectionZoneEventId:
      enterDetectionZoneEventId = UInt64(dotHex: string, numberOfBytes: 8) ?? 0
    case .exitDetectionZoneEventId:
      exitDetectionZoneEventId = UInt64(dotHex: string, numberOfBytes: 8) ?? 0
    case .enterTranspondingZoneEventId:
      enterTranspondingZoneEventId = UInt64(dotHex: string, numberOfBytes: 8) ?? 0
    case .exitTranspondingZoneEventId:
      exitTranspondingZoneEventId = UInt64(dotHex: string, numberOfBytes: 8) ?? 0
    case .trackFaultEventId:
      trackFaultEventId = UInt64(dotHex: string, numberOfBytes: 8) ?? 0
    case .trackFaultClearedEventId:
      trackFaultClearedEventId = UInt64(dotHex: string, numberOfBytes: 8) ?? 0
    case .locationServicesEventId:
      locationServicesEventId = UInt64(dotHex: string, numberOfBytes: 8) ?? 0
    case .sw1ThrowEventId:
      setTurnoutThrowEventId(turnoutNumber: 1, eventId: UInt64(dotHex: string, numberOfBytes: 8) ?? 0)
    case .sw1CloseEventId:
      setTurnoutCloseEventId(turnoutNumber: 1, eventId: UInt64(dotHex: string, numberOfBytes: 8) ?? 0)
    case .sw1ThrownEventId:
      setTurnoutThrownEventId(turnoutNumber: 1, eventId: UInt64(dotHex: string, numberOfBytes: 8) ?? 0)
    case .sw1ClosedEventId:
      setTurnoutClosedEventId(turnoutNumber: 1, eventId: UInt64(dotHex: string, numberOfBytes: 8) ?? 0)
    case .sw2ThrowEventId:
      setTurnoutThrowEventId(turnoutNumber: 2, eventId: UInt64(dotHex: string, numberOfBytes: 8) ?? 0)
    case .sw2CloseEventId:
      setTurnoutCloseEventId(turnoutNumber: 2, eventId: UInt64(dotHex: string, numberOfBytes: 8) ?? 0)
    case .sw2ThrownEventId:
      setTurnoutThrownEventId(turnoutNumber: 2, eventId: UInt64(dotHex: string, numberOfBytes: 8) ?? 0)
    case .sw2ClosedEventId:
      setTurnoutClosedEventId(turnoutNumber: 2, eventId: UInt64(dotHex: string, numberOfBytes: 8) ?? 0)
    case .sw3ThrowEventId:
      setTurnoutThrowEventId(turnoutNumber: 3, eventId: UInt64(dotHex: string, numberOfBytes: 8) ?? 0)
    case .sw3CloseEventId:
      setTurnoutCloseEventId(turnoutNumber: 3, eventId: UInt64(dotHex: string, numberOfBytes: 8) ?? 0)
    case .sw3ThrownEventId:
      setTurnoutThrownEventId(turnoutNumber: 3, eventId: UInt64(dotHex: string, numberOfBytes: 8) ?? 0)
    case .sw3ClosedEventId:
      setTurnoutClosedEventId(turnoutNumber: 3, eventId: UInt64(dotHex: string, numberOfBytes: 8) ?? 0)
    case .sw4ThrowEventId:
      setTurnoutThrowEventId(turnoutNumber: 4, eventId: UInt64(dotHex: string, numberOfBytes: 8) ?? 0)
    case .sw4CloseEventId:
      setTurnoutCloseEventId(turnoutNumber: 4, eventId: UInt64(dotHex: string, numberOfBytes: 8) ?? 0)
    case .sw4ThrownEventId:
      setTurnoutThrownEventId(turnoutNumber: 4, eventId: UInt64(dotHex: string, numberOfBytes: 8) ?? 0)
    case .sw4ClosedEventId:
      setTurnoutClosedEventId(turnoutNumber: 4, eventId: UInt64(dotHex: string, numberOfBytes: 8) ?? 0)
    case .sensorActivatedEventId:
      sensorActivatedEventId = UInt64(dotHex: string, numberOfBytes: 8) ?? 0
    case .sensorDeactivatedEventId:
      sensorDeactivatedEventId = UInt64(dotHex: string, numberOfBytes: 8) ?? 0
    case .sensorLocationServicesEventId:
      sensorLocationServicesEventId = UInt64(dotHex: string, numberOfBytes: 8) ?? 0
    case .signalSetState0EventId, .signalSetState1EventId, .signalSetState2EventId, .signalSetState3EventId, .signalSetState4EventId, .signalSetState5EventId, .signalSetState6EventId, .signalSetState7EventId, .signalSetState8EventId, .signalSetState9EventId, .signalSetState10EventId, .signalSetState11EventId, .signalSetState12EventId, .signalSetState13EventId, .signalSetState14EventId, .signalSetState15EventId, .signalSetState16EventId, .signalSetState17EventId, .signalSetState18EventId, .signalSetState19EventId, .signalSetState20EventId, .signalSetState21EventId, .signalSetState22EventId, .signalSetState23EventId, .signalSetState24EventId, .signalSetState25EventId, .signalSetState26EventId, .signalSetState27EventId, .signalSetState28EventId, .signalSetState29EventId, .signalSetState30EventId, .signalSetState31EventId:
      let index = property.rawValue - LayoutInspectorProperty.signalSetState0EventId.rawValue + 1
      setSetSignalAspectEventId(number: index, eventId: UInt64(dotHex: string, numberOfBytes: 8) ?? 0)
    case .speedConstraintDPType0, .speedConstraintDPType1, .speedConstraintDPType2, .speedConstraintDPType3, .speedConstraintDPType4, .speedConstraintDPType5, .speedConstraintDPType6, .speedConstraintDPType7, .speedConstraintDPType8, .speedConstraintDPType9, .speedConstraintDPType10, .speedConstraintDPType11, .speedConstraintDPType12, .speedConstraintDPType13, .speedConstraintDPType14, .speedConstraintDPType15:
      let index = (property.rawValue - LayoutInspectorProperty.speedConstraintDPType0.rawValue) / 2 + 1
      setSpeedConstraintDPType(number: index, constraintType: SpeedConstraintType(title: string)!)
    case .speedConstraintDPValue0, .speedConstraintDPValue1, .speedConstraintDPValue2, .speedConstraintDPValue3, .speedConstraintDPValue4, .speedConstraintDPValue5, .speedConstraintDPValue6, .speedConstraintDPValue7, .speedConstraintDPValue8, .speedConstraintDPValue9, .speedConstraintDPValue10, .speedConstraintDPValue11, .speedConstraintDPValue12, .speedConstraintDPValue13, .speedConstraintDPValue14, .speedConstraintDPValue15:
      let index = (property.rawValue - LayoutInspectorProperty.speedConstraintDPValue0.rawValue) / 2 + 1
      let value = UnitSpeed.convert(fromValue: Double(string)!, fromUnits: appNode!.unitsScaleSpeed, toUnits: UnitSpeed.defaultValueScaleSpeed)
      setSpeedConstraintDPValue(number: index, constraint: value.float16)
    case .speedConstraintDNType0, .speedConstraintDNType1, .speedConstraintDNType2, .speedConstraintDNType3, .speedConstraintDNType4, .speedConstraintDNType5, .speedConstraintDNType6, .speedConstraintDNType7, .speedConstraintDNType8, .speedConstraintDNType9, .speedConstraintDNType10, .speedConstraintDNType11, .speedConstraintDNType12, .speedConstraintDNType13, .speedConstraintDNType14, .speedConstraintDNType15:
      let index = (property.rawValue - LayoutInspectorProperty.speedConstraintDNType0.rawValue) / 2 + 1
      setSpeedConstraintDNType(number: index, constraintType: SpeedConstraintType(title: string)!)
    case .speedConstraintDNValue0, .speedConstraintDNValue1, .speedConstraintDNValue2, .speedConstraintDNValue3, .speedConstraintDNValue4, .speedConstraintDNValue5, .speedConstraintDNValue6, .speedConstraintDNValue7, .speedConstraintDNValue8, .speedConstraintDNValue9, .speedConstraintDNValue10, .speedConstraintDNValue11, .speedConstraintDNValue12, .speedConstraintDNValue13, .speedConstraintDNValue14, .speedConstraintDNValue15:
      let index = (property.rawValue - LayoutInspectorProperty.speedConstraintDNValue0.rawValue) / 2 + 1
      let value = UnitSpeed.convert(fromValue: Double(string)!, fromUnits: appNode!.unitsScaleSpeed, toUnits: UnitSpeed.defaultValueScaleSpeed)
      setSpeedConstraintDNValue(number: index, constraint: value.float16)
    default:
      break
    }
    
  }

  override public func variableChanged(space:OpenLCBMemorySpace, address:Int) {
    
    guard let spaceId = space.standardSpace else {
      return
    }
    
    switch spaceId {
    case .configuration:
      switch address {
      default:
        break
      }
    case .acdiUser:
      switch address {
      default:
        break
      }
    default:
      break
    }
    
  }

  internal override func resetToFactoryDefaults() {

    configuration!.zeroMemory()
    
    super.resetToFactoryDefaults()
 
    xPos = 1
    yPos = 1
    
    saveMemorySpaces()

  }
  
  override internal func customizeDynamicCDI(cdi:String) -> String {
 
    var result = cdi

    var sub = ""
    
    if itemType.isGroup {
      
      sub += "<group>\n"
      sub += "  <name>Track Configuration</name>\n"

      sub += "  <float size='4'>\n"
      sub += "    <name>Track Gradient %</name>\n"
      sub += "    <min>0.0</min>\n"
      sub += "    <max>100.0</max>\n"
      sub += "  </float>\n"

      sub += "  <int size='1'>\n"
      sub += "    <name>Track Gauge</name>\n"
      sub += "    \(CDI.TRACK_GAUGE)"
      sub += "  </int>\n"

      sub += "  \(CDI.ROUTE_DIMENSION)"

      sub += "</group>\n"

    }
    else {
      sub += "<group offset='\(69)'/>\n"
    }

    result = result.replacingOccurrences(of: CDI.SBI_TRACK_CONFIGURATION, with: sub)

    sub = ""

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
      sub += "<name>Position of Sensor (\(CDI.ACTUAL_DISTANCE_UNITS))</name>\n"
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
      sub += "<name>Position of Signal (\(CDI.ACTUAL_DISTANCE_UNITS))</name>\n"
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
    
    sub = ""
    
    if itemType.isGroup {

      sub += "<group>\n"
      sub += "  <name>Speed Constraints</name>\n"

      sub += "<group replication='16'>\n"
      
      sub += "  <name>Direction Previous</name>\n"
      sub += "  <description>Defines the custom speed constraints for this block in the direction previous. These constraints will override any constraint of the same type set in the layout configuration.</description>\n"
      sub += "  <repname>Constraint #</repname>\n"

      sub += "<int size='2'>\n"
      sub += "  <name>Speed Constraint Type</name>\n"
      sub += "  <default>0</default>\n"
      sub += "  %%SPEED_CONSTRAINT_TYPE%%\n"
      sub += "</int>\n"

      sub += "<float size='2'>\n"
      sub += "  <name>Speed Constraint Value (%%SCALE_SPEED_UNITS%%)</name>\n"
      sub += "  <default>0.0</default>\n"
      sub += "  <min>0.0</min>\n"
      sub += "</float>\n"

      sub += "</group>\n"

      sub += "<group replication='16'>\n"
      
      sub += "  <name>Direction Next</name>\n"
      sub += "  <description>Defines the custom speed constraints for this block in the direction next. These constraints will override any constraint of the same type set in the layout configuration.</description>\n"
      sub += "  <repname>Constraint #</repname>\n"

      sub += "<int size='2'>\n"
      sub += "  <name>Speed Constraint Type</name>\n"
      sub += "  <default>0</default>\n"
      sub += "  %%SPEED_CONSTRAINT_TYPE%%\n"
      sub += "</int>\n"

      sub += "<float size='2'>\n"
      sub += "  <name>Speed Constraint Value (%%SCALE_SPEED_UNITS%%)</name>\n"
      sub += "  <default>0.0</default>\n"
      sub += "  <min>0.0</min>\n"
      sub += "</float>\n"

      sub += "</group>\n"

      sub += "</group>\n"

    }
    else {
      sub += "<group offset='128'/>\n"
    }
    
    result = result.replacingOccurrences(of: CDI.SPEED_CONSTRAINTS, with: sub)

    sub = ""
    
    #if DEBUG
    
    sub += "<group>\n"
    sub += "  <name>General Settings</name>\n"

    sub += "<eventid>\n"
    sub += "  <name>Switchboard Panel</name>\n"
    sub += "    \(CDI.SWITCHBOARD_PANEL_NODES)"
    sub += "</eventid>\n"

    sub += "<int size='2'>\n"
    sub += "  <name>Switchboard Item Type</name>\n"
    sub += "  \(CDI.SWITCHBOARD_ITEM_TYPE)"
    sub += "</int>\n"

    sub += "<int size='2'>\n"
    sub += "  <name>X Coordinate</name>\n"
    sub += "  <min>1</min>\n"
    sub += "  <max>65535</max>\n"
    sub += "</int>\n"

    sub += "<int size='2'>\n"
    sub += "  <name>Y Coordinate</name>\n"
    sub += "  <min>1</min>\n"
    sub += "  <max>65535</max>\n"
    sub += "</int>\n"

    sub += "<int size='1'>\n"
    sub += "  <name>Orientation</name>\n"
    sub += "  \(CDI.ORIENTATION)\n"
    sub += "</int>\n"

    sub += "<eventid>\n"
    sub += "  <name>Group</name>\n"
    sub += "  \(CDI.SWITCHBOARD_GROUP_NODES)"
    sub += "</eventid>\n"

    sub += "</group>\n"

    #else
    sub += "<group offset='23'/>\n"
    #endif

    result = result.replacingOccurrences(of: CDI.SBI_GENERAL_SETTINGS, with: sub)

    sub = ""
    
    if itemType.isGroup {
      
      sub += "<group>\n"
      sub += "  <name>Block Configuration</name>\n"
        
      sub += "  <int size='1'>\n"
      sub += "    <name>Directionality</name>\n"
      sub += "    \(CDI.DIRECTIONALITY)"
      sub += "  </int>\n"
        
      sub += "  <int size='1'>\n"
      sub += "    <name>Allow Shunt</name>\n"
      sub += "    \(CDI.YES_NO)"
      sub += "  </int>\n"
        
      sub += "  <int size='1'>\n"
      sub += "    <name>Track Electrification Type</name>\n"
      sub += "    \(CDI.TRACK_ELECTRIFICATION_TYPE)"
      sub += "  </int>\n"
        
      sub += "  <int size='1'>\n"
      sub += "    <name>Is Critical Section</name>\n"
      sub += "    \(CDI.YES_NO)"
      sub += "  </int>\n"
        
      sub += "  <int size='1'>\n"
      sub += "    <name>Is Hidden Section</name>\n"
      sub += "    \(CDI.YES_NO)"
      sub += "  </int>\n"
        
      sub += "</group>\n"

    }
    else {
      sub += "<group offset='5'/>\n"
    }

    result = result.replacingOccurrences(of: CDI.SBI_BLOCK_CONFIGURATION, with: sub)
    
    sub = ""

    if itemType.isGroup {
      
      sub += "<group>\n"
      sub += "  <name>Block Events</name>\n"
        
      sub += "  <eventid>\n"
      sub += "    <name>Enter Detection Zone Event ID</name>\n"
      sub += "  </eventid>\n"
        
      sub += "  <eventid>\n"
      sub += "    <name>Exit Detection Zone Event ID</name>\n"
      sub += "  </eventid>\n"

      sub += "  <eventid>\n"
      sub += "    <name>Enter Transponding Zone Event ID</name>\n"
      sub += "  </eventid>\n"
        
      sub += "  <eventid>\n"
      sub += "    <name>Exit Transponding Zone Event ID</name>\n"
      sub += "  </eventid>\n"

      sub += "  <eventid>\n"
      sub += "    <name>Track Fault Event ID</name>\n"
      sub += "  </eventid>\n"

      sub += "  <eventid>\n"
      sub += "    <name>Track Fault Cleared Event ID</name>\n"
      sub += "  </eventid>\n"

      sub += "  <eventid>\n"
      sub += "    <name>Location Services Event ID</name>\n"
      sub += "  </eventid>\n"

      sub += "</group>\n"

    }
    else {
      sub += "<group offset='56'/>\n"
    }

    result = result.replacingOccurrences(of: CDI.SBI_BLOCK_EVENTS, with: sub)

    sub = ""
    
    result = SwitchBoardItemType.insertMap(cdi: result)
    result = Orientation.insertMap(cdi: result)
    result = BlockDirection.insertMap(cdi: result)
    result = YesNo.insertMap(cdi: result)
    result = TrackElectrificationType.insertMap(cdi: result)
    result = TrackGauge.insertMap(cdi: result, layout: layoutNode)
    result = TurnoutMotorType.insertMap(cdi: result)
    result = SensorType.insertMap(cdi: result)
    result = RouteDirection.insertMap(cdi: result)
    result = SignalType.insertMap(cdi: result, countryCode: layoutNode!.countryCode)
    result = SpeedConstraintType.insertMap(cdi: result)

    if let appNode {
      result = appNode.insertPanelMap(cdi: result, layoutId: layoutNodeId)
      result = appNode.insertGroupMap(cdi: result, layoutId: layoutNodeId)
      result = result.replacingOccurrences(of: CDI.ACTUAL_LENGTH_UNITS, with: appNode.unitsActualLength.symbol)
      result = result.replacingOccurrences(of: CDI.ACTUAL_DISTANCE_UNITS, with: appNode.unitsActualDistance.symbol)
      result = result.replacingOccurrences(of: CDI.SCALE_SPEED_UNITS, with: appNode.unitsScaleSpeed.symbol)
      result = result.replacingOccurrences(of: CDI.TIME_UNITS, with: appNode.unitsTime.symbol)
    }

    return result
    
  }

 // MARK: Public Methods
  
  public func getDimension(routeNumber:Int) -> Double?
  {
    guard routeNumber > 0 && routeNumber <= 8 else {
      return nil
    }
    return configuration!.getDouble(address: addressDimensionA + (routeNumber - 1) * 8)!
  }
  
  public func setDimension(routeNumber:Int, value:Double) {
    if routeNumber > 0 && routeNumber <= 8 {
      configuration!.setDouble(address: addressDimensionA + (routeNumber - 1) * 8, value: value)
    }
  }
  
  public func getTurnoutMotorType(turnoutNumber:Int) -> TurnoutMotorType? {
    guard turnoutNumber > 0 && turnoutNumber <= 4 else {
      return nil
    }
    return TurnoutMotorType(rawValue: configuration!.getUInt8(address: addressSW1TurnoutMotorType + (turnoutNumber - 1) * 33)!)
  }
  
  public func setTurnoutMotorType(turnoutNumber:Int, motorType:TurnoutMotorType) {
    if turnoutNumber > 0 && turnoutNumber <= 4 {
      configuration!.setUInt(address: addressSW1TurnoutMotorType + (turnoutNumber - 1) * 33, value: motorType.rawValue)
    }
  }
  
  public func getTurnoutThrowEventId(turnoutNumber:Int) -> UInt64? {
    guard turnoutNumber > 0 && turnoutNumber <= 4 else {
      return nil
    }
    return configuration!.getUInt64(address: addressSW1ThrowEventId + (turnoutNumber - 1) * 33)
  }
  
  public func setTurnoutThrowEventId(turnoutNumber:Int, eventId:UInt64) {
    if turnoutNumber > 0 && turnoutNumber <= 4 {
      configuration!.setUInt(address: addressSW1ThrowEventId + (turnoutNumber - 1) * 33, value: eventId)
    }
  }
  
  public func getTurnoutThrownEventId(turnoutNumber:Int) -> UInt64? {
    guard turnoutNumber > 0 && turnoutNumber <= 4 else {
      return nil
    }
    return configuration!.getUInt64(address: addressSW1ThrownEventId + (turnoutNumber - 1) * 33)
  }
  
  public func setTurnoutThrownEventId(turnoutNumber:Int, eventId:UInt64) {
    if turnoutNumber > 0 && turnoutNumber <= 4 {
      configuration!.setUInt(address: addressSW1ThrownEventId + (turnoutNumber - 1) * 33, value: eventId)
    }
  }

  public func getTurnoutCloseEventId(turnoutNumber:Int) -> UInt64? {
    guard turnoutNumber > 0 && turnoutNumber <= 4 else {
      return nil
    }
    return configuration!.getUInt64(address: addressSW1CloseEventId + (turnoutNumber - 1) * 33)
  }
  
  public func setTurnoutCloseEventId(turnoutNumber:Int, eventId:UInt64) {
    if turnoutNumber > 0 && turnoutNumber <= 4 {
      configuration!.setUInt(address: addressSW1CloseEventId + (turnoutNumber - 1) * 33, value: eventId)
    }
  }
  
  public func getTurnoutClosedEventId(turnoutNumber:Int) -> UInt64? {
    guard turnoutNumber > 0 && turnoutNumber <= 4 else {
      return nil
    }
    return configuration!.getUInt64(address: addressSW1ClosedEventId + (turnoutNumber - 1) * 33)
  }
  
  public func setTurnoutClosedEventId(turnoutNumber:Int, eventId:UInt64) {
    if turnoutNumber > 0 && turnoutNumber <= 4 {
      configuration!.setUInt(address: addressSW1ClosedEventId + (turnoutNumber - 1) * 33, value: eventId)
    }
  }
  
  public func getSetSignalAspectEventId(number:Int) -> UInt64? {
    guard number > 0 && number <= 32 else {
      return nil
    }
    return configuration!.getUInt64(address: addressSignalSetState0EventId + (number - 1) * 8)
  }

  public func setSetSignalAspectEventId(number:Int, eventId:UInt64) {
    if number > 0 && number <= 32 {
      configuration!.setUInt(address: addressSignalSetState0EventId + (number - 1) * 8, value: eventId)
    }
  }

  public func getSpeedConstraintDPType(number:Int) -> SpeedConstraintType? {
    guard number > 0 && number <= 16 else {
      return nil
    }
    return SpeedConstraintType(rawValue: configuration!.getUInt16(address: addressSpeedConstraintDPType0 + (number - 1) * 4)!)
  }

  public func setSpeedConstraintDPType(number:Int, constraintType:SpeedConstraintType) {
    if number > 0 && number <= 16 {
      configuration!.setUInt(address: addressSpeedConstraintDPType0 + (number - 1) * 4, value: constraintType.rawValue)
    }
  }

  public func getSpeedConstraintDPValue(number:Int) -> float16_t? {
    guard number > 0 && number <= 16 else {
      return nil
    }
    return configuration!.getFloat16(address: addressSpeedConstraintDPValue0 + (number - 1) * 4)!
  }

  public func setSpeedConstraintDPValue(number:Int, constraint:float16_t) {
    if number > 0 && number <= 16 {
      configuration!.setUInt(address: addressSpeedConstraintDPValue0 + (number - 1) * 4, value: constraint.v)
    }
  }

  public func getSpeedConstraintDNType(number:Int) -> SpeedConstraintType? {
    guard number > 0 && number <= 16 else {
      return nil
    }
    return SpeedConstraintType(rawValue: configuration!.getUInt16(address: addressSpeedConstraintDNType0 + (number - 1) * 4)!)
  }

  public func setSpeedConstraintDNType(number:Int, constraintType:SpeedConstraintType) {
    if number > 0 && number <= 16 {
      configuration!.setUInt(address: addressSpeedConstraintDNType0 + (number - 1) * 4, value: constraintType.rawValue)
    }
  }

  public func getSpeedConstraintDNValue(number:Int) -> float16_t? {
    guard number > 0 && number <= 16 else {
      return nil
    }
    return configuration!.getFloat16(address: addressSpeedConstraintDNValue0 + (number - 1) * 4)!
  }

  public func setSpeedConstraintDNValue(number:Int, constraint:float16_t) {
    if number > 0 && number <= 16 {
      configuration!.setUInt(address: addressSpeedConstraintDNValue0 + (number - 1) * 4, value: constraint.v)
    }
  }
  
  // MARK: OpenLCBNetworkLayerDelegate Methods
  
  public override func openLCBMessageReceived(message: OpenLCBMessage) {
    
    super.openLCBMessageReceived(message: message)
    
    switch message.messageTypeIndicator {
     
    case .producerConsumerEventReport:
      
      if let eventId = message.eventId, let event = OpenLCBWellKnownEvent(rawValue: eventId) {
      
        switch event {
        default:
          break
        }
        
      }
      
    default:
      break
    }
    
  }

}
