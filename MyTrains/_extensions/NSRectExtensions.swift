//
//  NSRectExtensions.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/04/2022.
//

import Foundation
import Cocoa

extension NSRect {
  
  init(coordinates: [CGPoint]) {
    
    guard coordinates.count > 1 else {
      self.init()
      return
    }
    
    let x1 = coordinates[0].x
    
    let y1 = coordinates[0].y
    
    let x2 = coordinates[1].x
    
    let y2 = coordinates[1].y
    
    self.init(x: min(x1, x2), y: min(y1, y2), width: abs(x1 - x2), height: abs(y1 - y2))
    
  }
  
}
