//
//  WorkstationType.swift
//  MyTrains
//
//  Created by Paul Willmott on 17/01/2024.
//

import Foundation
import AppKit

public enum AppMode : Int {
  
  case initializing = 0
  case master       = 1
  case delegate     = 2

  // MARK: Public Properties
  
  public var title : String {
    return AppMode.titles[Int(self.rawValue)]
  }
  
  // MARK: Private Class Properties
  
  private static let titles = [
    String(localized: "Initializing", comment: "Used to indicate that the workstation is initializing"),
    String(localized: "Master", comment: "Used to indicate that the workstation is the master mode"),
    String(localized: "Delegate", comment: "Used to indicate that the workstation is delegate mode"),
  ]
  
  // MARK: Public Class Prooperties
  
  public static let defaultValue : AppMode = .initializing
  
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
