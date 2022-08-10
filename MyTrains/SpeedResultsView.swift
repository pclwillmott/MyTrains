//
//  SpeedResultsView.swift
//  MyTrains
//
//  Created by Paul Willmott on 03/08/2022.
//

import Foundation
import Cocoa

@IBDesignable
class SpeedResultsView: NSView {

  // MARK: Public Properties

  public var locomotive : Locomotive? {
    didSet {
      needsDisplay = true
    }
  }
  
  public var speedUnits : UnitSpeed = .centimetersPerSecond {
    didSet {
      needsDisplay = true
    }
  }
  
  public var showTrendline : Bool = false {
    didSet {
      needsDisplay = true
    }
  }
  
  public var dataSet : Int = 2 {
    didSet {
      needsDisplay = true
    }
  }
  
  override func draw(_ dirtyRect: NSRect) {

    super.draw(dirtyRect)

    NSColor.black.setFill()
    bounds.fill()

    let context = NSGraphicsContext.current?.cgContext
    
    let xOffset = bounds.width / 14.0
    let yOffset = bounds.height / 11.0

    let maxValue : Double = 100.0
    
    // X Axis Labels
    
    for cn in 0...12 {
      let text = "\(cn * 10)"
      let font = NSFont.boldSystemFont(ofSize: 10)
      let dx = CGFloat(cn) * bounds.width / 14.0
      let dw = bounds.width / 14.0
      let dh = bounds.height / 11.0
      let textRect = CGRect(x: xOffset + dx - 3, y: -8, width: dw , height: dh)
      let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
      let textFontAttributes = [
          NSAttributedString.Key.font: font,
          NSAttributedString.Key.foregroundColor: NSColor.white,
          NSAttributedString.Key.paragraphStyle: textStyle,
      ] as [NSAttributedString.Key : Any]
      text.draw(in: textRect, withAttributes: textFontAttributes)
    }

    // Y Axis Labels
    
    for cn in 0...9 {
      let value = Double(cn) * 10.0 * speedUnits.fromCMS
      let text = String(format: "%.1f", value)
      let font = NSFont.boldSystemFont(ofSize: 10)
      let dh = bounds.height / 11.0
      let dy = 6 + Double(cn) * dh
      let dw = bounds.width / 14.0
      let textRect = CGRect(x: 4.0, y: dy, width: dw , height: dh)
      let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
      let textFontAttributes = [
          NSAttributedString.Key.font: font,
          NSAttributedString.Key.foregroundColor: NSColor.white,
          NSAttributedString.Key.paragraphStyle: textStyle,
      ] as [NSAttributedString.Key : Any]
      text.draw(in: textRect, withAttributes: textFontAttributes)
    }

    // Grid Lines
    
    context?.setStrokeColor(NSColor.gray.cgColor)
    for y in 0...9 {
      let dy = yOffset + CGFloat(y) * bounds.height / 11.0
      let horiPath = NSBezierPath()
      horiPath.lineWidth = 1
      horiPath.move(to: NSMakePoint(xOffset, dy))
      horiPath.line(to: NSMakePoint(bounds.width, dy))
      horiPath.close()
      horiPath.stroke()
      for x in 0...12 {
        let dx = xOffset + CGFloat(x) * bounds.width / 14.0
        let vertPath = NSBezierPath()
        vertPath.lineWidth = 1
        vertPath.move(to: NSMakePoint(dx, yOffset))
        vertPath.line(to: NSMakePoint(dx, bounds.height))
        vertPath.close()
        vertPath.stroke()
      }
    }
    
    if let locomotive = self.locomotive {
      
      locomotive.doBestFit()

      if dataSet != 1 {
        
        for profile in locomotive.speedProfile {

          if profile.newSpeedForward != 0.0 {
          
            NSColor.systemBlue.setFill()
            let dx = xOffset + CGFloat(profile.stepNumber) * (bounds.width - xOffset) / 129.0
            let dy = yOffset + ((bounds.height - yOffset) / maxValue) * profile.newSpeedForward
            let path = NSBezierPath()
            path.move(to: NSMakePoint(dx-2, dy+2))
            path.line(to: NSMakePoint(dx+2, dy+2))
            path.line(to: NSMakePoint(dx+2, dy-2))
            path.line(to: NSMakePoint(dx-2, dy-2))
            path.close()
            path.fill()
            
          }
          
        }
        
      }

      if dataSet != 0 {

        for profile in locomotive.speedProfile {
        
          if profile.newSpeedReverse != 0.0 {
            NSColor.red.setFill()
            let dx = xOffset + CGFloat(profile.stepNumber) * (bounds.width - xOffset) / 129.0
            let dy = yOffset + ((bounds.height - yOffset) / maxValue) * profile.newSpeedReverse
            let path = NSBezierPath()
            path.move(to: NSMakePoint(dx-2, dy+2))
            path.line(to: NSMakePoint(dx+2, dy+2))
            path.line(to: NSMakePoint(dx+2, dy-2))
            path.line(to: NSMakePoint(dx-2, dy-2))
            path.close()
            path.fill()
          }

        }
        
      }

      if showTrendline {
        
        if dataSet != 1 {
          
          for profile in locomotive.speedProfile {
            
            NSColor.cyan.setFill()
            let dx = xOffset + CGFloat(profile.stepNumber) * (bounds.width - xOffset) / 129.0
            let dy = yOffset + ((bounds.height - yOffset) / maxValue) * profile.bestFitForward
            let path = NSBezierPath()
            path.move(to: NSMakePoint(dx-2, dy+2))
            path.line(to: NSMakePoint(dx+2, dy+2))
            path.line(to: NSMakePoint(dx+2, dy-2))
            path.line(to: NSMakePoint(dx-2, dy-2))
            path.close()
            path.fill()

          }
          /*
          let text = "R2 = \(String(format: "%.4f", locomotive.r2Forward))"
          let font = NSFont.boldSystemFont(ofSize: 12)
          let textRect = CGRect(x: xOffset * 2 + 4, y: bounds.height - 38, width: 200 , height: 30)
          let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
          let textFontAttributes = [
              NSAttributedString.Key.font: font,
              NSAttributedString.Key.foregroundColor: NSColor.cyan,
              NSAttributedString.Key.paragraphStyle: textStyle,
          ] as [NSAttributedString.Key : Any]
          text.draw(in: textRect, withAttributes: textFontAttributes)
          */
        }
        
        if dataSet != 0 {
          
          for profile in locomotive.speedProfile {

            NSColor.magenta.setFill()
            let dx = xOffset + CGFloat(profile.stepNumber) * (bounds.width - xOffset) / 129.0
            let dy = yOffset + ((bounds.height - yOffset) / maxValue) * profile.bestFitReverse
            let path = NSBezierPath()
            path.move(to: NSMakePoint(dx-2, dy+2))
            path.line(to: NSMakePoint(dx+2, dy+2))
            path.line(to: NSMakePoint(dx+2, dy-2))
            path.line(to: NSMakePoint(dx-2, dy-2))
            path.close()
            path.fill()

          }
          
          /*
          let drop = (dataSet == 2) ? -68.0 : -38.0

          let text = "R2 = \(String(format: "%.4f", locomotive.r2Reverse))"
          let font = NSFont.boldSystemFont(ofSize: 12)
          let textRect = CGRect(x: xOffset * 2 + 4, y: bounds.height + drop, width: 200 , height: 30)
          let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
          let textFontAttributes = [
              NSAttributedString.Key.font: font,
              NSAttributedString.Key.foregroundColor: NSColor.magenta,
              NSAttributedString.Key.paragraphStyle: textStyle,
          ] as [NSAttributedString.Key : Any]
          text.draw(in: textRect, withAttributes: textFontAttributes)
           
           */
          
        }
        
      }
    
    }
    
  }
  
}
  
