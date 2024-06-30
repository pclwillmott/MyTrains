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
  
  public var sampleTable : [[Double]] = [] {
    didSet {
      needsDisplay = true
    }
  }
  
  public var speedProfile : SpeedProfile? {
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
    
    guard let appNode, let speedProfile else {
      return
    }
    
    let context = NSGraphicsContext.current?.cgContext
    
    let maximumSpeed = round((UnitSpeed.convert(fromValue: speedProfile.maximumSpeed, fromUnits: .defaultValueScaleSpeed, toUnits: appNode.unitsScaleSpeed) + 5) / 10.0) * 10.0
    
    let scaleMax = maximumSpeed + 10.0
    
    let gridSteps = Int(maximumSpeed) / 10
    let xOffset = bounds.width / CGFloat(gridSteps + 2)
    let yOffset = bounds.height / CGFloat(gridSteps + 2)
    
    // X Axis Labels
    
    for cn in 0 ... gridSteps {
      let text = "\(cn * 10)"
      let font = NSFont.boldSystemFont(ofSize: 10)
      let dx = CGFloat(cn) * bounds.width / CGFloat(gridSteps + 2)
      let dw = bounds.width / CGFloat(gridSteps + 2)
      let dh = bounds.height / CGFloat(gridSteps + 2)
      let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
      let textFontAttributes = [
        NSAttributedString.Key.font: font,
        NSAttributedString.Key.foregroundColor: NSColor.white,
        NSAttributedString.Key.paragraphStyle: textStyle,
      ] as [NSAttributedString.Key : Any]
      
      let attributedString = NSAttributedString(string: text, attributes: textFontAttributes)
      
      // Find text width in CGFloat units
      let line = CTLineCreateWithAttributedString(attributedString)
      let lineBounds = CTLineGetBoundsWithOptions(line, .useGlyphPathBounds)
      let width = CGFloat(lineBounds.width)
      
      let textRect = CGRect(x: xOffset + dx - width / 2.0, y: -1, width: dw , height: dh)
      
      text.draw(in: textRect, withAttributes: textFontAttributes)
      
      // Y Axis Labels
      
      for cn in 0 ... gridSteps {
        let text = "\(cn * 10)"
        let font = NSFont.boldSystemFont(ofSize: 10)
        let dh = bounds.height / CGFloat(gridSteps + 2)
        let dy = 6 + Double(cn) * dh
        let dw = bounds.width / CGFloat(gridSteps + 2)
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
      for y in 0 ... gridSteps {
        let dy = yOffset + CGFloat(y) * bounds.height / CGFloat(gridSteps + 2)
        let horiPath = NSBezierPath()
        horiPath.lineWidth = 1
        horiPath.move(to: NSMakePoint(xOffset, dy))
        horiPath.line(to: NSMakePoint(bounds.width, dy))
        horiPath.close()
        horiPath.stroke()
        for x in 0...gridSteps {
          let dx = xOffset + CGFloat(x) * bounds.width / CGFloat(gridSteps + 2)
          let vertPath = NSBezierPath()
          vertPath.lineWidth = 1
          vertPath.move(to: NSMakePoint(dx, yOffset))
          vertPath.line(to: NSMakePoint(dx, bounds.height))
          vertPath.close()
          vertPath.stroke()
        }
      }
      
      let show : [SamplingDirection:Set<Int>] = [
        .bothDirections : [1,2],
        .forward : [1],
        .reverse : [2],
      ]
      
      if speedProfile.showSamples {
        
        for row in sampleTable {
          
          for dataSet in (1 ... 2).reversed() {
            
            if show[speedProfile.directionToChart]!.contains(dataSet) {
              
              if row[dataSet] != 0.0 || row[0] == 0.0 {
                
                dataSet == 1 ? speedProfile.colourForward.color.setFill() : speedProfile.colourReverse.color.setFill()
                
                let dx = xOffset + (bounds.width - xOffset) * CGFloat(UnitSpeed.convert(fromValue: row[0], fromUnits: .defaultValueScaleSpeed, toUnits: appNode.unitsScaleSpeed)) / scaleMax
                
                let dy = yOffset + (bounds.height - yOffset) * CGFloat(UnitSpeed.convert(fromValue: row[dataSet], fromUnits: .defaultValueScaleSpeed, toUnits: appNode.unitsScaleSpeed)) / scaleMax
                
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
          
        }
        
      }
      
      if speedProfile.showTrendline {
        
        for dataSet in (1 ... 2).reversed() {
          
          if show[speedProfile.directionToChart]!.contains(dataSet) {
            
            let samples = speedProfile.bestFitMethod.fit(sampleTable: sampleTable, dataSet: dataSet)
            
            let path = NSBezierPath()
            
            dataSet == 1 ? speedProfile.colourForward.color.setStroke() : speedProfile.colourReverse.color.setStroke()
            
            path.move(to: NSMakePoint(xOffset, yOffset))
            
            path.lineWidth = 3
            
            for row in samples {
              
              let dx = xOffset + (bounds.width - xOffset) * CGFloat(UnitSpeed.convert(fromValue: row[0], fromUnits: .defaultValueScaleSpeed, toUnits: appNode.unitsScaleSpeed)) / scaleMax
              
              let dy = yOffset + (bounds.height - yOffset) * CGFloat(UnitSpeed.convert(fromValue: row[1], fromUnits: .defaultValueScaleSpeed, toUnits: appNode.unitsScaleSpeed)) / scaleMax
              
              path.line(to: NSMakePoint(dx, dy))
              
            }
            
            path.stroke()
            
          }
          
        }
        
      }
      
      /*
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
       
       
       
       }
       
       }
       
       } */
      
    }
    
  }
  
}
