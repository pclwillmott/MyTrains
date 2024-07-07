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
