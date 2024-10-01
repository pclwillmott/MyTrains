//
//  ArrangeButton.swift
//  MyTrains
//
//  Created by Paul Willmott on 27/05/2024.
//

import Foundation
import AppKit
import SGAppKit

public enum ArrangeButton : Int, CaseIterable {
  
  // MARK: Enumeration
  
  case addItemToPanel = 0
  case removeItemFromPanel = 1
  case rotateCounterClockwise = 2
  case rotateClockwise = 3
  case switchToGroupingMode = 4
  
  // MARK: Public Properties
  
  public var tooltip : String {
    return ArrangeButton.tooltips[self]!
  }

  public var icon : SGIcon {
    return ArrangeButton.icons[self]!
  }

  // MARK: Private Class Properties
  
  private static let tooltips : [ArrangeButton:String] = [
    .addItemToPanel         : String(localized: "Add Item to Panel", comment: ""),
    .removeItemFromPanel    : String(localized: "Remove Item from Panel", comment: ""),
    .rotateCounterClockwise : String(localized: "Rotate Counterclockwise", comment: ""),
    .rotateClockwise        : String(localized: "Rotate Clockwise", comment: ""),
    .switchToGroupingMode   : String(localized: "Switch to Grouping Mode", comment: ""),
  ]

  private static let icons : [ArrangeButton:SGIcon] = [
    .addItemToPanel         : .addItem,
    .removeItemFromPanel    : .removeItem,
    .rotateCounterClockwise : .rotateCounterClockwise,
    .rotateClockwise        : .rotateClockwise,
    .switchToGroupingMode   : .groupMode,
  ]

}


