//
//  LCCCDIElement.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/04/2023.
//

import Foundation

public class LCCCDIElement {
  
  // MARK: Constructors
  
  public init(type:LCCCDIElementType) {
    self.type = type
  }
  
  // MARK: Public Properties
  
  public var space : UInt8 = 0
  
  public var type : LCCCDIElementType
  
  public var origin : Int = 0
  
  public var name : String = ""
  
  public var description : String = ""
  
  public var dataElements : [LCCCDIDataElement] = []
  
}
