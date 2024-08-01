//
//  Decoder Extension - Layout Rules.swift
//  MyTrains
//
//  Created by Paul Willmott on 26/07/2024.
//

import Foundation
import AppKit

extension Decoder {

  internal func buildLayoutRules() {
    
    guard _layoutRules == nil else {
      return
    }
    
    _layoutRules = [
      (
        property1      : .locomotiveAddressType,
        testType1      : .equal,
        testValue1     : LocomotiveAddressType.primary.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.locomotiveAddressLong, .locomotiveAddressWarning],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .locomotiveAddressType,
        testType1      : .equal,
        testValue1     : LocomotiveAddressType.extended.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.marklinConsecutiveAddresses, .locomotiveAddressShort],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .enableDCCConsistAddress,
        testType1      : .equal,
        testValue1     : "false",
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.consistAddress, .consistReverseDirection],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .enableACAnalogMode,
        testType1      : .equal,
        testValue1     : "false",
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.acAnalogModeStartVoltage, .acAnalogModeMaximumSpeedVoltage],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .enableDCAnalogMode,
        testType1      : .equal,
        testValue1     : "false",
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.dcAnalogModeStartVoltage, .dcAnalogModeMaximumSpeedVoltage],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .brakeIfLeftRailSignalPositive,
        testType1      : .equal,
        testValue1     : "false",
        operator       : .and,
        property2      : .brakeIfRightRailSignalPositive,
        testType2      : .equal,
        testValue2     : "false",
        actionProperty : [.voltageDifferenceIndicatingABCBrakeSection, .abcReducedSpeed],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .enableABCShuttleTrain,
        testType1      : .equal,
        testValue1     : "false",
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.waitingPeriodBeforeDirectionChange],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .enableConstantBrakeDistance,
        testType1      : .equal,
        testValue1     : "false",
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.stoppingPeriod, .brakeDistanceLengthBackwards, .brakeDistanceLength, .driveUntilLocomotiveStopsInSpecifiedPeriod, .constantBrakeDistanceOnSpeedStep0, .differentBrakeDistanceBackwards],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .differentBrakeDistanceBackwards,
        testType1      : .equal,
        testValue1     : "false",
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.brakeDistanceLengthBackwards],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .driveUntilLocomotiveStopsInSpecifiedPeriod,
        testType1      : .equal,
        testValue1     : "false",
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.stoppingPeriod],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .enableRailComFeedback,
        testType1      : .equal,
        testValue1     : "false",
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.sendAddressViaBroadcastOnChannel1, .sendFollowingToCommandStation, .enableRailComPlusAutomaticAnnouncement, .allowDataTransmissionOnChannel2],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .detectSpeedStepModeAutomatically,
        testType1      : .equal,
        testValue1     : "false",
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.speedStepMode],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .enableAcceleration,
        testType1      : .equal,
        testValue1     : "false",
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.accelerationAdjustment, .accelerationRate],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .enableDeceleration,
        testType1      : .equal,
        testValue1     : "false",
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.decelerationRate, .decelerationAdjustment],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .enableReverseTrim,
        testType1      : .equal,
        testValue1     : "false",
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.reverseTrim],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .enableForwardTrim,
        testType1      : .equal,
        testValue1     : "false",
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.forwardTrim],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .enableShuntingModeTrim,
        testType1      : .equal,
        testValue1     : "false",
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.shuntingModeTrim],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .enableGearboxBacklashCompensation,
        testType1      : .equal,
        testValue1     : "false",
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.gearboxBacklashCompensation],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .physicalOutputEnableFunctionTimeout,
        testType1      : .equal,
        testValue1     : "false",
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputTimeUntilAutomaticPowerOff],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .physicalOutputUseClassLightLogic,
        testType1      : .equal,
        testValue1     : "false",
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputSequencePosition],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .physicalOutput,
        testType1      : .equal,
        testValue1     : ESUDecoderPhysicalOutput.aux10.title,
        operator       : .and,
        property2      : .decoderSensorSettings,
        testType2      : .equal,
        testValue2     : DecoderSensorSettings.useDigitalWheelSensor.title,
        actionProperty : [.physicalOutputRule17Forward, .physicalOutputLevel, .physicalOutputAccelerationRate, .physicalOutputPowerOffDelay, .physicalOutputSequencePosition, .physicalOutputPhaseShift, .physicalOutputHeatWhileLocomotiveStands, .physicalOutputStartupTimeInfo, .physicalOutputUseClassLightLogic, .physicalOutputExternalSmokeUnitType, .physicalOutputRule17Reverse, .physicalOutputFanPower, .physicalOutputStartupTime, .physicalOutputCouplerForce, .physicalOutputServoDurationA, .physicalOutputServoDoNotDisableServoPulseAtPositionB, .physicalOutputDimmer, .physicalOutputGradeCrossing, .physicalOutputServoPositionB, .physicalOutputPowerOnDelay, .physicalOutputTimeout, .physicalOutputBrightness, .physicalOutputServoDoNotDisableServoPulseAtPositionA, .physicalOutputSpecialFunctions, .physicalOutputDecelerationRate, .physicalOutputServoPositionA, .physicalOutputStartupDescription, .physicalOutputSmokeUnitControlMode, .physicalOutputChuffPower, .physicalOutputEnableFunctionTimeout, .physicalOutputTimeUntilAutomaticPowerOff, .physicalOutputMinimumHeatWhileLocomotiveDriving, .physicalOutputOutputMode, .physicalOutputLEDMode, .physicalOutputSpeed, .physicalOutputMaximumHeatWhileLocomotiveDriving, .physicalOutputServoDurationB, .physicalOutputPantographHeight],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .physicalOutput,
        testType1      : .equal,
        testValue1     : ESUDecoderPhysicalOutput.aux10.title,
        operator       : .and,
        property2      : .decoderSensorSettings,
        testType2      : .equal,
        testValue2     : DecoderSensorSettings.useOutputAUX10.title,
        actionProperty : [.physicalOutputAUX10Warning],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .physicalOutput,
        testType1      : .equal,
        testValue1     : ESUDecoderPhysicalOutput.aux11.title,
        operator       : .and,
        property2      : .enableSUSIMaster,
        testType2      : .equal,
        testValue2     : "false",
        actionProperty : [.physicalOutputAUX11Warning],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .physicalOutput,
        testType1      : .equal,
        testValue1     : ESUDecoderPhysicalOutput.aux12.title,
        operator       : .and,
        property2      : .enableSUSIMaster,
        testType2      : .equal,
        testValue2     : "false",
        actionProperty : [.physicalOutputAUX12Warning],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .physicalOutput,
        testType1      : .equal,
        testValue1     : ESUDecoderPhysicalOutput.aux11.title,
        operator       : .and,
        property2      : .enableSUSIMaster,
        testType2      : .equal,
        testValue2     : "true",
        actionProperty : [.physicalOutputChuffPower, .physicalOutputTimeUntilAutomaticPowerOff, .physicalOutputPowerOnDelay, .physicalOutputBrightness, .physicalOutputMaximumHeatWhileLocomotiveDriving, .physicalOutputSmokeUnitControlMode, .physicalOutputAccelerationRate, .physicalOutputServoPositionA, .physicalOutputServoDurationB, .physicalOutputPhaseShift, .physicalOutputSpeed, .physicalOutputLEDMode, .physicalOutputEnableFunctionTimeout, .physicalOutputExternalSmokeUnitType, .physicalOutputGradeCrossing, .physicalOutputTimeout, .physicalOutputMinimumHeatWhileLocomotiveDriving, .physicalOutputSpecialFunctions, .physicalOutputStartupTimeInfo, .physicalOutputRule17Forward, .physicalOutputLevel, .physicalOutputServoDurationA, .physicalOutputStartupDescription, .physicalOutputCouplerForce, .physicalOutputServoDoNotDisableServoPulseAtPositionA, .physicalOutputDecelerationRate, .physicalOutputOutputMode, .physicalOutputSequencePosition, .physicalOutputServoDoNotDisableServoPulseAtPositionB, .physicalOutputUseClassLightLogic, .physicalOutputRule17Reverse, .physicalOutputPowerOffDelay, .physicalOutputStartupTime, .physicalOutputFanPower, .physicalOutputHeatWhileLocomotiveStands, .physicalOutputDimmer, .physicalOutputServoPositionB, .physicalOutputPantographHeight],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .physicalOutput,
        testType1      : .equal,
        testValue1     : ESUDecoderPhysicalOutput.aux12.title,
        operator       : .and,
        property2      : .enableSUSIMaster,
        testType2      : .equal,
        testValue2     : "true",
        actionProperty : [.physicalOutputUseClassLightLogic, .physicalOutputOutputMode, .physicalOutputSequencePosition, .physicalOutputHeatWhileLocomotiveStands, .physicalOutputTimeout, .physicalOutputStartupDescription, .physicalOutputDimmer, .physicalOutputServoPositionA, .physicalOutputBrightness, .physicalOutputSmokeUnitControlMode, .physicalOutputExternalSmokeUnitType, .physicalOutputLevel, .physicalOutputRule17Reverse, .physicalOutputAccelerationRate, .physicalOutputLEDMode, .physicalOutputTimeUntilAutomaticPowerOff, .physicalOutputStartupTimeInfo, .physicalOutputServoDurationB, .physicalOutputSpeed, .physicalOutputEnableFunctionTimeout, .physicalOutputChuffPower, .physicalOutputStartupTime, .physicalOutputDecelerationRate, .physicalOutputSpecialFunctions, .physicalOutputServoPositionB, .physicalOutputPhaseShift, .physicalOutputPowerOffDelay, .physicalOutputServoDoNotDisableServoPulseAtPositionB, .physicalOutputMaximumHeatWhileLocomotiveDriving, .physicalOutputMinimumHeatWhileLocomotiveDriving, .physicalOutputServoDoNotDisableServoPulseAtPositionA, .physicalOutputGradeCrossing, .physicalOutputRule17Forward, .physicalOutputCouplerForce, .physicalOutputPowerOnDelay, .physicalOutputServoDurationA, .physicalOutputFanPower, .physicalOutputPantographHeight],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .enableAutomaticUncoupling,
        testType1      : .equal,
        testValue1     : "false",
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.automaticUncouplingWaitTime, .automaticUncouplingSpeed, .automaticUncouplingMoveTime, .automaticUncouplingPushTime],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .randomStop,
        testType1      : .equal,
        testValue1     : "false",
        operator       : .and,
        property2      : .randomDrive,
        testType2      : .equal,
        testValue2     : "false",
        actionProperty : [.randomActiveMaximum, .randomActiveMinimum, .randomPassiveMaximum, .randomPassiveMinimum, .randomTriggeredFunction, .randomOnlyPlayWhenDrivingSoundEnabled],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .enableSUSIMaster,
        testType1      : .equal,
        testValue1     : "false",
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.susiWarning, .physicalOutputAUX11Warning, .physicalOutputAUX12Warning],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .sensor1EnableAnalogSensorInput,
        testType1      : .equal,
        testValue1     : "false",
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.sensor1Threshold],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .sensor1DigitalSensorInputEnabled,
        testType1      : .equal,
        testValue1     : "true",
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.sensor1Threshold],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .sensor2EnableAnalogSensorInput,
        testType1      : .equal,
        testValue1     : "false",
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.sensor2Threshold],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .sensor2DigitalSensorInputEnabled,
        testType1      : .equal,
        testValue1     : "true",
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.sensor2Threshold],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .physicalOutput,
        testType1      : .notEqual,
        testValue1     : ESUDecoderPhysicalOutput.aux10.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputAUX10Warning],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .physicalOutput,
        testType1      : .notEqual,
        testValue1     : ESUDecoderPhysicalOutput.aux11.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputAUX11Warning],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .physicalOutput,
        testType1      : .notEqual,
        testValue1     : ESUDecoderPhysicalOutput.aux12.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputAUX12Warning],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .speedTableType,
        testType1      : .equal,
        testValue1     : SpeedTableType.vStartvMidvHigh.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.esuSpeedTable, .speedTableIndex, .speedTableEntryValue, .speedTablePreset, .maximumSpeed, .minimumSpeed],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .speedTableType,
        testType1      : .notEqual,
        testValue1     : SpeedTableType.vStartvMidvHigh.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.vStart, .vMid, .vHigh, .threeValueSpeedTable, .threeValueSpeedTablePreset],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .enableLoadControlBackEMF,
        testType1      : .equal,
        testValue1     : "false",
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.slowSpeedBackEMFSamplingPeriod, .slowSpeedLengthOfMeasurementGap, .regulationParameterI, .regulationReference, .fullSpeedBackEMFSamplingPeriod, .regulationParameterKSlow, .largestInternalSpeedStepThatUsesKSlow, .regulationParameterK, .fullSpeedLengthOfMeasurementGap],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .enableMotorCurrentLimiter,
        testType1      : .equal,
        testValue1     : "false",
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.motorCurrentLimiterLimit],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .enableRailComPlusSynchronization,
        testType1      : .equal,
        testValue1     : "false",
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.m4MasterDecoderManufacturer, .m4MasterDecoderSerialNumber],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .steamChuffMode,
        testType1      : .equal,
        testValue1     : SteamChuffMode.playSteamChuffsAccordingToSpeed.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.triggerImpulsesPerSteamChuff, .divideTriggerImpulsesInTwoIfShuntingModeEnabled],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .steamChuffMode,
        testType1      : .equal,
        testValue1     : SteamChuffMode.useExternalWheelSensor.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.distanceOfSteamChuffsAtSpeedStep1, .steamChuffAdjustmentAtHigherSpeedSteps],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .enableSecondaryTrigger,
        testType1      : .equal,
        testValue1     : "false",
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.secondaryTriggerDistanceReduction],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .enableMinimumDistanceOfSteamChuffs,
        testType1      : .equal,
        testValue1     : "false",
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.minimumDistanceofSteamChuffs],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .soundControlBasis,
        testType1      : .equal,
        testValue1     : SoundControlBasis.accelerationAndBrakeTime.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.enableLoadOperationThreshold, .idleOperationTriggeredFunction, .trainLoadAtHighSpeed, .enableIdleOperationThreshold, .loadOperationThreshold, .idleOperationThreshold, .loadOperationTriggeredFunction, .trainLoadAtLowSpeed],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .enableLoadOperationThreshold,
        testType1      : .equal,
        testValue1     : "false",
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.loadOperationTriggeredFunction, .loadOperationThreshold],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .enableIdleOperationThreshold,
        testType1      : .equal,
        testValue1     : "false",
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.idleOperationThreshold, .idleOperationTriggeredFunction],
        actionType     : .setIsHiddenToTestResult
      ),
      
      
      /* *************************************** */
      
      (
        property1      : .physicalOutputOutputMode,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputMode.disabled.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputBrightness, .physicalOutputUseClassLightLogic, .physicalOutputSequencePosition, .physicalOutputPhaseShift, .physicalOutputStartupTime, .physicalOutputLevel, .physicalOutputSmokeUnitControlMode, .physicalOutputSpeed, .physicalOutputAccelerationRate, .physicalOutputDecelerationRate, .physicalOutputHeatWhileLocomotiveStands, .physicalOutputMinimumHeatWhileLocomotiveDriving, .physicalOutputMaximumHeatWhileLocomotiveDriving, .physicalOutputChuffPower, .physicalOutputFanPower, .physicalOutputTimeout, .physicalOutputServoDurationA, .physicalOutputServoDurationB, .physicalOutputServoPositionA, .physicalOutputServoDoNotDisableServoPulseAtPositionA, .physicalOutputServoPositionB, .physicalOutputServoDoNotDisableServoPulseAtPositionB, .physicalOutputCouplerForce, .physicalOutputExternalSmokeUnitType, .physicalOutputGradeCrossing, .physicalOutputRule17Forward, .physicalOutputRule17Reverse, .physicalOutputDimmer, .physicalOutputStartupTimeInfo, .physicalOutputStartupDescription, .physicalOutputLEDMode, .physicalOutputSpecialFunctions, .physicalOutputPantographHeight],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .physicalOutputOutputMode,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputMode.dimmableHeadlight.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputPhaseShift, .physicalOutputStartupTime, .physicalOutputLevel, .physicalOutputSmokeUnitControlMode, .physicalOutputSpeed, .physicalOutputAccelerationRate, .physicalOutputDecelerationRate, .physicalOutputHeatWhileLocomotiveStands, .physicalOutputMinimumHeatWhileLocomotiveDriving, .physicalOutputMaximumHeatWhileLocomotiveDriving, .physicalOutputChuffPower, .physicalOutputFanPower, .physicalOutputTimeout, .physicalOutputServoDurationA, .physicalOutputServoDurationB, .physicalOutputServoPositionA, .physicalOutputServoDoNotDisableServoPulseAtPositionA, .physicalOutputServoPositionB, .physicalOutputServoDoNotDisableServoPulseAtPositionB, .physicalOutputCouplerForce, .physicalOutputExternalSmokeUnitType, .physicalOutputGradeCrossing, .physicalOutputStartupTimeInfo, .physicalOutputStartupDescription, .physicalOutputPantographHeight],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .physicalOutputOutputMode,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputMode.dimmableHeadlightFadeInFadeOut.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputPhaseShift, .physicalOutputStartupTime, .physicalOutputLevel, .physicalOutputSmokeUnitControlMode, .physicalOutputSpeed, .physicalOutputAccelerationRate, .physicalOutputDecelerationRate, .physicalOutputHeatWhileLocomotiveStands, .physicalOutputMinimumHeatWhileLocomotiveDriving, .physicalOutputMaximumHeatWhileLocomotiveDriving, .physicalOutputChuffPower, .physicalOutputFanPower, .physicalOutputTimeout, .physicalOutputServoDurationA, .physicalOutputServoDurationB, .physicalOutputServoPositionA, .physicalOutputServoDoNotDisableServoPulseAtPositionA, .physicalOutputServoPositionB, .physicalOutputServoDoNotDisableServoPulseAtPositionB, .physicalOutputCouplerForce, .physicalOutputExternalSmokeUnitType, .physicalOutputGradeCrossing, .physicalOutputStartupTimeInfo, .physicalOutputStartupDescription, .physicalOutputPantographHeight],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .physicalOutputOutputMode,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputMode.firebox.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputUseClassLightLogic, .physicalOutputSequencePosition, .physicalOutputPhaseShift, .physicalOutputStartupTime, .physicalOutputLevel, .physicalOutputSmokeUnitControlMode, .physicalOutputSpeed, .physicalOutputAccelerationRate, .physicalOutputDecelerationRate, .physicalOutputHeatWhileLocomotiveStands, .physicalOutputMinimumHeatWhileLocomotiveDriving, .physicalOutputMaximumHeatWhileLocomotiveDriving, .physicalOutputChuffPower, .physicalOutputFanPower, .physicalOutputTimeout, .physicalOutputServoDurationA, .physicalOutputServoDurationB, .physicalOutputServoPositionA, .physicalOutputServoDoNotDisableServoPulseAtPositionA, .physicalOutputServoPositionB, .physicalOutputServoDoNotDisableServoPulseAtPositionB, .physicalOutputCouplerForce, .physicalOutputExternalSmokeUnitType, .physicalOutputGradeCrossing, .physicalOutputRule17Forward, .physicalOutputRule17Reverse, .physicalOutputDimmer, .physicalOutputStartupTimeInfo, .physicalOutputStartupDescription, .physicalOutputPantographHeight],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .physicalOutputOutputMode,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputMode.smartFirebox.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputUseClassLightLogic, .physicalOutputSequencePosition, .physicalOutputPhaseShift, .physicalOutputStartupTime, .physicalOutputLevel, .physicalOutputSmokeUnitControlMode, .physicalOutputSpeed, .physicalOutputAccelerationRate, .physicalOutputDecelerationRate, .physicalOutputHeatWhileLocomotiveStands, .physicalOutputMinimumHeatWhileLocomotiveDriving, .physicalOutputMaximumHeatWhileLocomotiveDriving, .physicalOutputChuffPower, .physicalOutputFanPower, .physicalOutputTimeout, .physicalOutputServoDurationA, .physicalOutputServoDurationB, .physicalOutputServoPositionA, .physicalOutputServoDoNotDisableServoPulseAtPositionA, .physicalOutputServoPositionB, .physicalOutputServoDoNotDisableServoPulseAtPositionB, .physicalOutputCouplerForce, .physicalOutputExternalSmokeUnitType, .physicalOutputGradeCrossing, .physicalOutputRule17Forward, .physicalOutputRule17Reverse, .physicalOutputDimmer, .physicalOutputStartupTimeInfo, .physicalOutputStartupDescription, .physicalOutputPantographHeight],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .physicalOutputOutputMode,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputMode.singleStrobe.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputUseClassLightLogic, .physicalOutputSequencePosition, .physicalOutputStartupTime, .physicalOutputLevel, .physicalOutputSmokeUnitControlMode, .physicalOutputSpeed, .physicalOutputAccelerationRate, .physicalOutputDecelerationRate, .physicalOutputHeatWhileLocomotiveStands, .physicalOutputMinimumHeatWhileLocomotiveDriving, .physicalOutputMaximumHeatWhileLocomotiveDriving, .physicalOutputChuffPower, .physicalOutputFanPower, .physicalOutputTimeout, .physicalOutputServoDurationA, .physicalOutputServoDurationB, .physicalOutputServoPositionA, .physicalOutputServoDoNotDisableServoPulseAtPositionA, .physicalOutputServoPositionB, .physicalOutputServoDoNotDisableServoPulseAtPositionB, .physicalOutputCouplerForce, .physicalOutputExternalSmokeUnitType, .physicalOutputRule17Forward, .physicalOutputRule17Reverse, .physicalOutputDimmer, .physicalOutputLEDMode, .physicalOutputStartupTimeInfo, .physicalOutputStartupDescription, .physicalOutputPantographHeight],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .physicalOutputOutputMode,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputMode.doubleStrobe.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputUseClassLightLogic, .physicalOutputSequencePosition, .physicalOutputStartupTime, .physicalOutputLevel, .physicalOutputSmokeUnitControlMode, .physicalOutputSpeed, .physicalOutputAccelerationRate, .physicalOutputDecelerationRate, .physicalOutputHeatWhileLocomotiveStands, .physicalOutputMinimumHeatWhileLocomotiveDriving, .physicalOutputMaximumHeatWhileLocomotiveDriving, .physicalOutputChuffPower, .physicalOutputFanPower, .physicalOutputTimeout, .physicalOutputServoDurationA, .physicalOutputServoDurationB, .physicalOutputServoPositionA, .physicalOutputServoDoNotDisableServoPulseAtPositionA, .physicalOutputServoPositionB, .physicalOutputServoDoNotDisableServoPulseAtPositionB, .physicalOutputCouplerForce, .physicalOutputExternalSmokeUnitType, .physicalOutputRule17Forward, .physicalOutputRule17Reverse, .physicalOutputDimmer, .physicalOutputLEDMode, .physicalOutputStartupTimeInfo, .physicalOutputStartupDescription, .physicalOutputPantographHeight],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .physicalOutputOutputMode,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputMode.rotaryBeacon.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputUseClassLightLogic, .physicalOutputSequencePosition, .physicalOutputStartupTime, .physicalOutputLevel, .physicalOutputSmokeUnitControlMode, .physicalOutputSpeed, .physicalOutputAccelerationRate, .physicalOutputDecelerationRate, .physicalOutputHeatWhileLocomotiveStands, .physicalOutputMinimumHeatWhileLocomotiveDriving, .physicalOutputMaximumHeatWhileLocomotiveDriving, .physicalOutputChuffPower, .physicalOutputFanPower, .physicalOutputTimeout, .physicalOutputServoDurationA, .physicalOutputServoDurationB, .physicalOutputServoPositionA, .physicalOutputServoDoNotDisableServoPulseAtPositionA, .physicalOutputServoPositionB, .physicalOutputServoDoNotDisableServoPulseAtPositionB, .physicalOutputCouplerForce, .physicalOutputExternalSmokeUnitType, .physicalOutputRule17Forward, .physicalOutputRule17Reverse, .physicalOutputDimmer, .physicalOutputStartupTimeInfo, .physicalOutputStartupDescription, .physicalOutputPantographHeight],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .physicalOutputOutputMode,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputMode.stratoLight.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputUseClassLightLogic, .physicalOutputSequencePosition, .physicalOutputStartupTime, .physicalOutputLevel, .physicalOutputSmokeUnitControlMode, .physicalOutputSpeed, .physicalOutputAccelerationRate, .physicalOutputDecelerationRate, .physicalOutputHeatWhileLocomotiveStands, .physicalOutputMinimumHeatWhileLocomotiveDriving, .physicalOutputMaximumHeatWhileLocomotiveDriving, .physicalOutputChuffPower, .physicalOutputFanPower, .physicalOutputTimeout, .physicalOutputServoDurationA, .physicalOutputServoDurationB, .physicalOutputServoPositionA, .physicalOutputServoDoNotDisableServoPulseAtPositionA, .physicalOutputServoPositionB, .physicalOutputServoDoNotDisableServoPulseAtPositionB, .physicalOutputCouplerForce, .physicalOutputExternalSmokeUnitType, .physicalOutputRule17Forward, .physicalOutputRule17Reverse, .physicalOutputDimmer, .physicalOutputStartupTimeInfo, .physicalOutputStartupDescription, .physicalOutputPantographHeight],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .physicalOutputOutputMode,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputMode.ditchLightType1.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputUseClassLightLogic, .physicalOutputSequencePosition, .physicalOutputStartupTime, .physicalOutputLevel, .physicalOutputSmokeUnitControlMode, .physicalOutputSpeed, .physicalOutputAccelerationRate, .physicalOutputDecelerationRate, .physicalOutputHeatWhileLocomotiveStands, .physicalOutputMinimumHeatWhileLocomotiveDriving, .physicalOutputMaximumHeatWhileLocomotiveDriving, .physicalOutputChuffPower, .physicalOutputFanPower, .physicalOutputTimeout, .physicalOutputServoDurationA, .physicalOutputServoDurationB, .physicalOutputServoPositionA, .physicalOutputServoDoNotDisableServoPulseAtPositionA, .physicalOutputServoPositionB, .physicalOutputServoDoNotDisableServoPulseAtPositionB, .physicalOutputCouplerForce, .physicalOutputExternalSmokeUnitType, .physicalOutputRule17Forward, .physicalOutputRule17Reverse, .physicalOutputDimmer, .physicalOutputStartupTimeInfo, .physicalOutputStartupDescription, .physicalOutputPantographHeight],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .physicalOutputOutputMode,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputMode.ditchLightType2.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputUseClassLightLogic, .physicalOutputSequencePosition, .physicalOutputStartupTime, .physicalOutputLevel, .physicalOutputSmokeUnitControlMode, .physicalOutputSpeed, .physicalOutputAccelerationRate, .physicalOutputDecelerationRate, .physicalOutputHeatWhileLocomotiveStands, .physicalOutputMinimumHeatWhileLocomotiveDriving, .physicalOutputMaximumHeatWhileLocomotiveDriving, .physicalOutputChuffPower, .physicalOutputFanPower, .physicalOutputTimeout, .physicalOutputServoDurationA, .physicalOutputServoDurationB, .physicalOutputServoPositionA, .physicalOutputServoDoNotDisableServoPulseAtPositionA, .physicalOutputServoPositionB, .physicalOutputServoDoNotDisableServoPulseAtPositionB, .physicalOutputCouplerForce, .physicalOutputExternalSmokeUnitType, .physicalOutputRule17Forward, .physicalOutputRule17Reverse, .physicalOutputDimmer, .physicalOutputStartupTimeInfo, .physicalOutputStartupDescription, .physicalOutputPantographHeight],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .physicalOutputOutputMode,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputMode.oscillatingHeadlight.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputUseClassLightLogic, .physicalOutputSequencePosition, .physicalOutputStartupTime, .physicalOutputLevel, .physicalOutputSmokeUnitControlMode, .physicalOutputSpeed, .physicalOutputAccelerationRate, .physicalOutputDecelerationRate, .physicalOutputHeatWhileLocomotiveStands, .physicalOutputMinimumHeatWhileLocomotiveDriving, .physicalOutputMaximumHeatWhileLocomotiveDriving, .physicalOutputChuffPower, .physicalOutputFanPower, .physicalOutputTimeout, .physicalOutputServoDurationA, .physicalOutputServoDurationB, .physicalOutputServoPositionA, .physicalOutputServoDoNotDisableServoPulseAtPositionA, .physicalOutputServoPositionB, .physicalOutputServoDoNotDisableServoPulseAtPositionB, .physicalOutputCouplerForce, .physicalOutputExternalSmokeUnitType, .physicalOutputRule17Forward, .physicalOutputRule17Reverse, .physicalOutputDimmer, .physicalOutputStartupTimeInfo, .physicalOutputStartupDescription, .physicalOutputPantographHeight],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .physicalOutputOutputMode,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputMode.flashLight.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputUseClassLightLogic, .physicalOutputSequencePosition, .physicalOutputStartupTime, .physicalOutputLevel, .physicalOutputSmokeUnitControlMode, .physicalOutputSpeed, .physicalOutputAccelerationRate, .physicalOutputDecelerationRate, .physicalOutputHeatWhileLocomotiveStands, .physicalOutputMinimumHeatWhileLocomotiveDriving, .physicalOutputMaximumHeatWhileLocomotiveDriving, .physicalOutputChuffPower, .physicalOutputFanPower, .physicalOutputTimeout, .physicalOutputServoDurationA, .physicalOutputServoDurationB, .physicalOutputServoPositionA, .physicalOutputServoDoNotDisableServoPulseAtPositionA, .physicalOutputServoPositionB, .physicalOutputServoDoNotDisableServoPulseAtPositionB, .physicalOutputCouplerForce, .physicalOutputExternalSmokeUnitType, .physicalOutputRule17Forward, .physicalOutputRule17Reverse, .physicalOutputDimmer, .physicalOutputLEDMode, .physicalOutputStartupTimeInfo, .physicalOutputStartupDescription, .physicalOutputPantographHeight],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .physicalOutputOutputMode,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputMode.marsLight.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputUseClassLightLogic, .physicalOutputSequencePosition, .physicalOutputStartupTime, .physicalOutputLevel, .physicalOutputSmokeUnitControlMode, .physicalOutputSpeed, .physicalOutputAccelerationRate, .physicalOutputDecelerationRate, .physicalOutputHeatWhileLocomotiveStands, .physicalOutputMinimumHeatWhileLocomotiveDriving, .physicalOutputMaximumHeatWhileLocomotiveDriving, .physicalOutputChuffPower, .physicalOutputFanPower, .physicalOutputTimeout, .physicalOutputServoDurationA, .physicalOutputServoDurationB, .physicalOutputServoPositionA, .physicalOutputServoDoNotDisableServoPulseAtPositionA, .physicalOutputServoPositionB, .physicalOutputServoDoNotDisableServoPulseAtPositionB, .physicalOutputCouplerForce, .physicalOutputExternalSmokeUnitType, .physicalOutputRule17Forward, .physicalOutputRule17Reverse, .physicalOutputDimmer, .physicalOutputStartupTimeInfo, .physicalOutputStartupDescription, .physicalOutputPantographHeight],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .physicalOutputOutputMode,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputMode.gyraLight.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputUseClassLightLogic, .physicalOutputSequencePosition, .physicalOutputStartupTime, .physicalOutputLevel, .physicalOutputSmokeUnitControlMode, .physicalOutputSpeed, .physicalOutputAccelerationRate, .physicalOutputDecelerationRate, .physicalOutputHeatWhileLocomotiveStands, .physicalOutputMinimumHeatWhileLocomotiveDriving, .physicalOutputMaximumHeatWhileLocomotiveDriving, .physicalOutputChuffPower, .physicalOutputFanPower, .physicalOutputTimeout, .physicalOutputServoDurationA, .physicalOutputServoDurationB, .physicalOutputServoPositionA, .physicalOutputServoDoNotDisableServoPulseAtPositionA, .physicalOutputServoPositionB, .physicalOutputServoDoNotDisableServoPulseAtPositionB, .physicalOutputCouplerForce, .physicalOutputExternalSmokeUnitType, .physicalOutputRule17Forward, .physicalOutputRule17Reverse, .physicalOutputDimmer, .physicalOutputStartupTimeInfo, .physicalOutputStartupDescription, .physicalOutputPantographHeight],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .physicalOutputOutputMode,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputMode.endOfTrainFlasher.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputUseClassLightLogic, .physicalOutputSequencePosition, .physicalOutputStartupTime, .physicalOutputLevel, .physicalOutputSmokeUnitControlMode, .physicalOutputSpeed, .physicalOutputAccelerationRate, .physicalOutputDecelerationRate, .physicalOutputHeatWhileLocomotiveStands, .physicalOutputMinimumHeatWhileLocomotiveDriving, .physicalOutputMaximumHeatWhileLocomotiveDriving, .physicalOutputChuffPower, .physicalOutputFanPower, .physicalOutputTimeout, .physicalOutputServoDurationA, .physicalOutputServoDurationB, .physicalOutputServoPositionA, .physicalOutputServoDoNotDisableServoPulseAtPositionA, .physicalOutputServoPositionB, .physicalOutputServoDoNotDisableServoPulseAtPositionB, .physicalOutputCouplerForce, .physicalOutputExternalSmokeUnitType, .physicalOutputRule17Forward, .physicalOutputRule17Reverse, .physicalOutputDimmer, .physicalOutputStartupTimeInfo, .physicalOutputStartupDescription, .physicalOutputPantographHeight],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .physicalOutputOutputMode,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputMode.neonLight.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputUseClassLightLogic, .physicalOutputSequencePosition, .physicalOutputPhaseShift, .physicalOutputLevel, .physicalOutputSmokeUnitControlMode, .physicalOutputSpeed, .physicalOutputAccelerationRate, .physicalOutputDecelerationRate, .physicalOutputHeatWhileLocomotiveStands, .physicalOutputMinimumHeatWhileLocomotiveDriving, .physicalOutputMaximumHeatWhileLocomotiveDriving, .physicalOutputChuffPower, .physicalOutputFanPower, .physicalOutputTimeout, .physicalOutputServoDurationA, .physicalOutputServoDurationB, .physicalOutputServoPositionA, .physicalOutputServoDoNotDisableServoPulseAtPositionA, .physicalOutputServoPositionB, .physicalOutputServoDoNotDisableServoPulseAtPositionB, .physicalOutputCouplerForce, .physicalOutputExternalSmokeUnitType, .physicalOutputGradeCrossing, .physicalOutputRule17Forward, .physicalOutputRule17Reverse, .physicalOutputDimmer, .physicalOutputStartupTimeInfo, .physicalOutputLEDMode, .physicalOutputSpecialFunctions, .physicalOutputPantographHeight],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .physicalOutputOutputMode,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputMode.lowEnergyLight.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputUseClassLightLogic, .physicalOutputSequencePosition, .physicalOutputPhaseShift, .physicalOutputLevel, .physicalOutputSmokeUnitControlMode, .physicalOutputSpeed, .physicalOutputAccelerationRate, .physicalOutputDecelerationRate, .physicalOutputHeatWhileLocomotiveStands, .physicalOutputMinimumHeatWhileLocomotiveDriving, .physicalOutputMaximumHeatWhileLocomotiveDriving, .physicalOutputChuffPower, .physicalOutputFanPower, .physicalOutputTimeout, .physicalOutputServoDurationA, .physicalOutputServoDurationB, .physicalOutputServoPositionA, .physicalOutputServoDoNotDisableServoPulseAtPositionA, .physicalOutputServoPositionB, .physicalOutputServoDoNotDisableServoPulseAtPositionB, .physicalOutputCouplerForce, .physicalOutputExternalSmokeUnitType, .physicalOutputGradeCrossing, .physicalOutputRule17Forward, .physicalOutputRule17Reverse, .physicalOutputDimmer, .physicalOutputLEDMode, .physicalOutputStartupTimeInfo, .physicalOutputSpecialFunctions, .physicalOutputPantographHeight],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .physicalOutputOutputMode,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputMode.singleStrobeRandom.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputUseClassLightLogic, .physicalOutputSequencePosition, .physicalOutputPhaseShift, .physicalOutputStartupTime, .physicalOutputLevel, .physicalOutputSmokeUnitControlMode, .physicalOutputSpeed, .physicalOutputAccelerationRate, .physicalOutputDecelerationRate, .physicalOutputHeatWhileLocomotiveStands, .physicalOutputMinimumHeatWhileLocomotiveDriving, .physicalOutputMaximumHeatWhileLocomotiveDriving, .physicalOutputChuffPower, .physicalOutputFanPower, .physicalOutputTimeout, .physicalOutputServoDurationA, .physicalOutputServoDurationB, .physicalOutputServoPositionA, .physicalOutputServoDoNotDisableServoPulseAtPositionA, .physicalOutputServoPositionB, .physicalOutputServoDoNotDisableServoPulseAtPositionB, .physicalOutputCouplerForce, .physicalOutputExternalSmokeUnitType, .physicalOutputGradeCrossing, .physicalOutputRule17Forward, .physicalOutputRule17Reverse, .physicalOutputDimmer, .physicalOutputLEDMode, .physicalOutputStartupTimeInfo, .physicalOutputStartupDescription, .physicalOutputSpecialFunctions, .physicalOutputPantographHeight],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .physicalOutputOutputMode,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputMode.brakeLight.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputUseClassLightLogic, .physicalOutputSequencePosition, .physicalOutputPhaseShift, .physicalOutputStartupTime, .physicalOutputSmokeUnitControlMode, .physicalOutputSpeed, .physicalOutputAccelerationRate, .physicalOutputDecelerationRate, .physicalOutputHeatWhileLocomotiveStands, .physicalOutputMinimumHeatWhileLocomotiveDriving, .physicalOutputMaximumHeatWhileLocomotiveDriving, .physicalOutputChuffPower, .physicalOutputFanPower, .physicalOutputTimeout, .physicalOutputServoDurationA, .physicalOutputServoDurationB, .physicalOutputServoPositionA, .physicalOutputServoDoNotDisableServoPulseAtPositionA, .physicalOutputServoPositionB, .physicalOutputServoDoNotDisableServoPulseAtPositionB, .physicalOutputCouplerForce, .physicalOutputExternalSmokeUnitType, .physicalOutputGradeCrossing, .physicalOutputRule17Forward, .physicalOutputRule17Reverse, .physicalOutputDimmer, .physicalOutputLEDMode, .physicalOutputStartupTimeInfo, .physicalOutputStartupDescription, .physicalOutputSpecialFunctions, .physicalOutputPantographHeight],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .physicalOutputOutputMode,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputMode.sixteenTwoThirdsHzFlickering.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputUseClassLightLogic, .physicalOutputSequencePosition, .physicalOutputPhaseShift, .physicalOutputStartupTime, .physicalOutputLevel, .physicalOutputSmokeUnitControlMode, .physicalOutputSpeed, .physicalOutputAccelerationRate, .physicalOutputDecelerationRate, .physicalOutputHeatWhileLocomotiveStands, .physicalOutputMinimumHeatWhileLocomotiveDriving, .physicalOutputMaximumHeatWhileLocomotiveDriving, .physicalOutputChuffPower, .physicalOutputFanPower, .physicalOutputTimeout, .physicalOutputServoDurationA, .physicalOutputServoDurationB, .physicalOutputServoPositionA, .physicalOutputServoDoNotDisableServoPulseAtPositionA, .physicalOutputServoPositionB, .physicalOutputServoDoNotDisableServoPulseAtPositionB, .physicalOutputCouplerForce, .physicalOutputExternalSmokeUnitType, .physicalOutputGradeCrossing, .physicalOutputRule17Forward, .physicalOutputRule17Reverse, .physicalOutputDimmer, .physicalOutputLEDMode, .physicalOutputStartupTimeInfo, .physicalOutputStartupDescription, .physicalOutputSpecialFunctions, .physicalOutputPantographHeight],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .physicalOutputOutputMode,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputMode.esuCoupler.title(decoder: self),
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputBrightness, .physicalOutputUseClassLightLogic, .physicalOutputSequencePosition, .physicalOutputPhaseShift, .physicalOutputStartupTime, .physicalOutputLevel, .physicalOutputSmokeUnitControlMode, .physicalOutputSpeed, .physicalOutputAccelerationRate, .physicalOutputDecelerationRate, .physicalOutputHeatWhileLocomotiveStands, .physicalOutputMinimumHeatWhileLocomotiveDriving, .physicalOutputMaximumHeatWhileLocomotiveDriving, .physicalOutputChuffPower, .physicalOutputFanPower, .physicalOutputTimeout, .physicalOutputServoDurationA, .physicalOutputServoDurationB, .physicalOutputServoPositionA, .physicalOutputServoDoNotDisableServoPulseAtPositionA, .physicalOutputServoPositionB, .physicalOutputServoDoNotDisableServoPulseAtPositionB, .physicalOutputCouplerForce, .physicalOutputExternalSmokeUnitType, .physicalOutputGradeCrossing, .physicalOutputRule17Forward, .physicalOutputRule17Reverse, .physicalOutputDimmer, .physicalOutputLEDMode, .physicalOutputStartupTimeInfo, .physicalOutputStartupDescription, .physicalOutputSpecialFunctions, .physicalOutputPantographHeight],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .physicalOutputOutputMode,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputMode.smokeUnitControlledBySound.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputBrightness, .physicalOutputUseClassLightLogic, .physicalOutputSequencePosition, .physicalOutputPhaseShift, .physicalOutputStartupTime, .physicalOutputLevel, .physicalOutputSpeed, .physicalOutputAccelerationRate, .physicalOutputDecelerationRate, .physicalOutputHeatWhileLocomotiveStands, .physicalOutputMinimumHeatWhileLocomotiveDriving, .physicalOutputMaximumHeatWhileLocomotiveDriving, .physicalOutputChuffPower, .physicalOutputFanPower, .physicalOutputTimeout, .physicalOutputServoDurationA, .physicalOutputServoDurationB, .physicalOutputServoPositionA, .physicalOutputServoDoNotDisableServoPulseAtPositionA, .physicalOutputServoPositionB, .physicalOutputServoDoNotDisableServoPulseAtPositionB, .physicalOutputCouplerForce, .physicalOutputExternalSmokeUnitType, .physicalOutputGradeCrossing, .physicalOutputRule17Forward, .physicalOutputRule17Reverse, .physicalOutputDimmer, .physicalOutputLEDMode, .physicalOutputStartupTimeInfo, .physicalOutputStartupDescription, .physicalOutputSpecialFunctions, .physicalOutputPantographHeight],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .physicalOutputOutputMode,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputMode.ventilator.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputBrightness, .physicalOutputUseClassLightLogic, .physicalOutputSequencePosition, .physicalOutputPhaseShift, .physicalOutputStartupTime, .physicalOutputLevel, .physicalOutputSmokeUnitControlMode, .physicalOutputHeatWhileLocomotiveStands, .physicalOutputMinimumHeatWhileLocomotiveDriving, .physicalOutputMaximumHeatWhileLocomotiveDriving, .physicalOutputChuffPower, .physicalOutputFanPower, .physicalOutputTimeout, .physicalOutputServoDurationA, .physicalOutputServoDurationB, .physicalOutputServoPositionA, .physicalOutputServoDoNotDisableServoPulseAtPositionA, .physicalOutputServoPositionB, .physicalOutputServoDoNotDisableServoPulseAtPositionB, .physicalOutputCouplerForce, .physicalOutputExternalSmokeUnitType, .physicalOutputGradeCrossing, .physicalOutputRule17Forward, .physicalOutputRule17Reverse, .physicalOutputDimmer, .physicalOutputLEDMode, .physicalOutputStartupTimeInfo, .physicalOutputStartupDescription, .physicalOutputSpecialFunctions, .physicalOutputPantographHeight],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .physicalOutputOutputMode,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputMode.seutheSmokeUnit.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputBrightness, .physicalOutputUseClassLightLogic, .physicalOutputSequencePosition, .physicalOutputPhaseShift, .physicalOutputStartupTime, .physicalOutputLevel, .physicalOutputSmokeUnitControlMode, .physicalOutputSpeed, .physicalOutputAccelerationRate, .physicalOutputDecelerationRate, .physicalOutputChuffPower, .physicalOutputFanPower, .physicalOutputTimeout, .physicalOutputServoDurationA, .physicalOutputServoDurationB, .physicalOutputServoPositionA, .physicalOutputServoDoNotDisableServoPulseAtPositionA, .physicalOutputServoPositionB, .physicalOutputServoDoNotDisableServoPulseAtPositionB, .physicalOutputCouplerForce, .physicalOutputExternalSmokeUnitType, .physicalOutputGradeCrossing, .physicalOutputRule17Forward, .physicalOutputRule17Reverse, .physicalOutputDimmer, .physicalOutputLEDMode, .physicalOutputStartupTimeInfo, .physicalOutputStartupDescription, .physicalOutputSpecialFunctions, .physicalOutputPantographHeight],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .physicalOutputOutputMode,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputMode.triggerSmokeChuff.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputBrightness, .physicalOutputUseClassLightLogic, .physicalOutputSequencePosition, .physicalOutputPhaseShift, .physicalOutputStartupTime, .physicalOutputLevel, .physicalOutputSmokeUnitControlMode, .physicalOutputSpeed, .physicalOutputAccelerationRate, .physicalOutputDecelerationRate, .physicalOutputHeatWhileLocomotiveStands, .physicalOutputMinimumHeatWhileLocomotiveDriving, .physicalOutputMaximumHeatWhileLocomotiveDriving, .physicalOutputServoDurationA, .physicalOutputServoDurationB, .physicalOutputServoPositionA, .physicalOutputServoDoNotDisableServoPulseAtPositionA, .physicalOutputServoPositionB, .physicalOutputServoDoNotDisableServoPulseAtPositionB, .physicalOutputCouplerForce, .physicalOutputExternalSmokeUnitType, .physicalOutputGradeCrossing, .physicalOutputRule17Forward, .physicalOutputRule17Reverse, .physicalOutputDimmer, .physicalOutputLEDMode, .physicalOutputStartupTimeInfo, .physicalOutputStartupDescription, .physicalOutputSpecialFunctions, .physicalOutputPantographHeight],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .physicalOutputOutputMode,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputMode.externalControlledSmokeUnit.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputBrightness, .physicalOutputUseClassLightLogic, .physicalOutputSequencePosition, .physicalOutputPhaseShift, .physicalOutputStartupTime, .physicalOutputLevel, .physicalOutputSmokeUnitControlMode, .physicalOutputSpeed, .physicalOutputAccelerationRate, .physicalOutputDecelerationRate, .physicalOutputHeatWhileLocomotiveStands, .physicalOutputMinimumHeatWhileLocomotiveDriving, .physicalOutputMaximumHeatWhileLocomotiveDriving, .physicalOutputChuffPower, .physicalOutputFanPower, .physicalOutputTimeout, .physicalOutputServoDurationA, .physicalOutputServoDurationB, .physicalOutputServoPositionA, .physicalOutputServoDoNotDisableServoPulseAtPositionA, .physicalOutputServoPositionB, .physicalOutputServoDoNotDisableServoPulseAtPositionB, .physicalOutputCouplerForce, .physicalOutputGradeCrossing, .physicalOutputRule17Forward, .physicalOutputRule17Reverse, .physicalOutputDimmer, .physicalOutputLEDMode, .physicalOutputStartupTimeInfo, .physicalOutputStartupDescription, .physicalOutputSpecialFunctions, .physicalOutputPantographHeight],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .physicalOutputOutputMode,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputMode.servoOutput.title(decoder: self),
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputBrightness, .physicalOutputUseClassLightLogic, .physicalOutputSequencePosition, .physicalOutputPhaseShift, .physicalOutputStartupTime, .physicalOutputLevel, .physicalOutputSmokeUnitControlMode, .physicalOutputSpeed, .physicalOutputAccelerationRate, .physicalOutputDecelerationRate, .physicalOutputHeatWhileLocomotiveStands, .physicalOutputMinimumHeatWhileLocomotiveDriving, .physicalOutputMaximumHeatWhileLocomotiveDriving, .physicalOutputChuffPower, .physicalOutputFanPower, .physicalOutputTimeout, .physicalOutputCouplerForce, .physicalOutputExternalSmokeUnitType, .physicalOutputGradeCrossing, .physicalOutputRule17Forward, .physicalOutputRule17Reverse, .physicalOutputDimmer, .physicalOutputLEDMode, .physicalOutputStartupTimeInfo, .physicalOutputStartupDescription, .physicalOutputSpecialFunctions, .physicalOutputPantographHeight],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .physicalOutputOutputMode,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputMode.coupler.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputBrightness, .physicalOutputUseClassLightLogic, .physicalOutputSequencePosition, .physicalOutputPhaseShift, .physicalOutputStartupTime, .physicalOutputLevel, .physicalOutputSmokeUnitControlMode, .physicalOutputSpeed, .physicalOutputAccelerationRate, .physicalOutputDecelerationRate, .physicalOutputHeatWhileLocomotiveStands, .physicalOutputMinimumHeatWhileLocomotiveDriving, .physicalOutputMaximumHeatWhileLocomotiveDriving, .physicalOutputChuffPower, .physicalOutputFanPower, .physicalOutputTimeout, .physicalOutputServoDurationA, .physicalOutputServoDurationB, .physicalOutputServoPositionA, .physicalOutputServoDoNotDisableServoPulseAtPositionA, .physicalOutputServoPositionB, .physicalOutputServoDoNotDisableServoPulseAtPositionB, .physicalOutputExternalSmokeUnitType, .physicalOutputGradeCrossing, .physicalOutputRule17Forward, .physicalOutputRule17Reverse, .physicalOutputDimmer, .physicalOutputLEDMode, .physicalOutputStartupTimeInfo, .physicalOutputStartupDescription, .physicalOutputSpecialFunctions, .physicalOutputPantographHeight],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .physicalOutputOutputMode,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputMode.rocoCoupler.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputBrightness, .physicalOutputUseClassLightLogic, .physicalOutputSequencePosition, .physicalOutputPhaseShift, .physicalOutputStartupTime, .physicalOutputLevel, .physicalOutputSmokeUnitControlMode, .physicalOutputSpeed, .physicalOutputAccelerationRate, .physicalOutputDecelerationRate, .physicalOutputHeatWhileLocomotiveStands, .physicalOutputMinimumHeatWhileLocomotiveDriving, .physicalOutputMaximumHeatWhileLocomotiveDriving, .physicalOutputChuffPower, .physicalOutputFanPower, .physicalOutputTimeout, .physicalOutputServoDurationA, .physicalOutputServoDurationB, .physicalOutputServoPositionA, .physicalOutputServoDoNotDisableServoPulseAtPositionA, .physicalOutputServoPositionB, .physicalOutputServoDoNotDisableServoPulseAtPositionB, .physicalOutputCouplerForce, .physicalOutputExternalSmokeUnitType, .physicalOutputGradeCrossing, .physicalOutputRule17Forward, .physicalOutputRule17Reverse, .physicalOutputDimmer, .physicalOutputLEDMode, .physicalOutputStartupTimeInfo, .physicalOutputStartupDescription, .physicalOutputSpecialFunctions, .physicalOutputPantographHeight],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .physicalOutputOutputMode,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputMode.pantograph.title(decoder: self),
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputBrightness, .physicalOutputUseClassLightLogic, .physicalOutputSequencePosition, .physicalOutputPhaseShift, .physicalOutputStartupTime, .physicalOutputLevel, .physicalOutputSmokeUnitControlMode, .physicalOutputSpeed, .physicalOutputAccelerationRate, .physicalOutputDecelerationRate, .physicalOutputHeatWhileLocomotiveStands, .physicalOutputMinimumHeatWhileLocomotiveDriving, .physicalOutputMaximumHeatWhileLocomotiveDriving, .physicalOutputChuffPower, .physicalOutputFanPower, .physicalOutputTimeout, .physicalOutputServoDurationA, .physicalOutputServoDurationB, .physicalOutputServoPositionA, .physicalOutputServoDoNotDisableServoPulseAtPositionA, .physicalOutputServoPositionB, .physicalOutputServoDoNotDisableServoPulseAtPositionB, .physicalOutputCouplerForce, .physicalOutputExternalSmokeUnitType, .physicalOutputGradeCrossing, .physicalOutputRule17Forward, .physicalOutputRule17Reverse, .physicalOutputDimmer, .physicalOutputLEDMode, .physicalOutputStartupTimeInfo, .physicalOutputStartupDescription, .physicalOutputSpecialFunctions],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .physicalOutputOutputMode,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputMode.powerPackControl.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputBrightness, .physicalOutputUseClassLightLogic, .physicalOutputSequencePosition, .physicalOutputPhaseShift, .physicalOutputStartupTime, .physicalOutputLevel, .physicalOutputSmokeUnitControlMode, .physicalOutputSpeed, .physicalOutputAccelerationRate, .physicalOutputDecelerationRate, .physicalOutputHeatWhileLocomotiveStands, .physicalOutputMinimumHeatWhileLocomotiveDriving, .physicalOutputMaximumHeatWhileLocomotiveDriving, .physicalOutputChuffPower, .physicalOutputFanPower, .physicalOutputTimeout, .physicalOutputServoDurationA, .physicalOutputServoDurationB, .physicalOutputServoPositionA, .physicalOutputServoDoNotDisableServoPulseAtPositionA, .physicalOutputServoPositionB, .physicalOutputServoDoNotDisableServoPulseAtPositionB, .physicalOutputCouplerForce, .physicalOutputExternalSmokeUnitType, .physicalOutputGradeCrossing, .physicalOutputRule17Forward, .physicalOutputRule17Reverse, .physicalOutputDimmer, .physicalOutputLEDMode, .physicalOutputStartupTimeInfo, .physicalOutputStartupDescription, .physicalOutputSpecialFunctions, .physicalOutputPantographHeight],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .physicalOutputOutputMode,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputMode.servoPower.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputBrightness, .physicalOutputUseClassLightLogic, .physicalOutputSequencePosition, .physicalOutputPhaseShift, .physicalOutputStartupTime, .physicalOutputLevel, .physicalOutputSmokeUnitControlMode, .physicalOutputSpeed, .physicalOutputAccelerationRate, .physicalOutputDecelerationRate, .physicalOutputHeatWhileLocomotiveStands, .physicalOutputMinimumHeatWhileLocomotiveDriving, .physicalOutputMaximumHeatWhileLocomotiveDriving, .physicalOutputChuffPower, .physicalOutputFanPower, .physicalOutputTimeout, .physicalOutputServoDurationA, .physicalOutputServoDurationB, .physicalOutputServoPositionA, .physicalOutputServoDoNotDisableServoPulseAtPositionA, .physicalOutputServoPositionB, .physicalOutputServoDoNotDisableServoPulseAtPositionB, .physicalOutputCouplerForce, .physicalOutputExternalSmokeUnitType, .physicalOutputGradeCrossing, .physicalOutputRule17Forward, .physicalOutputRule17Reverse, .physicalOutputDimmer, .physicalOutputLEDMode, .physicalOutputStartupTimeInfo, .physicalOutputStartupDescription, .physicalOutputSpecialFunctions, .physicalOutputPantographHeight],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .physicalOutputOutputMode,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputMode.autoCoupleCoil2.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputBrightness, .physicalOutputUseClassLightLogic, .physicalOutputSequencePosition, .physicalOutputPhaseShift, .physicalOutputStartupTime, .physicalOutputLevel, .physicalOutputSmokeUnitControlMode, .physicalOutputSpeed, .physicalOutputAccelerationRate, .physicalOutputDecelerationRate, .physicalOutputHeatWhileLocomotiveStands, .physicalOutputMinimumHeatWhileLocomotiveDriving, .physicalOutputMaximumHeatWhileLocomotiveDriving, .physicalOutputChuffPower, .physicalOutputFanPower, .physicalOutputTimeout, .physicalOutputServoDurationA, .physicalOutputServoDurationB, .physicalOutputServoPositionA, .physicalOutputServoDoNotDisableServoPulseAtPositionA, .physicalOutputServoPositionB, .physicalOutputServoDoNotDisableServoPulseAtPositionB, .physicalOutputExternalSmokeUnitType, .physicalOutputGradeCrossing, .physicalOutputRule17Forward, .physicalOutputRule17Reverse, .physicalOutputDimmer, .physicalOutputLEDMode, .physicalOutputStartupTimeInfo, .physicalOutputStartupDescription, .physicalOutputSpecialFunctions, .physicalOutputPantographHeight],
        actionType     : .setIsHiddenToTestResult
      ),
      (
        property1      : .physicalOutputOutputMode,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputMode.servoOutputSteamEngineJohnsonBarControl.title(decoder: self),
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputBrightness, .physicalOutputUseClassLightLogic, .physicalOutputSequencePosition, .physicalOutputPhaseShift, .physicalOutputStartupTime, .physicalOutputLevel, .physicalOutputSmokeUnitControlMode, .physicalOutputSpeed, .physicalOutputAccelerationRate, .physicalOutputDecelerationRate, .physicalOutputHeatWhileLocomotiveStands, .physicalOutputMinimumHeatWhileLocomotiveDriving, .physicalOutputMaximumHeatWhileLocomotiveDriving, .physicalOutputChuffPower, .physicalOutputFanPower, .physicalOutputTimeout, .physicalOutputServoDoNotDisableServoPulseAtPositionA, .physicalOutputServoDoNotDisableServoPulseAtPositionB, .physicalOutputCouplerForce, .physicalOutputExternalSmokeUnitType, .physicalOutputGradeCrossing, .physicalOutputRule17Forward, .physicalOutputRule17Reverse, .physicalOutputDimmer, .physicalOutputLEDMode, .physicalOutputStartupTimeInfo, .physicalOutputStartupDescription, .physicalOutputSpecialFunctions, .physicalOutputPantographHeight],
        actionType     : .setIsHiddenToTestResult
      ),

    ]
    
    layoutRuleLookupTestProperties.removeAll()
    layoutRuleLookupActionProperties.removeAll()
    
    if let _layoutRules {
      
      for rule in _layoutRules {
        
        var rules : [PTSettingsPropertyLayoutRule] = []
        
        if let temp = layoutRuleLookupTestProperties[rule.property1] {
          rules.append(contentsOf: temp)
        }
        
        rules.append(rule)
        
        layoutRuleLookupTestProperties[rule.property1] = rules
        
        if let property2 = rule.property2 {
          
          var rules : [PTSettingsPropertyLayoutRule] = []
          
          if let temp = layoutRuleLookupTestProperties[property2] {
            rules.append(contentsOf: temp)
          }
          
          rules.append(rule)
          
          layoutRuleLookupTestProperties[property2] = rules

        }

        for actionProperty in rule.actionProperty {
          
          rules = []
          
          if let temp = layoutRuleLookupActionProperties[actionProperty] {
            rules.append(contentsOf: temp)
          }
          
          rules.append(rule)
          
          layoutRuleLookupActionProperties[actionProperty] = rules
        }
        
      }
      
    }
    
  }

}
