//
//  MyIcon.swift
//  MyTrains
//
//  Created by Paul Willmott on 16/04/2024.
//

import Foundation
import AppKit

public enum MyIcon : String {
  
  // MARK: Enumeration
  
  case addItem                = "AddItem"
  case addToGroup             = "AddToGroup"
  case bolt                   = "Bolt"
  case bottomThird            = "BottomThird"
  case connection             = "Connection"
  case cursor                 = "Cursor"
  case fitToSize              = "FitToSize"
  case gear                   = "Gear"
  case groupMode              = "GroupMode"
  case help                   = "Help"
  case info                   = "Info"
  case leadingThird           = "LeadingThird"
  case locationFinder         = "LocationFinder"
  case map                    = "Map"
  case removeFromGroup        = "RemoveFromGroup"
  case removeItem             = "RemoveItem"
  case rotateClockwise        = "RotateClockwise"
  case rotateCounterClockwise = "RotateCounterClockwise"
  case speedometer            = "Speedometer"
  case trailingThird          = "TrailingThird"
  case zoomIn                 = "ZoomIn"
  case zoomOut                = "ZoomOut"
  case wrench                 = "Wrench"
  case lightbulb              = "LightBulb"
  case gearshift              = "GearShift"
  case speaker                = "Speaker"
  case sliderVertical         = "SliderVertical"
  case smoke                  = "Smoke"
  case brake                  = "Brake"
  case engine                 = "Engine"
  case envelope               = "Envelope"
  case button                 = "Button"
  case id                     = "ID"
  case sunglasses             = "Sunglasses"
  
  // MARK: Public Methods
  
  public func button(target: Any?, action: Selector?) -> NSButton? {
    guard let image = NSImage(named: self.rawValue) else {
      return nil
    }
    return NSButton(image: image, target: target, action: action)
  }
  
}
