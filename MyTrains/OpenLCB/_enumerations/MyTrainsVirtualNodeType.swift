//
//  OpenLCBNodeType.swift
//  MyTrains
//
//  Created by Paul Willmott on 03/07/2023.
//

import Foundation
import AppKit

public enum MyTrainsVirtualNodeType : UInt16 {
  
  case genericVirtualNode    = 0
  case canGatewayNode        = 1
  case clockNode             = 2
  case throttleNode          = 3
  case locoNetGatewayNode    = 4
  case trainNode             = 5
  case configurationToolNode = 6
  case locoNetMonitorNode    = 8
  case programmerToolNode    = 9
  case programmingTrackNode  = 10
  case digitraxBXP88Node     = 11
  case layoutNode            = 12
  case switchboardNode       = 13
  case switchboardItemNode   = 14
  case applicationNode       = 15

  // MARK: Public Properties
  
  public var title : String {
    return MyTrainsVirtualNodeType.titles[self]!
  }
  
  public var manufacturerName : String {
    return "MyTrains"
  }
  
  public var isInternal : Bool {
    
    let internals : Set<MyTrainsVirtualNodeType> = [
      .layoutNode,
      .switchboardNode,
      .switchboardItemNode,
    ]
    
    return internals.contains(self)
    
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
        .digitraxBXP88Node,
      ]
      return publicNodeTypes.contains(self)
    }
  }
  
  public var baseNodeId : UInt64 {
    return MyTrainsVirtualNodeType.baseId[self]!
  }
  
  public var startupOrder : Int {
    return MyTrainsVirtualNodeType._startupOrder[self] ?? 0x7FFFFFFFFFFFFFFF
  }
  
  public var nodeIdIncrement : UInt64 {
    
    switch self {
    case .digitraxBXP88Node:
      return 8
    default:
      return 1
    }
    
  }
  
  // MARK: Public Methods
  
  public var defaultUserNodeName : String {
    return MyTrainsVirtualNodeType.defaultNames[self]!
  }
  
  // MARK: Private Class Properties
  
  public static let defaultNames : [MyTrainsVirtualNodeType:String] = [
    .applicationNode:       String(localized: "Application", comment: "Used to create a default OpenLCB virtual name"),
    .canGatewayNode:        String(localized: "CAN Gateway", comment: "Used to create a default OpenLCB virtual name"),
    .clockNode:             String(localized: "Virtual Clock", comment: "Used to create a default OpenLCB virtual name"),
    .throttleNode:          String(localized: "Virtual Throttle", comment: "Used to create a default OpenLCB virtual name"),
    .locoNetGatewayNode:    String(localized: "Virtual LocoNet Gateway", comment: "Used to create a default OpenLCB virtual name"),
    .trainNode:             String(localized: "Virtual Train", comment: "Used to create a default OpenLCB virtual name"),
    .configurationToolNode: String(localized: "Configuration Tool", comment: "Used to create a default OpenLCB virtual name"),
    .genericVirtualNode:    String(localized: "Generic Virtual", comment: "Used to create a default OpenLCB virtual name"),
    .locoNetMonitorNode:    String(localized: "LocoNet Monitor", comment: "Used to create a default OpenLCB virtual name"),
    .programmerToolNode:    String(localized: "DCC Programmer Tool", comment: "Used to create a default OpenLCB virtual name"),
    .programmingTrackNode:  String(localized: "DCC Programming Track", comment: "Used to create a default OpenLCB virtual name"),
    .digitraxBXP88Node:     String(localized: "Digitrax BXP88", comment: "Used to create a default OpenLCB virtual name"),
    .layoutNode:            String(localized: "Layout", comment: "Used to create a default OpenLCB virtual name"),
    .switchboardNode:       String(localized: "Switchboard", comment: "Used to create a default OpenLCB virtual name"),
    .switchboardItemNode:   String(localized: "Switchboard Item", comment: "Used to create a default OpenLCB virtual name"),
  ]

  private static let _startupOrder : [MyTrainsVirtualNodeType:Int] = [
    .canGatewayNode        : 0,
    .applicationNode       : 1,
    .locoNetMonitorNode    : 2,
    .clockNode             : 3,
    .locoNetGatewayNode    : 4,
    .configurationToolNode : 5,
    .trainNode             : 6,
    .throttleNode          : 7,
    .programmerToolNode    : 8,
    .programmingTrackNode  : 9,
    .digitraxBXP88Node     : 10,
    .genericVirtualNode    : 11,
    .layoutNode            : 12,
    .switchboardNode       : 13,
    .switchboardItemNode   : 14,
  ]

  // MARK: Public Class Properties
 
  public static var newFileOpenLCBItems : [MyTrainsVirtualNodeType] {
    
    guard let appMode else {
      return []
    }
    
    switch appMode {
    case .master:
      return [
        .throttleNode,
        .trainNode,
        .canGatewayNode,
        .clockNode,
      ]
    case .delegate:
      return [
        .throttleNode,
        .trainNode,
      ]
    }

  }

  public static var newFileLocoNetItems : [MyTrainsVirtualNodeType] {
    
    guard let appMode else {
      return []
    }
    
    switch appMode {
    case .master:
      return [
         .locoNetGatewayNode,
         .programmingTrackNode,
         .digitraxBXP88Node,
      ]
    case .delegate:
      return [
      ]
    }
    
  }

  public static let titles : [MyTrainsVirtualNodeType:String] = [
    .applicationNode:       String(localized: "Application Node", comment: "Used to describe an OpenLCB virtual node"),
    .canGatewayNode:        String(localized: "CAN Gateway Node", comment: "Used to describe an OpenLCB virtual node"),
    .clockNode:             String(localized: "Virtual Clock Node", comment: "Used to describe an OpenLCB virtual node"),
    .throttleNode:          String(localized: "Virtual Throttle Node", comment: "Used to describe an OpenLCB virtual node"),
    .locoNetGatewayNode:    String(localized: "Virtual LocoNet Gateway Node", comment: "Used to describe an OpenLCB virtual node"),
    .trainNode:             String(localized: "Virtual Train Node", comment: "Used to describe an OpenLCB virtual node"),
    .configurationToolNode: String(localized: "Configuration Tool Node", comment: "Used to describe an OpenLCB virtual node"),
    .genericVirtualNode:    String(localized: "Generic Virtual Node", comment: "Used to describe an OpenLCB virtual node"),
    .locoNetMonitorNode:    String(localized: "LocoNet Monitor Node", comment: "Used to describe an OpenLCB virtual node"),
    .programmerToolNode:    String(localized: "DCC Programmer Tool Node", comment: "Used to describe an OpenLCB virtual node"),
    .programmingTrackNode:  String(localized: "DCC Programming Track Node", comment: "Used to describe an OpenLCB virtual node"),
    .digitraxBXP88Node:     String(localized: "Digitrax BXP88 Node", comment: "Used to describe an OpenLCB virtual node"),
    .layoutNode:            String(localized: "Layout Node", comment: "Used to describe an OpenLCB virtual node"),
    .switchboardNode:       String(localized: "Switchboard Node", comment: "Used to describe an OpenLCB virtual node"),
    .switchboardItemNode:   String(localized: "Switchboard Item Node", comment: "Used to describe an OpenLCB virtual node"),
  ]
  
  public static let baseId : [MyTrainsVirtualNodeType:UInt64] = [
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
    .digitraxBXP88Node     : 0x09000d680001,
    .genericVirtualNode    : 0x09000d6f0001,
    .layoutNode            : 0xfe0000000001,
    .switchboardNode       : 0xfd0000000001,
    .switchboardItemNode   : 0xfc0000000001,
  ]

  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    
    comboBox.deselectItem(at: comboBox.indexOfSelectedItem)
    comboBox.removeAllItems()
    
    var items : [String] = []
    
    for (nodeType, nodeTitle) in titles {
      
      if nodeType.isPublic {
        items.append(nodeTitle)
      }
      
    }
    
    items.sort {$0 < $1}
    
    comboBox.addItems(withObjectValues: items)
    
  }
  
  public static func select(comboBox:NSComboBox, virtualNodeType:MyTrainsVirtualNodeType) {
    comboBox.stringValue = virtualNodeType.title
  }
  
  public static func selected(comboBox:NSComboBox) -> MyTrainsVirtualNodeType? {
    return virtualNodeType(title: comboBox.stringValue)
  }
  
  public static func virtualNodeType(title:String) -> MyTrainsVirtualNodeType? {
    for (nodeType, nodeTitle) in titles {
      if title == nodeTitle {
        return nodeType
      }
    }
    return nil
  }
  
  public static func virtualNodeType(nodeId:UInt64) -> MyTrainsVirtualNodeType? {
    let mask : UInt64 = 0xffffffffff00
    for (nodeType, id) in baseId {
      if (id & mask) == (nodeId & mask) {
        return nodeType
      }
    }
    return nil
  }
  
}
