//
//  Decoder.swift
//  MyTrains
//
//  Created by Paul Willmott on 05/07/2024.
//

import Foundation

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
  
  private var savedBlocks : [UInt8]
  
  private var modifiedBlocks : [UInt8] = []
  
  private var _indicies : [UInt16] = []
  
  private var indexLookup : [UInt16:Int] = [:]
  
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
  
  public var indicies : [UInt16] {
    return _indicies
  }
  
  public var cvsModified : [CV] {
    
    var result : [CV] = []
    
    for index in indicies {
      
      if let offset = indexLookup[index] {
        
        let isIndexed = index != 0
        
        let baseOffset = offset - 1 - (isIndexed ? 256 : 0)
        
        for cv : UInt16 in (isIndexed ? 1 : 257) ... (isIndexed ? 1024 : 512) {
          
          let ptr = baseOffset + Int(cv)
          
          if modifiedBlocks[ptr] != savedBlocks[ptr] {
            
            if let cvConstant = CV(index: index, cv: cv, indexMethod: .cv3132) {
              result.append(cvConstant)
            }
            else if let cvConstant = CV(index: index, cv: cv, indexMethod: .cv3132, isHidden: true) {
              result.append(cvConstant)
            }

          }
          
        }
        
      }
      
    }
    
    result.sort {$0.rawValue < $1.rawValue}
    
    return result
    
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
  
  public func getUInt8(cv:CV) -> UInt8? {
    
    guard let offset = indexLookup[cv.index] else {
      return nil
    }
    
    return modifiedBlocks[offset + Int(cv.cv) - 1 - (cv.isIndexed ? 256 : 0)]
    
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
  
}
