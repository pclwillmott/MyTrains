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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
      ),
      (
        property1      : .enableStartingDelayIfVirtualDriveSoundEnabledCV128,
        testType1      : .equal,
        testValue1     : "false",
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.startingDelayIfVirtualDriveSoundEnabledCV128],
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
      ),
      (
        property1      : .enableRailComFeedback,
        testType1      : .equal,
        testValue1     : "false",
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.sendAddressViaBroadcastOnChannel1, .sendFollowingToCommandStation, .enableRailComPlusAutomaticAnnouncement, .allowDataTransmissionOnChannel2, .allowCommandConfirmationOnChannel1],
        actionType     : .setIsHiddenToTestResult,
        capability     : []
      ),
      (
        property1      : .detectSpeedStepModeAutomatically,
        testType1      : .equal,
        testValue1     : "true",
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.speedStepMode],
        actionType     : .setIsHiddenToTestResult,
        capability     : [.detectSpeedStepAutomatically]
      ),
      (
        property1      : .enableAcceleration,
        testType1      : .equal,
        testValue1     : "false",
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.accelerationAdjustmentA, .accelerationRate, .accelerationRateBasic, .accelerationAdjustmentB, .accelerationRateESU, .accelerationRateLok3, .accelerationRateBasic],
        actionType     : .setIsHiddenToTestResult,
        capability     : []
      ),
      (
        property1      : .enableDeceleration,
        testType1      : .equal,
        testValue1     : "false",
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.decelerationRate, .decelerationAdjustmentA, .decelerationRateBasic, .decelerationAdjustmentB, .decelerationRateESU, .decelerationRateLok3, .decelerationRateBasic],
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
      ),
      (
        property1      : .enableStartingDelayIfVirtualDriveSoundEnabledCV253,
        testType1      : .equal,
        testValue1     : "false",
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.startingDelayIfVirtualDriveSoundEnabledCV253],
        actionType     : .setIsHiddenToTestResult,
        capability     : [.noSound]
      ),
      (
        property1      : .enableStartingDelayIfVirtualDriveSoundEnabledCV252,
        testType1      : .equal,
        testValue1     : "false",
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.startingDelayIfVirtualDriveSoundEnabledCV252],
        actionType     : .setIsHiddenToTestResult,
        capability     : [.noSound, .lok3]
      ),
      (
        property1      : .enableStartingDelayIfVirtualDriveSoundEnabledCV221,
        testType1      : .equal,
        testValue1     : "false",
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.startingDelayIfVirtualDriveSoundEnabledCV221],
        actionType     : .setIsHiddenToTestResult,
        capability     : [.noSound, .lok3]
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
        actionType     : .setIsHiddenToTestResult,
        capability     : [.digitalWheelSensorDisablesAUX10]
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
        actionType     : .setIsHiddenToTestResult,
        capability     : [.digitalWheelSensorDisablesAUX10]
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
        actionType     : .setIsHiddenToTestResult,
        capability     : [.susiMasterDisablesAUX11]
      ),
      (
        property1      : .enableSimpleSUSI,
        testType1      : .equal,
        testValue1     : "false",
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.timeToBridgePowerInterruptionWarning],
        actionType     : .setIsHiddenToTestResult,
        capability     : [.lok4]
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
        actionType     : .setIsHiddenToTestResult,
        capability     : [.susiMasterDisablesAUX12]
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
        actionType     : .setIsHiddenToTestResult,
        capability     : [.susiMasterDisablesAUX11]
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
        actionType     : .setIsHiddenToTestResult,
        capability     : [.susiMasterDisablesAUX12]
      ),
      (
        property1      : .physicalOutput,
        testType1      : .equal,
        testValue1     : ESUDecoderPhysicalOutput.aux3.title,
        operator       : .and,
        property2      : .enableSUSIMaster,
        testType2      : .equal,
        testValue2     : "true",
        actionProperty : [.physicalOutputChuffPower, .physicalOutputTimeUntilAutomaticPowerOff, .physicalOutputPowerOnDelay, .physicalOutputBrightness, .physicalOutputMaximumHeatWhileLocomotiveDriving, .physicalOutputSmokeUnitControlMode, .physicalOutputAccelerationRate, .physicalOutputServoPositionA, .physicalOutputServoDurationB, .physicalOutputPhaseShift, .physicalOutputSpeed, .physicalOutputLEDMode, .physicalOutputEnableFunctionTimeout, .physicalOutputExternalSmokeUnitType, .physicalOutputGradeCrossing, .physicalOutputTimeout, .physicalOutputMinimumHeatWhileLocomotiveDriving, .physicalOutputSpecialFunctions, .physicalOutputStartupTimeInfo, .physicalOutputRule17Forward, .physicalOutputLevel, .physicalOutputServoDurationA, .physicalOutputStartupDescription, .physicalOutputCouplerForce, .physicalOutputServoDoNotDisableServoPulseAtPositionA, .physicalOutputDecelerationRate, .physicalOutputOutputMode, .physicalOutputSequencePosition, .physicalOutputServoDoNotDisableServoPulseAtPositionB, .physicalOutputUseClassLightLogic, .physicalOutputRule17Reverse, .physicalOutputPowerOffDelay, .physicalOutputStartupTime, .physicalOutputFanPower, .physicalOutputHeatWhileLocomotiveStands, .physicalOutputDimmer, .physicalOutputServoPositionB, .physicalOutputPantographHeight],
        actionType     : .setIsHiddenToTestResult,
        capability     : [.susiMasterDisablesAUX3]
      ),
      (
        property1      : .physicalOutput,
        testType1      : .equal,
        testValue1     : ESUDecoderPhysicalOutput.aux4.title,
        operator       : .and,
        property2      : .enableSUSIMaster,
        testType2      : .equal,
        testValue2     : "true",
        actionProperty : [.physicalOutputChuffPower, .physicalOutputTimeUntilAutomaticPowerOff, .physicalOutputPowerOnDelay, .physicalOutputBrightness, .physicalOutputMaximumHeatWhileLocomotiveDriving, .physicalOutputSmokeUnitControlMode, .physicalOutputAccelerationRate, .physicalOutputServoPositionA, .physicalOutputServoDurationB, .physicalOutputPhaseShift, .physicalOutputSpeed, .physicalOutputLEDMode, .physicalOutputEnableFunctionTimeout, .physicalOutputExternalSmokeUnitType, .physicalOutputGradeCrossing, .physicalOutputTimeout, .physicalOutputMinimumHeatWhileLocomotiveDriving, .physicalOutputSpecialFunctions, .physicalOutputStartupTimeInfo, .physicalOutputRule17Forward, .physicalOutputLevel, .physicalOutputServoDurationA, .physicalOutputStartupDescription, .physicalOutputCouplerForce, .physicalOutputServoDoNotDisableServoPulseAtPositionA, .physicalOutputDecelerationRate, .physicalOutputOutputMode, .physicalOutputSequencePosition, .physicalOutputServoDoNotDisableServoPulseAtPositionB, .physicalOutputUseClassLightLogic, .physicalOutputRule17Reverse, .physicalOutputPowerOffDelay, .physicalOutputStartupTime, .physicalOutputFanPower, .physicalOutputHeatWhileLocomotiveStands, .physicalOutputDimmer, .physicalOutputServoPositionB, .physicalOutputPantographHeight],
        actionType     : .setIsHiddenToTestResult,
        capability     : [.susiMasterDisablesAUX4]
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
      ),
      (
        property1      : .enableSUSIMaster,
        testType1      : .equal,
        testValue1     : "false",
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.susiWarning, .physicalOutputAUX11Warning, .physicalOutputAUX12Warning, .physicalOutputAUX3Warning, .physicalOutputAUX4Warning, .susiWarningAux3Aux4],
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
      ),
      (
        property1      : .physicalOutput,
        testType1      : .notEqual,
        testValue1     : ESUDecoderPhysicalOutput.aux3.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputAUX3Warning],
        actionType     : .setIsHiddenToTestResult,
        capability     : []
      ),
      (
        property1      : .physicalOutput,
        testType1      : .notEqual,
        testValue1     : ESUDecoderPhysicalOutput.aux4.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputAUX4Warning],
        actionType     : .setIsHiddenToTestResult,
        capability     : []
      ),
      (
        property1      : .esuSoundType,
        testType1      : .equal,
        testValue1     : ESUSoundType.dieselHydraulical.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.esuDistanceOfGearSteps, .esuDistanceofSteamChuffsAtSpeedStep2, .esuDistanceOfSteamChuffsAtSpeedStep1, .esuTriggerImpulses],
        actionType     : .setIsHiddenToTestResult,
        capability     : [.lok3]
      ),
      (
        property1      : .esuSoundType,
        testType1      : .equal,
        testValue1     : ESUSoundType.dieselMechanical.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.esuDistanceOfGearSteps, .esuDistanceofSteamChuffsAtSpeedStep2, .esuDistanceOfSteamChuffsAtSpeedStep1, .esuTriggerImpulses],
        actionType     : .setIsHiddenToTestResult,
        capability     : [.lok3]
      ),
      (
        property1      : .esuSoundType,
        testType1      : .equal,
        testValue1     : ESUSoundType.electricOrDieselElectric.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.esuDistanceofSteamChuffsAtSpeedStep2, .esuDistanceOfSteamChuffsAtSpeedStep1, .esuTriggerImpulses],
        actionType     : .setIsHiddenToTestResult,
        capability     : [.lok3]
      ),
      (
        property1      : .esuSoundType,
        testType1      : .equal,
        testValue1     : ESUSoundType.steamLocomotiveWithoutExternalSensor.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.esuDistanceOfGearSteps,  .esuTriggerImpulses],
        actionType     : .setIsHiddenToTestResult,
        capability     : [.lok3]
      ),
      (
        property1      : .esuSoundType,
        testType1      : .equal,
        testValue1     : ESUSoundType.steamLocomotiveWithExternalSensor.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.esuDistanceOfGearSteps, .esuDistanceofSteamChuffsAtSpeedStep2, .esuDistanceOfSteamChuffsAtSpeedStep1],
        actionType     : .setIsHiddenToTestResult,
        capability     : [.lok3]
      ),
      (
        property1      : .speedTableType,
        testType1      : .equal,
        testValue1     : SpeedTableType.vStartvMidvHigh.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.esuSpeedTable, .speedTableIndex, .speedTableEntryValue, .speedTablePreset, .maximumSpeed, .minimumSpeed, .nmraSpeedTable, .speedTableEntryValueB],
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
      ),
      (
        property1      : .enableLoadControlBackEMF,
        testType1      : .equal,
        testValue1     : "false",
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.slowSpeedBackEMFSamplingPeriod, .slowSpeedLengthOfMeasurementGap, .regulationParameterID, .regulationParameterID, .regulationReference, .fullSpeedBackEMFSamplingPeriod, .regulationParameterKSlow, .largestInternalSpeedStepThatUsesKSlow, .regulationParameterK, .fullSpeedLengthOfMeasurementGap, .regulationParameterISlow, .regulationInfluenceDuringSlowSpeed, .adaptiveRegulationFrequencyEnabled, .backEMFSamplingPeriod, .emfBasicSettings, .emfSlowSpeedSettings, .regulationReferenceLok3, .regulationParameterKLok3, .regulationParameterILok3, .regulationInfluenceLok3],
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
      ),
      (
        property1      : .enableMinimumDistanceOfSteamChuffs,
        testType1      : .equal,
        testValue1     : "false",
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.minimumDistanceofSteamChuffs, .minimumDistanceofSteamChuffsLok3],
        actionType     : .setIsHiddenToTestResult,
        capability     : []
      ),
      (
        property1      : .enableSoundSteamShift,
        testType1      : .equal,
        testValue1     : "false",
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.timeForOneSteamShiftCycle, .earliestRelativeStartPosition, .latestRelativeEndPosition],
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
      ),
      
      
      /* *************************************** */
      
      (
        property1      : .physicalOutputModeB,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputModeB.dimmableHeadlight.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputPulseLengthB],
        actionType     : .setIsHiddenToTestResult,
        capability     : [.singleFrontRearAux1Aux2]
      ),
      (
        property1      : .physicalOutputModeB,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputModeB.flashLightPhase1.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputPulseLengthB],
        actionType     : .setIsHiddenToTestResult,
        capability     : [.singleFrontRearAux1Aux2]
      ),
      (
        property1      : .physicalOutputModeB,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputModeB.flashLightPhase2.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputPulseLengthB],
        actionType     : .setIsHiddenToTestResult,
        capability     : [.singleFrontRearAux1Aux2]
      ),
      (
        property1      : .physicalOutputModeB,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputModeB.singleStrobe.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputPulseLengthB],
        actionType     : .setIsHiddenToTestResult,
        capability     : [.singleFrontRearAux1Aux2]
      ),
      (
        property1      : .physicalOutputModeB,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputModeB.doubleStrobe.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputPulseLengthB],
        actionType     : .setIsHiddenToTestResult,
        capability     : [.singleFrontRearAux1Aux2]
      ),
      (
        property1      : .physicalOutputModeB,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputModeB.firebox.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputPulseLengthB],
        actionType     : .setIsHiddenToTestResult,
        capability     : [.singleFrontRearAux1Aux2]
      ),
      (
        property1      : .physicalOutputModeB,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputModeB.seutheSmokeUnit.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputPulseLengthB, .physicalOutputBrightnessB],
        actionType     : .setIsHiddenToTestResult,
        capability     : [.singleFrontRearAux1Aux2]
      ),
      (
        property1      : .physicalOutputModeB,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputModeB.dimmableHeadlightFadeInFadeOut.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputPulseLengthB],
        actionType     : .setIsHiddenToTestResult,
        capability     : [.singleFrontRearAux1Aux2]
      ),
      (
        property1      : .physicalOutputModeB,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputModeB.marsLight.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputPulseLengthB],
        actionType     : .setIsHiddenToTestResult,
        capability     : [.singleFrontRearAux1Aux2]
      ),
      (
        property1      : .physicalOutputModeB,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputModeB.gyraLight.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputPulseLengthB],
        actionType     : .setIsHiddenToTestResult,
        capability     : [.singleFrontRearAux1Aux2]
      ),
      (
        property1      : .physicalOutputModeB,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputModeB.rule17Forward.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputPulseLengthB],
        actionType     : .setIsHiddenToTestResult,
        capability     : [.singleFrontRearAux1Aux2]
      ),
      (
        property1      : .physicalOutputModeB,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputModeB.rule17Reverse.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputPulseLengthB],
        actionType     : .setIsHiddenToTestResult,
        capability     : [.singleFrontRearAux1Aux2]
      ),
      (
        property1      : .physicalOutputModeB,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputModeB.pulse.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputBrightnessB],
        actionType     : .setIsHiddenToTestResult,
        capability     : [.singleFrontRearAux1Aux2]
      ),
      (
        property1      : .physicalOutputModeB,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputModeB.ditchLightPhase1.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputPulseLengthB],
        actionType     : .setIsHiddenToTestResult,
        capability     : [.singleFrontRearAux1Aux2]
      ),
      (
        property1      : .physicalOutputModeB,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputModeB.ditchLightPhase2.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputPulseLengthB],
        actionType     : .setIsHiddenToTestResult,
        capability     : [.singleFrontRearAux1Aux2]
      ),
      (
        property1      : .physicalOutputOutputMode,
        testType1      : .equal,
        testValue1     : ESUPhysicalOutputMode.disabled.title,
        operator       : nil,
        property2      : nil,
        testType2      : nil,
        testValue2     : nil,
        actionProperty : [.physicalOutputBrightness, .physicalOutputUseClassLightLogic, .physicalOutputSequencePosition, .physicalOutputPhaseShift, .physicalOutputStartupTime, .physicalOutputLevel, .physicalOutputSmokeUnitControlMode, .physicalOutputSpeed, .physicalOutputAccelerationRate, .physicalOutputDecelerationRate, .physicalOutputHeatWhileLocomotiveStands, .physicalOutputMinimumHeatWhileLocomotiveDriving, .physicalOutputMaximumHeatWhileLocomotiveDriving, .physicalOutputChuffPower, .physicalOutputFanPower, .physicalOutputTimeout, .physicalOutputServoDurationA, .physicalOutputServoDurationB, .physicalOutputServoPositionA, .physicalOutputServoDoNotDisableServoPulseAtPositionA, .physicalOutputServoPositionB, .physicalOutputServoDoNotDisableServoPulseAtPositionB, .physicalOutputCouplerForce, .physicalOutputExternalSmokeUnitType, .physicalOutputGradeCrossing, .physicalOutputRule17Forward, .physicalOutputRule17Reverse, .physicalOutputDimmer, .physicalOutputStartupTimeInfo, .physicalOutputStartupDescription, .physicalOutputLEDMode, .physicalOutputSpecialFunctions, .physicalOutputPantographHeight],
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
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
        actionType     : .setIsHiddenToTestResult,
        capability     : []
      ),

    ]
    
    layoutRuleLookupTestProperties.removeAll()
    layoutRuleLookupActionProperties.removeAll()
    
    if let _layoutRules {
      
      for rule in _layoutRules {
        
        if decoderType.capabilities.intersection(rule.capability) == rule.capability {
          
          var ok = true
          
          if let propertyView = propertyViewLookup[rule.property1], !propertyView.isExtant {
            ok = false
          }
          
          if let property = rule.property2, let propertyView = propertyViewLookup[property], !propertyView.isExtant {
            ok = false
          }
          
          if ok {
            
            var rules : [PTSettingsPropertyLayoutRule] = [rule]
            
            if let temp = layoutRuleLookupTestProperties[rule.property1] {
              rules.append(contentsOf: temp)
            }
            
            layoutRuleLookupTestProperties[rule.property1] = rules
            
            if let property2 = rule.property2 {
              
              var rules : [PTSettingsPropertyLayoutRule] = [rule]
              
              if let temp = layoutRuleLookupTestProperties[property2] {
                rules.append(contentsOf: temp)
              }
              
              layoutRuleLookupTestProperties[property2] = rules
              
            }
            
            for actionProperty in rule.actionProperty {
              
              if let actionView = propertyViewLookup[actionProperty], actionView.isExtant {
                
                var rules : [PTSettingsPropertyLayoutRule] = [rule]
                
                if let temp = layoutRuleLookupActionProperties[actionProperty] {
                  rules.append(contentsOf: temp)
                }
                
                layoutRuleLookupActionProperties[actionProperty] = rules
                
              }
              
            }
            
          }
          
        }
        
      }
      
    }
    
  }

}
