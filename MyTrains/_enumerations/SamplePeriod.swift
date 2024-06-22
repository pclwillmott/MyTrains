//
//  SamplePeriod.swift
//  MyTrains
//
//  Created by Paul Willmott on 08/08/2022.
//

import Foundation
import AppKit

public enum SamplePeriod : UInt8, CaseIterable {
  
  // MARK: Enumeration
  
  case sec5  = 0
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

  // MARK: Constructors
  
  init?(title:String) {
    for temp in SamplePeriod.allCases {
      if temp.title == title {
        self = temp
        return
      }
    }
    return nil
  }

  // MARK: Public Properties
  
  public var title : String {
    
    let titles : [SamplePeriod:String] = [
      .sec5:  String(localized: "5 seconds",  comment: "Used to select a sampling period"),
      .sec10: String(localized: "10 seconds", comment: "Used to select a sampling period"),
      .sec15: String(localized: "15 seconds", comment: "Used to select a sampling period"),
      .sec20: String(localized: "20 seconds", comment: "Used to select a sampling period"),
      .sec25: String(localized: "25 seconds", comment: "Used to select a sampling period"),
      .sec30: String(localized: "30 seconds", comment: "Used to select a sampling period"),
      .sec35: String(localized: "35 seconds", comment: "Used to select a sampling period"),
      .sec40: String(localized: "40 seconds", comment: "Used to select a sampling period"),
      .sec45: String(localized: "45 seconds", comment: "Used to select a sampling period"),
      .sec50: String(localized: "50 seconds", comment: "Used to select a sampling period"),
      .sec55: String(localized: "55 seconds", comment: "Used to select a sampling period"),
      .sec60: String(localized: "1 minute",   comment: "Used to select a sampling period"),
    ]

    return titles[self]!
    
  }
  
  public var samplePeriod : TimeInterval {
    return Double(self.rawValue + 1) * 5.0
  }
  
  // MARK: Private Class Properties
  
  private static var map : String {
    
    var map = ""
    
    for item in SamplePeriod.allCases {
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
    for item in SamplePeriod.allCases {
      comboBox.addItem(withObjectValue: item.title)
    }
    select(comboBox: comboBox, value: .defaultValue)
  }
  
  public static func select(comboBox:NSComboBox, value:SamplePeriod) {
    comboBox.selectItem(at: Int(value.rawValue))
  }
  
  public static func selected(comboBox: NSComboBox) -> SamplePeriod {
    return SamplePeriod(rawValue: UInt8(comboBox.indexOfSelectedItem)) ?? defaultValue
  }
  
  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: mapPlaceholder, with: map)
  }

}
