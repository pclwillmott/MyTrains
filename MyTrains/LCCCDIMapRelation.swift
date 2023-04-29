//
//  LCCCDIMapRelation.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/04/2023.
//

import Foundation

public class LCCCDIMapRelation {
  
  // MARK: Constructors
  
  init(property:String, stringValue:String) {
    
    self.property = property
    
    self.stringValue = stringValue
    
  }
  
  // MARK: Public Properties
  
  public var property : String
  
  public var stringValue : String
  
  public var intValue : Int {
    get {
      return Int(stringValue) ?? 0
    }
  }
  
  public var floatValue : Float32 {
    get {
      return Float32(stringValue) ?? +0.0
    }
  }
  
}
