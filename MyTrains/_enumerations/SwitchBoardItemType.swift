//
//  SwitchBoardItemPartType.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/06/2022.
//

import Foundation
import AppKit

public typealias TurnoutSwitchSetting = (switchNumber: Int, switchState: TurnoutSwitchState)

public typealias SwitchBoardConnection = (from: Int, to: Int, switchSettings: [TurnoutSwitchSetting])

public enum SwitchBoardItemType : UInt16 {
  
  case straight           = 0
  case curve              = 1
  case longCurve          = 2
  case turnoutRight       = 3
  case turnoutLeft        = 4
  case cross              = 5
  case diagonalCross      = 6
  case yTurnout           = 7
  case turnout3Way        = 8
  case leftCurvedTurnout  = 9
  case rightCurvedTurnout = 10
  case singleSlip         = 11
  case doubleSlip         = 12
  case buffer             = 13
  case block              = 14
  case sensor             = 15
  case link               = 16
  case platform           = 17
  case signal             = 18
  case none               = 0xffff

  // MARK: Public Properties
  
  public var visibility : OpenLCBNodeVisibility {
    guard let result = SwitchBoardItemType.visibility[self] else {
      return .visibilityNone
    }
    return result
  }
  
  public var isTurnout : Bool {
  
    let turnouts : Set<SwitchBoardItemType> = [
      .turnoutRight,
      .turnoutLeft,
      .cross,
      .diagonalCross,
      .yTurnout,
      .turnout3Way,
      .leftCurvedTurnout,
      .rightCurvedTurnout,
      .singleSlip,
      .doubleSlip,
    ]
    
    return turnouts.contains(self)
    
  }

  public var isBlock : Bool {
  
    let blocks : Set<SwitchBoardItemType> = [
      .block,
    ]
    
    return blocks.contains(self)
    
  }
  
  public var isGroup : Bool {
    return isTurnout || isBlock
  }

  public var title : String {
    return self == .none ? String(localized: "None") : SwitchBoardItemType.titles[Int(self.rawValue)]
  }
  
  public var connections : [SwitchBoardConnection] {
    get {
      return SwitchBoardItemType.connections[self] ?? []
    }
  }
  
  public var numberOfDimensionsRequired : Int {
    if isGroup, let connections = SwitchBoardItemType.connections[self] {
      return connections.count
    }
    return 0
  }
  
  public var numberOfTurnoutSwitches : Int {
    var used : Set<Int> = []
    if let connections = SwitchBoardItemType.connections[self] {
      for connection in connections {
        for item in connection.switchSettings {
          used.insert(item.switchNumber)
        }
      }
    }
    return used.count
  }
  
  public var eventsSupported : Set<SwitchBoardEventType> {
    
    var result : Set<SwitchBoardEventType> = []
    
    let turnouts = numberOfTurnoutSwitches
    
    if turnouts > 0 {
      result = result.union([.sw1Thrown, .sw1Closed, .throwSW1, .closeSW1, .sw1CommandedThrown, .sw1CommandedClosed])
    }
    
    if turnouts > 1 {
      result = result.union([.sw2Thrown, .sw2Closed, .throwSW2, .closeSW2, .sw2CommandedThrown, .sw2CommandedClosed])
    }
    
    let noFeedback : Set<SwitchBoardItemType> = [.buffer, .curve, .longCurve, .link, .none, .platform, .straight]
    
    if self == .sensor {
      result = result.union([.enterDetectionZone, .exitDetectionZone])
    }
    else if !noFeedback.contains(self) {
      result = result.union([.enterDetectionZone, .exitDetectionZone, .transponder, .trackFault, .trackFaultCleared])
    }
    
    return result
    
  }
  
  // MARK: Public Methods
  
  public func pointsSet(orientation:Orientation) -> Set<Int> {
    var result : Set<Int> = []
    for connection in connections {
      if connection.from != -1 {
        let from = (connection.from + Int(orientation.rawValue)) % 8
        result.insert(from)
      }
      if connection.to != -1 {
        let to = (connection.to + Int(orientation.rawValue)) % 8
        result.insert(to)
      }
    }
    return result
  }
  
  public func points(orientation:Orientation) -> [Int] {
    return pointsSet(orientation: orientation).sorted {$0 < $1}
  }
  
  public func pointLabels(orientation:Orientation) -> [(pos:Int,label:String)] {
    
    let labels = ["A","B","C","D","E","F","G","H"]
    
    var nextLabel = 0
    
    var result : [(pos:Int, label:String)] = []
    for point in points(orientation: orientation) {
      result.append((pos: point, label: String(labels[nextLabel])))
      nextLabel += 1
    }
    
    return result
  }
  
  public func routeLabels(orientation:Orientation) -> [(index:Int,label:String)] {
    
    var lookup : [Int:String] = [:]
    for point in pointLabels(orientation: orientation) {
      lookup[point.pos] = point.label
    }
    
    var result : [(index:Int,label:String)] = []
    var index = 0
    for connection in connections {
      if let to = lookup[(connection.to + Int(orientation.rawValue)) % 8], let from = lookup[(connection.from + Int(orientation.rawValue)) % 8] {
        let label = to < from ? "\(to) to \(from)" : "\(from) to \(to)"
        result.append((index:index, label:label))
      }
      index += 1
    }
    
    return result.sorted {$0.label < $1.label}
  }
  
  // MARK: Private Class Properties
  
