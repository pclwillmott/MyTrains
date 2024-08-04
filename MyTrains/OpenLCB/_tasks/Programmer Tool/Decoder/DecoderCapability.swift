//
//  DecoderCapability.swift
//  MyTrains
//
//  Created by Paul Willmott on 11/07/2024.
//

import Foundation

public enum DecoderCapability : CaseIterable {
  
  // MARK: Enumeration
  
  case dccProtocol
  case marklinMotorolaProtocol
  case m4Protocol
  case selectrixProtocol
  case respondsToNonDCCCommands
  case acAnalogMode
  case threeValueSpeedTable
  case highFrequencyPWMMotorControl
  case sendZIMOZACKSignals
  case digitalWheelSensorDisablesAUX10
  case susiMasterDisablesAUX11
  case susiMasterDisablesAUX12
  case aux2toAux4
  case aux5toAux6
  case aux7toAux8
  case aux9toAux10
  case aux11toAux12
  case aux13toAux18
  case sensorConfiguration
  case loadControlBackEMF
  case motorOverloadProtection
  case pwmFrequency
  case automaticParkingBrake
  case dynamicSoundControl
  case sensorSettings
  case susiMasterDisablesAUX3
  case susiMasterDisablesAUX4
  case susi
  case broadway
  case sound
  case noSound
  case esuSmokeUnit
  case soundControlBehaviour
  case hluSections
  case zimoBrakeSections
  case simpleSUSI
  case lok5
  case lok4
  
}
