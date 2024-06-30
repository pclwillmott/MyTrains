//
//  Colour.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/06/2024.
//

import Foundation
import AppKit

public enum Colour : UInt8, CaseIterable {
  
  // MARK: Enumeration
  
  case black = 1
  case blue = 2
  case brown = 3
  case cyan = 4
  case darkGrey = 5
  case grey = 6
  case green = 7
  case indigo = 8
  case lightGrey = 9
  case magenta = 10
  case mint = 11
  case orange = 12
  case pink = 13
  case purple = 14
  case red = 15
  case teal = 16
  case white = 0
  case yellow = 17
  
  // MARK: Constructors
  
  init?(title:String) {
    for temp in Colour.allCases {
      if temp.title == title {
        self = temp
        return
      }
    }
    return nil
  }

  // MARK: Public Properties
  
  public var title : String {
    return Colour.titles[self]!
  }
  
  public var color : NSColor {
    
    switch self {
    case .black:
      return .black
    case .blue:
      return .systemBlue
    case .brown:
      return .brown
    case .cyan:
      return .systemCyan
    case .darkGrey:
      return .darkGray
    case .grey:
      return .systemGray
    case .green:
      return .systemGreen
    case .indigo:
      return .systemIndigo
    case .lightGrey:
      return .lightGray
    case .magenta:
      return .magenta
    case .mint:
      return .systemMint
    case .orange:
      return .systemOrange
    case .pink:
      return .systemPink
    case .purple:
      return .systemPurple
    case .red:
      return .systemRed
    case .teal:
      return .systemTeal
    case .white:
      return .white
    case .yellow:
      return .systemYellow
    }
    
  }
  
  // MARK: Private Class Properties
  
  private static let titles : [Colour:String] = [
    .black : String(localized: "Black", comment: "The name of a color."),
    .blue  : String(localized: "Blue", comment: "The name of a color."),
    .brown  : String(localized: "Brown", comment: "The name of a color."),
    .cyan  : String(localized: "Cyan", comment: "The name of a color."),
    .darkGrey  : String(localized: "Dark Gray", comment: "The name of a color."),
    .grey  : String(localized: "Gray", comment: "The name of a color."),
    .green  : String(localized: "Green", comment: "The name of a color."),
    .indigo  : String(localized: "Indigo", comment: "The name of a color."),
    .lightGrey  : String(localized: "Light Gray", comment: "The name of a color."),
    .magenta  : String(localized: "Magenta", comment: "The name of a color."),
    .mint  : String(localized: "Mint", comment: "The name of a color."),
    .orange  : String(localized: "Orange", comment: "The name of a color."),
    .pink  : String(localized: "Pink", comment: "The name of a color."),
    .purple  : String(localized: "Purple", comment: "The name of a color."),
    .red  : String(localized: "Red", comment: "The name of a color."),
    .teal  : String(localized: "Teal", comment: "The name of a color."),
    .white  : String(localized: "White", comment: "The name of a color."),
    .yellow  : String(localized: "Yellow", comment: "The name of a color."),
  ]
  
  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    for item in Colour.allCases {
      comboBox.addItem(withObjectValue: item.title)
    }
  }
  
  public static func select(comboBox:NSComboBox, item:Colour) {
    comboBox.selectItem(withObjectValue: item.title)
  }
  
  public static func selected(comboBox:NSComboBox) -> Colour? {
    guard comboBox.indexOfSelectedItem != -1 else {
      return nil
    }
    return Colour(rawValue: UInt8(exactly: comboBox.indexOfSelectedItem)!)
  }

}
