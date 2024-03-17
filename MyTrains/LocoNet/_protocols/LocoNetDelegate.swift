//
//  LocoNetDelegate.swift
//  MyTrains
//
//  Created by Paul Willmott on 02/07/2023.
//

import Foundation

@objc public protocol LocoNetDelegate {
  @objc optional func locoNetStartupComplete()
  @objc optional func locoNetStartupFailed()
  @objc optional func locoNetStopComplete()
  @objc optional func locoNetMessageReceived(message:LocoNetMessage)
}
