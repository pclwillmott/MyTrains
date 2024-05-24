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
  
  // MARK: Enumeration
  
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
  
  public var quickHelpSummary : String {
    switch self {
    case .straight, .curve, .longCurve:
      return String(localized: "This item is used to connect items to other items. This item is used to connect items to other items. This item is used to connect items to other items. This item is used to connect items to other items. This item is used to connect items to other items.")
    case .turnoutRight:
      return String(localized: "")
    case .turnoutLeft:
      return String(localized: "")
    case .cross:
      return String(localized: "")
    case .diagonalCross:
      return String(localized: "")
    case .yTurnout:
      return String(localized: "")
    case .turnout3Way:
      return String(localized: "")
    case .leftCurvedTurnout:
      return String(localized: "")
    case .rightCurvedTurnout:
      return String(localized: "")
    case .singleSlip:
      return String(localized: "")
    case .doubleSlip:
      return String(localized: "")
    case .buffer:
      return String(localized: "")
    case .block:
      return String(localized: "")
    case .sensor:
      return String(localized: "")
    case .link:
      return String(localized: "")
    case .platform:
      return String(localized: "")
    case .signal:
      return String(localized: "")
    case .none:
      return String(localized: "")
    }
  }
  
  public var quickHelpDiscussion : String {
    switch self {
    case .straight, .curve, .longCurve:
      return String(localized: "The only purpose of this item is to connect items to other items.")
    case .turnoutRight:
      return String(localized: "")
    case .turnoutLeft:
      return String(localized: "")
    case .cross:
      return String(localized: "")
    case .diagonalCross:
      return String(localized: "")
    case .yTurnout:
      return String(localized: "")
    case .turnout3Way:
      return String(localized: "")
    case .leftCurvedTurnout:
      return String(localized: "")
    case .rightCurvedTurnout:
      return String(localized: "")
    case .singleSlip:
      return String(localized: "")
    case .doubleSlip:
      return String(localized: "")
    case .buffer:
      return String(localized: "")
    case .block:
      return String(localized: "")
    case .sensor:
      return String(localized: "")
    case .link:
      return String(localized: "")
    case .platform:
      return String(localized: "")
    case .signal:
      return String(localized: "")
    case .none:
      return String(localized: "")
    }
  }
  
  public var properties : Set<LayoutInspectorProperty> {
    var result : Set<LayoutInspectorProperty> = [
      .panelId,
      .panelName,
      .itemType,
      .itemId,
      .name,
      .description,
      .xPos,
      .yPos,
      .orientation,
      .groupId,
    ]
    switch self {
    case .straight:
      break
    case .curve:
      break
    case .longCurve:
      break
    case .turnoutRight:
      result = result.union([
        .lengthRoute1,
        .lengthRoute2,
        .turnoutMotorType1,
        .sw1CloseEventId,
        .sw1ThrowEventId,
        .sw1ClosedEventId,
        .sw1ThrownEventId,
        ])
    case .turnoutLeft:
      result = result.union([
        .lengthRoute1,
        .lengthRoute2,
        .turnoutMotorType1,
        .sw1CloseEventId,
        .sw1ThrowEventId,
        .sw1ClosedEventId,
        .sw1ThrownEventId,
      ])
    case .cross:
      result = result.union([
        .lengthRoute1,
        .lengthRoute2,
      ])
    case .diagonalCross:
      result = result.union([
        .lengthRoute1,
        .lengthRoute2,
      ])
    case .yTurnout:
      result = result.union([
        .lengthRoute1,
        .lengthRoute2,
        .turnoutMotorType1,
        .sw1CloseEventId,
        .sw1ThrowEventId,
        .sw1ClosedEventId,
        .sw1ThrownEventId,
      ])
    case .turnout3Way:
      result = result.union([
        .lengthRoute1,
        .lengthRoute2,
        .lengthRoute3,
        .turnoutMotorType1,
        .turnoutMotorType2,
        .sw1CloseEventId,
        .sw1ThrowEventId,
        .sw1ClosedEventId,
        .sw1ThrownEventId,
        .sw2CloseEventId,
        .sw2ThrowEventId,
        .sw2ClosedEventId,
        .sw2ThrownEventId,
      ])
    case .leftCurvedTurnout:
      result = result.union([
        .lengthRoute1,
        .lengthRoute2,
        .turnoutMotorType1,
        .sw1CloseEventId,
        .sw1ThrowEventId,
        .sw1ClosedEventId,
        .sw1ThrownEventId,
      ])
    case .rightCurvedTurnout:
      result = result.union([
        .lengthRoute1,
        .lengthRoute2,
        .turnoutMotorType1,
        .sw1CloseEventId,
        .sw1ThrowEventId,
        .sw1ClosedEventId,
        .sw1ThrownEventId,
      ])
    case .singleSlip:
      result = result.union([
      ])
    case .doubleSlip:
      result = result.union([
      ])
    case .buffer:
      break
    case .block:
      result = result.union([
        .directionality,
        .allowShunt,
        .electrification,
        .isCriticalSection,
        .isHiddenSection,
        .trackGradient,
        .trackGauge,
        .lengthRoute1,
      ])
    case .sensor:
      result = result.union([
        .sensorType,
        .sensorPosition,
        .sensorActivateLatency,
        .sensorDeactivateLatency,
        .sensorActivatedEventId,
        .sensorDeactivatedEventId,
        .sensorLocationServicesEventId,
      ])
    case .link:
      result = result.union([
        .link,
      ])
    case .platform:
      break
    case .signal:
      result = result.union([
        .signalType,
        .signalRouteDirection,
        .signalPosition,
        .signalSetState0EventId,
        .signalSetState1EventId,
        .signalSetState2EventId,
        .signalSetState3EventId,
        .signalSetState4EventId,
        .signalSetState5EventId,
        .signalSetState6EventId,
        .signalSetState7EventId,
        .signalSetState8EventId,
        .signalSetState9EventId,
        .signalSetState10EventId,
        .signalSetState11EventId,
        .signalSetState12EventId,
        .signalSetState13EventId,
        .signalSetState14EventId,
        .signalSetState15EventId,
        .signalSetState16EventId,
        .signalSetState17EventId,
        .signalSetState18EventId,
        .signalSetState19EventId,
        .signalSetState20EventId,
        .signalSetState21EventId,
        .signalSetState22EventId,
        .signalSetState23EventId,
        .signalSetState24EventId,
        .signalSetState25EventId,
        .signalSetState26EventId,
        .signalSetState27EventId,
        .signalSetState28EventId,
        .signalSetState29EventId,
        .signalSetState30EventId,
        .signalSetState31EventId,
      ])
    case .none:
      break
    }
    if isGroup {
      result = result.union([
        .enterDetectionZoneEventId,
        .exitDetectionZoneEventId,
        .enterTranspondingZoneEventId,
        .exitTranspondingZoneEventId,
        .trackFaultEventId,
        .trackFaultClearedEventId,
        .locationServicesEventId,
        .speedConstraintDNType0,
        .speedConstraintDNValue0,
        .speedConstraintDPType0,
        .speedConstraintDPValue0,
        .speedConstraintDNType1,
        .speedConstraintDNValue1,
        .speedConstraintDPType1,
        .speedConstraintDPValue1,
        .speedConstraintDNType3,
        .speedConstraintDNValue3,
        .speedConstraintDPType3,
        .speedConstraintDPValue3,
        .speedConstraintDNType4,
        .speedConstraintDNValue4,
        .speedConstraintDPType4,
        .speedConstraintDPValue4,
        .speedConstraintDNType5,
        .speedConstraintDNValue5,
        .speedConstraintDPType5,
        .speedConstraintDPValue5,
        .speedConstraintDNType6,
        .speedConstraintDNValue6,
        .speedConstraintDPType6,
        .speedConstraintDPValue6,
        .speedConstraintDNType7,
        .speedConstraintDNValue7,
        .speedConstraintDPType7,
        .speedConstraintDPValue7,
        .speedConstraintDNType8,
        .speedConstraintDNValue8,
        .speedConstraintDPType8,
        .speedConstraintDPValue8,
        .speedConstraintDNType9,
        .speedConstraintDNValue9,
        .speedConstraintDPType9,
        .speedConstraintDPValue9,
        .speedConstraintDNType10,
        .speedConstraintDNValue10,
        .speedConstraintDPType10,
        .speedConstraintDPValue10,
        .speedConstraintDNType11,
        .speedConstraintDNValue11,
        .speedConstraintDPType11,
        .speedConstraintDPValue11,
        .speedConstraintDNType12,
        .speedConstraintDNValue12,
        .speedConstraintDPType12,
        .speedConstraintDPValue12,
        .speedConstraintDNType13,
        .speedConstraintDNValue13,
        .speedConstraintDPType13,
        .speedConstraintDPValue13,
        .speedConstraintDNType14,
        .speedConstraintDNValue14,
        .speedConstraintDPType14,
        .speedConstraintDPValue14,
        .speedConstraintDNType15,
        .speedConstraintDNValue15,
        .speedConstraintDPType15,
        .speedConstraintDPValue15,
      ])
    }
    return result
  }
  
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
  
  public var requireUniqueName : Bool {
    return self == .link || isBlock || isTurnout
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

