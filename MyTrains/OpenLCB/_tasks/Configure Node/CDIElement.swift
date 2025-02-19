//
//  LCCCDIDataElement.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/04/2023.
//

import Foundation

public class CDIElement {
  
  // MARK: Constructors & Destructors
  
  init(type:OpenLCBCDIElementType) {
    self.type = type
  }
  
  deinit {
    childElements.removeAll()
    map.removeAll()
    min = nil
    max = nil
    defaultValue = nil
    floatFormat = nil
    description.removeAll()
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
  
  public var map : [CDIMapRelation] = []
  
  public var size : Int = 0
  
  public var offset : Int = 0
  
  public var description : [String] = []
  
  public var repname : String = ""
  
  public var replication : Int = 1
  
  public var stringValue : String = ""

  public var space : UInt8 = 0
  
  public var origin : Int = 0

  public var isMap : Bool {
    return map.count > 0
  }
  
  public var name : String {
    get {
      switch type {
      case .manufacturer:
        return String(localized: "Manufacturer")
      case .model:
        return String(localized: "Model")
      case .softwareVersion:
        return String(localized: "Software Version")
      case .hardwareVersion:
        return String(localized: "Hardware Version")
      default:
        return _name
      }
    }
    set(value) {
      _name = value
    }
  }
    
}
