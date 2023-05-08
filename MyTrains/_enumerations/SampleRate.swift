//
//  SampleRate.swift
//  MyTrains
//
//  Created by Paul Willmott on 16/12/2022.
//

import Foundation
import AppKit

public enum SampleRate : Int {
  
  case rate1 = 1
  case rate2 = 2
  case rate3 = 3
  case rate4 = 4
  case rate5 = 5
  case rate6 = 6
  case rate7 = 7
  case rate8 = 8
  case rate9 = 9
  case rate10 = 10
  case rate11 = 11
  case rate12 = 12
  case rate13 = 13
  case rate14 = 14
  case rate15 = 15
  case rate16 = 16
  case rate17 = 17
  case rate18 = 18
  case rate19 = 19
  case rate20 = 20
  case rate21 = 21
  case rate22 = 22
  case rate23 = 23
  case rate24 = 24
  case rate25 = 25
  case rate26 = 26
  case rate27 = 27
  case rate28 = 28
  case rate29 = 29
  case rate30 = 30
  case rate31 = 31
  case rate32 = 32
  case rate33 = 33
  case rate34 = 34
  case rate35 = 35
  case rate36 = 36
  case rate37 = 37
  case rate38 = 38
  case rate39 = 39
  case rate40 = 40
  case rate41 = 41
  case rate42 = 42
  case rate43 = 43
  case rate44 = 44
  case rate45 = 45
  case rate46 = 46
  case rate47 = 47
  case rate48 = 48
  case rate49 = 49
  case rate50 = 50
  case rate75 = 75

  public var title : String {
    get {
      return "\(rawValue) Hz"
    }
  }
    
  public static let defaultValue : SampleRate = .rate1
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    for index in 1...50 {
      comboBox.addItem(withObjectValue: "\(index) Hz")
    }
    comboBox.addItem(withObjectValue: "\(75) Hz")
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox:NSComboBox, value:SampleRate) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selected(comboBox:NSComboBox) -> SampleRate {
    return SampleRate(rawValue: comboBox.indexOfSelectedItem) ?? .defaultValue
  }
  
}
