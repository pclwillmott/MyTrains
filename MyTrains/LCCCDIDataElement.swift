//
//  LCCCDIDataElement.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/04/2023.
//

import Foundation

public class LCCCDIDataElement {
  
  // MARK: Constructors
  
  init(parentElement:LCCCDIElement, parentDataElement:LCCCDIDataElement?, type:LCCCDIDataElementType) {
    
    self.type = type
    
    self.parentElement = parentElement
    
    self.parentDataElement = parentDataElement
    
  }
  
  // MARK: Public Properties
  
  public var type : LCCCDIDataElementType
  
  public var dataElements : [LCCCDIDataElement] = []
  
  public var parentDataElement : LCCCDIDataElement?
  
  public var parentElement : LCCCDIElement
  
  public var min : String?
  
  public var max : String?
  
  public var defaultValue : String?
  
  public var map : [LCCCDIMapRelation] = []
  
  public var size : Int = 0
  
  public var offset : Int = 0
  
  public var name : String = ""
  
  public var description : String = ""
  
  public var repname : String = ""
  
  public var replication : Int = 1
  
  public var stringValue : String = ""
  
}
