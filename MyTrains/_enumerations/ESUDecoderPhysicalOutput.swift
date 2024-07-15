//
//  ESUDecoderPhysicalOutput.swift
//  MyTrains
//
//  Created by Paul Willmott on 15/07/2024.
//

import Foundation
import AppKit

public enum ESUDecoderPhysicalOutput : UInt8, CaseIterable {
  
  // MARK: Enumeration
  
  case frontLight   = 0
  case frontLight_2 = 20
  case rearLight    = 1
  case rearLight_2  = 21
  case aux1         = 2
  case aux1_2       = 22
  case aux2         = 3
  case aux2_2       = 23
  case aux3         = 4
  case aux4         = 5
  case aux5         = 6
  case aux6         = 7
  case aux7         = 8
  case aux8         = 9
  case aux9         = 10
  case aux10        = 11
  case aux11        = 12
  case aux12        = 13
  case aux13        = 14
  case aux14        = 15
  case aux15        = 16
  case aux16        = 17
  case aux17        = 18
  case aux18        = 19

  // MARK: Constructors
  
  init?(title:String) {
    for temp in ESUDecoderPhysicalOutput.allCases {
      if temp.title == title {
        self = temp
        return
      }
    }
    return nil
  }

  // MARK: Public Properties
  
  public var title : String {
    
    let titles : [ESUDecoderPhysicalOutput:String] = [
      .frontLight   : String(localized:"Front Light [1]"),
      .frontLight_2 : String(localized:"Front Light [2]"),
      .rearLight    : String(localized:"Rear Light [1]"),
      .rearLight_2  : String(localized:"Rear Light [2]"),
      .aux1         : String(localized:"AUX1 [1]"),
      .aux1_2       : String(localized:"AUX1 [2]"),
      .aux2         : String(localized:"AUX2 [1]"),
      .aux2_2       : String(localized:"AUX2 [2]"),
      .aux3         : String(localized:"AUX3"),
      .aux4         : String(localized:"AUX4"),
      .aux5         : String(localized:"AUX5"),
      .aux6         : String(localized:"AUX6"),
      .aux7         : String(localized:"AUX7"),
      .aux8         : String(localized:"AUX8"),
      .aux9         : String(localized:"AUX9"),
      .aux10        : String(localized:"AUX10"),
      .aux11        : String(localized:"AUX11"),
      .aux12        : String(localized:"AUX12"),
      .aux13        : String(localized:"AUX13"),
      .aux14        : String(localized:"AUX14"),
      .aux15        : String(localized:"AUX15"),
      .aux16        : String(localized:"AUX16"),
      .aux17        : String(localized:"AUX17"),
      .aux18        : String(localized:"AUX18"),
    ]
    
    return titles[self]!
    
  }
  
  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    for item in ESUDecoderPhysicalOutput.allCases {
      comboBox.addItem(withObjectValue: item.title)
    }
  }

}
