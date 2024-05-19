//
//  TrackElectrificationType.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/06/2022.
//

import Foundation
import AppKit

public enum TrackElectrificationType : UInt8, CaseIterable {
  
  case notElectrified = 0
  case thirdRail      = 1
  case overhead       = 2

  init?(title:String) {
    for temp in TrackElectrificationType.allCases {
      if temp.title == title {
        self = temp
        return
      }
    }
    return nil
  }

  // MARK: Public Properties
  
  public var title : String {
    return TrackElectrificationType.titles[Int(self.rawValue)]
  }
  
  // MARK: Private Class Properties
  
  private static let titles = [
    String(localized: "Not Electrified", comment: "Used to indicate that the track is not electrified, i.e. only steam and diesels can use it"),
    String(localized: "Third Rail", comment: "Used to indicate that the track models 3rd rail electrification"),
    String(localized: "Overhead", comment: "Used to indicate that the track models overhead electrification"),
  ]
  
  private static var map : String {
    
    let items : [TrackElectrificationType] = [
      .notElectrified,
      .thirdRail,
      .overhead,
    ]
    
    var map = "<default>\(defaultValue.rawValue)</default>\n<map>\n"

    for item in items {
      map += "<relation><property>\(item.rawValue)</property><value>\(item.title)</value></relation>\n"
    }

    map += "</map>\n"

    return map

  }
  
  // MARK: Public Class Properties
  
  public static let defaultValue : TrackElectrificationType = .notElectrified
  
  // MARK: Public Class Methods
  
  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox:NSComboBox, value: TrackElectrificationType) {
    comboBox.selectItem(at: Int(value.rawValue))
  }
  
  public static func selected(comboBox: NSComboBox) -> TrackElectrificationType {
    return TrackElectrificationType(rawValue: UInt8(comboBox.indexOfSelectedItem)) ?? defaultValue
  }
  
  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: CDI.TRACK_ELECTRIFICATION_TYPE, with: map)
  }

}
