//
//  SwitchBoardItemPartType.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/06/2022.
//

import Foundation
import AppKit

public enum SwitchBoardItemPartType : Int {
  
  case straight = 0
  case curve = 1
  case longCurve = 2
  case turnoutRight = 3
  case turnoutLeft = 4
  case cross = 5
  case diagonalCross = 6
  case yTurnout = 7
  case turnout3Way = 8
  case leftCurvedTurnout = 9
  case rightCurvedTurnout = 10
  case buffer = 11
  case block = 12
  case feedback = 13
  case link = 14
  case platform = 15
  case none = -1

  public var partName : String {
    get {
      return self == .none ? "None" : SwitchBoardItemPartType.titles[self.rawValue]
    }
  }
  
  private static let titles = [
    "Straight",
    "Curve",
    "Long Curve",
    "Turnout Right",
    "Turnout Left",
    "Cross",
    "Diagonal Cross",
    "Y Turnout",
    "3-Way Turnout",
    "Left Curved Turnout",
    "Right Curved Turnout",
    "Buffer",
    "Block",
    "Feedback",
    "Link",
    "Platform",
  ]
  
  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    for item in titles {
      comboBox.addItem(withObjectValue: item)
    }
  }
  
  public static func select(comboBox: NSComboBox, partType:SwitchBoardItemPartType) {
    comboBox.selectItem(at: partType.rawValue)
  }
  
}

