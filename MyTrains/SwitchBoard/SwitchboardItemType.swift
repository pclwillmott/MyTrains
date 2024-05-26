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

public enum SwitchboardItemType : UInt16 {
  
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
    var result = ""
    switch self {
    case .straight, .curve, .longCurve:
      result += String(localized: "This item is used to connect items to other items.")
    case .turnoutRight:
      result += String(localized: "This item defines the properties and control methodology for a right hand turnout.")
    case .turnoutLeft:
      result += String(localized: "This item defines the properties and control methodology for a left hand turnout.")
    case .cross:
      result += String(localized: "This item defines the properties for a crossing.")
    case .diagonalCross:
      result += String(localized: "This item defines the properties for a diagonal crossing.")
    case .yTurnout:
      result += String(localized: "This item defines the properties and control methodology for a Y turnout.")
    case .turnout3Way:
      result += String(localized: "This item defines the properties and control methodology for a 3-way turnout.")
    case .leftCurvedTurnout:
      result += String(localized: "This item defines the properties and control methodology for a left curved turnout.")
    case .rightCurvedTurnout:
      result += String(localized: "This item defines the properties and control methodology for a right curved turnout.")
    case .singleSlip:
      result += String(localized: "This item defines the properties and control methodology for a single slip turnout.")
    case .doubleSlip:
      result += String(localized: "This item defines the properties and control methodology for a double slip turnout.")
    case .buffer:
      result += String(localized: "The buffer stop item is used to indicate the end of a line or siding in the panel view.")
    case .block:
      result += String(localized: "The block item defines the properties of a block of track.")
    case .sensor:
      result += String(localized: "A sensor item defines the properties of a sensor or button associated with a block of track.")
    case .link:
      result += String(localized: "A link item is primarily used to connect switchboard panels. They may also be used to implement track layouts where one track goes over or under another track.")
    case .platform:
      result += String(localized: "The platform item is used to indicate the position of a platform in the panel view.")
    case .signal:
      return String(localized: "")
    case .none:
      return String(localized: "")
    }
    return result
  }
  
  public var quickHelpDiscussion : String {
    var result = ""
    
    if self.isTurnout {
      result += String(localized: "This item is used to configure a turnout or crossing. Each turnout or crossing item must be given a unique name.\n\nElectric trains can only run on electrified track of the correct type. Select the appropriate electrification type. Diesel and Electro-Diesel trains can run on any type of track.\n\nA \"Hidden Section\" is a block of track that is not in the scenic area of the layout, such as a fiddle yard. The application may turn off a train's sound effects in hidden sections.\n\nThe \"Track Gradient\" is used when calculating a train's speed when on an incline. The application determines what routes are available on the layout by examining the connections between switchboard items. If two adjacent tracks have different track guages they will not be connected together. The route lengths are simply the physical lengths of the different routes through the turnout or crossing. These dimensions are critical values for automatic train control so try and be as accurate as possible. A piece of rope is very useful for curved routes. You can select your preferred units of length in the application preferences.\n\n")
    }
    
    switch self {
    case .straight, .curve, .longCurve:
      result += String(localized: "The only purpose of this item is to connect items to other items. A track group may contain multiple instances of this item type.")
    case .turnoutRight:
      result += String(localized: "A right hand turnout is controlled with a single switch. Select the applicable turnout control method - manual, solenoid, or slow motion. The application requires this information for timing purposes. If the turnout is to be controlled by the application then the enter the applicable event ids for the throw and close actions. These events will be sent to the node controlling the switch when the application needs to change the selected route throgh the turnout. The thrown and closed events are sent by a node monitoring the current state of the turnout to tell the application that a throw or close action was successful. If no node is monitoring the state of the turnout then leave these events blank and the application will assume that all throw and close actions are always successful. ")
    case .turnoutLeft:
      result += String(localized: "A left hand turnout is controlled with a single switch. Select the applicable turnout control method - manual, solenoid, or slow motion. The application requires this information for timing purposes. If the turnout is to be controlled by the application then the enter the applicable event ids for the throw and close actions. These events will be sent to the node controlling the switch when the application needs to change the selected route throgh the turnout. The thrown and closed events are sent by a node monitoring the current state of the turnout to tell the application that a throw or close action was successful. If no node is monitoring the state of the turnout then leave these events blank and the application will assume that all throw and close actions are always successful. ")
    case .cross:
      result += String(localized: "")
    case .diagonalCross:
      result += String(localized: "")
    case .yTurnout:
      result += String(localized: "A Y turnout is controlled with a single switch. Select the applicable turnout control method - manual, solenoid, or slow motion. The application requires this information for timing purposes. If the turnout is to be controlled by the application then the enter the applicable event ids for the throw and close actions. These events will be sent to the node controlling the switch when the application needs to change the selected route throgh the turnout. The thrown and closed events are sent by a node monitoring the current state of the turnout to tell the application that a throw or close action was successful. If no node is monitoring the state of the turnout then leave these events blank and the application will assume that all throw and close actions are always successful. ")
    case .turnout3Way:
      result += String(localized: "A 3-way turnout is controlled with two switches. Switch #1 is the switch nearest the toe of the turnout. Select the applicable turnout control methods - manual, solenoid, or slow motion. The application requires this information for timing purposes. If the turnout is to be controlled by the application then the enter the applicable event ids for the throw and close actions. These events will be sent to the node controlling the switch when the application needs to change the selected route throgh the turnout. The thrown and closed events are sent by a node monitoring the current state of the turnout to tell the application that a throw or close action was successful. If no node is monitoring the state of the turnout then leave these events blank and the application will assume that all throw and close actions are always successful. ")
    case .leftCurvedTurnout:
      result += String(localized: "A left curved turnout is controlled with a single switch. Select the applicable turnout control method - manual, solenoid, or slow motion. The application requires this information for timing purposes. If the turnout is to be controlled by the application then the enter the applicable event ids for the throw and close actions. These events will be sent to the node controlling the switch when the application needs to change the selected route throgh the turnout. The thrown and closed events are sent by a node monitoring the current state of the turnout to tell the application that a throw or close action was successful. If no node is monitoring the state of the turnout then leave these events blank and the application will assume that all throw and close actions are always successful. ")
    case .rightCurvedTurnout:
      result += String(localized: "A right hand turnout is controlled with a single switch. Select the applicable turnout control method - manual, solenoid, or slow motion. The application requires this information for timing purposes. If the turnout is to be controlled by the application then the enter the applicable event ids for the throw and close actions. These events will be sent to the node controlling the switch when the application needs to change the selected route throgh the turnout. The thrown and closed events are sent by a node monitoring the current state of the turnout to tell the application that a throw or close action was successful. If no node is monitoring the state of the turnout then leave these events blank and the application will assume that all throw and close actions are always successful. ")
    case .singleSlip:
      result += String(localized: "")
    case .doubleSlip:
      result += String(localized: "")
    case .buffer:
      result += String(localized: "The buffer stop item serves no other purpose.")
    case .block:
      result += String(localized: "The block item is used to configure a block of track. Each block item must be given a unique name. A block of track consists or a single block item and zero or more other items, such as connecting items (straight tracks, curves, etc.), sensors, and signals. Items are added and removed from a block of track using the Layout Builder in \"Grouping Mode\".\n\nA block has a direction, the exit direction of the block is marked with a small dot. The exit direction is called \"Direction Next\" and the entry direction is called \"Direction Previous\". A block of track can be either unidirectional or bidirectional. When a block is set to unidirectional trains may only move from \"Direction Previous\" to \"Direction Next\". Use the rotate buttons in \"Arrange Mode\" to set the correct orientation of the block. When a block is set to bidirectional trains may move in both directions in the block. Note that the directionality of the block relates to the physical direction of the track not the direction the train may be operating (forward or reverse).\n\nNormally only one train is allowed in a block at any time. An exception to this rule is allowed for low speed shunting at stations and yards. If you want to allow multiple trains to be present in a block for shunting purposes check the \"Allow Shunt\" box.\n\nElectric trains can only run on electrified track of the correct type. Select the appropriate electrification type. Diesel and Electro-Diesel trains can run on any type of track.\n\nA \"Hidden Section\" is a block of track that is not in the scenic area of the layout, such as a fiddle yard. The application may turn off a train's sound effects in hidden sections.\n\nThe \"Track Gradient\" is used when calculating a train's speed when on an incline. The application determines what routes are available on the layout by examining the connections between switchboard items. If two blocks have different track guages they will not be connected together. The length of the route is simply the physical length of the track from the end of the last block to the start of the next block or buffer stop. This dimension is a critical value for automatic train control so try and be as accurate as possible. A piece of rope is very useful for curved track sections. You can select your preferred units of length in the application preferences.\n\nThe current state of the block is set by listening for specific LCC/OpenLCB event messages. Each event has a unique id. You can enter the event ids applicable to the block in the \"Events Inspector\". The \"New\" button may be used to get a new event id from the application's pool of event ids. The copy and paste buttons are provided as a convenience for copying event ids to and/or from a configuration tool.\n\nThe speed limits applicable for the specific block can be set by using the \"Speed Constraints Inspector\". Any speed constraints set for the block will override any speed constraints set as layout properties. You can set your preferred units of speed in the application preferences. Different speed constarints can be set for \"Direction Next\" and \"Direction Previous\".")
    case .sensor:
      result += String(localized: "There are 5 types of sensor supported: light sensor, reed switch, RFID reader, push button, and other. The sensor's position is the distance from the start of the block (the \"Direction Previous\" end). You can set your preferred units of distance in the application preferences.\n\nLatency is the time between something happening and the report that something happened is received by the application. Many things can influence latency, including switch debouncing and network arbitration. The activate and deactive latency settings are used to fine tune train position determination.\n\nThe current state of the sensor is set by listening for specific LCC/OpenLCB event messages. Each event has a unique id. You can enter the event ids applicable to the sensor in the \"Events Inspector\". The \"New\" button may be used to get a new event id from the application's pool of event ids. The copy and paste buttons are provided as a convenience for copying event ids to and/or from a configuration tool.")
    case .link:
      result += String(localized: "A layout is defined by one or more switchboard panels. A small layout may only require a single panel. Larger layouts will require more than one panel. A panel may be viewed as a single signal box, interlocking tower, or signal cabin. All the items relating to the operation of that box, tower, or cabin are defined on the panel. Where a track exits the operational area of a panel it moves to the operational area of another panel. This is what link items are used for. The link tells the application that the track continues at the next link. Links may be connected to only one other link. To connect 2 tracks on different panels, first create a link on both panels, then connect each link to each other.\n\nLayout Builder does not allow more than 1 item to be placed in the same panel grid square. If you have tracks the run over or under another track (e.g. bridges and tunnels), then use links on each side of the track being crossed to implement the crossing.")
    case .platform:
      result += String(localized: "The platform item serves no other purpose.")
    case .signal:
      result += String(localized: "")
    case .none:
      result += String(localized: "")
    }
    
    if self.isTurnout {
      result += String(localized: "Each event has a unique id. You can enter the event ids applicable to the turnout or crossing in the \"Events Inspector\". The \"New\" button may be used to get a new event id from the application's pool of event ids. The copy and paste buttons are provided as a convenience for copying event ids to and/or from a configuration tool.\n\nThe speed limits applicable for the specific turnout or crossing can be set by using the \"Speed Constraints Inspector\". Any speed constraints set for the turnout or crossing will override any speed constraints set as layout properties. You can set your preferred units of speed in the application preferences. Different speed constarints can be set for \"Direction Next\" and \"Direction Previous\". \"Direction Next\" and \"Direction Previous\" are defined by the blocks of track connected to the turnout or crossing.")
    }

    return result
    
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
        .rightThroughRoute,
        .rightDivergingRoute,
        .turnoutMotorType1,
        .sw1CloseEventId,
        .sw1ThrowEventId,
        .sw1ClosedEventId,
        .sw1ThrownEventId,
        ])
    case .turnoutLeft:
      result = result.union([
        .leftThroughRoute,
        .leftDivergingRoute,
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
        .yLeftDivergingRoute,
        .yRightDivergingRoute,
        .turnoutMotorType1,
        .sw1CloseEventId,
        .sw1ThrowEventId,
        .sw1ClosedEventId,
        .sw1ThrownEventId,
      ])
    case .turnout3Way:
      result = result.union([
        .way3LeftDivergingRoute,
        .way3ThroughRoute,
        .way3RightDivergingRoute,
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
        .leftCurvedLargerRadiusRoute,
        .leftCurvedSmallerRadiusRoute,
        .turnoutMotorType1,
        .sw1CloseEventId,
        .sw1ThrowEventId,
        .sw1ClosedEventId,
        .sw1ThrownEventId,
      ])
    case .rightCurvedTurnout:
      result = result.union([
        .rightCurvedLargerRadiusRoute,
        .rightCurvedSmallerRadiusRoute,
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
        .rightThroughRoute,
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
        .electrification,
        .isCriticalSection,
        .isHiddenSection,
        .trackGradient,
        .trackGauge,
        .enterDetectionZoneEventId,
        .exitDetectionZoneEventId,
   //     .enterTranspondingZoneEventId,
   //     .exitTranspondingZoneEventId,
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
    guard let result = SwitchboardItemType.visibility[self] else {
      return .visibilityNone
    }
    return result
  }
  
  public var isTurnout : Bool {
  
    let turnouts : Set<SwitchboardItemType> = [
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
    return self == .link || isBlock || isTurnout || self == .signal
  }

  public var isBlock : Bool {
  
    let blocks : Set<SwitchboardItemType> = [
      .block,
    ]
    
    return blocks.contains(self)
    
  }
  
  public var isGroup : Bool {
    return isTurnout || isBlock
  }

  public var title : String {
    return self == .none ? String(localized: "None") : SwitchboardItemType.titles[Int(self.rawValue)]
  }
  
  public var connections : [SwitchBoardConnection] {
    get {
      return SwitchboardItemType.connections[self] ?? []
    }
  }
  
  public var numberOfDimensionsRequired : Int {
    if isGroup, let connections = SwitchboardItemType.connections[self] {
      return connections.count
    }
    return 0
  }
  
  public var numberOfTurnoutSwitches : Int {
    var used : Set<Int> = []
    if let connections = SwitchboardItemType.connections[self] {
      for connection in connections {
        for item in connection.switchSettings {
          used.insert(item.switchNumber)
        }
      }
    }
    return used.count
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
  
  private static let visibility : [SwitchboardItemType:OpenLCBNodeVisibility] = [
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
  
  private static let connections : [SwitchboardItemType:[SwitchBoardConnection]] = [
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
  
  public static let defaultValue : SwitchboardItemType = .straight

  // MARK: Private Class Methods
  
  private static var map : String {
    
    let items : [SwitchboardItemType] = [
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
  
  public static func select(comboBox: NSComboBox, partType:SwitchboardItemType) {
    comboBox.selectItem(at: Int(partType.rawValue))
  }
  
  public static func selected(comboBox: NSComboBox) -> SwitchboardItemType {
    return SwitchboardItemType(rawValue: UInt16(comboBox.indexOfSelectedItem)) ?? .none
  }
  
  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: CDI.SWITCHBOARD_ITEM_TYPE, with: map)
  }

}

