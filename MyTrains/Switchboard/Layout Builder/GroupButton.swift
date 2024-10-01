//
//  GroupButton.swift
//  MyTrains
//
//  Created by Paul Willmott on 27/05/2024.
//

import Foundation
import AppKit
import SGAppKit

public enum GroupButton : Int, CaseIterable {
  
  // MARK: Enumeration
  
  case addItemToGroup = 0
  case removeItemFromGroup = 1
  case switchToArrangeMode = 2
  
  // MARK: Public Properties
 
  public var tooltip : String {
    return GroupButton.tooltips[self]!
  }

  public var icon : SGIcon {
    return GroupButton.icons[self]!
  }

  // MARK: Private Class Properties
  
  private static let tooltips : [GroupButton:String] = [
    .addItemToGroup      : String(localized: "Add Item to Group", comment: ""),
    .removeItemFromGroup : String(localized: "Remove Item from Group", comment: ""),
    .switchToArrangeMode : String(localized: "Switch to Arrange Mode", comment: ""),
  ]

  private static let icons : [GroupButton:SGIcon] = [
    .addItemToGroup      : .addToGroup,
    .removeItemFromGroup : .removeFromGroup,
    .switchToArrangeMode : .cursor,
  ]

}


