//
//  TurnoutMotorType.swift
//  MyTrains
//
//  Created by Paul Willmott on 20/06/2022.
//

import Foundation
import AppKit

public enum TurnoutMotorType : UInt8 {
  
  case manual     = 0
  case slowMotion = 1
  case solenoid   = 2

  // MARK: Public Properties
  
  public var title : String {
    return TurnoutMotorType.titles[Int(self.rawValue)]
  }
  
  // MARK: Private Class Properties
  
  private static let titles = [
    String(localized: "Manual", comment: "Used to indicate turnout motor type"),
    String(localized: "Slow Motion", comment: "Used to indicate turnout motor type"),
    String(localized: "Solenoid", comment: "Used to indicate turnout motor type"),
  ]

  private static var map : String {
    
    let items : [TurnoutMotorType] = [
      .manual,
      .slowMotion,
      .solenoid,
    ]
    
    var map = "<default>\(defaultValue.rawValue)</default>\n<map>\n"

    for item in items {
      map += "<relation><property>\(item.rawValue)</property><value>\(item.title)</value></relation>\n"
    }

    map += "</map>\n"

    return map

  }
  
  // MARK: Public Class Properties
  
  public static let defaultValue : TurnoutMotorType = .manual
  
  public static let mapPlaceholder = CDI.TURNOUT_MOTOR_TYPE

  // MARK: Public Class Methods
  
  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func populate(comboBox: NSComboBox, fromSet:Set<TurnoutMotorType>) {
    comboBox.removeAllItems()
    for item in fromSet {
      comboBox.addItem(withObjectValue: item.title)
    }
    comboBox.selectItem(at: 0)
  }

  public static func select(comboBox: NSComboBox, value: TurnoutMotorType) {
    var index = 0
    while index < comboBox.numberOfItems {
      if (comboBox.itemObjectValue(at: index) as! String) == value.title {
        comboBox.selectItem(at: index)
        return
      }
      index += 1
    }
  }
  
  public static func selected(comboBox: NSComboBox) -> TurnoutMotorType? {
    var index = 0
    while index < titles.count {
      if comboBox.stringValue == titles[index] {
        return TurnoutMotorType(rawValue: UInt8(index))
      }
      index += 1
    }
    return nil
  }

  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: mapPlaceholder, with: map)
  }

}
