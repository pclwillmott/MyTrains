//
//  OpenLCBConfigurationToolDelegate.swift
//  MyTrains
//
//  Created by Paul Willmott on 02/08/2023.
//

import Foundation

@objc public protocol OpenLCBConfigurationToolDelegate {
  @objc optional func openLCBMessageReceived(message:OpenLCBMessage)
}
