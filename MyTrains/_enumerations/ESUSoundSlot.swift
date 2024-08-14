//
//  ESUSoundSlot.swift
//  MyTrains
//
//  Created by Paul Willmott on 30/07/2024.
//

import Foundation
import AppKit

public enum ESUSoundSlot : Int, CaseIterable {
  
  // MARK: Enumeration
  
  case soundSlot1 = 0
  case soundSlot2 = 1
  case soundSlot3 = 2
  case soundSlot4 = 3
  case soundSlot5 = 4
  case soundSlot6 = 5
  case soundSlot7 = 6
  case soundSlot8 = 7
  case soundSlot9 = 8
  case soundSlot10 = 9
  case soundSlot11 = 10
  case soundSlot12 = 11
  case soundSlot13 = 12
  case soundSlot14 = 13
  case soundSlot15 = 14
  case soundSlot16 = 15
  case soundSlot17 = 16
  case soundSlot18 = 17
  case soundSlot19 = 18
  case soundSlot20 = 19
  case soundSlot21 = 20
  case soundSlot22 = 21
  case soundSlot23 = 22
  case soundSlot24 = 23
  case soundSlot25 = 24
  case soundSlot26 = 25
  case soundSlot27 = 26
  case soundSlot28 = 27
  case soundSlot29 = 28
  case soundSlot30 = 29
  case soundSlot31 = 30
  case soundSlot32 = 31
  case randomSounds = 34
  case brakeSound = 32
  case gearShiftSound = 33

  // MARK: Constructors
  
  init?(title:String) {
    for temp in ESUSoundSlot.allCases {
      if temp.title == title {
        self = temp
        return
      }
    }
    return nil
  }

  // MARK: Public Properties
  
  public var title : String {
    return ESUSoundSlot.titles[self]!
  }

  public func cvIndexOffset(decoder:Decoder) -> Int {
    
    var index : Int
    
    if decoder.decoderType.capabilities.contains(.lok4) {
      switch self {
      case .randomSounds:
        index = 24
      case .brakeSound:
        index = 25
      case .gearShiftSound:
        index = 26
      default:
        index = rawValue
      }
    }
    else {
      index = self.rawValue
    }
    
    return index * 8
    
  }

  // MARK: Public Class Properties
  
  public static let titles : [ESUSoundSlot:String] = [
    .soundSlot1     : String(localized:"Sound Slot 1"),
    .soundSlot2     : String(localized:"Sound Slot 2"),
    .soundSlot3     : String(localized:"Sound Slot 3"),
    .soundSlot4     : String(localized:"Sound Slot 4"),
    .soundSlot5     : String(localized:"Sound Slot 5"),
    .soundSlot6     : String(localized:"Sound Slot 6"),
    .soundSlot7     : String(localized:"Sound Slot 7"),
    .soundSlot8     : String(localized:"Sound Slot 8"),
    .soundSlot9     : String(localized:"Sound Slot 9"),
    .soundSlot10    : String(localized:"Sound Slot 10"),
    .soundSlot11    : String(localized:"Sound Slot 11"),
    .soundSlot12    : String(localized:"Sound Slot 12"),
    .soundSlot13    : String(localized:"Sound Slot 13"),
    .soundSlot14    : String(localized:"Sound Slot 14"),
    .soundSlot15    : String(localized:"Sound Slot 15"),
    .soundSlot16    : String(localized:"Sound Slot 16"),
    .soundSlot17    : String(localized:"Sound Slot 17"),
    .soundSlot18    : String(localized:"Sound Slot 18"),
    .soundSlot19    : String(localized:"Sound Slot 19"),
    .soundSlot20    : String(localized:"Sound Slot 20"),
    .soundSlot21    : String(localized:"Sound Slot 21"),
    .soundSlot22    : String(localized:"Sound Slot 22"),
    .soundSlot23    : String(localized:"Sound Slot 23"),
    .soundSlot24    : String(localized:"Sound Slot 24"),
    .soundSlot25    : String(localized:"Sound Slot 25"),
    .soundSlot26    : String(localized:"Sound Slot 26"),
    .soundSlot27    : String(localized:"Sound Slot 27"),
    .soundSlot28    : String(localized:"Sound Slot 28"),
    .soundSlot29    : String(localized:"Sound Slot 29"),
    .soundSlot30    : String(localized:"Sound Slot 30"),
    .soundSlot31    : String(localized:"Sound Slot 31"),
    .soundSlot32    : String(localized:"Sound Slot 32"),
    .brakeSound     : String(localized:"Brake Sound"),
    .gearShiftSound : String(localized:"Gear Shift Sound"),
    .randomSounds   : String(localized:"Random Sounds"),
  ]

  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox, decoder:Decoder) {
    
    var slots : Set<ESUSoundSlot> = []
    
    if decoder.decoderType.capabilities.contains(.soundSlot1to10) {
      slots = slots.union([
        .soundSlot1,
        .soundSlot2,
        .soundSlot3,
        .soundSlot4,
        .soundSlot5,
        .soundSlot6,
        .soundSlot7,
        .soundSlot8,
        .soundSlot9,
        .soundSlot10,
      ])
    }

    if decoder.decoderType.capabilities.contains(.soundSlot11to24) {
      slots = slots.union([
        .soundSlot11,
        .soundSlot12,
        .soundSlot13,
        .soundSlot14,
        .soundSlot15,
        .soundSlot16,
        .soundSlot17,
        .soundSlot18,
        .soundSlot19,
        .soundSlot20,
        .soundSlot21,
        .soundSlot22,
        .soundSlot23,
        .soundSlot24,
      ])
    }

    if decoder.decoderType.capabilities.contains(.soundSlot25to27) {
      slots = slots.union([
        .soundSlot25,
        .soundSlot26,
        .soundSlot27,
      ])
    }

    if decoder.decoderType.capabilities.contains(.soundSlot28to32) {
      slots = slots.union([
        .soundSlot28,
        .soundSlot29,
        .soundSlot30,
        .soundSlot31,
        .soundSlot32,
      ])
    }

    if decoder.decoderType.capabilities.contains(.soundSlotBrake) {
      slots = slots.union([
        .brakeSound,
      ])
    }

    if decoder.decoderType.capabilities.contains(.soundSlotGearShift) {
      slots = slots.union([
        .gearShiftSound,
      ])
    }

    if decoder.decoderType.capabilities.contains(.soundSlotRandom) {
      slots = slots.union([
        .randomSounds,
      ])
    }
    
    comboBox.removeAllItems()
    for item in ESUSoundSlot.allCases {
      if slots.contains(item) {
        comboBox.addItem(withObjectValue: item.title)
      }
    }
  }

}
