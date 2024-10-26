//
//  TrackPart.swift
//  MyTrains
//
//  Created by Paul Willmott on 25/06/2022.
//

import Foundation

/*
 private static let connections : [SwitchBoardItemPartType:[SwitchBoardConnection]] = [
   .turnoutRight       : [(5,1),(5,2)],
   .turnoutLeft        : [(5,1),(5,0)],
   .cross              : [(7,3),(5,1)],
   .diagonalCross      : [(0,4),(5,1)],
   .yTurnout           : [(5,0),(5,2)],
   .turnout3Way        : [(5,0),(5,1),(5,2)],
   .leftCurvedTurnout  : [(5,7),(5,0)],
   .rightCurvedTurnout : [(5,3),(5,2)],
 ]

 */
public typealias TrackPartInfo = (trackPartId:TrackPart, manufacturer:xManufacturer, brandName:String, title: String, partNumber: String, itemPartType: SwitchboardItemType, trackCode: TrackCode, trackGauge: TrackGauge, frogType:FrogType, dimensions: [Double])

public enum TrackPart : UInt16 {
  
  case custom = 0
  case pecoStreamlineOOHOCode100CatchPointLeftHand = 1
  case pecoStreamlineOOHOCode100SmallRadiusTurnoutRightHand = 2
  case pecoStreamlineOOHOCode100SmallRadiusTurnoutLeftHand = 3
  case pecoStreamlineOOHOCode100SmallRadiusTurnoutRightHandEF = 4
  case pecoStreamlineOOHOCode100SmallRadiusTurnoutLeftHandEF = 5
  case pecoStreamlineOOHOCode100ShortCrossing = 6
  case pecoStreamlineOOHOCode100MediumRadiusTurnoutRightHand = 7
  case pecoStreamlineOOHOCode100MediumRadiusTurnoutLeftHand = 8
  case pecoStreamlineOOHOCode100MediumRadiusTurnoutRightHandEF = 9
  case pecoStreamlineOOHOCode100MediumRadiusTurnoutLeftHandEF = 10
  case pecoStreamlineOOHOCode100LargeRadiusTurnoutRightHand = 11
  case pecoStreamlineOOHOCode100LargeRadiusTurnoutLeftHand = 12
  case pecoStreamlineOOHOCode100LargeRadiusTurnoutRightHandEF = 13
  case pecoStreamlineOOHOCode100LargeRadiusTurnoutLeftHandEF = 14
  case pecoStreamlineOOHOCode100CurvedSmallRadiusTurnoutRightHandUF = 15
  case pecoStreamlineOOHOCode100CurvedSmallRadiusTurnoutLeftHandUF = 16
  case pecoStreamlineOOHOCode100CurvedTurnoutRightHand = 17
  case pecoStreamlineOOHOCode100CurvedTurnoutLeftHand = 18
  case pecoStreamlineOOHOCode100CurvedTurnoutRightHandEF = 19
  case pecoStreamlineOOHOCode100CurvedTurnoutLeftHandEF = 20
  case pecoStreamlineOOHOCode100SmallRadiusYTurnout = 21
  case pecoStreamlineOOHOCode100SmallRadiusYTurnoutEF = 22
  case pecoStreamlineOOHOCode100LargeRadiusYTurnout = 23
  case pecoStreamlineOOHOCode100LargeRadiusYTurnoutEF = 24
  case pecoStreamlineOOHOCode100LongCrossing = 25
  case pecoStreamlineOOHOCode100SingleSlip = 26
  case pecoStreamlineOOHOCode100DoubleSlip = 27
  case pecoStreamlineOOHOCode1003WayTurnout = 28
  case pecoStreamlineOOHOCode1003WayTurnoutEF = 29
  case pecoStreamlineOOHOCode75CatchPointRightHand = 30
  case pecoStreamlineOOHOCode75CatchPointLeftHand = 31
  case pecoStreamlineOOHOCode75SmallRadiusTurnoutRightHandEF = 32
  case pecoStreamlineOOHOCode75SmallRadiusTurnoutLeftHandEF = 33
  case pecoStreamlineOOHOCode75MediumRadiusTurnoutRightHandEF = 34
  case pecoStreamlineOOHOCode75MediumRadiusTurnoutLeftHandEF = 35
  case pecoStreamlineOOHOCode75MediumRadiusTurnoutRightHandEFConcrete = 36
  case pecoStreamlineOOHOCode75MediumRadiusTurnoutLeftHandEFConcrete = 37
  case pecoStreamlineOOHOCode75LargeRadiusTurnoutRightHandEF = 38
  case pecoStreamlineOOHOCode75LargeRadiusTurnoutLeftHandEF = 39
  case pecoStreamlineOOHOCode75CurvedTurnoutRightHandEF = 40
  case pecoStreamlineOOHOCode75CurvedTurnoutLeftHandEF = 41
  case pecoStreamlineOOHOCode75LargeRadiusYTurnoutEF = 42
  case pecoStreamlineOOHOCode75SmallRadiusYTurnoutEF = 43
  case pecoStreamlineOOHOCode75Asymmetric3WayTurnoutEF = 44
  case pecoStreamlineOOHOCode75ShortCrossing = 45
  case pecoStreamlineOOHOCode75ShortCrossingEF = 46
  case pecoStreamlineOOHOCode75LongCrossing = 47
  case pecoStreamlineOOHOCode75LongCrossingEF = 48
  case pecoStreamlineOOHOCode75SingleSlip = 49
  case pecoStreamlineOOHOCode75SingleSlipEF = 50
  case pecoStreamlineOOHOCode75DoubleSlip = 51
  case pecoStreamlineOOHOCode75DoubleSlipEF = 52
  case pecoStreamlineOOHOCode75LargeRadiusTurnoutRightHandUFBullhead = 53
  case pecoStreamlineOOHOCode75LargeRadiusTurnoutLeftHandUFBullhead = 54
  case pecoStreamlineOOHOCode75MediumRadiusTurnoutRightHandUFBullhead = 55
  case pecoStreamlineOOHOCode75MediumRadiusTurnoutLeftHandUFBullhead = 56
  case pecoStreamlineOOHOCode75LongCrossingUFBullhead = 57
  case pecoStreamlineOOHOCode75SingleSlipUFBullhead = 58
  case pecoStreamlineOOHOCode75DoubleSlipUFBullhead = 59
  case pecoSetrackOOHOCode100No2RadiusTurnoutRightHand = 60
  case pecoSetrackOOHOCode100No2RadiusTurnoutLeftHand = 61
  case pecoSetrackOOHOCode100MediumRadiusYTurnout = 62
  case pecoSetrackOOHOCode100CurvedTurnoutRightHand = 63
  case pecoSetrackOOHOCode100CurvedTurnoutLeftHand = 64
  case pecoSetrackOOHOCode100Crossing = 65
  case pecoStreamlineOOHOCode100CatchPointRightHand = 66

