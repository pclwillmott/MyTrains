//
//  LCCCDIDataElement.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/04/2023.
//

import Foundation

public class CDIElement {
  
  // MARK: Constructors
  
  init(type:OpenLCBCDIElementType) {
    self.type = type
  }
  
  // MARK: Private Properties
  
  private var _name : String = ""
  
  // MARK: Public Properties
  
  public var type : OpenLCBCDIElementType
  
  public var childElements : [CDIElement] = []
  
  public var min : String?
  
  public var max : String?
  
  public var defaultValue : String?
  
  public var floatFormat : String?
  
  public var map : [LCCCDIMapRelation] = []
  
  public var isMap : Bool {
    return map.count > 0
  }
  
  public var size : Int = 0
  
  public var offset : Int = 0
  
  public var name : String {
    get {
      switch type {
      case .manufacturer:
        return "Manufacturer"
      case .model:
        return "Model"
      case .softwareVersion:
        return "Software Version"
      case .hardwareVersion:
        return "Hardware Version"
      default:
        return _name
      }
    }
    set(value) {
      _name = value
    }
  }
  
  public var description : [String] = []
  
  public var repname : String = ""
  
  public var replication : Int = 1
  
  public var stringValue : String = ""

  public var space : UInt8 = 0
  
  public var origin : Int = 0
  
}
