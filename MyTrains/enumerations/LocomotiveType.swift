//
//  LocomotiveType.swift
//  MyTrains
//
//  Created by Paul Willmott on 11/06/2022.
//

import Foundation
import AppKit

public enum LocomotiveType : Int {
  
  case unknown = 0
  case diesel = 1
  case electricThirdRail = 2
  case electricOverhead = 3
  case electroDiesel = 4
  case steam = 5
  
  public var displayName : String {
    get {
      return LocomotiveType.names[self.rawValue]
    }
  }
  
  private static var names = [
    "Unknown",
    "Diesel",
    "Electric (Overhead)",
    "Electric (Third Rail)",
    "Electro-diesel",
    "Steam",
  ]
  
  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    for raw in 0...names.count-1 {
      comboBox.insertItem(withObjectValue: LocomotiveType(rawValue: raw)!.displayName, at: raw)
    }
  }
  
  public static func getType(forName: String) -> LocomotiveType {
    for raw in 0...names.count-1 {
      if names[raw] == forName {
        return LocomotiveType(rawValue: raw)!
      }
    }
    return .unknown
  }
  
}
