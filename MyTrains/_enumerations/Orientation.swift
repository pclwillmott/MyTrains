//
//  Orientation.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/06/2022.
//

import Foundation
import AppKit

public enum Orientation : UInt8 {
  
  case deg0   = 0
  case deg45  = 1
  case deg90  = 2
  case deg135 = 3
  case deg180 = 4
  case deg225 = 5
  case deg270 = 6
  case deg315 = 7

  // MARK: Public Properties
  
  public var title : String {
    return Orientation.titles[Int(self.rawValue)]
  }
  
  // MARK: Private Class Properties
  
  private static let titles = [
    String(localized: "0°", comment: "Used to indicate a rotation angle in degrees"),
    String(localized: "45°", comment: "Used to indicate a rotation angle in degrees"),
    String(localized: "90°", comment: "Used to indicate a rotation angle in degrees"),
    String(localized: "135°", comment: "Used to indicate a rotation angle in degrees"),
    String(localized: "180°", comment: "Used to indicate a rotation angle in degrees"),
    String(localized: "225°", comment: "Used to indicate a rotation angle in degrees"),
    String(localized: "270°", comment: "Used to indicate a rotation angle in degrees"),
    String(localized: "315°", comment: "Used to indicate a rotation angle in degrees"),
  ]
  
  private static var map : String {
    
    let items : [Orientation] = [
      .deg0,
      .deg45,
      .deg90,
      .deg135,
      .deg180,
      .deg225,
      .deg270,
      .deg315,
    ]
    
    var map = "<default>\(defaultValue.rawValue)</default>\n<map>\n"

    for item in items {
      map += "<relation><property>\(item.rawValue)</property><value>\(item.title)</value></relation>\n"
    }

    map += "</map>\n"

    return map
    
  }
  
  // MARK: Public Class Prooperties
  
  public static let defaultValue : Orientation = .deg0
  
  public static let mapPlaceholder = CDI.ORIENTATION

  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: .defaultValue)
  }
  
  public static func select(comboBox:NSComboBox, value:Orientation) {
    comboBox.selectItem(at: Int(value.rawValue))
  }
  
  public static func selected(comboBox: NSComboBox) -> Orientation {
    return Orientation(rawValue: UInt8(comboBox.indexOfSelectedItem)) ?? defaultValue
  }
  
  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: mapPlaceholder, with: map)
  }

}
