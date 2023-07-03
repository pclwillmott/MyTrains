//
//  OpenLCBNodeType.swift
//  MyTrains
//
//  Created by Paul Willmott on 03/07/2023.
//

import Foundation
import Cocoa

public enum MyTrainsVirtualNodeType : String {
  
  case clockNode             = "Virtual Clock Node"
  case throttleNode          = "Virtual Throttle Node"
  case locoNetGatewayNode    = "Virtual LocoNet Gateway Node"
  case trainNode             = "Virtual Train Node"
  case applicationNode       = "Application Node"
  case configurationToolNode = "Configuration Tool Node"
  case genericVirtualNode    = "Generic Virtual Node"
  
  public var name : String {
    get {
      return self.rawValue
    }
  }
  
  public var manufacturerName : String {
    get {
      return "MyTrains"
    }
  }
  
  public var isPublic : Bool {
    get {
      let publicNodeTypes : Set<MyTrainsVirtualNodeType> = [
        .clockNode,
        .locoNetGatewayNode,
        .throttleNode,
        .trainNode,
      ]
      return publicNodeTypes.contains(self)
    }
  }
  
  public var baseNodeId : UInt64 {
    
    get {
      
      let baseId : [MyTrainsVirtualNodeType:UInt64] = [
        .applicationNode       : 0x09000d600001,
        .clockNode             : 0x09000d610001,
        .locoNetGatewayNode    : 0x09000d620001,
        .configurationToolNode : 0x09000d630001,
        .trainNode             : 0x09000d640001,
        .throttleNode          : 0x09000d650001,
        .genericVirtualNode    : 0x09000d6f0001,
      ]
      
      return baseId[self]!
      
    }
    
  }
  
  // MARK: Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    
    comboBox.removeAllItems()
    
    comboBox.deselectItem(at: comboBox.indexOfSelectedItem)
    
    let items = [
      clockNode.name,
      locoNetGatewayNode.name,
      trainNode.name,
      throttleNode.name,
    ]
    
    comboBox.addItems(withObjectValues: items)
    
  }
  
  public static func select(comboBox:NSComboBox, virtualNodeType:MyTrainsVirtualNodeType) {
    comboBox.stringValue = virtualNodeType.isPublic ? virtualNodeType.name : ""
  }
  
  public static func selected(comboBox:NSComboBox) -> MyTrainsVirtualNodeType? {
    return MyTrainsVirtualNodeType(rawValue: comboBox.stringValue)
  }
  
}
