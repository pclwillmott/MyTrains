//
//  MyTrainsViewType.swift
//  MyTrains
//
//  Created by Paul Willmott on 10/03/2024.
//

import Foundation

public enum MyTrainsViewType : Int {
  
  case openLCBNetworkView    = 0
  case openLCBTrafficMonitor = 1
  case throttle              = 2
  case switchboardPanel      = 3
  case clock                 = 4
  case locoNetTrafficMonitor = 5
  case locoNetSlotView       = 6
  case locoNetDashboard      = 7
  case layoutBuilder         = 8 // Remember to change numberOfTypes property value.

  // MARK: Public Properties
  
  public var title : String {
    return MyTrainsViewType.titles[self]!
  }
  
  // MARK: Public Class Properties
  
  public static var numberOfTypes : Int {
    return 9
  }
  
  // MARK: Private Class Methods
  
  private static let titles : [MyTrainsViewType:String] = [
    .openLCBNetworkView    : String(localized: "LCC/OpenLCB Network View"),
    .openLCBTrafficMonitor : String(localized: "LCC/OpenLCB Traffic Monitor"),
    .throttle              : String(localized: "Throttle"),
    .switchboardPanel      : String(localized: "Switchboard Panel"),
    .clock                 : String(localized: "Fast Clock"),
    .locoNetTrafficMonitor : String(localized: "LocoNet Traffic Monitor"),
    .locoNetSlotView       : String(localized: "LocoNet Slot View"),
    .locoNetDashboard      : String(localized: "LocoNet Dashboard"),
    .layoutBuilder         : String(localized: "Layout Builder"),
  ]

  private static var map : String {
    
    let items : [MyTrainsViewType] = [
      .openLCBNetworkView,
      .openLCBTrafficMonitor,
      .throttle,
      .switchboardPanel,
      .clock,
      .locoNetTrafficMonitor,
      .locoNetSlotView,
      .locoNetDashboard,
      .layoutBuilder,
    ]
    
    var map = "<segment space='1' origin='0'>\n"
      
    map += "  <name>" + String(localized: "Window startup options") + "</name>\n"
      
    map += "  <description>" + String(localized: "The following options determine which windows are automatically displayed at start-up and when the application restarts after configuration changes.") + "</description>\n"
    
    for item in items {
      map += "<int size='1'>\n"
      map += "<name>" + item.title + "</name>\n"
      map += "%%VIEW_OPTIONS%%"
      map += "</int>\n"
      map += "<group offset='\(1)'/>\n"
    }

    map += "</segment>\n"

    return MyTrainsViewOption.insertMap(cdi: map)
    
  }
  
  // MARK: Public Class Properties
  
  public static let defaultValue : MyTrainsViewOption = .doNotOpen
  
  // MARK: Public Class Methods
  
  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: CDI.VIEW_TYPES, with: map)
  }

}
