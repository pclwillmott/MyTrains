//
//  SamplePeriod.swift
//  MyTrains
//
//  Created by Paul Willmott on 08/08/2022.
//

import Foundation
import AppKit

public enum SamplePeriod : Int {
  
  case sec5 = 0
  case sec10 = 1
  case sec15 = 2
  case sec20 = 3
  case sec25 = 4
  case sec30 = 5
  case sec35 = 6
  case sec40 = 7
  case sec45 = 8
  case sec50 = 9
  case sec55 = 10
  case sec60 = 11

  // MARK: Public Properties
  
  public var title : String {
    return SamplePeriod.titles[self.rawValue]
  }
  
  public var samplePeriod : TimeInterval {
    get {
      return Double(self.rawValue + 1) * 5.0
    }
  }
  
  // MARK: Private Class Properties
  
  private static let titles = [
    String(localized: "5 seconds", comment: "Used to select a sampling period"),
    String(localized: "10 seconds", comment: "Used to select a sampling period"),
    String(localized: "15 seconds", comment: "Used to select a sampling period"),
    String(localized: "20 seconds", comment: "Used to select a sampling period"),
    String(localized: "25 seconds", comment: "Used to select a sampling period"),
    String(localized: "30 seconds", comment: "Used to select a sampling period"),
    String(localized: "35 seconds", comment: "Used to select a sampling period"),
    String(localized: "40 seconds", comment: "Used to select a sampling period"),
    String(localized: "45 seconds", comment: "Used to select a sampling period"),
    String(localized: "50 seconds", comment: "Used to select a sampling period"),
    String(localized: "55 seconds", comment: "Used to select a sampling period"),
    String(localized: "1 minute", comment: "Used to select a sampling period"),
  ]
  
  private static var map : String {
    
    let items : [SamplePeriod] = [
      .sec5,
      .sec10,
      .sec15,
      .sec20,
      .sec25,
      .sec30,
      .sec35,
      .sec40,
      .sec45,
      .sec50,
      .sec55,
      .sec60,
    ]
    
    var map = ""
    
    for item in items {
      map += "<relation><property>\(item.rawValue)</property><value>\(item.title)</value></relation>\n"
    }

    return map
    
  }

  // MARK: Public Class Properties
  
  public static let defaultValue : SamplePeriod = .sec15
  
  public static let mapPlaceholder = "%%SAMPLE_PERIOD%%"

  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: .defaultValue)
  }
  
  public static func select(comboBox:NSComboBox, value:SamplePeriod) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selected(comboBox: NSComboBox) -> SamplePeriod {
    return SamplePeriod(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }
  
  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: mapPlaceholder, with: map)
  }

}
