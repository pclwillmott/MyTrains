//
//  SpeedProfilerInspectorProperty.swift
//  MyTrains
//
//  Created by Paul Willmott on 17/06/2024.
//

import Foundation
import AppKit

public enum SpeedProfilerInspectorProperty : Int, CaseIterable {
  
  // MARK: Enumeration
  
  // Identity
  
  case locomotiveId = 1    //
  case locomotiveName = 2 //
  
  // Locomotive Control
  
  case trackProtocol = 3   //
  case locomotiveControlBasis = 4 //
  case locomotiveFacingDirection = 5
  case maximumSpeed = 24

  // Sampling

  case locomotiveTravelDirectionToSample = 6
  case numberOfSamples = 7
  case numberOfSamplesLabel = 8
  case minimumSamplePeriod = 9
  case startSampleNumber = 10
  case stopSampleNumber = 11
  case useLightSensors = 12
  case useReedSwitches = 13
  case useRFIDReaders = 14
  case useOccupancyDetectors = 15

  // Analysis

  case bestFitMethod = 16
  case showTrendline = 17

  // Route
  
  case routeType = 18       //
  case startBlockId = 19   //
  case endBlockId = 20     //
  case route = 21            //
  case routeSegments = 22
  case totalRouteLength = 23 //
  
  // MARK: Private Class Properties
  
  private static let labels : [SpeedProfilerInspectorProperty:(labelTitle:String, toolTip:String, group:SpeedProfilerInspectorGroup, controlType:InspectorControlType)] = [
    .locomotiveId
    : (
      String(localized:"Locomotive ID", comment:"This is used for the title of label which displays the locomotive's node Id."),
      String(localized:"Locomotive's node ID.", comment:"This is used for a tooltip."),
      .identity,
      .label
    ),
    .locomotiveName
    : (
      String(localized:"Locomotive Name", comment:"This is used for the title of label which displays the locomotive's name."),
      String(localized:"Locomotive's name.", comment:"This is used for a tooltip."),
      .identity,
      .label
    ),
    .trackProtocol
    : (
      String(localized:"Track Protocol", comment:"This is used for the title of combobox."),
      String(localized:"Track Protocol.", comment:"This is used for a tooltip."),
      .locomotiveControl,
      .comboBox
    ),
    .locomotiveControlBasis
    : (
      String(localized:"Locomotive Control Basis", comment:"This is used for the title of combobox."),
      String(localized:"This determines how MyTrains controls this locomotive in automatic mode.", comment:"This is used for a tooltip."),
      .locomotiveControl,
      .comboBox
    ),
    .routeType
    : (
      String(localized:"Route Type", comment:"This is used for the title of combobox."),
      String(localized:"Route Type.", comment:"This is used for a tooltip."),
      .route,
      .comboBox
    ),
    .startBlockId
    : (
      String(localized:"Start Block", comment:"This is used for the title of combobox."),
      String(localized:"Select the starting block for the route.", comment:"This is used for a tooltip."),
      .route,
      .comboBox
    ),
    .endBlockId
    : (
      String(localized:"End Block", comment:"This is used for the title of combobox."),
      String(localized:"Select the end block for the route.", comment:"This is used for a tooltip."),
      .route,
      .comboBox
    ),
    .route
    : (
      String(localized:"Route", comment:"This is used for the title of combobox."),
      String(localized:"Select the required route.", comment:"This is used for a tooltip."),
      .route,
      .comboBox
    ),
    .totalRouteLength
    : (
      String(localized:"Route Length", comment:"This is used for the title of combobox."),
      String(localized:"This is the total length of the selected route.", comment:"This is used for a tooltip."),
      .route,
      .comboBox
    ),
  ]
  
}
