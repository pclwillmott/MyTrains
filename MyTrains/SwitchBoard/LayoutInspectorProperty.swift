//
//  LayoutInspectorProperty.swift
//  MyTrains
//
//  Created by Paul Willmott on 22/04/2024.
//

import Foundation

/// The value of zero is reserved as a trap for unintialized fields. The actual rawValues have no purpose
/// other than to uniquely identify the property and its label. Where a field is overloaded between
/// switchboard item types a separate property is required if the function or label is different between
/// the item types; a single item property may map to multiple LayoutInspectorProperty values.

public enum LayoutInspectorProperty : Int {
  
  // MARK: Enumeration
  
  case name                          = 1
  case description                   = 2
  case xPos                          = 3
  case yPos                          = 4
  case orientation                   = 5
  case groupId                       = 6
  case directionality                = 7
  case allowShunt                    = 8
  case electrification               = 9
  case isCriticalSection             = 10
  case isHiddenSection               = 11
  case trackGradient                 = 12
  case trackGauge                    = 13
  case lengthRoute1                  = 14
  case lengthRoute2                  = 15
  case lengthRoute3                  = 16
  case lengthRoute4                  = 17
  case lengthRoute5                  = 18
  case lengthRoute6                  = 19
  case lengthRoute7                  = 20
  case lengthRoute8                  = 21
  case panelId                       = 22
  case panelName                     = 23
  case itemType                      = 24
  case enterDetectionZoneEventId     = 25
  case exitDetectionZoneEventId      = 26
  case enterTranspondingZoneEventId  = 27
  case exitTranspondingZoneEventId   = 28
  case trackFaultEventId             = 29
  case trackFaultClearedEventId      = 30
  case locationServicesEventId       = 31
  case turnoutMotorType              = 32
  case sw1ThrowEventId               = 33
  case sw1CloseEventId               = 34
  case sw1ThrownEventId              = 35
  case sw1ClosedEventId              = 36
  case sw2ThrowEventId               = 37
  case sw2CloseEventId               = 38
  case sw2ThrownEventId              = 39
  case sw2ClosedEventId              = 40
  case sw3ThrowEventId               = 41
  case sw3CloseEventId               = 42
  case sw3ThrownEventId              = 43
  case sw3ClosedEventId              = 44
  case sw4ThrowEventId               = 45
  case sw4CloseEventId               = 46
  case sw4ThrownEventId              = 47
  case sw4ClosedEventId              = 48
  case sensorType                    = 49
  case sensorPosition                = 50
  case sensorActivatedEventId        = 51
  case sensorActivateLatency         = 52
  case sensorDeactivatedEventId      = 53
  case sensorDeactivateLatency       = 54
  case sensorLocationServicesEventId = 55
  case link                          = 56
  case signalType                    = 57
  case signalRouteDirection          = 58
  case signalPosition                = 59
  case signalSetState0EventId        = 60
  case signalSetState1EventId        = 61
  case signalSetState2EventId        = 62
  case signalSetState3EventId        = 63
  case signalSetState4EventId        = 64
  case signalSetState5EventId        = 65
  case signalSetState6EventId        = 66
  case signalSetState7EventId        = 67
  case signalSetState8EventId        = 68
  case signalSetState9EventId        = 69
  case signalSetState10EventId       = 70
  case signalSetState11EventId       = 71
  case signalSetState12EventId       = 72
  case signalSetState13EventId       = 73
  case signalSetState14EventId       = 74
  case signalSetState15EventId       = 75
  case signalSetState16EventId       = 76
  case signalSetState17EventId       = 77
  case signalSetState18EventId       = 78
  case signalSetState19EventId       = 79
  case signalSetState20EventId       = 80
  case signalSetState21EventId       = 81
  case signalSetState22EventId       = 82
  case signalSetState23EventId       = 83
  case signalSetState24EventId       = 84
  case signalSetState25EventId       = 85
  case signalSetState26EventId       = 86
  case signalSetState27EventId       = 87
  case signalSetState28EventId       = 88
  case signalSetState29EventId       = 89
  case signalSetState30EventId       = 90
  case signalSetState31EventId       = 91
  case speedConstraintDPType0        = 92
  case speedConstraintDPValue0       = 93
  case speedConstraintDPType1        = 94
  case speedConstraintDPValue1       = 95
  case speedConstraintDPType2        = 96
  case speedConstraintDPValue2       = 97
  case speedConstraintDPType3        = 98
  case speedConstraintDPValue3       = 99
  case speedConstraintDPType4        = 100
  case speedConstraintDPValue4       = 101
  case speedConstraintDPType5        = 102
  case speedConstraintDPValue5       = 103
  case speedConstraintDPType6        = 104
  case speedConstraintDPValue6       = 105
  case speedConstraintDPType7        = 106
  case speedConstraintDPValue7       = 107
  case speedConstraintDPType8        = 108
  case speedConstraintDPValue8       = 109
  case speedConstraintDPType9        = 110
  case speedConstraintDPValue9       = 111
  case speedConstraintDPType10       = 112
  case speedConstraintDPValue10      = 113
  case speedConstraintDPType11       = 114
  case speedConstraintDPValue11      = 115
  case speedConstraintDPType12       = 116
  case speedConstraintDPValue12      = 117
  case speedConstraintDPType13       = 118
  case speedConstraintDPValue13      = 119
  case speedConstraintDPType14       = 120
  case speedConstraintDPValue14      = 121
  case speedConstraintDPType15       = 122
  case speedConstraintDPValue15      = 123
  case speedConstraintDNType0        = 124
  case speedConstraintDNValue0       = 125
  case speedConstraintDNType1        = 126
  case speedConstraintDNValue1       = 127
  case speedConstraintDNType2        = 128
  case speedConstraintDNValue2       = 129
  case speedConstraintDNType3        = 130
  case speedConstraintDNValue3       = 131
  case speedConstraintDNType4        = 132
  case speedConstraintDNValue4       = 133
  case speedConstraintDNType5        = 134
  case speedConstraintDNValue5       = 135
  case speedConstraintDNType6        = 136
  case speedConstraintDNValue6       = 137
  case speedConstraintDNType7        = 138
  case speedConstraintDNValue7       = 139
  case speedConstraintDNType8        = 140
  case speedConstraintDNValue8       = 141
  case speedConstraintDNType9        = 142
  case speedConstraintDNValue9       = 143
  case speedConstraintDNType10       = 144
  case speedConstraintDNValue10      = 145
  case speedConstraintDNType11       = 146
  case speedConstraintDNValue11      = 147
  case speedConstraintDNType12       = 148
  case speedConstraintDNValue12      = 149
  case speedConstraintDNType13       = 150
  case speedConstraintDNValue13      = 151
  case speedConstraintDNType14       = 152
  case speedConstraintDNValue14      = 153
  case speedConstraintDNType15       = 154
  case speedConstraintDNValue15      = 155
  
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
  
