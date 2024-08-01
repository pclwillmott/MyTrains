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
  case manufacturerName
  case esuFunctionCategory
  
}

public enum ProgrammerToolEncodingType : Int, CaseIterable {
  
  // MARK: Enumeration

  // Generic Encodings
  
  case none             // No encoding - property is a description or warning
  case byte             // Byte, Min, Max, Mask, Shift
  case word             // Word, Min, Max
  case dword            // DWord, Min, Max
  case boolBit          // Bit of Byte, Mask
  case boolNZ           // Byte, Non-Zero means true, 0 means false
  case boolNZReversed   // Byte, Non-Zero means false, 0 means true
  case extendedAddress  // Word DCC long address encoding
  case specialInt8      // Byte +/- 127 with bit 7 as sign (not 2s complement)
  case custom           // Decoding/Encoding is handled by separate code
  case dWordHex         // 4 byte value in hex, little endian
  case manufacturerName // 1 byte decoded as NMRA Manufacturer Name
  case railComDate      // 4 bytes encoded as number of seconds since 1 Jan 2000
  case zString          // Null terminated string upto the Max length of the field.
                        // If all characters are used there is no null termination
  
  // Selection Encodings (ComboBox)
  
  case esuDecoderPhysicalOutput
  case esuPhysicalOutputMode
  case esuSteamChuffMode
  case esuSmokeUnitControlMode
  case esuExternalSmokeUnitType
  case esuSoundControlBasis
  case esuTriggeredFunction
  case esuSpeedTablePreset
  case threeValueSpeedTablePreset
  case locomotiveAddressType
  case esuMarklinConsecutiveAddresses
  case esuSpeedStepMode
  case manufacturerCode
  case esuDecoderSensorSettings
  case esuClassLightLogicLength
  case speedTableIndex
  case speedTableValue
  case analogModeEnable
//  case hluSpeedLimit
//  case steamChuffDuration
  case esuRandomFunction
  case soundCV
  case esuSoundSlot
//  case soundSlotMinMaxSoundSpeed
  case esuFunction
  case esuFunctionIcon
  case esuFunctionMapping
  case esuCondition
  case esuConditionDriving
  case esuConditionDirection
  case speedTableType
//  case vStartvMidvHigh
  
}

public enum CVIndexingMethod {
  
  // MARK: Enumeration
  
  case standard
  case esuDecoderPhysicalOutput
  case esuRandomFunction
  case soundCV
  case esuSoundSlot
  case esuFunction
  case esuFunctionMapping
  
}
