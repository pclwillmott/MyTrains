//
//  SwitchBoardItemPartType.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/06/2022.
//

import Foundation
import AppKit

public typealias SwitchBoardConnection = (from:Int, to:Int)

public enum SwitchBoardItemPartType : Int {
  
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
  case singleSlip = 16
  case doubleSlip = 17
  case none = -1

  public var partName : String {
    get {
      return self == .none ? "None" : SwitchBoardItemPartType.titles[self.rawValue]
    }
  }
  
  public var connections : [SwitchBoardConnection] {
    get {
      return SwitchBoardItemPartType.connections[self] ?? []
    }
  }
  
  public func pointsSet(orientation:Orientation) -> Set<Int> {
    var result : Set<Int> = []
    for connection in connections {
      if connection.from != -1 {
        let from = (connection.from + orientation.rawValue) % 8
        result.insert(from)
      }
      if connection.to != -1 {
        let to = (connection.to + orientation.rawValue) % 8
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
      if let to = lookup[(connection.to + orientation.rawValue) % 8], let from = lookup[(connection.from + orientation.rawValue) % 8] {
        let label = to < from ? "\(to) to \(from)" : "\(from) to \(to)"
        result.append((index:index, label:label))
      }
      index += 1
    }
    
    return result.sorted {$0.label < $1.label}
  }
  
  private static let connections : [SwitchBoardItemPartType:[SwitchBoardConnection]] = [
    .straight           : [(5,1)],
    .curve              : [(5,3)],
    .longCurve          : [(5,2)],
    .turnoutRight       : [(5,1),(5,2)],
    .turnoutLeft        : [(5,1),(5,0)],
    .cross              : [(7,3),(5,1)],
    .diagonalCross      : [(0,4),(5,1)],
    .yTurnout           : [(5,0),(5,2)],
    .turnout3Way        : [(5,0),(5,1),(5,2)],
    .leftCurvedTurnout  : [(5,7),(5,0)],
    .rightCurvedTurnout : [(5,3),(5,2)],
    .buffer             : [],
    .block              : [(5,1)],
    .feedback           : [(5,1)],
    .link               : [(5,-1)],
    .platform           : [],
    .none               : [],
    .singleSlip         : [],
    .doubleSlip         : [],
  ]
  
  private static let titles = [
    "Straight",
    "Curve",
    "Long Curve",
    "Turnout Right",
    "Turnout Left",
    "Cross",
    "Diagonal Cross",
    "Y Turnout",
    "3-Way Turnout",
    "Left Curved Turnout",
    "Right Curved Turnout",
    "Buffer",
    "Block",
    "Feedback",
    "Link",
    "Platform",
    "Single Slip",
    "Double Slip",
  ]
  
  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
  }
  
  public static func select(comboBox: NSComboBox, partType:SwitchBoardItemPartType) {
    comboBox.selectItem(at: partType.rawValue)
  }
  
  public static func selected(comboBox: NSComboBox) -> SwitchBoardItemPartType {
    return SwitchBoardItemPartType(rawValue: comboBox.indexOfSelectedItem) ?? .none
  }
  
}

