//
//  Decoder.swift
//  MyTrains
//
//  Created by Paul Willmott on 05/07/2024.
//

import Foundation

private enum IdentifyDecoderState {
  case idle
  case getManufacturer
  case getESUProductId
}

public class Decoder : NSObject {
  
  // MARK: Constructors & Destructors
  
  init(decoderType:DecoderType) {
    
    self._decoderType = decoderType
    
    self._cvList = decoderType.allCVlists[0]
    self._cvs = decoderType.cvList(filename: _cvList.filename)
    
    var lastIndex : UInt16?
    var block = 0
    for item in _cvs {
      let index = item.cv.index
      if index != lastIndex {
        _indicies.append(index)
        indexLookup[index] = block
        block += item.cv.isIndexed ? 256 : 1024
        lastIndex = index
      }
      if !item.cv.isHidden {
        _visibleCVs.append(item)
      }
    }
    
    savedBlocks = [UInt8](repeating: 0, count: 1024 + (_indicies.count - 1) * 256)
    
    super.init()
    
    for item in _cvs {
      setSavedValue(cv: item.cv, value: item.defaultValue)
    }
    
    revertToSaved()

  }
  
  // MARK: Private Properties
  
  private var _decoderType : DecoderType
  
  private var _cvList : CVList
  
  private var _cvs : [(cv: CV, defaultValue:UInt8)]
  
  private var _visibleCVs : [(cv: CV, defaultValue:UInt8)] = []
  
  private var savedBlocks : [UInt8]
  
  private var modifiedBlocks : [UInt8] = [] {
    didSet {
      _cvsModified = nil
      delegate?.reloadData?(self)
    }
  }
  
  private var _indicies : [UInt16] = []
  
  private var indexLookup : [UInt16:Int] = [:]
  
  private weak var _delegate : DecoderDelegate?
  
  private var _cvsModified : [(cv: CV, value:UInt8)]?
  
  private var physicalOutputProperties : [PTSettingsPropertyView] = []
  
  // MARK: Public Properties
  
  public var decoderType : DecoderType {
    return _decoderType
  }
  
  public var propertyViews : [PTSettingsPropertyView] = [] {
    didSet {
      for view in propertyViews {
        if view.indexingMethod == .esuDecoderPhysicalOutput {
          physicalOutputProperties.append(view)
        }
        view.decoder = self
      }
    }
  }
  
  public var cvList : CVList {
    return _cvList
  }
  
  public var cvs : [(cv: CV, defaultValue:UInt8)] {
    return _cvs
  }
  
  public var visibleCVs : [(cv: CV, defaultValue:UInt8)] {
    return _visibleCVs
  }
  
  public var indicies : [UInt16] {
    return _indicies
  }
  
  public var delegate : DecoderDelegate? {
    get {
      return _delegate
    }
    set(value) {
      _delegate = value
      _delegate?.reloadData?(self)
    }
  }
  
  public var cvsToWrite : [(cv:CV, value:UInt8)] {

    var result : [(cv:CV, value:UInt8)] = []
    
    var lastIndex : UInt16?
    
    var lastCV31 : UInt8 = 0
    
    var lastCV32 : UInt8 = 0
    
    for item in cvsModified {
      
      if item.cv.index != lastIndex {
        
        if lastIndex == nil {
          result.append((.cv_000_000_031, item.cv.cv31))
          result.append((.cv_000_000_032, item.cv.cv32))
        }
        else {
          if item.cv.cv31 != lastCV31 {
            result.append((.cv_000_000_031, item.cv.cv31))
          }
          if item.cv.cv32 != lastCV32 {
            result.append((.cv_000_000_032, item.cv.cv32))
          }
        }

        lastIndex = item.cv.index

        lastCV31 = item.cv.cv31
        lastCV32 = item.cv.cv32

      }
      
      result.append((item.cv, item.value))
        
    }

    return result
    
  }
  
  public var cvsModified : [(cv:CV, value:UInt8)] {
    
    if _cvsModified == nil {
      
      var result : [(cv:CV, value:UInt8)] = []
      
      for index in indicies {
        
        if let offset = indexLookup[index] {
          
          let isIndexed = index != 0
          
          let baseOffset = offset - 1 - (isIndexed ? 256 : 0)
          
          for cv : UInt16 in (!isIndexed ? 1 : 257) ... (!isIndexed ? 1024 : 512) {
            
            let ptr = baseOffset + Int(cv)
            
            if modifiedBlocks[ptr] != savedBlocks[ptr] {
              
              if let cvConstant = CV(index: index, cv: cv, indexMethod: .cv3132) {
                result.append((cvConstant, modifiedBlocks[ptr]))
              }
              else if let cvConstant = CV(index: index, cv: cv, indexMethod: .cv3132, isHidden: true) {
                result.append((cvConstant, modifiedBlocks[ptr]))
              }
              
            }
            
          }
          
        }
        
      }
      
      result.sort {$0.cv.rawValue < $1.cv.rawValue}
      
      _cvsModified = result
      
    }
    
    return _cvsModified!
    
  }
  
  public var supportedFunctionsConsistMode : Set<FunctionConsistMode> {
    var result : Set<FunctionConsistMode> = []
    for item in FunctionConsistMode.allCases {
      result.insert(item)
    }
    return result
  }
  
  public var supportedFunctionsAnalogMode : Set<FunctionAnalogMode> {
    var result : Set<FunctionAnalogMode> = []
    for item in FunctionAnalogMode.allCases {
      result.insert(item)
    }
    return result
  }
  
  public var locomotiveAddressType : LocomotiveAddressType { // KEEP
    return LocomotiveAddressType(title: getValue(property: .locomotiveAddressType))!
  }
  
  public var marklinConsecutiveAddresses : MarklinConsecutiveAddresses { // *** KEEP ***
    get {
      return MarklinConsecutiveAddresses(rawValue: getUInt8(cv: .cv_000_000_049)! & MarklinConsecutiveAddresses.mask)!
    }
    set(value) {
      setMaskedUInt8(cv: .cv_000_000_049, mask: MarklinConsecutiveAddresses.mask, value: value.rawValue)
    }
  }
  
  public var isConsistAddressEnabled : Bool { // KEEP
    return getValue(property: .enableDCCConsistAddress) == "true"
  }
  
  public var isACAnalogModeEnabled : Bool { // KEEP
    return getValue(property: .enableACAnalogMode) == "true"
  }

  public var isDCAnalogModeEnabled : Bool { // KEEP
    return getValue(property: .enableDCAnalogMode) == "true"
  }
  
  public var abcBrakeIfRightRailMorePositive : Bool { // KEEP
    return getValue(property: .brakeIfRightRailSignalPositive) == "true"
  }
  
  public var abcBrakeIfLeftRailMorePositive : Bool { // KEEP
    return getValue(property: .brakeIfLeftRailSignalPositive) == "true"
  }
  
  public var isABCShuttleTrainEnabled : Bool { // KEEP
    return getValue(property: .enableABCShuttleTrain) == "true"
  }

