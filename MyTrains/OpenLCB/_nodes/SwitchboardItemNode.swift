//
//  SwitchboardItemNode.swift
//  MyTrains
//
//  Created by Paul Willmott on 11/01/2024.
//

import Foundation
import SGUnitConversion
import SGInteger

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

    initSpaceAddress(&addressCommandedThrownEventId0, 8, &configurationSize)
    initSpaceAddress(&addressCommandedClosedEventId0, 8, &configurationSize)
    initSpaceAddress(&addressNotThrownEventId0, 8, &configurationSize)
    initSpaceAddress(&addressNotClosedEventId0, 8, &configurationSize)
    initSpaceAddress(&addressDoNotUseForSpeedProfiling, 1, &configurationSize)

    var temp = 0
    for _ in 1 ... 3 {
      initSpaceAddress(&temp, 8, &configurationSize)
      initSpaceAddress(&temp, 8, &configurationSize)
      initSpaceAddress(&temp, 8, &configurationSize)
      initSpaceAddress(&temp, 8, &configurationSize)
    }

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

      for index in 0 ... 3 {
        let offset = index * 32
        registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressCommandedThrownEventId0 + offset)
        registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressCommandedClosedEventId0 + offset)
        registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressNotThrownEventId0 + offset)
        registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressNotClosedEventId0 + offset)
        userConfigEventConsumedAddresses.insert(addressCommandedThrownEventId0 + offset)
        userConfigEventConsumedAddresses.insert(addressCommandedClosedEventId0 + offset)
        userConfigEventConsumedAddresses.insert(addressNotThrownEventId0 + offset)
        userConfigEventConsumedAddresses.insert(addressNotClosedEventId0 + offset)
      }
      
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
      
      configurationSize = 0
      initSpaceAddress(&addressRouteCommanded, 1, &configurationSize)
      initSpaceAddress(&addressIsThrown0, 1, &configurationSize)
      initSpaceAddress(&addressIsClosed0, 1, &configurationSize)
      
      temp = 0
      for _ in 1 ... 3 {
        initSpaceAddress(&temp, 1, &configurationSize)
        initSpaceAddress(&temp, 1, &configurationSize)
      }

      routeSettings = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.routeSettings.rawValue, defaultMemorySize: configurationSize, isReadOnly: false, description: "")

      if let routeSettings {
        
        routeSettings.delegate = self
        
        memorySpaces[routeSettings.space] = routeSettings
        
        registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressRouteCommanded)
        
        for temp in 0 ... 3 {
          let offset = temp * 2
          registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressIsThrown0 + offset)
          registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressIsClosed0 + offset)
        }
        
        findRouteSet()

      }

      if !memorySpacesInitialized {
        resetToFactoryDefaults()
      }
      
