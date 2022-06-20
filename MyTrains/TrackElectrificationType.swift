//
//  TrackElectrificationType.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/06/2022.
//

import Foundation
import AppKit

public enum TrackElectrificationType : Int {
  
  case notElectrified = 0
  case thirdRail = 1
  case overhead = 2

  public var title : String {
    get {
      return TrackElectrificationType.titles[self.rawValue]
    }
  }
  
  private static let titles = [
    "Not Electrified",
    "Third Rail",
    "Overhead"
  ]
  
  public static let defaultValue : TrackElectrificationType = .notElectrified
  
  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox:NSComboBox, value: TrackElectrificationType) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selected(comboBox: NSComboBox) -> TrackElectrificationType {
    return TrackElectrificationType(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }
  
}