  // MARK: Public Properties
  
  public var title : String {
    if let info = partInfo {
      return "\(info.brandName) \(info.trackGauge.title) \(info.trackCode.title) \(info.title) \(info.frogType.title) (\(info.partNumber))"
    }
    return String(localized: "Use Custom Dimensions", comment: "Used as the title for custom dimensions of a track part.")
  }
  
  public var partInfo : TrackPartInfo? {
    if let partInfo = TrackPart.info[self] {
      return partInfo
    }
    return nil
  }
  
  // MARK: Private Class Properties
  
  private static let info : [TrackPart:TrackPartInfo] = [

    .pecoStreamlineOOHOCode100CatchPointRightHand:
    (trackPartId: .pecoStreamlineOOHOCode100CatchPointRightHand,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Catch Point Right Hand",
     partNumber: "SL-84",
     itemPartType: .turnoutRight,
     trackCode: .code100,
     trackGauge: .ho,
     frogType: .insulFrog,
     dimensions: [9.8, 9.8]),

    .pecoStreamlineOOHOCode100CatchPointLeftHand:
    (trackPartId: .pecoStreamlineOOHOCode100CatchPointLeftHand,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Catch Point Left Hand",
     partNumber: "SL-85",
     itemPartType: .turnoutLeft,
     trackCode: .code100,
     trackGauge: .ho,
     frogType: .insulFrog,
     dimensions: [9.8, 9.8]),

    .pecoStreamlineOOHOCode100SmallRadiusTurnoutRightHand:
    (trackPartId: .pecoStreamlineOOHOCode100SmallRadiusTurnoutRightHand,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Small Radius Turnout Right Hand",
     partNumber: "SL-91",
     itemPartType: .turnoutRight,
     trackCode: .code100,
     trackGauge: .ho,
     frogType: .insulFrog,
     dimensions: [18.5, 18.5]),

    .pecoStreamlineOOHOCode100SmallRadiusTurnoutLeftHand:
    (trackPartId: .pecoStreamlineOOHOCode100SmallRadiusTurnoutLeftHand,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Small Radius Turnout Left Hand",
     partNumber: "SL-92",
     itemPartType: .turnoutLeft,
     trackCode: .code100,
     trackGauge: .ho,
     frogType: .insulFrog,
     dimensions: [18.5, 18.5]),

    .pecoStreamlineOOHOCode100SmallRadiusTurnoutRightHandEF:
    (trackPartId: .pecoStreamlineOOHOCode100SmallRadiusTurnoutRightHandEF,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Small Radius Turnout Right Hand",
     partNumber: "SL-E91",
     itemPartType: .turnoutRight,
     trackCode: .code100,
     trackGauge: .ho,
     frogType: .electroFrog,
     dimensions: [18.5, 18.5]),

    .pecoStreamlineOOHOCode100SmallRadiusTurnoutLeftHandEF:
    (trackPartId: .pecoStreamlineOOHOCode100SmallRadiusTurnoutLeftHandEF,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Small Radius Turnout Left Hand",
     partNumber: "SL-E92",
     itemPartType: .turnoutLeft,
     trackCode: .code100,
     trackGauge: .ho,
     frogType: .electroFrog,
     dimensions: [18.5, 18.5]),

    .pecoStreamlineOOHOCode100ShortCrossing:
    (trackPartId: .pecoStreamlineOOHOCode100ShortCrossing,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Short Crossing",
     partNumber: "SL-93",
     itemPartType: .cross,
     trackCode: .code100,
     trackGauge: .ho,
     frogType: .insulFrog,
     dimensions: [12.7, 12.7]),

    .pecoStreamlineOOHOCode100MediumRadiusTurnoutRightHand:
    (trackPartId: .pecoStreamlineOOHOCode100MediumRadiusTurnoutRightHand,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Medium Radius Turnout Right Hand",
     partNumber: "SL-95",
     itemPartType: .turnoutRight,
     trackCode: .code100,
     trackGauge: .ho,
     frogType: .insulFrog,
     dimensions: [21.9, 21.9]),

    .pecoStreamlineOOHOCode100MediumRadiusTurnoutLeftHand:
    (trackPartId: .pecoStreamlineOOHOCode100MediumRadiusTurnoutLeftHand,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Medium Radius Turnout Left Hand",
     partNumber: "SL-96",
     itemPartType: .turnoutLeft,
     trackCode: .code100,
     trackGauge: .ho,
     frogType: .insulFrog,
     dimensions: [21.9, 21.9]),

    .pecoStreamlineOOHOCode100MediumRadiusTurnoutRightHandEF:
    (trackPartId: .pecoStreamlineOOHOCode100MediumRadiusTurnoutRightHandEF,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Medium Radius Turnout Right Hand",
     partNumber: "SL-E95",
     itemPartType: .turnoutRight,
     trackCode: .code100,
     trackGauge: .ho,
     frogType: .electroFrog,
     dimensions: [21.9, 21.9]),

    .pecoStreamlineOOHOCode100MediumRadiusTurnoutLeftHandEF:
    (trackPartId: .pecoStreamlineOOHOCode100MediumRadiusTurnoutLeftHandEF,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Medium Radius Turnout Left Hand",
     partNumber: "SL-E96",
     itemPartType: .turnoutLeft,
     trackCode: .code100,
     trackGauge: .ho,
     frogType: .electroFrog,
     dimensions: [21.9, 21.9]),

    .pecoStreamlineOOHOCode100LargeRadiusTurnoutRightHand:
    (trackPartId: .pecoStreamlineOOHOCode100LargeRadiusTurnoutRightHand,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Large Radius Turnout Right Hand",
     partNumber: "SL-88",
     itemPartType: .turnoutRight,
     trackCode: .code100,
     trackGauge: .ho,
     frogType: .insulFrog,
     dimensions: [25.9, 25.9]),

    .pecoStreamlineOOHOCode100LargeRadiusTurnoutLeftHand:
    (trackPartId: .pecoStreamlineOOHOCode100LargeRadiusTurnoutLeftHand,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Large Radius Turnout Left Hand",
     partNumber: "SL-89",
     itemPartType: .turnoutLeft,
     trackCode: .code100,
     trackGauge: .ho,
     frogType: .insulFrog,
     dimensions: [25.9, 25.9]),

    .pecoStreamlineOOHOCode100LargeRadiusTurnoutRightHandEF:
    (trackPartId: .pecoStreamlineOOHOCode100LargeRadiusTurnoutRightHandEF,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Large Radius Turnout Right Hand",
     partNumber: "SL-E88",
     itemPartType: .turnoutRight,
     trackCode: .code100,
     trackGauge: .ho,
     frogType: .electroFrog,
     dimensions: [25.9, 25.9]),

    .pecoStreamlineOOHOCode100LargeRadiusTurnoutLeftHandEF:
    (trackPartId: .pecoStreamlineOOHOCode100LargeRadiusTurnoutLeftHandEF,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Large Radius Turnout Left Hand",
     partNumber: "SL-E89",
     itemPartType: .turnoutLeft,
     trackCode: .code100,
     trackGauge: .ho,
     frogType: .electroFrog,
     dimensions: [25.9, 25.9]),

    .pecoStreamlineOOHOCode100CurvedSmallRadiusTurnoutRightHandUF:
    (trackPartId: .pecoStreamlineOOHOCode100CurvedSmallRadiusTurnoutRightHandUF,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Curved Small Radius Turnout Right Hand",
     partNumber: "SL-U76",
     itemPartType: .rightCurvedTurnout,
     trackCode: .code100,
     trackGauge: .ho,
     frogType: .uniFrog,
     dimensions: [16.8, 16.8]),

    .pecoStreamlineOOHOCode100CurvedSmallRadiusTurnoutLeftHandUF:
    (trackPartId: .pecoStreamlineOOHOCode100CurvedSmallRadiusTurnoutLeftHandUF,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Curved Small Radius Turnout Left Hand",
     partNumber: "SL-U77",
     itemPartType: .leftCurvedTurnout,
     trackCode: .code100,
     trackGauge: .ho,
     frogType: .uniFrog,
     dimensions: [16.8, 16.8]),

    .pecoStreamlineOOHOCode100CurvedTurnoutRightHand:
    (trackPartId: .pecoStreamlineOOHOCode100CurvedTurnoutRightHand,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Curved Turnout Right Hand",
     partNumber: "SL-86",
     itemPartType: .rightCurvedTurnout,
     trackCode: .code100,
     trackGauge: .ho,
     frogType: .insulFrog,
     dimensions: [25.8, 25.8]),

    .pecoStreamlineOOHOCode100CurvedTurnoutLeftHand:
    (trackPartId: .pecoStreamlineOOHOCode100CurvedTurnoutLeftHand,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Curved Turnout Left Hand",
     partNumber: "SL-87",
     itemPartType: .leftCurvedTurnout,
     trackCode: .code100,
     trackGauge: .ho,
     frogType: .insulFrog,
     dimensions: [25.8, 25.8]),

    .pecoStreamlineOOHOCode100CurvedTurnoutRightHandEF:
    (trackPartId: .pecoStreamlineOOHOCode100CurvedTurnoutRightHandEF,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Curved Turnout Right Hand",
     partNumber: "SL-E86",
     itemPartType: .rightCurvedTurnout,
     trackCode: .code100,
     trackGauge: .ho,
     frogType: .electroFrog,
     dimensions: [25.8, 25.8]),

    .pecoStreamlineOOHOCode100CurvedTurnoutLeftHandEF:
    (trackPartId: .pecoStreamlineOOHOCode100CurvedTurnoutLeftHandEF,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Curved Turnout Left Hand",
     partNumber: "SL-E87",
     itemPartType: .leftCurvedTurnout,
     trackCode: .code100,
     trackGauge: .ho,
     frogType: .electroFrog,
     dimensions: [25.8, 25.8]),

    .pecoStreamlineOOHOCode100SmallRadiusYTurnout:
    (trackPartId: .pecoStreamlineOOHOCode100SmallRadiusYTurnout,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Small Radius Y Turnout",
     partNumber: "SL-97",
     itemPartType: .yTurnout,
     trackCode: .code100,
     trackGauge: .ho,
     frogType: .insulFrog,
     dimensions: [14.8, 14.8]),

    .pecoStreamlineOOHOCode100SmallRadiusYTurnoutEF:
    (trackPartId: .pecoStreamlineOOHOCode100SmallRadiusYTurnoutEF,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Small Radius Y Turnout",
     partNumber: "SL-E97",
     itemPartType: .yTurnout,
     trackCode: .code100,
     trackGauge: .ho,
     frogType: .electroFrog,
     dimensions: [14.8, 14.8]),

    .pecoStreamlineOOHOCode100LargeRadiusYTurnout:
    (trackPartId: .pecoStreamlineOOHOCode100LargeRadiusYTurnout,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Large Radius Y Turnout",
     partNumber: "SL-98",
     itemPartType: .yTurnout,
     trackCode: .code100,
     trackGauge: .ho,
     frogType: .insulFrog,
     dimensions: [22.0, 22.0]),

    .pecoStreamlineOOHOCode100LargeRadiusYTurnoutEF:
    (trackPartId: .pecoStreamlineOOHOCode100LargeRadiusYTurnoutEF,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Large Radius Y Turnout",
     partNumber: "SL-E98",
     itemPartType: .yTurnout,
     trackCode: .code100,
     trackGauge: .ho,
     frogType: .electroFrog,
     dimensions: [22.0, 22.0]),

    .pecoStreamlineOOHOCode100LongCrossing:
    (trackPartId: .pecoStreamlineOOHOCode100LongCrossing,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Long Crossing",
     partNumber: "SL-94",
     itemPartType: .cross,
     trackCode: .code100,
     trackGauge: .ho,
     frogType: .insulFrog,
     dimensions: [24.9, 24.9]),

    .pecoStreamlineOOHOCode100SingleSlip:
    (trackPartId: .pecoStreamlineOOHOCode100SingleSlip,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Single Slip",
     partNumber: "SL-80",
     itemPartType: .singleSlip,
     trackCode: .code100,
     trackGauge: .ho,
     frogType: .insulFrog,
     dimensions: [24.9, 24.9, 24.9]),

    .pecoStreamlineOOHOCode100DoubleSlip:
    (trackPartId: .pecoStreamlineOOHOCode100DoubleSlip,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Double Slip",
     partNumber: "SL-90",
     itemPartType: .doubleSlip,
     trackCode: .code100,
     trackGauge: .ho,
     frogType: .insulFrog,
     dimensions: [24.9, 24.9, 24.9, 24.9]),

    .pecoStreamlineOOHOCode1003WayTurnout:
    (trackPartId: .pecoStreamlineOOHOCode1003WayTurnout,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "3 Way Turnout",
     partNumber: "SL-99",
     itemPartType: .turnout3Way,
     trackCode: .code100,
     trackGauge: .ho,
     frogType: .insulFrog,
     dimensions: [22.0, 22.0, 22.0]),

    .pecoStreamlineOOHOCode1003WayTurnoutEF:
    (trackPartId: .pecoStreamlineOOHOCode1003WayTurnoutEF,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "3 Way Turnout",
     partNumber: "SL-E99",
     itemPartType: .turnout3Way,
     trackCode: .code100,
     trackGauge: .ho,
     frogType: .electroFrog,
     dimensions: [22.0, 22.0, 22.0]),

    .pecoStreamlineOOHOCode75CatchPointRightHand:
    (trackPartId: .pecoStreamlineOOHOCode75CatchPointRightHand,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Catch Point Right Hand",
     partNumber: "SL-184",
     itemPartType: .turnoutRight,
     trackCode: .code75,
     trackGauge: .ho,
     frogType: .insulFrog,
     dimensions: [9.1, 9.1]),

    .pecoStreamlineOOHOCode75CatchPointLeftHand:
    (trackPartId: .pecoStreamlineOOHOCode75CatchPointLeftHand,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Catch Point Left Hand",
     partNumber: "SL-185",
     itemPartType: .turnoutLeft,
     trackCode: .code75,
     trackGauge: .ho,
     frogType: .insulFrog,
     dimensions: [9.1, 9.1]),

    .pecoStreamlineOOHOCode75SmallRadiusTurnoutRightHandEF:
    (trackPartId: .pecoStreamlineOOHOCode75SmallRadiusTurnoutRightHandEF,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Small Radius Turnout Right Hand",
     partNumber: "SL-E191",
     itemPartType: .turnoutRight,
     trackCode: .code75,
     trackGauge: .ho,
     frogType: .electroFrog,
     dimensions: [18.5, 18.5]),

    .pecoStreamlineOOHOCode75SmallRadiusTurnoutLeftHandEF:
    (trackPartId: .pecoStreamlineOOHOCode75SmallRadiusTurnoutLeftHandEF,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Small Radius Turnout Left Hand",
     partNumber: "SL-E192",
     itemPartType: .turnoutLeft,
     trackCode: .code75,
     trackGauge: .ho,
     frogType: .electroFrog,
     dimensions: [18.5, 18.5]),

    .pecoStreamlineOOHOCode75MediumRadiusTurnoutRightHandEF:
    (trackPartId: .pecoStreamlineOOHOCode75MediumRadiusTurnoutRightHandEF,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Medium Radius Turnout Right Hand",
     partNumber: "SL-E195",
     itemPartType: .turnoutRight,
     trackCode: .code75,
     trackGauge: .ho,
     frogType: .electroFrog,
     dimensions: [21.9, 21.9]),

    .pecoStreamlineOOHOCode75MediumRadiusTurnoutLeftHandEF:
    (trackPartId: .pecoStreamlineOOHOCode75MediumRadiusTurnoutLeftHandEF,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Medium Radius Turnout Left Hand",
     partNumber: "SL-E196",
     itemPartType: .turnoutLeft,
     trackCode: .code75,
     trackGauge: .ho,
     frogType: .electroFrog,
     dimensions: [21.9, 21.9]),

    .pecoStreamlineOOHOCode75MediumRadiusTurnoutRightHandEFConcrete:
    (trackPartId: .pecoStreamlineOOHOCode75MediumRadiusTurnoutRightHandEFConcrete,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Medium Radius Turnout Right Hand Concrete",
     partNumber: "SL-E1095",
     itemPartType: .turnoutRight,
     trackCode: .code75,
     trackGauge: .ho,
     frogType: .electroFrog,
     dimensions: [21.9, 21.9]),

    .pecoStreamlineOOHOCode75MediumRadiusTurnoutLeftHandEFConcrete:
    (trackPartId: .pecoStreamlineOOHOCode75MediumRadiusTurnoutLeftHandEFConcrete,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Medium Radius Turnout Left Hand Concrete",
     partNumber: "SL-E1096",
     itemPartType: .turnoutLeft,
     trackCode: .code75,
     trackGauge: .ho,
     frogType: .electroFrog,
     dimensions: [21.9, 21.9]),

    .pecoStreamlineOOHOCode75LargeRadiusTurnoutRightHandEF:
    (trackPartId: .pecoStreamlineOOHOCode75LargeRadiusTurnoutRightHandEF,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Large Radius Turnout Right Hand",
     partNumber: "SL-E188",
     itemPartType: .turnoutRight,
     trackCode: .code75,
     trackGauge: .ho,
     frogType: .electroFrog,
     dimensions: [25.9, 25.9]),

    .pecoStreamlineOOHOCode75LargeRadiusTurnoutLeftHandEF:
    (trackPartId: .pecoStreamlineOOHOCode75LargeRadiusTurnoutLeftHandEF,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Large Radius Turnout Left Hand",
     partNumber: "SL-E189",
     itemPartType: .turnoutLeft,
     trackCode: .code75,
     trackGauge: .ho,
     frogType: .electroFrog,
     dimensions: [25.9, 25.9]),

    .pecoStreamlineOOHOCode75CurvedTurnoutRightHandEF:
    (trackPartId: .pecoStreamlineOOHOCode75CurvedTurnoutRightHandEF,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Curved Turnout Right Hand",
     partNumber: "SL-E186",
     itemPartType: .rightCurvedTurnout,
     trackCode: .code75,
     trackGauge: .ho,
     frogType: .electroFrog,
     dimensions: [25.8, 25.8]),

    .pecoStreamlineOOHOCode75CurvedTurnoutLeftHandEF:
    (trackPartId: .pecoStreamlineOOHOCode75CurvedTurnoutLeftHandEF,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Curved Turnout Left Hand",
     partNumber: "SL-E187",
     itemPartType: .leftCurvedTurnout,
     trackCode: .code75,
     trackGauge: .ho,
     frogType: .electroFrog,
     dimensions: [25.8, 25.8]),

    .pecoStreamlineOOHOCode75LargeRadiusYTurnoutEF:
    (trackPartId: .pecoStreamlineOOHOCode75LargeRadiusYTurnoutEF,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Large Radius Y Turnout",
     partNumber: "SL-E198",
     itemPartType: .yTurnout,
     trackCode: .code75,
     trackGauge: .ho,
     frogType: .electroFrog,
     dimensions: [22.0, 22.0]),

    .pecoStreamlineOOHOCode75SmallRadiusYTurnoutEF:
    (trackPartId: .pecoStreamlineOOHOCode75SmallRadiusYTurnoutEF,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Small Radius Y Turnout",
     partNumber: "SL-E197",
     itemPartType: .yTurnout,
     trackCode: .code75,
     trackGauge: .ho,
     frogType: .electroFrog,
     dimensions: [14.8, 14.8]),

    .pecoStreamlineOOHOCode75Asymmetric3WayTurnoutEF:
    (trackPartId: .pecoStreamlineOOHOCode75Asymmetric3WayTurnoutEF,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Asymmetric 3 Way Turnout",
     partNumber: "SL-E199",
     itemPartType: .turnout3Way,
     trackCode: .code75,
     trackGauge: .ho,
     frogType: .electroFrog,
     dimensions: [27.3, 27.3, 27.3]),

    .pecoStreamlineOOHOCode75ShortCrossing:
    (trackPartId: .pecoStreamlineOOHOCode75ShortCrossing,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Short Crossing",
     partNumber: "SL-193",
     itemPartType: .cross,
     trackCode: .code75,
     trackGauge: .ho,
     frogType: .insulFrog,
     dimensions: [12.7, 12.7]),

    .pecoStreamlineOOHOCode75ShortCrossingEF:
    (trackPartId: .pecoStreamlineOOHOCode75ShortCrossingEF,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Short Crossing",
     partNumber: "SL-E193",
     itemPartType: .cross,
     trackCode: .code75,
     trackGauge: .ho,
     frogType: .electroFrog,
     dimensions: [12.7, 12.7]),

    .pecoStreamlineOOHOCode75LongCrossing:
    (trackPartId: .pecoStreamlineOOHOCode75LongCrossing,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Long Crossing",
     partNumber: "SL-194",
     itemPartType: .cross,
     trackCode: .code75,
     trackGauge: .ho,
     frogType: .insulFrog,
     dimensions: [24.9, 24.9]),

    .pecoStreamlineOOHOCode75LongCrossingEF:
    (trackPartId: .pecoStreamlineOOHOCode75LongCrossingEF,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Long Crossing",
     partNumber: "SL-E194",
     itemPartType: .cross,
     trackCode: .code75,
     trackGauge: .ho,
     frogType: .insulFrog,
     dimensions: [24.9, 24.9]),

    .pecoStreamlineOOHOCode75SingleSlip:
    (trackPartId: .pecoStreamlineOOHOCode75SingleSlip,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Single Slip",
     partNumber: "SL-180",
     itemPartType: .singleSlip,
     trackCode: .code75,
     trackGauge: .ho,
     frogType: .insulFrog,
     dimensions: [24.9, 24.9, 24.9]),

    .pecoStreamlineOOHOCode75SingleSlipEF:
    (trackPartId: .pecoStreamlineOOHOCode75SingleSlipEF,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Single Slip",
     partNumber: "SL-E180",
     itemPartType: .singleSlip,
     trackCode: .code75,
     trackGauge: .ho,
     frogType: .electroFrog,
     dimensions: [24.9, 24.9, 24.9]),

    .pecoStreamlineOOHOCode75DoubleSlip:
    (trackPartId: .pecoStreamlineOOHOCode75DoubleSlip,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Double Slip",
     partNumber: "SL-190",
     itemPartType: .doubleSlip,
     trackCode: .code75,
     trackGauge: .ho,
     frogType: .insulFrog,
     dimensions: [24.9, 24.9, 24.9, 24.9]),

    .pecoStreamlineOOHOCode75DoubleSlipEF:
    (trackPartId: .pecoStreamlineOOHOCode75DoubleSlipEF,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Double Slip",
     partNumber: "SL-E190",
     itemPartType: .doubleSlip,
     trackCode: .code75,
     trackGauge: .ho,
     frogType: .electroFrog,
     dimensions: [24.9, 24.9, 24.9, 24.9]),

    .pecoStreamlineOOHOCode75LargeRadiusTurnoutRightHandUFBullhead:
    (trackPartId: .pecoStreamlineOOHOCode75LargeRadiusTurnoutRightHandUFBullhead,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Large Radius Turnout Right Hand Bullhead",
     partNumber: "SL-U1188",
     itemPartType: .turnoutRight,
     trackCode: .code75,
     trackGauge: .ho,
     frogType: .uniFrog,
     dimensions: [25.9, 25.9]),

    .pecoStreamlineOOHOCode75LargeRadiusTurnoutLeftHandUFBullhead:
    (trackPartId: .pecoStreamlineOOHOCode75LargeRadiusTurnoutLeftHandUFBullhead,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Large Radius Turnout Left Hand Bullhead",
     partNumber: "SL-U1189",
     itemPartType: .turnoutLeft,
     trackCode: .code75,
     trackGauge: .ho,
     frogType: .uniFrog,
     dimensions: [25.9, 25.9]),

    .pecoStreamlineOOHOCode75MediumRadiusTurnoutRightHandUFBullhead:
    (trackPartId: .pecoStreamlineOOHOCode75MediumRadiusTurnoutRightHandUFBullhead,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Medium Radius Turnout Right Hand Bullhead",
     partNumber: "SL-U1195",
     itemPartType: .turnoutRight,
     trackCode: .code75,
     trackGauge: .ho,
     frogType: .uniFrog,
     dimensions: [21.9, 21.9]),

    .pecoStreamlineOOHOCode75MediumRadiusTurnoutLeftHandUFBullhead:
    (trackPartId: .pecoStreamlineOOHOCode75MediumRadiusTurnoutLeftHandUFBullhead,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Medium Radius Turnout Left Hand Bullhead",
     partNumber: "SL-U1196",
     itemPartType: .turnoutLeft,
     trackCode: .code75,
     trackGauge: .ho,
     frogType: .uniFrog,
     dimensions: [21.9, 21.9]),

    .pecoStreamlineOOHOCode75LongCrossingUFBullhead:
    (trackPartId: .pecoStreamlineOOHOCode75LongCrossingUFBullhead,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Long Crossing Bullhead",
     partNumber: "SL-U1194",
     itemPartType: .cross,
     trackCode: .code75,
     trackGauge: .ho,
     frogType: .uniFrog,
     dimensions: [24.9, 24.9]),

    .pecoStreamlineOOHOCode75SingleSlipUFBullhead:
    (trackPartId: .pecoStreamlineOOHOCode75SingleSlipUFBullhead,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Single Slip Bullhead",
     partNumber: "SL-U1180",
     itemPartType: .singleSlip,
     trackCode: .code75,
     trackGauge: .ho,
     frogType: .uniFrog,
     dimensions: [24.9, 24.9, 24.9]),

    .pecoStreamlineOOHOCode75DoubleSlipUFBullhead:
    (trackPartId: .pecoStreamlineOOHOCode75DoubleSlipUFBullhead,
     manufacturer: .peco,
     brandName: "PECO Streamline",
     title: "Double Slip Bullhead",
     partNumber: "SL-U1190",
     itemPartType: .doubleSlip,
     trackCode: .code75,
     trackGauge: .ho,
     frogType: .uniFrog,
     dimensions: [24.9, 24.9, 24.9, 24.9]),

    .pecoSetrackOOHOCode100No2RadiusTurnoutRightHand:
    (trackPartId: .pecoSetrackOOHOCode100No2RadiusTurnoutRightHand,
     manufacturer: .peco,
     brandName: "PECO Setrack",
     title: "No. 2 Radius Turnout Right Hand",
     partNumber: "ST-240",
     itemPartType: .turnoutRight,
     trackCode: .code100,
     trackGauge: .ho,
     frogType: .insulFrog,
     dimensions: [16.8, 16.8]),

    .pecoSetrackOOHOCode100No2RadiusTurnoutLeftHand:
    (trackPartId: .pecoSetrackOOHOCode100No2RadiusTurnoutLeftHand,
     manufacturer: .peco,
     brandName: "PECO Setrack",
     title: "No. 2 Radius Turnout Left Hand",
     partNumber: "ST-241",
     itemPartType: .turnoutLeft,
     trackCode: .code100,
     trackGauge: .ho,
     frogType: .insulFrog,
     dimensions: [16.8, 16.8]),

    .pecoSetrackOOHOCode100MediumRadiusYTurnout:
    (trackPartId: .pecoSetrackOOHOCode100MediumRadiusYTurnout,
     manufacturer: .peco,
     brandName: "PECO Setrack",
     title: "Medium Radius Y Turnout",
     partNumber: "ST-247",
     itemPartType: .yTurnout,
     trackCode: .code100,
     trackGauge: .ho,
     frogType: .insulFrog,
     dimensions: [17.0, 17.0]),

    .pecoSetrackOOHOCode100CurvedTurnoutRightHand:
    (trackPartId: .pecoSetrackOOHOCode100CurvedTurnoutRightHand,
     manufacturer: .peco,
     brandName: "PECO Setrack",
     title: "Curved Turnout Right Hand",
     partNumber: "ST-244",
     itemPartType: .rightCurvedTurnout,
     trackCode: .code100,
     trackGauge: .ho,
     frogType: .insulFrog,
     dimensions: [16.8, 16.8]), // these values are incorrect

    .pecoSetrackOOHOCode100CurvedTurnoutLeftHand:
    (trackPartId: .pecoSetrackOOHOCode100CurvedTurnoutLeftHand,
     manufacturer: .peco,
     brandName: "PECO Setrack",
     title: "Curved Turnout Left Hand",
     partNumber: "ST-245",
     itemPartType: .leftCurvedTurnout,
     trackCode: .code100,
     trackGauge: .ho,
     frogType: .insulFrog,
     dimensions: [16.8, 16.8]), // these values are incorrect

    .pecoSetrackOOHOCode100Crossing:
    (trackPartId: .pecoSetrackOOHOCode100Crossing,
     manufacturer: .peco,
     brandName: "PECO Setrack",
     title: "Crossing",
     partNumber: "ST-250",
     itemPartType: .cross,
     trackCode: .code100,
     trackGauge: .ho,
     frogType: .insulFrog,
     dimensions: [16.8, 16.8]),

  ]
  
