//
//  SoundCV.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/07/2024.
//

import Foundation
import AppKit

public enum SoundCV : UInt8, CaseIterable {
  
  // MARK: Enumeration
  
  case soundCV1 = 0
  case soundCV2 = 1
  case soundCV3 = 2
  case soundCV4 = 3
  case soundCV5 = 4
  case soundCV6 = 5
  case soundCV7 = 6
  case soundCV8 = 7
  case soundCV9 = 8
  case soundCV10 = 9
  case soundCV11 = 10
  case soundCV12 = 11
  case soundCV13 = 12
  case soundCV14 = 13
  case soundCV15 = 14
  case soundCV16 = 15

  // MARK: Constructors
  
  init?(title:String) {
    for temp in SoundCV.allCases {
      if temp.title == title {
        self = temp
        return
      }
    }
    return nil
  }

  // MARK: Public Properties
  
  public var title : String {
    return SoundCV.titles[self]!
  }

  public func cvIndexOffset(decoder:Decoder) -> Int {
    return Int(self.rawValue)
  }

  // MARK: Public Class Properties
  
  public static let titles : [SoundCV:String] = [
    .soundCV1 : String(localized:"Sound CV 1"),
    .soundCV2 : String(localized:"Sound CV 2"),
    .soundCV3 : String(localized:"Sound CV 3"),
    .soundCV4 : String(localized:"Sound CV 4"),
    .soundCV5 : String(localized:"Sound CV 5"),
    .soundCV6 : String(localized:"Sound CV 6"),
    .soundCV7 : String(localized:"Sound CV 7"),
    .soundCV8 : String(localized:"Sound CV 8"),
    .soundCV9 : String(localized:"Sound CV 9"),
    .soundCV10 : String(localized:"Sound CV 10"),
    .soundCV11 : String(localized:"Sound CV 11"),
    .soundCV12 : String(localized:"Sound CV 12"),
    .soundCV13 : String(localized:"Sound CV 13"),
    .soundCV14 : String(localized:"Sound CV 14"),
    .soundCV15 : String(localized:"Sound CV 15"),
    .soundCV16 : String(localized:"Sound CV 16"),
  ]

  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    for item in SoundCV.allCases {
      comboBox.addItem(withObjectValue: item.title)
    }
  }

}
