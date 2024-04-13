//
//  SWBRoutePart.swift
//  MyTrains
//
//  Created by Paul Willmott on 13/04/2024.
//

import Foundation

public typealias SWBRoutePart = (
  fromSwitchBoardItem: SwitchboardItemNode,
  fromConnectionPointId: Int,
  toSwitchBoardItem: SwitchboardItemNode,
  toConnectionPointId: Int,
  turnoutConnection:Int,
  distance: Double,
  routeDirection: RouteDirection
)
