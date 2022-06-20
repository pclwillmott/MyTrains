//
//  SwitchBoardItemView.swift
//  MyTrains
//
//  Created by Paul Willmott on 20/06/2022.
//

import Foundation
import Cocoa

@IBDesignable
class SwitchBoardItemView: NSView {
  
  // MARK: Drawing Stuff
  
  override func draw(_ dirtyRect: NSRect) {
    
    super.draw(dirtyRect)
    
    if let item = switchBoardItem {
    
      let scale = 0.5
      
      let offset = CGPoint(x: bounds.width * (1.0-scale) / 2.0, y: bounds.height * (1.0-scale) / 2.0)
      
      let cellSize = min(bounds.width * scale, bounds.height * scale)
      
      let lineWidth = cellSize * 0.1
   
      let path = NSBezierPath()
      
      path.appendRect(bounds)
      
      NSColor.windowBackgroundColor.setFill()
      
      path.fill()
      
      SwitchBoardShape.drawShape(partType: item.itemPartType, orientation: item.orientation, location: (x:0,y:0), lineWidth: lineWidth, cellSize: cellSize, isButton: false, isEnabled: true, offset: offset)
      
      NSColor.setStrokeColor(color: .clear)
      
      path.appendRect(frame)
      
      path.lineWidth = lineWidth
      
      path.stroke()
      
      for labelInfo in item.itemPartType.pointLabels(orientation: item.orientation) {
        
        let coords : [CGPoint] = [
          CGPoint(x: 0.1, y: 0.84),
          CGPoint(x: 0.47, y: 0.84),
          CGPoint(x: 0.84, y: 0.84),
          CGPoint(x: 0.84, y: 0.47),
          CGPoint(x: 0.84, y: 0.1),
          CGPoint(x: 0.47, y: 0.1),
          CGPoint(x: 0.1, y: 0.1),
          CGPoint(x: 0.1, y: 0.47),
        ]
        
        let x = coords[labelInfo.pos].x * bounds.width
        let y = coords[labelInfo.pos].y * bounds.height
        
        
        let text = "\(labelInfo.label)"
        let font = NSFont.boldSystemFont(ofSize: 16)
        let textRect = CGRect(x: x, y: y, width: 15.0 , height: 15.0)
        let textStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        let textFontAttributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: NSColor.gray,
            NSAttributedString.Key.paragraphStyle: textStyle
        ] as [NSAttributedString.Key : Any]
        text.draw(in: textRect, withAttributes: textFontAttributes)

      }
      
      print(item.itemPartType.routeLabels(orientation: item.orientation))
      
    }
    
  }
  
  // MARK: Public Properties
  
  public var switchBoardItem : SwitchBoardItem? {
    didSet {
      needsDisplay = true
    }
  }
  
}
