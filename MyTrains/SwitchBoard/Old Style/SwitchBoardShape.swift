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
  
  public static func drawShape(partType: SwitchBoardItemType, orientation: Orientation, location: SwitchBoardLocation, lineWidth:CGFloat, cellSize: CGFloat, isButton: Bool, isEnabled: Bool, offset: CGPoint, switchBoardItem: SwitchBoardItem?) {
    
    let onlyTurnouts : Bool = switchBoardItem != nil
    
    var isFeedback : Bool = false
    
    if let item = switchBoardItem, item.isSensor {
      isFeedback = true
    }
    
    var turnoutConnection : Int = -1
    
    if let item = switchBoardItem, let actualTurnoutConnection = item.actualTurnoutConnection {
      turnoutConnection = actualTurnoutConnection
   //   turnoutConnection = item.turnoutConnection
    }
        
    if let shape = SwitchBoardShape.getShape(part: partType, orientation: orientation) {

      let bx = (CGFloat(location.x) + 0.5) * cellSize
      let by = (CGFloat(location.y) + 0.5) * cellSize
      
      let theta : CGFloat = CGFloat(orientation.rawValue >> 1) * -0.5 * CGFloat.pi
      
      let sinTheta = sin(theta)
      
      let cosTheta = cos(theta)
      
      var index : Int = 0
      
      for shapePart in shape {
        
        var coordinates : [CGPoint] = []
        
        for coord in shapePart.coordinates {
          
          let x = coord.x * cellSize * (isButton ? +1.0 : +1.0)
          let y = coord.y * cellSize * (isButton ? -1.0 : +1.0)
          
          let dx = bx + x * cosTheta - y * sinTheta
          let dy = by + x * sinTheta + y * cosTheta
          
          coordinates.append(CGPoint(x: offset.x + dx, y: offset.y + dy))
          
        }
        
        if isButton {
          isEnabled ? NSColor.setStrokeColor(color: .black) : NSColor.setStrokeColor(color: .lightGray)
        }
        else if onlyTurnouts {
          NSColor.setStrokeColor(color: .white)
        }
        else {
          NSColor.setStrokeColor(color: .lightGray)
        }
                
        switch shapePart.type {
       
        case .circle:
          
          if !onlyTurnouts || isFeedback {
            
            let path = NSBezierPath()
            
            path.lineWidth = lineWidth
            
            path.appendArc(withCenter: NSMakePoint(coordinates[0].x, coordinates[0].y), radius: shapePart.parameters[0] * cellSize, startAngle: 0.0, endAngle: 360.0)
            
            if let fillColor = shapePart.actionColors[.fill] {
              isEnabled ? NSColor.setFillColor(color:fillColor) : NSColor.setFillColor(color: .lightGray)
              if let item = switchBoardItem {
                item.isOccupied ? NSColor.setFillColor(color:fillColor) : NSColor.setFillColor(color:.darkGray)
              }
              path.fill()
            }
            
            path.stroke()
            
          }
          
        case .rectangle:
          
          if !onlyTurnouts {
          
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

            if let fillColor = shapePart.actionColors[.fill] {
              isEnabled ? NSColor.setFillColor(color: fillColor) : NSColor.setFillColor(color: .lightGray)
              path.fill()
            }

            path.stroke()

          }
          
        case .irregular:
          
          if !onlyTurnouts {
            
            let path = NSBezierPath()
            
            path.lineWidth = lineWidth
            
            path.move(to: NSMakePoint(coordinates[0].x, coordinates[0].y))
            
            for index in 1...coordinates.count-1 {
              path.line(to: NSMakePoint(coordinates[index].x, coordinates[index].y))
            }
            
            path.close()
          
            if let fillColor = shapePart.actionColors[.fill] {
              isEnabled ? NSColor.setFillColor(color: fillColor) : NSColor.setFillColor(color: .lightGray)
              path.fill()
            }

            path.stroke()

          }

        case .ellipse:
          
          if !onlyTurnouts {
          
            let path = NSBezierPath()
          
            path.lineWidth = lineWidth
            
            let rect = NSRect(coordinates: coordinates)
            
            path.appendOval(in: rect)
            
            if let fillColor = shapePart.actionColors[.fill] {
              isEnabled ? NSColor.setFillColor(color: fillColor) : NSColor.setFillColor(color: .lightGray)
              path.fill()
            }
            
            path.stroke()

          }
          
        case .line:
          
          if !onlyTurnouts || index == turnoutConnection {
          
            let path = NSBezierPath()
          
            path.lineWidth = lineWidth
            
            path.move(to: NSMakePoint(coordinates[0].x, coordinates[0].y))
            
            for index in 1...coordinates.count-1 {
              path.line(to: NSMakePoint(coordinates[index].x, coordinates[index].y))
            }
            
            path.stroke()

          }
          
        case .curve:
          
          if !onlyTurnouts || index == turnoutConnection {
          
            let path = NSBezierPath()
            
            path.lineWidth = lineWidth
            
            path.move(to: NSMakePoint(coordinates[0].x, coordinates[0].y))
            
            path.curve(to: NSMakePoint(coordinates[1].x, coordinates[1].y), controlPoint1: NSMakePoint(coordinates[2].x, coordinates[2].y), controlPoint2: NSMakePoint(coordinates[3].x, coordinates[3].y))
            
            path.stroke()

          }
          
        default:
          break
        }
        
        index += 1

      }
      
    }

  }
  
  public static func getShape(part: SwitchBoardItemType, orientation: Orientation) -> Shape? {
    if let shape = shapes[part] {
      return shape[shape.count == 1 ? 0 : Int(orientation.rawValue & 1)]
    }
    return nil
  }
  
  private static let shapes : [SwitchBoardItemType: [Shape]] = [
    .straight : [[
      (type: .line, coordinates:[CGPoint(x: 0.0, y: -0.5), CGPoint(x: 0.0, y: 0.5)], parameters: [], actionColors: [:])
    ],
    [
      (type: .line, coordinates:[CGPoint(x: -0.5, y: -0.5), CGPoint(x: 0.5, y: 0.5)], parameters: [], actionColors: [:])
    ]],
    .block : [[
      (type: .line, coordinates:[CGPoint(x: 0.0, y: -0.5), CGPoint(x: 0.0, y: 0.5)], parameters: [], actionColors: [:]),
      (type: .rectangle, coordinates:[CGPoint(x: -0.2, y: -0.40), CGPoint(x: +0.2, y: +0.40)], parameters: [], actionColors: [.fill:NSColor.white, .stroke:NSColor.black]),
      (type: .circle, coordinates:[CGPoint(x: 0.0, y: 0.3),], parameters: [0.01], actionColors:[/*.fill:NSColor.black,*/.stroke:NSColor.black])

    ],
    [
      (type: .line, coordinates:[CGPoint(x: -0.5, y: -0.5), CGPoint(x: 0.5, y: 0.5)], parameters: [], actionColors: [:]),
      (type: .irregular , coordinates:[CGPoint(x: -0.42426, y: -0.14142), CGPoint(x: 0.14142, y: 0.42426), CGPoint(x: 0.42426, y: 0.14142), CGPoint(x: -0.14142, y: -0.42426)], parameters: [], actionColors: [.fill:NSColor.white, .stroke:NSColor.black]),
      (type: .circle, coordinates:[CGPoint(x: 0.2, y: 0.2),], parameters: [0.01], actionColors:[/*.fill:NSColor.black,*/.stroke:NSColor.black])
    ]],
    .platform : [[
      (type: .rectangle, coordinates:[CGPoint(x: -0.5, y: -0.50), CGPoint(x: +0.5, y: +0.50)], parameters: [], actionColors: [.fill:NSColor.lightGray])
    ]],
    .sensor : [[
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
      (type: .line, coordinates:[CGPoint(x: 0.0, y: -0.5), CGPoint(x: 0.0, y: 0.5)], parameters: [], actionColors: [:]),
      (type: .curve, coordinates:[CGPoint(x: 0.0, y: -0.5), CGPoint(x: 0.5, y: 0.5), CGPoint(x: 0.0, y: -0.2), CGPoint(x: 0.0, y: -0.2)], parameters: [], actionColors: [:]),
    ],
    [
      (type: .line, coordinates:[CGPoint(x: -0.5, y: -0.5), CGPoint(x: 0.5, y: 0.5)], parameters: [], actionColors: [:]),
      (type: .curve, coordinates:[CGPoint(x: -0.5, y: -0.5), CGPoint(x: 0.5, y: 0.0), CGPoint(x: -0.2, y: -0.2), CGPoint(x: -0.2, y: -0.2)], parameters: [], actionColors: [:]),
    ]],
    .turnoutLeft : [[
      (type: .line, coordinates:[CGPoint(x: 0.0, y: -0.5), CGPoint(x: 0.0, y: 0.5)], parameters: [], actionColors: [:]),
      (type: .curve, coordinates:[CGPoint(x: 0.0, y: -0.5), CGPoint(x: -0.5, y: 0.5), CGPoint(x: 0.0, y: -0.2), CGPoint(x: 0.0, y: -0.2)], parameters: [], actionColors: [:]),
    ],
    [
      (type: .line, coordinates:[CGPoint(x: -0.5, y: -0.5), CGPoint(x: 0.5, y: 0.5)], parameters: [], actionColors: [:]),
      (type: .curve, coordinates:[CGPoint(x: -0.5, y: -0.5), CGPoint(x: 0.0, y: 0.5), CGPoint(x: -0.2, y: -0.2), CGPoint(x: -0.2, y: -0.2)], parameters: [], actionColors: [:]),
    ]],
    .singleSlip : [[
      (type: .line, coordinates:[CGPoint(x: 0.0, y: -0.5), CGPoint(x: 0.0, y: 0.5)], parameters: [], actionColors: [:]),
      (type: .line, coordinates:[CGPoint(x: -0.5, y: 0.5), CGPoint(x: 0.5, y: -0.5)], parameters: [], actionColors: [:])
    ],
    [
      (type: .line, coordinates:[CGPoint(x: -0.5, y: -0.5), CGPoint(x: 0.5, y: 0.5)], parameters: [], actionColors: [:]),
      (type: .line, coordinates:[CGPoint(x: 0.0, y: 0.5), CGPoint(x: 0.0, y: -0.5)], parameters: [], actionColors: [:])
    ]],
    .doubleSlip : [[
      (type: .line, coordinates:[CGPoint(x: 0.0, y: -0.5), CGPoint(x: 0.0, y: 0.5)], parameters: [], actionColors: [:]),
      (type: .line, coordinates:[CGPoint(x: -0.5, y: 0.5), CGPoint(x: 0.5, y: -0.5)], parameters: [], actionColors: [:])
    ],
    [
      (type: .line, coordinates:[CGPoint(x: -0.5, y: -0.5), CGPoint(x: 0.5, y: 0.5)], parameters: [], actionColors: [:]),
      (type: .line, coordinates:[CGPoint(x: 0.0, y: 0.5), CGPoint(x: 0.0, y: -0.5)], parameters: [], actionColors: [:])
    ]],
  ]

}