  public var isConstantBrakeDistanceEnabled : Bool { // KEEP
    return getValue(property: .enableConstantBrakeDistance) == "true"
  }

  public var isDifferentBrakeDistanceBackwards : Bool { // KEEP
    return getValue(property: .differentBrakeDistanceBackwards) == "true"
  }

  public var driveUntilLocomotiveStopsInSpecifiedPeriod : Bool { // KEEP
    return getValue(property: .driveUntilLocomotiveStopsInSpecifiedPeriod) == "true"
  }

  public var isRailComPlusAutomaticAnnouncementEnabled : Bool { // KEEP
    return getValue(property: .enableRailComPlusAutomaticAnnouncement) == "true"
  }

  public var detectSpeedStepModeAutomatically : Bool { // KEEP
    return getValue(property: .detectSpeedStepModeAutomatically) == "true"
  }
  
  public var isAccelerationEnabled : Bool { // KEEP
    return getValue(property: .enableAcceleration) == "true"
  }
  
  public var isDecelerationEnabled : Bool { // KEEP
    return getValue(property: .enableDeceleration) == "true"
  }

  public var isRailComFeedbackEnabled : Bool { // KEEP
    return getValue(property: .enableRailComFeedback) == "true"
  }
  
  public var isForwardTrimEnabled : Bool { // KEEP
    return getValue(property: .enableForwardTrim) == "true"
  }
  
  public var isReverseTrimEnabled : Bool { // KEEP
    return getValue(property: .enableReverseTrim) == "true"
  }
  
  public var isShuntingModeTrimEnabled : Bool { // KEEP
    return getValue(property: .enableShuntingModeTrim) == "true"
  }
  
  public var isGearboxBacklashCompensationEnabled : Bool { // KEEP
    return getValue(property: .enableGearboxBacklashCompensation) == "true"
  }
  
  public var isDecoderSynchronizedWithMasterDecoder : Bool { // KEEP
    return getValue(property: .enableRailComPlusSynchronization) == "true"
  }
  
  public var isAutomaticUncouplingEnabled : Bool { // KEEP
    return getValue(property: .enableAutomaticUncoupling) == "true"
  }
  
  public var isLoadControlBackEMFEnabled : Bool { // KEEP
    return getValue(property: .enableLoadControlBackEMF) == "true"
  }
  
  public var isMotorCurrentLimiterEnabled : Bool { // KEEP
    return getValue(property: .enableMotorCurrentLimiter) == "true"
  }
  
  public var steamChuffMode : SteamChuffMode { // KEEP
    return SteamChuffMode(title: getValue(property: .steamChuffMode))!
  }
  
  public var isSecondaryTrimmerEnabled : Bool { // KEEP
    return getValue(property: .enableSecondaryTrigger) == "true"
  }
  
  public var isMinimumDistanceOfSteamChuffsEnabled : Bool { // KEEP
    return getValue(property: .enableMinimumDistanceOfSteamChuffs) == "true"
  }
  
  public var soundControlBasis : SoundControlBasis { // KEEP
    return SoundControlBasis(title: getValue(property: .soundControlBasis))!
  }
  
  public var isThresholdForLoadOperationEnabled : Bool { // KEEP
    return getValue(property: .enableLoadOperationThreshold) == "true"
  }
  
  public var isThresholdForIdleOperationEnabled : Bool { // KEEP
    return getValue(property: .enableIdleOperationThreshold) == "true"
  }
  
  public var isSUSIMasterEnabled : Bool { // KEEP
    return getValue(property: .enableSUSIMaster) == "true"
  }

  public var isSUSISlaveEnabled : Bool { // KEEP
    return getValue(property: .enableSUSISlave) == "true"
  }
  
  public var decoderSensorSettings : DecoderSensorSettings { //KEEP
    return DecoderSensorSettings(title: getValue(property: .decoderSensorSettings))!
  }
  
  private var _speedTablePreset : SpeedTablePreset = .doNothing
  
  private var speedTablePreset : SpeedTablePreset { // *** KEEP ***
    get {
      return _speedTablePreset
    }
    set(value) {
      _speedTablePreset = value
      if !_speedTablePreset.speedTableValues.isEmpty {
        let table = _speedTablePreset.speedTableValues
        for index in 0 ... table.count - 1 {
          setUInt8(cv: .cv_000_000_067 + index, value: table[index])
        }
      }
      else if _speedTablePreset == .linearUntilFirstMaximumValue {
        var firstMax : Int = 0
        for index in 0 ... 27 {
          if getUInt8(cv: .cv_000_000_067 + index)! == 255 {
            firstMax = index
            break
          }
        }
        for index in 1 ... firstMax - 1 {
          let value = UInt8(1 + (255 - 1) * Double(index) / Double(firstMax))
          setUInt8(cv: .cv_000_000_067 + index, value: value)
        }
      }
      _speedTablePreset = .doNothing
      delegate?.reloadSettings?(self)
    }
  }
  
  private var _speedTableIndex : Int = 1
  
