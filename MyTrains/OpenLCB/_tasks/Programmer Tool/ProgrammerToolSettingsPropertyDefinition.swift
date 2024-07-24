//
//  ProgrammerToolSettingsPropertyDefinition.swift
//  MyTrains
//
//  Created by Paul Willmott on 22/07/2024.
//

import Foundation

public typealias ProgrammerToolSettingsPropertyDefinition = (
  title                : String,
  section              : ProgrammerToolSettingsSection,
  controlType          : ProgrammerToolControlType,
  encoding             : ProgrammerToolEncodingType,
  cvIndexingMethod     : CVIndexingMethod?,
  cv                   : [CV]?,
  mask                 : [UInt8]?,
  shift                : [Int]?,
  minValue             : Double?,
  maxValue             : Double?,
  trueDefaultValue     : UInt8?,
  infoType             : ProgrammerToolInfoType,
  infoFactor           : Double?,
  infoMaxDecimalPlaces : Int?,
  infoFormat           : String?,
  requiredCapabilities : Set<DecoderCapability>
)

public enum ProgrammerToolInfoType : CaseIterable {
  
  // MARK: Enumeration
  
  case none
  case value
  case percentage
  case time
  case voltage
  case decibel
  case frequency
  case temperature
  
}

public enum ProgrammerToolEncodingType : Int, CaseIterable {
  
  // MARK: Enumeration

  // Generic Encodings
  
  case none            // No encoding - property is a description or warning
  case byte            // Byte, Min, Max, Mask, Shift
  case boolBit         // Bit of Byte, Mask
  case boolNZ          // Byte, Non-Zero means true, 0 means false
  case extendedAddress // Word DCC long address encoding
  case specialInt8     // Byte +/- 127 with bit 7 as sign (not 2s complement)
  case custom          // Decoding/Encoding is handled by separate code
  case dWordHex        // 4 byte value in hex, little endian
  
  // Selection Encodings (ComboBox)
  
  case esuDecoderPhysicalOutput
  case esuPhysicalOutputMode
  case esuSteamChuffMode
  case esuSmokeUnitControlMode
  case esuExternalSmokeUnitType
  case esuSoundControlBasis
  case esuTriggeredFunction
  case esuSpeedTablePreset
  case locomotiveAddressType
  case esuMarklinConsecutiveAddresses
  case esuSpeedStepMode
  case manufacturerCode
  case esuDecoderSensorSettings
  case esuClassLightLogicLength
  case speedTableIndex
  case speedTableValue
  case analogModeEnable

}

public enum CVIndexingMethod {
  
  // MARK: Enumeration
  
  case standard
  case esuDecoderPhysicalOutput
  
}
