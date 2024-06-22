//
//  SpeedProfileDelegate.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/06/2024.
//

import Foundation

@objc public protocol SpeedProfileDelegate {
  @objc optional func inspectorNeedsUpdate(profile:SpeedProfile)
  @objc optional func tableNeedsUpdate(profile:SpeedProfile)
  @objc optional func chartNeedsUpdate(profile:SpeedProfile)
  @objc optional func reloadSamples(profile:SpeedProfile)
}
