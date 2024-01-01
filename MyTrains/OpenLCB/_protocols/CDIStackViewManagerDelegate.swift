//
//  CDIStackManagerDelegate.swift
//  MyTrains
//
//  Created by Paul Willmott on 01/01/2024.
//

import Foundation
import AppKit

@objc public protocol CDIStackViewManagerDelegate {
  @objc optional func addArrangedSubview(_ view:NSView)
}
