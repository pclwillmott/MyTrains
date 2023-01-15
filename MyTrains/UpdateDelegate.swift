//
//  UpdateDelegate.swift
//  MyTrains
//
//  Created by Paul Willmott on 14/01/2023.
//

import Foundation

@objc public protocol UpdateDelegate {
  @objc optional func displayUpdate(update:String)
  @objc optional func updateCompleted(success:Bool)
}

@objc public protocol IODevicePropertySheetDelegate {
  @objc optional func reloadData()
}
