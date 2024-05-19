//
//  BlockDirection.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/06/2022.
//

import Foundation
import AppKit

public enum BlockDirection : UInt8, CaseIterable {

  case bidirectional  = 0
  case unidirectional = 1

  init?(title:String) {
    for temp in BlockDirection.allCases {
      if temp.title == title {
        self = temp
        return
      }
    }
    return nil
  }

  // MARK: Public Properties
  
  public var title : String {
    return BlockDirection.titles[Int(self.rawValue)]
  }
  
  // MARK: Private Class Properties
  
  private static let titles = [
    String(localized: "Bidirectional", comment: "Used by combobox to indicate that trains can travel in both directions in the track block"),
    String(localized: "Unidirectional", comment: "Used by combobox to indicate that trains can travel in one direction only in the track block"),
  ]
  
  private static var map : String {
    
    let items : [BlockDirection] = [
      .bidirectional,
      .unidirectional,
    ]
    
    var map = "<default>\(defaultValue.rawValue)</default>\n<map>\n"

    for item in items {
      map += "<relation><property>\(item.rawValue)</property><value>\(item.title)</value></relation>\n"
    }

    map += "</map>\n"

    return map

  }

  // MARK: Public Class Properties
  
  public static let defaultValue : BlockDirection = .bidirectional

  // MARK: Public Class Methods
  
  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox: NSComboBox, value: BlockDirection) {
    comboBox.selectItem(at: Int(value.rawValue))
  }
  
  public static func selected(comboBox: NSComboBox) -> BlockDirection {
    return BlockDirection(rawValue: UInt8(comboBox.indexOfSelectedItem)) ?? defaultValue
  }

  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: CDI.DIRECTIONALITY, with: map)
  }

}
