//
//  NSColorExtensions.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/04/2022.
//

import Foundation
import Cocoa

extension NSColor {
  
  // MARK: Set Fill Color
  
  public static func setFillColor(color: NSColor) {
    switch color {
    case .clear:
      NSColor.clear.setFill()
    case .black:
      NSColor.black.setFill()
    case .white:
      NSColor.white.setFill()
    case .green:
      NSColor.green.setFill()
    case .yellow:
      NSColor.yellow.setFill()
    case .red:
      NSColor.red.setFill()
    case .blue:
      NSColor.blue.setFill()
    case .gray:
      NSColor.gray.setFill()
    case .lightGray:
      NSColor.lightGray.setFill()
    case .darkGray:
      NSColor.darkGray.setFill()
    case .brown:
      NSColor.brown.setFill()
    case .cyan:
      NSColor.cyan.setFill()
    case .magenta:
      NSColor.magenta.setFill()
    case .orange:
      NSColor.orange.setFill()
    case .purple:
      NSColor.purple.setFill()
    case .systemBlue:
      NSColor.systemBlue.setFill()
    case .systemBrown:
      NSColor.systemBrown.setFill()
    case .systemRed:
      NSColor.systemRed.setFill()
    case .systemGray:
      NSColor.systemGray.setFill()
    case .systemMint:
      NSColor.systemMint.setFill()
    case .systemPink:
      NSColor.systemPink.setFill()
    case .systemTeal:
      NSColor.systemTeal.setFill()
    case .systemGreen:
      NSColor.systemGreen.setFill()
    case .systemIndigo:
      NSColor.systemIndigo.setFill()
    case .systemOrange:
      NSColor.systemOrange.setFill()
    case .systemPurple:
      NSColor.systemPurple.setFill()
    case .systemYellow:
      NSColor.systemYellow.setFill()
    default:
      break
    }
  }
  
  // MARK: Set Stroke Color
  
  public static func setStrokeColor(color: NSColor) {
    switch color {
    case .clear:
      NSColor.clear.setStroke()
    case .black:
      NSColor.black.setStroke()
    case .white:
      NSColor.white.setStroke()
    case .green:
      NSColor.green.setStroke()
    case .yellow:
      NSColor.yellow.setStroke()
    case .red:
      NSColor.red.setStroke()
    case .blue:
      NSColor.blue.setStroke()
    case .gray:
      NSColor.gray.setStroke()
    case .lightGray:
      NSColor.lightGray.setStroke()
    case .darkGray:
      NSColor.darkGray.setStroke()
    case .brown:
      NSColor.brown.setStroke()
    case .cyan:
      NSColor.cyan.setStroke()
    case .magenta:
      NSColor.magenta.setStroke()
    case .orange:
      NSColor.orange.setStroke()
    case .purple:
      NSColor.purple.setStroke()
    case .systemBlue:
      NSColor.systemBlue.setStroke()
    case .systemBrown:
      NSColor.systemBrown.setStroke()
    case .systemRed:
      NSColor.systemRed.setStroke()
    case .systemGray:
      NSColor.systemGray.setStroke()
    case .systemMint:
      NSColor.systemMint.setStroke()
    case .systemPink:
      NSColor.systemPink.setStroke()
    case .systemTeal:
      NSColor.systemTeal.setStroke()
    case .systemGreen:
      NSColor.systemGreen.setStroke()
    case .systemIndigo:
      NSColor.systemIndigo.setStroke()
    case .systemOrange:
      NSColor.systemOrange.setStroke()
    case .systemPurple:
      NSColor.systemPurple.setStroke()
    case .systemYellow:
      NSColor.systemYellow.setStroke()
    default:
      break
    }
  }
  
}
