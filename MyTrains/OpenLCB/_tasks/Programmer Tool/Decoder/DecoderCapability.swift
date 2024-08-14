//
//  DecoderCapability.swift
//  MyTrains
//
//  Created by Paul Willmott on 11/07/2024.
//

import Foundation

public enum DecoderCapability : CaseIterable {
  
  // MARK: Enumeration
  
  // Address
  
  case primaryAddress
  case extendedAddress
  case respondsToNonDCCCommands
  case marklinConsecutiveAddresses
  case secondAddressForMotorolaCommands
  case dccAddresses
  case consistFunctions2
  case consistFunctionsFRF1F12
  case consistFunctionsF0F15
  case consistFunctions4
  case consistFunctionsFRF1F30

  // Analog Settings
  
  case analogFunctions
  case analogFunctionsFRF1F12
  case analogFunctionsLF1F15
  case acAnalogMode
  case acAnalogModeVoltages
  case dcAnalogModeSimple
  case dcAnalogMode
  case dcAnalogModeVoltages
  case quantumEngineer
  case soundControlBehaviour
  case highFrequencyPWMMotorControl
  case analogModeHysteresis

  // Brake Settings

  case abcBrakeSections
  case abcShuttleTrain
  case hluSections
  case zimoBrakeSections
  case sendZIMOZACKSignals
  case trixBrakeSections
  case marklinBrakeSections
  case lenzBrakeSections
  case lenzBrakeSectionsB
  case autoStopDCPolarity
  case selectrixBrakeSections
  case brakeFunction2And3
  case constantBrakeDistance

  // DCC Settings
  
  case railCom
  case railComPlusAutomaticAnnouncement
  case detectSpeedStepAutomatically

  // Driving Characteristics
  
  case accelerationRateA
  case accelerationRateC
  case accelerationRateD
  case accelerationAdjustmentA
  case accelerationAdjustmentB
  case trimming
  case loadAdjustment
  case timeToBridgePowerInterruption
  case preserveDirection

  // Function Outputs
  
  case physicalOutputs
  case singleFrontRearAux1Aux2
  case aux1toAux2
  case aux3toAux4
  case aux5toAux6
  case aux7toAux8
  case aux9toAux10
  case aux11toAux12
  case aux13toAux18
  case physicalOutputsPropertiesA
  case physicalOutputsPropertiesB
  case digitalWheelSensorDisablesAUX10
  case susiMasterDisablesAUX11
  case susiMasterDisablesAUX12
  case susiMasterDisablesAUX3
  case susiMasterDisablesAUX4

  // Function Settings
  
  case frequencyForBlinkingEffectsA
  case frequencyForBlinkingEffectsB
  case gradeCrossingHoldingTime
  case enforceSlaveCommunicationOnAUX3AndAUX4
  case sensorSettings
  case sensorConfiguration
  case automaticUncoupling

  // Identification
  
  case userIdentification

  // Compatibility

  case serialFunctionModeForLGBMTS
  case broadway
  case simpleSUSI
  case susi

  // Motor Settings
  
  case locoMaximumSpeedAndName
  case speedTable
  case threeValueSpeedTable
  case esuSpeedTable
  case nmraSpeedTable
  case minMaxSpeedB
  case loadControlBackEMF
  case regulationReference
  case loadControlBackEMFA
  case loadControlBackEMFB
  case loadControlBackEMFC
  case loadControlBackEMFSlow
  case backEMFSettings
  case adaptiveRegulationFrequency
  case backEMFSamplingPeriod
  case motorOverloadProtection
  case pwmFrequency
  case automaticParkingBrake

  // Smoke Unit
  
  case esuSmokeUnit

  // Special Options
  
  case dccProtocol
  case marklinMotorolaProtocol
  case selectrixProtocol
  case m4Protocol
  case syncWithMasterDecoder

  // Sound Settings
  
  case sound
  case smokeChuffs
  case soundFadeInOut
  case toneControl
  case dynamicSoundControl

  // Sound Slot Settings
  
  case soundSlot1to10
  case soundSlot11to24
  case soundSlot25to27
  case soundSlot28to32
  case soundSlotGearShift
  case soundSlotBrake
  case soundSlotRandom

  case lok5
  case lok4
  case lok3
  case disableMotorPWM
  case noSound
  case startingDelay
  case marklinDeltaMode
  case powerPackSolderedWarning
  case functionIcons
  case triggerSoundsOnFunctionStatusChange
  case zimoManualFunction
  case disableMotorEMKMeasure
  case disableMotorBrake
  case brightnessOfLightAndFunctionOutputsCV54
  case brightnessOfLightAndFunctionOutputsCV63
  case functionMappings
  case startingDelayIfVirtualSoundEnabledCV221
  case startingDelayIfVirtualSoundEnabledCV252
  case startingDelayIfVirtualSoundEnabledCV253
  case startingDelayIfVirtualSoundEnabledCV128
  case disableFunctionOutputPWM
  
}