  public static let mapPlaceholder = CDI.TRACK_PART

  private static func map(itemType:SwitchboardItemType, layout:LayoutNode) -> String {

    var gauges : Set<TrackGauge> = []
    
    if layout.scale == .scale1to76dot2 && (layout.defaultTrackGuage == .ho || layout.usesMultipleTrackGauges) {
      gauges.insert(.ho)
    }
    
    for (id, data) in TrackGauge.data {
      if data.ratio == layout.scale && (data.gauge == layout.defaultTrackGuage || layout.usesMultipleTrackGauges) {
        gauges.insert(id)
      }
    }

    var items : [TrackPart] = []
    
    for (_, item) in info {
      if item.itemPartType == itemType && gauges.contains(item.trackGauge) {
        items.append(item.trackPartId)
      }
    }
    
    items.sort {$0.title < $1.title}
    
    items.insert(.custom, at: 0)
    
    var map = "<map>\n"

    for item in items {
      map += "<relation><property>\(item.rawValue)</property><value>\(item.title)</value></relation>\n"
    }

    map += "</map>\n"

    return map

  }

  // MARK: Public Class Methods
  
  public static func insertMap(cdi:String, itemType:SwitchboardItemType, layout:LayoutNode?) -> String {
    guard let layout else {
      return cdi
    }
    return cdi.replacingOccurrences(of: mapPlaceholder, with: map(itemType: itemType, layout: layout))
  }
/*
  public static func dictionary(itemPartType:SwitchboardItemType, trackGauge:TrackGauge) -> [Int:TrackPartEditorObject] {
    
    var result : [Int:TrackPartEditorObject] = [:]
    
    for (_, part) in info {
      if part.trackPartId == .custom || (part.itemPartType == itemPartType && part.trackGauge == trackGauge) {
        let editorObject = TrackPartEditorObject(trackPart: part.trackPartId)
        result[editorObject.primaryKey] = editorObject
      }
    }
    let editorObject = TrackPartEditorObject(trackPart: .custom)
    result[editorObject.primaryKey] = editorObject
    
    return result
    
  }
}
 */

// MARK: TrackPartEditorObject
/*
public class TrackPartEditorObject : EditorObject {
  
  // MARK: Constructors
  
  init(trackPart:TrackPart) {
    self.trackPart = trackPart
    super.init(primaryKey: Int(trackPart.rawValue))
  }
  
  // MARK: Public Properties
  
  public var trackPart : TrackPart
  
  // MARK: Public Methods
  
  override public func displayString() -> String {
    return trackPart.title
  }
*/
}
