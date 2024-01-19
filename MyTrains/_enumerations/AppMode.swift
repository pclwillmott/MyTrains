//
//  WorkstationType.swift
//  MyTrains
//
//  Created by Paul Willmott on 17/01/2024.
//

import Foundation
import AppKit

public enum AppMode : Int {
  
  case master   = 0
  case delegate = 1

  // MARK: Public Properties
  
  public var title : String {
    return AppMode.titles[Int(self.rawValue)]
  }
  
  // MARK: Private Class Properties
  
  private static let titles = [
    String(localized: "Master", comment: "Used to indicate that the workstation is the master system controller"),
    String(localized: "Delegate", comment: "Used to indicate that the workstation is not the master system controller but can be delegated some of its functions"),
  ]
  
  // MARK: Public Class Prooperties
  
  public static let defaultValue : AppMode = .master
  
  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: .defaultValue)
  }
  
  public static func select(comboBox:NSComboBox, value:AppMode) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selected(comboBox: NSComboBox) -> AppMode {
    return AppMode(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }
  
}
