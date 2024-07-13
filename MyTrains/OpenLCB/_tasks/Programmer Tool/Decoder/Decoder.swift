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
      setUInt8(cv: .cv_000_000_134, value: value)
    }
  }
  
  public var abcReducedSpeed : UInt8 {
    get {
      return getUInt8(cv: .cv_000_000_123)!
    }
    set(value) {
      setUInt8(cv: .cv_000_000_123, value: value)
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
      setUInt8(cv: .cv_000_000_254, value: value)
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
      setUInt8(cv: .cv_000_000_255, value: value)
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
      setUInt8(cv: .cv_000_000_182, value: value)
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
      setUInt8(cv: .cv_000_000_183, value: value)
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
      setUInt8(cv: .cv_000_000_184, value: value)
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

  // MARK: Private Methods
  
  // MARK: Public Methods
  
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
      return String(localized: "Enable ABC brake mode (asymmetrical DCC signal:")
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
    case .userId1:
      return "\(userId1)"
    case .userId2:
      return "\(userId2)"
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
    default:
      return ""
    }
    
  }
  
  public func isValid(property:ProgrammerToolSettingsProperty, string:String) -> Bool {
    
    switch property {
    case .locomotiveAddressShort, .consistAddress:
      guard let value = UInt8(string), value > 0 && value < 128 else {
        return false
      }
    case .locomotiveAddressLong:
      guard let value = UInt16(string), value > 0 && value < 10240 else {
        return false
      }
    case .waitingPeriodBeforeDirectionChange, .brakeDistanceLength, .brakeDistanceLengthBackwards, .stoppingPeriod:
      guard let value = UInt8(string), value > 0 else {
        return false
      }
    case .maximumSpeedWhenBrakeFunction1Active, .maximumSpeedWhenBrakeFunction2Active, .maximumSpeedWhenBrakeFunction3Active:
      guard let value = UInt8(string), value < 127 else {
        return false
      }
    case .acAnalogModeStartVoltage, .acAnalogModeMaximumSpeedVoltage, .dcAnalogModeStartVoltage, .dcAnalogModeMaximumSpeedVoltage, .analogMotorHysteresisVoltage, .analogFunctionDifferenceVoltage, .voltageDifferenceIndicatingABCBrakeSection, .abcReducedSpeed, .hluSpeedLimit1, .hluSpeedLimit2, .hluSpeedLimit3, .hluSpeedLimit4, .hluSpeedLimit5, .delayTimeBeforeExitingBrakeSection, .brakeFunction1BrakeTimeReduction, .brakeFunction2BrakeTimeReduction, .brakeFunction3BrakeTimeReduction, .userId1, .userId2:
      guard let _ = UInt8(string) else {
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
    case .userId1:
      userId1 = UInt8(string)!
    case .userId2:
      userId2 = UInt8(string)!
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