  public var speedTableIndex : Int { // *** KEEP ***
    get {
      return _speedTableIndex
    }
    set(value) {
      if value != _speedTableIndex {
        _speedTableIndex = value
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var speedTableValue : UInt8 { // *** KEEP ***
    get {
      return getUInt8(cv: .cv_000_000_067 + (speedTableIndex - 1))!
    }
    set(value) {
      if value != speedTableValue {
        setUInt8(cv: .cv_000_000_067 + (speedTableIndex - 1), value: value)
        if speedTableIndex > 2 {
          for index in 2 ... speedTableIndex - 1 {
            setUInt8(cv: .cv_000_000_067 + (index - 1), value: min(getUInt8(cv: .cv_000_000_067 + (index - 1))!, value))
          }
        }
        if speedTableIndex < 27 {
          for index in speedTableIndex + 1 ... 27 {
            setUInt8(cv: .cv_000_000_067 + (index - 1), value: max(getUInt8(cv: .cv_000_000_067 + (index - 1))!, value))
          }
        }
        delegate?.reloadSettings?(self)
      }
      
    }
  }
  
  private var _esuDecoderPhysicalOutput : ESUDecoderPhysicalOutput = .frontLight {
    didSet {
      for view in physicalOutputProperties {
        view.reload()
      }
    }
  }
  
  public var esuDecoderPhysicalOutput : ESUDecoderPhysicalOutput { // *** KEEP ***
    get {
      return _esuDecoderPhysicalOutput
    }
    set(value) {
      if value != esuDecoderPhysicalOutput {
        _esuDecoderPhysicalOutput = value
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var esuDecoderPhysicalOutputMode : ESUPhysicalOutputMode {
    return ESUPhysicalOutputMode(title: getValue(property: .physicalOutputOutputMode), decoder: self)!
  }
  
  public func isPropertySupported(property:ProgrammerToolSettingsProperty) -> Bool {
    return property.definition.cvIndexingMethod != .esuDecoderPhysicalOutput || esuDecoderPhysicalOutputMode.supportedProperties.contains(property)
    }
  
  public func cvIndexOffset(indexingMethod:CVIndexingMethod) -> Int {
    
    switch indexingMethod {
    case .standard:
      return 0
    case .esuDecoderPhysicalOutput:
      return Int(esuDecoderPhysicalOutput.rawValue) * 8
    }
    
  }

  public func getProperty(property:ProgrammerToolSettingsProperty, propertyDefinition:ProgrammerToolSettingsPropertyDefinition? = nil) -> [UInt8] {
    
    var result : [UInt8] = []
    
    guard let definition = propertyDefinition == nil ? ProgrammerToolSettingsProperty.definitions[property] : propertyDefinition, let cvs = definition.cv, let masks = definition.mask, let shifts = definition.shift, let cvIndexingMethod = definition.cvIndexingMethod else {
      return result
    }
    
    let indexOffset = cvIndexOffset(indexingMethod: cvIndexingMethod)
    
    for index in 0 ... cvs.count - 1 {
      
      let cv = cvs[index] + indexOffset
      
      if let offset = indexLookup[cv.index] {
        
        result.append((modifiedBlocks[offset + Int(cv.cv) - 1 - (cv.isIndexed ? 256 : 0)] & masks[index]) >> shifts[index])
        
      }
      
    }
    
    return result
    
  }

  public func setProperty(property:ProgrammerToolSettingsProperty, values:[UInt8], propertyDefinition:ProgrammerToolSettingsPropertyDefinition? = nil) {
    
    guard let definition = propertyDefinition == nil ? ProgrammerToolSettingsProperty.definitions[property] : propertyDefinition, let cvs = definition.cv, let masks = definition.mask, let shifts = definition.shift, let cvIndexingMethod = definition.cvIndexingMethod else {
      return
    }
    
    let indexOffset = cvIndexOffset(indexingMethod: cvIndexingMethod)
    
    for index in 0 ... cvs.count - 1 {
      
      let cv = cvs[index] + indexOffset
      
      if let offset = indexLookup[cv.index] {
        
        let position = offset + Int(cv.cv) - 1 - (cv.isIndexed ? 256 : 0)
        
        modifiedBlocks[position] = (modifiedBlocks[position] & ~masks[index]) | ((values[index] << shifts[index]) & masks[index])
        
      }
      
    }

  }

  public var isFunctionTimeOutEnabled : Bool { // KEEP
    return getValue(property: .physicalOutputEnableFunctionTimeout) == "true"
  }
  
  public var isClassLightLogicEnabled : Bool { // KEEP
    return getValue(property: .physicalOutputUseClassLightLogic) == "true"
  }
  
  // MARK: Public Methods
  
  public func getConsistFunctionState(function:FunctionConsistMode) -> Bool {
    let cvMask = function.cvMask
    return getBool(cv: cvMask.cv, mask: cvMask.mask)!
  }
  
  public func setConsistFunctionState(function:FunctionConsistMode, state:Bool) {
    let cvMask = function.cvMask
    setBool(cv: cvMask.cv, mask: cvMask.mask, value: state)
  }

  public func getAnalogFunctionState(function:FunctionAnalogMode) -> Bool {
    let cvMask = function.cvMask
    return getBool(cv: cvMask.cv, mask: cvMask.mask)!
  }
  
  public func setAnalogFunctionState(function:FunctionAnalogMode, state:Bool) {
    let cvMask = function.cvMask
    setBool(cv: cvMask.cv, mask: cvMask.mask, value: state)
  }

  public func getSavedValue(cv:CV) -> UInt8? {
    
    guard let offset = indexLookup[cv.index] else {
      return nil
    }
    
    return savedBlocks[offset + Int(cv.cv) - 1 - (cv.isIndexed ? 256 : 0)]
    
  }
  
  public func setSavedValue(cv:CV, value:UInt8) {

    guard let offset = indexLookup[cv.index] else {
      return
    }

    savedBlocks[offset + Int(cv.cv) - 1 - (cv.isIndexed ? 256 : 0)] = value
    
  }
  
  public func cvWasWritten(cv:CV, value:UInt8) {
    setSavedValue(cv: cv, value: value)
    setUInt8(cv: cv, value: value)
  }
  
  public func setUInt8(cv:CV, value:UInt8) {

    guard let offset = indexLookup[cv.index] else {
      return
    }

    modifiedBlocks[offset + Int(cv.cv) - 1 - (cv.isIndexed ? 256 : 0)] = value
    
  }

  public func setUInt32(cv:CV, value:UInt32) {

    guard let offset = indexLookup[cv.index] else {
      return
    }

    var temp = value
    
    for index in 0 ... 3 {
      modifiedBlocks[offset + Int(cv.cv) - 1 - (cv.isIndexed ? 256 : 0) + index] = UInt8(temp & 0xff)
      temp >>= 8
    }
    
  }

  public func revertToSaved() {
    modifiedBlocks = savedBlocks
  }
  
  public func getMaskedUInt8(cv:CV, mask:UInt8) -> UInt8? {
    guard let value = getUInt8(cv: cv) else {
      return nil
    }
    return value & mask
  }
  
  public func setMaskedUInt8(cv:CV, mask:UInt8, value:UInt8) {
    guard var temp = getUInt8(cv: cv) else {
      return
    }
    setUInt8(cv: cv, value: (temp & ~mask) | (value & mask))
  }
  
  public func getBool(cv:CV, mask:UInt8) -> Bool? {
    guard let value = getMaskedUInt8(cv: cv, mask: mask) else {
      return nil
    }
    return value == mask
  }
  
  public func setBool(cv:CV, mask:UInt8, value:Bool) {

    guard var byte = getUInt8(cv: cv), var offset = indexLookup[cv.index] else {
      return
    }
    
    modifiedBlocks[offset + Int(cv.cv) - 1 - (cv.isIndexed ? 256 : 0)] = (byte & ~mask) | (value ? mask : 0)

  }
  
  public func getUInt32(cv:CV) -> UInt32? {

    guard let offset = indexLookup[cv.index] else {
      return nil
    }

    let baseOffset = offset - 1 - (cv.isIndexed ? 256 : 0)
    
    var data : [UInt8] = []
    
    for byte in 0 ... 3 {
      data.append(modifiedBlocks[baseOffset + Int(cv.cv) + byte])
    }
    
    return UInt32(bigEndianData: data.reversed())

  }
  
  public func getUInt16(cv:CV) -> UInt16? {

    guard let offset = indexLookup[cv.index] else {
      return nil
    }

    let baseOffset = offset - 1 - (cv.isIndexed ? 256 : 0)
    
    var data : [UInt8] = []
    
    for byte in 0 ... 1 {
      data.append(modifiedBlocks[baseOffset + Int(cv.cv) + byte])
    }
    
    return UInt16(bigEndianData: data.reversed())

  }
  
  public func getUInt8(cv:CV) -> UInt8? {
    
    guard let offset = indexLookup[cv.index] else {
      return nil
    }
    
    return modifiedBlocks[offset + Int(cv.cv) - 1 - (cv.isIndexed ? 256 : 0)]
    
  }
  
  public var showPhysicalOutputPropertiesForThisOutput : Bool {
    
    switch esuDecoderPhysicalOutput {
    case .aux10:
      return decoderSensorSettings != .useDigitalWheelSensor
    case .aux11, .aux12:
      return !isSUSIMasterEnabled
    default:
      return true
    }
    
  }
  
  public func cvTextList(list:[(cv:CV, value:UInt8)]) -> String {
    
    var result = ""
    
    var lastIndex : UInt16 = 0
    
    var maxTitle : Int = 0
    
    for item in list {
      
      if lastIndex != item.cv.index {
        result += "\n"
        lastIndex = item.cv.index
        let title = String(format:"CV31 = %i, CV32 = %i", item.cv.cv31, item.cv.cv32)
        maxTitle = max(maxTitle, title.count)
        result += title + "\n"
        result += "%%UNDERLINE%%\n"
      }
      
      result += String(format:"CV%-4i=%5i\n", item.cv.cv, item.value)
      
    }
    
    return result.replacingOccurrences(of: "%%UNDERLINE%%", with: String(repeating: "-", count: maxTitle))
    
  }
  
  public func getValue(property:ProgrammerToolSettingsProperty, definition : ProgrammerToolSettingsPropertyDefinition? = nil) -> String {
    
    let excludedEncodings : Set<ProgrammerToolEncodingType> = [
      .custom,
      .none,
    ]
    
    guard let definition = definition ?? ProgrammerToolSettingsProperty.definitions[property], !excludedEncodings.contains(definition.encoding) else {
      return ""
    }
    
    let values = getProperty(property: property, propertyDefinition: definition)
    
    switch definition.encoding {
    case .byte:
      return "\(values[0])"
    case .boolBit:
      return values[0] == definition.mask![0] ? "true" : "false"
    case .boolNZ:
      return values[0] != 0 ? "true" : "false"
    case .locomotiveAddressType:
      return (values[0] == definition.mask![0] ? LocomotiveAddressType.extended : LocomotiveAddressType.primary).title
    case .extendedAddress:
      return "\((( UInt16(values[0]) << 8) | UInt16(values[1])) - 49152)"
    case .specialInt8:
      return "\(Int8(values[0] & 0x7f) * (((values[0] & ByteMask.d7) == ByteMask.d7) ? -1 : 1))"
    case .esuExternalSmokeUnitType:
      return ExternalSmokeUnitType(rawValue: values[0])!.title
    case .esuMarklinConsecutiveAddresses:
      return marklinConsecutiveAddresses.title
    case .esuSpeedStepMode:
      return SpeedStepMode(rawValue: values[0])!.title
    case .manufacturerCode:
      return ManufacturerCode(rawValue:UInt16(values[0]))!.title
    case .esuDecoderSensorSettings:
      return DecoderSensorSettings(rawValue: values[0])!.title
    case .esuSteamChuffMode:
      return (values[0] == 0 ? SteamChuffMode.useExternalWheelSensor : SteamChuffMode.playSteamChuffsAccordingToSpeed).title
    case .esuSoundControlBasis:
      return (values[0] == 0 ? SoundControlBasis.accelerationAndBrakeTime : SoundControlBasis.accelerationAndBrakeTimeAndTrainLoad).title
    case .esuSpeedTablePreset:
      return speedTablePreset.title
    case .esuDecoderPhysicalOutput:
      return esuDecoderPhysicalOutput.title
    case .esuSmokeUnitControlMode:
      return SmokeUnitControlMode(rawValue: values[0])!.title
    case .esuPhysicalOutputMode:
      return ESUPhysicalOutputMode(rawValue: values[0])!.title(decoder: self)
    case .esuClassLightLogicLength:
      return ClassLightLogicSequenceLength(rawValue: values[0])!.title
    case .speedTableIndex:
      return "\(speedTableIndex)"
    case .speedTableValue:
      return "\(speedTableValue)"
    case .esuTriggeredFunction:
      return TriggeredFunction(rawValue: values[0])!.title
    case .dWordHex:
      return UInt32(bigEndianData: values.reversed())!.toHex(numberOfDigits: 8)
    case .analogModeEnable:
      return values[1] == definition.mask![1] ? "true" : "false"
    default:
      break
    }
    
    return ""
    
  }

  let formatter = NumberFormatter()
  
  public func getInfo(property:ProgrammerToolSettingsProperty, definition:ProgrammerToolSettingsPropertyDefinition? = nil) -> String {

    guard let definition = definition ?? ProgrammerToolSettingsProperty.definitions[property], definition.infoType != .none, let maximumFractionDigits = definition.infoMaxDecimalPlaces, let infoFactor = definition.infoFactor, let appNode else {
      return ""
    }

    formatter.usesGroupingSeparator = true
    formatter.groupingSize = 3
    formatter.alwaysShowsDecimalSeparator = false
    formatter.minimumFractionDigits = 0
    formatter.maximumFractionDigits = maximumFractionDigits

    let values = getProperty(property: property, propertyDefinition: definition)

    var doubleValue : Double

    if definition.encoding == .specialInt8 {
      doubleValue = Double((Int8(values[0] & 0x7f) * (((values[0] & ByteMask.d7) == ByteMask.d7) ? -1 : 1)))
    }
    else {
      doubleValue = Double(values[0])
    }

    doubleValue *= infoFactor

    var symbol = ""
    
    switch definition.infoType {
    case .decibel:
      doubleValue = (Double(values[0]) - 16.0) * infoFactor
      symbol = String(localized:"dB")
    case .frequency:
      doubleValue = UnitFrequency.convert(fromValue: doubleValue, fromUnits: .hertz, toUnits: appNode.unitsFrequency)
      symbol = appNode.unitsFrequency.symbol
    case .percentage:
      symbol = String(localized:"%")
    case .temperature:
      doubleValue = UnitTemperature.convert(fromValue: doubleValue, fromUnits: .celsius, toUnits: appNode.unitsTemperature)
      symbol = appNode.unitsTemperature.symbol
    case .time:
      doubleValue = UnitTime.convert(fromValue: doubleValue, fromUnits: .seconds, toUnits: appNode.unitsTime)
      symbol = appNode.unitsTime.symbol
    case .voltage:
      doubleValue = UnitVoltage.convert(fromValue: doubleValue, fromUnits: .volts, toUnits: appNode.unitsVoltage)
      symbol = appNode.unitsVoltage.symbol
    default:
      break
    }
    
    let number = formatter.string(from: doubleValue as NSNumber)!
    
    if let format = definition.infoFormat {
      return format.replacingOccurrences(of: "%%VALUE%%", with: number)
    }
    
    return "\(number)\(symbol)"
        
  }
  
  public func isValid(property:ProgrammerToolSettingsProperty, string:String, definition:ProgrammerToolSettingsPropertyDefinition? = nil) -> Bool {
    
    guard let definition = definition ?? ProgrammerToolSettingsProperty.definitions[property], let maxValue = definition.maxValue, let minValue = definition.minValue else {
      return true
    }
    
    switch definition.encoding {
    case .dWordHex:
      guard let _ = UInt32(hex:string) else {
        return false
      }
    default:
      guard let value = Int(string), value >= Int(minValue) && value <= Int(maxValue) else {
        return false
      }
    }

    return true
    
  }
  
  public func setValue(property: ProgrammerToolSettingsProperty, string: String, definition:ProgrammerToolSettingsPropertyDefinition? = nil) {
 
    let excludedEncodings : Set<ProgrammerToolEncodingType> = [
      .custom,
      .none,
    ]
    
    guard let definition = definition ?? ProgrammerToolSettingsProperty.definitions[property], !excludedEncodings.contains(definition.encoding) else {
      return
    }
    
    var newValues : [UInt8] = []
    
    switch definition.encoding {
    case .byte:
      newValues.append(UInt8(string)!)
    case .boolBit:
      newValues.append(string == "true" ? definition.mask![0] : 0)
    case .boolNZ:
      newValues.append(string == "true" ? definition.trueDefaultValue! : 0)
    case .locomotiveAddressType:
      newValues.append(LocomotiveAddressType(title: string) == .extended ? definition.mask![0] : 0)
    case .extendedAddress:
      let extendedAddress = UInt16(string)! + 49152
      newValues.append(UInt8(extendedAddress >> 8))
      newValues.append(UInt8(extendedAddress & 0xff))
    case .specialInt8:
      let value = Int(string)!
      newValues.append(UInt8(abs(value)) | (value < 0 ? ByteMask.d7 : 0))
    case .esuExternalSmokeUnitType:
      newValues.append(ExternalSmokeUnitType(title: string)!.rawValue)
    case .esuMarklinConsecutiveAddresses:
      marklinConsecutiveAddresses = MarklinConsecutiveAddresses(title: string)!
    case .esuSpeedStepMode:
      newValues.append(SpeedStepMode(title: string)!.rawValue)
    case .manufacturerCode:
      newValues.append(UInt8(ManufacturerCode(title: string)!.rawValue))
    case .esuDecoderSensorSettings:
      newValues.append(DecoderSensorSettings(title: string)!.rawValue)
    case .esuSteamChuffMode:
      newValues.append(SteamChuffMode(title: string)! == .playSteamChuffsAccordingToSpeed ? definition.trueDefaultValue! : 0)
    case .esuSoundControlBasis:
      newValues.append(SoundControlBasis(title: string)! == .accelerationAndBrakeTimeAndTrainLoad ? definition.trueDefaultValue! : 0)
    case .esuSpeedTablePreset:
      speedTablePreset = SpeedTablePreset(title: string)!
    case .esuDecoderPhysicalOutput:
      esuDecoderPhysicalOutput = ESUDecoderPhysicalOutput(title: string)!
    case .esuSmokeUnitControlMode:
      newValues.append(SmokeUnitControlMode(title: string)!.rawValue)
    case .esuPhysicalOutputMode:
      newValues.append(ESUPhysicalOutputMode(title: string, decoder: self)!.rawValue)
    case .esuClassLightLogicLength:
      newValues.append(ClassLightLogicSequenceLength(title: string)!.rawValue)
    case .speedTableIndex:
      speedTableIndex = Int(string)!
    case .speedTableValue:
      speedTableValue = UInt8(string)!
    case .esuTriggeredFunction:
      newValues.append(TriggeredFunction(title: string)!.rawValue)
    case .dWordHex:
      newValues = UInt32(hex: string)!.bigEndianData.reversed()
    case .analogModeEnable:
      
      let otherProperty : ProgrammerToolSettingsProperty = property == .enableACAnalogMode ? .enableDCAnalogMode : .enableACAnalogMode
      
      let otherDefinition = otherProperty.definition
      
      let otherValues = getProperty(property: otherProperty, propertyDefinition: otherDefinition)
      
      let otherEnabled = otherValues[1] == otherDefinition.mask![1]
      
      let thisEnabled = string == "true"
      
      newValues.append((thisEnabled || otherEnabled) ? definition.mask![0] : 0)
      
      newValues.append(thisEnabled ? definition.mask![1] : 0)
      
    default:
      break
    }
    
    if !newValues.isEmpty {
      
      let values = getProperty(property: property, propertyDefinition: definition)
      
      if values != newValues {
        setProperty(property: property, values: newValues, propertyDefinition: definition)
        
      }
      
    }
    
    return
/*
    switch property {
    case .locomotiveAddressType:
      if let temp = LocomotiveAddressType(title: string) {
        locomotiveAddressType = temp
      }
    case .locomotiveAddressShort:
      primaryAddress = UInt8(string)!
    case .locomotiveAddressLong:
      extendedAddress = UInt16(string)!
    case .marklinConsecutiveAddresses:
      marklinConsecutiveAddresses = MarklinConsecutiveAddresses(title: string)!
    case .enableDCCConsistAddress:
      isConsistAddressEnabled = string == "true"
    case .consistAddress:
      consistAddress = UInt8(string)!
    case .consistReverseDirection:
      isConsistReverseDirection = string == "true"
    case .enableACAnalogMode:
      isACAnalogModeEnabled = string == "true"
    case .acAnalogModeStartVoltage:
      analogModeACStartVoltage = UInt8(string)!
    case .acAnalogModeMaximumSpeedVoltage:
      analogModeACMaximumSpeedVoltage = UInt8(string)!
    case .enableDCAnalogMode:
      isDCAnalogModeEnabled = string == "true"
    case .dcAnalogModeStartVoltage:
      analogModeDCStartVoltage = UInt8(string)!
    case .dcAnalogModeMaximumSpeedVoltage:
      analogModeDCMaximumSpeedVoltage = UInt8(string)!
    case .enableQuantumEngineer:
      isQuantumEngineerEnabled = string == "true"
    case .ignoreAccelerationDecelerationInSoundSchedule:
      ignoreAccelerationDecelerationInSoundSchedule = string == "true"
    case .useHighFrequencyPWMMotorControl:
      useHighFrequencyPWMMotorControl = string == "true"
    case .analogMotorHysteresisVoltage:
      analogMotorHysteresisVoltage = UInt8(string)!
    case .analogFunctionDifferenceVoltage:
      analogFunctionDifferenceVoltage = UInt8(string)!
    case .brakeIfRightRailSignalPositive:
      abcBrakeIfRightRailMorePositive = string == "true"
    case .brakeIfLeftRailSignalPositive:
      abcBrakeIfLeftRailMorePositive = string == "true"
    case .voltageDifferenceIndicatingABCBrakeSection:
      voltageDifferenceIndicatingABCBrakeSection = UInt8(string)!
    case .abcReducedSpeed:
      abcReducedSpeed = UInt8(string)!
    case .enableABCShuttleTrain:
      isABCShuttleTrainEnabled = string == "true"
    case .waitingPeriodBeforeDirectionChange:
      abcWaitingTime = UInt8(string)!
    case .hluAllowZIMO:
      allowZIMOBrakeSections = string == "true"
    case .hluSendZIMOZACKSignals:
      sendZIMOZACKSignals = string == "true"
    case .hluSpeedLimit1:
      hluSpeedLimit1 = UInt8(string)!
    case .hluSpeedLimit2:
      hluSpeedLimit2 = UInt8(string)!
    case .hluSpeedLimit3:
      hluSpeedLimit3 = UInt8(string)!
    case .hluSpeedLimit4:
      hluSpeedLimit4 = UInt8(string)!
    case .hluSpeedLimit5:
      hluSpeedLimit5 = UInt8(string)!
    case .brakeOnForwardPolarity:
      brakeOnForwardDCPolarity = string == "true"
    case .brakeOnReversePolarity:
      brakeOnReverseDCPolarity = string == "true"
    case .selectrixBrakeOnForwardPolarity:
      selectrixBrakeOnForwardPolarity = string == "true"
    case .selectrixBrakeOnReversePolarity:
      selectrixBrakeOnReversePolarity = string == "true"
    case .enableConstantBrakeDistance:
      isConstantBrakeDistanceEnabled = string == "true"
    case .brakeDistanceLength:
      brakeDistanceLength = UInt8(string)!
    case .differentBrakeDistanceBackwards:
      isDifferentBrakeDistanceBackwards = string == "true"
    case .brakeDistanceLengthBackwards:
      brakeDistanceLengthBackwards = UInt8(string)!
    case .driveUntilLocomotiveStopsInSpecifiedPeriod:
      driveUntilLocomotiveStopsInSpecifiedPeriod = string == "true"
    case .stoppingPeriod:
      stoppingPeriod = UInt8(string)!
    case .constantBrakeDistanceOnSpeedStep0:
      constantBrakeDistanceOnSpeedStep0 = string == "true"
    case .delayTimeBeforeExitingBrakeSection:
      delayBeforeExitingBrakeSection = UInt8(string)!
    case .brakeFunction1BrakeTimeReduction:
      brakeFunction1BrakeTimeReduction = UInt8(string)!
    case .maximumSpeedWhenBrakeFunction1Active:
      maximumSpeedWhenBrakeFunction1Active = UInt8(string)!
    case .brakeFunction2BrakeTimeReduction:
      brakeFunction2BrakeTimeReduction = UInt8(string)!
    case .maximumSpeedWhenBrakeFunction2Active:
      maximumSpeedWhenBrakeFunction2Active = UInt8(string)!
    case .brakeFunction3BrakeTimeReduction:
      brakeFunction3BrakeTimeReduction = UInt8(string)!
    case .maximumSpeedWhenBrakeFunction3Active:
      maximumSpeedWhenBrakeFunction3Active = UInt8(string)!
    case .enableRailComFeedback:
      isRailComFeedbackEnabled = string == "true"
    case .enableRailComPlusAutomaticAnnouncement:
      isRailComPlusAutomaticAnnouncementEnabled = string == "true"
    case .sendAddressViaBroadcastOnChannel1:
      sendAddressViaBroadcastOnChannel1 = string == "true"
    case .allowDataTransmissionOnChannel2:
      allowDataTransmissionOnChannel2 = string == "true"
    case .detectSpeedStepModeAutomatically:
      detectSpeedStepModeAutomatically = string == "true"
    case .speedStepMode:
      speedStepMode = SpeedStepMode(title: string)!
    case .enableAcceleration:
      isAccelerationEnabled = string == "true"
    case .accelerationRate:
      accelerationRate = UInt8(string)!
    case .accelerationAdjustment:
      accelerationAdjustment = Int8(string)!
    case .enableDeceleration:
      isDecelerationEnabled = string == "true"
    case .decelerationRate:
      decelerationRate = UInt8(string)!
    case .decelerationAdjustment:
      decelerationAdjustment = Int8(string)!
    case .reverseMode:
      isReversed = string == "true"
    case .enableForwardTrim:
      isForwardTrimEnabled = string == "true"
    case .forwardTrim:
      forwardTrim = UInt8(string)!
    case .enableReverseTrim:
      isReverseTrimEnabled = string == "true"
    case .reverseTrim:
      reverseTrim = UInt8(string)!
    case .enableShuntingModeTrim:
      isShuntingModeTrimEnabled = string == "true"
    case .shuntingModeTrim:
      shuntingModeTrim = UInt8(string)!
    case .loadAdjustmentOptionalLoad:
      loadAdjustmentOptionalLoad = UInt8(string)!
    case .loadAdjustmentPrimaryLoad:
      loadAdjustmentPrimaryLoad = UInt8(string)!
    case .enableGearboxBacklashCompensation:
      isGearboxBacklashCompensationEnabled = string == "true"
    case .gearboxBacklashCompensation:
      gearboxBacklashCompensation = UInt8(string)!
    case .timeToBridgePowerInterruption:
      timeToBridgePowerInterruption = UInt8(string)!
    case .preserveDirection:
      isDirectionPreserved = string == "true"
    case .enableStartingDelay:
      isStartingDelayEnabled = string == "true"
    case .userId1:
      userId1 = UInt8(string)!
    case .userId2:
      userId2 = UInt8(string)!
    case .enableDCCProtocol:
      isDCCProtocolEnabled = string == "true"
    case .enableMarklinMotorolaProtocol:
      isMarklinMotorolaProtocolEnabled = string == "true"
    case .enableSelectrixProtocol:
      isSelectrixProtocolEnabled = string == "true"
    case .enableM4Protocol:
      isM4ProtocolEnabled = string == "true"
    case .memoryPersistentFunction:
      isMemoryPersistentFunctionEnabled = string == "true"
    case .memoryPersistentSpeed:
      isMemoryPersistentSpeedEnabled = string == "true"
    case .enableRailComPlusSynchronization:
      isDecoderSynchronizedWithMasterDecoder = string == "true"
    case .m4MasterDecoderManufacturer:
      m4MasterDecoderManufacturerId = ManufacturerCode(title: string) ?? .noneSelected
    case .m4MasterDecoderSerialNumber:
      m4MasterDecoderSerialNumber = UInt32(hex:string)!
    case .frequencyForBlinkingEffects:
      frequencyForBlinkingEffects = UInt8(string)!
    case .gradeCrossingHoldingTime:
      gradeCrossingHoldingTime = UInt8(string)!
    case .fadeInTimeOfLightEffects:
      fadeInTimeOfLightEffects = UInt8(string)!
    case .fadeOutTimeOfLightEffects:
      fadeOutTimeOfLightEffects = UInt8(string)!
    case .logicalFunctionDimmerBrightnessReduction:
      logicalFunctionDimmerBrightnessReduction = UInt8(string)!
    case .classLightLogicSequenceLength:
      classLightLogicSequenceLength = ClassLightLogicSequenceLength(title: string)!
    case .enforceSlaveCommunicationOnAUX3AndAUX4:
      isSlaveCommunicationOnAUX3andAUX4Enforced = string == "true"
    case .decoderSensorSettings:
      decoderSensorSettings = DecoderSensorSettings(title: string)!
    case .enableAutomaticUncoupling:
      isAutomaticUncouplingEnabled = string == "true"
    case .automaticUncouplingSpeed:
      automaticUncouplingSpeed = UInt8(string)!
    case .automaticUncouplingPushTime:
      automaticUncouplingPushTime = UInt8(string)!
    case .automaticUncouplingWaitTime:
      automaticUncouplingWaitTime = UInt8(string)!
    case .automaticUncouplingMoveTime:
      automaticUncouplingMoveTime = UInt8(string)!
    case .smokeUnitTimeUntilPowerOff:
      smokeUnitTimeUntilAutomaticPowerOff = UInt8(string)!
    case .smokeUnitFanSpeedTrim:
      smokeUnitFanSpeedTrim = UInt8(string)!
    case .smokeUnitTemperatureTrim:
      smokeUnitTemperatureTrim = UInt8(string)!
    case .smokeUnitPreheatingTemperatureForSecondarySmokeUnits:
      smokeUnitPreheatingTemperatureForSecondarySmokeUnits = UInt8(string)!
    case .smokeChuffsDurationRelativeToTriggerDistance:
      smokeChuffsDurationRelativeToTriggerDistance = UInt8(string)!
    case .smokeChuffsMinimumDuration:
      smokeChuffsMinimumDuration = UInt8(string)!
    case .smokeChuffsMaximumDuration:
      smokeChuffsMaximumDuration = UInt8(string)!
    case .minimumSpeed:
      minimumSpeed = UInt8(string)!
    case .maximumSpeed:
      maximumSpeed = UInt8(string)!
    case .enableLoadControlBackEMF:
      isLoadControlBackEMFEnabled = string == "true"
    case .regulationReference:
      regulationReference = UInt8(string)!
    case .regulationParameterK:
      regulationParameterK = UInt8(string)!
    case .regulationParameterI:
      regulationParameterI = UInt8(string)!
    case .regulationParameterKSlow:
      regulationParameterKSlow = UInt8(string)!
    case .largestInternalSpeedStepThatUsesKSlow:
      largestInternalSpeedStepThatUsesKSlow = UInt8(string)!
    case .regulationInfluenceDuringSlowSpeed:
      regulationInfluenceDuringSlowSpeed = UInt8(string)!
    case .slowSpeedBackEMFSamplingPeriod:
      slowSpeedBackEMFSamplingPeriod = UInt8(string)!
    case .fullSpeedBackEMFSamplingPeriod:
      fullSpeedBackEMFSamplingPeriod = UInt8(string)!
    case .slowSpeedLengthOfMeasurementGap:
      slowSpeedLengthOfMeasurementGap = UInt8(string)!
    case .fullSpeedLengthOfMeasurementGap:
      fullSpeedLengthOfMeasurementGap = UInt8(string)!
    case .enableMotorOverloadProtection:
      isMotorOverloadProtectionEnabled = string == "true"
    case .enableMotorCurrentLimiter:
      isMotorCurrentLimiterEnabled = string == "true"
    case .motorCurrentLimiterLimit:
      motorCurrentLimiterLimit = UInt8(string)!
    case .motorPulseFrequency:
      motorPulseFrequency = UInt8(string)!
    case .enableAutomaticParkingBrake:
      isAutomaticParkingBrakeEnabled = string == "true"
    case .steamChuffMode:
      steamChuffMode = SteamChuffMode(title: string)!
    case .distanceOfSteamChuffsAtSpeedStep1:
      distanceOfSteamChuffsAtSpeedStep1 = UInt8(string)!
    case .steamChuffAdjustmentAtHigherSpeedSteps:
      steamChuffAdjustmentAtHigherSpeedSteps = UInt8(string)!
    case .triggerImpulsesPerSteamChuff:
      triggerImpulsesPerSteamChuff = UInt8(string)!
    case .divideTriggerImpulsesInTwoIfShuntingModeEnabled:
      divideTriggerImpulsesInTwoIfShuntingModeEnabled = string == "true"
    case .enableSecondaryTrigger:
      isSecondaryTrimmerEnabled = string == "true"
    case .secondaryTriggerDistanceReduction:
      secondaryTriggerDistanceReduction = UInt8(string)!
    case .enableMinimumDistanceOfSteamChuffs:
      isMinimumDistanceOfSteamChuffsEnabled = string == "true"
    case .minimumDistanceofSteamChuffs:
      minimumDistanceOfSteamChuffs = UInt8(string)!
    case .masterVolume:
      masterVolume = UInt8(string)!
    case .fadeSoundVolumeReduction:
      fadeSoundVolumeReduction = UInt8(string)!
    case .soundFadeOutFadeInTime:
      soundFadeInFadeOutTime = UInt8(string)!
    case .soundBass:
      toneBass = UInt8(string)!
    case .soundTreble:
      toneTreble = UInt8(string)!
    case .brakeSoundSwitchingOnThreshold:
      brakeSoundSwitchingOnThreshold = UInt8(string)!
    case .brakeSoundSwitchingOffThreshold:
      brakeSoundSwitchingOffThreshold = UInt8(string)!
    case .soundControlBasis:
      soundControlBasis = SoundControlBasis(title: string)!
    case .trainLoadAtLowSpeed:
      trainLoadAtLowSpeed = UInt8(string)!
    case .trainLoadAtHighSpeed:
      trainLoadAtHighSpeed = UInt8(string)!
    case .enableLoadOperationThreshold:
      isThresholdForLoadOperationEnabled = string == "true"
    case .loadOperationThreshold:
      thresholdForLoadOperation = UInt8(string)!
    case .loadOperationTriggeredFunction:
      loadOperationTriggeredFunction = TriggeredFunction(title: string)!
    case .enableIdleOperationThreshold:
      isThresholdForIdleOperationEnabled = string == "true"
    case .idleOperationThreshold:
      thresholdForIdleOperation = UInt8(string)!
    case .idleOperationTriggeredFunction:
      idleOperationTriggeredFunction = TriggeredFunction(title: string)!
    case .enableSerialFunctionModeF1toF8ForLGBMTS:
      isSerialFunctionModeF1toF8ForLGBMTSEnabled = string == "true"
    case .enableSupportForBroadwayLimitedSteamEngineControl:
      isSupportForBroadwayLimitedSteamEngineControlEnabled = string == "true"
    case .enableSUSIMaster:
      isSUSIMasterEnabled = string == "true"
    case .enableSUSISlave:
      isSUSISlaveEnabled = string == "true"
    case .speedTableIndex:
      speedTableIndex = Int(string)!
    case .speedTableEntryValue:
      speedTableValue = UInt8(string)!
    case .speedTablePreset:
      speedTablePreset = SpeedTablePreset(title: string)!
    case .physicalOutput:
      esuDecoderPhysicalOutput = ESUDecoderPhysicalOutput(title: string)!
    case .physicalOutputPowerOnDelay:
      setPhysicalOutputValue(property: .physicalOutputPowerOnDelay, value: UInt8(string)!)
    case .physicalOutputPowerOffDelay:
      setPhysicalOutputValue(property: .physicalOutputPowerOffDelay, value: UInt8(string)!)
    case .physicalOutputEnableFunctionTimeout:
      setPhysicalOutputValue(property: .physicalOutputTimeUntilAutomaticPowerOff, value: (string == "true" ? 1 : 0))
    case .physicalOutputTimeUntilAutomaticPowerOff:
      setPhysicalOutputValue(property: .physicalOutputTimeUntilAutomaticPowerOff, value: UInt8(string)!)
    case .physicalOutputOutputMode:
      esuDecoderPhysicalOutputMode = ESUPhysicalOutputMode(title: string, decoder: self)!
    case .physicalOutputBrightness:
      setPhysicalOutputValue(property: .physicalOutputBrightness, value: UInt8(string)!)
    case .physicalOutputUseClassLightLogic:
      setPhysicalOutputValue(property: .physicalOutputSequencePosition, value: (string == "true" ? 1 : 0))
    case .physicalOutputSequencePosition:
      setPhysicalOutputValue(property: .physicalOutputSequencePosition, value: UInt8(string)!)
    case .physicalOutputRule17Forward:
      setPhysicalOutputBoolValue(property: .physicalOutputRule17Forward, value: string == "true")
    case .physicalOutputRule17Reverse:
      setPhysicalOutputBoolValue(property: .physicalOutputRule17Reverse, value: string == "true")
    case .physicalOutputDimmer:
      setPhysicalOutputBoolValue(property: .physicalOutputDimmer, value: string == "true")
    case .physicalOutputLEDMode:
      setPhysicalOutputBoolValue(property: .physicalOutputLEDMode, value: string == "true")
    case .physicalOutputGradeCrossing:
      setPhysicalOutputBoolValue(property: .physicalOutputGradeCrossing, value: string == "true")
    case .physicalOutputPhaseShift:
      setPhysicalOutputValue(property: .physicalOutputPhaseShift, value: UInt8(string)!)
    case .physicalOutputStartupTime:
      setPhysicalOutputValue(property: .physicalOutputStartupTime, value: UInt8(string)!)
    case .physicalOutputSmokeUnitControlMode:
      smokeUnitControlMode = SmokeUnitControlMode(title: string)!
    case .physicalOutputSpeed:
      setPhysicalOutputValue(property: .physicalOutputSpeed, value: UInt8(string)!)
    case .physicalOutputAccelerationRate:
      setPhysicalOutputValue(property: .physicalOutputAccelerationRate, value: UInt8(string)!)
    case .physicalOutputDecelerationRate:
      setPhysicalOutputValue(property: .physicalOutputDecelerationRate, value: UInt8(string)!)
    case .physicalOutputHeatWhileLocomotiveStands:
      setPhysicalOutputValue(property: .physicalOutputHeatWhileLocomotiveStands, value: UInt8(string)!)
    case .physicalOutputMinimumHeatWhileLocomotiveDriving:
      setPhysicalOutputValue(property: .physicalOutputMinimumHeatWhileLocomotiveDriving, value: UInt8(string)!)
    case .physicalOutputMaximumHeatWhileLocomotiveDriving:
      setPhysicalOutputValue(property: .physicalOutputMaximumHeatWhileLocomotiveDriving, value: UInt8(string)!)
    case .physicalOutputChuffPower:
      setPhysicalOutputValue(property: .physicalOutputChuffPower, value: UInt8(string)!)
    case .physicalOutputFanPower:
      setPhysicalOutputValue(property: .physicalOutputFanPower, value: UInt8(string)!)
    case .physicalOutputTimeout:
      setPhysicalOutputValue(property: .physicalOutputTimeout, value: UInt8(string)!)
    case .physicalOutputLevel:
      setPhysicalOutputValue(property: .physicalOutputLevel, value: UInt8(string)!)
    case .physicalOutputCouplerForce:
      setPhysicalOutputValue(property: .physicalOutputCouplerForce, value: UInt8(string)!)
    case .physicalOutputServoDurationA:
      setPhysicalOutputValue(property: .physicalOutputServoDurationA, value: UInt8(string)!)
    case .physicalOutputServoDurationB:
      setPhysicalOutputValue(property: .physicalOutputServoDurationB, value: UInt8(string)!)
    case .physicalOutputServoPositionA:
      setPhysicalOutputValue(property: .physicalOutputServoPositionA, value: UInt8(string)!)
    case .physicalOutputServoPositionB:
      setPhysicalOutputValue(property: .physicalOutputServoPositionB, value: UInt8(string)!)
    case .physicalOutputServoDoNotDisableServoPulseAtPositionA:
      setPhysicalOutputBoolValue(property: .physicalOutputServoDoNotDisableServoPulseAtPositionA, value: string == "true")
    case .physicalOutputServoDoNotDisableServoPulseAtPositionB:
      setPhysicalOutputBoolValue(property: .physicalOutputServoDoNotDisableServoPulseAtPositionB, value: string == "true")
    case .physicalOutputExternalSmokeUnitType:
      externalSmokeUnitType = ExternalSmokeUnitType(title: string)!

    default:
      break
    }
 */
    
  }
  
  // MARK: Private Class Properties
  
  private static var _delegate : IdentifyDecoderDelegate?
  
  private static var identifyDecoderState : IdentifyDecoderState = .idle
  
  // MARK: Public Class Methods
  
  public static func startIdentifyDecoder(delegate:IdentifyDecoderDelegate) {
    _delegate = delegate
    identifyDecoderState = .getManufacturer
    delegate.identifyDecoderGetCVs(cvs: [.cv_000_000_008])
  }
  
  public static func stopIdentifyDecoder() {
    _delegate = nil
    identifyDecoderState = .idle
  }
  
  public static func identifyDecoderCVRead(cvs:[(cv:CV, value:UInt8)]) {
    
    switch identifyDecoderState {
    case .idle:
      break
    case .getManufacturer:
      if let manufacturer = ManufacturerCode(rawValue: UInt16(cvs[0].value)) {
        switch manufacturer {
        case .electronicSolutionsUlmGmbH:
          identifyDecoderState = .getESUProductId
          _delegate?.identifyDecoderGetCVs(cvs: CV.consecutiveCVs(startCV: .cv_000_255_261, numberOfCVs: 4))
        default:
          break
        }
      }
    case .getESUProductId:
      var data : [UInt8] = []
      for item in cvs {
        data.append(item.value)
      }
      if let id = UInt32(bigEndianData: data.reversed()), let decoderType = DecoderType.esuProductIdLookup[id] {
    //    debugLog("Found")
      }
      else {
        
      }
    }
  }
  
}
