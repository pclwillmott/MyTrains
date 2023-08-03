//
//  OpenLCBNodeType.swift
//  MyTrains
//
//  Created by Paul Willmott on 03/07/2023.
//

import Foundation
import Cocoa

public enum MyTrainsVirtualNodeType : String {
  
  case applicationNode       = "Application Node"
  case canGatewayNode        = "CAN Gateway Node"
  case clockNode             = "Virtual Clock Node"
  case throttleNode          = "Virtual Throttle Node"
  case locoNetGatewayNode    = "Virtual LocoNet Gateway Node"
  case trainNode             = "Virtual Train Node"
  case configurationToolNode = "Configuration Tool Node"
  case genericVirtualNode    = "Generic Virtual Node"
  case locoNetMonitorNode    = "LocoNet Monitor Node"
  case programmerToolNode    = "DCC Programmer Tool Node"
  case programmingTrackNode  = "DCC Programming Track Node"
 
  // MARK: Public Properties
  
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
        .canGatewayNode,
        .locoNetGatewayNode,
        .throttleNode,
        .trainNode,
        .programmingTrackNode,
      ]
      return publicNodeTypes.contains(self)
    }
  }
  
  public var baseNodeId : UInt64 {
    
    get {
      
      let baseId : [MyTrainsVirtualNodeType:UInt64] = [
        .canGatewayNode        : 0x09000d590001,
        .applicationNode       : 0x09000d600001,
        .locoNetMonitorNode    : 0x09000d60ff01,
        .clockNode             : 0x09000d610001,
        .locoNetGatewayNode    : 0x09000d620001,
        .configurationToolNode : 0x09000d630001,
        .trainNode             : 0x09000d640001,
        .throttleNode          : 0x09000d650001,
        .programmerToolNode    : 0x09000d660001,
        .programmingTrackNode  : 0x09000d670001,
        .genericVirtualNode    : 0x09000d6f0001,
      ]
      
      return baseId[self]!
      
    }
    
  }
  
  // MARK: Public Methods
  
  public func defaultUserNodeName(nodeId:UInt64) -> String {
    var userName = self.name
    userName.removeLast(5)
    return "\(userName) #\(nodeId - self.baseNodeId + 1)"
  }
  
  // MARK: Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    
    comboBox.removeAllItems()
    
    comboBox.deselectItem(at: comboBox.indexOfSelectedItem)
    
    let items = [
      canGatewayNode.name,
      clockNode.name,
      locoNetGatewayNode.name,
      trainNode.name,
      throttleNode.name,
      applicationNode.name,
      configurationToolNode.name,
      locoNetMonitorNode.name,
      programmerToolNode.name,
      programmingTrackNode.name,
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
