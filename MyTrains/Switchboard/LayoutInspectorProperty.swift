//
//  LayoutInspectorProperty.swift
//  MyTrains
//
//  Created by Paul Willmott on 22/04/2024.
//

import Foundation
import AppKit

/// The value of zero is reserved as a trap for unintialized fields. The actual rawValues have no purpose
/// other than to uniquely identify the property and its label. Where a field is overloaded between
/// switchboard item types a separate property is required if the function or label is different between
/// the item types; a single item property may map to multiple LayoutInspectorProperty values.

public enum LayoutInspectorProperty : Int, CaseIterable {
  
  // MARK: Enumeration
  
  // Information Inspector
  /// Identity
  case panelId                       = 1
  case panelName                     = 2
  case itemType                      = 3
  case itemId                        = 4
  
  // Attributes Inspector
  /// General Settings
  case name                          = 5
  case description                   = 6
  case xPos                          = 7
  case yPos                          = 8
  case orientation                   = 9
  case groupId                       = 10
  /// Block Settings
  case directionality                = 11
  case allowShunt                    = 12
  case electrification               = 13
  case isCriticalSection             = 14
  case isHiddenSection               = 15
  /// Track Configuration
  case trackGradient                 = 16
  case trackGauge                    = 17
  case lengthRoute1                  = 18
  case leftDivergingRoute            = 160
  case rightThroughRoute             = 162
  case yLeftDivergingRoute           = 164
  case way3LeftDivergingRoute        = 166
  case leftCurvedSmallerRadiusRoute  = 169
  case rightCurvedLargerRadiusRoute  = 171
  case lengthRoute2                  = 19
  case leftThroughRoute              = 161
  case rightDivergingRoute           = 163
  case yRightDivergingRoute          = 165
  case way3ThroughRoute              = 167
  case leftCurvedLargerRadiusRoute   = 170
  case rightCurvedSmallerRadiusRoute = 172
  case lengthRoute3                  = 20
  case way3RightDivergingRoute       = 168
  case lengthRoute4                  = 21
  case lengthRoute5                  = 22
  case lengthRoute6                  = 23
  case lengthRoute7                  = 24
  case lengthRoute8                  = 25
  case link                          = 26
  /// Turnout Control
  case turnoutMotorType1             = 27
  case turnoutMotorType2             = 28
  case turnoutMotorType3             = 29
  case turnoutMotorType4             = 30
  /// Sensor Settings
  case sensorType                    = 31
  case sensorPosition                = 32
  case sensorActivateLatency         = 33
  case sensorDeactivateLatency       = 34
  /// Signal Settings
  case signalType                    = 35
  case signalRouteDirection          = 36
  case signalPosition                = 37

  // Events
  /// Block Events
  case enterDetectionZoneEventId     = 38
  case blockDoNotUseForSpeedProfile  = 190
  case exitDetectionZoneEventId      = 39
  case enterTranspondingZoneEventId  = 40
  case exitTranspondingZoneEventId   = 41
  case locationServicesEventId       = 44
  case trackFaultEventId             = 42
  case trackFaultClearedEventId      = 43
  /// Turnout Events
  case sw1ThrowEventId               = 45
  case sw1CommandedThrownEventId     = 173
  case sw1ThrownEventId              = 47
  case sw1NotThrownEventId           = 181
  case sw1CloseEventId               = 46
  case sw1CommandedClosedEventId     = 177
  case sw1ClosedEventId              = 48
  case sw1NotClosedEventId           = 185
  case sw2ThrowEventId               = 49
  case sw2CommandedThrownEventId     = 174
  case sw2ThrownEventId              = 51
  case sw2NotThrownEventId           = 182
  case sw2CloseEventId               = 50
  case sw2CommandedClosedEventId     = 178
  case sw2ClosedEventId              = 52
  case sw2NotClosedEventId           = 186
  case sw3ThrowEventId               = 53
  case sw3CommandedThrownEventId     = 175
  case sw3ThrownEventId              = 55
  case sw3NotThrownEventId           = 183
  case sw3CloseEventId               = 54
  case sw3CommandedClosedEventId     = 179
  case sw3ClosedEventId              = 56
  case sw3NotClosedEventId           = 187
  case sw4ThrowEventId               = 57
  case sw4CommandedThrownEventId     = 176
  case sw4ThrownEventId              = 59
  case sw4NotThrownEventId           = 184
  case sw4CloseEventId               = 58
  case sw4CommandedClosedEventId     = 180
  case sw4ClosedEventId              = 60
  case sw4NotClosedEventId           = 188
  /// Sensor Events
  case sensorActivatedEventId        = 61
  case sensorDoNotUseForSpeedProfile = 189
  case sensorDeactivatedEventId      = 62
  case sensorLocationServicesEventId = 63
  /// Signal Events
  case signalSetState0EventId        = 64
  case signalSetState1EventId        = 65
  case signalSetState2EventId        = 66
  case signalSetState3EventId        = 67
  case signalSetState4EventId        = 68
  case signalSetState5EventId        = 69
  case signalSetState6EventId        = 70
  case signalSetState7EventId        = 71
  case signalSetState8EventId        = 72
  case signalSetState9EventId        = 73
  case signalSetState10EventId       = 74
  case signalSetState11EventId       = 75
  case signalSetState12EventId       = 76
  case signalSetState13EventId       = 77
  case signalSetState14EventId       = 78
  case signalSetState15EventId       = 79
  case signalSetState16EventId       = 80
  case signalSetState17EventId       = 81
  case signalSetState18EventId       = 82
  case signalSetState19EventId       = 83
  case signalSetState20EventId       = 84
  case signalSetState21EventId       = 85
  case signalSetState22EventId       = 86
  case signalSetState23EventId       = 87
  case signalSetState24EventId       = 88
  case signalSetState25EventId       = 89
  case signalSetState26EventId       = 90
  case signalSetState27EventId       = 91
  case signalSetState28EventId       = 92
  case signalSetState29EventId       = 93
  case signalSetState30EventId       = 94
  case signalSetState31EventId       = 95

  // Speed Constraints
  /// Direction Previous
  case speedConstraintDPType0        = 96
  case speedConstraintDPValue0       = 97
  case speedConstraintDPType1        = 98
  case speedConstraintDPValue1       = 99
  case speedConstraintDPType2        = 100
  case speedConstraintDPValue2       = 101
  case speedConstraintDPType3        = 102
  case speedConstraintDPValue3       = 103
  case speedConstraintDPType4        = 104
  case speedConstraintDPValue4       = 105
  case speedConstraintDPType5        = 106
  case speedConstraintDPValue5       = 107
  case speedConstraintDPType6        = 108
  case speedConstraintDPValue6       = 109
  case speedConstraintDPType7        = 110
  case speedConstraintDPValue7       = 111
  case speedConstraintDPType8        = 112
  case speedConstraintDPValue8       = 113
  case speedConstraintDPType9        = 114
  case speedConstraintDPValue9       = 115
  case speedConstraintDPType10       = 116
  case speedConstraintDPValue10      = 117
  case speedConstraintDPType11       = 118
  case speedConstraintDPValue11      = 119
  case speedConstraintDPType12       = 120
  case speedConstraintDPValue12      = 121
  case speedConstraintDPType13       = 122
  case speedConstraintDPValue13      = 123
  case speedConstraintDPType14       = 124
  case speedConstraintDPValue14      = 125
  case speedConstraintDPType15       = 126
  case speedConstraintDPValue15      = 127
  /// Direction Next
  case speedConstraintDNType0        = 128
  case speedConstraintDNValue0       = 129
  case speedConstraintDNType1        = 130
  case speedConstraintDNValue1       = 131
  case speedConstraintDNType2        = 132
  case speedConstraintDNValue2       = 133
  case speedConstraintDNType3        = 134
  case speedConstraintDNValue3       = 135
  case speedConstraintDNType4        = 136
  case speedConstraintDNValue4       = 137
  case speedConstraintDNType5        = 138
  case speedConstraintDNValue5       = 139
  case speedConstraintDNType6        = 140
  case speedConstraintDNValue6       = 141
  case speedConstraintDNType7        = 142
  case speedConstraintDNValue7       = 143
  case speedConstraintDNType8        = 144
  case speedConstraintDNValue8       = 145
  case speedConstraintDNType9        = 146
  case speedConstraintDNValue9       = 147
  case speedConstraintDNType10       = 148
  case speedConstraintDNValue10      = 149
  case speedConstraintDNType11       = 150
  case speedConstraintDNValue11      = 151
  case speedConstraintDNType12       = 152
  case speedConstraintDNValue12      = 153
  case speedConstraintDNType13       = 154
  case speedConstraintDNValue13      = 155
  case speedConstraintDNType14       = 156
  case speedConstraintDNValue14      = 157
  case speedConstraintDNType15       = 158
  case speedConstraintDNValue15      = 159
  
