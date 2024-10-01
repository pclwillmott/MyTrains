//
//  LayoutButton.swift
//  MyTrains
//
//  Created by Paul Willmott on 27/05/2024.
//

import Foundation
import AppKit
import SGAppKit

public enum LayoutButton : Int, CaseIterable {
  
  // MARK: Enumeration
  
  case zoomIn = 0
  case zoomOut = 1
  case fitToSize = 2
  
  // MARK: Public Properties
  
  public var tooltip : String {
    return LayoutButton.tooltips[self]!
  }

  public var icon : SGIcon {
    return LayoutButton.icons[self]!
  }

  // MARK: Private Class Properties
  
  private static let tooltips : [LayoutButton:String] = [
    .zoomIn    : String(localized: "Zoom In", comment: ""),
    .zoomOut   : String(localized: "Zoom Out", comment: ""),
    .fitToSize : String(localized: "Fit to Size", comment: ""),
  ]

  private static let icons : [LayoutButton:SGIcon] = [
    .zoomIn    : .zoomIn,
    .zoomOut   : .zoomOut,
    .fitToSize : .fitToSize,
  ]

}