//      cdiFilename = "MyTrains Switchboard Item"
      
    }
    
    makeLookups()
    
  }
  
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
  internal var addressCommandedThrownEventId0       = 0
  internal var addressCommandedClosedEventId0       = 0
  internal var addressNotThrownEventId0             = 0
  internal var addressNotClosedEventId0             = 0
  internal var addressDoNotUseForSpeedProfiling     = 0
  
  // Route Settings Memory Space Addresses
  
  internal var addressRouteCommanded = 0
  /// Repeats 4
  internal var addressIsThrown0      = 0
  internal var addressIsClosed0      = 0
  
  internal var routeSettings : OpenLCBMemorySpace?

  private var layoutNode : LayoutNode? {
    return appDelegate.networkLayer!.virtualNodeLookup[layoutNodeId] as? LayoutNode
  }
  
  internal var eventLookup : [UInt64:Selector] = [:]
  
  internal var _controlBlock : SwitchboardItemNode?

  // MARK: Public Properties
  
  public var controlBlock : SwitchboardItemNode? {
    if let _controlBlock {
      return _controlBlock
    }
    if let item = appNode?.switchboardItemList[groupId] {
      _controlBlock = item
    }
    return _controlBlock
  }
  
  public override var visibility : OpenLCBNodeVisibility {
    return itemType.visibility
  }

  public override var isPassiveNode: Bool {
    return itemType.isPassiveNode
  }
  
  public var panelId : UInt64 {
    get {
      return configuration!.getUInt64(address: addressPanelId)!
    }
    set(value) {
      configuration!.setUInt(address: addressPanelId, value: value)
    }
  }

  public var itemType : SwitchboardItemType {
    get {
      return SwitchboardItemType(rawValue: configuration!.getUInt16(address: addressItemType)!)!
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

  public var location : SwitchboardLocation {
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
      _controlBlock = nil
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

  public var doNotUseForSpeedProfiling : Bool {
    get {
      return configuration!.getUInt8(address: addressDoNotUseForSpeedProfiling)! == 1
    }
    set(value) {
      configuration!.setUInt(address: addressDoNotUseForSpeedProfiling, value: value ? UInt8(1) : UInt8(0))
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

  public var routeCommanded : Int? {
    get {
      let saveValue = routeSettings!.getUInt8(address: addressRouteCommanded)!
      if saveValue == 0xff {
        return nil
      }
      return Int(saveValue)
    }
    set(value) {
      var saveValue : UInt8
      if let value {
        saveValue = UInt8(value)
      }
      else {
        saveValue = 0xff
      }
      routeSettings!.setUInt(address: addressRouteCommanded, value: saveValue)
      routeSettings?.save()
      appNode?.panelChanged(panelId: panelId)
    }
  }

  public var nodeLinks = [SWBNodeLink](repeating: (nil, -1, []), count: 8)

  public var isEliminated : Bool = false

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
    return itemType.isTurnout ? itemType.connections.count : 0
  }
  
  public var isBlockOccupied : Bool = false {
    didSet {
      appNode?.panelChanged(panelId: panelId)
    }
  }
  
  public var isSensorActivated : Bool = false {
    didSet {
      appNode?.panelChanged(panelId: panelId)
    }
  }
  
  public var isTrackFaulted : Bool = false {
    didSet {
      appNode?.panelChanged(panelId: panelId)
    }
  }
  
  public var routeSet : Int? {
    didSet {
      appNode?.panelChanged(panelId: panelId)
    }
  }
  
  public var isRouteConsistent : Bool {
    guard let routeSet, let routeCommanded else {
      return false
    }
    return routeSet == routeCommanded
  }
  
  // MARK: Public Methods

  public func getValue(property:LayoutInspectorProperty) -> String {
    
    switch property {
    case .panelId:
      return panelId.dotHex(numberOfBytes: 6)!
    case .panelName:
      let panel = appDelegate.networkLayer!.virtualNodeLookup[panelId]!
      return panel.userNodeName
    case .itemType:
      return itemType.title
    case .itemId:
      return nodeId.dotHex(numberOfBytes: 6)!
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
    case .blockDoNotUseForSpeedProfile, .sensorDoNotUseForSpeedProfile:
      return doNotUseForSpeedProfiling ? "true" : "false"
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
    case .lengthRoute1, .leftDivergingRoute, .rightThroughRoute, .yLeftDivergingRoute, .way3LeftDivergingRoute, .leftCurvedSmallerRadiusRoute, .rightCurvedLargerRadiusRoute:
      return "\(SGUnitLength.convert(fromValue: getDimension(routeNumber: 1)!, fromUnits: .centimeters, toUnits: appNode!.unitsActualLength))"
    case .lengthRoute2, .leftThroughRoute, .rightDivergingRoute, .yRightDivergingRoute, .way3ThroughRoute, .leftCurvedLargerRadiusRoute, .rightCurvedSmallerRadiusRoute:
      return "\(SGUnitLength.convert(fromValue: getDimension(routeNumber: 2)!, fromUnits: .centimeters, toUnits: appNode!.unitsActualLength))"
    case .lengthRoute3, .way3RightDivergingRoute:
      return "\(SGUnitLength.convert(fromValue: getDimension(routeNumber: 3)!, fromUnits: .centimeters, toUnits: appNode!.unitsActualLength))"
    case .lengthRoute4:
      return "\(SGUnitLength.convert(fromValue: getDimension(routeNumber: 4)!, fromUnits: .centimeters, toUnits: appNode!.unitsActualLength))"
    case .lengthRoute5:
      return "\(SGUnitLength.convert(fromValue: getDimension(routeNumber: 5)!, fromUnits: .centimeters, toUnits: appNode!.unitsActualLength))"
    case .lengthRoute6:
      return "\(SGUnitLength.convert(fromValue: getDimension(routeNumber: 6)!, fromUnits: .centimeters, toUnits: appNode!.unitsActualLength))"
    case .lengthRoute7:
      return "\(SGUnitLength.convert(fromValue: getDimension(routeNumber: 7)!, fromUnits: .centimeters, toUnits: appNode!.unitsActualLength))"
    case .lengthRoute8:
      return "\(SGUnitLength.convert(fromValue: getDimension(routeNumber: 8)!, fromUnits: .centimeters, toUnits: appNode!.unitsActualLength))"
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
      return "\(SGUnitLength.convert(fromValue: sensorPosition, fromUnits: .centimeters, toUnits: appNode!.unitsActualDistance))"
    case .sensorActivateLatency:
      return "\(SGUnitTime.convert(fromValue: sensorActivateLatency, fromUnits: defaultValueTime, toUnits: appNode!.unitsTime))"
    case .sensorDeactivateLatency:
      return "\(SGUnitTime.convert(fromValue: sensorDeactivateLatency, fromUnits: defaultValueTime, toUnits: appNode!.unitsTime))"
    case .signalType:
      return signalType.title
    case .signalRouteDirection:
      return signalRouteDirection.title
    case .signalPosition:
      return "\(SGUnitLength.convert(fromValue: signalPosition, fromUnits: .centimeters, toUnits: appNode!.unitsActualDistance))"
    case .enterDetectionZoneEventId:
      let id = enterDetectionZoneEventId
      return id == 0 ? "" : id.dotHex(numberOfBytes: 8)!
    case .exitDetectionZoneEventId:
      let id = exitDetectionZoneEventId
      return id == 0 ? "" : id.dotHex(numberOfBytes: 8)!
    case .enterTranspondingZoneEventId:
      let id = enterTranspondingZoneEventId
      return id == 0 ? "" : id.dotHex(numberOfBytes: 8)!
    case .exitTranspondingZoneEventId:
      let id = exitTranspondingZoneEventId
      return id == 0 ? "" : id.dotHex(numberOfBytes: 8)!
    case .trackFaultEventId:
      let id = trackFaultEventId
      return id == 0 ? "" : id.dotHex(numberOfBytes: 8)!
    case .trackFaultClearedEventId:
      let id = trackFaultClearedEventId
      return id == 0 ? "" : id.dotHex(numberOfBytes: 8)!
    case .locationServicesEventId:
      let id = locationServicesEventId
      return id == 0 ? "" : id.dotHex(numberOfBytes: 8)!
    case .sw1ThrowEventId:
      let id = getTurnoutThrowEventId(turnoutNumber: 1)!
      return id == 0 ? "" : id.dotHex(numberOfBytes: 8)!
    case .sw1CloseEventId:
      let id = getTurnoutCloseEventId(turnoutNumber: 1)!
      return id == 0 ? "" : id.dotHex(numberOfBytes: 8)!
    case .sw1ThrownEventId:
      let id = getTurnoutThrownEventId(turnoutNumber: 1)!
      return id == 0 ? "" : id.dotHex(numberOfBytes: 8)!
    case .sw1ClosedEventId:
      let id = getTurnoutClosedEventId(turnoutNumber: 1)!
      return id == 0 ? "" : id.dotHex(numberOfBytes: 8)!
    case .sw1NotThrownEventId:
      let id = getNotThrownEventId(turnoutNumber: 1) ?? 0
      return id == 0 ? "" : id.dotHex(numberOfBytes: 8)!
    case .sw1NotClosedEventId:
      let id = getNotClosedEventId(turnoutNumber: 1) ?? 0
      return id == 0 ? "" : id.dotHex(numberOfBytes: 8)!
    case .sw2ThrowEventId:
      let id = getTurnoutThrowEventId(turnoutNumber: 2)!
      return id == 0 ? "" : id.dotHex(numberOfBytes: 8)!
    case .sw2CloseEventId:
      let id = getTurnoutCloseEventId(turnoutNumber: 2)!
      return id == 0 ? "" : id.dotHex(numberOfBytes: 8)!
    case .sw2ThrownEventId:
      let id = getTurnoutThrownEventId(turnoutNumber: 2)!
      return id == 0 ? "" : id.dotHex(numberOfBytes: 8)!
    case .sw2ClosedEventId:
      let id = getTurnoutClosedEventId(turnoutNumber: 2)!
      return id == 0 ? "" : id.dotHex(numberOfBytes: 8)!
    case .sw2NotThrownEventId:
      let id = getNotThrownEventId(turnoutNumber: 2) ?? 0
      return id == 0 ? "" : id.dotHex(numberOfBytes: 8)!
    case .sw2NotClosedEventId:
      let id = getNotClosedEventId(turnoutNumber: 2) ?? 0
      return id == 0 ? "" : id.dotHex(numberOfBytes: 8)!
    case .sw3ThrowEventId:
      let id = getTurnoutThrowEventId(turnoutNumber: 3)!
      return id == 0 ? "" : id.dotHex(numberOfBytes: 8)!
    case .sw3CloseEventId:
      let id = getTurnoutCloseEventId(turnoutNumber: 3)!
      return id == 0 ? "" : id.dotHex(numberOfBytes: 8)!
    case .sw3ThrownEventId:
      let id = getTurnoutThrownEventId(turnoutNumber: 3)!
      return id == 0 ? "" : id.dotHex(numberOfBytes: 8)!
    case .sw3ClosedEventId:
      let id = getTurnoutClosedEventId(turnoutNumber: 3)!
      return id == 0 ? "" : id.dotHex(numberOfBytes: 8)!
    case .sw3NotThrownEventId:
      let id = getNotThrownEventId(turnoutNumber: 3) ?? 0
      return id == 0 ? "" : id.dotHex(numberOfBytes: 8)!
    case .sw3NotClosedEventId:
      let id = getNotClosedEventId(turnoutNumber: 3) ?? 0
      return id == 0 ? "" : id.dotHex(numberOfBytes: 8)!
    case .sw4ThrowEventId:
      let id = getTurnoutThrowEventId(turnoutNumber: 4)!
      return id == 0 ? "" : id.dotHex(numberOfBytes: 8)!
    case .sw4CloseEventId:
      let id = getTurnoutCloseEventId(turnoutNumber: 4)!
      return id == 0 ? "" : id.dotHex(numberOfBytes: 8)!
    case .sw4ThrownEventId:
      let id = getTurnoutThrownEventId(turnoutNumber: 4)!
      return id == 0 ? "" : id.dotHex(numberOfBytes: 8)!
    case .sw4ClosedEventId:
      let id = getTurnoutClosedEventId(turnoutNumber: 4)!
      return id == 0 ? "" : id.dotHex(numberOfBytes: 8)!
    case .sw4NotThrownEventId:
      let id = getNotThrownEventId(turnoutNumber: 4) ?? 0
      return id == 0 ? "" : id.dotHex(numberOfBytes: 8)!
    case .sw4NotClosedEventId:
      let id = getNotClosedEventId(turnoutNumber: 4) ?? 0
      return id == 0 ? "" : id.dotHex(numberOfBytes: 8)!
    case .sensorActivatedEventId:
      let id = sensorActivatedEventId
      return id == 0 ? "" : id.dotHex(numberOfBytes: 8)!
    case .sensorDeactivatedEventId:
      let id = sensorDeactivatedEventId
      return id == 0 ? "" : id.dotHex(numberOfBytes: 8)!
    case .sensorLocationServicesEventId:
      let id = sensorLocationServicesEventId
      return id == 0 ? "" : id.dotHex(numberOfBytes: 8)!
    case .signalSetState0EventId, .signalSetState1EventId, .signalSetState2EventId, .signalSetState3EventId, .signalSetState4EventId, .signalSetState5EventId, .signalSetState6EventId, .signalSetState7EventId, .signalSetState8EventId, .signalSetState9EventId, .signalSetState10EventId, .signalSetState11EventId, .signalSetState12EventId, .signalSetState13EventId, .signalSetState14EventId, .signalSetState15EventId, .signalSetState16EventId, .signalSetState17EventId, .signalSetState18EventId, .signalSetState19EventId, .signalSetState20EventId, .signalSetState21EventId, .signalSetState22EventId, .signalSetState23EventId, .signalSetState24EventId, .signalSetState25EventId, .signalSetState26EventId, .signalSetState27EventId, .signalSetState28EventId, .signalSetState29EventId, .signalSetState30EventId, .signalSetState31EventId:
      let index = property.rawValue - LayoutInspectorProperty.signalSetState0EventId.rawValue + 1
      let id = getSetSignalAspectEventId(number: index) ?? 0
      return id == 0 ? "" : id.dotHex(numberOfBytes: 8)!
    case .speedConstraintDPType0, .speedConstraintDPType1, .speedConstraintDPType2, .speedConstraintDPType3, .speedConstraintDPType4, .speedConstraintDPType5, .speedConstraintDPType6, .speedConstraintDPType7, .speedConstraintDPType8, .speedConstraintDPType9, .speedConstraintDPType10, .speedConstraintDPType11, .speedConstraintDPType12, .speedConstraintDPType13, .speedConstraintDPType14, .speedConstraintDPType15:
      let index = (property.rawValue - LayoutInspectorProperty.speedConstraintDPType0.rawValue) / 2 + 1
      return getSpeedConstraintDPType(number: index)!.title
    case .speedConstraintDPValue0, .speedConstraintDPValue1, .speedConstraintDPValue2, .speedConstraintDPValue3, .speedConstraintDPValue4, .speedConstraintDPValue5, .speedConstraintDPValue6, .speedConstraintDPValue7, .speedConstraintDPValue8, .speedConstraintDPValue9, .speedConstraintDPValue10, .speedConstraintDPValue11, .speedConstraintDPValue12, .speedConstraintDPValue13, .speedConstraintDPValue14, .speedConstraintDPValue15:
      let index = (property.rawValue - LayoutInspectorProperty.speedConstraintDPValue0.rawValue) / 2 + 1
      let value = Double(float16: getSpeedConstraintDPValue(number: index)!)
      return "\(SGUnitSpeed.convert(fromValue: value, fromUnits: defaultValueScaleSpeed, toUnits: appNode!.unitsScaleSpeed))"

    case .speedConstraintDNType0, .speedConstraintDNType1, .speedConstraintDNType2, .speedConstraintDNType3, .speedConstraintDNType4, .speedConstraintDNType5, .speedConstraintDNType6, .speedConstraintDNType7, .speedConstraintDNType8, .speedConstraintDNType9, .speedConstraintDNType10, .speedConstraintDNType11, .speedConstraintDNType12, .speedConstraintDNType13, .speedConstraintDNType14, .speedConstraintDNType15:
      let index = (property.rawValue - LayoutInspectorProperty.speedConstraintDNType0.rawValue) / 2 + 1
      return getSpeedConstraintDNType(number: index)!.title
    case .speedConstraintDNValue0, .speedConstraintDNValue1, .speedConstraintDNValue2, .speedConstraintDNValue3, .speedConstraintDNValue4, .speedConstraintDNValue5, .speedConstraintDNValue6, .speedConstraintDNValue7, .speedConstraintDNValue8, .speedConstraintDNValue9, .speedConstraintDNValue10, .speedConstraintDNValue11, .speedConstraintDNValue12, .speedConstraintDNValue13, .speedConstraintDNValue14, .speedConstraintDNValue15:
      let index = (property.rawValue - LayoutInspectorProperty.speedConstraintDNValue0.rawValue) / 2 + 1
      let value = Double(float16: getSpeedConstraintDNValue(number: index)!)
      return "\(SGUnitSpeed.convert(fromValue: value, fromUnits: defaultValueScaleSpeed, toUnits: appNode!.unitsScaleSpeed))"
    case .sw1CommandedThrownEventId, .sw2CommandedThrownEventId, .sw3CommandedThrownEventId, .sw4CommandedThrownEventId:
      let index = 1 + property.rawValue - LayoutInspectorProperty.sw1CommandedThrownEventId.rawValue
      let id = getCommandedThrownEventId(turnoutNumber: index) ?? 0
      return id == 0 ? "" : id.dotHex(numberOfBytes: 8)!
    case .sw1CommandedClosedEventId, .sw2CommandedClosedEventId, .sw3CommandedClosedEventId, .sw4CommandedClosedEventId:
      let index = 1 + property.rawValue - LayoutInspectorProperty.sw1CommandedThrownEventId.rawValue
      let id = getCommandedClosedEventId(turnoutNumber: index) ?? 0
      return id == 0 ? "" : id.dotHex(numberOfBytes: 8)!
    }
    
  }

  public func setValue(property:LayoutInspectorProperty, string:String) {
    
    var eventChanged = false
    
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
    case .lengthRoute1, .leftDivergingRoute, .rightThroughRoute, .yLeftDivergingRoute, .leftCurvedSmallerRadiusRoute, .rightCurvedLargerRadiusRoute, .way3LeftDivergingRoute:
      setDimension(routeNumber: 1, value: SGUnitLength.convert(fromValue: Double(string)!, fromUnits: appNode!.unitsActualLength, toUnits: .centimeters))
    case .lengthRoute2, .leftThroughRoute, .rightDivergingRoute, .yRightDivergingRoute, .way3ThroughRoute, .leftCurvedLargerRadiusRoute, .rightCurvedSmallerRadiusRoute:
      setDimension(routeNumber: 2, value: SGUnitLength.convert(fromValue: Double(string)!, fromUnits: appNode!.unitsActualLength, toUnits: .centimeters))
    case .lengthRoute3, .way3RightDivergingRoute:
      setDimension(routeNumber: 3, value: SGUnitLength.convert(fromValue: Double(string)!, fromUnits: appNode!.unitsActualLength, toUnits: .centimeters))
    case .lengthRoute4:
      setDimension(routeNumber: 4, value: SGUnitLength.convert(fromValue: Double(string)!, fromUnits: appNode!.unitsActualLength, toUnits: .centimeters))
    case .lengthRoute5:
      setDimension(routeNumber: 5, value: SGUnitLength.convert(fromValue: Double(string)!, fromUnits: appNode!.unitsActualLength, toUnits: .centimeters))
    case .lengthRoute6:
      setDimension(routeNumber: 6, value: SGUnitLength.convert(fromValue: Double(string)!, fromUnits: appNode!.unitsActualLength, toUnits: .centimeters))
    case .lengthRoute7:
      setDimension(routeNumber: 7, value: SGUnitLength.convert(fromValue: Double(string)!, fromUnits: appNode!.unitsActualLength, toUnits: .centimeters))
    case .lengthRoute8:
      setDimension(routeNumber: 8, value: SGUnitLength.convert(fromValue: Double(string)!, fromUnits: appNode!.unitsActualLength, toUnits: .centimeters))
    case .link:
      if let link = appNode?.getLink(name: string) {
        linkId = link.nodeId
      }
      else {
        linkId = 0
      }
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
      sensorPosition = SGUnitLength.convert(fromValue: Double(string)!, fromUnits: appNode!.unitsActualDistance, toUnits: .centimeters)
    case .sensorActivateLatency:
      sensorActivateLatency = SGUnitTime.convert(fromValue: Double(string)!, fromUnits: appNode!.unitsTime, toUnits: defaultValueTime)
    case .sensorDeactivateLatency:
      sensorDeactivateLatency = SGUnitTime.convert(fromValue: Double(string)!, fromUnits: appNode!.unitsTime, toUnits: defaultValueTime)
    case .blockDoNotUseForSpeedProfile, .sensorDoNotUseForSpeedProfile:
      doNotUseForSpeedProfiling = string == "true"
    case .signalType:
      signalType = SignalType(title: string)!
    case .signalRouteDirection:
      signalRouteDirection = RouteDirection(title: string)!
    case .signalPosition:
      signalPosition = SGUnitLength.convert(fromValue: Double(string)!, fromUnits: appNode!.unitsActualDistance, toUnits: .centimeters)
    case .enterDetectionZoneEventId:
      enterDetectionZoneEventId = UInt64(dotHex: string, numberOfBytes: 8) ?? 0
      eventChanged = true
    case .exitDetectionZoneEventId:
      exitDetectionZoneEventId = UInt64(dotHex: string, numberOfBytes: 8) ?? 0
      eventChanged = true
    case .enterTranspondingZoneEventId:
      enterTranspondingZoneEventId = UInt64(dotHex: string, numberOfBytes: 8) ?? 0
      eventChanged = true
    case .exitTranspondingZoneEventId:
      exitTranspondingZoneEventId = UInt64(dotHex: string, numberOfBytes: 8) ?? 0
      eventChanged = true
    case .trackFaultEventId:
      trackFaultEventId = UInt64(dotHex: string, numberOfBytes: 8) ?? 0
      eventChanged = true
    case .trackFaultClearedEventId:
      trackFaultClearedEventId = UInt64(dotHex: string, numberOfBytes: 8) ?? 0
      eventChanged = true
    case .locationServicesEventId:
      let x = UInt64(dotHex: string, numberOfBytes: 8)
      locationServicesEventId = UInt64(dotHex: string, numberOfBytes: 8) ?? 0
      eventChanged = true
    case .sw1ThrowEventId:
      setTurnoutThrowEventId(turnoutNumber: 1, eventId: UInt64(dotHex: string, numberOfBytes: 8) ?? 0)
      eventChanged = true
    case .sw1CloseEventId:
      setTurnoutCloseEventId(turnoutNumber: 1, eventId: UInt64(dotHex: string, numberOfBytes: 8) ?? 0)
      eventChanged = true
    case .sw1ThrownEventId:
      setTurnoutThrownEventId(turnoutNumber: 1, eventId: UInt64(dotHex: string, numberOfBytes: 8) ?? 0)
      eventChanged = true
    case .sw1ClosedEventId:
      setTurnoutClosedEventId(turnoutNumber: 1, eventId: UInt64(dotHex: string, numberOfBytes: 8) ?? 0)
      eventChanged = true
    case .sw1NotThrownEventId:
      setNotThrownEventId(turnoutNumber: 1, eventId: UInt64(dotHex: string, numberOfBytes: 8) ?? 0)
      eventChanged = true
    case .sw1NotClosedEventId:
      setNotClosedEventId(turnoutNumber: 1, eventId: UInt64(dotHex: string, numberOfBytes: 8) ?? 0)
      eventChanged = true
    case .sw2ThrowEventId:
      setTurnoutThrowEventId(turnoutNumber: 2, eventId: UInt64(dotHex: string, numberOfBytes: 8) ?? 0)
      eventChanged = true
    case .sw2CloseEventId:
      setTurnoutCloseEventId(turnoutNumber: 2, eventId: UInt64(dotHex: string, numberOfBytes: 8) ?? 0)
      eventChanged = true
    case .sw2ThrownEventId:
      setTurnoutThrownEventId(turnoutNumber: 2, eventId: UInt64(dotHex: string, numberOfBytes: 8) ?? 0)
      eventChanged = true
    case .sw2ClosedEventId:
      setTurnoutClosedEventId(turnoutNumber: 2, eventId: UInt64(dotHex: string, numberOfBytes: 8) ?? 0)
      eventChanged = true
    case .sw2NotThrownEventId:
      setNotThrownEventId(turnoutNumber: 2, eventId: UInt64(dotHex: string, numberOfBytes: 8) ?? 0)
      eventChanged = true
    case .sw2NotClosedEventId:
      setNotClosedEventId(turnoutNumber: 2, eventId: UInt64(dotHex: string, numberOfBytes: 8) ?? 0)
      eventChanged = true
    case .sw3ThrowEventId:
      setTurnoutThrowEventId(turnoutNumber: 3, eventId: UInt64(dotHex: string, numberOfBytes: 8) ?? 0)
      eventChanged = true
    case .sw3CloseEventId:
      setTurnoutCloseEventId(turnoutNumber: 3, eventId: UInt64(dotHex: string, numberOfBytes: 8) ?? 0)
      eventChanged = true
    case .sw3ThrownEventId:
      setTurnoutThrownEventId(turnoutNumber: 3, eventId: UInt64(dotHex: string, numberOfBytes: 8) ?? 0)
      eventChanged = true
    case .sw3ClosedEventId:
      setTurnoutClosedEventId(turnoutNumber: 3, eventId: UInt64(dotHex: string, numberOfBytes: 8) ?? 0)
      eventChanged = true
    case .sw3NotThrownEventId:
      setNotThrownEventId(turnoutNumber: 3, eventId: UInt64(dotHex: string, numberOfBytes: 8) ?? 0)
      eventChanged = true
    case .sw3NotClosedEventId:
      setNotClosedEventId(turnoutNumber: 3, eventId: UInt64(dotHex: string, numberOfBytes: 8) ?? 0)
      eventChanged = true
    case .sw4ThrowEventId:
      setTurnoutThrowEventId(turnoutNumber: 4, eventId: UInt64(dotHex: string, numberOfBytes: 8) ?? 0)
      eventChanged = true
    case .sw4CloseEventId:
      setTurnoutCloseEventId(turnoutNumber: 4, eventId: UInt64(dotHex: string, numberOfBytes: 8) ?? 0)
      eventChanged = true
    case .sw4ThrownEventId:
      setTurnoutThrownEventId(turnoutNumber: 4, eventId: UInt64(dotHex: string, numberOfBytes: 8) ?? 0)
      eventChanged = true
    case .sw4ClosedEventId:
      setTurnoutClosedEventId(turnoutNumber: 4, eventId: UInt64(dotHex: string, numberOfBytes: 8) ?? 0)
      eventChanged = true
    case .sw4NotThrownEventId:
      setNotThrownEventId(turnoutNumber: 4, eventId: UInt64(dotHex: string, numberOfBytes: 8) ?? 0)
      eventChanged = true
    case .sw4NotClosedEventId:
      setNotClosedEventId(turnoutNumber: 4, eventId: UInt64(dotHex: string, numberOfBytes: 8) ?? 0)
      eventChanged = true
    case .sensorActivatedEventId:
      sensorActivatedEventId = UInt64(dotHex: string, numberOfBytes: 8) ?? 0
      eventChanged = true
    case .sensorDeactivatedEventId:
      sensorDeactivatedEventId = UInt64(dotHex: string, numberOfBytes: 8) ?? 0
      eventChanged = true
    case .sensorLocationServicesEventId:
      sensorLocationServicesEventId = UInt64(dotHex: string, numberOfBytes: 8) ?? 0
      eventChanged = true
    case .signalSetState0EventId, .signalSetState1EventId, .signalSetState2EventId, .signalSetState3EventId, .signalSetState4EventId, .signalSetState5EventId, .signalSetState6EventId, .signalSetState7EventId, .signalSetState8EventId, .signalSetState9EventId, .signalSetState10EventId, .signalSetState11EventId, .signalSetState12EventId, .signalSetState13EventId, .signalSetState14EventId, .signalSetState15EventId, .signalSetState16EventId, .signalSetState17EventId, .signalSetState18EventId, .signalSetState19EventId, .signalSetState20EventId, .signalSetState21EventId, .signalSetState22EventId, .signalSetState23EventId, .signalSetState24EventId, .signalSetState25EventId, .signalSetState26EventId, .signalSetState27EventId, .signalSetState28EventId, .signalSetState29EventId, .signalSetState30EventId, .signalSetState31EventId:
      let index = property.rawValue - LayoutInspectorProperty.signalSetState0EventId.rawValue + 1
      setSetSignalAspectEventId(number: index, eventId: UInt64(dotHex: string, numberOfBytes: 8) ?? 0)
      eventChanged = true
    case .speedConstraintDPType0, .speedConstraintDPType1, .speedConstraintDPType2, .speedConstraintDPType3, .speedConstraintDPType4, .speedConstraintDPType5, .speedConstraintDPType6, .speedConstraintDPType7, .speedConstraintDPType8, .speedConstraintDPType9, .speedConstraintDPType10, .speedConstraintDPType11, .speedConstraintDPType12, .speedConstraintDPType13, .speedConstraintDPType14, .speedConstraintDPType15:
      let index = (property.rawValue - LayoutInspectorProperty.speedConstraintDPType0.rawValue) / 2 + 1
      setSpeedConstraintDPType(number: index, constraintType: SpeedConstraintType(title: string)!)
    case .speedConstraintDPValue0, .speedConstraintDPValue1, .speedConstraintDPValue2, .speedConstraintDPValue3, .speedConstraintDPValue4, .speedConstraintDPValue5, .speedConstraintDPValue6, .speedConstraintDPValue7, .speedConstraintDPValue8, .speedConstraintDPValue9, .speedConstraintDPValue10, .speedConstraintDPValue11, .speedConstraintDPValue12, .speedConstraintDPValue13, .speedConstraintDPValue14, .speedConstraintDPValue15:
      let index = (property.rawValue - LayoutInspectorProperty.speedConstraintDPValue0.rawValue) / 2 + 1
      let value = SGUnitSpeed.convert(fromValue: Double(string)!, fromUnits: appNode!.unitsScaleSpeed, toUnits: defaultValueScaleSpeed)
      setSpeedConstraintDPValue(number: index, constraint: value.float16)
    case .speedConstraintDNType0, .speedConstraintDNType1, .speedConstraintDNType2, .speedConstraintDNType3, .speedConstraintDNType4, .speedConstraintDNType5, .speedConstraintDNType6, .speedConstraintDNType7, .speedConstraintDNType8, .speedConstraintDNType9, .speedConstraintDNType10, .speedConstraintDNType11, .speedConstraintDNType12, .speedConstraintDNType13, .speedConstraintDNType14, .speedConstraintDNType15:
      let index = (property.rawValue - LayoutInspectorProperty.speedConstraintDNType0.rawValue) / 2 + 1
      setSpeedConstraintDNType(number: index, constraintType: SpeedConstraintType(title: string)!)
    case .speedConstraintDNValue0, .speedConstraintDNValue1, .speedConstraintDNValue2, .speedConstraintDNValue3, .speedConstraintDNValue4, .speedConstraintDNValue5, .speedConstraintDNValue6, .speedConstraintDNValue7, .speedConstraintDNValue8, .speedConstraintDNValue9, .speedConstraintDNValue10, .speedConstraintDNValue11, .speedConstraintDNValue12, .speedConstraintDNValue13, .speedConstraintDNValue14, .speedConstraintDNValue15:
      let index = (property.rawValue - LayoutInspectorProperty.speedConstraintDNValue0.rawValue) / 2 + 1
      let value = SGUnitSpeed.convert(fromValue: Double(string)!, fromUnits: appNode!.unitsScaleSpeed, toUnits: defaultValueScaleSpeed)
      setSpeedConstraintDNValue(number: index, constraint: value.float16)
    case .sw1CommandedClosedEventId, .sw2CommandedClosedEventId, .sw3CommandedClosedEventId, .sw4CommandedClosedEventId:
      let index = 1 + property.rawValue - LayoutInspectorProperty.sw1CommandedClosedEventId.rawValue
      setCommandedClosedEventId(turnoutNumber: index, eventId: UInt64(dotHex: string, numberOfBytes: 8) ?? 0)
      eventChanged = true
    case .sw1CommandedThrownEventId, .sw2CommandedThrownEventId, .sw3CommandedThrownEventId, .sw4CommandedThrownEventId:
      let index = 1 + property.rawValue - LayoutInspectorProperty.sw1CommandedThrownEventId.rawValue
      setCommandedThrownEventId(turnoutNumber: index, eventId: UInt64(dotHex: string, numberOfBytes: 8) ?? 0)
      eventChanged = true
    default:
      break
    }
    
    if eventChanged {
      makeLookups()
    }
    
  }

  internal override func resetToFactoryDefaults() {

    configuration!.zeroMemory()
    
    super.resetToFactoryDefaults()
 
    xPos = 1
    yPos = 1
    
    routeCommanded = nil
    
    saveMemorySpaces()
    
    makeLookups()

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

  public func getCommandedThrownEventId(turnoutNumber:Int) -> UInt64? {
    guard turnoutNumber > 0 && turnoutNumber <= 4 else {
      return nil
    }
    return configuration!.getUInt64(address: addressCommandedThrownEventId0 + (turnoutNumber - 1) * 32)
  }
  
  public func setCommandedThrownEventId(turnoutNumber:Int, eventId:UInt64) {
    if turnoutNumber > 0 && turnoutNumber <= 4 {
      configuration!.setUInt(address: addressCommandedThrownEventId0 + (turnoutNumber - 1) * 32, value: eventId)
    }
  }

  public func getCommandedClosedEventId(turnoutNumber:Int) -> UInt64? {
    guard turnoutNumber > 0 && turnoutNumber <= 4 else {
      return nil
    }
    return configuration!.getUInt64(address: addressCommandedClosedEventId0 + (turnoutNumber - 1) * 32)
  }
  
  public func setCommandedClosedEventId(turnoutNumber:Int, eventId:UInt64) {
    if turnoutNumber > 0 && turnoutNumber <= 4 {
      configuration!.setUInt(address: addressCommandedClosedEventId0 + (turnoutNumber - 1) * 32, value: eventId)
    }
  }
  
  public func getNotThrownEventId(turnoutNumber:Int) -> UInt64? {
    guard turnoutNumber > 0 && turnoutNumber <= 4 else {
      return nil
    }
    return configuration!.getUInt64(address: addressNotThrownEventId0 + (turnoutNumber - 1) * 32)
  }
  
  public func setNotThrownEventId(turnoutNumber:Int, eventId:UInt64) {
    if turnoutNumber > 0 && turnoutNumber <= 4 {
      configuration!.setUInt(address: addressNotThrownEventId0 + (turnoutNumber - 1) * 32, value: eventId)
    }
  }

  public func getNotClosedEventId(turnoutNumber:Int) -> UInt64? {
    guard turnoutNumber > 0 && turnoutNumber <= 4 else {
      return nil
    }
    return configuration!.getUInt64(address: addressNotClosedEventId0 + (turnoutNumber - 1) * 32)
  }
  
  public func setNotClosedEventId(turnoutNumber:Int, eventId:UInt64) {
    if turnoutNumber > 0 && turnoutNumber <= 4 {
      configuration!.setUInt(address: addressNotClosedEventId0 + (turnoutNumber - 1) * 32, value: eventId)
    }
  }

  public func getIsThrown(turnoutNumber:Int) -> Bool? {
    guard turnoutNumber > 0 && turnoutNumber <= 4 else {
      return nil
    }
    let state = routeSettings!.getUInt8(address: addressIsThrown0 + (turnoutNumber - 1) * 2)
    switch state {
    case 1:
      return true
    case 2:
      return false
    default:
      return nil
    }
  }
  
  public func setIsThrown(turnoutNumber:Int, state:Bool?) {
    guard turnoutNumber > 0 && turnoutNumber <= 4 else {
      return
    }
    var value : UInt8
    switch state {
    case true:
      value = 1
    case false:
      value = 2
    default:
      value = 0
    }
    routeSettings!.setUInt(address: addressIsThrown0 + (turnoutNumber - 1) * 2, value: value)
    routeSettings?.save()
    findRouteSet()
  }

  public func getIsClosed(turnoutNumber:Int) -> Bool? {
    guard turnoutNumber > 0 && turnoutNumber <= 4 else {
      return nil
    }
    let state = routeSettings!.getUInt8(address: addressIsClosed0 + (turnoutNumber - 1) * 2)
    switch state {
    case 1:
      return true
    case 2:
      return false
    default:
      return nil
    }
  }
  
  public func setIsClosed(turnoutNumber:Int, state:Bool?) {
    guard turnoutNumber > 0 && turnoutNumber <= 4 else {
      return
    }
    var value : UInt8
    switch state {
    case true:
      value = 1
    case false:
      value = 2
    default:
      value = 0
    }
    routeSettings!.setUInt(address: addressIsClosed0 + (turnoutNumber - 1) * 2, value: value)
    routeSettings?.save()
    findRouteSet()
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
  
  public func rotateRight() {
    var orientation = Int(self.orientation.rawValue)
    orientation += 1
    if orientation > 7 {
      orientation = 0
    }
    self.orientation = Orientation(rawValue: UInt8(orientation)) ?? Orientation.defaultValue
    saveMemorySpaces()
  }
  
  public func rotateLeft() {
    var orientation = Int(self.orientation.rawValue)
    orientation -= 1
    if orientation < 0 {
      orientation = 7
    }
    self.orientation = Orientation(rawValue: UInt8(orientation)) ?? Orientation.defaultValue
    saveMemorySpaces()
  }
  
  public func findRouteSet() {
    
    routeSet = nil
    
    var routeNumber = 0
    
    let connections = itemType.connections
    
    while routeNumber < connections.count {
      
      let route = connections[routeNumber]
      
      var routeOK = true
      
      for item in route.switchSettings {
        
        if item.switchState == .thrown, let state = getIsThrown(turnoutNumber: item.switchNumber) {
          routeOK = state
        }
        else if item.switchState == .closed, let state = getIsClosed(turnoutNumber: item.switchNumber) {
          routeOK = state
        }
        else {
          routeOK = false
        }
        
        if !routeOK {
          break
        }
        
      }
      
      if routeOK {
        routeSet = routeNumber
        break
      }
      
      routeNumber += 1
      
    }
    
  }

  public func isTurnoutFeedbackAvailable(route:SwitchBoardConnection) -> Bool {
    
    for item in route.switchSettings {
      
      let index = item.switchNumber
      
      guard let thrownEventId = getTurnoutThrownEventId(turnoutNumber: index), let notThrownEventId = getNotThrownEventId(turnoutNumber: index), let closedEventId = getTurnoutClosedEventId(turnoutNumber: index), let notClosedEventId = getNotClosedEventId(turnoutNumber: index), thrownEventId != 0 && notThrownEventId != 0 && closedEventId != 0 && notClosedEventId != 0 else {
        return false
      }
      
    }
    
    return true

  }
  
  public var lengthOfRoute : Double? {
  
    switch itemType {
    case .block:
      return getDimension(routeNumber: 1)
    case .sensor:
      return controlBlock?.lengthOfRoute
    case .turnoutRight, .turnoutLeft, .cross, .diagonalCross, .yTurnout, .turnout3Way, .leftCurvedTurnout, .rightCurvedTurnout, .singleSlip, .doubleSlip:
      if let routeCommanded {
        return getDimension(routeNumber: routeCommanded + 1)
      }
    default:
      break
    }
    
    return nil
    
  }
  
  public func getEventsForProfiler(profile:SpeedProfile) -> [(eventId:UInt64, eventType:SpeedProfilerEventType, position:Double)] {

    var result : [(eventId:UInt64, eventType:SpeedProfilerEventType, position:Double)] = []

    guard let appNode else {
      return result
    }
    
    for (key, item) in appNode.switchboardItemList {
      
      if item.controlBlock === self {
        
        if (item.itemType.isSensor || item.itemType.isGroup) && !item.doNotUseForSpeedProfiling {
          
          if item.itemType.isGroup {
            
            if item.enterDetectionZoneEventId != 0, profile.useOccupancyDetectors, let lengthOfRoute = item.lengthOfRoute {
              result.append((item.enterDetectionZoneEventId, .occupancy, lengthOfRoute))
            }
            
          }
          else {
            
            let ok =
            (profile.useLightSensors && item.sensorType == .lightSensor) ||
            (profile.useRFIDReaders  && item.sensorType == .rfid) ||
            (profile.useReedSwitches && item.sensorType == .reedSwitch)

            if ok && item.sensorActivatedEventId != 0 {
              var position = item.sensorPosition
              if position < 0.0, let lengthOfRoute = item.lengthOfRoute {
                position += lengthOfRoute
              }
              result.append((item.sensorActivatedEventId, .sensor, position))
            }
            
          }
          
        }
        
      }
      
    }
    
    result.sort {$0.position < $1.position}

    return result
    
  }
  
  public func setRoute(route:Int) {
    
    routeCommanded = route
    
    let route = itemType.connections[route]
    
    let isNoFeedback = !isTurnoutFeedbackAvailable(route: route)
    
    for setting in route.switchSettings {
      
      var eventId : UInt64?
      
      let index = setting.switchNumber - 1
      
      switch setting.switchState {
      case .closed:
        eventId = getTurnoutCloseEventId(turnoutNumber: setting.switchNumber)
        if isNoFeedback {
          setIsThrown(turnoutNumber: index, state: false)
          setIsClosed(turnoutNumber: index, state: true)
        }
      case .thrown:
        eventId = getTurnoutThrowEventId(turnoutNumber: setting.switchNumber)
        if isNoFeedback {
          setIsClosed(turnoutNumber: index, state: false)
          setIsThrown(turnoutNumber: index, state: true)
        }
      default:
        break
      }
      
      if let eventId {
        sendEvent(eventId: eventId)
      }
      
    }
    
  }
  
  internal func makeLookups() {
    
    func addItem(eventId:UInt64?, action:Selector) {
      guard let eventId, eventId != 0 else {
        return
      }
      eventLookup[eventId] = action
    }
    
    eventLookup.removeAll()
    
    if itemType.isGroup {
      
      addItem(eventId: enterDetectionZoneEventId, action: #selector(enterDetectionZoneAction(_:)))
      addItem(eventId: exitDetectionZoneEventId, action: #selector(exitDetectionZoneAction(_:)))
      addItem(eventId: locationServicesEventId, action: #selector(locationServicesAction(_:)))
      addItem(eventId: trackFaultEventId, action: #selector(trackFaultAction(_:)))
      addItem(eventId: trackFaultClearedEventId, action: #selector(trackFaultClearedAction(_:)))
      
      if itemType.isTurnout {
        addItem(eventId: getTurnoutClosedEventId(turnoutNumber: 1), action: #selector(turnout1ClosedAction(_:)))
        addItem(eventId: getTurnoutClosedEventId(turnoutNumber: 2), action: #selector(turnout2ClosedAction(_:)))
        addItem(eventId: getTurnoutClosedEventId(turnoutNumber: 3), action: #selector(turnout3ClosedAction(_:)))
        addItem(eventId: getTurnoutClosedEventId(turnoutNumber: 4), action: #selector(turnout4ClosedAction(_:)))
        addItem(eventId: getNotClosedEventId(turnoutNumber: 1), action: #selector(turnout1NotClosedAction(_:)))
        addItem(eventId: getNotClosedEventId(turnoutNumber: 2), action: #selector(turnout2NotClosedAction(_:)))
        addItem(eventId: getNotClosedEventId(turnoutNumber: 3), action: #selector(turnout3NotClosedAction(_:)))
        addItem(eventId: getNotClosedEventId(turnoutNumber: 4), action: #selector(turnout4NotClosedAction(_:)))
        addItem(eventId: getTurnoutThrownEventId(turnoutNumber: 1), action: #selector(turnout1ThrownAction(_:)))
        addItem(eventId: getTurnoutThrownEventId(turnoutNumber: 2), action: #selector(turnout2ThrownAction(_:)))
        addItem(eventId: getTurnoutThrownEventId(turnoutNumber: 3), action: #selector(turnout3ThrownAction(_:)))
        addItem(eventId: getTurnoutThrownEventId(turnoutNumber: 4), action: #selector(turnout4ThrownAction(_:)))
        addItem(eventId: getNotThrownEventId(turnoutNumber: 1), action: #selector(turnout1NotThrownAction(_:)))
        addItem(eventId: getNotThrownEventId(turnoutNumber: 2), action: #selector(turnout2NotThrownAction(_:)))
        addItem(eventId: getNotThrownEventId(turnoutNumber: 3), action: #selector(turnout3NotThrownAction(_:)))
        addItem(eventId: getNotThrownEventId(turnoutNumber: 4), action: #selector(turnout4NotThrownAction(_:)))
      }
      
    }
    else if itemType.isSensor {
      addItem(eventId: sensorActivatedEventId, action: #selector(sensorActivatedAction(_:)))
      addItem(eventId: sensorDeactivatedEventId, action: #selector(sensorDeactivatedAction(_:)))
    }
    
  }
  
  // MARK: Event Actions
  
  @objc func enterDetectionZoneAction(_ event:OpenLCBMessage) {
    isBlockOccupied = true
  }

  @objc func exitDetectionZoneAction(_ event:OpenLCBMessage) {
    isBlockOccupied = false
  }

  @objc func locationServicesAction(_ event:OpenLCBMessage) {
    
  }

  @objc func trackFaultAction(_ event:OpenLCBMessage) {
    isTrackFaulted = true
  }

  @objc func trackFaultClearedAction(_ event:OpenLCBMessage) {
    isTrackFaulted = false
  }

  @objc func sensorActivatedAction(_ event:OpenLCBMessage) {
    isSensorActivated = true
  }

  @objc func sensorDeactivatedAction(_ event:OpenLCBMessage) {
    isSensorActivated = false
  }

  @objc func turnout1ClosedAction(_ event:OpenLCBMessage) {
    setIsClosed(turnoutNumber: 1, state: true)
  }

  @objc func turnout2ClosedAction(_ event:OpenLCBMessage) {
    setIsClosed(turnoutNumber: 2, state: true)
  }

  @objc func turnout3ClosedAction(_ event:OpenLCBMessage) {
    setIsClosed(turnoutNumber: 3, state: true)
  }

  @objc func turnout4ClosedAction(_ event:OpenLCBMessage) {
    setIsClosed(turnoutNumber: 4, state: true)
  }

  @objc func turnout1NotClosedAction(_ event:OpenLCBMessage) {
    setIsClosed(turnoutNumber: 1, state: false)
  }

  @objc func turnout2NotClosedAction(_ event:OpenLCBMessage) {
    setIsClosed(turnoutNumber: 2, state: false)
  }

  @objc func turnout3NotClosedAction(_ event:OpenLCBMessage) {
    setIsClosed(turnoutNumber: 3, state: false)
  }

  @objc func turnout4NotClosedAction(_ event:OpenLCBMessage) {
    setIsClosed(turnoutNumber: 4, state: false)
  }

  @objc func turnout1ThrownAction(_ event:OpenLCBMessage) {
    setIsThrown(turnoutNumber: 1, state: true)
  }

  @objc func turnout2ThrownAction(_ event:OpenLCBMessage) {
    setIsThrown(turnoutNumber: 2, state: true)
  }

  @objc func turnout3ThrownAction(_ event:OpenLCBMessage) {
    setIsThrown(turnoutNumber: 3, state: true)
  }

  @objc func turnout4ThrownAction(_ event:OpenLCBMessage) {
    setIsThrown(turnoutNumber: 4, state: true)
  }

  @objc func turnout1NotThrownAction(_ event:OpenLCBMessage) {
    setIsThrown(turnoutNumber: 1, state: false)
  }

  @objc func turnout2NotThrownAction(_ event:OpenLCBMessage) {
    setIsThrown(turnoutNumber: 2, state: false)
  }

  @objc func turnout3NotThrownAction(_ event:OpenLCBMessage) {
    setIsThrown(turnoutNumber: 3, state: false)
  }

  @objc func turnout4NotThrownAction(_ event:OpenLCBMessage) {
    setIsThrown(turnoutNumber: 4, state: false)
  }

  // MARK: OpenLCBNetworkLayerDelegate Methods
  
  public override func openLCBMessageReceived(message: OpenLCBMessage) {
    
    guard !isPassiveNode else {
      return
    }
    
    switch message.messageTypeIndicator {
     
    case .producerConsumerEventReport:
      
      if let eventId = message.eventId, let action = eventLookup[eventId] {
        self.perform(action, with: message)
      }

    default:
      super.openLCBMessageReceived(message: message)
    }
    
  }

}
