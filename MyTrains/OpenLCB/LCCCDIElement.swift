//
//  LCCCDIDataElement.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/04/2023.
//

import Foundation

public class LCCCDIElement {
  
  // MARK: Constructors
  
  init(type:OpenLCBCDIElementType) {
    self.type = type
  }
  
  // MARK: Public Properties
  
  public var type : OpenLCBCDIElementType
  
  public var childElements : [LCCCDIElement] = []
  
  public var min : String?
  
  public var max : String?
  
  public var defaultValue : String?
  
  public var floatFormat : String?
  
  public var map : [LCCCDIMapRelation] = []
  
  public var size : Int = 0
  
  public var offset : Int = 0
  
  public var name : String = ""
  
  public var description : String = ""
  
  public var repname : String = ""
  
  public var replication : Int = 1
  
  public var stringValue : String = ""

  public var space : UInt8 = 0
  
  public var origin : Int = 0
  
  public var address : Int = 0
  
  public var sortAddress : UInt64 {
    get {
      return (UInt64(space) << 32) | UInt64(address)
    }
  }
  
  public var tag : Int = -1
  
  // MARK: Public Methods
  
  public func clone() -> LCCCDIElement {
    
    let result = LCCCDIElement(type: self.type)
    
    result.min = self.min
    result.max = self.max
    result.defaultValue = self.defaultValue
    result.size = self.size
    result.offset = self.offset
    result.name = self.name
    result.description = self.description
    result.repname = self.repname
    result.stringValue = self.stringValue
    result.space = self.space
    result.origin = self.origin
    result.floatFormat = self.floatFormat
    
    for relation in self.map {
      result.map.append(relation)
    }
    
    return result
    
  }
  
}