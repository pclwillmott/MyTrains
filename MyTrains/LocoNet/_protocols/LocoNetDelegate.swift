//
//  LocoNetDelegate.swift
//  MyTrains
//
//  Created by Paul Willmott on 02/07/2023.
//

import Foundation

@objc public protocol LocoNetDelegate {
  @objc optional func locoNetInitializationComplete()
  @objc optional func locoNetMessageReceived(message:LocoNetMessage)
}
