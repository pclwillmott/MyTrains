//
//  MessageTiming.swift
//  MyTrains
//
//  Created by Paul Willmott on 14/05/2022.
//

import Foundation

enum MessageTiming {
  static let STANDARD = 20.0 / 1000.0
  static let SWREQ = 20.0 / 1000.0
  static let DISCOVER = 1.0
  static let PRMODE = 2.0
  static let CVOP = 2.0
  static let FAST = 5.0 / 1000.0
  static let IMMPACKET = 100.0 / 1000.0
}
