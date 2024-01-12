//
//  BlockDirection.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/06/2022.
//

import Foundation
import AppKit

public enum BlockDirection : Int {

  case bidirectional  = 0
  case unidirectional = 1

  // MARK: Public Properties
  
  public var title : String {
    return BlockDirection.titles[self.rawValue]
  }
  
  // MARK: Private Class Properties
  
  private static let titles = [
    String(localized: "Bidirectional", comment: "Used by combobox to indicate that trains can travel in both directions in the track block"),
    String(localized: "Unidirectional", comment: "Used by combobox to indicate that trains can travel in one direction only in the track block"),
  ]
  
  private static var map : String {
    
    var items : [BlockDirection] = [
      .bidirectional,
      .unidirectional,
    ]
    
    var map = ""
    
    for item in items {
      map += "<relation><property>\(item.rawValue)</property><value>\(item.title)</value></relation>\n"
    }

    return map
    
  }

  // MARK: Public Class Properties
  
  public static let defaultValue : BlockDirection = .bidirectional

  public static let mapPlaceholder = "%%BLOCK_DIRECTION%%"

  // MARK: Public Class Methods
  
  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox: NSComboBox, value: BlockDirection) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selected(comboBox: NSComboBox) -> BlockDirection {
    return BlockDirection(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }

  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: mapPlaceholder, with: map)
  }

}
