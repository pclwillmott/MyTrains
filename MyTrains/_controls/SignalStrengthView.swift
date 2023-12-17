//
//  SignalStrengthView.swift
//  MyTrains
//
//  Created by Paul Willmott on 15/04/2022.
//

import Cocoa
import Foundation

@IBDesignable
class SignalStrengthView: NSView {

  // MARK: Public Properties

  public var max : [Double] = [] {
    didSet {
      needsDisplay = true
    }
  }
  
  public var current : [Double] = [] {
    didSet {
      needsDisplay = true
    }
  }
  
  public var average : [Double] = [] {
    didSet {
      needsDisplay = true
    }
  }
  
  override func draw(_ dirtyRect: NSRect) {

    let maxValue = 256.0
    
    super.draw(dirtyRect)

    NSColor.black.setFill()
    bounds.fill()

    let context = NSGraphicsContext.current?.cgContext
    
    // Grid Lines
    
    context?.setStrokeColor(NSColor.gray.cgColor)
    for y in 1...9 {
      let dy = CGFloat(y) * bounds.height / 10.0
      let horiPath = NSBezierPath()
      horiPath.lineWidth = 1
      horiPath.move(to: NSMakePoint(0, dy))
      horiPath.line(to: NSMakePoint(bounds.width, dy))
      horiPath.close()
      horiPath.stroke()
      for x in 1...15 {
        let dx = CGFloat(x) * bounds.width / 16.0
        let vertPath = NSBezierPath()
        vertPath.lineWidth = 1
        vertPath.move(to: NSMakePoint(dx, 0))
        vertPath.line(to: NSMakePoint(dx, bounds.height))
        vertPath.close()
        vertPath.stroke()
      }
    }
    
    // Current Value
  
    if current.count > 0 {
      NSColor.systemBlue.setFill()
      for cn in 0...15 {
        let dw = bounds.width / 16.0
        let dx = CGFloat(cn) * bounds.width / 16.0
        let dy = (bounds.height / maxValue) * current[cn]
        let path = NSBezierPath()
        path.move(to: NSMakePoint(dx, 0))
        path.line(to: NSMakePoint(dx, dy))
        path.line(to: NSMakePoint(dx+dw, dy))
        path.line(to: NSMakePoint(dx+dw, 0))
        path.close()
        path.fill()
      }
    }

    // Dash Line
    
    let dy = CGFloat(97) / maxValue * bounds.height
    context?.setStrokeColor(NSColor.green.cgColor)
    let dashPath = NSBezierPath()
    dashPath.setLineDash([2,3], count: 2, phase: 1.0)
    dashPath.lineWidth = 3
    dashPath.move(to: NSMakePoint(0, dy))
    dashPath.line(to: NSMakePoint(bounds.width, dy))
    dashPath.close()
    dashPath.stroke()

    // Max Value
 
    if max.count > 0 {
      context?.setStrokeColor(NSColor.red.cgColor)
      let path = NSBezierPath()
      let dw = bounds.width / 16.0
      path.lineWidth = 3
      path.move(to: NSMakePoint(0.0, 0.0))
      for cn in 0...15 {
        let dx = CGFloat(cn) * dw + dw / 2.0
        let dy = (bounds.height / maxValue) * max[cn]
        path.line(to: NSMakePoint(dx, dy))
      }
      path.line(to: NSMakePoint(bounds.width, 0.0))
      path.close()
      path.stroke()
    }
  
    // Average Value
 
    if average.count > 0 {
      context?.setStrokeColor(NSColor.orange.cgColor)
      let path = NSBezierPath()
      let dw = bounds.width / 16.0
      path.lineWidth = 3
      path.move(to: NSMakePoint(0.0, 0.0))
      for cn in 0...15 {
        let dx = CGFloat(cn) * dw + dw / 2.0
        let dy = (bounds.height / maxValue) * average[cn]
        path.line(to: NSMakePoint(dx, dy))
      }
      path.line(to: NSMakePoint(bounds.width, 0.0))
      path.close()
      path.stroke()
    }

    // Channel Numbers
 
    for cn in 0...15 {
      let text = "\(cn+11)"
      let font = NSFont.boldSystemFont(ofSize: 16)
      let dx = CGFloat(cn) * bounds.width / 16.0
      let dw = bounds.width / 16.0
      let dh = bounds.height / 10.0
      let textRect = CGRect(x: dx + dw / 4 , y: dh * 9, width: dw , height: dh)
      let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
      let textFontAttributes = [
          NSAttributedString.Key.font: font,
          NSAttributedString.Key.foregroundColor: NSColor.gray,
          NSAttributedString.Key.paragraphStyle: textStyle
      ] as [NSAttributedString.Key : Any]
      text.draw(in: textRect, withAttributes: textFontAttributes)
   }

  }
  
}

