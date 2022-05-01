//
//  SwitchBoardDefs.swift
//  MyTrains
//
//  Created by Paul Willmott on 30/04/2022.
//

import Foundation
import Cocoa

// MARK: SwitchBoardPart

public enum SwitchBoardPart : Int {
  
  case none = -1
  case straight = 0
  case curve = 1
  case longCurve = 2
  case turnoutRight = 3
  case turnoutLeft = 4
  case cross = 5
  case diagonalCross = 6
  case yTurnout = 7
  case turnout3Way = 8
  case leftCurvedTurnout = 9
  case rightCurvedTurnout = 10
  case buffer = 11
  case block = 12
  case feedback = 13
  case link = 14
  case platform = 15
  
  public var partName : String {
    get {
      switch self {
      case .straight:
        return "Straight"
      case .curve:
        return "Curve"
      case .longCurve:
        return "Long Curve"
      case .turnoutRight:
        return "Turnout Right"
      case .turnoutLeft:
        return "Turnout Left"
      case .cross:
        return "Cross"
      case .diagonalCross:
        return "Diagonal Cross"
      case .yTurnout:
        return "Y Turnout"
      case .turnout3Way:
        return "3-Way Turnout"
      case .leftCurvedTurnout:
        return "Left Curved Turnout"
      case .rightCurvedTurnout:
        return "Right Curved Turnout"
      case .buffer:
        return "Buffer"
      case .block:
        return "Block"
      case .feedback:
        return "Feedback"
      case .link:
        return "Link"
      case .platform:
        return "Platform"
      default:
        return "None"
      }
    }
  }
  
}

// MARK: SwitchBoardLocation

public typealias SwitchBoardLocation = (x: Int, y:Int)

// MARK: ShapePartType

public enum ShapePartType {
  case line
  case circle
  case ellipse
  case rectangle
  case square
  case curve
  case irregular
}

// MARK: ActionColor

public enum ActionColor {
  case closed
  case thrown
  case ndeterminate
  case fill
  case stroke
}

// MARK: ShapePart

public typealias ShapePart = (type: ShapePartType, coordinates: [CGPoint], parameters: [CGFloat], actionColors: [ActionColor:NSColor])

// MARK: Shape

public typealias Shape = [ShapePart]

// MARK: SwitchBoardMode

public enum SwitchBoardMode {
  case arrange
  case group
}

