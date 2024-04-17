//
//  SwitchboardItemPalette.swift
//  MyTrains
//
//  Created by Paul Willmott on 17/04/2024.
//

import Foundation
import AppKit

public enum SwitchboardItemPalette : Int {
  
  // MARK: Enumeration
  
  case tracks     = 1000000 /// Regular track straights and curves
  case blocks     = 2000000 /// Blocks
  case turnouts   = 3000000 /// Turnouts and crossovers
  case sensors    = 4000000 /// Sensors
  case scenics    = 5000000 /// Scenic items like platforms
  case signals    = 6000000 /// Signals - generic
  case signals_GB = 6000826 /// Signals - Great Britain
  
  // MARK: Public Properties
  
  public var country : CountryCode? {
    return CountryCode(rawValue: UInt16(self.rawValue % SwitchboardItemPalette.tracks.rawValue))
  }
  
  public var title : String {
    return SwitchboardItemPalette.titles[self]!
  }
  
  public var isEmpty : Bool {
    guard let members = SwitchboardItemPalette.members[self] else {
      return true
    }
    return members.isEmpty
  }
  
  // MARK: Private Class Properties
  
  private static let titles : [SwitchboardItemPalette:String] = [
    .tracks     : String(localized:"Tracks", comment: "Used for the title of a switchboard item palette in LayoutBuilder"),
    .blocks     : String(localized:"Blocks", comment: "Used for the title of a switchboard item palette in LayoutBuilder"),
    .turnouts   : String(localized:"Turnouts & Crossovers", comment: "Used for the title of a switchboard item palette in LayoutBuilder"),
    .sensors    : String(localized:"Sensors", comment: "Used for the title of a switchboard item palette in LayoutBuilder"),
    .scenics    : String(localized:"Scenic Items", comment: "Used for the title of a switchboard item palette in LayoutBuilder"),
    .signals    : String(localized:"Signals", comment: "Used for the title of a switchboard item palette in LayoutBuilder"),
    .signals_GB : String(localized:"Signals - Great Britain", comment: "Used for the title of a switchboard item palette in LayoutBuilder"),
  ]
  
  private static let members : [SwitchboardItemPalette:[SwitchBoardItemType]] = [
    .tracks : [ .straight, .curve, .longCurve, .link],
    .blocks : [.block],
    .turnouts : [.turnoutRight, .turnoutLeft, .rightCurvedTurnout,  .leftCurvedTurnout,  .yTurnout,  .turnout3Way, .singleSlip, .doubleSlip, .cross, .diagonalCross],
    .sensors : [.sensor],
    .scenics : [.buffer, .platform],
    .signals : [.signal],
    .signals_GB : [],
  ]
  
  // MARK: Public Class Properties
  
  public static let defaultValue : SwitchboardItemPalette = .tracks
  
  // MARK: Public Class Methods
  
  public static func availablePalettes(country:CountryCode) -> Set<SwitchboardItemPalette> {
    var result : Set<SwitchboardItemPalette> = []
    for (palette, _) in titles {
      if !palette.isEmpty && (palette.country == nil || palette.country == country) {
        result.insert(palette)
      }
    }
    return result
  }
  
  public static func populate(comboBox: NSComboBox, country:CountryCode) {
    comboBox.removeAllItems()
    comboBox.isEditable = false
    var sorted : [String] = []
    for (palette, title) in titles {
      if !palette.isEmpty && (palette.country == nil || palette.country == country) {
        sorted.append(title)
      }
    }
    sorted.sort {$0 < $1}
    comboBox.addItems(withObjectValues: sorted)
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox: NSComboBox, value: SwitchboardItemPalette) {
    comboBox.deselectItem(at: comboBox.indexOfSelectedItem)
    var index = 0
    while index < comboBox.numberOfItems {
      if comboBox.itemObjectValue(at: index) as! String == value.title {
        comboBox.selectItem(at: index)
      }
      index += 1
    }
  }
  
  public static func selected(comboBox:NSComboBox) -> SwitchboardItemPalette {
    guard comboBox.indexOfSelectedItem != -1 else {
      return defaultValue
    }
    let test = comboBox.objectValueOfSelectedItem as! String
    for (palette, title) in titles {
      if title == test {
        return palette
      }
    }
    return defaultValue
  }

  public static func populate(paletteView:NSView, palette:SwitchboardItemPalette, target:AnyObject?, action: Selector?) -> [NSLayoutConstraint] {
    
    guard let members = members[palette] else {
      return []
    }
    
    var constraints : [NSLayoutConstraint] = []
    
    let view = NSView()
    view.translatesAutoresizingMaskIntoConstraints = false
//    view.wantsLayer = true
//    view.layer?.backgroundColor = NSColor.cyan.cgColor
     paletteView.addSubview(view)
    
    constraints.append(view.centerXAnchor.constraint(equalTo: paletteView.centerXAnchor))
    constraints.append(view.topAnchor.constraint(equalTo: paletteView.topAnchor))
    
    let numberOfColumns = 6
    
    var yAnchor = view.topAnchor
    var xAnchor = view.leadingAnchor
    var column = 0
    
    for member in members {
      let button = SwitchboardShapeButton()
      button.partType = member
      button.tag = Int(member.rawValue)
      button.target = target
      button.action = action
      button.isBordered = true
      button.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview(button)
      constraints.append(button.topAnchor.constraint(equalToSystemSpacingBelow: yAnchor, multiplier: 1.0))
      constraints.append(button.leadingAnchor.constraint(equalToSystemSpacingAfter: xAnchor, multiplier: 1.0))
      constraints.append(button.widthAnchor.constraint(equalToConstant: 20.0))
      constraints.append(button.heightAnchor.constraint(equalToConstant: 20.0))
      xAnchor = button.trailingAnchor
      column += 1
      if column == numberOfColumns {
        xAnchor = view.leadingAnchor
        yAnchor = button.bottomAnchor
        column = 0
      }
      constraints.append(view.trailingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: button.trailingAnchor, multiplier: 1.0))
      constraints.append(view.bottomAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: button.bottomAnchor, multiplier: 1.0))
    }
    constraints.append(paletteView.bottomAnchor.constraint(equalToSystemSpacingBelow: view.bottomAnchor, multiplier: 1.0))
    constraints.append(paletteView.trailingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: view.trailingAnchor, multiplier: 1.0))
    paletteView.isHidden = true
    return constraints
    
  }
  
}