  // MARK: Public Properties
  
  /// This will cause a runtime error if the lookup is not defined - this is the intent!
  public var label : String {
    guard let appNode else {
      return ""
    }
    var result = LayoutInspectorProperty.labels[self]!.labelTitle
    result = result.replacingOccurrences(of: "%%UNITS_ACTUAL_LENGTH%%", with: appNode.unitsActualLength.symbol)
    result = result.replacingOccurrences(of: "%%UNITS_SCALE_LENGTH%%", with: appNode.unitsScaleLength.symbol)
    result = result.replacingOccurrences(of: "%%UNITS_ACTUAL_DISTANCE%%", with: appNode.unitsActualDistance.symbol)
    result = result.replacingOccurrences(of: "%%UNITS_SCALE_DISTANCE%%", with: appNode.unitsScaleDistance.symbol)
    result = result.replacingOccurrences(of: "%%UNITS_ACTUAL_SPEED%%", with: appNode.unitsActualSpeed.symbol)
    result = result.replacingOccurrences(of: "%%UNITS_SCALE_SPEED%%", with: appNode.unitsScaleSpeed.symbol)
    result = result.replacingOccurrences(of: "%%UNITS_TIME%%", with: appNode.unitsTime.symbol)
    return result
  }
  
  /// This will cause a runtime error if the lookup is not defined - this is the intent!
  public var toolTip : String {
    return LayoutInspectorProperty.labels[self]!.toolTip
  }

  /// This will cause a runtime error if the lookup is not defined - this is the intent!
  public var group : LayoutInspectorGroup {
    return LayoutInspectorProperty.labels[self]!.group
  }

  /// This will cause a runtime error if the lookup is not defined - this is the intent!
  public var inspector : LayoutInspector {
    return LayoutInspectorProperty.labels[self]!.group.inspector
  }

  /// This will cause a runtime error if the lookup is not defined - this is the intent!
  public var controlType : InspectorControlType {
    return LayoutInspectorProperty.labels[self]!.controlType
  }
  
  // MARK: Public Methods
  
  public func isValid(string:String) -> Bool {
    
    switch self {
    case .xPos, .yPos:
      guard let value = Int(string), value >= 0x0000 && value <= 0xffff else {
        return false
      }
    case .trackGradient:
      guard let value = Double(string), value >= 0.0 && value <= 100.0 else {
        return false
      }
    case .lengthRoute1, .lengthRoute2, .lengthRoute3, .lengthRoute4, .lengthRoute5, .lengthRoute6, .lengthRoute7, .lengthRoute8, .leftThroughRoute, .leftDivergingRoute, .rightThroughRoute, .rightDivergingRoute, .yLeftDivergingRoute, .yRightDivergingRoute, .way3ThroughRoute, .way3LeftDivergingRoute, .way3RightDivergingRoute, .leftCurvedLargerRadiusRoute, .leftCurvedSmallerRadiusRoute, .rightCurvedLargerRadiusRoute, .rightCurvedSmallerRadiusRoute:
      guard let value = Double(string), value >= 0.0 else {
        return false
      }
    case .sensorPosition:
      guard let value = Double(string), value >= 0.0 else {
        return false
      }
    case .sensorActivateLatency, .sensorDeactivateLatency:
      guard let value = Double(string), value >= 0.0 else {
        return false
      }
    case .signalPosition:
      guard let value = Double(string), value >= 0.0 else {
        return false
      }
    case .enterDetectionZoneEventId, .exitDetectionZoneEventId, .enterTranspondingZoneEventId, .exitTranspondingZoneEventId, .trackFaultEventId, .trackFaultClearedEventId, .locationServicesEventId, .sw1ThrowEventId, .sw1CloseEventId, .sw1ThrownEventId, .sw1ClosedEventId, .sw2ThrowEventId, .sw2CloseEventId, .sw2ThrownEventId, .sw2ClosedEventId, .sw3ThrowEventId, .sw3CloseEventId, .sw3ThrownEventId, .sw3ClosedEventId, .sw4ThrowEventId, .sw4CloseEventId, .sw4ThrownEventId, .sw4ClosedEventId, .sensorActivatedEventId, .sensorDeactivatedEventId, .sensorLocationServicesEventId, .signalSetState0EventId, .signalSetState1EventId, .signalSetState2EventId, .signalSetState3EventId, .signalSetState4EventId, .signalSetState5EventId, .signalSetState6EventId, .signalSetState7EventId, .signalSetState8EventId, .signalSetState9EventId, .signalSetState10EventId, .signalSetState11EventId, .signalSetState12EventId, .signalSetState13EventId, .signalSetState14EventId, .signalSetState15EventId, .signalSetState16EventId, .signalSetState17EventId, .signalSetState18EventId, .signalSetState19EventId, .signalSetState20EventId, .signalSetState21EventId, .signalSetState22EventId, .signalSetState23EventId, .signalSetState24EventId, .signalSetState25EventId, .signalSetState26EventId, .signalSetState27EventId, .signalSetState28EventId, .signalSetState29EventId, .signalSetState30EventId, .signalSetState31EventId, .sw1CommandedClosedEventId, .sw1CommandedThrownEventId, .sw2CommandedClosedEventId, .sw2CommandedThrownEventId, .sw3CommandedClosedEventId, .sw3CommandedThrownEventId, .sw4CommandedClosedEventId, .sw4CommandedThrownEventId, .sw1NotClosedEventId, .sw1NotThrownEventId, .sw2NotClosedEventId, .sw2NotThrownEventId, .sw3NotClosedEventId, .sw3NotThrownEventId, .sw4NotClosedEventId, .sw4NotThrownEventId:
      guard let _ = UInt64(dotHex: string, numberOfBytes: 8) else {
        return string.isEmpty
      }
    case .speedConstraintDPValue0, .speedConstraintDPValue1, .speedConstraintDPValue2, .speedConstraintDPValue3, .speedConstraintDPValue4, .speedConstraintDPValue5, .speedConstraintDPValue6, .speedConstraintDPValue7, .speedConstraintDPValue8, .speedConstraintDPValue9, .speedConstraintDPValue10, .speedConstraintDPValue11, .speedConstraintDPValue12, .speedConstraintDPValue13, .speedConstraintDPValue14, .speedConstraintDPValue15, .speedConstraintDNValue0, .speedConstraintDNValue1, .speedConstraintDNValue2, .speedConstraintDNValue3, .speedConstraintDNValue4, .speedConstraintDNValue5, .speedConstraintDNValue6, .speedConstraintDNValue7, .speedConstraintDNValue8, .speedConstraintDNValue9, .speedConstraintDNValue10, .speedConstraintDNValue11, .speedConstraintDNValue12, .speedConstraintDNValue13, .speedConstraintDNValue14, .speedConstraintDNValue15:
      guard let value = Double(string), value >= 0.0 else {
        return false
      }
    default:
      break
    }
    
    return true
    
  }

  // MARK: Private Class Properties
  
