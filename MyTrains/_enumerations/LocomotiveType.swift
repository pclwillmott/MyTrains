//
//  LocomotiveType.swift
//  MyTrains
//
//  Created by Paul Willmott on 11/06/2022.
//

import Foundation
import AppKit

public enum LocomotiveType : Int {
  
  case unknown           = 0
  case diesel            = 1
  case electricThirdRail = 2
  case electricOverhead  = 3
  case electroDiesel     = 4
  case steam             = 5

  // MARK: Public Properties
  
  public var title : String {
    return LocomotiveType.titles[self.rawValue]
  }
  
  // MARK: Private Class Properties
  
  private static var titles = [
    String(localized: "Unknown", comment: "Used to indicate that the type of something is unknown"),
    String(localized: "Diesel", comment: "Used to indicate that a locomotive is diesel powered"),
    String(localized: "Electric (Overhead)", comment: "Used to indicate that a locomotive is electric powered by overhead cables"),
    String(localized: "Electric (Third Rail)", comment: "Used to indicate that a locomotive is electric powered by a third rail"),
    String(localized: "Electro-diesel", comment: "Used to indicate that a locomotive is can be powered by diesel or electric power"),
    String(localized: "Steam", comment: "Used to indicate that a locomotive is steam powered"),
  ]
  
  private static var map : String {
    
    let items : [LocomotiveType] = [
      .unknown,
      .diesel,
      .electricOverhead,
      .electricThirdRail,
      .electroDiesel,
      .steam,
    ]
    
    var map = ""
    
    for item in items {
      map += "<relation><property>\(item.rawValue)</property><value>\(item.title)</value></relation>\n"
    }

    return map
    
  }

  // MARK: Public Class Properties
  
  public static let defaultValue : LocomotiveType = .unknown
  
  public static let mapPlaceholder = "%%LOCOMOTIVE_TYPE%%"

  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: .defaultValue)
  }
  
  public static func select(comboBox:NSComboBox, value:LocomotiveType) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selected(comboBox: NSComboBox) -> LocomotiveType {
    return LocomotiveType(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }
  
  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: mapPlaceholder, with: map)
  }

}
