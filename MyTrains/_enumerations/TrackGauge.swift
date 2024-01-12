//
//  TrackGauge.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/06/2022.
//

import Foundation
import AppKit

public enum TrackGauge : Int {
  
  case em         = 0
  case n          = 1
  case o          = 2
  case o14        = 3
  case ooho       = 4
  case ooo        = 5
  case p4         = 6
  case s          = 7
  case scaleSeven = 8
  case tt         = 9
  case tt3        = 10

  // MARK: Public Properties
  
  public var title : String {
    return TrackGauge.titles[self.rawValue]
  }
  
  // MARK: Private Class Properties
  
  private static let titles = [
    String(localized: "EM", comment: "Used to indicate the track gauge"),
    String(localized: "N", comment: "Used to indicate the track gauge"),
    String(localized: "O", comment: "Used to indicate the track gauge"),
    String(localized: "OO/HO", comment: "Used to indicate the track gauge"),
    String(localized: "OOO", comment: "Used to indicate the track gauge"),
    String(localized: "P4", comment: "Used to indicate the track gauge"),
    String(localized: "S", comment: "Used to indicate the track gauge"),
    String(localized: "Scale 7", comment: "Used to indicate the track gauge"),
    String(localized: "TT", comment: "Used to indicate the track gauge"),
    String(localized: "TT3", comment: "Used to indicate the track gauge"),
  ]
  
  private static var map : String {
    
    var items : [TrackGauge] = [
      .em,
      .n,
      .o,
      .ooho,
      .ooo,
      .p4,
      .s,
      .scaleSeven,
      .tt,
      .tt3,
    ]
    
    var map = ""
    
    for item in items {
      map += "<relation><property>\(item.rawValue)</property><value>\(item.title)</value></relation>\n"
    }

    return map
    
  }
  
  // MARK: Public Class Properties
  
  public static let defaultValue : TrackGauge = .ooho

  public static let mapPlaceholder = "%%TRACK_GAUGE%%"

  // MARK: Public Class Methods
  
  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox: NSComboBox, value: TrackGauge) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selected(comboBox: NSComboBox) -> TrackGauge {
    return TrackGauge(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }
  
  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: mapPlaceholder, with: map)
  }

}

