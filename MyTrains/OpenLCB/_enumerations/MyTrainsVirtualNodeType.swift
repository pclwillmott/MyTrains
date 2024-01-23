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
  case switchboardPanelNode  = 13
  case switchboardItemNode   = 14
  case applicationNode       = 15

  // MARK: Public Properties
  
  public var title : String {
    return MyTrainsVirtualNodeType.titles[self]!
  }
  
  public var manufacturerName : String {
    return "MyTrains"
  }
  
  public var startupOrder : Int {
    return MyTrainsVirtualNodeType._startupOrder[self] ?? 0x7FFFFFFFFFFFFFFF
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
    .switchboardPanelNode:  String(localized: "Switchboard Panel", comment: "Used to create a default OpenLCB virtual name"),
    .switchboardItemNode:   String(localized: "Switchboard Item", comment: "Used to create a default OpenLCB virtual name"),
  ]

  private static let _startupOrder : [MyTrainsVirtualNodeType:Int] = [
    .canGatewayNode        : 0,
    .applicationNode       : 1,
    .layoutNode            : 2,
    .locoNetMonitorNode    : 3,
    .locoNetGatewayNode    : 4,
    .clockNode             : 5,
    .configurationToolNode : 6,
    .trainNode             : 7,
    .throttleNode          : 8,
    .programmerToolNode    : 9,
    .programmingTrackNode  : 10,
    .switchboardPanelNode  : 11,
    .switchboardItemNode   : 12,
    .digitraxBXP88Node     : 13,
    .genericVirtualNode    : 14,
  ]

  // MARK: Public Class Properties
 
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
    .switchboardPanelNode:  String(localized: "Switchboard Panel Node", comment: "Used to describe an OpenLCB virtual node"),
    .switchboardItemNode:   String(localized: "Switchboard Item Node", comment: "Used to describe an OpenLCB virtual node"),
  ]
  
  // MARK: Public Class Properties
  
  public static let defaultValue : MyTrainsVirtualNodeType = .genericVirtualNode
  
  public static let mapPlaceholder = CDI.VIRTUAL_NODE_TYPE

  // MARK: Private Class Methods
  
  private static var map : String {
    
    var items : [MyTrainsVirtualNodeType] = [
      .canGatewayNode        ,
      .applicationNode       ,
      .locoNetMonitorNode    ,
      .locoNetGatewayNode    ,
      .clockNode             ,
      .configurationToolNode ,
      .trainNode             ,
      .throttleNode          ,
      .programmerToolNode    ,
      .programmingTrackNode  ,
      .layoutNode            ,
      .switchboardPanelNode  ,
      .switchboardItemNode   ,
      .digitraxBXP88Node     ,
      .genericVirtualNode    ,
    ]
    
    var map = "<default>\(defaultValue.rawValue)</default>\n<map>\n"

    for item in items {
      map += "<relation><property>\(item.rawValue)</property><value>\(item.title)</value></relation>\n"
    }

    map += "</map>\n"

    return map
    
  }

  // MARK: Public Class Methods
  
  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: mapPlaceholder, with: map)
  }

  // MARK: Public Class Methods
  
  public static func newSubMenuItems(appMode:AppMode) -> [NSMenuItem] {
    
    var nodeTypes : [MyTrainsVirtualNodeType]
    
    switch appMode {
    case .master:
      nodeTypes = [
        .layoutNode,
        .switchboardPanelNode,
        .throttleNode,
        .trainNode,
        .canGatewayNode,
        .clockNode,
        .locoNetGatewayNode,
        .programmingTrackNode,
        .digitraxBXP88Node,
      ]
    case .delegate:
      nodeTypes = [
        .throttleNode,
        .trainNode,
        .canGatewayNode,
        .clockNode,
        .locoNetGatewayNode,
        .programmingTrackNode,
      ]
    case .initializing:
      nodeTypes = []
    }
    
    var result : [NSMenuItem] = []
    
    for nodeType in nodeTypes {
      let menuItem = NSMenuItem()
      menuItem.title = nodeType.title
      menuItem.tag = Int(nodeType.rawValue)
      result.append(menuItem)
    }
    
    return result

  }
  
}
