//
//  TrackCode.swift
//  MyTrains
//
//  Created by Paul Willmott on 25/06/2022.
//

import Foundation
import AppKit

public enum TrackCode : Int {

  case code55  = 0
  case code60  = 1
  case code70  = 2
  case code75  = 3
  case code80  = 4
  case code83  = 5
  case code100 = 6
  case code124 = 7
  case code143 = 8
  case code200 = 9
  case code250 = 10

  // MARK: Public Properties
  
  public var title : String {
    return TrackCode.titles[self.rawValue]
  }
  
  // MARK: Private Class Properties
  
  private static let titles : [String] = [
    String(localized: "Code 55", comment: "Used to indicate the track code"),
    String(localized: "Code 60", comment: "Used to indicate the track code"),
    String(localized: "Code 70", comment: "Used to indicate the track code"),
    String(localized: "Code 75", comment: "Used to indicate the track code"),
    String(localized: "Code 80", comment: "Used to indicate the track code"),
    String(localized: "Code 83", comment: "Used to indicate the track code"),
    String(localized: "Code 100", comment: "Used to indicate the track code"),
    String(localized: "Code 124", comment: "Used to indicate the track code"),
    String(localized: "Code 143", comment: "Used to indicate the track code"),
    String(localized: "Code 200", comment: "Used to indicate the track code"),
    String(localized: "Code 250", comment: "Used to indicate the track code"),
  ]
  
  private static var map : String {
    
    var items : [TrackCode] = [
      .code55,
      .code60,
      .code70,
      .code75,
      .code80,
      .code83,
      .code100,
      .code124,
      .code143,
      .code200,
      .code250,
    ]
    
    var map = ""
    
    for item in items {
      map += "<relation><property>\(item.rawValue)</property><value>\(item.title)</value></relation>\n"
    }

    return map
    
  }
  
  // MARK: Public Class Properties
  
  public static var defaultValue : TrackCode = .code100
  
  public static let mapPlaceholder = "%%TRACK_CODE%%"

  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox:NSComboBox, value:TrackCode) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selection(comboBox:NSComboBox) -> TrackCode {
    return TrackCode(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }

  public static func selected(comboBox:NSComboBox) -> SampleRate {
    return SampleRate(rawValue: comboBox.indexOfSelectedItem) ?? .defaultValue
  }
  
  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: mapPlaceholder, with: map)
  }

}

