//
//  TrackGauge.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/06/2022.
//

import Foundation
import AppKit

public enum TrackGauge : UInt8, CaseIterable {

  case z                   = 1
  case nEurope             = 2
  case twomm               = 3
  case ooo                 = 4
  case nUK                 = 5
  case ttEurope            = 6
  case tt3                 = 7
  case ttTriang            = 8
  case threemm13dot5       = 9
  case threemm14dot2       = 10
  case ho                  = 11
  case em18dot0            = 12
  case em18dot2            = 13
  case p4                  = 14
  case s4                  = 15
  case s                   = 16
  case oUSA                = 17
  case oEurope             = 18
  case oUK                 = 19
  case s7                  = 20
  case one                 = 21
  case three               = 22
  case g                   = 23
  case o16dot5             = 24
  case o9                  = 25
  case on30                = 26
  case fivedotfivemm12dot0 = 27
  case fivedotfivemm16dot5 = 28
  case oon3                = 29
  case zerozero9           = 30
  case p7dot83             = 31
  case tenmm               = 32
  case sixteenmm           = 33
  case t                   = 34

  init?(title:String) {
    for temp in TrackGauge.allCases {
      if temp.title == title {
        self = temp
        return
      }
    }
    return nil
  }

  // MARK: Public Properties
  
  public var title : String {
    
    let data = TrackGauge.data[self]!
    
    let formatter = NumberFormatter()
    
    formatter.usesGroupingSeparator = true
    formatter.groupingSize = 3

    formatter.alwaysShowsDecimalSeparator = false
    formatter.minimumFractionDigits = 0
    formatter.maximumFractionDigits = 2

    let width = formatter.string(from: UnitLength.convert(fromValue: data.track, fromUnits: .millimeters, toUnits: appNode!.unitsActualLength) as NSNumber)!
    
    let result = "\(data.title) \(data.ratio.title) (\(width)\(appNode!.unitsActualLength.symbol))"

    return result
    
  }
  
  // MARK: Public Class Properties
  
  public static let data : [TrackGauge:(gauge:TrackGauge, title:String, ratio:Scale, scale:Double, track:Double)] = [
    .t:(.t, "T", .scale1to450, 0.64, 3.0),
    .z:(.z, "Z", .scale1to220, 1.4, 6.0),
    .nEurope:(.nEurope, "N", .scale1to160, 1.9, 9.0),
    .twomm:(.twomm, "2mm", .scale1to152, 2.0, 9.42),
    .ooo:(.ooo, "OOO", .scale1to152, 2.0, 9.5),
    .nUK:(.nUK, "N", .scale1to148, 2.06, 9.0),
    .ttEurope:(.ttEurope, "TT", .scale1to120, 2.5, 12.0),
    .tt3:(.tt3, "TT3", .scale1to120, 2.5, 12.0),
    .ttTriang:(.ttTriang, "TT", .scale1to101dot6, 3.0, 12.0),
    .threemm13dot5:(.threemm13dot5, "3mm", .scale1to101dot6, 3.0, 13.5),
    .threemm14dot2:(.threemm14dot2, "3mm", .scale1to101dot6, 3.0, 14.2),
    .ho:(.ho, "HO", .scale1to87dot1, 3.5, 16.5),
    .em18dot0:(.em18dot0, "EM", .scale1to76dot2, 4.0, 18.0),
    .em18dot2:(.em18dot0, "EM", .scale1to76dot2, 4.0, 18.2),
    .p4:(.p4, "P4", .scale1to76dot2, 4.0, 18.83),
    .s4:(.s4, "S4", .scale1to76dot2, 4.0, 18.83),
    .s:(.s, "S", .scale1to64, 4.76, 7.0 / 8.0 * 25.4),
    .oUSA:(.oUSA, "O", .scale1to48, 0.25 * 25.4, 1.25 * 25.4),
    .oEurope:(.oEurope, "O", .scale1to45, 6.8, 32.0),
    .oUK:(.oUK, "O", .scale1to43dot5, 7.0, 32.0),
    .s7:(.s7, "S7", .scale1to43dot5, 7.0, 33.0),
    .one:(.one, "1", .scale1to32, 3.0 / 8.0 * 25.4, 45.0),
    .tenmm:(.tenmm, "1", .scale1to32, 10.0, 45.0),
    .three:(.three, "3", .scale1to22dot5, 13.5, 2.5 * 25.4),
    .g:(.g, "G", .scale1to22dot5, 13.55, 45.0),
    .sixteenmm:(.sixteenmm, "16mm", .scale1to32, 16.0, 32.0),
    .o16dot5:(.o16dot5, "O-16.5", .scale1to43, 7.0, 16.5),
    .o9:(.o9, "O9", .scale1to43, 7.0, 9.0),
    .on30:(.on30, "On30", .scale1to48, 0.25 * 25.4, 16.5),
    .fivedotfivemm12dot0:(.fivedotfivemm12dot0, "5.5mm", .scale1to55, 5.5, 12.0),
    .fivedotfivemm16dot5:(.fivedotfivemm16dot5, "5.5mm", .scale1to55, 5.5, 16.5),
    .oon3:(.oon3, "OOn3", .scale1to76, 4.0, 12.0),
    .zerozero9:(.zerozero9, "009", .scale1to76, 4.0, 9.0),
    .p7dot83:(.p7dot83, "P7.83", .scale1to76, 4.0, 7.83),
  ]
  
  // MARK: Private Class Methods
  
  private static func map(layout:LayoutNode?) -> String {
    
    var items : [TrackGauge] = []
    
    if let layout {
      if layout.scale == .scale1to76dot2 {
        items.append(.ho)
      }
      
      for (id, data) in TrackGauge.data {
        if data.ratio == layout.scale && (data.gauge == layout.defaultTrackGuage || layout.usesMultipleTrackGauges) {
          items.append(id)
        }
      }
    }
    else {
      for (id, _) in TrackGauge.data {
        items.append(id)
      }
    }
    
    items.sort {$0.title < $1.title}
    
    var map = "<map>\n"

    for item in items {
      map += "<relation><property>\(item.rawValue)</property><value>\(item.title)</value></relation>\n"
    }

    map += "</map>\n"

    return map

  }
  
  // MARK: Public Class Properties
  
  public static let defaultValue : TrackGauge = .ho

  // MARK: Public Class Methods
  
  public static func insertMap(cdi:String, layout:LayoutNode?) -> String {
    return cdi.replacingOccurrences(of: CDI.TRACK_GAUGE, with: map(layout: layout))
  }

  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: CDI.ALL_TRACK_GAUGES, with: map(layout: nil))
  }
  
  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    for item in TrackGauge.allCases {
      comboBox.addItem(withObjectValue: item.title)
    }
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox:NSComboBox, value: TrackGauge) {
    comboBox.selectItem(at: Int(value.rawValue)-1)
  }
  
  public static func selected(comboBox: NSComboBox) -> TrackGauge {
    return TrackGauge(rawValue: UInt8(comboBox.indexOfSelectedItem) + 1) ?? defaultValue
  }


}

