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
  
  // MARK: Public Properties
  
  public var decoderType : DecoderType {
    return _decoderType
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
  
  public var manufacturer : ManufacturerCode? {
    return ManufacturerCode(rawValue: UInt16(getUInt8(cv: .cv_000_000_008)!))
  }
  
  public var locomotiveAddressType : LocomotiveAddressType {
    get {
      return getBool(cv: .cv_000_000_029, mask: ByteMask.d5)! ? .extended : .primary
    }
    set(value) {
      if value != locomotiveAddressType {
        setBool(cv: .cv_000_000_029, mask: ByteMask.d5, value: value == .extended)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var primaryAddress : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_001)! & 0x7f
    }
    set(value) {
      setMaskedUInt8(cv: .cv_000_000_001, mask: 0x7f, value: value)
    }
  }
  
  public var extendedAddress : UInt16 {
    get {
      return ((UInt16(getUInt8(cv: .cv_000_000_017)!) << 8) | UInt16(getUInt8(cv: .cv_000_000_018)!)) - 49152
    }
    set(value) {
      let temp = value + 49152
      setUInt8(cv: .cv_000_000_017, value: UInt8(temp >> 8))
      setUInt8(cv: .cv_000_000_018, value: UInt8(temp & 0xff))
    }
  }
  
  public var marklinConsecutiveAddresses : MarklinConsecutiveAddresses {
    get {
      return MarklinConsecutiveAddresses(rawValue: getUInt8(cv: .cv_000_000_049)! & MarklinConsecutiveAddresses.mask)!
    }
    set(value) {
      setMaskedUInt8(cv: .cv_000_000_049, mask: MarklinConsecutiveAddresses.mask, value: value.rawValue)
    }
  }
  
  public var isConsistAddressEnabled : Bool {
    get {
      return consistAddress != 0
    }
    set(value) {
      if value != isConsistAddressEnabled {
        consistAddress = value ? 1 : 0
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var consistAddress : UInt8 {
    get {
      return getMaskedUInt8(cv: .cv_000_000_019, mask: 0b01111111)!
    }
    set(value) {
      setMaskedUInt8(cv: .cv_000_000_019, mask: 0b01111111, value: value)
    }
  }
  
  public var isConsistReverseDirection : Bool {
    get {
      return getMaskedUInt8(cv: .cv_000_000_019, mask: ByteMask.d7)! == ByteMask.d7
    }
    set(value) {
      setMaskedUInt8(cv: .cv_000_000_019, mask: ByteMask.d7, value: value ? ByteMask.d7 : 0)
    }
  }
  
  public var isAnalogModeEnabled : Bool {
    get {
      return getBool(cv: .cv_000_000_029, mask: ByteMask.d2)!
    }
    set(value) {
      setMaskedUInt8(cv: .cv_000_000_029, mask: ByteMask.d2, value: value ? ByteMask.d2 : 0)
    }
  }
  
  public var isACAnalogModeEnabled : Bool {
    get {
      return getBool(cv: .cv_000_000_050, mask: ByteMask.d0)!
    }
    set(value) {
      if value != isACAnalogModeEnabled {
        setMaskedUInt8(cv: .cv_000_000_050, mask: ByteMask.d0, value: value ? ByteMask.d0 : 0)
        if value {
          isAnalogModeEnabled = true
        }
        else if !isDCAnalogModeEnabled {
          isAnalogModeEnabled = false
        }
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var isDCAnalogModeEnabled : Bool {
    get {
      return getBool(cv: .cv_000_000_050, mask: ByteMask.d1)!
    }
    set(value) {
      if value != isDCAnalogModeEnabled {
        setMaskedUInt8(cv: .cv_000_000_050, mask: ByteMask.d1, value: value ? ByteMask.d1 : 0)
        if value {
          isAnalogModeEnabled = true
        }
        else if !isACAnalogModeEnabled {
          isAnalogModeEnabled = false
        }
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var analogModeACStartVoltage : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_127)!
    }
    set(value) {
      if value != analogModeACStartVoltage {
        setUInt8(cv: .cv_000_000_127, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var analogModeACStartVoltageInVolts : Double {
    return Double(analogModeACStartVoltage) / 10.0
  }

  public var analogModeACMaximumSpeedVoltage : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_128)!
    }
    set(value) {
      if value != analogModeACMaximumSpeedVoltage {
        setUInt8(cv: .cv_000_000_128, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var analogModeACMaximumSpeedVoltageInVolts : Double {
    return Double(analogModeACMaximumSpeedVoltage) / 10.0
  }

  public var analogModeDCStartVoltage : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_125)!
    }
    set(value) {
      if value != analogModeDCStartVoltage {
        setUInt8(cv: .cv_000_000_125, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var analogModeDCStartVoltageInVolts : Double {
    return Double(analogModeDCStartVoltage) / 10.0
  }

  public var analogModeDCMaximumSpeedVoltage : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_126)!
    }
    set(value) {
      if value != analogModeDCMaximumSpeedVoltage {
        setUInt8(cv: .cv_000_000_126, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var analogModeDCMaximumSpeedVoltageInVolts : Double {
    return Double(analogModeDCMaximumSpeedVoltage) / 10.0
  }
  
  public var isQuantumEngineerEnabled : Bool {
    get {
      return getBool(cv: .cv_000_000_050, mask: ByteMask.d2)!
    }
    set(value) {
      setBool(cv: .cv_000_000_050, mask: ByteMask.d2, value: value)
    }
  }
  
  public var ignoreAccelerationDecelerationInSoundSchedule : Bool {
    get {
      return getBool(cv: .cv_000_000_122, mask: ByteMask.d5)!
    }
    set(value) {
      setBool(cv: .cv_000_000_122, mask: ByteMask.d5, value: value)
    }
  }
  
  public var useHighFrequencyPWMMotorControl : Bool {
    get {
      return getBool(cv: .cv_000_000_122, mask: ByteMask.d6)!
    }
    set(value) {
      setBool(cv: .cv_000_000_122, mask: ByteMask.d6, value: value)
    }
  }
  
  public var analogMotorHysteresisVoltage : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_130)!
    }
    set(value) {
      if value != analogMotorHysteresisVoltage {
        setUInt8(cv: .cv_000_000_130, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var analogMotorHysteresisVoltageInVolts : Double {
    return Double(analogMotorHysteresisVoltage) / 10.0
  }
  
  public var analogFunctionDifferenceVoltage : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_129)!
    }
    set(value) {
      if value != analogFunctionDifferenceVoltage {
        setUInt8(cv: .cv_000_000_129, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var analogFunctionDifferenceVoltageInVolts : Double {
    return Double(analogFunctionDifferenceVoltage) / 10.0
  }

  public var abcBrakeIfRightRailMorePositive : Bool {
    get {
      return getBool(cv: .cv_000_000_027, mask: ByteMask.d0)!
    }
    set(value) {
      if value != abcBrakeIfRightRailMorePositive {
        setBool(cv: .cv_000_000_027, mask: ByteMask.d0, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var abcBrakeIfLeftRailMorePositive : Bool {
    get {
      return getBool(cv: .cv_000_000_027, mask: ByteMask.d1)!
    }
    set(value) {
      if value != abcBrakeIfLeftRailMorePositive {
        setBool(cv: .cv_000_000_027, mask: ByteMask.d1, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var voltageDifferenceIndicatingABCBrakeSection : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_134)!
    }
    set(value) {
      if value != voltageDifferenceIndicatingABCBrakeSection {
        setUInt8(cv: .cv_000_000_134, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var abcReducedSpeed : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_123)!
    }
    set(value) {
      if value != abcReducedSpeed {
        setUInt8(cv: .cv_000_000_123, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var isABCShuttleTrainEnabled : Bool {
    get {
      return getUInt8(cv: .cv_000_000_149)! != 0
    }
    set(value) {
      if value != isABCShuttleTrainEnabled {
        setUInt8(cv: .cv_000_000_149, value: value ? 1 : 0)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var abcWaitingTime : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_149)!
    }
    set(value) {
      if value != abcWaitingTime {
        setUInt8(cv: .cv_000_000_149, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var abcWaitingTimeInSeconds : TimeInterval {
    return Double(abcWaitingTime)
  }

  public var allowZIMOBrakeSections : Bool {
    get {
      return getBool(cv: .cv_000_000_027, mask: ByteMask.d2)!
    }
    set(value) {
      setBool(cv: .cv_000_000_027, mask: ByteMask.d2, value: value)
    }
  }

  public var sendZIMOZACKSignals : Bool {
    get {
      return getBool(cv: .cv_000_000_122, mask: ByteMask.d2)!
    }
    set(value) {
      setBool(cv: .cv_000_000_122, mask: ByteMask.d2, value: value)
    }
  }

  public var hluSpeedLimit1 : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_150)!
    }
    set(value) {
      if value != hluSpeedLimit1 {
        setUInt8(cv: .cv_000_000_150, value: value)
        hluSpeedLimit2 = max(hluSpeedLimit2, value)
        hluSpeedLimit3 = max(hluSpeedLimit3, value)
        hluSpeedLimit4 = max(hluSpeedLimit4, value)
        hluSpeedLimit5 = max(hluSpeedLimit5, value)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var hluSpeedLimit2 : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_151)!
    }
    set(value) {
      if value != hluSpeedLimit2 {
        setUInt8(cv: .cv_000_000_151, value: value)
        hluSpeedLimit1 = min(hluSpeedLimit1, value)
        hluSpeedLimit3 = max(hluSpeedLimit3, value)
        hluSpeedLimit4 = max(hluSpeedLimit4, value)
        hluSpeedLimit5 = max(hluSpeedLimit5, value)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var hluSpeedLimit3 : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_152)!
    }
    set(value) {
      if value != hluSpeedLimit3 {
        setUInt8(cv: .cv_000_000_152, value: value)
        hluSpeedLimit1 = min(hluSpeedLimit1, value)
        hluSpeedLimit2 = min(hluSpeedLimit2, value)
        hluSpeedLimit4 = max(hluSpeedLimit4, value)
        hluSpeedLimit5 = max(hluSpeedLimit5, value)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var hluSpeedLimit4 : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_153)!
    }
    set(value) {
      if value != hluSpeedLimit4 {
        setUInt8(cv: .cv_000_000_153, value: value)
        hluSpeedLimit1 = min(hluSpeedLimit1, value)
        hluSpeedLimit2 = min(hluSpeedLimit2, value)
        hluSpeedLimit3 = min(hluSpeedLimit3, value)
        hluSpeedLimit5 = max(hluSpeedLimit5, value)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var hluSpeedLimit5 : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_154)!
    }
    set(value) {
      if value != hluSpeedLimit5 {
        setUInt8(cv: .cv_000_000_154, value: value)
        hluSpeedLimit1 = min(hluSpeedLimit1, value)
        hluSpeedLimit2 = min(hluSpeedLimit2, value)
        hluSpeedLimit3 = min(hluSpeedLimit3, value)
        hluSpeedLimit4 = min(hluSpeedLimit4, value)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var brakeOnForwardDCPolarity : Bool {
    get {
      return getBool(cv: .cv_000_000_027, mask: ByteMask.d4)!
    }
    set(value) {
      setBool(cv: .cv_000_000_027, mask: ByteMask.d4, value: value)
    }
  }

  public var brakeOnReverseDCPolarity : Bool {
    get {
      return getBool(cv: .cv_000_000_027, mask: ByteMask.d3)!
    }
    set(value) {
      setBool(cv: .cv_000_000_027, mask: ByteMask.d3, value: value)
    }
  }

  public var selectrixBrakeOnForwardPolarity : Bool {
    get {
      return getBool(cv: .cv_000_000_027, mask: ByteMask.d6)!
    }
    set(value) {
      setBool(cv: .cv_000_000_027, mask: ByteMask.d6, value: value)
    }
  }

  public var selectrixBrakeOnReversePolarity : Bool {
    get {
      return getBool(cv: .cv_000_000_027, mask: ByteMask.d5)!
    }
    set(value) {
      setBool(cv: .cv_000_000_027, mask: ByteMask.d5, value: value)
    }
  }

  public var isConstantBrakeDistanceEnabled : Bool {
    get {
      return getUInt8(cv: .cv_000_000_254)! != 0
    }
    set(value) {
      if value != isConstantBrakeDistanceEnabled {
        setUInt8(cv: .cv_000_000_254, value: value ? 1 : 0)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var brakeDistanceLength : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_254)!
    }
    set(value) {
      if value != brakeDistanceLength {
        setUInt8(cv: .cv_000_000_254, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var isDifferentBrakeDistanceBackwards : Bool {
    get {
      return getUInt8(cv: .cv_000_000_255)! != 0
    }
    set(value) {
      if value != isDifferentBrakeDistanceBackwards {
        setUInt8(cv: .cv_000_000_255, value: value ? 1 : 0)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var brakeDistanceLengthBackwards : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_255)!
    }
    set(value) {
      if value != brakeDistanceLengthBackwards {
        setUInt8(cv: .cv_000_000_255, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var driveUntilLocomotiveStopsInSpecifiedPeriod : Bool {
    get {
      return getUInt8(cv: .cv_000_000_253)! != 0
    }
    set(value) {
      if value != driveUntilLocomotiveStopsInSpecifiedPeriod {
        setUInt8(cv: .cv_000_000_253, value: value ? 1 : 0)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var stoppingPeriod : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_253)!
    }
    set(value) {
      if value != stoppingPeriod {
        setUInt8(cv: .cv_000_000_253, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var stoppingPeriodInSeconds : TimeInterval {
    return Double(stoppingPeriod) / 4.0
  }

  public var constantBrakeDistanceOnSpeedStep0 : Bool {
    get {
      return getBool(cv: .cv_000_000_027, mask: ByteMask.d7)!
    }
    set(value) {
      setBool(cv: .cv_000_000_027, mask: ByteMask.d7, value: value)
    }
  }

  public var delayBeforeExitingBrakeSection : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_102)!
    }
    set(value) {
      if value != delayBeforeExitingBrakeSection {
        setUInt8(cv: .cv_000_000_102, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var delayBeforeExitingBrakeSectionInSeconds : TimeInterval {
    /// The NMRA spec says that the multipler should be 0.016s, the 61.0 factor
    /// was derived from LokProgrammer app.
    return Double(delayBeforeExitingBrakeSection) / 61.0
  }

  public var brakeFunction1BrakeTimeReduction : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_179)!
    }
    set(value) {
      if value != brakeFunction1BrakeTimeReduction {
        setUInt8(cv: .cv_000_000_179, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var brakeFunction1BrakeTimeReductionPercentage : Double {
    return Double(brakeFunction1BrakeTimeReduction) / 255.0 * 100.0
  }
  
  public var maximumSpeedWhenBrakeFunction1Active : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_182)!
    }
    set(value) {
      if value != maximumSpeedWhenBrakeFunction1Active {
        setUInt8(cv: .cv_000_000_182, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var brakeFunction2BrakeTimeReduction : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_180)!
    }
    set(value) {
      if value != brakeFunction2BrakeTimeReduction {
        setUInt8(cv: .cv_000_000_180, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var brakeFunction2BrakeTimeReductionPercentage : Double {
    return Double(brakeFunction2BrakeTimeReduction) / 255.0 * 100.0
  }
  
  public var maximumSpeedWhenBrakeFunction2Active : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_183)!
    }
    set(value) {
      if value != maximumSpeedWhenBrakeFunction2Active {
        setUInt8(cv: .cv_000_000_183, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var brakeFunction3BrakeTimeReduction : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_181)!
    }
    set(value) {
      if value != brakeFunction3BrakeTimeReduction {
        setUInt8(cv: .cv_000_000_181, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var brakeFunction3BrakeTimeReductionPercentage : Double {
    return Double(brakeFunction3BrakeTimeReduction) / 255.0 * 100.0
  }
  
  public var maximumSpeedWhenBrakeFunction3Active : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_184)!
    }
    set(value) {
      if value != maximumSpeedWhenBrakeFunction3Active {
        setUInt8(cv: .cv_000_000_184, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var isRailComFeedbackEnabled : Bool {
    get {
      return getBool(cv: .cv_000_000_029, mask: ByteMask.d3)!
    }
    set(value) {
      if value != isRailComFeedbackEnabled {
        setBool(cv: .cv_000_000_029, mask: ByteMask.d3, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var isRailComPlusAutomaticAnnouncementEnabled : Bool {
    get {
      return getBool(cv: .cv_000_000_028, mask: ByteMask.d7)!
    }
    set(value) {
      if value != isRailComPlusAutomaticAnnouncementEnabled {
        setBool(cv: .cv_000_000_028, mask: ByteMask.d7, value: value)
      }
    }
  }

  public var sendAddressViaBroadcastOnChannel1 : Bool {
    get {
      return getBool(cv: .cv_000_000_028, mask: ByteMask.d0)!
    }
    set(value) {
      if value != sendAddressViaBroadcastOnChannel1 {
        setBool(cv: .cv_000_000_028, mask: ByteMask.d0, value: value)
      }
    }
  }

  public var allowDataTransmissionOnChannel2 : Bool {
    get {
      return getBool(cv: .cv_000_000_028, mask: ByteMask.d1)!
    }
    set(value) {
      if value != allowDataTransmissionOnChannel2 {
        setBool(cv: .cv_000_000_028, mask: ByteMask.d1, value: value)
      }
    }
  }

  public var detectSpeedStepModeAutomatically : Bool {
    get {
      return getBool(cv: .cv_000_000_049, mask: ByteMask.d4)!
    }
    set(value) {
      if value != detectSpeedStepModeAutomatically {
        setBool(cv: .cv_000_000_049, mask: ByteMask.d4, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var speedStepMode : SpeedStepMode {
    get {
      return SpeedStepMode(rawValue: getMaskedUInt8(cv: .cv_000_000_029, mask: SpeedStepMode.mask)!)!
    }
    set(value) {
      if value != speedStepMode {
        setMaskedUInt8(cv: .cv_000_000_029, mask: SpeedStepMode.mask, value: value.rawValue)
      }
    }
  }
  
  public var userId1 : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_105)!
    }
    set(value) {
      setUInt8(cv: .cv_000_000_105, value: value)
    }
  }

  public var userId2 : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_106)!
    }
    set(value) {
      setUInt8(cv: .cv_000_000_106, value: value)
    }
  }
  
  public var isAccelerationEnabled : Bool {
    get {
      return getUInt8(cv: .cv_000_000_003)! != 0
    }
    set(value) {
      if value != isAccelerationEnabled {
        setUInt8(cv: .cv_000_000_003, value: value ? 40 : 0)
        delegate?.reloadSettings!(self)
      }
    }
  }
  
  public var accelerationRate : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_003)!
    }
    set(value) {
      if value != accelerationRate {
        setUInt8(cv: .cv_000_000_003, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var accelerationRateInSeconds : TimeInterval {
    return Double(accelerationRate) * 0.25
  }
  
  public var accelerationAdjustment : Int8 {
    get {
      let value = getUInt8(cv: .cv_000_000_023)!
      return Int8(value & 0x7f) * (((value & ByteMask.d7) == ByteMask.d7) ? -1 : 1)
    }
    set(value) {
      if value != accelerationAdjustment {
        setUInt8(cv: .cv_000_000_023, value: UInt8(abs(value)) | (value < 0 ? ByteMask.d7 : 0))
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var accelerationAdjustmentInSeconds : TimeInterval {
    return Double(accelerationAdjustment) * 0.25
  }

  public var isDecelerationEnabled : Bool {
    get {
      return getUInt8(cv: .cv_000_000_004)! != 0
    }
    set(value) {
      if value != isDecelerationEnabled {
        setUInt8(cv: .cv_000_000_004, value: value ? 40 : 0)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var decelerationRate : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_004)!
    }
    set(value) {
      if value != decelerationRate {
        setUInt8(cv: .cv_000_000_004, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var decelerationRateInSeconds : TimeInterval {
    return Double(decelerationRate) * 0.25
  }
  
  public var decelerationAdjustment : Int8 {
    get {
      let value = getUInt8(cv: .cv_000_000_024)!
      return Int8(value & 0x7f) * (((value & ByteMask.d7) == ByteMask.d7) ? -1 : 1)
    }
    set(value) {
      if decelerationAdjustment != value {
        setUInt8(cv: .cv_000_000_024, value: UInt8(abs(value)) | (value < 0 ? ByteMask.d7 : 0))
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var decelerationAdjustmentInSeconds : TimeInterval {
    return Double(decelerationAdjustment) * 0.25
  }
  
  public var isReversed : Bool {
    get {
      return getBool(cv: .cv_000_000_029, mask: ByteMask.d0)!
    }
    set(value) {
      setBool(cv: .cv_000_000_029, mask: ByteMask.d0, value: value)
    }
  }
  
  public var isForwardTrimEnabled : Bool {
    get {
      return getUInt8(cv: .cv_000_000_066)! != 0
    }
    set(value) {
      if value != isForwardTrimEnabled {
        setUInt8(cv: .cv_000_000_066, value: value ? 128 : 0)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var forwardTrim : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_066)!
    }
    set(value) {
      if value != forwardTrim {
        setUInt8(cv: .cv_000_000_066, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var forwardTrimMultiplier : Double {
    return Double(forwardTrim) / 128.0
  }

  public var isReverseTrimEnabled : Bool {
    get {
      return getUInt8(cv: .cv_000_000_095)! != 0
    }
    set(value) {
      if value != isReverseTrimEnabled {
        setUInt8(cv: .cv_000_000_095, value: value ? 128 : 0)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var reverseTrim : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_095)!
    }
    set(value) {
      if value != reverseTrim {
        setUInt8(cv: .cv_000_000_095, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var reverseTrimMultiplier : Double {
    return Double(reverseTrim) / 128.0
  }

  public var isShuntingModeTrimEnabled : Bool {
    get {
      return getUInt8(cv: .cv_000_000_101)! != 0
    }
    set(value) {
      if value != isShuntingModeTrimEnabled {
        setUInt8(cv: .cv_000_000_101, value: value ? 64 : 0)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var shuntingModeTrim : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_101)!
    }
    set(value) {
      if value != shuntingModeTrim {
        setUInt8(cv: .cv_000_000_101, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var shuntingModeTrimMultiplier : Double {
    return Double(shuntingModeTrim) / 128.0
  }
  
  public var loadAdjustmentOptionalLoad : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_103)!
    }
    set(value) {
      if value != loadAdjustmentOptionalLoad {
        setUInt8(cv: .cv_000_000_103, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var loadAdjustmentOptionalLoadMultiplier : Double {
    return Double(loadAdjustmentOptionalLoad) / 128.0
  }

  public var loadAdjustmentPrimaryLoad : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_104)!
    }
    set(value) {
      if value != loadAdjustmentPrimaryLoad {
        setUInt8(cv: .cv_000_000_104, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var loadAdjustmentPrimaryLoadMultiplier : Double {
    return Double(loadAdjustmentPrimaryLoad) / 128.0
  }

  public var isGearboxBacklashCompensationEnabled : Bool {
    get {
      return getUInt8(cv: .cv_000_000_111)! != 0
    }
    set(value) {
      if value != isGearboxBacklashCompensationEnabled {
        setUInt8(cv: .cv_000_000_111, value: value ? 1 : 0)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var gearboxBacklashCompensation : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_111)!
    }
    set(value) {
      if value != gearboxBacklashCompensation {
        setUInt8(cv: .cv_000_000_111, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var gearboxBacklashCompensationInSeconds : Double {
    return Double(gearboxBacklashCompensation) / 61.0
  }
  
  public var timeToBridgePowerInterruption : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_113)!
    }
    set(value) {
      if value != timeToBridgePowerInterruption {
        setUInt8(cv: .cv_000_000_113, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var timeToBridgePowerInterruptionInSeconds : TimeInterval {
    return Double(timeToBridgePowerInterruption) * 0.032768
  }

  public var isDirectionPreserved : Bool {
    get {
      return getBool(cv: .cv_000_000_124, mask: ByteMask.d0)!
    }
    set(value) {
      setBool(cv: .cv_000_000_124, mask: ByteMask.d0, value: value)
    }
  }
  
  public var isStartingDelayEnabled : Bool {
    get {
      return getBool(cv: .cv_000_000_124, mask: ByteMask.d2)!
    }
    set(value) {
      setBool(cv: .cv_000_000_124, mask: ByteMask.d2, value: value)
    }
  }
  
  public var isDCCProtocolEnabled : Bool {
    get {
      return getBool(cv: .cv_000_000_047, mask: ByteMask.d0)!
    }
    set(value) {
      setBool(cv: .cv_000_000_047, mask: ByteMask.d0, value: value)
    }
  }
  
  public var isMarklinMotorolaProtocolEnabled : Bool {
    get {
      return getBool(cv: .cv_000_000_047, mask: ByteMask.d2)!
    }
    set(value) {
      setBool(cv: .cv_000_000_047, mask: ByteMask.d2, value: value)
    }
  }
  
  public var isSelectrixProtocolEnabled : Bool {
    get {
      return getBool(cv: .cv_000_000_047, mask: ByteMask.d3)!
    }
    set(value) {
      setBool(cv: .cv_000_000_047, mask: ByteMask.d3, value: value)
    }
  }
  
  public var isM4ProtocolEnabled : Bool {
    get {
      return getBool(cv: .cv_000_000_047, mask: ByteMask.d1)!
    }
    set(value) {
      setBool(cv: .cv_000_000_047, mask: ByteMask.d1, value: value)
    }
  }

  public var isMemoryPersistentFunctionEnabled : Bool {
    get {
      return getBool(cv: .cv_000_000_122, mask: ByteMask.d0)!
    }
    set(value) {
      setBool(cv: .cv_000_000_122, mask: ByteMask.d0, value: value)
    }
  }
  
  public var isMemoryPersistentSpeedEnabled : Bool {
    get {
      return getBool(cv: .cv_000_000_122, mask: ByteMask.d1)!
    }
    set(value) {
      setBool(cv: .cv_000_000_122, mask: ByteMask.d1, value: value)
    }
  }
  
  public var isDecoderSynchronizedWithMasterDecoder : Bool {
    get {
      return m4MasterDecoderManufacturerId != .noneSelected
    }
    set(value) {
      if value != isDecoderSynchronizedWithMasterDecoder {
        if !value {
          m4MasterDecoderManufacturerId = .noneSelected
          m4MasterDecoderSerialNumber = 0
        }
        else {
          m4MasterDecoderManufacturerId = .cMLElectronicsLimited
        }
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var m4MasterDecoderManufacturerId : ManufacturerCode {
    get {
      return ManufacturerCode(rawValue: UInt16(getUInt8(cv: .cv_000_000_191)!))!
    }
    set(value) {
      setUInt8(cv: .cv_000_000_191, value: UInt8(value.rawValue & 0xff))
    }
  }
  
  public var m4MasterDecoderSerialNumber : UInt32 {
    get {
      return getUInt32(cv: .cv_000_000_192)!
    }
    set(value) {
      setUInt32(cv: .cv_000_000_192, value: value)
    }
  }
  
  public var frequencyForBlinkingEffects : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_112)!
    }
    set(value) {
      if value != frequencyForBlinkingEffects {
        setUInt8(cv: .cv_000_000_112, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var frequencyForBlinkingEffectsInSeconds : TimeInterval {
    /// The multipler value is for ESU decoders and is different from NMRA value
    return Double(frequencyForBlinkingEffects) / 20.0
  }
  
  public var gradeCrossingHoldingTime : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_132)!
    }
    set(value) {
      if value != gradeCrossingHoldingTime {
        setUInt8(cv: .cv_000_000_132, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var gradeCrossingHoldingTimeInSeconds : TimeInterval {
    return Double(gradeCrossingHoldingTime) * 0.065536
  }
  
  public var fadeInTimeOfLightEffects : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_114)!
    }
    set(value) {
      if value != fadeInTimeOfLightEffects {
        setUInt8(cv: .cv_000_000_114, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var fadeInTimeOfLightEffectsInSeconds : TimeInterval {
    /// This is an approximation from LokProgrammer
    return Double(fadeInTimeOfLightEffects) * 0.008189
  }
  
  public var fadeOutTimeOfLightEffects : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_115)!
    }
    set(value) {
      if value != fadeOutTimeOfLightEffects {
        setUInt8(cv: .cv_000_000_115, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var fadeOutTimeOfLightEffectsInSeconds : TimeInterval {
    /// This is an approximation from LokProgrammer
    return Double(fadeOutTimeOfLightEffects) * 0.008189
  }
  
  public var logicalFunctionDimmerBrightnessReduction : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_131)!
    }
    set(value) {
      if value != logicalFunctionDimmerBrightnessReduction {
        setUInt8(cv: .cv_000_000_131, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var logicalFunctionDimmerBrightnessReductionPercentage : Double {
    return Double(logicalFunctionDimmerBrightnessReduction) / 128.0 * 100.0
  }
  
  public var classLightLogicSequenceLength : ClassLightLogicSequenceLength {
    get {
      return ClassLightLogicSequenceLength(rawValue: getMaskedUInt8(cv: .cv_000_000_199, mask: ClassLightLogicSequenceLength.mask)!)!
    }
    set(value) {
      setMaskedUInt8(cv: .cv_000_000_199, mask: ClassLightLogicSequenceLength.mask, value: value.rawValue)
    }
  }
  
  public var isSlaveCommunicationOnAUX3andAUX4Enforced : Bool {
    get {
      return getBool(cv: .cv_000_000_122, mask: ByteMask.d4)!
    }
    set(value) {
      setBool(cv: .cv_000_000_122, mask: ByteMask.d4, value: value)
    }
  }
  
  public var decoderSensorSettings : DecoderSensorSettings {
    get {
      return DecoderSensorSettings(rawValue: getMaskedUInt8(cv: .cv_000_000_124, mask: DecoderSensorSettings.mask)!)!
    }
    set(value) {
      setMaskedUInt8(cv: .cv_000_000_124, mask: DecoderSensorSettings.mask, value: value.rawValue)
    }
  }
  
  public var isAutomaticUncouplingEnabled : Bool {
    get {
      return getUInt8(cv: .cv_000_000_246)! != 0
    }
    set(value) {
      if value != isAutomaticUncouplingEnabled {
        setUInt8(cv: .cv_000_000_246, value: value ? 1 : 0)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var automaticUncouplingSpeed : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_246)!
    }
    set(value) {
      if value != automaticUncouplingSpeed {
        setUInt8(cv: .cv_000_000_246, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var automaticUncouplingPushTime : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_248)!
    }
    set(value) {
      if value != automaticUncouplingPushTime {
        setUInt8(cv: .cv_000_000_248, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var automaticUncouplingPushTimeInSeconds : TimeInterval {
    ///multiplier derived from LokProgramme; not NMRA value
    return Double(automaticUncouplingPushTime) / 61.0
  }

  public var automaticUncouplingWaitTime : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_245)!
    }
    set(value) {
      if value != automaticUncouplingWaitTime {
        setUInt8(cv: .cv_000_000_245, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var automaticUncouplingWaitTimeInSeconds : TimeInterval {
    ///multiplier derived from LokProgramme; not NMRA value
    return Double(automaticUncouplingWaitTime) / 61.0
  }

  public var automaticUncouplingMoveTime : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_247)!
    }
    set(value) {
      if value != automaticUncouplingMoveTime {
        setUInt8(cv: .cv_000_000_247, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var automaticUncouplingMoveTimeInSeconds : TimeInterval {
    ///multiplier derived from LokProgramme; not NMRA value
    return Double(automaticUncouplingMoveTime) / 61.0
  }
  
  public var smokeUnitTimeUntilAutomaticPowerOff : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_140)!
    }
    set(value) {
      if value != smokeUnitTimeUntilAutomaticPowerOff {
        setUInt8(cv: .cv_000_000_140, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var smokeUnitTimeUntilAutomaticPowerOffInSeconds : TimeInterval {
    return Double(smokeUnitTimeUntilAutomaticPowerOff) * 5.0
  }
  
  public var smokeUnitFanSpeedTrim : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_138)!
    }
    set(value) {
      if value != smokeUnitFanSpeedTrim {
        setUInt8(cv: .cv_000_000_138, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var smokeUnitFanSpeedTrimPercentage : Double {
    return Double(smokeUnitFanSpeedTrim) / 128.0 * 100.0
  }
  
  public var smokeUnitTemperatureTrim : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_139)!
    }
    set(value) {
      if value != smokeUnitTemperatureTrim {
        setUInt8(cv: .cv_000_000_139, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var smokeUnitTemperatureTrimPercentage : Double {
    return Double(smokeUnitTemperatureTrim) / 128.0 * 100.0
  }
  
  public var smokeUnitPreheatingTemperatureForSecondarySmokeUnits : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_144)!
    }
    set(value) {
      if value != smokeUnitPreheatingTemperatureForSecondarySmokeUnits {
        setUInt8(cv: .cv_000_000_144, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var smokeUnitPreheatingTemperatureForSecondarySmokeUnitsInCelsius : Double {
    return Double(smokeUnitPreheatingTemperatureForSecondarySmokeUnits)
  }
  
  public var smokeChuffsDurationRelativeToTriggerDistance : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_143)!
    }
    set(value) {
      if value != smokeChuffsDurationRelativeToTriggerDistance {
        setUInt8(cv: .cv_000_000_143, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var smokeChuffsDurationRelativeToTriggerDistancePercentage : Double {
    return Double(smokeChuffsDurationRelativeToTriggerDistance) / 255.0 * 100.0
  }
  
  public var smokeChuffsMinimumDuration : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_141)!
    }
    set(value) {
      if value != smokeChuffsMinimumDuration {
        setUInt8(cv: .cv_000_000_141, value: value)
        smokeChuffsMaximumDuration = max(smokeChuffsMaximumDuration, value)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var smokeChuffsMinimumDurationInSeconds : TimeInterval {
    /// This is the NMRA multiplier, the Lokprogrammer version was 0.004078
    return Double(smokeChuffsMinimumDuration) * 0.041
  }

  public var smokeChuffsMaximumDuration : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_142)!
    }
    set(value) {
      if value != smokeChuffsMaximumDuration {
        setUInt8(cv: .cv_000_000_142, value: value)
        smokeChuffsMinimumDuration = min(smokeChuffsMinimumDuration, value)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var smokeChuffsMaximumDurationInSeconds : TimeInterval {
    /// This is the NMRA multiplier, the Lokprogrammer version was 0.004078
    return Double(smokeChuffsMaximumDuration) * 0.041
  }
  
  public var minimumSpeed : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_002)!
    }
    set(value) {
      if value != minimumSpeed {
        setUInt8(cv: .cv_000_000_002, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var minimumSpeedPercentage : Double {
    return Double(minimumSpeed) / 255 * 100.0
  }

  public var maximumSpeed : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_005)!
    }
    set(value) {
      if value != maximumSpeed {
        setUInt8(cv: .cv_000_000_005, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var maximumSpeedPercentage : Double {
    return Double(maximumSpeed) / 255 * 100.0
  }
  
  public var isLoadControlBackEMFEnabled : Bool {
    get {
      return getBool(cv: .cv_000_000_049, mask: ByteMask.d0)!
    }
    set(value) {
      if value != isLoadControlBackEMFEnabled {
        setBool(cv: .cv_000_000_049, mask: ByteMask.d0, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var regulationReference : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_053)!
    }
    set(value) {
      if value != regulationReference {
        setUInt8(cv: .cv_000_000_053, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var regulationReferenceInVolts : Double {
    return Double(regulationReference) / 10.0
  }
  
  public var regulationParameterK : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_054)!
    }
    set(value) {
      if value != regulationParameterK {
        setUInt8(cv: .cv_000_000_054, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var regulationParameterI : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_055)!
    }
    set(value) {
      if value != regulationParameterI {
        setUInt8(cv: .cv_000_000_055, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var regulationParameterIInSeconds : Double {
    return Double(regulationParameterI) * 2.0 / 1000.0
  }

  public var regulationParameterKSlow : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_052)!
    }
    set(value) {
      if value != regulationParameterKSlow {
        setUInt8(cv: .cv_000_000_052, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var largestInternalSpeedStepThatUsesKSlow : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_051)!
    }
    set(value) {
      if value != largestInternalSpeedStepThatUsesKSlow {
        setUInt8(cv: .cv_000_000_051, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var regulationInfluenceDuringSlowSpeed : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_056)!
    }
    set(value) {
      if value != regulationInfluenceDuringSlowSpeed {
        setUInt8(cv: .cv_000_000_056, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var regulationInfluenceDuringSlowSpeedPercentage : Double {
    return Double(regulationInfluenceDuringSlowSpeed) / 255.0 * 100.0
  }
  
  public var slowSpeedBackEMFSamplingPeriod : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_116)!
    }
    set(value) {
      if value != slowSpeedBackEMFSamplingPeriod {
        setUInt8(cv: .cv_000_000_116, value: value)
        fullSpeedBackEMFSamplingPeriod = max(fullSpeedBackEMFSamplingPeriod, value)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var slowSpeedBackEMFSamplingPeriodInSeconds : Double {
    return Double(slowSpeedBackEMFSamplingPeriod) / 10000.0
  }
  
  public var fullSpeedBackEMFSamplingPeriod : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_117)!
    }
    set(value) {
      if value != fullSpeedBackEMFSamplingPeriod {
        setUInt8(cv: .cv_000_000_117, value: value)
        slowSpeedBackEMFSamplingPeriod = min(slowSpeedBackEMFSamplingPeriod, value)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var fullSpeedBackEMFSamplingPeriodInSeconds : Double {
    return Double(fullSpeedBackEMFSamplingPeriod) / 10000.0
  }
  
  public var slowSpeedLengthOfMeasurementGap : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_118)!
    }
    set(value) {
      if value != slowSpeedLengthOfMeasurementGap {
        setUInt8(cv: .cv_000_000_118, value: value)
        fullSpeedLengthOfMeasurementGap = max(fullSpeedLengthOfMeasurementGap, value)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var slowSpeedLengthOfMeasurementGapInSeconds : Double {
    return Double(slowSpeedLengthOfMeasurementGap) / 10000.0
  }

  public var fullSpeedLengthOfMeasurementGap : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_119)!
    }
    set(value) {
      if value != fullSpeedLengthOfMeasurementGap {
        setUInt8(cv: .cv_000_000_119, value: value)
        slowSpeedLengthOfMeasurementGap = min(slowSpeedLengthOfMeasurementGap, value)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var fullSpeedLengthOfMeasurementGapInSeconds : Double {
    return Double(fullSpeedLengthOfMeasurementGap) / 10000.0
  }
  
  public var isMotorOverloadProtectionEnabled : Bool {
    get {
      return getBool(cv: .cv_000_000_124, mask: ByteMask.d5)!
    }
    set(value) {
      setBool(cv: .cv_000_000_124, mask: ByteMask.d5, value: value)
    }
  }
  
  public var isMotorCurrentLimiterEnabled : Bool {
    get {
      return getUInt8(cv: .cv_000_000_100)! != 0
    }
    set(value) {
      if value != isMotorCurrentLimiterEnabled {
        setUInt8(cv: .cv_000_000_100, value: value ? 1 : 0)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var motorCurrentLimiterLimit : UInt8 {
    get {
      getUInt8(cv: .cv_000_000_100)!
    }
    set(value) {
      if value != motorCurrentLimiterLimit {
        setUInt8(cv: .cv_000_000_100, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var motorCurrentLimiterLimitPercentage : Double {
    return Double(motorCurrentLimiterLimit) / 255.0 * 100.0
  }
  
  public var motorPulseFrequency : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_009)!
    }
    set(value) {
      if value != motorPulseFrequency {
        setUInt8(cv: .cv_000_000_009, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var motorPulseFrequencyInHertz : Double {
    return Double(motorPulseFrequency) * 1000.0
  }
  
  public var isAutomaticParkingBrakeEnabled : Bool {
    get {
      return getBool(cv: .cv_000_000_124, mask: ByteMask.d6)!
    }
    set(value) {
      setBool(cv: .cv_000_000_124, mask: ByteMask.d6, value: value)
    }
  }
  
  public var steamChuffMode : SteamChuffMode {
    get {
      return (getUInt8(cv: .cv_000_000_057)! == 0) ? .useExternalWheelSensor : .playSteamChuffsAccordingToSpeed
    }
    set(value) {
      if value != steamChuffMode {
        setUInt8(cv: .cv_000_000_057, value: value == .useExternalWheelSensor ? 0 : 1)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var distanceOfSteamChuffsAtSpeedStep1 : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_057)!
    }
    set(value) {
      if value != distanceOfSteamChuffsAtSpeedStep1 {
        setUInt8(cv: .cv_000_000_057, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var distanceOfSteamChuffsAtSpeedStep1InSeconds : Double {
    return Double(distanceOfSteamChuffsAtSpeedStep1) * 0.032
  }
  
  public var steamChuffAdjustmentAtHigherSpeedSteps : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_058)!
    }
    set(value) {
      if value != steamChuffAdjustmentAtHigherSpeedSteps {
        setUInt8(cv: .cv_000_000_058, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var isSecondaryTrimmerEnabled : Bool {
    get {
      return getUInt8(cv: .cv_000_000_250)! != 0
    }
    set(value) {
      if value != isSecondaryTrimmerEnabled {
        setUInt8(cv: .cv_000_000_250, value: value ? 1 : 0)
        delegate?.reloadSettings!(self)
      }
    }
  }
  
  public var secondaryTriggerDistanceReduction : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_250)!
    }
    set(value) {
      if value != secondaryTriggerDistanceReduction {
        setUInt8(cv: .cv_000_000_250, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var secondaryTriggerDistanceReductionAmount : Double {
    return Double(secondaryTriggerDistanceReduction) * 0.001
  }
  
  public var isMinimumDistanceOfSteamChuffsEnabled : Bool {
    get {
      return getUInt8(cv: .cv_000_000_249)! != 0
    }
    set(value) {
      if value != isMinimumDistanceOfSteamChuffsEnabled {
        setUInt8(cv: .cv_000_000_249, value: value ? 1 : 0)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var minimumDistanceOfSteamChuffs : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_249)!
    }
    set(value) {
      if value != minimumDistanceOfSteamChuffs {
        setUInt8(cv: .cv_000_000_249, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var minimumDistanceOfSteamChuffsInSeconds : Double {
    return Double(minimumDistanceOfSteamChuffs) * 0.001
  }
  
  public var triggerImpulsesPerSteamChuff : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_058)!
    }
    set(value) {
      if value != triggerImpulsesPerSteamChuff {
        setUInt8(cv: .cv_000_000_058, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var divideTriggerImpulsesInTwoIfShuntingModeEnabled : Bool {
    get {
      return getBool(cv: .cv_000_000_122, mask: ByteMask.d3)!
    }
    set(value) {
      setBool(cv: .cv_000_000_122, mask: ByteMask.d3, value: value)
    }
  }
  
  public var masterVolume : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_063)!
    }
    set(value) {
      if value != masterVolume {
        setUInt8(cv: .cv_000_000_063, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var masterVolumePercentage : Double {
    return Double(masterVolume) / 128.0 * 100.0
  }
  
  public var fadeSoundVolumeReduction : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_133)!
    }
    set(value) {
      if value != fadeSoundVolumeReduction {
        setUInt8(cv: .cv_000_000_133, value: value)
        delegate?.reloadSettings!(self)
      }
    }
  }

  public var fadeSoundVolumeReductionPercentage : Double {
    return Double(fadeSoundVolumeReduction) / 128.0 * 100.0
  }
  
  public var soundFadeInFadeOutTime : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_135)!
    }
    set(value) {
      if value != soundFadeInFadeOutTime {
        setUInt8(cv: .cv_000_000_135, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var soundFadeInFadeOutTimeInSeconds : Double {
    return Double(soundFadeInFadeOutTime)
  }

  public var toneBass : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_196)!
    }
    set(value) {
      if value != toneBass {
        setUInt8(cv: .cv_000_000_196, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var toneBassdB : Double {
    return (Double(toneBass) - 16.0) * 10.0 / 16.0
  }

  public var toneTreble : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_197)!
    }
    set(value) {
      if value != toneTreble {
        setUInt8(cv: .cv_000_000_197, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var toneTrebledB : Double {
    return (Double(toneTreble) - 16.0) * 10.0 / 16.0
  }
  
  public var brakeSoundSwitchingOnThreshold : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_064)!
    }
    set(value) {
      if value != brakeSoundSwitchingOnThreshold {
        setUInt8(cv: .cv_000_000_064, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var brakeSoundSwitchingOffThreshold : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_065)!
    }
    set(value) {
      if value != brakeSoundSwitchingOffThreshold {
        setUInt8(cv: .cv_000_000_065, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var soundControlBasis : SoundControlBasis {
    get {
      return getUInt8(cv: .cv_000_000_200)! == 0 ? .accelerationAndBrakeTime : .accelerationAndBrakeTimeAndTrainLoad
    }
    set(value) {
      if value != soundControlBasis {
        setUInt8(cv: .cv_000_000_200, value: value == .accelerationAndBrakeTime ? 0 : 1)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var trainLoadAtLowSpeed : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_200)!
    }
    set(value) {
      if value != trainLoadAtLowSpeed {
        setUInt8(cv: .cv_000_000_200, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var trainLoadAtLowSpeedPercentage : Double {
    return Double(trainLoadAtLowSpeed) / 255.0 * 100.0
  }
  
  public var trainLoadAtHighSpeed : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_201)!
    }
    set(value) {
      if value != trainLoadAtHighSpeed {
        setUInt8(cv: .cv_000_000_201, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var trainLoadAtHighSpeedPercentage : Double {
    return Double(trainLoadAtHighSpeed) / 255.0 * 100.0
  }
  
  public var isThresholdForLoadOperationEnabled : Bool {
    get {
      return getUInt8(cv: .cv_000_000_202)! != 0
    }
    set(value) {
      if value != isThresholdForLoadOperationEnabled {
        setUInt8(cv: .cv_000_000_202, value: value ? 1 : 0)
        delegate?.reloadSettings!(self)
      }
    }
  }
  
  public var thresholdForLoadOperation : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_202)!
    }
    set(value) {
      if value != thresholdForLoadOperation {
        setUInt8(cv: .cv_000_000_202, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var loadOperationTriggeredFunction : TriggeredFunction {
    get {
      return TriggeredFunction(rawValue: getUInt8(cv: .cv_000_000_204)!)!
    }
    set(value) {
      if value != loadOperationTriggeredFunction {
        setUInt8(cv: .cv_000_000_204, value: value.rawValue)
      }
    }
  }

  public var isThresholdForIdleOperationEnabled : Bool {
    get {
      return getUInt8(cv: .cv_000_000_203)! != 0
    }
    set(value) {
      if value != isThresholdForIdleOperationEnabled {
        setUInt8(cv: .cv_000_000_203, value: value ? 1 : 0)
        delegate?.reloadSettings!(self)
      }
    }
  }
  
  public var thresholdForIdleOperation : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_203)!
    }
    set(value) {
      if value != thresholdForIdleOperation {
        setUInt8(cv: .cv_000_000_203, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  public var idleOperationTriggeredFunction : TriggeredFunction {
    get {
      return TriggeredFunction(rawValue: getUInt8(cv: .cv_000_000_205)!)!
    }
    set(value) {
      if value != idleOperationTriggeredFunction {
        setUInt8(cv: .cv_000_000_205, value: value.rawValue)
      }
    }
  }
  
  public var isSerialFunctionModeF1toF8ForLGBMTSEnabled : Bool {
    get {
      return getBool(cv: .cv_000_000_049, mask: ByteMask.d5)!
    }
    set(value) {
      setBool(cv: .cv_000_000_049, mask: ByteMask.d5, value: value)
    }
  }
  
  public var isSupportForBroadwayLimitedSteamEngineControlEnabled : Bool {
    get {
      return getBool(cv: .cv_000_000_122, mask: ByteMask.d7)!
    }
    set(value) {
      setBool(cv: .cv_000_000_122, mask: ByteMask.d7, value: value)
    }
  }
  
  public var isSUSIMasterEnabled : Bool {
    get {
      return getBool(cv: .cv_000_000_124, mask: ByteMask.d3)!
    }
    set(value) {
      if value != isSUSIMasterEnabled {
        setBool(cv: .cv_000_000_124, mask: ByteMask.d3, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }

  public var isSUSISlaveEnabled : Bool {
    get {
      return getBool(cv: .cv_000_000_124, mask: ByteMask.d1)!
    }
    set(value) {
      if value != isSUSISlaveEnabled {
        setBool(cv: .cv_000_000_124, mask: ByteMask.d1, value: value)
        delegate?.reloadSettings?(self)
      }
    }
  }
  
  private var _speedTablePreset : SpeedTablePreset = .doNothing
  
  private var speedTablePreset : SpeedTablePreset {
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
  
  public var speedTableIndex : Int {
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
  
  public var speedTableValue : UInt8 {
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
        delegate?.reloadSettings!(self)
      }
    }
  }
  
  private var _esuDecoderPhysicalOutput : ESUDecoderPhysicalOutput = .frontLight
  
  public var esuDecoderPhysicalOutput : ESUDecoderPhysicalOutput {
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
    get {
      return ESUPhysicalOutputMode(rawValue: getPhysicalOutputValue(property: .physicalOutputOutputMode)!)!
    }
    set(value) {
      if value != esuDecoderPhysicalOutputMode {
        setPhysicalOutputValue(property: .physicalOutputOutputMode, value: value.rawValue)
        delegate?.reloadSettings!(self)
      }
    }
  }
  
  public func isPropertySupported(property:ProgrammerToolSettingsProperty) -> Bool {
    if isPhysicalOutputProperty(property: property) {
      return esuDecoderPhysicalOutputMode.supportedProperties.contains(property)
    }
    return true
  }
  
  public var smokeUnitControlMode : SmokeUnitControlMode {
    get {
      return SmokeUnitControlMode(rawValue: getPhysicalOutputValue(property: .physicalOutputSmokeUnitControlMode)!)!
    }
    set(value) {
      if value != smokeUnitControlMode {
        setPhysicalOutputValue(property: .physicalOutputSmokeUnitControlMode, value: value.rawValue)
      }
    }
  }
  
  public var externalSmokeUnitType : ExternalSmokeUnitType {
    get {
      return ExternalSmokeUnitType(rawValue: getPhysicalOutputValue(property: .physicalOutputExternalSmokeUnitType)!)!
    }
    set(value) {
      if value != externalSmokeUnitType {
        setPhysicalOutputValue(property: .physicalOutputExternalSmokeUnitType, value: value.rawValue)
      }
    }
  }
  
  public func isPhysicalOutputProperty(property:ProgrammerToolSettingsProperty) -> Bool {
    return physicalOutputCVs.keys.contains(property)
  }
  
  private let physicalOutputCVs : [ProgrammerToolSettingsProperty:(cv:CV, mask:UInt8, shift:UInt8)] = [
    .physicalOutputPowerOnDelay  : (cv: .cv_016_000_260, mask: 0b00001111, shift:0),
    .physicalOutputPowerOffDelay : (cv: .cv_016_000_260, mask: 0b11110000 , shift: 4),
    .physicalOutputEnableFunctionTimeout : (cv: .cv_016_000_261, mask: 0xff, shift:0),
    .physicalOutputTimeUntilAutomaticPowerOff : (cv: .cv_016_000_261, mask: 0xff , shift:0),
    .physicalOutputOutputMode : (cv: .cv_016_000_259, mask: 0xff , shift:0),
    .physicalOutputBrightness : (cv:.cv_016_000_262, mask: 0b00011111, shift:0),
    .physicalOutputUseClassLightLogic: (cv:.cv_016_000_258, mask: 0b11000000, shift:6),
    .physicalOutputSequencePosition: (cv:.cv_016_000_262, mask: 0b11000000, shift:6),
    .physicalOutputPhaseShift : (cv: .cv_016_000_258, mask: 0b00111111, shift:0),
    .physicalOutputStartupTime : (cv: .cv_016_000_264, mask: 0xff, shift:0),
    .physicalOutputLevel : (cv: .cv_016_000_264, mask: 0b01111111, shift:0),
    .physicalOutputSmokeUnitControlMode : (cv: .cv_016_000_262, mask: ByteMask.d0, shift:0),
    .physicalOutputSpeed : (cv: .cv_016_000_262, mask: 0b00011111, shift:0),
    .physicalOutputAccelerationRate : (cv:.cv_016_000_263, mask: 0b00011111 , shift:0),
    .physicalOutputDecelerationRate : (cv:.cv_016_000_264, mask: 0b00011111 , shift:0),
    .physicalOutputHeatWhileLocomotiveStands : (cv: .cv_016_000_262, mask: 0b00011111 , shift:0),
    .physicalOutputMinimumHeatWhileLocomotiveDriving : (cv: .cv_016_000_263, mask: 0b00011111, shift:0),
    .physicalOutputMaximumHeatWhileLocomotiveDriving : (cv: .cv_016_000_264, mask: 0b00011111, shift:0),
    .physicalOutputChuffPower : (cv: .cv_016_000_262, mask: 0b00011111, shift:0),
    .physicalOutputFanPower : (cv:.cv_016_000_263, mask: 0b00011111, shift:0),
    .physicalOutputTimeout : (cv: .cv_016_000_264, mask: 0xff , shift:0),
    .physicalOutputServoDurationA : (cv:.cv_016_000_258, mask: 0b00111111, shift:0),
    .physicalOutputServoDurationB : (cv:.cv_016_000_262, mask: 0b00111111 , shift:0),
    .physicalOutputServoPositionA : (cv: .cv_016_000_263, mask: 0b00111111 , shift:0),
    .physicalOutputServoDoNotDisableServoPulseAtPositionA : (cv:.cv_016_000_263, mask: 0b10000000, shift:0),
    .physicalOutputServoPositionB : (cv:.cv_016_000_264, mask: 0b00111111, shift:0),
    .physicalOutputServoDoNotDisableServoPulseAtPositionB : (cv: .cv_016_000_264, mask: 0b10000000, shift:0),
    .physicalOutputCouplerForce : (cv: .cv_016_000_262, mask: 0b00011111, shift:0),
    .physicalOutputRule17Forward : (cv: .cv_016_000_263, mask: ByteMask.d2 , shift:0),
    .physicalOutputRule17Reverse : (cv: .cv_016_000_263, mask: ByteMask.d3 , shift:0),
    .physicalOutputDimmer : (cv: .cv_016_000_263, mask: ByteMask.d4, shift:0),
    .physicalOutputLEDMode : (cv: .cv_016_000_263, mask: ByteMask.d7, shift:0),
    .physicalOutputGradeCrossing : (cv: .cv_016_000_263, mask: ByteMask.d1, shift:0),
    .physicalOutputExternalSmokeUnitType : (cv: .cv_016_000_262, mask: 0b00000011, shift:0),
    .physicalOutputSpecialFunctions : (cv: .cv_000_000_001, mask: 0, shift:0),
    .physicalOutputStartupTimeInfo : (cv: .cv_000_000_001, mask: 0, shift:0),
    .physicalOutputStartupDescription : (cv: .cv_000_000_001, mask: 0, shift:0),
  ]
  
  public func physicalOutputCV(property:ProgrammerToolSettingsProperty) -> CV? {
    
    if let info = physicalOutputCVs[property] {
      return info.cv + (Int(esuDecoderPhysicalOutput.rawValue) * 8)
    }
    
    return nil
    
  }
  
  public func isPhysicalOutputBoolean(property:ProgrammerToolSettingsProperty) -> Bool? {
    
    if let info = physicalOutputCVs[property] {
      
      var mask : UInt8 = 0b10000000
      
      var firstBit : Int?
      var lastBit : Int?
      var index = 7
      
      while mask != 0 {
        if firstBit == nil && (info.mask & mask) == mask {
          firstBit = index
        }
        if (info.mask & mask) == mask {
          lastBit = firstBit
        }
        mask >>= 1
        index -= 1
      }
      
      if let firstBit, let lastBit {
        return firstBit == lastBit
      }
      
    }
    
    return nil
    
  }
  
  public func getPhysicalOutputValue(property:ProgrammerToolSettingsProperty) -> UInt8? {
    
    if let cv = physicalOutputCV(property:property) {
      if let info = physicalOutputCVs[property], var value = getMaskedUInt8(cv: cv, mask: info.mask) {
        return value >> info.shift
      }
      
    }
    
    return nil
    
  }

  public func setPhysicalOutputValue(property:ProgrammerToolSettingsProperty, value:UInt8) {
    
    if value != getPhysicalOutputValue(property: property), let cv = physicalOutputCV(property:property), let info = physicalOutputCVs[property] {
      
      setMaskedUInt8(cv: cv, mask: info.mask, value: value << info.shift)
      
      delegate?.reloadSettings?(self)
      
    }
    
  }

  public func getPhysicalOutputBoolValue(property:ProgrammerToolSettingsProperty) -> Bool? {
    
    if let cv = physicalOutputCV(property:property), let info = physicalOutputCVs[property] {
      
      return getBool(cv: cv, mask: info.mask)
      
    }
    
    return nil
    
  }

  public func setPhysicalOutputBoolValue(property:ProgrammerToolSettingsProperty, value:Bool) {
    
    if value != getPhysicalOutputBoolValue(property: property)!, let cv = physicalOutputCV(property:property), let info = physicalOutputCVs[property] {
      
      setBool(cv: cv, mask: info.mask, value: value)
      
      delegate?.reloadSettings!(self)
      
    }
    
  }

  public func physicalOutputCVLabel(property:ProgrammerToolSettingsProperty) -> String {
    
    if let info = physicalOutputCVs[property] {
      
      var mask : UInt8 = 0b10000000
      
      var firstBit : Int?
      var lastBit : Int?
      var index = 7
      
      while mask != 0 {
        if firstBit == nil && (info.mask & mask) == mask {
          firstBit = index
        }
        if (info.mask & mask) == mask {
          lastBit = index
        }
        mask >>= 1
        index -= 1
      }
      
      if let cv = physicalOutputCV(property:property), let firstBit, let lastBit {
        
        if firstBit == 7 && lastBit == 0 {
          return ("\(cv.cvLabel)").replacingOccurrences(of: "%%BITS%%", with: "")
        }
        
        if firstBit == lastBit {
          return ("\(cv.cvLabel)").replacingOccurrences(of: "%%BITS%%", with: ".\(firstBit)")
        }
        
        return ("\(cv.cvLabel)").replacingOccurrences(of: "%%BITS%%", with: ".\(firstBit):\(lastBit)")

      }
      
    }
    
    return "error"
    
  }
  
  // MARK: Private Methods
  
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
  
  public func getValue(property:ProgrammerToolSettingsProperty) -> String {
    
    switch property {
    case .physicalOutputExternalSmokeUnitType:
      return externalSmokeUnitType.title
    case .locomotiveAddressType:
      return "\(locomotiveAddressType.title)"
    case .locomotiveAddressShort:
      return "\(primaryAddress)"
    case .locomotiveAddressLong:
      return "\(extendedAddress)"
    case .marklinConsecutiveAddresses:
      return "\(marklinConsecutiveAddresses.title)"
    case .locomotiveAddressWarning:
      return String(localized:"The decoder will only respond to DCC commands!")
    case .enableDCCConsistAddress:
      return isConsistAddressEnabled ? "true" : "false"
    case .consistAddress:
      return "\(consistAddress)"
    case .consistReverseDirection:
      return isConsistReverseDirection ? "true" : "false"
    case .enableACAnalogMode:
      return isACAnalogModeEnabled ? "true" : "false"
    case .acAnalogModeStartVoltage:
      return "\(analogModeACStartVoltage)"
    case .acAnalogModeMaximumSpeedVoltage:
      return "\(analogModeACMaximumSpeedVoltage)"
    case .enableDCAnalogMode:
      return isDCAnalogModeEnabled ? "true" : "false"
    case .dcAnalogModeStartVoltage:
      return "\(analogModeDCStartVoltage)"
    case .dcAnalogModeMaximumSpeedVoltage:
      return "\(analogModeDCMaximumSpeedVoltage)"
    case .enableQuantumEngineer:
      return isQuantumEngineerEnabled ? "true" : "false"
    case .ignoreAccelerationDecelerationInSoundSchedule:
      return ignoreAccelerationDecelerationInSoundSchedule ? "true" : "false"
    case .useHighFrequencyPWMMotorControl:
      return useHighFrequencyPWMMotorControl ? "true" : "false"
    case .analogVoltageHysteresisDescription:
      return String(localized:"The motor will stop when the voltage falls below start voltage minus the motor hysteresis voltage. Functions will be activated when the voltage reaches the motor start voltage minus the function difference voltage.")
    case .analogMotorHysteresisVoltage:
      return "\(analogMotorHysteresisVoltage)"
    case .analogFunctionDifferenceVoltage:
      return "\(analogFunctionDifferenceVoltage)"
    case .enableABCBrakeMode:
      return String(localized: "Enable ABC brake mode (asymmetrical DCC signal):")
    case .emfBasicSettings:
      return String(localized: "Basic Settings")
    case .emfSlowSpeedSettings:
      return String(localized: "Slow Speed Settings")
    case .emfBackEMFSettings:
      return String(localized: "Back EMF Settings")
    case .brakeIfRightRailSignalPositive:
      return abcBrakeIfRightRailMorePositive ? "true" : "false"
    case .brakeIfLeftRailSignalPositive:
      return abcBrakeIfLeftRailMorePositive ? "true" : "false"
    case .voltageDifferenceIndicatingABCBrakeSection:
      return "\(voltageDifferenceIndicatingABCBrakeSection)"
    case .abcReducedSpeed:
      return "\(abcReducedSpeed)"
    case .enableABCShuttleTrain:
      return isABCShuttleTrainEnabled ? "true" : "false"
    case .waitingPeriodBeforeDirectionChange:
      return "\(abcWaitingTime)"
    case .hluAllowZIMO:
      return allowZIMOBrakeSections ? "true" : "false"
    case .hluSendZIMOZACKSignals:
      return sendZIMOZACKSignals ? "true" : "false"
    case .hluSpeedLimit1:
      return "\(hluSpeedLimit1)"
    case .hluSpeedLimit2:
      return "\(hluSpeedLimit2)"
    case .hluSpeedLimit3:
      return "\(hluSpeedLimit3)"
    case .hluSpeedLimit4:
      return "\(hluSpeedLimit4)"
    case .hluSpeedLimit5:
      return "\(hluSpeedLimit5)"
    case .brakeOnForwardPolarity:
      return brakeOnForwardDCPolarity ? "true" : "false"
    case .brakeOnReversePolarity:
      return brakeOnReverseDCPolarity ? "true" : "false"
    case .selectrixBrakeOnForwardPolarity:
      return selectrixBrakeOnForwardPolarity ? "true" : "false"
    case .selectrixBrakeOnReversePolarity:
      return selectrixBrakeOnReversePolarity ? "true" : "false"
    case .enableConstantBrakeDistance:
      return isConstantBrakeDistanceEnabled ? "true" : "false"
    case .brakeDistanceLength:
      return "\(brakeDistanceLength)"
    case .differentBrakeDistanceBackwards:
      return isDifferentBrakeDistanceBackwards ? "true" : "false"
    case .brakeDistanceLengthBackwards:
      return "\(brakeDistanceLengthBackwards)"
    case .driveUntilLocomotiveStopsInSpecifiedPeriod:
      return driveUntilLocomotiveStopsInSpecifiedPeriod ? "true" : "false"
    case .stoppingPeriod:
      return "\(stoppingPeriod)"
    case .constantBrakeDistanceOnSpeedStep0:
      return constantBrakeDistanceOnSpeedStep0 ? "true" : "false"
    case .delayTimeBeforeExitingBrakeSection:
      return "\(delayBeforeExitingBrakeSection)"
    case .brakeFunction1BrakeTimeReduction:
      return "\(brakeFunction1BrakeTimeReduction)"
    case .maximumSpeedWhenBrakeFunction1Active:
      return "\(maximumSpeedWhenBrakeFunction1Active)"
    case .brakeFunction2BrakeTimeReduction:
      return "\(brakeFunction2BrakeTimeReduction)"
    case .maximumSpeedWhenBrakeFunction2Active:
      return "\(maximumSpeedWhenBrakeFunction2Active)"
    case .brakeFunction3BrakeTimeReduction:
      return "\(brakeFunction3BrakeTimeReduction)"
    case .maximumSpeedWhenBrakeFunction3Active:
      return "\(maximumSpeedWhenBrakeFunction3Active)"
    case .enableRailComFeedback:
      return isRailComFeedbackEnabled ? "true" : "false"
    case .enableRailComPlusAutomaticAnnouncement:
      return isRailComPlusAutomaticAnnouncementEnabled ? "true" : "false"
    case .sendFollowingToCommandStation:
      return "Send following information to the command station:"
    case .sendAddressViaBroadcastOnChannel1:
      return sendAddressViaBroadcastOnChannel1 ? "true" : "false"
    case .allowDataTransmissionOnChannel2:
      return allowDataTransmissionOnChannel2 ? "true" : "false"
    case .detectSpeedStepModeAutomatically:
      return detectSpeedStepModeAutomatically ? "true" : "false"
    case .speedStepMode:
      return speedStepMode.title
    case .enableAcceleration:
      return isAccelerationEnabled ? "true" : "false"
    case .accelerationRate:
      return "\(accelerationRate)"
    case .accelerationAdjustment:
      return "\(accelerationAdjustment)"
    case .enableDeceleration:
      return isDecelerationEnabled ? "true" : "false"
    case .decelerationRate:
      return "\(decelerationRate)"
    case .decelerationAdjustment:
      return "\(decelerationAdjustment)"
    case .reverseMode:
      return isReversed ? "true" : "false"
    case .enableForwardTrim:
      return isForwardTrimEnabled ? "true" : "false"
    case .forwardTrim:
      return "\(forwardTrim)"
    case .enableReverseTrim:
      return isReverseTrimEnabled ? "true" : "false"
    case .reverseTrim:
      return "\(reverseTrim)"
    case .enableShuntingModeTrim:
      return isShuntingModeTrimEnabled ? "true" : "false"
    case .shuntingModeTrim:
      return "\(shuntingModeTrim)"
    case .loadAdjustmentOptionalLoad:
      return "\(loadAdjustmentOptionalLoad)"
    case .loadAdjustmentPrimaryLoad:
      return "\(loadAdjustmentPrimaryLoad)"
    case .enableGearboxBacklashCompensation:
      return isGearboxBacklashCompensationEnabled ? "true" : "false"
    case .gearboxBacklashCompensation:
      return "\(gearboxBacklashCompensation)"
    case .timeToBridgePowerInterruption:
      return "\(timeToBridgePowerInterruption)"
    case .preserveDirection:
      return isDirectionPreserved ? "true" : "false"
    case .enableStartingDelay:
      return isStartingDelayEnabled ? "true" : "false"
    case .userId1:
      return "\(userId1)"
    case .userId2:
      return "\(userId2)"
    case .enableDCCProtocol:
      return isDCCProtocolEnabled ? "true" : "false"
    case .enableMarklinMotorolaProtocol:
      return isMarklinMotorolaProtocolEnabled ? "true" : "false"
    case .enableSelectrixProtocol:
      return isSelectrixProtocolEnabled ? "true" : "false"
    case .enableM4Protocol:
      return isM4ProtocolEnabled ? "true" : "false"
    case .memoryPersistentFunction:
      return isMemoryPersistentFunctionEnabled ? "true" : "false"
    case .memoryPersistentSpeed:
      return isMemoryPersistentSpeedEnabled ? "true" : "false"
    case .enableRailComPlusSynchronization:
      return isDecoderSynchronizedWithMasterDecoder ? "true" : "false"
    case .m4MasterDecoderManufacturer:
      return m4MasterDecoderManufacturerId.title
    case .m4MasterDecoderSerialNumber:
      return m4MasterDecoderSerialNumber.toHex(numberOfDigits: 8)
    case .frequencyForBlinkingEffects:
      return "\(frequencyForBlinkingEffects)"
    case .gradeCrossingHoldingTime:
      return "\(gradeCrossingHoldingTime)"
    case .fadeInTimeOfLightEffects:
      return "\(fadeInTimeOfLightEffects)"
    case .fadeOutTimeOfLightEffects:
      return "\(fadeOutTimeOfLightEffects)"
    case .logicalFunctionDimmerBrightnessReduction:
      return "\(logicalFunctionDimmerBrightnessReduction)"
    case .classLightLogicSequenceLength:
      return classLightLogicSequenceLength.title
    case .enforceSlaveCommunicationOnAUX3AndAUX4:
      return isSlaveCommunicationOnAUX3andAUX4Enforced ? "true" : "false"
    case .decoderSensorSettings:
      return decoderSensorSettings.title
    case .enableAutomaticUncoupling:
      return isAutomaticUncouplingEnabled ? "true" : "false"
    case .automaticUncouplingSpeed:
      return "\(automaticUncouplingSpeed)"
    case .automaticUncouplingPushTime:
      return "\(automaticUncouplingPushTime)"
    case .automaticUncouplingWaitTime:
      return "\(automaticUncouplingWaitTime)"
    case .automaticUncouplingMoveTime:
      return "\(automaticUncouplingMoveTime)"
    case .smokeUnitTimeUntilPowerOff:
      return "\(smokeUnitTimeUntilAutomaticPowerOff)"
    case .smokeUnitFanSpeedTrim:
      return "\(smokeUnitFanSpeedTrim)"
    case .smokeUnitTemperatureTrim:
      return "\(smokeUnitTemperatureTrim)"
    case .smokeUnitPreheatingTemperatureForSecondarySmokeUnits:
      return "\(smokeUnitPreheatingTemperatureForSecondarySmokeUnits)"
    case .smokeChuffsDurationRelativeToTriggerDistance:
      return "\(smokeChuffsDurationRelativeToTriggerDistance)"
    case .smokeChuffsMinimumDuration:
      return "\(smokeChuffsMinimumDuration)"
    case .smokeChuffsMaximumDuration:
      return "\(smokeChuffsMaximumDuration)"
    case .minimumSpeed:
      return "\(minimumSpeed)"
    case .maximumSpeed:
      return "\(maximumSpeed)"
    case .enableLoadControlBackEMF:
      return isLoadControlBackEMFEnabled ? "true" : "false"
    case .regulationReference:
      return "\(regulationReference)"
    case .regulationParameterK:
      return "\(regulationParameterK)"
    case .regulationParameterI:
      return "\(regulationParameterI)"
    case .regulationParameterKSlow:
      return "\(regulationParameterKSlow)"
    case .largestInternalSpeedStepThatUsesKSlow:
      return "\(largestInternalSpeedStepThatUsesKSlow)"
    case .regulationInfluenceDuringSlowSpeed:
      return "\(regulationInfluenceDuringSlowSpeed)"
    case .slowSpeedBackEMFSamplingPeriod:
      return "\(slowSpeedBackEMFSamplingPeriod)"
    case .fullSpeedBackEMFSamplingPeriod:
      return "\(fullSpeedBackEMFSamplingPeriod)"
    case .slowSpeedLengthOfMeasurementGap:
      return "\(slowSpeedLengthOfMeasurementGap)"
    case .fullSpeedLengthOfMeasurementGap:
      return "\(fullSpeedLengthOfMeasurementGap)"
    case .enableMotorOverloadProtection:
      return isMotorOverloadProtectionEnabled ? "true" : "false"
    case .enableMotorCurrentLimiter:
      return isMotorCurrentLimiterEnabled ? "true" : "false"
    case .motorCurrentLimiterLimit:
      return "\(motorCurrentLimiterLimit)"
    case .motorPulseFrequency:
      return "\(motorPulseFrequency)"
    case .enableAutomaticParkingBrake:
      return isAutomaticParkingBrakeEnabled ? "true" : "false"
    case .steamChuffMode:
      return steamChuffMode.title
    case .distanceOfSteamChuffsAtSpeedStep1:
      return "\(distanceOfSteamChuffsAtSpeedStep1)"
    case .steamChuffAdjustmentAtHigherSpeedSteps:
      return "\(steamChuffAdjustmentAtHigherSpeedSteps)"
    case .triggerImpulsesPerSteamChuff:
      return "\(triggerImpulsesPerSteamChuff)"
    case .divideTriggerImpulsesInTwoIfShuntingModeEnabled:
      return divideTriggerImpulsesInTwoIfShuntingModeEnabled ? "true" : "false"
    case .enableSecondaryTrigger:
      return isSecondaryTrimmerEnabled ? "true" : "false"
    case .secondaryTriggerDistanceReduction:
      return "\(secondaryTriggerDistanceReduction)"
    case .enableMinimumDistanceOfSteamChuffs:
      return isMinimumDistanceOfSteamChuffsEnabled ? "true" : "false"
    case .minimumDistanceofSteamChuffs:
      return "\(minimumDistanceOfSteamChuffs)"
    case .masterVolume:
      return "\(masterVolume)"
    case .fadeSoundVolumeReduction:
      return "\(fadeSoundVolumeReduction)"
    case .soundFadeOutFadeInTime:
      return "\(soundFadeInFadeOutTime)"
    case .soundBass:
      return "\(toneBass)"
    case .soundTreble:
      return "\(toneTreble)"
    case .brakeSoundSwitchingOnThreshold:
      return "\(brakeSoundSwitchingOnThreshold)"
    case .brakeSoundSwitchingOffThreshold:
      return "\(brakeSoundSwitchingOffThreshold)"
    case .soundControlBasis:
      return soundControlBasis.title
    case .trainLoadAtLowSpeed:
      return "\(trainLoadAtLowSpeed)"
    case .trainLoadAtHighSpeed:
      return "\(trainLoadAtHighSpeed)"
    case .enableLoadOperationThreshold:
      return isThresholdForLoadOperationEnabled ? "true" : "false"
    case .loadOperationThreshold:
      return "\(thresholdForLoadOperation)"
    case .loadOperationTriggeredFunction:
      return loadOperationTriggeredFunction.title
    case .enableIdleOperationThreshold:
      return isThresholdForIdleOperationEnabled ? "true" : "false"
    case .idleOperationThreshold:
      return "\(thresholdForIdleOperation)"
    case .idleOperationTriggeredFunction:
      return idleOperationTriggeredFunction.title
    case .enableSerialFunctionModeF1toF8ForLGBMTS:
      return isSerialFunctionModeF1toF8ForLGBMTSEnabled ? "true" : "false"
    case .enableSupportForBroadwayLimitedSteamEngineControl:
      return isSupportForBroadwayLimitedSteamEngineControlEnabled ? "true" : "false"
    case .enableSUSIMaster:
      return isSUSIMasterEnabled ? "true" : "false"
    case .susiWarning:
      return String(localized:"AUX11 and AUX12 will not work while SUSI is enabled.")
    case .enableSUSISlave:
      return isSUSISlaveEnabled ? "true" : "false"
    case .consistFunctions, .analogModeActiveFunctions, .esuSpeedTable:
      return ""
    case .speedTableIndex:
      return "\(speedTableIndex)"
    case .speedTableEntryValue:
      return "\(speedTableValue)"
    case .speedTablePreset:
      return speedTablePreset.title
    case .physicalOutput:
      return esuDecoderPhysicalOutput.title
    case .physicalOutputPowerOnDelay:
      return "\(getPhysicalOutputValue(property: .physicalOutputPowerOnDelay)!)"
    case .physicalOutputPowerOffDelay:
      return "\(getPhysicalOutputValue(property: .physicalOutputPowerOffDelay)!)"
    case .physicalOutputEnableFunctionTimeout:
      return getPhysicalOutputValue(property: .physicalOutputTimeUntilAutomaticPowerOff)! != 0 ? "true" : "false"
    case .physicalOutputTimeUntilAutomaticPowerOff:
      return "\(getPhysicalOutputValue(property: .physicalOutputTimeUntilAutomaticPowerOff)!)"
    case .physicalOutputOutputMode:
      return esuDecoderPhysicalOutputMode.title(decoder: self)
    case .physicalOutputCouplerForce:
      return "\(getPhysicalOutputValue(property: .physicalOutputCouplerForce)!)"
    case .physicalOutputBrightness:
      return "\(getPhysicalOutputValue(property: .physicalOutputBrightness)!)"
    case .physicalOutputUseClassLightLogic:
      return getPhysicalOutputValue(property: .physicalOutputSequencePosition)! != 0 ? "true" : "false"
    case .physicalOutputSequencePosition:
      return "\(getPhysicalOutputValue(property: .physicalOutputSequencePosition)!)"
    case .physicalOutputSpecialFunctions:
      return String(localized: "Special Functions")
    case .physicalOutputRule17Forward:
      return getPhysicalOutputBoolValue(property: .physicalOutputRule17Forward)! ? "true" : "false"
    case .physicalOutputRule17Reverse:
      return getPhysicalOutputBoolValue(property: .physicalOutputRule17Reverse)! ? "true" : "false"
    case .physicalOutputDimmer:
      return getPhysicalOutputBoolValue(property: .physicalOutputDimmer)! ? "true" : "false"
    case .physicalOutputLEDMode:
      return getPhysicalOutputBoolValue(property: .physicalOutputLEDMode)! ? "true" : "false"
    case .physicalOutputPhaseShift:
      return "\(getPhysicalOutputValue(property: .physicalOutputPhaseShift)!)"
    case .physicalOutputGradeCrossing:
      return getPhysicalOutputBoolValue(property: .physicalOutputGradeCrossing)! ? "true" : "false"
    case .physicalOutputStartupTime:
      return "\(getPhysicalOutputValue(property: .physicalOutputStartupTime)!)"
    case .physicalOutputStartupDescription:
      return String(localized: "Startup time = 255 means defective Neon lamp.")
    case .physicalOutputLevel:
      return "\(getPhysicalOutputValue(property: .physicalOutputLevel)!)"
    case .physicalOutputSmokeUnitControlMode:
      return smokeUnitControlMode.title
    case .physicalOutputSpeed:
      return "\(getPhysicalOutputValue(property: .physicalOutputSpeed)!)"
    case .physicalOutputAccelerationRate:
      return "\(getPhysicalOutputValue(property: .physicalOutputAccelerationRate)!)"
    case .physicalOutputDecelerationRate:
      return "\(getPhysicalOutputValue(property: .physicalOutputDecelerationRate)!)"
    case .physicalOutputHeatWhileLocomotiveStands:
      return "\(getPhysicalOutputValue(property: .physicalOutputHeatWhileLocomotiveStands)!)"
    case .physicalOutputMinimumHeatWhileLocomotiveDriving:
      return "\(getPhysicalOutputValue(property: .physicalOutputMinimumHeatWhileLocomotiveDriving)!)"
    case .physicalOutputMaximumHeatWhileLocomotiveDriving:
      return "\(getPhysicalOutputValue(property: .physicalOutputMaximumHeatWhileLocomotiveDriving)!)"
    case .physicalOutputChuffPower:
      return "\(getPhysicalOutputValue(property: .physicalOutputChuffPower)!)"
    case .physicalOutputFanPower:
      return "\(getPhysicalOutputValue(property: .physicalOutputFanPower)!)"
    case .physicalOutputTimeout:
      return "\(getPhysicalOutputValue(property: .physicalOutputTimeout)!)"
    case .physicalOutputExternalSmokeUnitType:
      return externalSmokeUnitType.title
    case .physicalOutputServoDurationA:
      return "\(getPhysicalOutputValue(property: .physicalOutputServoDurationA)!)"
    case .physicalOutputServoDurationB:
      return "\(getPhysicalOutputValue(property: .physicalOutputServoDurationB)!)"
    case .physicalOutputServoPositionA:
      return "\(getPhysicalOutputValue(property: .physicalOutputServoPositionA)!)"
    case .physicalOutputServoPositionB:
      return "\(getPhysicalOutputValue(property: .physicalOutputServoPositionB)!)"
    case .physicalOutputServoDoNotDisableServoPulseAtPositionA:
      return getPhysicalOutputBoolValue(property: .physicalOutputServoDoNotDisableServoPulseAtPositionA)! ? "true" : "false"
    case .physicalOutputServoDoNotDisableServoPulseAtPositionB:
      return getPhysicalOutputBoolValue(property: .physicalOutputServoDoNotDisableServoPulseAtPositionB)! ? "true" : "false"
    case .physicalOutputStartupTimeInfo:
      return String(localized: "PLACEHOLDER")
    }
  }
  
  public func getInfo(property:ProgrammerToolSettingsProperty) -> String {

    let formatter = NumberFormatter()
    
    formatter.usesGroupingSeparator = true
    formatter.groupingSize = 3

    formatter.alwaysShowsDecimalSeparator = false
    formatter.minimumFractionDigits = 0

    switch property {
    case .dcAnalogModeStartVoltage:
      return "\(analogModeDCStartVoltageInVolts)V"
    case .acAnalogModeStartVoltage:
      return "\(analogModeACStartVoltageInVolts)V"
    case .dcAnalogModeMaximumSpeedVoltage:
      return "\(analogModeDCMaximumSpeedVoltageInVolts)V"
    case .acAnalogModeMaximumSpeedVoltage:
      return "\(analogModeACMaximumSpeedVoltageInVolts)V"
    case .analogMotorHysteresisVoltage:
      return "\(analogMotorHysteresisVoltageInVolts)V"
    case .analogFunctionDifferenceVoltage:
      return "\(analogFunctionDifferenceVoltageInVolts)V"
    case .waitingPeriodBeforeDirectionChange:
      let x = UnitTime.convert(fromValue: abcWaitingTimeInSeconds, fromUnits: .seconds, toUnits: appNode!.unitsTime)
      formatter.maximumFractionDigits = 2
      return "\(formatter.string(from: x as NSNumber)!)\(appNode!.unitsTime.symbol)"
    case .stoppingPeriod:
      let x = UnitTime.convert(fromValue: stoppingPeriodInSeconds, fromUnits: .seconds, toUnits: appNode!.unitsTime)
      formatter.maximumFractionDigits = 2
      return "\(formatter.string(from: x as NSNumber)!)\(appNode!.unitsTime.symbol)"
    case .delayTimeBeforeExitingBrakeSection:
      let x = UnitTime.convert(fromValue: delayBeforeExitingBrakeSectionInSeconds, fromUnits: .seconds, toUnits: appNode!.unitsTime)
      formatter.maximumFractionDigits = 2
      return "\(formatter.string(from: x as NSNumber)!)\(appNode!.unitsTime.symbol)"
    case .brakeFunction1BrakeTimeReduction:
      let x = brakeFunction1BrakeTimeReductionPercentage
      formatter.maximumFractionDigits = 2
      return "\(formatter.string(from: x as NSNumber)!)%"
    case .brakeFunction2BrakeTimeReduction:
      let x = brakeFunction2BrakeTimeReductionPercentage
      formatter.maximumFractionDigits = 2
      return "\(formatter.string(from: x as NSNumber)!)%"
    case .brakeFunction3BrakeTimeReduction:
      let x = brakeFunction3BrakeTimeReductionPercentage
      formatter.maximumFractionDigits = 2
      return "\(formatter.string(from: x as NSNumber)!)%"
    case .accelerationRate:
      let x = UnitTime.convert(fromValue: accelerationRateInSeconds, fromUnits: .seconds, toUnits: appNode!.unitsTime)
      formatter.maximumFractionDigits = 2
      return "\(formatter.string(from: x as NSNumber)!)\(appNode!.unitsTime.symbol)"
    case .accelerationAdjustment:
      let x = UnitTime.convert(fromValue: accelerationAdjustmentInSeconds, fromUnits: .seconds, toUnits: appNode!.unitsTime)
      formatter.maximumFractionDigits = 2
      return "\(formatter.string(from: x as NSNumber)!)\(appNode!.unitsTime.symbol)"
    case .decelerationRate:
      let x = UnitTime.convert(fromValue: decelerationRateInSeconds, fromUnits: .seconds, toUnits: appNode!.unitsTime)
      formatter.maximumFractionDigits = 2
      return "\(formatter.string(from: x as NSNumber)!)\(appNode!.unitsTime.symbol)"
    case .decelerationAdjustment:
      let x = UnitTime.convert(fromValue: decelerationAdjustmentInSeconds, fromUnits: .seconds, toUnits: appNode!.unitsTime)
      formatter.maximumFractionDigits = 2
      return "\(formatter.string(from: x as NSNumber)!)\(appNode!.unitsTime.symbol)"
    case .forwardTrim:
      let x = forwardTrimMultiplier
      formatter.maximumFractionDigits = 2
      return String(localized: "\(formatter.string(from: x as NSNumber)!) × Voltage")
    case .reverseTrim:
      let x = reverseTrimMultiplier
      formatter.maximumFractionDigits = 2
      return String(localized: "\(formatter.string(from: x as NSNumber)!) × Voltage")
    case .shuntingModeTrim:
      let x = shuntingModeTrimMultiplier
      formatter.maximumFractionDigits = 2
      return String(localized: "\(formatter.string(from: x as NSNumber)!) × Drive Level")
    case .loadAdjustmentOptionalLoad:
      let x = loadAdjustmentOptionalLoadMultiplier
      formatter.maximumFractionDigits = 2
      return String(localized: "\(formatter.string(from: x as NSNumber)!)")
    case .loadAdjustmentPrimaryLoad:
      let x = loadAdjustmentPrimaryLoadMultiplier
      formatter.maximumFractionDigits = 2
      return String(localized: "\(formatter.string(from: x as NSNumber)!)")
    case .gearboxBacklashCompensation:
      let x = UnitTime.convert(fromValue: gearboxBacklashCompensationInSeconds, fromUnits: .seconds, toUnits: appNode!.unitsTime)
      formatter.maximumFractionDigits = 2
      return "\(formatter.string(from: x as NSNumber)!)\(appNode!.unitsTime.symbol)"
    case .timeToBridgePowerInterruption:
      let x = UnitTime.convert(fromValue: timeToBridgePowerInterruptionInSeconds, fromUnits: .seconds, toUnits: appNode!.unitsTime)
      formatter.maximumFractionDigits = 2
      return "\(formatter.string(from: x as NSNumber)!)\(appNode!.unitsTime.symbol)"
    case .frequencyForBlinkingEffects:
      let x = UnitTime.convert(fromValue: frequencyForBlinkingEffectsInSeconds, fromUnits: .seconds, toUnits: appNode!.unitsTime)
      formatter.maximumFractionDigits = 2
      return "\(formatter.string(from: x as NSNumber)!)\(appNode!.unitsTime.symbol)"
    case .gradeCrossingHoldingTime:
      let x = UnitTime.convert(fromValue: gradeCrossingHoldingTimeInSeconds, fromUnits: .seconds, toUnits: appNode!.unitsTime)
      formatter.maximumFractionDigits = 2
      return "\(formatter.string(from: x as NSNumber)!)\(appNode!.unitsTime.symbol)"
    case .fadeInTimeOfLightEffects:
      let x = UnitTime.convert(fromValue: fadeInTimeOfLightEffectsInSeconds, fromUnits: .seconds, toUnits: appNode!.unitsTime)
      formatter.maximumFractionDigits = 2
      return "\(formatter.string(from: x as NSNumber)!)\(appNode!.unitsTime.symbol)"
    case .fadeOutTimeOfLightEffects:
      let x = UnitTime.convert(fromValue: fadeOutTimeOfLightEffectsInSeconds, fromUnits: .seconds, toUnits: appNode!.unitsTime)
      formatter.maximumFractionDigits = 2
      return "\(formatter.string(from: x as NSNumber)!)\(appNode!.unitsTime.symbol)"
    case .logicalFunctionDimmerBrightnessReduction:
      let x = logicalFunctionDimmerBrightnessReductionPercentage
      formatter.maximumFractionDigits = 2
      return String(localized: "\(formatter.string(from: x as NSNumber)!)%")
    case .automaticUncouplingPushTime:
      let x = UnitTime.convert(fromValue: automaticUncouplingPushTimeInSeconds, fromUnits: .seconds, toUnits: appNode!.unitsTime)
      formatter.maximumFractionDigits = 2
      return "\(formatter.string(from: x as NSNumber)!)\(appNode!.unitsTime.symbol)"
    case .automaticUncouplingWaitTime:
      let x = UnitTime.convert(fromValue: automaticUncouplingWaitTimeInSeconds, fromUnits: .seconds, toUnits: appNode!.unitsTime)
      formatter.maximumFractionDigits = 2
      return "\(formatter.string(from: x as NSNumber)!)\(appNode!.unitsTime.symbol)"
    case .automaticUncouplingMoveTime:
      let x = UnitTime.convert(fromValue: automaticUncouplingMoveTimeInSeconds, fromUnits: .seconds, toUnits: appNode!.unitsTime)
      formatter.maximumFractionDigits = 2
      return "\(formatter.string(from: x as NSNumber)!)\(appNode!.unitsTime.symbol)"
    case .smokeUnitTimeUntilPowerOff:
      let x = UnitTime.convert(fromValue: smokeUnitTimeUntilAutomaticPowerOffInSeconds, fromUnits: .seconds, toUnits: appNode!.unitsTime)
      formatter.maximumFractionDigits = 2
      return "\(formatter.string(from: x as NSNumber)!)\(appNode!.unitsTime.symbol)"
    case .smokeUnitFanSpeedTrim:
      let x = smokeUnitFanSpeedTrimPercentage
      formatter.maximumFractionDigits = 2
      return String(localized: "\(formatter.string(from: x as NSNumber)!)%")
    case .smokeUnitTemperatureTrim:
      let x = smokeUnitTemperatureTrimPercentage
      formatter.maximumFractionDigits = 2
      return String(localized: "\(formatter.string(from: x as NSNumber)!)%")
    case .smokeUnitPreheatingTemperatureForSecondarySmokeUnits:
      let x = smokeUnitPreheatingTemperatureForSecondarySmokeUnitsInCelsius
      formatter.maximumFractionDigits = 2
      return String(localized: "\(formatter.string(from: x as NSNumber)!)°C")
    case .smokeChuffsDurationRelativeToTriggerDistance:
      let x = smokeChuffsDurationRelativeToTriggerDistancePercentage
      formatter.maximumFractionDigits = 2
      return String(localized: "\(formatter.string(from: x as NSNumber)!)%")
    case .smokeChuffsMinimumDuration:
      let x = UnitTime.convert(fromValue: smokeChuffsMinimumDurationInSeconds, fromUnits: .seconds, toUnits: appNode!.unitsTime)
      formatter.maximumFractionDigits = 2
      return "\(formatter.string(from: x as NSNumber)!)\(appNode!.unitsTime.symbol)"
    case .smokeChuffsMaximumDuration:
      let x = UnitTime.convert(fromValue: smokeChuffsMaximumDurationInSeconds, fromUnits: .seconds, toUnits: appNode!.unitsTime)
      formatter.maximumFractionDigits = 2
      return "\(formatter.string(from: x as NSNumber)!)\(appNode!.unitsTime.symbol)"
    case .minimumSpeed:
      let x = minimumSpeedPercentage
      formatter.maximumFractionDigits = 2
      return String(localized: "\(formatter.string(from: x as NSNumber)!)%")
    case .maximumSpeed:
      let x = maximumSpeedPercentage
      formatter.maximumFractionDigits = 2
      return String(localized: "\(formatter.string(from: x as NSNumber)!)%")
    case .regulationReference:
      let x = regulationReferenceInVolts
      formatter.maximumFractionDigits = 2
      return String(localized: "\(formatter.string(from: x as NSNumber)!)V")
    case .regulationParameterI:
      let x = UnitTime.convert(fromValue: regulationParameterIInSeconds, fromUnits: .seconds, toUnits: appNode!.unitsTime)
      formatter.maximumFractionDigits = 2
      return "\(formatter.string(from: x as NSNumber)!)\(appNode!.unitsTime.symbol)"
    case .regulationInfluenceDuringSlowSpeed:
      let x = regulationInfluenceDuringSlowSpeedPercentage
      formatter.maximumFractionDigits = 2
      return String(localized: "\(formatter.string(from: x as NSNumber)!)%")
    case .slowSpeedBackEMFSamplingPeriod:
      let x = UnitTime.convert(fromValue: slowSpeedBackEMFSamplingPeriodInSeconds, fromUnits: .seconds, toUnits: appNode!.unitsTime)
      formatter.maximumFractionDigits = 2
      return "\(formatter.string(from: x as NSNumber)!)\(appNode!.unitsTime.symbol)"
    case .fullSpeedBackEMFSamplingPeriod:
      let x = UnitTime.convert(fromValue: fullSpeedBackEMFSamplingPeriodInSeconds, fromUnits: .seconds, toUnits: appNode!.unitsTime)
      formatter.maximumFractionDigits = 2
      return "\(formatter.string(from: x as NSNumber)!)\(appNode!.unitsTime.symbol)"
    case .slowSpeedLengthOfMeasurementGap:
      let x = UnitTime.convert(fromValue: slowSpeedLengthOfMeasurementGapInSeconds, fromUnits: .seconds, toUnits: appNode!.unitsTime)
      formatter.maximumFractionDigits = 2
      return "\(formatter.string(from: x as NSNumber)!)\(appNode!.unitsTime.symbol)"
    case .fullSpeedLengthOfMeasurementGap:
      let x = UnitTime.convert(fromValue: fullSpeedLengthOfMeasurementGapInSeconds, fromUnits: .seconds, toUnits: appNode!.unitsTime)
      formatter.maximumFractionDigits = 2
      return "\(formatter.string(from: x as NSNumber)!)\(appNode!.unitsTime.symbol)"
    case .motorCurrentLimiterLimit:
      let x = motorCurrentLimiterLimitPercentage
      formatter.maximumFractionDigits = 2
      return String(localized: "\(formatter.string(from: x as NSNumber)!)%")
    case .motorPulseFrequency:
      let x = motorPulseFrequencyInHertz
      formatter.maximumFractionDigits = 2
      return String(localized: "\(formatter.string(from: x as NSNumber)!)Hz")
    case .distanceOfSteamChuffsAtSpeedStep1:
      let x = UnitTime.convert(fromValue: distanceOfSteamChuffsAtSpeedStep1InSeconds, fromUnits: .seconds, toUnits: appNode!.unitsTime)
      formatter.maximumFractionDigits = 2
      return "\(formatter.string(from: x as NSNumber)!)\(appNode!.unitsTime.symbol)"
    case .secondaryTriggerDistanceReduction:
      let x = secondaryTriggerDistanceReductionAmount
      formatter.maximumFractionDigits = 2
      return "\(formatter.string(from: x as NSNumber)!)"
    case .minimumDistanceofSteamChuffs:
      let x = UnitTime.convert(fromValue: minimumDistanceOfSteamChuffsInSeconds, fromUnits: .seconds, toUnits: appNode!.unitsTime)
      formatter.maximumFractionDigits = 2
      return "\(formatter.string(from: x as NSNumber)!)\(appNode!.unitsTime.symbol)"
    case .masterVolume:
      let x = masterVolumePercentage
      formatter.maximumFractionDigits = 2
      return String(localized: "\(formatter.string(from: x as NSNumber)!)%")
    case .fadeSoundVolumeReduction:
      let x = fadeSoundVolumeReductionPercentage
      formatter.maximumFractionDigits = 2
      return String(localized: "\(formatter.string(from: x as NSNumber)!)%")
    case .soundFadeOutFadeInTime:
      let x = UnitTime.convert(fromValue: soundFadeInFadeOutTimeInSeconds, fromUnits: .seconds, toUnits: appNode!.unitsTime)
      formatter.maximumFractionDigits = 2
      return "\(formatter.string(from: x as NSNumber)!)\(appNode!.unitsTime.symbol)"
    case .soundBass:
      let x = toneBassdB
      formatter.maximumFractionDigits = 2
      return String(localized: "\(formatter.string(from: x as NSNumber)!)dB")
    case .soundTreble:
      let x = toneTrebledB
      formatter.maximumFractionDigits = 2
      return String(localized: "\(formatter.string(from: x as NSNumber)!)dB")
    case .trainLoadAtLowSpeed:
      let x = trainLoadAtLowSpeedPercentage
      formatter.maximumFractionDigits = 2
      return String(localized: "\(formatter.string(from: x as NSNumber)!)%")
    case .trainLoadAtHighSpeed:
      let x = trainLoadAtHighSpeedPercentage
      formatter.maximumFractionDigits = 2
      return String(localized: "\(formatter.string(from: x as NSNumber)!)%")
    case .physicalOutputPowerOnDelay:
      let x = UnitTime.convert(fromValue: Double(getPhysicalOutputValue(property: .physicalOutputPowerOnDelay)!) * 0.40933333, fromUnits: .seconds, toUnits: appNode!.unitsTime)
      formatter.maximumFractionDigits = 2
      return "\(formatter.string(from: x as NSNumber)!)\(appNode!.unitsTime.symbol)"
    case .physicalOutputPowerOffDelay:
      let x = UnitTime.convert(fromValue: Double(getPhysicalOutputValue(property: .physicalOutputPowerOffDelay)!) * 0.40933333, fromUnits: .seconds, toUnits: appNode!.unitsTime)
      formatter.maximumFractionDigits = 2
      return "\(formatter.string(from: x as NSNumber)!)\(appNode!.unitsTime.symbol)"
    case .physicalOutputTimeUntilAutomaticPowerOff:
      let x = UnitTime.convert(fromValue: Double(getPhysicalOutputValue(property: .physicalOutputTimeUntilAutomaticPowerOff)!) * 0.41, fromUnits: .seconds, toUnits: appNode!.unitsTime)
      formatter.maximumFractionDigits = 2
      return "\(formatter.string(from: x as NSNumber)!)\(appNode!.unitsTime.symbol)"
    case .physicalOutputTimeout:
      let x = UnitTime.convert(fromValue: Double(getPhysicalOutputValue(property: .physicalOutputTimeout)!) * 0.256, fromUnits: .seconds, toUnits: appNode!.unitsTime)
      formatter.maximumFractionDigits = 2
      return "\(formatter.string(from: x as NSNumber)!)\(appNode!.unitsTime.symbol)"
    case .physicalOutputServoDurationA:
      let x = UnitTime.convert(fromValue: Double(getPhysicalOutputValue(property: .physicalOutputServoDurationA)!) * 0.25, fromUnits: .seconds, toUnits: appNode!.unitsTime)
      formatter.maximumFractionDigits = 2
      return "\(formatter.string(from: x as NSNumber)!)\(appNode!.unitsTime.symbol)"
    case .physicalOutputServoDurationB:
      let x = UnitTime.convert(fromValue: Double(getPhysicalOutputValue(property: .physicalOutputServoDurationB)!) * 0.25, fromUnits: .seconds, toUnits: appNode!.unitsTime)
      formatter.maximumFractionDigits = 2
      return "\(formatter.string(from: x as NSNumber)!)\(appNode!.unitsTime.symbol)"

    default:
      return ""
    }
    
  }
  
  public func isValid(property:ProgrammerToolSettingsProperty, string:String) -> Bool {
    
    switch property {
    case .locomotiveAddressLong:
      guard let value = UInt16(string), value > 0 && value < 10240 else {
        return false
      }
    case .m4MasterDecoderSerialNumber:
      guard let _ = UInt32(hex:string) else {
        return false
      }
    case .locomotiveAddressShort, .consistAddress, .waitingPeriodBeforeDirectionChange, .brakeDistanceLength, .brakeDistanceLengthBackwards, .stoppingPeriod, .accelerationRate, .decelerationRate, .forwardTrim, .reverseTrim, .gearboxBacklashCompensation, .accelerationAdjustment, .decelerationAdjustment, .shuntingModeTrim, .acAnalogModeStartVoltage, .acAnalogModeMaximumSpeedVoltage, .dcAnalogModeStartVoltage, .dcAnalogModeMaximumSpeedVoltage, .analogMotorHysteresisVoltage, .analogFunctionDifferenceVoltage, .voltageDifferenceIndicatingABCBrakeSection, .abcReducedSpeed, .hluSpeedLimit1, .hluSpeedLimit2, .hluSpeedLimit3, .hluSpeedLimit4, .hluSpeedLimit5, .delayTimeBeforeExitingBrakeSection, .brakeFunction1BrakeTimeReduction, .brakeFunction2BrakeTimeReduction, .brakeFunction3BrakeTimeReduction, .userId1, .userId2, .loadAdjustmentOptionalLoad, .loadAdjustmentPrimaryLoad, .timeToBridgePowerInterruption, .maximumSpeedWhenBrakeFunction1Active, .maximumSpeedWhenBrakeFunction2Active, .maximumSpeedWhenBrakeFunction3Active, .frequencyForBlinkingEffects, .gradeCrossingHoldingTime, .fadeInTimeOfLightEffects, .fadeOutTimeOfLightEffects, .logicalFunctionDimmerBrightnessReduction, .automaticUncouplingSpeed, .automaticUncouplingPushTime, .automaticUncouplingWaitTime, .automaticUncouplingMoveTime, .smokeUnitTimeUntilPowerOff, .smokeUnitFanSpeedTrim, .smokeUnitTemperatureTrim, .smokeUnitPreheatingTemperatureForSecondarySmokeUnits, .smokeChuffsDurationRelativeToTriggerDistance, .smokeChuffsMinimumDuration, .smokeChuffsMaximumDuration, .minimumSpeed, .maximumSpeed, .regulationReference, .regulationParameterK, .regulationParameterI, .regulationParameterKSlow, .largestInternalSpeedStepThatUsesKSlow, .regulationInfluenceDuringSlowSpeed, .slowSpeedBackEMFSamplingPeriod, .fullSpeedBackEMFSamplingPeriod, .slowSpeedLengthOfMeasurementGap, .fullSpeedLengthOfMeasurementGap, .motorCurrentLimiterLimit, .motorPulseFrequency, .distanceOfSteamChuffsAtSpeedStep1, .steamChuffAdjustmentAtHigherSpeedSteps, .triggerImpulsesPerSteamChuff, .secondaryTriggerDistanceReduction, .minimumDistanceofSteamChuffs, .masterVolume, .soundFadeOutFadeInTime, .fadeSoundVolumeReduction, .soundBass, .soundTreble, .trainLoadAtLowSpeed, .trainLoadAtHighSpeed, .idleOperationThreshold, .loadOperationThreshold, .speedTableIndex, .speedTableEntryValue, .physicalOutputPowerOnDelay, .physicalOutputPowerOffDelay, .physicalOutputEnableFunctionTimeout, .physicalOutputCouplerForce, .physicalOutputSequencePosition, .physicalOutputBrightness, .physicalOutputPhaseShift, .physicalOutputStartupTime, .physicalOutputLevel, .physicalOutputSpeed, .physicalOutputAccelerationRate, .physicalOutputDecelerationRate, .physicalOutputHeatWhileLocomotiveStands, .physicalOutputMinimumHeatWhileLocomotiveDriving, .physicalOutputMaximumHeatWhileLocomotiveDriving, .physicalOutputChuffPower, .physicalOutputFanPower, .physicalOutputTimeout, .physicalOutputServoDurationA, .physicalOutputServoDurationB, .physicalOutputServoPositionA, .physicalOutputServoPositionB:
      guard let value = UInt8(string), Double(value) >= property.minValue && Double(value) <= property.maxValue else {
        return false
      }
    default:
      break
    }

    return true

  }
  
  public func setValue(property: ProgrammerToolSettingsProperty, string: String) {
    
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
        debugLog("Found")
      }
      else {
        
      }
    }
  }
  
}
