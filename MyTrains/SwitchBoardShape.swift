//
//  SwitchBoardShape.swift
//  MyTrains
//
//  Created by Paul Willmott on 30/04/2022.
//

import Foundation
import Cocoa

class SwitchBoardShape {
  
  // MARK: Class Methods
  
  public static func drawShape(partType: SwitchBoardItemPartType, orientation: Int, location: SwitchBoardLocation, lineWidth:CGFloat, cellSize: CGFloat, isButton: Bool, isEnabled: Bool) {
    
    if let shape = SwitchBoardShape.getShape(part: partType, orientation: orientation) {

      if isButton {
        isEnabled ? NSColor.setStrokeColor(color: .black) : NSColor.setStrokeColor(color: .lightGray)
      }
      else {
        NSColor.setStrokeColor(color: .lightGray)
      }
      
      let bx = (CGFloat(location.x) + 0.5) * cellSize
      let by = (CGFloat(location.y) + 0.5) * cellSize
      
      let theta : CGFloat = CGFloat(orientation >> 1) * -0.5 * CGFloat.pi
      
      let sinTheta = sin(theta)
      
      let cosTheta = cos(theta)
      
      for shapePart in shape {
        
        var coordinates : [CGPoint] = []
        
        for coord in shapePart.coordinates {
          
          let x = coord.x * cellSize * (isButton ? +1.0 : +1.0)
          let y = coord.y * cellSize * (isButton ? -1.0 : +1.0)
          
          let dx = bx + x * cosTheta - y * sinTheta
          let dy = by + x * sinTheta + y * cosTheta
          
          coordinates.append(CGPoint(x: dx, y: dy))
          
        }
        
        switch shapePart.type {
       
        case .circle:
          
          let path = NSBezierPath()
          
          path.lineWidth = lineWidth
          
          path.appendArc(withCenter: NSMakePoint(coordinates[0].x, coordinates[0].y), radius: shapePart.parameters[0] * cellSize, startAngle: 0.0, endAngle: 360.0)
          /*
          if let fillColor = shapePart.actionColors[.fill] {
            isEnabled ? NSColor.setFillColor(color:fillColor) : NSColor.setFillColor(color: .lightGray)
            path.fill()
          }
          */
          path.stroke()
          
        case .rectangle:
          
          let path = NSBezierPath()
          
          path.lineWidth = lineWidth
          
          let x1 = coordinates[0].x
          let y1 = coordinates[0].y
          let x2 = coordinates[1].x
          let y2 = coordinates[1].y
          
          path.move(to: NSMakePoint(x1, y1))
          path.line(to: NSMakePoint(x2, y1))
          path.line(to: NSMakePoint(x2, y2))
          path.line(to: NSMakePoint(x1, y2))
          path.close()
/*
          if let fillColor = shapePart.actionColors[.fill] {
            isEnabled ? NSColor.setFillColor(color: fillColor) : NSColor.setFillColor(color: .lightGray)
            path.fill()
          }
*/
          path.stroke()

        case .irregular:
          
          let path = NSBezierPath()
          
          path.lineWidth = lineWidth
          
          path.move(to: NSMakePoint(coordinates[0].x, coordinates[0].y))
          
          for index in 1...coordinates.count-1 {
            path.line(to: NSMakePoint(coordinates[index].x, coordinates[index].y))
          }
          
          path.close()
          /*
          if let fillColor = shapePart.actionColors[.fill] {
            isEnabled ? NSColor.setFillColor(color: fillColor) : NSColor.setFillColor(color: .lightGray)
            path.fill()
          }
*/
          path.stroke()

        case .ellipse:
          
          let path = NSBezierPath()
          
          path.lineWidth = lineWidth
          
          let rect = NSRect(coordinates: coordinates)
          
          path.appendOval(in: rect)
          /*
          if let fillColor = shapePart.actionColors[.fill] {
            isEnabled ? NSColor.setFillColor(color: fillColor) : NSColor.setFillColor(color: .lightGray)
            path.fill()
          }
          */
          path.stroke()
          
        case .line:
          
          let path = NSBezierPath()
          
          path.lineWidth = lineWidth
          
          path.move(to: NSMakePoint(coordinates[0].x, coordinates[0].y))
          
          for index in 1...coordinates.count-1 {
            path.line(to: NSMakePoint(coordinates[index].x, coordinates[index].y))
          }
          
          path.stroke()
          
        case .curve:
          
          let path = NSBezierPath()
          
          path.lineWidth = lineWidth
          
          path.move(to: NSMakePoint(coordinates[0].x, coordinates[0].y))
          
          path.curve(to: NSMakePoint(coordinates[1].x, coordinates[1].y), controlPoint1: NSMakePoint(coordinates[2].x, coordinates[2].y), controlPoint2: NSMakePoint(coordinates[3].x, coordinates[3].y))
          
          path.stroke()
          
        default:
          break
        }
        
      }

    }

  }
  
