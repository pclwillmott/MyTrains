//
//  SwitchBoardDefs.swift
//  MyTrains
//
//  Created by Paul Willmott on 30/04/2022.
//

import Foundation
import AppKit

// MARK: SwitchBoardItemPartType

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
  case closedSW1
  case thrownSW1
  case indeterminateSW1
  case closedSW2
  case thrownSW2
  case indeterminateSW2
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

public enum SwitchBoardItemAction {
  case delete
  case save
  case noAction
}

public typealias RoutePart = (
  fromSwitchBoardItem: SwitchBoardItem,
  fromNodeId: Int,
  toSwitchBoardItem: SwitchBoardItem,
  toNodeId: Int,
  turnoutConnection:Int,
  distance: Double,
  routeDirection: RouteDirection
)

public typealias NodeLink = (switchBoardItem: SwitchBoardItem?, nodeId: Int, routes: [RoutePart])

@objc public protocol LayoutDelegate {
  @objc optional func needsDisplay()
}

public typealias Route = [RoutePart]


