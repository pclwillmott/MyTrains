//
//  ESUPhysicalOutputModeB.swift
//  MyTrains
//
//  Created by Paul Willmott on 09/08/2024.
//

import Foundation
import AppKit

public enum ESUPhysicalOutputModeB : UInt8, CaseIterable {
  
  // MARK: Enumeration
  
  case dimmableHeadlight              = 0b00000000
  case flashLightPhase1               = 0b00010000
  case flashLightPhase2               = 0b00100000
  case singleStrobe                   = 0b00110000
  case doubleStrobe                   = 0b01000000
  case firebox                        = 0b01010000
  case seutheSmokeUnit                = 0b01100000
  case dimmableHeadlightFadeInFadeOut = 0b01110000
  case marsLight                      = 0b10000000
  case gyraLight                      = 0b10010000
  case rule17Forward                  = 0b10100000
  case rule17Reverse                  = 0b10110000
  case pulse                          = 0b11000000
  case ditchLightPhase1               = 0b11010000
  case ditchLightPhase2               = 0b11100000
  
  // MARK: Constructors
  
  init?(title:String, decoder:Decoder) {
    for temp in ESUPhysicalOutputModeB.allCases {
      if temp.title(decoder: decoder) == title {
        self = temp
        return
      }
    }
    return nil
  }

  // MARK: Public Properties
  
  public var title : String {
    return ESUPhysicalOutputModeB.titles[self]!
  }
  
  // MARK: Public Methods
  
  public func title(decoder:Decoder) -> String {
    return self.title
  }
  
  // MARK: Private Class Properties
  
  private static let titles : [ESUPhysicalOutputModeB:String] = [
    .dimmableHeadlight : String(localized:"Dimmable headlight"),
    .flashLightPhase1 : String(localized:"Flash light (Phase 1)"),
    .flashLightPhase2 : String(localized:"Flash light (Phase 2)"),
    .singleStrobe : String(localized:"Single strobe"),
    .doubleStrobe : String(localized:"Double strobe"),
    .firebox : String(localized:"Firebox"),
    .seutheSmokeUnit : String(localized:"Seuthe smoke unit"),
    .dimmableHeadlightFadeInFadeOut : String(localized:"Dimmable headlight (fade in/out)"),
    .marsLight : String(localized:"Mars light"),
    .gyraLight : String(localized:"Gyra light"),
    .rule17Forward : String(localized:"Rule 17 Forward"),
    .rule17Reverse : String(localized:"Rule 17 Reverse"),
    .pulse : String(localized:"Pulse"),
    .ditchLightPhase1 : String(localized:"Ditch light (Phase 1)"),
    .ditchLightPhase2 : String(localized:"Ditch light (Phase 2)"),
  ]
  
  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox, decoder:Decoder) {
    
    let target = comboBox.target
    let action = comboBox.action
    comboBox.target = nil
    comboBox.action = nil
    
    comboBox.removeAllItems()
    
    var sorted : [String] = []
    
    for item in ESUPhysicalOutputModeB.allCases {
      sorted.append(item.title(decoder: decoder))
    }
    
//    sorted.sort {$0 < $1}
    
    comboBox.addItems(withObjectValues: sorted)

    comboBox.target = target
    comboBox.action = action

  }

}