  private static let labels : [LayoutInspectorProperty:(labelTitle:String, toolTip:String, group:LayoutInspectorGroup, controlType:InspectorControlType)] = [
    .name
    : (
      String(localized:"Name", comment:"This is used for the title of an input field where the user can define the name of a switchboard item."),
      String(localized:"User name of this switchboard item. Switchboard items should be given unique names with a logical naming convention.", comment:"This is used for a tooltip."),
      .generalSettings,
      .textField
    ),
    .description
    : (
      String(localized:"Description", comment:"This is used for the title of an input field where the user can enter a description of a switchboard item."),
      String(localized:"User description of this switchboard item. This is an optional field and may contain any descriptive text the user chooses.", comment:"This is used for a tooltip."),
      .generalSettings,
      .textField
    ),
    .xPos
    : (
      String(localized:"X Position", comment:"This is used for the title of an input field where the user can enter a switchboard item's x coordinate in the panel's grid."),
      String(localized:"X position coordinate of this switchboard item in the panel's grid.", comment:"This is used for a tooltip."),
      .generalSettings,
      .label
    ),
    .yPos
    : (
      String(localized:"Y Position", comment:"This is used for the title of an input field where the user can enter a switchboard item's y coordinate in the panel's grid."),
      String(localized:"Y position coordinate of this switchboard item in the panel's grid.", comment:"This is used for a tooltip."),
      .generalSettings,
      .label
    ),
    .orientation
    : (
      String(localized:"Orientation", comment:"This is used for the title of a combo box where the user can select the orientation/rotation state of the switchboard item."),
      String(localized:"Rotation angle of the switchboard item.", comment:"This is used for a tooltip."),
      .generalSettings,
      .comboBox
    ),
    .groupId
    : (
      String(localized:"Group", comment:"This is used for the title of a combo box where the user can select which group the switchboard item belongs to."),
      String(localized:"Group that this switchboard item belongs to. Groups are used to identify which track items belong to which block. It is also used to group opposing turnouts.", comment:"This is used for a tooltip."),
      .generalSettings,
      .comboBox
    ),
    .directionality
    : (
      String(localized:"Directionality", comment:"This is used for the title of combo box where the user can select which directions of travel are valid for the switchboard item."),
      String(localized:"Permitted directions of travel for a train on this switchboard item.", comment:"This is used for a tooltip."),
      .blockSettings,
      .comboBox
    ),
    .allowShunt
    : (
      String(localized:"Allow Shunt", comment:"This is used for the title of a check box where the user can select if shunting is allowed in reverese direction on this switchbaord item."),
      String(localized:"Check this box to allow shunting in the reverse direction to that permitted for this switchboard item.", comment:"This is used for a tooltip."),
      .blockSettings,
      .checkBox
    ),
    .electrification
    : (
      String(localized:"Electrification", comment:"This is used for the title of a combo box where the user can select the applicable electrification type for the switchboard item."),
      String(localized:"This identifies the type of electrification that is applicable for this switchboard item. Electric trains will not be permitted on non-electrified track, or trains with the wrong electrification type.", comment:"This is used for a tooltip."),
      .blockSettings,
      .comboBox
    ),
    .isCriticalSection
    : (
      String(localized:"Critical Section", comment:"This is used for the title of a check box where the user can select if a piece or track or turnout is a critical section."),
      String(localized:"A critical section is a turnout or block which cannot be reserved unless the section following it is ready to accept the train.", comment:"This is used for a tooltip."),
      .blockSettings,
      .checkBox
    ),
    .isHiddenSection
    : (
      String(localized:"Hidden Section", comment:"This is used for the title of a check box where the user can select if a switchboard item is marked as hidden."),
      String(localized:"A hidden section is an area outside of the scenic area of the layout, i.e. it is hidden from the public view.", comment:"This is used for a tooltip."),
      .blockSettings,
      .checkBox
    ),
    .trackGradient
    : (
      String(localized:"Track Gradient", comment:"This is used for the title of an input field where the user can enter the gradient of the track."),
      String(localized:"This is a percentage from 0 to 100 where 0 means horizontal and 100 means vertical.", comment:"This is used for a tooltip."),
      .trackConfiguration,
      .textField
    ),
    .trackGauge
    : (
      String(localized:"Track Guage", comment:"This is used for the title of a combo box where the user can select the track guage."),
      String(localized:"Track guage of this switchboard item. Trains will not be permitted on track of the wrong guage. Also you cannot connect together track items with different track guages.", comment:"This is used for a tooltip."),
      .trackConfiguration,
      .comboBox
    ),
    .lengthRoute1
    : (
      String(localized:"Length of Route #1 (%%UNITS_ACTUAL_LENGTH%%)", comment:"This is used for the title of an input field where the user enters the length of the specified route. The %%UNITS_ACTUAL_LENGTH%% will be replaced at runtime by the name of the user selected units of length - place this at an approprate position in the title for the language."),
      String(localized:"Length of route #1", comment:"This is used for a tooltip."),
      .routeLengths,
      .textField
    ),
    .leftDivergingRoute
    : (
      String(localized:"Left Diverging Route (%%UNITS_ACTUAL_LENGTH%%)", comment:"This is used for the title of an input field where the user enters the length of the specified route. The %%UNITS_ACTUAL_LENGTH%% will be replaced at runtime by the name of the user selected units of length - place this at an approprate position in the title for the language."),
      String(localized:"Length of left diverging route", comment:"This is used for a tooltip."),
      .routeLengths,
      .textField
    ),
    .rightThroughRoute
    : (
      String(localized:"Through Route (%%UNITS_ACTUAL_LENGTH%%)", comment:"This is used for the title of an input field where the user enters the length of the specified route. The %%UNITS_ACTUAL_LENGTH%% will be replaced at runtime by the name of the user selected units of length - place this at an approprate position in the title for the language."),
      String(localized:"Length of through route", comment:"This is used for a tooltip."),
      .routeLengths,
      .textField
    ),
    .yLeftDivergingRoute
    : (
      String(localized:"Left Diverging Route (%%UNITS_ACTUAL_LENGTH%%)", comment:"This is used for the title of an input field where the user enters the length of the specified route. The %%UNITS_ACTUAL_LENGTH%% will be replaced at runtime by the name of the user selected units of length - place this at an approprate position in the title for the language."),
      String(localized:"Length of left diverging route", comment:"This is used for a tooltip."),
      .routeLengths,
      .textField
    ),
    .way3LeftDivergingRoute
    : (
      String(localized:"Left Diverging Route (%%UNITS_ACTUAL_LENGTH%%)", comment:"This is used for the title of an input field where the user enters the length of the specified route. The %%UNITS_ACTUAL_LENGTH%% will be replaced at runtime by the name of the user selected units of length - place this at an approprate position in the title for the language."),
      String(localized:"Length of left diverging route", comment:"This is used for a tooltip."),
      .routeLengths,
      .textField
    ),
    .leftCurvedSmallerRadiusRoute
    : (
      String(localized:"Smaller Radius Route (%%UNITS_ACTUAL_LENGTH%%)", comment:"This is used for the title of an input field where the user enters the length of the specified route. The %%UNITS_ACTUAL_LENGTH%% will be replaced at runtime by the name of the user selected units of length - place this at an approprate position in the title for the language."),
      String(localized:"Length of smaller radius route", comment:"This is used for a tooltip."),
      .routeLengths,
      .textField
    ),
    .rightCurvedLargerRadiusRoute
    : (
      String(localized:"Larger Radius Route (%%UNITS_ACTUAL_LENGTH%%)", comment:"This is used for the title of an input field where the user enters the length of the specified route. The %%UNITS_ACTUAL_LENGTH%% will be replaced at runtime by the name of the user selected units of length - place this at an approprate position in the title for the language."),
      String(localized:"Length of larger radius route", comment:"This is used for a tooltip."),
      .routeLengths,
      .textField
    ),
    .lengthRoute2
    : (
      String(localized:"Length of Route #2 (%%UNITS_ACTUAL_LENGTH%%)", comment:"This is used for the title of an input field where the user enters the length of the specified route. The %%UNITS_ACTUAL_LENGTH%% will be replaced at runtime by the name of the user selected units of length - place this at an approprate position in the title for the language."),
      String(localized:"Length of route #2", comment:"This is used for a tooltip."),
      .routeLengths,
      .textField
    ),
    .leftThroughRoute
    : (
      String(localized:"Through Route (%%UNITS_ACTUAL_LENGTH%%)", comment:"This is used for the title of an input field where the user enters the length of the specified route. The %%UNITS_ACTUAL_LENGTH%% will be replaced at runtime by the name of the user selected units of length - place this at an approprate position in the title for the language."),
      String(localized:"Length of through route", comment:"This is used for a tooltip."),
      .routeLengths,
      .textField
    ),
    .rightDivergingRoute
    : (
      String(localized:"Right Diverging Route (%%UNITS_ACTUAL_LENGTH%%)", comment:"This is used for the title of an input field where the user enters the length of the specified route. The %%UNITS_ACTUAL_LENGTH%% will be replaced at runtime by the name of the user selected units of length - place this at an approprate position in the title for the language."),
      String(localized:"Length of right diverging route", comment:"This is used for a tooltip."),
      .routeLengths,
      .textField
    ),
    .yRightDivergingRoute
    : (
      String(localized:"Right Diverging Route (%%UNITS_ACTUAL_LENGTH%%)", comment:"This is used for the title of an input field where the user enters the length of the specified route. The %%UNITS_ACTUAL_LENGTH%% will be replaced at runtime by the name of the user selected units of length - place this at an approprate position in the title for the language."),
      String(localized:"Length of right diverging route", comment:"This is used for a tooltip."),
      .routeLengths,
      .textField
    ),
    .way3ThroughRoute
    : (
      String(localized:"Through Route (%%UNITS_ACTUAL_LENGTH%%)", comment:"This is used for the title of an input field where the user enters the length of the specified route. The %%UNITS_ACTUAL_LENGTH%% will be replaced at runtime by the name of the user selected units of length - place this at an approprate position in the title for the language."),
      String(localized:"Length of through route", comment:"This is used for a tooltip."),
      .routeLengths,
      .textField
    ),
    .leftCurvedLargerRadiusRoute
    : (
      String(localized:"Larger Radius Route (%%UNITS_ACTUAL_LENGTH%%)", comment:"This is used for the title of an input field where the user enters the length of the specified route. The %%UNITS_ACTUAL_LENGTH%% will be replaced at runtime by the name of the user selected units of length - place this at an approprate position in the title for the language."),
      String(localized:"Length of larger radius route", comment:"This is used for a tooltip."),
      .routeLengths,
      .textField
    ),
    .rightCurvedSmallerRadiusRoute
    : (
      String(localized:"Smaller Radius Route (%%UNITS_ACTUAL_LENGTH%%)", comment:"This is used for the title of an input field where the user enters the length of the specified route. The %%UNITS_ACTUAL_LENGTH%% will be replaced at runtime by the name of the user selected units of length - place this at an approprate position in the title for the language."),
      String(localized:"Length of smaller radius route", comment:"This is used for a tooltip."),
      .routeLengths,
      .textField
    ),
    .lengthRoute3
    : (
      String(localized:"Length of Route #3 (%%UNITS_ACTUAL_LENGTH%%)", comment:"This is used for the title of an input field where the user enters the length of the specified route. The %%UNITS_ACTUAL_LENGTH%% will be replaced at runtime by the name of the user selected units of length - place this at an approprate position in the title for the language."),
      String(localized:"Length of route #3", comment:"This is used for a tooltip."),
      .routeLengths,
      .textField
    ),
    .way3RightDivergingRoute
    : (
      String(localized:"Right Diverging Route (%%UNITS_ACTUAL_LENGTH%%)", comment:"This is used for the title of an input field where the user enters the length of the specified route. The %%UNITS_ACTUAL_LENGTH%% will be replaced at runtime by the name of the user selected units of length - place this at an approprate position in the title for the language."),
      String(localized:"Length of right diverging route", comment:"This is used for a tooltip."),
      .routeLengths,
      .textField
    ),
    .lengthRoute4
    : (
      String(localized:"Length of Route #4 (%%UNITS_ACTUAL_LENGTH%%)", comment:"This is used for the title of an input field where the user enters the length of the specified route. The %%UNITS_ACTUAL_LENGTH%% will be replaced at runtime by the name of the user selected units of length - place this at an approprate position in the title for the language."),
      String(localized:"Length of route #4", comment:"This is used for a tooltip."),
      .routeLengths,
      .textField
    ),
    .lengthRoute5
    : (
      String(localized:"Length of Route #5 (%%UNITS_ACTUAL_LENGTH%%)", comment:"This is used for the title of an input field where the user enters the length of the specified route. The %%UNITS_ACTUAL_LENGTH%% will be replaced at runtime by the name of the user selected units of length - place this at an approprate position in the title for the language."),
      String(localized:"Length of route #5", comment:"This is used for a tooltip."),
      .routeLengths,
      .textField
    ),
    .lengthRoute6
    : (
      String(localized:"Length of Route #6 (%%UNITS_ACTUAL_LENGTH%%)", comment:"This is used for the title of an input field where the user enters the length of the specified route. The %%UNITS_ACTUAL_LENGTH%% will be replaced at runtime by the name of the user selected units of length - place this at an approprate position in the title for the language."),
      String(localized:"Length of route #6", comment:"This is used for a tooltip."),
      .routeLengths,
      .textField
    ),
    .lengthRoute7
    : (
      String(localized:"Length of Route #7 (%%UNITS_ACTUAL_LENGTH%%)", comment:"This is used for the title of an input field where the user enters the length of the specified route. The %%UNITS_ACTUAL_LENGTH%% will be replaced at runtime by the name of the user selected units of length - place this at an approprate position in the title for the language."),
      String(localized:"Length of route #7", comment:"This is used for a tooltip."),
      .routeLengths,
      .textField
    ),
    .lengthRoute8
    : (
      String(localized:"Length of Route #8 (%%UNITS_ACTUAL_LENGTH%%)", comment:"This is used for the title of an input field where the user enters the length of the specified route. The %%UNITS_ACTUAL_LENGTH%% will be replaced at runtime by the name of the user selected units of length - place this at an approprate position in the title for the language."),
      String(localized:"Length of route #8", comment:"This is used for a tooltip."),
      .routeLengths,
      .textField
    ),
    .panelId
    : (
      String(localized:"Panel ID", comment:"This is used for the title of an informational field that displays the ID of the parent panel of the switchboard item."),
      String(localized:"ID of the parent panel for this switchboard item.", comment:"This is used for a tooltip."),
      .identity,
      .label
    ),
    .panelName
    : (
      String(localized:"Panel Name", comment:"This is used for the title of an informational field that displays the name of the parent panel of the switchboard item."),
      String(localized:"Name of the parent panel for this switchboard item.", comment:"This is used for a tooltip."),
      .identity,
      .label
    ),
    .itemType
    : (
      String(localized:"Item Type", comment:"This is used for the title of an informational field that displays the switchboard item's type."),
      String(localized:"Type of this switchboard item.", comment:"This is used for a tooltip."),
      .identity,
      .label
    ),
    .itemId
    : (
      String(localized:"Item ID", comment:"This is used for the title of an informational field that displays the ID of the switchboard item."),
      String(localized:"ID of this switchboard item.", comment:"This is used for a tooltip."),
      .identity,
      .label
    ),
    .enterDetectionZoneEventId
    : (
      String(localized:"Enter Zone", comment:"This is used for the title of an input field where the user can enter an event ID."),
      String(localized:"Event ID that signals that a train has entered the detection zone associated with this switchboard item.", comment:"This is used for a tooltip."),
      .blockEvents,
      .eventId
    ),
    .blockDoNotUseForSpeedProfile
    : (
      String(localized:"Do not use enter zone event for speed profiling", comment:"This is used for the title of a check box."),
      String(localized:"If this box is checked then the enter zone event will not be used by the speed profiler.", comment:"This is used for a tooltip."),
      .blockEvents,
      .checkBox
    ),
    .exitDetectionZoneEventId
    : (
      String(localized:"Exit Zone", comment:"This is used for the title of an input field where the user can enter an event ID."),
      String(localized:"Event ID that signals that a train has exited the detection zone associated with this switchboard item.", comment:"This is used for a tooltip."),
      .blockEvents,
      .eventId
    ),
    .enterTranspondingZoneEventId
    : (
      String(localized:"Enter Transponding Zone", comment:"This is used for the title of an input field where the user can enter an event ID."),
      String(localized:"Event ID that signals that a train's transponder has been detected in the transponding zone associated with this switchboard item.", comment:"This is used for a tooltip."),
      .blockEvents,
      .eventId
    ),
    .exitTranspondingZoneEventId
    : (
      String(localized:"Exit Transponding Zone", comment:"This is used for the title of an input field where the user can enter an event ID."),
      String(localized:"Event ID that signals that a train's transponder is no longer detected in the transponding zone associated with this switchboard item.", comment:"This is used for a tooltip."),
      .blockEvents,
      .eventId
    ),
    .trackFaultEventId
    : (
      String(localized:"Track Fault", comment:"This is used for the title of an input field where the user can enter an event ID."),
      String(localized:"Event ID that signals that a track fault has been detected in the detection zone associated with this switchboard item.", comment:"This is used for a tooltip."),
      .blockEvents,
      .eventId
    ),
    .trackFaultClearedEventId
    : (
      String(localized:"Track Fault Cleared", comment:"This is used for the title of an input field where the user can enter an event ID."),
      String(localized:"Event ID that signals that a track fault is no longer detected in the detection zone associated with this switchboard item.", comment:"This is used for a tooltip."),
      .blockEvents,
      .eventId
    ),
    .locationServicesEventId
    : (
      String(localized:"Location Services", comment:"This is used for the title of an input field where the user can enter an event ID."),
      String(localized:"Event ID that reports location services information for the zone associated with this switchboard item.", comment:"This is used for a tooltip."),
      .blockEvents,
      .eventId
    ),
    .turnoutMotorType1
    : (
      String(localized:"Switch #1 Method", comment:"This is used for the title of a combo box where the user can select the applicable turnout motor type."),
      String(localized:"The turnout switching method for turnout switch #1.", comment:"This is used for a tooltip."),
      .turnoutControl,
      .comboBox
    ),
    .turnoutMotorType2
    : (
      String(localized:"Switch #2 Method", comment:"This is used for the title of a combo box where the user can select the applicable turnout motor type."),
      String(localized:"The turnout switching method for turnout switch #2.", comment:"This is used for a tooltip."),
      .turnoutControl,
      .comboBox
    ),
    .turnoutMotorType3
    : (
      String(localized:"Switch #3 Method", comment:"This is used for the title of a combo box where the user can select the applicable turnout motor type."),
      String(localized:"The turnout switching method for turnout switch #3.", comment:"This is used for a tooltip."),
      .turnoutControl,
      .comboBox
    ),
    .turnoutMotorType4
    : (
      String(localized:"Switch #4 Method", comment:"This is used for the title of a combo box where the user can select the applicable turnout motor type."),
      String(localized:"The turnout switching method for turnout switch #4.", comment:"This is used for a tooltip."),
      .turnoutControl,
      .comboBox
    ),
    .sw1ThrowEventId
    : (
      String(localized:"Throw Switch #1", comment:"This is used for the title of an input field where the user can select which event ID to send to throw a turnout switch."),
      String(localized:"Event ID to send to throw turnout switch #1. In general the diverging route is selected by close and the through route by throw.", comment:"This is used for a tooltip."),
      .turnoutEvents,
      .eventId
    ),
    .sw1CloseEventId
    : (
      String(localized:"Close Switch #1", comment:"This is used for the title of an input field where the user can select which event ID to send to close a turnout switch."),
      String(localized:"Event ID to send to close turnout switch #1. In general the diverging route is selected by close and the through route by throw.", comment:"This is used for a tooltip."),
      .turnoutEvents,
      .eventId
    ),
    .sw1ThrownEventId
    : (
      String(localized:"Switch #1 Thrown", comment:"This is used for the title of an input field where the user can select which event ID indicates that the turnout switch has been thrown."),
      String(localized:"Event ID that indicates that turnout switch #1 has been thrown.", comment:"This is used for a tooltip."),
      .turnoutEvents,
      .eventId
    ),
    .sw1NotThrownEventId
    : (
      String(localized:"Switch #1 Not Thrown", comment:"This is used for the title of an input field where the user can select which event ID indicates that the turnout switch is no longer thrown."),
      String(localized:"Event ID that indicates that turnout switch #1 is no longer thrown.", comment:"This is used for a tooltip."),
      .turnoutEvents,
      .eventId
    ),
    .sw1ClosedEventId
    : (
      String(localized:"Switch #1 Closed", comment:"This is used for the title of an input field where the user can select which event ID indicates that the turnout switch has been closed."),
      String(localized:"Event ID that indicates that turnout switch #1 has been closed.", comment:"This is used for a tooltip."),
      .turnoutEvents,
      .eventId
    ),
    .sw1NotClosedEventId
    : (
      String(localized:"Switch #1 Not Closed", comment:"This is used for the title of an input field where the user can select which event ID indicates that the turnout switch is no longer closed."),
      String(localized:"Event ID that indicates that turnout switch #1 is no longer closed.", comment:"This is used for a tooltip."),
      .turnoutEvents,
      .eventId
    ),
    .sw2ThrowEventId
    : (
      String(localized:"Throw Switch #2", comment:"This is used for the title of an input field where the user can select which event ID to send to throw a turnout switch."),
      String(localized:"Event ID to send to throw turnout switch #2. In general the diverging route is selected by close and the through route by throw.", comment:"This is used for a tooltip."),
      .turnoutEvents,
      .eventId
    ),
    .sw2CloseEventId
    : (
      String(localized:"Close Switch #2", comment:"This is used for the title of an input field where the user can select which event ID to send to close a turnout switch."),
      String(localized:"Event ID to send to close turnout switch #2. In general the diverging route is selected by close and the through route by throw.", comment:"This is used for a tooltip."),
      .turnoutEvents,
      .eventId
    ),
    .sw2ThrownEventId
    : (
      String(localized:"Switch #2 Thrown", comment:"This is used for the title of an input field where the user can select which event ID indicates that the turnout switch has been thrown."),
      String(localized:"Event ID that indicates that turnout switch #2 has been thrown.", comment:"This is used for a tooltip."),
      .turnoutEvents,
      .eventId
    ),
    .sw2NotThrownEventId
    : (
      String(localized:"Switch #2 Not Thrown", comment:"This is used for the title of an input field where the user can select which event ID indicates that the turnout switch is no longer thrown."),
      String(localized:"Event ID that indicates that turnout switch #2 is no longer thrown.", comment:"This is used for a tooltip."),
      .turnoutEvents,
      .eventId
    ),
    .sw2ClosedEventId
    : (
      String(localized:"Switch #2 Closed", comment:"This is used for the title of an input field where the user can select which event ID indicates that the turnout switch has been closed."),
      String(localized:"Event ID that indicates that turnout switch #2 has been closed.", comment:"This is used for a tooltip."),
      .turnoutEvents,
      .eventId
    ),
    .sw2NotClosedEventId
    : (
      String(localized:"Switch #2 Not Closed", comment:"This is used for the title of an input field where the user can select which event ID indicates that the turnout switch is no longer closed."),
      String(localized:"Event ID that indicates that turnout switch #2 is no longer closed.", comment:"This is used for a tooltip."),
      .turnoutEvents,
      .eventId
    ),
    .sw3ThrowEventId
    : (
      String(localized:"Throw Switch #3", comment:"This is used for the title of an input field where the user can select which event ID to send to throw a turnout switch."),
      String(localized:"Event ID to send to throw turnout switch #3. In general the diverging route is selected by close and the through route by throw.", comment:"This is used for a tooltip."),
      .turnoutEvents,
      .eventId
    ),
    .sw3CloseEventId
    : (
      String(localized:"Close Switch #3", comment:"This is used for the title of an input field where the user can select which event ID to send to close a turnout switch."),
      String(localized:"Event ID to send to close turnout switch #3. In general the diverging route is selected by close and the through route by throw.", comment:"This is used for a tooltip."),
      .turnoutEvents,
      .eventId
    ),
    .sw3ThrownEventId
    : (
      String(localized:"Switch #3 Thrown", comment:"This is used for the title of an input field where the user can select which event ID indicates that the turnout switch has been thrown."),
      String(localized:"Event ID that indicates that turnout switch #3 has been thrown.", comment:"This is used for a tooltip."),
      .turnoutEvents,
      .eventId
    ),
    .sw3NotThrownEventId
    : (
      String(localized:"Switch #3 Not Thrown", comment:"This is used for the title of an input field where the user can select which event ID indicates that the turnout switch is no longer thrown."),
      String(localized:"Event ID that indicates that turnout switch #3 is no longer thrown.", comment:"This is used for a tooltip."),
      .turnoutEvents,
      .eventId
    ),
    .sw3ClosedEventId
    : (
      String(localized:"Switch #3 Closed", comment:"This is used for the title of an input field where the user can select which event ID indicates that the turnout switch has been closed."),
      String(localized:"Event ID that indicates that turnout switch #3 has been closed.", comment:"This is used for a tooltip."),
      .turnoutEvents,
      .eventId
    ),
    .sw3NotClosedEventId
    : (
      String(localized:"Switch #3 Not Closed", comment:"This is used for the title of an input field where the user can select which event ID indicates that the turnout switch is no longer closed."),
      String(localized:"Event ID that indicates that turnout switch #3 is no longer closed.", comment:"This is used for a tooltip."),
      .turnoutEvents,
      .eventId
    ),
    .sw4ThrowEventId
    : (
      String(localized:"Throw Switch #4", comment:"This is used for the title of an input field where the user can select which event ID to send to throw a turnout switch."),
      String(localized:"Event ID to send to throw turnout switch #4. In general the diverging route is selected by close and the through route by throw.", comment:"This is used for a tooltip."),
      .turnoutEvents,
      .eventId
    ),
    .sw4CloseEventId
    : (
      String(localized:"Close Switch #4", comment:"This is used for the title of an input field where the user can select which event ID to send to close a turnout switch."),
      String(localized:"Event ID to send to close turnout switch #4. In general the diverging route is selected by close and the through route by throw.", comment:"This is used for a tooltip."),
      .turnoutEvents,
      .eventId
    ),
    .sw4ThrownEventId
    : (
      String(localized:"Switch #4 Thrown", comment:"This is used for the title of an input field where the user can select which event ID indicates that the turnout switch has been thrown."),
      String(localized:"Event ID that indicates that turnout switch #4 has been thrown.", comment:"This is used for a tooltip."),
      .turnoutEvents,
      .eventId
    ),
    .sw4NotThrownEventId
    : (
      String(localized:"Switch #4 Not Thrown", comment:"This is used for the title of an input field where the user can select which event ID indicates that the turnout switch is no longer thrown."),
      String(localized:"Event ID that indicates that turnout switch #4 is no longer thrown.", comment:"This is used for a tooltip."),
      .turnoutEvents,
      .eventId
    ),
    .sw4ClosedEventId
    : (
      String(localized:"Switch #4 Closed", comment:"This is used for the title of an input field where the user can select which event ID indicates that the turnout switch has been closed."),
      String(localized:"Event ID that indicates that turnout switch #4 has been closed.", comment:"This is used for a tooltip."),
      .turnoutEvents,
      .eventId
    ),
    .sw4NotClosedEventId
    : (
      String(localized:"Switch #4 Not Closed", comment:"This is used for the title of an input field where the user can select which event ID indicates that the turnout switch is no longer closed."),
      String(localized:"Event ID that indicates that turnout switch #4 is no longer closed.", comment:"This is used for a tooltip."),
      .turnoutEvents,
      .eventId
    ),
    .sw1CommandedThrownEventId
    : (
      String(localized:"Switch #1 Commanded Thrown", comment:"This is used for the title of an input field where the user can select which event ID indicates that the turnout switch has been commanded thrown."),
      String(localized:"Event ID that indicates that turnout switch #1 has been commanded thrown.", comment:"This is used for a tooltip."),
      .turnoutEvents,
      .eventId
    ),
    .sw1CommandedClosedEventId
    : (
      String(localized:"Switch #1 Commanded Closed", comment:"This is used for the title of an input field where the user can select which event ID indicates that the turnout switch has been commanded closed."),
      String(localized:"Event ID that indicates that turnout switch #1 has been commanded closed.", comment:"This is used for a tooltip."),
      .turnoutEvents,
      .eventId
    ),
    .sw2CommandedThrownEventId
    : (
      String(localized:"Switch #2 Commanded Thrown", comment:"This is used for the title of an input field where the user can select which event ID indicates that the turnout switch has been commanded thrown."),
      String(localized:"Event ID that indicates that turnout switch #2 has been commanded thrown.", comment:"This is used for a tooltip."),
      .turnoutEvents,
      .eventId
    ),
    .sw2CommandedClosedEventId
    : (
      String(localized:"Switch #2 Commanded Closed", comment:"This is used for the title of an input field where the user can select which event ID indicates that the turnout switch has been commanded closed."),
      String(localized:"Event ID that indicates that turnout switch #2 has been commanded closed.", comment:"This is used for a tooltip."),
      .turnoutEvents,
      .eventId
    ),
    .sw3CommandedThrownEventId
    : (
      String(localized:"Switch #3 Commanded Thrown", comment:"This is used for the title of an input field where the user can select which event ID indicates that the turnout switch has been commanded thrown."),
      String(localized:"Event ID that indicates that turnout switch #3 has been commanded thrown.", comment:"This is used for a tooltip."),
      .turnoutEvents,
      .eventId
    ),
    .sw3CommandedClosedEventId
    : (
      String(localized:"Switch #3 Commanded Closed", comment:"This is used for the title of an input field where the user can select which event ID indicates that the turnout switch has been commanded closed."),
      String(localized:"Event ID that indicates that turnout switch #3 has been commanded closed.", comment:"This is used for a tooltip."),
      .turnoutEvents,
      .eventId
    ),
    .sw4CommandedThrownEventId
    : (
      String(localized:"Switch #4 Commanded Thrown", comment:"This is used for the title of an input field where the user can select which event ID indicates that the turnout switch has been commanded thrown."),
      String(localized:"Event ID that indicates that turnout switch #4 has been commanded thrown.", comment:"This is used for a tooltip."),
      .turnoutEvents,
      .eventId
    ),
    .sw4CommandedClosedEventId
    : (
      String(localized:"Switch #4 Commanded Closed", comment:"This is used for the title of an input field where the user can select which event ID indicates that the turnout switch has been commanded closed."),
      String(localized:"Event ID that indicates that turnout switch #4 has been commanded closed.", comment:"This is used for a tooltip."),
      .turnoutEvents,
      .eventId
    ),

    .sensorType
    : (
      String(localized:"Type", comment:"This is used for the title of a combo box that the user selects the type of sensor."),
      String(localized:"Type of sensor.", comment:"This is used for a tooltip."),
      .sensorSettings,
      .comboBox
    ),
    .sensorPosition
    : (
      String(localized:"Position (%%UNITS_ACTUAL_DISTANCE%%)", comment:"This is used for the title of an input field that the user enters the position of a sensor device."),
      String(localized:"Sensor position from the start of the block.", comment:"This is used for a tooltip."),
      .sensorSettings,
      .textField
    ),
    .sensorActivatedEventId
    : (
      String(localized:"Activated", comment:"This is used for the title of an input field where the user enters a specific event ID."),
      String(localized:"Event ID generated when the sensor is activated.", comment:"this is used for a tooltip."),
      .sensorEvents,
      .eventId
    ),
    .sensorDoNotUseForSpeedProfile
    : (
      String(localized:"Do not use activated event for speed profiling", comment:"This is used for the title of a check box."),
      String(localized:"If this box is checked then the activated event will not be used by the speed profiler.", comment:"This is used for a tooltip."),
      .sensorEvents,
      .checkBox
    ),
    .sensorActivateLatency
    : (
      String(localized:"Activate Latency (%%UNITS_TIME%%)", comment:"This is used for the title of an input field where the user enters the time delay between a sensor being activated and when it sends the event report. The %%UNITS_TIME%% will be replaced at runtime by the name of the user selected units of time - place this at an approprate position in the title for the language."),
      String(localized:"Time between the sensor triggering and the sensor reporting such trigger.", comment:"This is used for a tooltip."),
      .sensorSettings,
      .textField
    ),
    .sensorDeactivatedEventId
    : (
      String(localized:"Deactivated", comment:"This is used for the title of an input field where the user enters a specific event ID."),
      String(localized:"Event ID generated when the sensor is deactivated.", comment:"this is used for a tooltip."),
      .sensorEvents,
      .eventId
    ),
    .sensorDeactivateLatency
    : (
      String(localized:"Deactivate Latency (%%UNITS_TIME%%)", comment:"This is used for the title of an input field where the user enters the time delay between a sensor being deactivated and when it sends the event report. The %%UNITS_TIME%% will be replaced at runtime by the name of the user selected units of time - place this at an approprate position in the title for the language."),
      String(localized:"Time between the sensor no longer being triggered and the sensor reporting such non-triggering.", comment:"This is used for a tooltip."),
      .sensorSettings,
      .textField
    ),
    .sensorLocationServicesEventId
    : (
      String(localized:"Location Services", comment:"This is used for the title of an input field where the user can enter an event ID."),
      String(localized:"Event ID that the sensor uses to report location services information.", comment:"This is used for a tooltip."),
      .sensorEvents,
      .eventId
    ),
    .link
    : (
      String(localized:"Link", comment:"This is used for the title of a combo box that the user selects which switchboard link this link connects to."),
      String(localized:"Switchboard link that this link connects to. Links are used to make connections between switchboard panels and to allow tracks to go above or below other tracks.", comment:"This is used for a tooltip."),
      .trackConfiguration,
      .comboBox
    ),
    .signalType
    : (
      String(localized:"Type", comment:"This is used for the title of a combo box that the user selects the signal type."),
      String(localized:"Type of signal.", comment:"This is used for a tooltip."),
      .signalSettings,
      .comboBox
    ),
    .signalRouteDirection
    : (
      String(localized:"Route Direction", comment:"This is used for the title of a combo box which the user selects the directionality applicable to the signal."),
      String(localized:"Directionality applicable to this signal.", comment:"This is used for a tooltip."),
      .signalSettings,
      .comboBox
    ),
    .signalPosition
    : (
      String(localized:"Stop Position (%%UNITS_ACTUAL_DISTANCE%%)", comment:""),
      String(localized:"The position from the start of the block where a train should stop.", comment:"This is used for a tooltip."),
      .signalSettings,
      .textField
    ),
    .signalSetState0EventId
    : (
      String(localized:"Set Aspect #1", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #1.", comment:"This is used for a tooltip."),
      .signalEvents,
      .eventId
    ),
    .signalSetState1EventId
    : (
      String(localized:"Set Aspect #2", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #2.", comment:"This is used for a tooltip."),
      .signalEvents,
      .eventId
    ),
    .signalSetState2EventId
    : (
      String(localized:"Set Aspect #3", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #3.", comment:"This is used for a tooltip."),
      .signalEvents,
      .eventId
    ),
    .signalSetState3EventId
    : (
      String(localized:"Set Aspect #4", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #4.", comment:"This is used for a tooltip."),
      .signalEvents,
      .eventId
    ),
    .signalSetState4EventId
    : (
      String(localized:"Set Aspect #5", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #5.", comment:"This is used for a tooltip."),
      .signalEvents,
      .eventId
    ),
    .signalSetState5EventId
    : (
      String(localized:"Set Aspect #6", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #6.", comment:"This is used for a tooltip."),
      .signalEvents,
      .eventId
    ),
    .signalSetState6EventId
    : (
      String(localized:"Set Aspect #7", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #7.", comment:"This is used for a tooltip."),
      .signalEvents,
      .eventId
    ),
    .signalSetState7EventId
    : (
      String(localized:"Set Aspect #8", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #8.", comment:"This is used for a tooltip."),
      .signalEvents,
      .eventId
    ),
    .signalSetState8EventId
    : (
      String(localized:"Set Aspect #9", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #9.", comment:"This is used for a tooltip."),
      .signalEvents,
      .eventId
    ),
    .signalSetState9EventId
    : (
      String(localized:"Set Aspect #10", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #10.", comment:"This is used for a tooltip."),
      .signalEvents,
      .eventId
    ),
    .signalSetState10EventId
    : (
      String(localized:"Set Aspect #11", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #11.", comment:"This is used for a tooltip."),
      .signalEvents,
      .eventId
    ),
    .signalSetState11EventId
    : (
      String(localized:"Set Aspect #12", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #12.", comment:"This is used for a tooltip."),
      .signalEvents,
      .eventId
    ),
    .signalSetState12EventId
    : (
      String(localized:"Set Aspect #13", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #13.", comment:"This is used for a tooltip."),
      .signalEvents,
      .eventId
    ),
    .signalSetState13EventId
    : (
      String(localized:"Set Aspect #14", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #14.", comment:"This is used for a tooltip."),
      .signalEvents,
      .eventId
    ),
    .signalSetState14EventId
    : (
      String(localized:"Set Aspect #15", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #15.", comment:"This is used for a tooltip."),
      .signalEvents,
      .eventId
    ),
    .signalSetState15EventId
    : (
      String(localized:"Set Aspect #16", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #16.", comment:"This is used for a tooltip."),
      .signalEvents,
      .eventId
    ),
    .signalSetState16EventId
    : (
      String(localized:"Set Aspect #17", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #17.", comment:"This is used for a tooltip."),
      .signalEvents,
      .eventId
    ),
    .signalSetState17EventId
    : (
      String(localized:"Set Aspect #18", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #18.", comment:"This is used for a tooltip."),
      .signalEvents,
      .eventId
    ),
    .signalSetState18EventId
    : (
      String(localized:"Set Aspect #19", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #19.", comment:"This is used for a tooltip."),
      .signalEvents,
      .eventId
    ),
    .signalSetState19EventId
    : (
      String(localized:"Set Aspect #20", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #20.", comment:"This is used for a tooltip."),
      .signalEvents,
      .eventId
    ),
    .signalSetState20EventId
    : (
      String(localized:"Set Aspect #21", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #21.", comment:"This is used for a tooltip."),
      .signalEvents,
      .eventId
    ),
    .signalSetState21EventId
    : (
      String(localized:"Set Aspect #22", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #22.", comment:"This is used for a tooltip."),
      .signalEvents,
      .eventId
    ),
    .signalSetState22EventId
    : (
      String(localized:"Set Aspect #23", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #23.", comment:"This is used for a tooltip."),
      .signalEvents,
      .eventId
    ),
    .signalSetState23EventId
    : (
      String(localized:"Set Aspect #24", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #24.", comment:"This is used for a tooltip."),
      .signalEvents,
      .eventId
    ),
    .signalSetState24EventId
    : (
      String(localized:"Set Aspect #25", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #25.", comment:"This is used for a tooltip."),
      .signalEvents,
      .eventId
    ),
    .signalSetState25EventId
    : (
      String(localized:"Set Aspect #26", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #26.", comment:"This is used for a tooltip."),
      .signalEvents,
      .eventId
    ),
    .signalSetState26EventId
    : (
      String(localized:"Set Aspect #27", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #27.", comment:"This is used for a tooltip."),
      .signalEvents,
      .eventId
    ),
    .signalSetState27EventId
    : (
      String(localized:"Set Aspect #28", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #28.", comment:"This is used for a tooltip."),
      .signalEvents,
      .eventId
    ),
    .signalSetState28EventId
    : (
      String(localized:"Set Aspect #29", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #29.", comment:"This is used for a tooltip."),
      .signalEvents,
      .eventId
    ),
    .signalSetState29EventId
    : (
      String(localized:"Set Aspect #30", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #30.", comment:"This is used for a tooltip."),
      .signalEvents,
      .eventId
    ),
    .signalSetState30EventId
    : (
      String(localized:"Set Aspect #31", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #31.", comment:"This is used for a tooltip."),
      .signalEvents,
      .eventId
    ),
    .signalSetState31EventId
    : (
      String(localized:"Set Aspect #32", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #32.", comment:"This is used for a tooltip."),
      .signalEvents,
      .eventId
    ),
    .speedConstraintDPType0
    : (
      String(localized:"Constraint #1 Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP,
      .comboBox
    ),
    .speedConstraintDPValue0
    : (
      String(localized:"Constraint #1 (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP,
      .textField
    ),
    .speedConstraintDPType1
    : (
      String(localized:"Constraint #2 Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP,
      .comboBox
    ),
    .speedConstraintDPValue1
    : (
      String(localized:"Constraint #2 (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP,
      .textField
    ),
    .speedConstraintDPType2
    : (
      String(localized:"Constraint #3 Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP,
      .comboBox
    ),
    .speedConstraintDPValue2
    : (
      String(localized:"Constraint #3 (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP,
      .textField
    ),
    .speedConstraintDPType3
    : (
      String(localized:"Constraint #4 Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP,
      .comboBox
    ),
    .speedConstraintDPValue3
    : (
      String(localized:"Constraint #4 (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP,
      .textField
    ),
    .speedConstraintDPType4
    : (
      String(localized:"Constraint #5 Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP,
      .comboBox
    ),
    .speedConstraintDPValue4
    : (
      String(localized:"Constraint #5 (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP,
      .textField
    ),
    .speedConstraintDPType5
    : (
      String(localized:"Constraint #6 Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP,
      .comboBox
    ),
    .speedConstraintDPValue5
    : (
      String(localized:"Constraint #6 (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP,
      .textField
    ),
    .speedConstraintDPType6
    : (
      String(localized:"Constraint #7 Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP,
      .comboBox
    ),
    .speedConstraintDPValue6
    : (
      String(localized:"Constraint #7 (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP,
      .textField
    ),
    .speedConstraintDPType7
    : (
      String(localized:"Constraint #8 Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP,
      .comboBox
    ),
    .speedConstraintDPValue7
    : (
      String(localized:"Constraint #8 (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP,
      .textField
    ),
    .speedConstraintDPType8
    : (
      String(localized:"Constraint #9 Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP,
      .comboBox
    ),
    .speedConstraintDPValue8
    : (
      String(localized:"Constraint #9 (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP,
      .textField
    ),
    .speedConstraintDPType9
    : (
      String(localized:"Constraint #10 Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP,
      .comboBox
    ),
    .speedConstraintDPValue9
    : (
      String(localized:"Constraint #10 (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP,
      .textField
    ),
    .speedConstraintDPType10
    : (
      String(localized:"Constraint #11 Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP,
      .comboBox
    ),
    .speedConstraintDPValue10
    : (
      String(localized:"Constraint #11 (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP,
      .textField
    ),
    .speedConstraintDPType11
    : (
      String(localized:"Constraint #12 Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP,
      .comboBox
    ),
    .speedConstraintDPValue11
    : (
      String(localized:"Constraint #12 (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP,
      .textField
    ),
    .speedConstraintDPType12
    : (
      String(localized:"Constraint #13 Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP,
      .comboBox
    ),
    .speedConstraintDPValue12
    : (
      String(localized:"Constraint #13 (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP,
      .textField
    ),
    .speedConstraintDPType13
    : (
      String(localized:"Constraint #14 Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP,
      .comboBox
    ),
    .speedConstraintDPValue13
    : (
      String(localized:"Constraint #14 (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP,
      .textField
    ),
    .speedConstraintDPType14
    : (
      String(localized:"Constraint #15 Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP,
      .comboBox
    ),
    .speedConstraintDPValue14
    : (
      String(localized:"Constraint #15 (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP,
      .textField
    ),
    .speedConstraintDPType15
    : (
      String(localized:"Constraint #16 Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP,
      .comboBox
    ),
    .speedConstraintDPValue15
    : (
      String(localized:"Constraint #16 (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP,
      .textField
    ),
    .speedConstraintDNType0
    : (
      String(localized:"Constraint #1 Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN,
      .comboBox
    ),
    .speedConstraintDNValue0
    : (
      String(localized:"Constraint #1 (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN,
      .textField
    ),
    .speedConstraintDNType1
    : (
      String(localized:"Constraint #2 Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN,
      .comboBox
    ),
    .speedConstraintDNValue1
    : (
      String(localized:"Constraint #2 (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN,
      .textField
    ),
    .speedConstraintDNType2
    : (
      String(localized:"Constraint #3 Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN,
      .comboBox
    ),
    .speedConstraintDNValue2
    : (
      String(localized:"Constraint #3 (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN,
      .textField
    ),
    .speedConstraintDNType3
    : (
      String(localized:"Constraint #4 Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN,
      .comboBox
    ),
    .speedConstraintDNValue3
    : (
      String(localized:"Constraint #4 (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN,
      .textField
    ),
    .speedConstraintDNType4
    : (
      String(localized:"Constraint #5 Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN,
      .comboBox
    ),
    .speedConstraintDNValue4
    : (
      String(localized:"Constraint #5 (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN,
      .textField
    ),
    .speedConstraintDNType5
    : (
      String(localized:"Constraint #6 Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN,
      .comboBox
    ),
    .speedConstraintDNValue5
    : (
      String(localized:"Constraint #6 (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN,
      .textField
    ),
    .speedConstraintDNType6
    : (
      String(localized:"Constraint #7 Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN,
      .comboBox
    ),
    .speedConstraintDNValue6
    : (
      String(localized:"Constraint #7 (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN,
      .textField
    ),
    .speedConstraintDNType7
    : (
      String(localized:"Constraint #8 Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN,
      .comboBox
    ),
    .speedConstraintDNValue7
    : (
      String(localized:"Constraint #8 (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN,
      .textField
    ),
    .speedConstraintDNType8
    : (
      String(localized:"Constraint #9 Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN,
      .comboBox
    ),
    .speedConstraintDNValue8
    : (
      String(localized:"Constraint #9 (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN,
      .textField
    ),
    .speedConstraintDNType9
    : (
      String(localized:"Constraint #10 Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN,
      .comboBox
    ),
    .speedConstraintDNValue9
    : (
      String(localized:"Constraint #10 (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN,
      .textField
    ),
    .speedConstraintDNType10
    : (
      String(localized:"Constraint #11 Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN,
      .comboBox
    ),
    .speedConstraintDNValue10
    : (
      String(localized:"Constraint #11 (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN,
      .textField
    ),
    .speedConstraintDNType11
    : (
      String(localized:"Constraint #12 Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN,
      .comboBox
    ),
    .speedConstraintDNValue11
    : (
      String(localized:"Constraint #12 (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN,
      .textField
    ),
    .speedConstraintDNType12
    : (
      String(localized:"Constraint #13 Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN,
      .comboBox
    ),
    .speedConstraintDNValue12
    : (
      String(localized:"Constraint #13 (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN,
      .textField
    ),
    .speedConstraintDNType13
    : (
      String(localized:"Constraint #14 Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN,
      .comboBox
    ),
    .speedConstraintDNValue13
    : (
      String(localized:"Constraint #14 (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN,
      .textField
    ),
    .speedConstraintDNType14
    : (
      String(localized:"Constraint #15 Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN,
      .comboBox
    ),
    .speedConstraintDNValue14
    : (
      String(localized:"Constraint #15 (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN,
      .textField
    ),
    .speedConstraintDNType15
    : (
      String(localized:"Constraint #16 Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN,
      .comboBox
    ),
    .speedConstraintDNValue15
    : (
      String(localized:"Constraint #16 (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN,
      .textField
    ),
  ]
  
  // MARK: Public Class Properties
  
  public static var inspectorPropertyFields: [LayoutInspectorPropertyField] {
    
    var result : [LayoutInspectorPropertyField] = []
    
    let labelFontSize : CGFloat = 10.0
    let textFontSize  : CGFloat = 11.0
    
    for item in LayoutInspectorProperty.allCases {
      
      var field : LayoutInspectorPropertyField = (view:nil, label:nil, control:nil, item, new:nil, copy:nil, paste:nil)
      
      field.label = NSTextField(labelWithString: item.label)
      
      let view = NSView()
      
      view.translatesAutoresizingMaskIntoConstraints = false
      
      switch item.controlType {
      case .checkBox:
        field.label!.stringValue = ""
        let checkBox = NSButton()
        checkBox.setButtonType(.switch)
        checkBox.title = item.label
        field.control = checkBox
      case .comboBox:
        let comboBox = MyComboBox()
        comboBox.isEditable = false
        field.control = comboBox
        initComboBox(property: field.property, comboBox: comboBox)
      case .eventId:
        let textField = NSTextField()
        textField.placeholderString = "00.00.00.00.00.00.00.00"
        field.control = textField
        let newButton = NSButton()
        newButton.title = String(localized: "New")
        newButton.fontSize = labelFontSize
        newButton.translatesAutoresizingMaskIntoConstraints = false
        newButton.tag = item.rawValue
        view.addSubview(newButton)
        field.new = newButton
        let copyButton = NSButton()
        copyButton.title = String(localized: "Copy")
        copyButton.fontSize = labelFontSize
        copyButton.translatesAutoresizingMaskIntoConstraints = false
        copyButton.tag = item.rawValue

        view.addSubview(copyButton)
        field.copy = copyButton
        let pasteButton = NSButton()
        pasteButton.title = String(localized: "Paste")
        pasteButton.fontSize = labelFontSize
        pasteButton.translatesAutoresizingMaskIntoConstraints = false
        pasteButton.tag = item.rawValue
        view.addSubview(pasteButton)
        field.paste = pasteButton
        
      case .label:
        let textField = NSTextField(labelWithString: "")
        field.control = textField
      case .textField:
        let textField = NSTextField()
        field.control = textField
      }
      
      field.control?.toolTip = item.toolTip
      field.control?.tag = item.rawValue
      
      /// https://manasaprema04.medium.com/autolayout-fundamental-522f0a6e5790
      
      field.label!.translatesAutoresizingMaskIntoConstraints = false
      field.label!.fontSize = labelFontSize
      field.label!.alignment = .right
      field.label!.setContentHuggingPriority(NSLayoutConstraint.Priority(rawValue: 250), for: .horizontal)
 //     field.label!.lineBreakMode = .byWordWrapping
 //     field.label!.maximumNumberOfLines = 0
 //     field.label!.preferredMaxLayoutWidth = 120.0

      view.addSubview(field.label!)
      
      field.control!.translatesAutoresizingMaskIntoConstraints = false
      field.control!.fontSize = textFontSize
      field.control!.setContentHuggingPriority(NSLayoutConstraint.Priority(rawValue: 1), for: .horizontal)

      view.addSubview(field.control!)
//      view.backgroundColor = NSColor.yellow.cgColor

      field.view = view
      field.view!.setContentHuggingPriority(NSLayoutConstraint.Priority(rawValue: 500), for: .horizontal)

      result.append(field)
      
    }
    
    return result
    
  }
  
  // MARK: Private Class Methods
  
  private static func initComboBox(property:LayoutInspectorProperty, comboBox:MyComboBox) {
    
    switch property {
    case .orientation:
      Orientation.populate(comboBox: comboBox)
    case .groupId:
      appNode?.populateGroup(comboBox: comboBox)
    case .directionality:
      BlockDirection.populate(comboBox: comboBox)
    case .electrification:
      TrackElectrificationType.populate(comboBox: comboBox)
    case .trackGauge:
      TrackGauge.populate(comboBox: comboBox)
    case .link:
      appNode?.populateLink(comboBox: comboBox)
    case .turnoutMotorType1, .turnoutMotorType2, .turnoutMotorType3, .turnoutMotorType4:
      TurnoutMotorType.populate(comboBox: comboBox)
    case .sensorType:
      SensorType.populate(comboBox: comboBox)
    case .signalType:
      SignalType.populate(comboBox: comboBox, countryCode: appNode!.layout!.countryCode)
    case .signalRouteDirection:
      RouteDirection.populate(comboBox: comboBox)
    case .speedConstraintDPType0, .speedConstraintDPType1, .speedConstraintDPType2, .speedConstraintDPType3, .speedConstraintDPType4, .speedConstraintDPType5, .speedConstraintDPType6, .speedConstraintDPType7, .speedConstraintDPType8, .speedConstraintDPType9, .speedConstraintDPType10, .speedConstraintDPType11, .speedConstraintDPType12, .speedConstraintDPType13, .speedConstraintDPType14, .speedConstraintDPType15:
      SpeedConstraintType.populate(comboBox: comboBox)
    case .speedConstraintDNType0, .speedConstraintDNType1, .speedConstraintDNType2, .speedConstraintDNType3, .speedConstraintDNType4, .speedConstraintDNType5, .speedConstraintDNType6, .speedConstraintDNType7, .speedConstraintDNType8, .speedConstraintDNType9, .speedConstraintDNType10, .speedConstraintDNType11, .speedConstraintDNType12, .speedConstraintDNType13, .speedConstraintDNType14, .speedConstraintDNType15:
      SpeedConstraintType.populate(comboBox: comboBox)
    default:
      break
    }
  }
  

}
