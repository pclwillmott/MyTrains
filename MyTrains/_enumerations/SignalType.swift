//
//  SignalType.swift
//  MyTrains
//
//  Created by Paul Willmott on 10/02/2024.
//

import Foundation
import AppKit

public enum SignalType : UInt16, CaseIterable {
  
  // MARK: Great Britain
  
  case noneSelected         = 0
  case gbColourLight2Aspect = 1
  case gbColourLight3Aspect = 2
  case gbColourLight4Aspect = 3

  init?(title:String) {
    for temp in SignalType.allCases {
      if temp.title == title {
        self = temp
        return
      }
    }
    return nil
  }

  // MARK: Public Properties
  
  public var title : String {
    return SignalType.titles[self]!
  }
  
  public var numberOfStates : Int {
    if let states = SignalType.numberOfStates[self] {
      return states
    }
    return 0
  }

  // MARK: Private Class Properties
  
  private static let titles : [SignalType:String] = [
    .noneSelected:String(localized: "None Selected"),
    .gbColourLight2Aspect:String(localized: "Colour-light 2 aspect"),
    .gbColourLight3Aspect:String(localized: "Colour-light 3 aspect"),
    .gbColourLight4Aspect:String(localized: "Colour-light 4 aspect"),
  ]
  
  // MARK: Public Class Properties
  
  private static let applicable : [CountryCode:Set<SignalType>] = [
    .greatBritain : [.gbColourLight2Aspect, .gbColourLight3Aspect, .gbColourLight4Aspect],
  ]
  
  private static let numberOfStates : [SignalType:Int] = [
    .gbColourLight2Aspect: 2,
    .gbColourLight3Aspect: 3,
    .gbColourLight4Aspect: 4,
  ]

  // MARK: Private Class Methods
  
  private static func map(countryCode:CountryCode) -> String {
    
    var items : [SignalType] = []
    
    if let signalTypes = applicable[countryCode] {
      for item in SignalType.allCases {
        if signalTypes.contains(item) {
          items.append(item)
        }
      }
    }
    
    items.sort {$0.title < $1.title}
    
    var map = "<map>\n"

    map += "<relation><property>\(0)</property><value>\("None Selected")</value></relation>\n"

    for item in items {
      map += "<relation><property>\(item.rawValue)</property><value>\(item.title)</value></relation>\n"
    }

    map += "</map>\n"
    
    return map
    
  }

  // MARK: Public Class Methods
  
  public static func insertMap(cdi:String, countryCode:CountryCode) -> String {
    return cdi.replacingOccurrences(of: CDI.SIGNAL_TYPE, with: map(countryCode: countryCode))
  }
  
  public static func populate(comboBox: NSComboBox, countryCode:CountryCode) {
    comboBox.removeAllItems()
    if let signalTypes = applicable[countryCode] {
      for item in SignalType.allCases {
        if signalTypes.contains(item) {
          comboBox.addItem(withObjectValue: item.title)
        }
      }
    }
  }
  
  public static func select(comboBox: NSComboBox, signalType:SignalType) {
    comboBox.deselectItem(at: comboBox.indexOfSelectedItem)
    var index = 0
    while index < comboBox.numberOfItems {
      if let title = comboBox.itemObjectValue(at: index) as? String, title == signalType.title {
        comboBox.selectItem(at: index)
        return
      }
      index += 1
    }
  }
  
  public static func selected(comboBox: NSComboBox) -> SignalType? {
    if let title = comboBox.objectValueOfSelectedItem as? String {
      for item in SignalType.allCases {
        if item.title == title {
          return item
        }
      }
    }
    return nil
  }

}
