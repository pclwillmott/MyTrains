//
//  ESUDecoderPhysicalOutput.swift
//  MyTrains
//
//  Created by Paul Willmott on 15/07/2024.
//

import Foundation
import AppKit

public enum ESUDecoderPhysicalOutput : UInt8, CaseIterable, Codable {
  
  // MARK: Enumeration
  
  case frontLight   = 24
  case frontLight_1 = 0
  case frontLight_2 = 20
  case rearLight    = 25
  case rearLight_1  = 1
  case rearLight_2  = 21
  case aux1         = 26
  case aux1_1       = 2
  case aux1_2       = 22
  case aux2         = 27
  case aux2_1       = 3
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
    return ESUDecoderPhysicalOutput.titles[self]!
  }
  
  // MARK: Public Methods
  
  public func cvIndexOffset(decoder:Decoder) -> Int {
    
    let method = decoder.esuPhysicalOutputCVIndexOffsetMethod
    
    if let lookup = ESUDecoderPhysicalOutput.indexLookup[method], let index = lookup[self] {
      return index * (method == .lok3 ? 1 : 8)
    }
    
    return 0
    
  }
  
  // MARK: Private Class Properties
  
  private static let titles : [ESUDecoderPhysicalOutput:String] = [
    .frontLight     : String(localized:"Front Light"),
    .frontLight_1   : String(localized:"Front Light [1]"),
    .frontLight_2   : String(localized:"Front Light [2]"),
    .rearLight      : String(localized:"Rear Light"),
    .rearLight_1    : String(localized:"Rear Light [1]"),
    .rearLight_2    : String(localized:"Rear Light [2]"),
    .aux1           : String(localized:"AUX1"),
    .aux1_1         : String(localized:"AUX1 [1]"),
    .aux1_2         : String(localized:"AUX1 [2]"),
    .aux2           : String(localized:"AUX2"),
    .aux2_1         : String(localized:"AUX2 [1]"),
    .aux2_2         : String(localized:"AUX2 [2]"),
    .aux3           : String(localized:"AUX3"),
    .aux4           : String(localized:"AUX4"),
    .aux5           : String(localized:"AUX5"),
    .aux6           : String(localized:"AUX6"),
    .aux7           : String(localized:"AUX7"),
    .aux8           : String(localized:"AUX8"),
    .aux9           : String(localized:"AUX9"),
    .aux10          : String(localized:"AUX10"),
    .aux11          : String(localized:"AUX11"),
    .aux12          : String(localized:"AUX12"),
    .aux13          : String(localized:"AUX13"),
    .aux14          : String(localized:"AUX14"),
    .aux15          : String(localized:"AUX15"),
    .aux16          : String(localized:"AUX16"),
    .aux17          : String(localized:"AUX17"),
    .aux18          : String(localized:"AUX18"),
  ]
  
  private static let indexLookup : [ESUPhysicalOutputCVIndexOffsetMethod:[ESUDecoderPhysicalOutput:Int]] = [
    
    .none : [:],
    
    .lok5 : [
      .frontLight_1 : 0,
      .rearLight_1  : 1,
      .aux1_1       : 2,
      .aux2_1       : 3,
      .aux3         : 4,
      .aux4         : 5,
      .aux5         : 6,
      .aux6         : 7,
      .aux7         : 8,
      .aux8         : 9,
      .aux9         : 10,
      .aux10        : 11,
      .aux11        : 12,
      .aux12        : 13,
      .aux13        : 14,
      .aux14        : 15,
      .aux15        : 16,
      .aux16        : 17,
      .aux17        : 18,
      .aux18        : 19,
      .frontLight_2 : 20,
      .rearLight_2  : 21,
      .aux1_2       : 22,
      .aux2_2       : 23,
    ],
    
    .lok4 : [
      .frontLight_1 : 0,
      .rearLight_1  : 1,
      .aux1_1       : 2,
      .aux2_1       : 3,
      .aux3         : 4,
      .aux4         : 5,
      .aux5         : 6,
      .aux6         : 7,
      .aux7         : 8,
      .aux8         : 9,
      .aux9         : 10,
      .aux10        : 11,
      .frontLight_2 : 12,
      .rearLight_2  : 13,
      .aux1_2       : 14,
      .aux2_2       : 15,
    ],
    
    .lok3 : [
      .frontLight : 0,
      .rearLight  : 1,
      .aux1       : 2,
      .aux2       : 3,
      .aux3       : 4,
      .aux4       : 5,
      .aux5       : 6,
      .aux6       : 7,
    ],
    
  ]

  // MARK: Public Class Methods
  
  public static func applicableOutputs(method:ESUPhysicalOutputCVIndexOffsetMethod) -> [ESUDecoderPhysicalOutput] {
    
    var result : [ESUDecoderPhysicalOutput] = []
    
    guard let lookup = indexLookup[method] else {
      return result
    }
    
    for output in ESUDecoderPhysicalOutput.allCases {
      if lookup.keys.contains(output) {
        result.append(output)
      }
    }
    
    return result
    
  }
  
  public static func populate(comboBox:NSComboBox, decoder:Decoder) {
    
    let target = comboBox.target
    let action = comboBox.action
    
    comboBox.target = nil
    comboBox.action = nil
    
    let validOutputs = decoder.esuSupportedPhysicalOutputs
    
    comboBox.removeAllItems()
    
    for item in ESUDecoderPhysicalOutput.allCases {
      if validOutputs.contains(item) {
        comboBox.addItem(withObjectValue: item.title)
      }
    }
    
    comboBox.target = target
    comboBox.action = action
  }

}