  // MARK: Private Class Properties
  
  private static let labels : [LayoutInspectorProperty:(labelTitle:String, toolTip:String, group:LayoutInspectorGroup)] = [
    .name
    : (
      String(localized:"Name", comment:"This is used for the title of an input field where the user can define the name of a switchboard item."),
      String(localized:"User name of this switchboard item. Switchboard items should be given unique names with a logical naming convention.", comment:"This is used for a tooltip."),
      .identity
    ),
    .description
    : (
      String(localized:"Description", comment:"This is used for the title of an input field where the user can enter a description of a switchboard item."),
      String(localized:"User description of this switchboard item. This is an optional field and may contain any descriptive text the user chooses.", comment:"This is used for a tooltip."),
      .identity
    ),
    .xPos
    : (
      String(localized:"X Position", comment:"This is used for the title of an input field where the user can enter a switchboard item's x coordinate in the panel's grid."),
      String(localized:"X position coordinate of this switchboard item in the panel's grid.", comment:"This is used for a tooltip."),
      .generalSettings
    ),
    .yPos
    : (
      String(localized:"Y Position", comment:"This is used for the title of an input field where the user can enter a switchboard item's y coordinate in the panel's grid."),
      String(localized:"Y position coordinate of this switchboard item in the panel's grid.", comment:"This is used for a tooltip."),
      .generalSettings
    ),
    .orientation
    : (
      String(localized:"Orientation", comment:"This is used for the title of a combo box where the user can select the orientation/rotation state of the switchboard item."),
      String(localized:"Rotation angle of the switchboard item.", comment:"This is used for a tooltip."),
      .generalSettings
    ),
    .groupId
    : (
      String(localized:"Group", comment:"This is used for the title of a combo box where the user can select which group the switchboard item belongs to."),
      String(localized:"Group that this switchboard item belongs to. Groups are used to identify which track items belong to which block. It is also used to group opposing turnouts.", comment:"This is used for a tooltip."),
      .generalSettings
    ),
    .directionality
    : (
      String(localized:"Directionality", comment:"This is used for the title of combo box where the user can select which directions of travel are valid for the switchboard item."),
      String(localized:"Permitted directions of travel for a train on this switchboard item.", comment:"This is used for a tooltip."),
      .blockSettings
    ),
    .allowShunt
    : (
      String(localized:"Allow Shunt", comment:"This is used for the title of a check box where the user can select if shunting is allowed in reverese direction on this switchbaord item."),
      String(localized:"Check this box to allow shunting in the reverse direction to that permitted for this switchboard item.", comment:"This is used for a tooltip."),
      .blockSettings
    ),
    .electrification
    : (
      String(localized:"Electrification", comment:"This is used for the title of a combo box where the user can select the applicable electrification type for the switchboard item."),
      String(localized:"This identifies the type of electrification that is applicable for this switchboard item. Electric trains will not be permitted on non-electrified track, or trains with the wrong electrification type.", comment:"This is used for a tooltip."),
      .blockSettings
    ),
    .isCriticalSection
    : (
      String(localized:"Critical Section", comment:"This is used for the title of a check box where the user can select if a piece or track or turnout is a critical section."),
      String(localized:"A critical section is a turnout or block which cannot be reserved unless the section following it is ready to accept the train.", comment:"This is used for a tooltip."),
      .blockSettings
    ),
    .isHiddenSection
    : (
      String(localized:"Hidden Section", comment:"This is used for the title of a check box where the user can select if a switchboard item is marked as hidden."),
      String(localized:"A hidden section is an area outside of the scenic area of the layout, i.e. it is hidden from the public view.", comment:"This is used for a tooltip."),
      .blockSettings
    ),
    .trackGradient
    : (
      String(localized:"Track Gradient", comment:"This is used for the title of an input field where the user can enter the gradient of the track."),
      String(localized:"This is a percentage from 0 to 100 where 0 means horizontal and 100 means vertical.", comment:"This is used for a tooltip."),
      .trackConfiguration
    ),
    .trackGauge
    : (
      String(localized:"Track Guage", comment:"This is used for the title of a combo box where the user can select the track guage."),
      String(localized:"Track guage of this switchboard item. Trains will not be permitted on track of the wrong guage. Also you cannot connect together track items with different track guages.", comment:"This is used for a tooltip."),
      .trackConfiguration
    ),
    .lengthRoute1
    : (
      String(localized:"Length of Route #1 (%%UNITS_ACTUAL_LENGTH%%)", comment:"This is used for the title of an input field where the user enters the length of the specified route. The %%UNITS_ACTUAL_LENGTH%% will be replaced at runtime by the name of the user selected units of length - place this at an approprate position in the title for the language."),
      String(localized:"Length of route #1", comment:"This is used for a tooltip."),
      .trackConfiguration
    ),
    .lengthRoute2
    : (
      String(localized:"Length of Route #2 (%%UNITS_ACTUAL_LENGTH%%)", comment:"This is used for the title of an input field where the user enters the length of the specified route. The %%UNITS_ACTUAL_LENGTH%% will be replaced at runtime by the name of the user selected units of length - place this at an approprate position in the title for the language."),
      String(localized:"Length of route #2", comment:"This is used for a tooltip."),
      .trackConfiguration
    ),
    .lengthRoute3
    : (
      String(localized:"Length of Route #3 (%%UNITS_ACTUAL_LENGTH%%)", comment:"This is used for the title of an input field where the user enters the length of the specified route. The %%UNITS_ACTUAL_LENGTH%% will be replaced at runtime by the name of the user selected units of length - place this at an approprate position in the title for the language."),
      String(localized:"Length of route #3", comment:"This is used for a tooltip."),
      .trackConfiguration
    ),
    .lengthRoute4
    : (
      String(localized:"Length of Route #4 (%%UNITS_ACTUAL_LENGTH%%)", comment:"This is used for the title of an input field where the user enters the length of the specified route. The %%UNITS_ACTUAL_LENGTH%% will be replaced at runtime by the name of the user selected units of length - place this at an approprate position in the title for the language."),
      String(localized:"Length of route #4", comment:"This is used for a tooltip."),
      .trackConfiguration
    ),
    .lengthRoute5
    : (
      String(localized:"Length of Route #5 (%%UNITS_ACTUAL_LENGTH%%)", comment:"This is used for the title of an input field where the user enters the length of the specified route. The %%UNITS_ACTUAL_LENGTH%% will be replaced at runtime by the name of the user selected units of length - place this at an approprate position in the title for the language."),
      String(localized:"Length of route #5", comment:"This is used for a tooltip."),
      .trackConfiguration
    ),
    .lengthRoute6
    : (
      String(localized:"Length of Route #6 (%%UNITS_ACTUAL_LENGTH%%)", comment:"This is used for the title of an input field where the user enters the length of the specified route. The %%UNITS_ACTUAL_LENGTH%% will be replaced at runtime by the name of the user selected units of length - place this at an approprate position in the title for the language."),
      String(localized:"Length of route #6", comment:"This is used for a tooltip."),
      .trackConfiguration
    ),
    .lengthRoute7
    : (
      String(localized:"Length of Route #7 (%%UNITS_ACTUAL_LENGTH%%)", comment:"This is used for the title of an input field where the user enters the length of the specified route. The %%UNITS_ACTUAL_LENGTH%% will be replaced at runtime by the name of the user selected units of length - place this at an approprate position in the title for the language."),
      String(localized:"Length of route #7", comment:"This is used for a tooltip."),
      .trackConfiguration
    ),
    .lengthRoute8
    : (
      String(localized:"Length of Route #8 (%%UNITS_ACTUAL_LENGTH%%)", comment:"This is used for the title of an input field where the user enters the length of the specified route. The %%UNITS_ACTUAL_LENGTH%% will be replaced at runtime by the name of the user selected units of length - place this at an approprate position in the title for the language."),
      String(localized:"Length of route #8", comment:"This is used for a tooltip."),
      .trackConfiguration
    ),
    .panelId
    : (
      String(localized:"Panel ID", comment:"This is used for the title of an informational field that displays the ID of the parent panel of the switchboard item."),
      String(localized:"ID of the parent panel for this switchboard item.", comment:"This is used for a tooltip."),
      .identity
    ),
    .panelName
    : (
      String(localized:"Panel Name", comment:"This is used for the title of an informational field that displays the name of the parent panel of the switchboard item."),
      String(localized:"Name of the parent panel for this switchboard item.", comment:"This is used for a tooltip."),
      .identity
    ),
    .itemType
    : (
      String(localized:"Item Type", comment:"This is used for the title of an informational field that displays the switchboard item's type."),
      String(localized:"Type of this switchboard item.", comment:"This is used for a tooltip."),
      .identity
    ),
    .enterDetectionZoneEventId
    : (
      String(localized:"Enter Detection Zone Event ID", comment:"This is used for the title of an input field where the user can enter an event ID."),
      String(localized:"Event ID that signals that a train has entered the detection zone associated with this switchboard item.", comment:"This is used for a tooltip."),
      .blockEvents
    ),
    .exitDetectionZoneEventId
    : (
      String(localized:"Exit Detection Zone Event ID", comment:"This is used for the title of an input field where the user can enter an event ID."),
      String(localized:"Event ID that signals that a train has exited the detection zone associated with this switchboard item.", comment:"This is used for a tooltip."),
      .blockEvents
    ),
    .enterTranspondingZoneEventId
    : (
      String(localized:"Enter Transponding Zone Event ID", comment:"This is used for the title of an input field where the user can enter an event ID."),
      String(localized:"Event ID that signals that a train's transponder has been detected in the transponding zone associated with this switchboard item.", comment:"This is used for a tooltip."),
      .blockEvents
    ),
    .exitTranspondingZoneEventId
    : (
      String(localized:"Exit Transponding Zone Event ID", comment:"This is used for the title of an input field where the user can enter an event ID."),
      String(localized:"Event ID that signals that a train's transponder is no longer detected in the transponding zone associated with this switchboard item.", comment:"This is used for a tooltip."),
      .blockEvents
    ),
    .trackFaultEventId
    : (
      String(localized:"Track Fault Event ID", comment:"This is used for the title of an input field where the user can enter an event ID."),
      String(localized:"Event ID that signals that a track fault has been detected in the detection zone associated with this switchboard item.", comment:"This is used for a tooltip."),
      .blockEvents
    ),
    .trackFaultClearedEventId
    : (
      String(localized:"Track Fault Cleared Event ID", comment:"This is used for the title of an input field where the user can enter an event ID."),
      String(localized:"Event ID that signals that a track fault is no longer detected in the detection zone associated with this switchboard item.", comment:"This is used for a tooltip."),
      .blockEvents
    ),
    .locationServicesEventId
    : (
      String(localized:"Location Services Event ID", comment:"This is used for the title of an input field where the user can enter an event ID."),
      String(localized:"Event ID that reports location services information for the zone associated with this switchboard item.", comment:"This is used for a tooltip."),
      .blockEvents
    ),
    .turnoutMotorType
    : (
      String(localized:"Turnout Motor Type", comment:"This is used for the title of a combo box where the user can select the applicable turnout motor type."),
      String(localized:"The turnout switching method for this turnout.", comment:"This is used for a tooltip."),
      .turnoutControl
    ),
    .sw1ThrowEventId
    : (
      String(localized:"Switch #1 Throw Event ID", comment:"This is used for the title of an input field where the user can select which event ID to send to throw a turnout switch."),
      String(localized:"Event ID to send to throw turnout switch #1. In general the diverging route is selected by close and the through route by throw.", comment:"This is used for a tooltip."),
      .turnoutControl
    ),
    .sw1CloseEventId
    : (
      String(localized:"Switch #1 Close Event ID", comment:"This is used for the title of an input field where the user can select which event ID to send to close a turnout switch."),
      String(localized:"Event ID to send to close turnout switch #1. In general the diverging route is selected by close and the through route by throw.", comment:"This is used for a tooltip."),
      .turnoutControl
    ),
    .sw1ThrownEventId
    : (
      String(localized:"Switch #1 Thrown Event ID", comment:"This is used for the title of an input field where the user can select which event ID indicates that the turnout switch has been thrown."),
      String(localized:"Event ID that indicates that turnout switch #1 has been thrown.", comment:"This is used for a tooltip."),
      .turnoutControl
    ),
    .sw1ClosedEventId
    : (
      String(localized:"Switch #1 Closed Event ID", comment:"This is used for the title of an input field where the user can select which event ID indicates that the turnout switch has been closed."),
      String(localized:"Event ID that indicates that turnout switch #1 has been closed.", comment:"This is used for a tooltip."),
      .turnoutControl
    ),
    .sw2ThrowEventId
    : (
      String(localized:"Switch #2 Throw Event ID", comment:"This is used for the title of an input field where the user can select which event ID to send to throw a turnout switch."),
      String(localized:"Event ID to send to throw turnout switch #2. In general the diverging route is selected by close and the through route by throw.", comment:"This is used for a tooltip."),
      .turnoutControl
    ),
    .sw2CloseEventId
    : (
      String(localized:"Switch #2 Close Event ID", comment:"This is used for the title of an input field where the user can select which event ID to send to close a turnout switch."),
      String(localized:"Event ID to send to close turnout switch #2. In general the diverging route is selected by close and the through route by throw.", comment:"This is used for a tooltip."),
      .turnoutControl
    ),
    .sw2ThrownEventId
    : (
      String(localized:"Switch #2 Thrown Event ID", comment:"This is used for the title of an input field where the user can select which event ID indicates that the turnout switch has been thrown."),
      String(localized:"Event ID that indicates that turnout switch #2 has been thrown.", comment:"This is used for a tooltip."),
      .turnoutControl
    ),
    .sw2ClosedEventId
    : (
      String(localized:"Switch #2 Closed Event ID", comment:"This is used for the title of an input field where the user can select which event ID indicates that the turnout switch has been closed."),
      String(localized:"Event ID that indicates that turnout switch #2 has been closed.", comment:"This is used for a tooltip."),
      .turnoutControl
    ),
    .sw3ThrowEventId
    : (
      String(localized:"Switch #3 Throw Event ID", comment:"This is used for the title of an input field where the user can select which event ID to send to throw a turnout switch."),
      String(localized:"Event ID to send to throw turnout switch #3. In general the diverging route is selected by close and the through route by throw.", comment:"This is used for a tooltip."),
      .turnoutControl
    ),
    .sw3CloseEventId
    : (
      String(localized:"Switch #3 Close Event ID", comment:"This is used for the title of an input field where the user can select which event ID to send to close a turnout switch."),
      String(localized:"Event ID to send to close turnout switch #3. In general the diverging route is selected by close and the through route by throw.", comment:"This is used for a tooltip."),
      .turnoutControl
    ),
    .sw3ThrownEventId
    : (
      String(localized:"Switch #3 Thrown Event ID", comment:"This is used for the title of an input field where the user can select which event ID indicates that the turnout switch has been thrown."),
      String(localized:"Event ID that indicates that turnout switch #3 has been thrown.", comment:"This is used for a tooltip."),
      .turnoutControl
    ),
    .sw3ClosedEventId
    : (
      String(localized:"Switch #3 Closed Event ID", comment:"This is used for the title of an input field where the user can select which event ID indicates that the turnout switch has been closed."),
      String(localized:"Event ID that indicates that turnout switch #3 has been closed.", comment:"This is used for a tooltip."),
      .turnoutControl
    ),
    .sw4ThrowEventId
    : (
      String(localized:"Switch #4 Throw Event ID", comment:"This is used for the title of an input field where the user can select which event ID to send to throw a turnout switch."),
      String(localized:"Event ID to send to throw turnout switch #4. In general the diverging route is selected by close and the through route by throw.", comment:"This is used for a tooltip."),
      .turnoutControl
    ),
    .sw4CloseEventId
    : (
      String(localized:"Switch #4 Close Event ID", comment:"This is used for the title of an input field where the user can select which event ID to send to close a turnout switch."),
      String(localized:"Event ID to send to close turnout switch #4. In general the diverging route is selected by close and the through route by throw.", comment:"This is used for a tooltip."),
      .turnoutControl
    ),
    .sw4ThrownEventId
    : (
      String(localized:"Switch #4 Thrown Event ID", comment:"This is used for the title of an input field where the user can select which event ID indicates that the turnout switch has been thrown."),
      String(localized:"Event ID that indicates that turnout switch #4 has been thrown.", comment:"This is used for a tooltip."),
      .turnoutControl
    ),
    .sw4ClosedEventId
    : (
      String(localized:"Switch #4 Closed Event ID", comment:"This is used for the title of an input field where the user can select which event ID indicates that the turnout switch has been closed."),
      String(localized:"Event ID that indicates that turnout switch #4 has been closed.", comment:"This is used for a tooltip."),
      .turnoutControl
    ),
    .sensorType
    : (
      String(localized:"Sensor Type", comment:"This is used for the title of a combo box that the user selects the type of sensor."),
      String(localized:"Type of sensor.", comment:"This is used for a tooltip."),
      .sensorSettings
    ),
    .sensorPosition
    : (
      String(localized:"Sensor Position (%%UNITS_ACTUAL_DISTANCE%%)", comment:"This is used for the title of an input field that the user enters the position of a sensor device."),
      String(localized:"Sensor position from the start of the block.", comment:"This is used for a tooltip."),
      .sensorSettings
    ),
    .sensorActivatedEventId
    : (
      String(localized:"Sensor Activated Event ID", comment:"This is used for the title of an input field where the user enters a specific event ID."),
      String(localized:"Event ID generated when the sensor is activated.", comment:"this is used for a tooltip."),
      .sensorSettings
    ),
    .sensorActivateLatency
    : (
      String(localized:"Sensor Activate Latency (%%UNITS_TIME%%)", comment:"This is used for the title of an input field where the user enters the time delay between a sensor being activated and when it sends the event report. The %%UNITS_TIME%% will be replaced at runtime by the name of the user selected units of time - place this at an approprate position in the title for the language."),
      String(localized:"Time between the sensor triggering and the sensor reporting such trigger.", comment:"This is used for a tooltip."),
      .sensorSettings
    ),
    .sensorDeactivatedEventId
    : (
      String(localized:"Sensor Deactivated Event ID", comment:"This is used for the title of an input field where the user enters a specific event ID."),
      String(localized:"Event ID generated when the sensor is deactivated.", comment:"this is used for a tooltip."),
      .sensorSettings
    ),
    .sensorDeactivateLatency
    : (
      String(localized:"Sensor Deactivate Latency (%%UNITS_TIME%%)", comment:"This is used for the title of an input field where the user enters the time delay between a sensor being deactivated and when it sends the event report. The %%UNITS_TIME%% will be replaced at runtime by the name of the user selected units of time - place this at an approprate position in the title for the language."),
      String(localized:"Time between the sensor no longer being triggered and the sensor reporting such non-triggering.", comment:"This is used for a tooltip."),
      .sensorSettings
    ),
    .sensorLocationServicesEventId
    : (
      String(localized:"Sensor Location Services Event ID", comment:"This is used for the title of an input field where the user can enter an event ID."),
      String(localized:"Event ID that the sensor uses to report location services information.", comment:"This is used for a tooltip."),
      .sensorSettings
    ),
    .link
    : (
      String(localized:"Link", comment:"This is used for the title of a combo box that the user selects which switchboard link this link connects to."),
      String(localized:"Switchboard link that this link connects to. Links are used to make connections between switchboard panels and to allow tracks to go above or below other tracks.", comment:"This is used for a tooltip."),
      .generalSettings
    ),
    .signalType
    : (
      String(localized:"Signal Type", comment:"This is used for the title of a combo box that the user selects the signal type."),
      String(localized:"Type of signal.", comment:"This is used for a tooltip."),
      .signalSettings
    ),
    .signalRouteDirection
    : (
      String(localized:"Signal Route Direction", comment:"This is used for the title of a combo box which the user selects the directionality applicable to the signal."),
      String(localized:"Directionality applicable to this signal.", comment:"This is used for a tooltip."),
      .signalSettings
    ),
    .signalPosition
    : (
      String(localized:"Signal Stop Position (%%UNITS_ACTUAL_DISTANCE%%)", comment:""),
      String(localized:"The position from the start of the block where a train should stop.", comment:"This is used for a tooltip."),
      .signalSettings
    ),
    .signalSetState0EventId
    : (
      String(localized:"Set Signal Aspect #1 Event ID", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #1.", comment:"This is used for a tooltip."),
      .signalEvents
    ),
    .signalSetState1EventId
    : (
      String(localized:"Set Signal Aspect #2 Event ID", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #2.", comment:"This is used for a tooltip."),
      .signalEvents
    ),
    .signalSetState2EventId
    : (
      String(localized:"Set Signal Aspect #3 Event ID", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #3.", comment:"This is used for a tooltip."),
      .signalEvents
    ),
    .signalSetState3EventId
    : (
      String(localized:"Set Signal Aspect #4 Event ID", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #4.", comment:"This is used for a tooltip."),
      .signalEvents
    ),
    .signalSetState4EventId
    : (
      String(localized:"Set Signal Aspect #5 Event ID", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #5.", comment:"This is used for a tooltip."),
      .signalEvents
    ),
    .signalSetState5EventId
    : (
      String(localized:"Set Signal Aspect #6 Event ID", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #6.", comment:"This is used for a tooltip."),
      .signalEvents
    ),
    .signalSetState6EventId
    : (
      String(localized:"Set Signal Aspect #7 Event ID", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #7.", comment:"This is used for a tooltip."),
      .signalEvents
    ),
    .signalSetState7EventId
    : (
      String(localized:"Set Signal Aspect #8 Event ID", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #8.", comment:"This is used for a tooltip."),
      .signalEvents
    ),
    .signalSetState8EventId
    : (
      String(localized:"Set Signal Aspect #9 Event ID", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #9.", comment:"This is used for a tooltip."),
      .signalEvents
    ),
    .signalSetState9EventId
    : (
      String(localized:"Set Signal Aspect #10 Event ID", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #10.", comment:"This is used for a tooltip."),
      .signalEvents
    ),
    .signalSetState10EventId
    : (
      String(localized:"Set Signal Aspect #11 Event ID", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #11.", comment:"This is used for a tooltip."),
      .signalEvents
    ),
    .signalSetState11EventId
    : (
      String(localized:"Set Signal Aspect #12 Event ID", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #12.", comment:"This is used for a tooltip."),
      .signalEvents
    ),
    .signalSetState12EventId
    : (
      String(localized:"Set Signal Aspect #13 Event ID", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #13.", comment:"This is used for a tooltip."),
      .signalEvents
    ),
    .signalSetState13EventId
    : (
      String(localized:"Set Signal Aspect #14 Event ID", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #14.", comment:"This is used for a tooltip."),
      .signalEvents
    ),
    .signalSetState14EventId
    : (
      String(localized:"Set Signal Aspect #15 Event ID", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #15.", comment:"This is used for a tooltip."),
      .signalEvents
    ),
    .signalSetState15EventId
    : (
      String(localized:"Set Signal Aspect #16 Event ID", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #16.", comment:"This is used for a tooltip."),
      .signalEvents
    ),
    .signalSetState16EventId
    : (
      String(localized:"Set Signal Aspect #17 Event ID", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #17.", comment:"This is used for a tooltip."),
      .signalEvents
    ),
    .signalSetState17EventId
    : (
      String(localized:"Set Signal Aspect #18 Event ID", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #18.", comment:"This is used for a tooltip."),
      .signalEvents
    ),
    .signalSetState18EventId
    : (
      String(localized:"Set Signal Aspect #19 Event ID", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #19.", comment:"This is used for a tooltip."),
      .signalEvents
    ),
    .signalSetState19EventId
    : (
      String(localized:"Set Signal Aspect #20 Event ID", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #20.", comment:"This is used for a tooltip."),
      .signalEvents
    ),
    .signalSetState20EventId
    : (
      String(localized:"Set Signal Aspect #21 Event ID", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #21.", comment:"This is used for a tooltip."),
      .signalEvents
    ),
    .signalSetState21EventId
    : (
      String(localized:"Set Signal Aspect #22 Event ID", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #22.", comment:"This is used for a tooltip."),
      .signalEvents
    ),
    .signalSetState22EventId
    : (
      String(localized:"Set Signal Aspect #23 Event ID", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #23.", comment:"This is used for a tooltip."),
      .signalEvents
    ),
    .signalSetState23EventId
    : (
      String(localized:"Set Signal Aspect #24 Event ID", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #24.", comment:"This is used for a tooltip."),
      .signalEvents
    ),
    .signalSetState24EventId
    : (
      String(localized:"Set Signal Aspect #25 Event ID", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #25.", comment:"This is used for a tooltip."),
      .signalEvents
    ),
    .signalSetState25EventId
    : (
      String(localized:"Set Signal Aspect #26 Event ID", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #26.", comment:"This is used for a tooltip."),
      .signalEvents
    ),
    .signalSetState26EventId
    : (
      String(localized:"Set Signal Aspect #27 Event ID", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #27.", comment:"This is used for a tooltip."),
      .signalEvents
    ),
    .signalSetState27EventId
    : (
      String(localized:"Set Signal Aspect #28 Event ID", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #28.", comment:"This is used for a tooltip."),
      .signalEvents
    ),
    .signalSetState28EventId
    : (
      String(localized:"Set Signal Aspect #29 Event ID", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #29.", comment:"This is used for a tooltip."),
      .signalEvents
    ),
    .signalSetState29EventId
    : (
      String(localized:"Set Signal Aspect #30 Event ID", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #30.", comment:"This is used for a tooltip."),
      .signalEvents
    ),
    .signalSetState30EventId
    : (
      String(localized:"Set Signal Aspect #31 Event ID", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #31.", comment:"This is used for a tooltip."),
      .signalEvents
    ),
    .signalSetState31EventId
    : (
      String(localized:"Set Signal Aspect #32 Event ID", comment:"This is used for the title of an input field where the user enters the event ID that sets the signal to the specified aspect."),
      String(localized:"Event ID to send to set the signal to aspect #32.", comment:"This is used for a tooltip."),
      .signalEvents
    ),
    .speedConstraintDPType0
    : (
      String(localized:"Speed Constraint Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP
    ),
    .speedConstraintDPValue0
    : (
      String(localized:"Speed Constraint (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP
    ),
    .speedConstraintDPType1
    : (
      String(localized:"Speed Constraint Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP
    ),
    .speedConstraintDPValue1
    : (
      String(localized:"Speed Constraint (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP
    ),
    .speedConstraintDPType2
    : (
      String(localized:"Speed Constraint Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP
    ),
    .speedConstraintDPValue2
    : (
      String(localized:"Speed Constraint (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP
    ),
    .speedConstraintDPType3
    : (
      String(localized:"Speed Constraint Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP
    ),
    .speedConstraintDPValue3
    : (
      String(localized:"Speed Constraint (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP
    ),
    .speedConstraintDPType4
    : (
      String(localized:"Speed Constraint Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP
    ),
    .speedConstraintDPValue4
    : (
      String(localized:"Speed Constraint (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP
    ),
    .speedConstraintDPType5
    : (
      String(localized:"Speed Constraint Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP
    ),
    .speedConstraintDPValue5
    : (
      String(localized:"Speed Constraint (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP
    ),
    .speedConstraintDPType6
    : (
      String(localized:"Speed Constraint Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP
    ),
    .speedConstraintDPValue6
    : (
      String(localized:"Speed Constraint (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP
    ),
    .speedConstraintDPType7
    : (
      String(localized:"Speed Constraint Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP
    ),
    .speedConstraintDPValue7
    : (
      String(localized:"Speed Constraint (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP
    ),
    .speedConstraintDPType8
    : (
      String(localized:"Speed Constraint Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP
    ),
    .speedConstraintDPValue8
    : (
      String(localized:"Speed Constraint (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP
    ),
    .speedConstraintDPType9
    : (
      String(localized:"Speed Constraint Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP
    ),
    .speedConstraintDPValue9
    : (
      String(localized:"Speed Constraint (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP
    ),
    .speedConstraintDPType10
    : (
      String(localized:"Speed Constraint Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP
    ),
    .speedConstraintDPValue10
    : (
      String(localized:"Speed Constraint (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP
    ),
    .speedConstraintDPType11
    : (
      String(localized:"Speed Constraint Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP
    ),
    .speedConstraintDPValue11
    : (
      String(localized:"Speed Constraint (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP
    ),
    .speedConstraintDPType12
    : (
      String(localized:"Speed Constraint Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP
    ),
    .speedConstraintDPValue12
    : (
      String(localized:"Speed Constraint (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP
    ),
    .speedConstraintDPType13
    : (
      String(localized:"Speed Constraint Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP
    ),
    .speedConstraintDPValue13
    : (
      String(localized:"Speed Constraint (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP
    ),
    .speedConstraintDPType14
    : (
      String(localized:"Speed Constraint Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP
    ),
    .speedConstraintDPValue14
    : (
      String(localized:"Speed Constraint (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP
    ),
    .speedConstraintDPType15
    : (
      String(localized:"Speed Constraint Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP
    ),
    .speedConstraintDPValue15
    : (
      String(localized:"Speed Constraint (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDP
    ),
    .speedConstraintDNType0
    : (
      String(localized:"Speed Constraint Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN
    ),
    .speedConstraintDNValue0
    : (
      String(localized:"Speed Constraint (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN
    ),
    .speedConstraintDNType1
    : (
      String(localized:"Speed Constraint Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN
    ),
    .speedConstraintDNValue1
    : (
      String(localized:"Speed Constraint (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN
    ),
    .speedConstraintDNType2
    : (
      String(localized:"Speed Constraint Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN
    ),
    .speedConstraintDNValue2
    : (
      String(localized:"Speed Constraint (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN
    ),
    .speedConstraintDNType3
    : (
      String(localized:"Speed Constraint Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN
    ),
    .speedConstraintDNValue3
    : (
      String(localized:"Speed Constraint (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN
    ),
    .speedConstraintDNType4
    : (
      String(localized:"Speed Constraint Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN
    ),
    .speedConstraintDNValue4
    : (
      String(localized:"Speed Constraint (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN
    ),
    .speedConstraintDNType5
    : (
      String(localized:"Speed Constraint Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN
    ),
    .speedConstraintDNValue5
    : (
      String(localized:"Speed Constraint (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN
    ),
    .speedConstraintDNType6
    : (
      String(localized:"Speed Constraint Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN
    ),
    .speedConstraintDNValue6
    : (
      String(localized:"Speed Constraint (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN
    ),
    .speedConstraintDNType7
    : (
      String(localized:"Speed Constraint Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN
    ),
    .speedConstraintDNValue7
    : (
      String(localized:"Speed Constraint (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN
    ),
    .speedConstraintDNType8
    : (
      String(localized:"Speed Constraint Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN
    ),
    .speedConstraintDNValue8
    : (
      String(localized:"Speed Constraint (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN
    ),
    .speedConstraintDNType9
    : (
      String(localized:"Speed Constraint Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN
    ),
    .speedConstraintDNValue9
    : (
      String(localized:"Speed Constraint (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN
    ),
    .speedConstraintDNType10
    : (
      String(localized:"Speed Constraint Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN
    ),
    .speedConstraintDNValue10
    : (
      String(localized:"Speed Constraint (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN
    ),
    .speedConstraintDNType11
    : (
      String(localized:"Speed Constraint Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN
    ),
    .speedConstraintDNValue11
    : (
      String(localized:"Speed Constraint (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN
    ),
    .speedConstraintDNType12
    : (
      String(localized:"Speed Constraint Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN
    ),
    .speedConstraintDNValue12
    : (
      String(localized:"Speed Constraint (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN
    ),
    .speedConstraintDNType13
    : (
      String(localized:"Speed Constraint Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN
    ),
    .speedConstraintDNValue13
    : (
      String(localized:"Speed Constraint (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN
    ),
    .speedConstraintDNType14
    : (
      String(localized:"Speed Constraint Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN
    ),
    .speedConstraintDNValue14
    : (
      String(localized:"Speed Constraint (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN
    ),
    .speedConstraintDNType15
    : (
      String(localized:"Speed Constraint Type", comment:"This is used for the title of a combo box from which the user selects the speed constraint type."),
      String(localized:"Type of speed constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN
    ),
    .speedConstraintDNValue15
    : (
      String(localized:"Speed Constraint (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of an input field where the user enters the speed constraint value. The %%UNITS_SCALE_SPEED%% will be replaced at runtime by the name of the user selected units of speed - place this at an approprate position in the title for the language."),
      String(localized:"The applicable speed for this constraint.", comment:"This is used for a tooltip."),
      .speedConstraintsDN
    ),
  ]
  
}
