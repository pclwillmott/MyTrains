//
//  SWBRoutePart.swift
//  MyTrains
//
//  Created by Paul Willmott on 13/04/2024.
//

import Foundation

public typealias SWBRoutePart = (
  fromSwitchboardItem: SwitchboardItemNode,
  fromConnectionPointId: Int,
  toSwitchboardItem: SwitchboardItemNode,
  toConnectionPointId: Int,
  turnoutConnection:Int,
  distance: Double,
  routeDirection: RouteDirection
)

public typealias SWBRoute = [SWBRoutePart]

