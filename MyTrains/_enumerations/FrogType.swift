//
//  FrogType.swift
//  MyTrains
//
//  Created by Paul Willmott on 25/06/2022.
//

import Foundation
import AppKit

public enum FrogType : Int {
  
  case electroFrog = 0
  case insulFrog   = 1
  case uniFrog     = 2
 
  // MARK: Public Properties
  
  public var title : String {
    get {
      return FrogType.titles[self.rawValue]
    }
  }
  
  // MARK: Private Class Properties
  
  private static let titles : [String] = [
    String(localized: "ElectroFrog", comment: "Used to indicate that a turnout has a powered frog"),
    String(localized: "InsulFrog", comment: "Used to indicate that turnout has an insulated frog"),
    String(localized: "UniFrog", comment: "Used to indicate that turnout can be configured to have a powered or insulated frog"),
  ]
  
  private static var map : String {
    
    var items : [FrogType] = [
      .electroFrog,
      .insulFrog,
      .uniFrog,
    ]
    
    var map = ""
    
    for item in items {
      map += "<relation><property>\(item.rawValue)</property><value>\(item.title)</value></relation>\n"
    }

    return map
    
  }

  // MARK: Public Class Properties
  
  public static let defaultValue : FrogType = .insulFrog
  
  public static let mapPlaceholder = "%%FROG_TYPE%%"

  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox:NSComboBox, value:FrogType) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selected(comboBox:NSComboBox) -> FrogType {
    return FrogType(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }
  
  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: mapPlaceholder, with: map)
  }

}
