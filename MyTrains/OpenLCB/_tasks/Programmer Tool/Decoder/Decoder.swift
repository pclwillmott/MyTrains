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
    
    definition = DecoderType.decoderDefinitions[decoderType]
    
    if definition == nil {
      definition = DecoderDefinition(decoderType: decoderType, firmwareVersion: [], esuProductIds: [], cvs: [], defaultValues: [], mapping: [:], properties: [], esuPhysicalOutputs: [], offsetMethod: .none)
    }
    
    if let definition, !definition.cvs.isEmpty {
      
      var lastIndex : UInt16?
      
      var block = 0
      
      for cvIndex in 0 ..< definition.cvs.count {
        
        let item = definition.cvs[cvIndex]
 
        _cvs.append((item, definition.defaultValues[cvIndex]))

        let index = item.index
        
        if index != lastIndex {
          _indicies.append(index)
          indexLookup[index] = block
          block += item.isIndexed ? 256 : 1024
          lastIndex = index
        }
        
      }
      
      savedBlocks = [UInt8](repeating: 0, count: 1024 + (_indicies.count - 1) * 256)
      
    }

    super.init()
    
    for (cv, defaultValue) in _cvs {
      setSavedValue(cv: cv, value: defaultValue)
    }

    esuDecoderPhysicalOutput = decoderType.capabilities.contains(.singleFrontRearAux1Aux2) ? .frontLight : .frontLight_1
    
    revertToSaved()

  }
  
  deinit {
    
    propertyViewLookup.removeAll()
    
    cvLookup.removeAll()
    
    indexedProperties.removeAll()
    
  }
  
  // MARK: Private Properties
  
  private var _decoderType : DecoderType
  
  private var _cvs : [(cv: CV, defaultValue:UInt8)] = []
  
  private var savedBlocks : [UInt8] = []
  
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
  
  internal var propertyViewLookup : [ProgrammerToolSettingsProperty:PTSettingsPropertyView] = [:]
  
  private var cvLookup : [CV:[PTSettingsPropertyView]] = [:]
  
  private var indexedProperties : [CVIndexingMethod:[PTSettingsPropertyView]] = [:]

  // MARK: Public Properties
  
  public var decoderType : DecoderType {
    return _decoderType
  }
  
  private var definition : DecoderDefinition?
  
  public var esuPhysicalOutputCVIndexOffsetMethod : ESUPhysicalOutputCVIndexOffsetMethod {
    guard let definition else {
      return .none
    }
    return definition.offsetMethod
  }
  
  public var propertyViews : [PTSettingsPropertyView] = [] {
    
    didSet {
      
      /*
      do {
        
        let url = URL(fileURLWithPath: "\(Bundle.main.resourcePath!)/DECODER_INFO.json")
        
        let json = try Data(contentsOf: url)
        
        let jsonDecoder = JSONDecoder()
        
        let decoderTypes = try jsonDecoder.decode([DecoderType:DecoderDefinition].self, from: json)
        
        definition = decoderTypes[decoderType]
        
      } catch {
        
      }
       
       */
      
      guard let definition else {
        #if DEBUG
        debugLog("Definition is still nil")
        #endif
        return
      }
      
      for view in propertyViews {
        
        if definition.properties.contains(view.property) {
          
          propertyViewLookup[view.property] = view
          
          if let indexingMethod = view.indexingMethod, indexingMethod != .standard {
            
            var views = [view]
            
            if let temp = indexedProperties[indexingMethod] {
              views.append(contentsOf: temp)
            }
            
            indexedProperties[indexingMethod] = views
            
          }
          
          if let cvs = view.definition.cv {
            
            for cv in cvs {
              
              var views : [PTSettingsPropertyView] = [view]
              
              if let temp = cvLookup[cv] {
                views.append(contentsOf: temp)
              }
              
              cvLookup[cv] = views
              
            }
            
          }
          
          view.decoder = self
          
        }
        else {
          view.isExtant = false
        }
        
      }
      
      delegate?.displaySettingsInspector?(self)
      
      applyLayoutRules()
      
    }
    
  }
  
  public var cvs : [(cv: CV, defaultValue:UInt8)] {
    return _cvs
  }
  
  public var cvSet : Set<CV> {
    var result : Set<CV> = []
    for cv in cvs {
      result.insert(cv.cv)
    }
    return result
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
              else if let cvConstant = CV(index: index, cv: cv, indexMethod: .cv3132) {
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
      if let _ = item.cvMask(decoder: self) {
        result.insert(item)
      }
    }
    return result
  }
  
  public var supportedFunctionsAnalogMode : Set<FunctionAnalogMode> {
    var result : Set<FunctionAnalogMode> = []
    for item in FunctionAnalogMode.allCases {
      if let _ = item.cvMask(decoder: self) {
        result.insert(item)
      }
    }
    return result
  }
  
  private var _speedTableIndex : Int = 1
  
  public var speedTableIndex : Int { // *** KEEP ***
    get {
      return _speedTableIndex
    }
    set(value) {
      if value != _speedTableIndex {
        _speedTableIndex = value
        propertyViewLookup[.speedTableIndex]?.reload()
        propertyViewLookup[.speedTableEntryValue]?.reload()
        propertyViewLookup[.esuSpeedTable]?.reload()
      }
    }
  }

  private func reloadIndexedViews(indexingMethod:CVIndexingMethod?) {
    if let indexingMethod, let views = indexedProperties[indexingMethod] {
      for view in views {
        view.reload()
      }
    }
  }
  
  private var esuRandomFunction : ESURandomFunction = .random1 {
    didSet {
      reloadIndexedViews(indexingMethod: .esuRandomFunction)
      applyLayoutRules()
    }
  }
  
  private var esuSoundType : ESUSoundType = .dieselHydraulical {
    didSet {
      applyLayoutRules()
    }
  }
  
  public var esuDecoderPhysicalOutput : ESUDecoderPhysicalOutput = .frontLight_1 {
    didSet {
      reloadIndexedViews(indexingMethod: .esuDecoderPhysicalOutput)
      _layoutRules = nil
      applyLayoutRules()
    }
  }
  
  public var esuSupportedPhysicalOutputs : Set<ESUDecoderPhysicalOutput> {
    
    guard let definition else {
      return []
    }
    
    return definition.esuPhysicalOutputs
    
    /*
    let capabilities = decoderType.capabilities
    
    var result : Set<ESUDecoderPhysicalOutput> = []
    
    if capabilities.contains(.singleFrontRearAux1Aux2) {
      result = result.union([
        .frontLight,
        .rearLight,
      ])
      if capabilities.intersection([.aux3toAux4]) == [.aux3toAux4] {
        result = result.union([
          .aux3,
          .aux4,
        ])
      }
      if capabilities.intersection([.aux1]) == [.aux1] {
        result = result.union([
          .aux1,
        ])
      }
      if capabilities.intersection([.aux2]) == [.aux2] {
        result = result.union([
          .aux2,
        ])
      }
    }
    else {
      result = result.union([
        .frontLight_1,
        .frontLight_2,
        .rearLight_1,
        .rearLight_2,
      ])
      if capabilities.intersection([.aux1]) == [.aux1] {
        result = result.union([
          .aux1_1,
          .aux1_2,
        ])
      }
      if capabilities.intersection([.aux2]) == [.aux2] {
        result = result.union([
          .aux2_1,
          .aux2_2,
        ])
      }
      if capabilities.intersection([.aux3toAux4]) == [.aux3toAux4] {
        result = result.union([
          .aux3,
          .aux4,
        ])
      }
    }
    
    if capabilities.intersection([.aux5toAux6]) == [.aux5toAux6] {
      result = result.union([
        .aux5,
        .aux6,
      ])
    }

    if capabilities.intersection([.aux7toAux8]) == [.aux7toAux8] {
      result = result.union([
        .aux7,
        .aux8,
      ])
    }

    if capabilities.intersection([.aux9toAux10]) == [.aux9toAux10] {
      result = result.union([
        .aux9,
        .aux10,
      ])
    }

    if capabilities.intersection([.aux11toAux12]) == [.aux11toAux12] {
      result = result.union([
        .aux11,
        .aux12,
      ])
    }

    if capabilities.intersection([.aux13toAux18]) == [.aux13toAux18] {
      
      result = result.union([
        .aux13,
        .aux14,
        .aux15,
        .aux16,
        .aux17,
        .aux18,
      ])
      
    }
    
    return result
    */
    
  }
  
  public var soundCV : SoundCV = .soundCV1 {
    didSet {
      reloadIndexedViews(indexingMethod: .soundCV)
    }
  }
  
  public var esuSoundSlot : ESUSoundSlot = .soundSlot1 {
    didSet {
      reloadIndexedViews(indexingMethod: .esuSoundSlot)
    }
  }
  
  public var esuFunction : TriggeredFunction = .f0 {
    didSet {
      reloadIndexedViews(indexingMethod: .esuFunction)
    }
  }
  
  public var esuFunctionMapping : ESUFunctionMapping = .mapping1 {
    didSet {
      reloadIndexedViews(indexingMethod: .esuFunctionMapping)
    }
  }
  
  public var esuDecoderPhysicalOutputMode : ESUPhysicalOutputMode {
    return ESUPhysicalOutputMode(title: getValue(property: .physicalOutputOutputMode), decoder: self)!
  }
  
  public func cvIndexOffset(indexingMethod:CVIndexingMethod) -> Int {
    
    switch indexingMethod {
    case .standard:
      return 0
    case .esuDecoderPhysicalOutput:
      return esuDecoderPhysicalOutput.cvIndexOffset(decoder: self)
    case .esuRandomFunction:
      return esuRandomFunction.cvIndexOffset(decoder: self)
    case .soundCV:
      return soundCV.cvIndexOffset(decoder: self)
    case .esuSoundSlot:
      return esuSoundSlot.cvIndexOffset(decoder: self)
    case .esuFunction:
      return esuFunction.cvIndexOffset(decoder:self)
    case .esuFunctionMapping:
      return esuFunctionMapping.cvIndexOffset(decoder: self)
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
        
        if let views = cvLookup[cvs[index]] {
          for view in views {
            view.reload()
          }
        }
        
      }
      
    }

  }

  // MARK: Public Methods
  
  public func getSFMappingState(mapIndex:Int) -> Bool {
    
    let row = mapIndex / 16
    
    let column = mapIndex % 16
    
    var cv : CV = .cv_000_252_257 + (row * 4)
    
    if column > 7 {
      cv = cv + 1
    }
    
    let mask : UInt8 = 1 << (column & 0x07)
    
    return getBool(cv: cv, mask: mask)!
    
  }
  
  public func setSFMappingState(mapIndex:Int, value:Bool) {
    
    let row = mapIndex / 16
    
    let column = mapIndex % 16
    
    var cv : CV = .cv_000_252_257 + (row * 4)
    
    if column > 7 {
      cv = cv + 1
    }
    
    let mask : UInt8 = 1 << (column & 0x07)
    
    setBool(cv: cv, mask: mask, value: value)
    
  }
  
  public func getConsistFunctionState(function:FunctionConsistMode) -> Bool {
    let cvMask = function.cvMask(decoder: self)!
    return getBool(cv: cvMask.cv, mask: cvMask.mask)!
  }
  
  public func setConsistFunctionState(function:FunctionConsistMode, state:Bool) {
    let cvMask = function.cvMask(decoder: self)!
    setBool(cv: cvMask.cv, mask: cvMask.mask, value: state)
  }

  public func getAnalogFunctionState(function:FunctionAnalogMode) -> Bool {
    let cvMask = function.cvMask(decoder: self)!
    return getBool(cv: cvMask.cv, mask: cvMask.mask)!
  }
  
  public func setAnalogFunctionState(function:FunctionAnalogMode, state:Bool) {
    let cvMask = function.cvMask(decoder: self)!
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
    guard let temp = getUInt8(cv: cv) else {
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
  
  public func reloadAll() {
    for view in propertyViews {
      view.reload()
    }
  }
  
  public func setBool(cv:CV, mask:UInt8, value:Bool) {

    guard let byte = getUInt8(cv: cv), let offset = indexLookup[cv.index] else {
      return
    }
    
    modifiedBlocks[offset + Int(cv.cv) - 1 - (cv.isIndexed ? 256 : 0)] = (byte & ~mask) | (value ? mask : 0)

  }
  
  public func getUInt8(cv:CV) -> UInt8? {
    
    guard let offset = indexLookup[cv.index] else {
      return nil
    }
    
    return modifiedBlocks[offset + Int(cv.cv) - 1 - (cv.isIndexed ? 256 : 0)]
    
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
  
  private var dateFormatter = DateFormatter()
  
  public func getValue(property:ProgrammerToolSettingsProperty, definition : ProgrammerToolSettingsPropertyDefinition? = nil) -> String {
    
    let excludedEncodings : Set<ProgrammerToolEncodingType> = [
      .custom,
      .none,
    ]
    
    guard let definition = definition ?? ProgrammerToolSettingsProperty.definitions[property], !excludedEncodings.contains(definition.encoding) else {
      return ""
    }
    
    switch definition.encoding {
    case .esuSpeedTablePreset:
      return SpeedTablePreset.doNothing.title
    case .esuSoundType:
      return esuSoundType.title
    case .threeValueSpeedTablePreset:
      return ThreeValueSpeedTablePreset.identity.title
    case .esuDecoderPhysicalOutput:
      return esuDecoderPhysicalOutput.title
    case .esuRandomFunction:
      return esuRandomFunction.title
    case .esuFunctionMapping:
      return esuFunctionMapping.title
    case .esuFunction:
      return esuFunction.title
    case .soundCV:
      return soundCV.title
    case .esuSoundSlot:
      return esuSoundSlot.title
    case .speedTableIndex:
      return "\(speedTableIndex)"
    default:
      break
    }
    
    var values = getProperty(property: property, propertyDefinition: definition)
    
    guard values.count > 0 else {
      return ""
    }
    
    if let baseProperty = property.minMaxBaseProperty {
      let index = property.rawValue - baseProperty.rawValue
      values = [values[index]]
    }
    
    switch definition.encoding {
    case .byte:
      return "\(values[0])"
    case .boolBit:
      return values[0] == definition.mask![0] ? "true" : "false"
    case .boolBitReversed:
      return values[0] == definition.mask![0] ? "false" : "true"
    case .boolNZ:
      return values[0] != 0 ? "true" : "false"
    case .boolNZReversed:
      return values[0] != 0 ? "false" : "true"
    case .dword:
      return "\(UInt32(bigEndianData: values.reversed())!)"
    case .word:
      return "\(UInt16(bigEndianData: values.reversed())!)"
    case .zString:
      var data = values
      data.append(0)
      return String(cString: data)
    case .locomotiveAddressType:
      return (values[0] == definition.mask![0] ? LocomotiveAddressType.extended : LocomotiveAddressType.primary).title
    case .extendedAddress:
      return "\((( UInt16(values[0]) << 8) | UInt16(values[1])) - 49152)"
    case .specialInt8:
      return "\(Int8(values[0] & 0x7f) * (((values[0] & ByteMask.d7) == ByteMask.d7) ? -1 : 1))"
    case .esuExternalSmokeUnitType:
      if let item = ExternalSmokeUnitType(rawValue: values[0]) {
        return item.title
      }
    case .esuMarklinConsecutiveAddresses:
      if let item = MarklinConsecutiveAddresses(rawValue: values[0]) {
        return item.title
      }
    case .esuSpeedStepMode:
      if let item = SpeedStepMode(rawValue: values[0]) {
        return item.title
      }
    case .esuBrakingMode:
      if let item = ESUBrakingMode(rawValue:values[0]) {
        return item.title
      }
    case .manufacturerCode:
      if let item = ManufacturerCode(rawValue:UInt16(values[0])) {
        return item.title
      }
    case .speedTableType:
      if let item = SpeedTableType(rawValue:values[0]) {
        return item.title
      }
    case .esuCondition:
      if let item = ESUCondition(rawValue: values[0]) {
        return item.title
      }
    case .esuConditionDriving:
      if let item = ESUConditionDriving(rawValue: values[0]) {
        return item.title
      }
    case .esuConditionDirection:
      if let item = ESUConditionDirection(rawValue: values[0]) {
        return item.title
      }
    case .esuDecoderSensorSettings:
      if let item = DecoderSensorSettings(rawValue: values[0]) {
        return item.title
      }
    case .esuDCMotorPWMFrequency:
      if let item = ESUDCMotorPWMFrequency(rawValue:values[0]) {
        return item.title
      }
    case .esuDCMotorPWMFrequencyLok3:
      if let item = ESUDCMotorPWMFrequencyLok3(rawValue:values[0]) {
        return item.title
      }
    case .esuSteamChuffMode:
      return (values[0] == 0 ? SteamChuffMode.useExternalWheelSensor : SteamChuffMode.playSteamChuffsAccordingToSpeed).title
    case .esuSoundControlBasis:
      return (values[0] == 0 ? SoundControlBasis.accelerationAndBrakeTime : SoundControlBasis.accelerationAndBrakeTimeAndTrainLoad).title
    case .esuFunctionIcon:
      if let item = ESUFunctionIcon(rawValue: values[1]) {
        return item.title
      }
    case .esuSmokeUnitControlMode:
      if let item = SmokeUnitControlMode(rawValue: values[0]) {
        return item.title
      }
    case .esuPhysicalOutputMode:
      if let item = ESUPhysicalOutputMode(rawValue: values[0]) {
        return item.title(decoder: self)
      }
    case .esuPhysicalOutputModeB:
      if let item = ESUPhysicalOutputModeB(rawValue: values[0]) {
        return item.title(decoder: self)
      }
    case .esuClassLightLogicLength:
      if let item = ClassLightLogicSequenceLength(rawValue: values[0]) {
        return item.title
      }
    case .speedTableValue, .speedTableValueB:
      return "\(values[speedTableIndex - 1])"
    case .esuTriggeredFunction:
      if let item = TriggeredFunction(rawValue: values[0]) {
        return item.title
      }
    case .dWordHex:
      return UInt32(bigEndianData: values.reversed())!.toHex(numberOfDigits: 8)
    case .analogModeEnable:
      return values[1] == definition.mask![1] ? "true" : "false"
    case .manufacturerName:
      return ManufacturerCode(rawValue: UInt16(values[0]))?.title ?? ""
    case .railComDate:

      let date = Date(timeIntervalSince1970: 946684800.0 + Double(UInt32(bigEndianData: values.reversed())!)) // 1-1-2000
      
      dateFormatter.calendar = NSLocale.autoupdatingCurrent.calendar
      dateFormatter.locale = NSLocale.autoupdatingCurrent
      dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
      dateFormatter.dateStyle = .long
      
      return dateFormatter.string(from: date)
      
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

    var values = getProperty(property: property, propertyDefinition: definition)

    if let baseProperty = property.minMaxBaseProperty {
      let index = property.rawValue - baseProperty.rawValue
      values = [values[index]]
    }

    var doubleValue : Double

    switch definition.encoding {
    case .specialInt8:
      doubleValue = Double((Int8(values[0] & 0x7f) * (((values[0] & ByteMask.d7) == ByteMask.d7) ? -1 : 1)))
    default:
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
    case .esuFunctionCategory:
      return ESUFunctionIconCategory(rawValue: values[0])!.title

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
    
    guard let definition = definition ?? ProgrammerToolSettingsProperty.definitions[property] else {
      return true
    }
    
    switch definition.encoding {
    case .zString:
      guard let maxValue = definition.maxValue, let minValue = definition.minValue, Int(minValue) ... Int(maxValue) ~= string.utf8.count else {
        return false
      }
    case .dWordHex:
      guard let _ = UInt32(hex:string) else {
        return false
      }
    case .speedTableValue:
      
      guard let maxValue = definition.maxValue, let minValue = definition.minValue, let value = Int(string) else {
        return false
      }
      
      if !(Int(minValue) ... Int(maxValue) ~= value) {
        return false
      }
      
      if speedTableIndex == 1 && value != 1 {
        return false
      }

      if speedTableIndex == 28 && value != 255 {
        return false
      }

    case .speedTableValueB:
      
      guard let maxValue = definition.maxValue, let minValue = definition.minValue, let value = Int(string) else {
        return false
      }
      
      if !(Int(minValue) ... Int(maxValue) ~= value) {
        return false
      }
      
    case .esuDecoderPhysicalOutput:
      return ESUDecoderPhysicalOutput(title: string) != nil
    case .esuPhysicalOutputMode:
      return ESUPhysicalOutputMode(title: string, decoder: self) != nil
    case .esuSoundType:
      return ESUSoundType(title:string) != nil
    case .esuPhysicalOutputModeB:
      return ESUPhysicalOutputModeB(title: string, decoder: self) != nil
    case .esuSteamChuffMode:
      return SteamChuffMode(title: string) != nil
    case .esuSmokeUnitControlMode:
      return SmokeUnitControlMode(title: string) != nil
    case .esuExternalSmokeUnitType:
      return ExternalSmokeUnitType(title: string) != nil
    case .esuSoundControlBasis:
      return SoundControlBasis(title: string) != nil
    case .esuBrakingMode:
      return ESUBrakingMode(title:string) != nil
    case .esuTriggeredFunction:
      return TriggeredFunction(title: string) != nil
    case .esuSpeedTablePreset:
      return SpeedTablePreset(title: string) != nil
    case .threeValueSpeedTablePreset:
      return ThreeValueSpeedTablePreset(title: string) != nil
    case .locomotiveAddressType:
      return LocomotiveAddressType(title: string) != nil
    case .esuMarklinConsecutiveAddresses:
      return MarklinConsecutiveAddresses(title: string) != nil
    case .esuSpeedStepMode:
      return SpeedStepMode(title: string) != nil
    case .manufacturerCode:
      return ManufacturerCode(title: string) != nil
    case .esuDecoderSensorSettings:
      return DecoderSensorSettings(title: string) != nil
    case .esuClassLightLogicLength:
      return ClassLightLogicSequenceLength(title: string) != nil
    case .esuRandomFunction:
      return ESURandomFunction(title: string) != nil
    case .soundCV:
      return SoundCV(title: string) != nil
    case .esuSoundSlot:
      return ESUSoundSlot(title: string) != nil
    case .esuFunctionIcon:
      return ESUFunctionIcon(title: string) != nil
    case .esuFunctionMapping:
      return ESUFunctionMapping(title: string) != nil
    case .esuCondition:
      return ESUCondition(title: string) != nil
    case .esuConditionDriving:
      return ESUConditionDriving(title: string) != nil
    case .esuConditionDirection:
      return ESUConditionDirection(title: string) != nil
    case .speedTableType:
      return SpeedTableType(title: string) != nil
    case .esuDCMotorPWMFrequency:
      return ESUDCMotorPWMFrequency(title: string) != nil
    case .esuDCMotorPWMFrequencyLok3:
      return ESUDCMotorPWMFrequencyLok3(title: string) != nil
    default:
      guard let maxValue = definition.maxValue, let minValue = definition.minValue, let value = Int(string), value >= Int(minValue) && value <= Int(maxValue) else {
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
    case .boolBitReversed:
      newValues.append(string == "false" ? definition.mask![0] : 0)
    case .boolNZ:
      newValues.append(string == "true" ? definition.trueDefaultValue! : 0)
    case .boolNZReversed:
      newValues.append(string == "false" ? definition.trueDefaultValue! : 0)
    case .word:
      newValues.append(contentsOf: UInt16(string)!.bigEndianData.reversed())
    case .dword:
      newValues.append(contentsOf: UInt32(string)!.bigEndianData.reversed())
    case .zString:
      newValues = [UInt8](string.padWithNull(length: 29).prefix(28))
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
      newValues.append(MarklinConsecutiveAddresses(title: string)!.rawValue)
    case .esuSpeedStepMode:
      newValues.append(SpeedStepMode(title: string)!.rawValue)
    case .esuFunctionIcon:
      let icon = ESUFunctionIcon(title: string)!
      newValues.append(icon.category.rawValue)
      newValues.append(icon.rawValue)
    case .manufacturerCode:
      newValues.append(UInt8(ManufacturerCode(title: string)!.rawValue))
    case .esuDecoderSensorSettings:
      newValues.append(DecoderSensorSettings(title: string)!.rawValue)
    case .esuSteamChuffMode:
      newValues.append(SteamChuffMode(title: string)! == .playSteamChuffsAccordingToSpeed ? definition.trueDefaultValue! : 0)
    case .esuSoundControlBasis:
      newValues.append(SoundControlBasis(title: string)! == .accelerationAndBrakeTimeAndTrainLoad ? definition.trueDefaultValue! : 0)
    case .esuCondition:
      newValues.append(ESUCondition(title: string)!.rawValue)
    case .esuConditionDriving:
      newValues.append(ESUConditionDriving(title: string)!.rawValue)
    case .esuConditionDirection:
      newValues.append(ESUConditionDirection(title: string)!.rawValue)
    case .threeValueSpeedTablePreset:
      
      let speedTablePreset = ThreeValueSpeedTablePreset(title: string)!
      
      if !speedTablePreset.speedTableValues.isEmpty {
        newValues = speedTablePreset.speedTableValues
      }

    case .esuSpeedTablePreset:
      
      let speedTablePreset = SpeedTablePreset(title: string)!
      
      if !speedTablePreset.speedTableValues.isEmpty {
        newValues = speedTablePreset.speedTableValues
      }
      else if speedTablePreset == .linearUntilFirstMaximumValue {
        newValues = getProperty(property: .speedTablePreset)
        var firstMax : Int = 0
        for index in 0 ... 27 {
          if newValues[index] == 255 {
            firstMax = index
            break
          }
        }
        for index in 1 ... firstMax - 1 {
          newValues[index] = UInt8(1 + (255 - 1) * Double(index) / Double(firstMax))
        }
      }
      
    case .esuDecoderPhysicalOutput:
      esuDecoderPhysicalOutput = ESUDecoderPhysicalOutput(title: string)!
    case .soundCV:
      soundCV = SoundCV(title: string)!
    case .esuSoundSlot:
      esuSoundSlot = ESUSoundSlot(title: string)!
      
    case .esuSoundType:
      
      let item = ESUSoundType(title: string)!
      
      if item != esuSoundType {
        
        esuSoundType = item
        
        let values = getProperty(property: property)
        
        switch esuSoundType {
        case .dieselHydraulical:
          newValues = [0, 0]
        case .dieselMechanical:
          newValues = [1, 0]
        case .electricOrDieselElectric:
          newValues = [0, max(values[1], 1)]
        case .steamLocomotiveWithoutExternalSensor:
          newValues = [max(values[0], 1), max(values[1], 1)]
        case .steamLocomotiveWithExternalSensor:
          newValues = [0, max(values[1], 1)]
        }
        
      }
      
    case .esuRandomFunction:
      esuRandomFunction = ESURandomFunction(title: string)!
    case .esuFunction:
      esuFunction = TriggeredFunction(title: string)!
    case .esuFunctionMapping:
      esuFunctionMapping = ESUFunctionMapping(title: string)!
    case .esuDCMotorPWMFrequency:
      newValues.append(ESUDCMotorPWMFrequency(title:string)!.rawValue)
    case .esuDCMotorPWMFrequencyLok3:
      newValues.append(ESUDCMotorPWMFrequencyLok3(title:string)!.rawValue)
    case .esuSmokeUnitControlMode:
      newValues.append(SmokeUnitControlMode(title: string)!.rawValue)
    case .esuBrakingMode:
      newValues.append(ESUBrakingMode(title: string)!.rawValue)
    case .esuPhysicalOutputMode:
      newValues.append(ESUPhysicalOutputMode(title: string, decoder: self)!.rawValue)
    case .esuPhysicalOutputModeB:
      newValues.append(ESUPhysicalOutputModeB(title: string, decoder: self)!.rawValue)
    case .esuClassLightLogicLength:
      newValues.append(ClassLightLogicSequenceLength(title: string)!.rawValue)
    case .speedTableIndex:
      speedTableIndex = Int(string)!
    case .speedTableValue:
      
      newValues = getProperty(property: property, propertyDefinition: definition)
      
      let value = UInt8(string)!
      
      newValues[speedTableIndex - 1] = value
      
      if speedTableIndex > 2 {
        for index in 2 ... speedTableIndex - 1 {
          newValues[index - 1] = min(newValues[index - 1], value)
        }
      }
      
      if speedTableIndex < 27 {
        for index in speedTableIndex + 1 ... 27 {
          newValues[index - 1] = max(newValues[index - 1], value)
        }
      }
      
    case .speedTableValueB:
      
      newValues = getProperty(property: property, propertyDefinition: definition)
      
      let value = UInt8(string)!
      
      newValues[speedTableIndex - 1] = value
      
      if speedTableIndex > 1 {
        for index in 1 ... speedTableIndex - 1 {
          newValues[index - 1] = min(newValues[index - 1], value)
        }
      }
      
      if speedTableIndex < 28 {
        for index in speedTableIndex + 1 ... 28 {
          newValues[index - 1] = max(newValues[index - 1], value)
        }
      }
      
    case .esuTriggeredFunction:
      newValues.append(TriggeredFunction(title: string)!.rawValue)
    case .dWordHex:
      newValues = UInt32(hex: string)!.bigEndianData.reversed()
    case .speedTableType:
      newValues = [SpeedTableType(title:string)!.rawValue]
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
    
    if let baseProperty = property.minMaxBaseProperty {
      let index = property.rawValue - baseProperty.rawValue
      let value = newValues[0]
      newValues = getProperty(property: property, propertyDefinition: definition)
      newValues[index] = value
      if index > 0 {
        for tempIndex in 0 ... index - 1 {
          newValues[tempIndex] = min(newValues[tempIndex], value)
        }
      }
      if index < newValues.count - 1 {
        for tempIndex in index + 1 ... newValues.count - 1 {
          newValues[tempIndex] = max(newValues[tempIndex], value)
        }
      }
    }

    if !newValues.isEmpty {
      
      let values = getProperty(property: property, propertyDefinition: definition)
      
      if values != newValues {
        
        setProperty(property: property, values: newValues, propertyDefinition: definition)
        
        if definition.controlType == .comboBoxDynamic {
          _layoutRules = nil
        }
        
      }
      
    }
    
    applyLayoutRules(property:property)
    
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
      }
      else {
        
      }
    }
  }
  
  // MARK: Layout Rules
  
  internal var _layoutRules : [PTSettingsPropertyLayoutRule]?
  
  internal var layoutRuleLookupTestProperties : [ProgrammerToolSettingsProperty:[PTSettingsPropertyLayoutRule]] = [:]

  internal var layoutRuleLookupActionProperties : [ProgrammerToolSettingsProperty:[PTSettingsPropertyLayoutRule]] = [:]
  
  public func applyLayoutRules(property:ProgrammerToolSettingsProperty? = nil) {
    
    func applyProperty(property:ProgrammerToolSettingsProperty) {
      
      guard let rules = layoutRuleLookupTestProperties[property] else {
        return
      }

      var actionProperties : Set<ProgrammerToolSettingsProperty> = []
      
      for rule in rules {
        actionProperties = actionProperties.union(rule.actionProperty)
      }
      
      for actionProperty in actionProperties {
        
        if let rules = layoutRuleLookupActionProperties[actionProperty] {
          
          var isHidden : Bool?
          var isExtant : Bool?
          
          for rule in rules {
            
            var result : Bool
            
            let operand = getValue(property: rule.property1)
            
            switch rule.testType1 {
            case .equal:
              result = operand == rule.testValue1
            case .notEqual:
              result = operand != rule.testValue1
            }
            
            if let property = rule.property2, let testType = rule.testType2, let testValue = rule.testValue2, let ruleOperator = rule.operator {

              var result2 : Bool
              
              let operand = getValue(property: property)

              switch testType {
              case .equal:
                result2 = operand == testValue
              case .notEqual:
                result2 = operand != testValue
              }
              
              switch ruleOperator {
              case .and:
                result = result && result2
              case .or:
                result = result || result2
                break
              }

            }
            
            switch rule.actionType {
            case .setIsExtantToTestResult:
              if isExtant == nil {
                isExtant = result
              }
              else {
                isExtant = isExtant! && result
              }
            case .setIsHiddenToTestResult:
              if isHidden == nil {
                isHidden = result
              }
              else {
                isHidden = isHidden! || result
              }
            }
            
            if let isHidden, isHidden {
              break
            }
            
          }
          
          if let isExtant, let view = propertyViewLookup[actionProperty] {
            view.isExtant = isExtant
          }

          if let isHidden, let view = propertyViewLookup[actionProperty] {
            view.isHidden = isHidden
          }

        }
        
      }

    }
    
    buildLayoutRules()
    
    if let property = property {
      applyProperty(property: property)
    }
    else {
      for property in ProgrammerToolSettingsProperty.allCases {
        applyProperty(property: property)
      }
    }
    
  }
  
}