  private static let visibility : [SwitchBoardItemType:OpenLCBNodeVisibility] = [
    .straight           : .visibilityInternal,
    .curve              : .visibilityInternal,
    .longCurve          : .visibilityInternal,
    .turnoutRight       : .visibilitySemiPublic,
    .turnoutLeft        : .visibilitySemiPublic,
    .cross              : .visibilityInternal,
    .diagonalCross      : .visibilityInternal,
    .yTurnout           : .visibilitySemiPublic,
    .turnout3Way        : .visibilitySemiPublic,
    .leftCurvedTurnout  : .visibilitySemiPublic,
    .rightCurvedTurnout : .visibilitySemiPublic,
    .singleSlip         : .visibilitySemiPublic,
    .doubleSlip         : .visibilitySemiPublic,
    .buffer             : .visibilityInternal,
    .block              : .visibilitySemiPublic,
    .sensor             : .visibilitySemiPublic,
    .link               : .visibilityInternal,
    .platform           : .visibilityInternal,
    .signal             : .visibilitySemiPublic,
    .none               : .visibilityNone,
  ]
  
  private static let connections : [SwitchBoardItemType:[SwitchBoardConnection]] = [
    .straight           : [(5, 1, [])],
    .curve              : [(5, 3, [])],
    .longCurve          : [(5, 2, [])],
    .turnoutRight       : [(5, 1, [(1, .closed)]),(5, 2, [(1, .thrown)])],
    .turnoutLeft        : [(5, 1, [(1, .closed)]),(5, 0, [(1, .thrown)])],
    .cross              : [(7, 3, []),(5, 1, [])],
    .diagonalCross      : [(0, 4, []),(5, 1, [])],
    .yTurnout           : [(5, 0, [(1, .closed)]),(5, 2, [(1, .thrown)])],
    .turnout3Way        : [(5, 0, [(1, .thrown), (2, .closed)]),(5, 1, [(1, .closed), (2, .closed)]),(5, 2, [(1, .thrown), (2, .thrown)])],
    .leftCurvedTurnout  : [(5, 7, [(1, .thrown)]),(5, 0, [(1, .closed)])],
    .rightCurvedTurnout : [(5, 3, [(1, .closed)]),(5, 2, [(1, .thrown)])],
    .singleSlip         : [(0, 4, [(1, .closed)]),(5, 1, [(1, .closed)]),(4, 1, [(1, .thrown)])],
    .doubleSlip         : [(0, 4, [(1, .closed), (2, .closed)]),
                           (5, 1, [(1, .closed), (2, .closed)]),
                           (4, 1, [(1, .thrown), (2, .thrown)]),
                           (5, 0, [(1, .thrown), (2, .thrown)])],
    .buffer             : [(5, -1, [])],
    .block              : [(5, 1, [])],
    .sensor             : [(5, 1, [])],
    .link               : [(5, -1, [])],
    .platform           : [],
    .signal             : [],
    .none               : [],
  ]
  
  private static let titles = [
    String(localized: "Straight Track", comment: "This is used to describe a piece of track."),
    String(localized: "Curved Track", comment: "This is used to describe a piece of track."),
    String(localized: "Long Curved Track", comment: "This is used to describe a piece of track."),
    String(localized: "Turnout Right", comment: "This is used to describe a piece of track."),
    String(localized: "Turnout Left", comment: "This is used to describe a piece of track."),
    String(localized: "Cross", comment: "This is used to describe a piece of track."),
    String(localized: "Diagonal Cross", comment: "This is used to describe a piece of track."),
    String(localized: "Y Turnout", comment: "This is used to describe a piece of track."),
    String(localized: "3-Way Turnout", comment: "This is used to describe a piece of track."),
    String(localized: "Left Curved Turnout", comment: "This is used to describe a piece of track."),
    String(localized: "Right Curved Turnout", comment: "This is used to describe a piece of track."),
    String(localized: "Single Slip", comment: "This is used to describe a piece of track."),
    String(localized: "Double Slip", comment: "This is used to describe a piece of track."),
    String(localized: "Buffer Stop", comment: "This is used to describe a piece of track."),
    String(localized: "Block", comment: "This is used to describe a piece of track."),
    String(localized: "Sensor", comment: "This is used to describe a switchboard item."),
    String(localized: "Link", comment: "This is used to describe a switchboard item."),
    String(localized: "Platform", comment: "This is used to describe a switchboard item."),
    String(localized: "Signal", comment: "This is used to describe a switchboard item."),
  ]
  
  // MARK: Public Class Properties
  
  public static let defaultValue : SwitchBoardItemType = .straight

  // MARK: Private Class Methods
  
  private static var map : String {
    
    let items : [SwitchBoardItemType] = [
      .straight,
      .curve,
      .longCurve,
      .turnoutRight,
      .turnoutLeft,
      .cross,
      .diagonalCross,
      .yTurnout,
      .turnout3Way,
      .leftCurvedTurnout,
      .rightCurvedTurnout,
      .singleSlip,
      .doubleSlip,
      .buffer,
      .block,
      .sensor,
      .link,
      .platform,
      .signal,
    ]
    
    var map = "<default>\(defaultValue.rawValue)</default>\n<map>\n"

    for item in items {
      map += "<relation><property>\(item.rawValue)</property><value>\(item.title)</value></relation>\n"
    }

    map += "</map>\n"

    return map

  }

  // MARK: Public Class Methods
  
  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
  }
  
  public static func select(comboBox: NSComboBox, partType:SwitchBoardItemType) {
    comboBox.selectItem(at: Int(partType.rawValue))
  }
  
  public static func selected(comboBox: NSComboBox) -> SwitchBoardItemType {
    return SwitchBoardItemType(rawValue: UInt16(comboBox.indexOfSelectedItem)) ?? .none
  }
  
  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: CDI.SWITCHBOARD_ITEM_TYPE, with: map)
  }

}