  public static func getShape(part: SwitchBoardItemPartType, orientation: Int) -> Shape? {
/*    if let shape = shapes[part] {
      return shape[shape.count == 1 ? 0 : orientation & 1]
    } */
    return nil
  }
  
  private static let shapes : [SwitchBoardItemPartType: [Shape]] = [
    .straight : [[
      (type: .line, coordinates:[CGPoint(x: 0.0, y: -0.5), CGPoint(x: 0.0, y: 0.5)], parameters: [], actionColors: [:])
    ],
    [
      (type: .line, coordinates:[CGPoint(x: -0.5, y: -0.5), CGPoint(x: 0.5, y: 0.5)], parameters: [], actionColors: [:])
    ]],
    .block : [[
      (type: .line, coordinates:[CGPoint(x: 0.0, y: -0.5), CGPoint(x: 0.0, y: 0.5)], parameters: [], actionColors: [:]),
      (type: .rectangle, coordinates:[CGPoint(x: -0.2, y: -0.40), CGPoint(x: +0.2, y: +0.40)], parameters: [], actionColors: [.fill:NSColor.white, .stroke:NSColor.black])
    ],
    [
      (type: .line, coordinates:[CGPoint(x: -0.5, y: -0.5), CGPoint(x: 0.5, y: 0.5)], parameters: [], actionColors: [:]),
      (type: .irregular , coordinates:[CGPoint(x: -0.42426, y: -0.14142), CGPoint(x: 0.14142, y: 0.42426), CGPoint(x: 0.42426, y: 0.14142), CGPoint(x: -0.14142, y: -0.42426)], parameters: [], actionColors: [.fill:NSColor.white, .stroke:NSColor.black])
    ]],
    .platform : [[
      (type: .rectangle, coordinates:[CGPoint(x: -0.5, y: -0.50), CGPoint(x: +0.5, y: +0.50)], parameters: [], actionColors: [.fill:NSColor.lightGray])
    ]],
    .feedback : [[
      (type: .line, coordinates:[CGPoint(x: 0.0, y: -0.5), CGPoint(x: 0.0, y: 0.5)], parameters: [], actionColors: [:]),
      (type: .circle, coordinates:[CGPoint(x: 0.0, y: 0.0),], parameters: [0.3], actionColors: [.fill:NSColor.red])
    ],
    [
      (type: .line, coordinates:[CGPoint(x: -0.5, y: -0.5), CGPoint(x: 0.5, y: 0.5)], parameters: [], actionColors: [:]),
      (type: .circle, coordinates:[CGPoint(x: 0.0, y: 0.0),], parameters: [0.3], actionColors: [.fill:NSColor.red])
    ]],
    .link : [[
      (type: .line, coordinates:[CGPoint(x: 0.0, y: -0.5), CGPoint(x: 0.0, y: 0.0)], parameters: [], actionColors: [:]),
      (type: .circle, coordinates:[CGPoint(x: 0.0, y: 0.1),], parameters: [0.2], actionColors: [.fill:NSColor.yellow])
    ],
    [
      (type: .line, coordinates:[CGPoint(x: -0.5, y: -0.5), CGPoint(x: 0.0, y: 0.0)], parameters: [], actionColors: [:]),
      (type: .circle, coordinates:[CGPoint(x: 0.0, y: 0.1),], parameters: [0.2], actionColors: [.fill:NSColor.yellow])
    ]],
    .cross : [[
      (type: .line, coordinates:[CGPoint(x: 0.0, y: -0.5), CGPoint(x: 0.0, y: 0.5)], parameters: [], actionColors: [:]),
      (type: .line, coordinates:[CGPoint(x: -0.5, y: 0.0), CGPoint(x: 0.5, y: 0.0)], parameters: [], actionColors: [:])
    ],
    [
      (type: .line, coordinates:[CGPoint(x: -0.5, y: -0.5), CGPoint(x: 0.5, y: 0.5)], parameters: [], actionColors: [:]),
      (type: .line, coordinates:[CGPoint(x: -0.5, y: 0.5), CGPoint(x: 0.5, y: -0.5)], parameters: [], actionColors: [:])
    ]],
    .buffer : [[
      (type: .line, coordinates:[CGPoint(x: 0.0, y: -0.5), CGPoint(x: 0.0, y: 0.0)], parameters: [], actionColors: [:]),
      (type: .line, coordinates:[CGPoint(x: -0.2, y: 0.0), CGPoint(x: 0.2, y: 0.0)], parameters: [], actionColors: [:])
    ],
    [
      (type: .line, coordinates:[CGPoint(x: -0.5, y: -0.5), CGPoint(x: 0.0, y: 0.0)], parameters: [], actionColors: [:]),
      (type: .line, coordinates:[CGPoint(x: -0.15, y: 0.15), CGPoint(x: +0.15, y: -0.15)], parameters: [], actionColors: [:])
    ]],
    .diagonalCross : [[
      (type: .line, coordinates:[CGPoint(x: 0.0, y: -0.5), CGPoint(x: 0.0, y: 0.5)], parameters: [], actionColors: [:]),
      (type: .line, coordinates:[CGPoint(x: -0.5, y: 0.5), CGPoint(x: 0.5, y: -0.5)], parameters: [], actionColors: [:])
    ],
    [
      (type: .line, coordinates:[CGPoint(x: -0.5, y: -0.5), CGPoint(x: 0.5, y: 0.5)], parameters: [], actionColors: [:]),
      (type: .line, coordinates:[CGPoint(x: 0.0, y: 0.5), CGPoint(x: 0.0, y: -0.5)], parameters: [], actionColors: [:])
    ]],
    .curve    : [[
      (type: .curve, coordinates:[CGPoint(x: 0.0, y: -0.5), CGPoint(x: 0.5, y: 0.0), CGPoint(x: 0.0, y: -0.5), CGPoint(x: 0.0, y: 0.0)], parameters: [], actionColors: [:]),
    ],
    [
      (type: .curve, coordinates:[CGPoint(x: -0.5, y: -0.5), CGPoint(x: 0.5, y: -0.5), CGPoint(x: -0.5, y: -0.5), CGPoint(x: 0.0, y: 0.0)], parameters: [], actionColors: [:]),
    ]],
    .longCurve    : [[
      (type: .curve, coordinates:[CGPoint(x: 0.0, y: -0.5), CGPoint(x: 0.5, y: 0.5), CGPoint(x: 0.0, y: 0.0), CGPoint(x: 0.0, y: 0.0)], parameters: [], actionColors: [:])
    ],
    [
      (type: .curve, coordinates:[CGPoint(x: -0.5, y: -0.5), CGPoint(x: 0.5, y: 0.0), CGPoint(x: -0.5, y: -0.5), CGPoint(x: 0.0, y: 0.0)], parameters: [], actionColors: [:])
    ]],
    .yTurnout    : [[
      (type: .curve, coordinates:[CGPoint(x: 0.0, y: -0.5), CGPoint(x: 0.5, y: 0.5), CGPoint(x: 0.0, y: 0.0), CGPoint(x: 0.0, y: 0.0)], parameters: [], actionColors: [:]),
      (type: .curve, coordinates:[CGPoint(x: 0.0, y: -0.5), CGPoint(x: -0.5, y: 0.5), CGPoint(x: 0.0, y: 0.0), CGPoint(x: 0.0, y: 0.0)], parameters: [], actionColors: [:])
    ],
    [
      (type: .curve, coordinates:[CGPoint(x: -0.5, y: -0.5), CGPoint(x: 0.0, y: 0.5), CGPoint(x: -0.2, y: -0.2), CGPoint(x: -0.2, y: -0.2)], parameters: [], actionColors: [:]),
      (type: .curve, coordinates:[CGPoint(x: -0.5, y: -0.5), CGPoint(x: 0.5, y: 0.0), CGPoint(x: -0.2, y: -0.2), CGPoint(x: -0.2, y: -0.2)], parameters: [], actionColors: [:])
    ]],
    .leftCurvedTurnout    : [[
      (type: .curve, coordinates:[CGPoint(x: 0.0, y: -0.5), CGPoint(x: -0.5, y: 0.5), CGPoint(x: 0.0, y: 0.0), CGPoint(x: 0.0, y: 0.0)], parameters: [], actionColors: [:]),
      (type: .curve, coordinates:[CGPoint(x: 0.0, y: -0.5), CGPoint(x: -0.5, y: 0.0), CGPoint(x: 0.0, y: -0.5), CGPoint(x: 0.0, y: 0.0)], parameters: [], actionColors: [:])
    ],
    [
      (type: .curve, coordinates:[CGPoint(x: -0.5, y: -0.5), CGPoint(x: -0.5, y: 0.5), CGPoint(x: -0.2, y: -0.2), CGPoint(x: -0.2, y: -0.2)], parameters: [], actionColors: [:]),
      (type: .curve, coordinates:[CGPoint(x: -0.5, y: -0.5), CGPoint(x: 0.0, y: 0.5), CGPoint(x: -0.2, y: -0.2), CGPoint(x: -0.2, y: -0.2)], parameters: [], actionColors: [:])
    ]],
    .rightCurvedTurnout    : [[
      (type: .curve, coordinates:[CGPoint(x: 0.0, y: -0.5), CGPoint(x: 0.5, y: 0.5), CGPoint(x: 0.0, y: 0.0), CGPoint(x: 0.0, y: 0.0)], parameters: [], actionColors: [:]),
      (type: .curve, coordinates:[CGPoint(x: 0.0, y: -0.5), CGPoint(x: 0.5, y: 0.0), CGPoint(x: 0.0, y: -0.5), CGPoint(x: 0.0, y: 0.0)], parameters: [], actionColors: [:])
    ],
    [
      (type: .curve, coordinates:[CGPoint(x: -0.5, y: -0.5), CGPoint(x: 0.5, y: 0.0), CGPoint(x: -0.2, y: -0.2), CGPoint(x: -0.2, y: -0.2)], parameters: [], actionColors: [:]),
      (type: .curve, coordinates:[CGPoint(x: -0.5, y: -0.5), CGPoint(x: 0.5, y: -0.5), CGPoint(x: -0.2, y: -0.2), CGPoint(x: -0.2, y: -0.2)], parameters: [], actionColors: [:])
    ]],
    .turnout3Way    : [[
      (type: .line, coordinates:[CGPoint(x: 0.0, y: -0.5), CGPoint(x: 0.0, y: 0.5)], parameters: [], actionColors: [:]),
      (type: .curve, coordinates:[CGPoint(x: 0.0, y: -0.5), CGPoint(x: 0.5, y: 0.5), CGPoint(x: 0.0, y: 0.0), CGPoint(x: 0.0, y: 0.0)], parameters: [], actionColors: [:]),
      (type: .curve, coordinates:[CGPoint(x: 0.0, y: -0.5), CGPoint(x: -0.5, y: 0.5), CGPoint(x: 0.0, y: 0.0), CGPoint(x: 0.0, y: 0.0)], parameters: [], actionColors: [:])
    ],
    [
      (type: .line, coordinates:[CGPoint(x: -0.5, y: -0.5), CGPoint(x: 0.5, y: 0.5)], parameters: [], actionColors: [:]),
      (type: .curve, coordinates:[CGPoint(x: -0.5, y: -0.5), CGPoint(x: 0.0, y: 0.5), CGPoint(x: -0.2, y: -0.2), CGPoint(x: -0.2, y: -0.2)], parameters: [], actionColors: [:]),
      (type: .curve, coordinates:[CGPoint(x: -0.5, y: -0.5), CGPoint(x: 0.5, y: 0.0), CGPoint(x: -0.2, y: -0.2), CGPoint(x: -0.2, y: -0.2)], parameters: [], actionColors: [:])
    ]],
    .turnoutRight : [[
      (type: .curve, coordinates:[CGPoint(x: 0.0, y: -0.5), CGPoint(x: 0.5, y: 0.5), CGPoint(x: 0.0, y: -0.2), CGPoint(x: 0.0, y: -0.2)], parameters: [], actionColors: [:]),
      (type: .line, coordinates:[CGPoint(x: 0.0, y: -0.5), CGPoint(x: 0.0, y: 0.5)], parameters: [], actionColors: [:])
    ],
    [
      (type: .curve, coordinates:[CGPoint(x: -0.5, y: -0.5), CGPoint(x: 0.5, y: 0.0), CGPoint(x: -0.2, y: -0.2), CGPoint(x: -0.2, y: -0.2)], parameters: [], actionColors: [:]),
      (type: .line, coordinates:[CGPoint(x: -0.5, y: -0.5), CGPoint(x: 0.5, y: 0.5)], parameters: [], actionColors: [:])
    ]],
    .turnoutLeft : [[
      (type: .curve, coordinates:[CGPoint(x: 0.0, y: -0.5), CGPoint(x: -0.5, y: 0.5), CGPoint(x: 0.0, y: -0.2), CGPoint(x: 0.0, y: -0.2)], parameters: [], actionColors: [:]),
      (type: .line, coordinates:[CGPoint(x: 0.0, y: -0.5), CGPoint(x: 0.0, y: 0.5)], parameters: [], actionColors: [:])
    ],
    [
      (type: .curve, coordinates:[CGPoint(x: -0.5, y: -0.5), CGPoint(x: 0.0, y: 0.5), CGPoint(x: -0.2, y: -0.2), CGPoint(x: -0.2, y: -0.2)], parameters: [], actionColors: [:]),
      (type: .line, coordinates:[CGPoint(x: -0.5, y: -0.5), CGPoint(x: 0.5, y: 0.5)], parameters: [], actionColors: [:])
    ]],
  ]

  
}
