//
//  ClockView.swift
//  MyTrains
//
//  Created by Paul Willmott on 10/12/2022.
//

import Foundation
import Cocoa

enum SevenSegmentDigit : Int {
  
  case digit0 = 0
  case digit1 = 1
  case digit2 = 2
  case digit3 = 3
  case digit4 = 4
  case digit5 = 5
  case digit6 = 6
  case digit7 = 7
  case digit8 = 8
  case digit9 = 9

  func drawSegment(segment:Int) -> Bool {
    
    let segmentParts = [
    0x3f,
    0x06,
    0x5b,
    0x4f,
    0x66,
    0x6d,
    0x7d,
    0x07,
    0x7f,
    0x6f,
    ]
    
    let mask = 1 << segment
    
    return (segmentParts[self.rawValue] & mask) == mask
    
  }
  
}

@IBDesignable
class ClockView: NSView {
  
  // MARK: Drawing Stuff
  
  
  // https://aj-computing.co.uk/articles/html5-network-southeast-clock/
  
  override func draw(_ dirtyRect: NSRect) {
    
    super.draw(dirtyRect)
    
    var xSize : CGFloat = bounds.width * 1.9 / 16.0
    let ySize = xSize * 1.5

    var path = NSBezierPath()
    
    path.appendRect(bounds)
    
    NSColor.setFillColor(color: .black)
    
    path.fill()

    NSColor.setStrokeColor(color: .yellow)
    NSColor.setFillColor(color: .yellow)

    path = NSBezierPath()
    
    path.lineWidth = 1
    
    var xPos : CGFloat = bounds.width * 6.0 / 16.0
    var yPos : CGFloat = bounds.height * 0.1 + ySize * 0.7
    
    var dotSize = 0.3 / 16.0 * bounds.width / 2.0
    
    path.appendArc(withCenter: NSPoint(x: xPos, y: yPos), radius: dotSize, startAngle: 0.0, endAngle: 360.0, clockwise: false)
    
    path.fill()
    
    path.stroke()

    path = NSBezierPath()
    
    path.lineWidth = 1
    
    yPos = bounds.height * 0.1 + ySize * 0.3
    
    dotSize = 0.3 / 16.0 * bounds.width / 2.0
    
    path.appendArc(withCenter: NSPoint(x: xPos, y: yPos), radius: dotSize, startAngle: 0.0, endAngle: 360.0, clockwise: false)
    
    path.fill()
    
    path.stroke()

    path = NSBezierPath()
    
    path.lineWidth = 1
    
    xPos = bounds.width * 11.72 / 16.0
    yPos = bounds.height * 0.1 + ySize * 0.5
    
    dotSize = 0.3 / 16.0 * bounds.width / 2.0
    
    path.appendArc(withCenter: NSPoint(x: xPos, y: yPos), radius: dotSize, startAngle: 0.0, endAngle: 360.0, clockwise: false)
    
    path.fill()
    
    path.stroke()


    var number = 0
    
    /*
    var seconds = date.timeIntervalSince1970
    
    var sec = Int(seconds)
    let days = sec / 86400
    sec -= days * 86400
    let hr = sec / 3600
    sec -= hr * 3600
    let min = sec / 60
    sec -= min * 60

    */
    
    let components = date.dateComponents
    
//    var calendar = Calendar(identifier: .gregorian)
//    calendar.timeZone = TimeZone(secondsFromGMT: 0)!
//    var components = calendar.dateComponents(in: TimeZone(secondsFromGMT: 0)!, from: date)
    
    let hr = components.hour!
    let min = components.minute!
    let sec = components.second!
    
    number += hr * 10000
    number += min * 100
    number += sec

//    number = 888888
    
    let param : [(x:CGFloat, y:CGFloat, color:NSColor, size:CGFloat)] = [
      (x:13.8 / 16.0, y:0.05, color:.red, size:1.5 / 2.0 ),
      (x:12.2 / 16.0, y:0.05, color:.red, size:1.5 / 2.0 ),
      (x:9.2 / 16.0, y:0.1, color:.yellow, size:1.0 ),
      (x:6.7 / 16.0, y:0.1, color:.yellow, size:1.0 ),
      (x:3.4 / 16.0, y:0.1, color:.yellow, size:1.0 ),
      (x:0.9 / 16.0, y:0.1, color:.yellow, size:1.0 ),
    ]
    
    for position in 0...5 {
      
      let p = param[position]

      let xPos = bounds.width * p.x
      let yPos = bounds.height * p.y
      
      let digit = number % 10
      
      number /= 10
      
      drawDigit(xPos: xPos, yPos: yPos, xSize: xSize * p.size, ySize: ySize * p.size, color: p.color, digit: digit)

    }
    
  }
  
  func drawDigit(xPos:CGFloat, yPos:CGFloat, xSize: CGFloat, ySize:CGFloat, color:NSColor, digit:Int) {
    
    let segments : [[(x:CGFloat, y:CGFloat)]] = [
      [(12, 147), (19, 154), (67, 154), (75, 147), (67, 139), (19, 139)],
      [(70,  89), (70, 135), (78, 143), (86, 135), (86,  89), (78,  81)],
      [(70,  20), (70,  65), (78,  73), (86,  65), (86,  20), (78,  11)],
      [(12,   8), (19,  16), (67,  16), (75,   8), (67,   0), (19,   0)],
      [(0,   20), (0,   65), (8,   73), (16,  65), (16,  20), (8,   11)],
      [(0,   89), (0,  135), (8,  143), (16, 135), (16,  89), (8,   80)],
      [(12,  77), (19,  85), (67,  85), (75,  77), (67,  69), (19,  69)],
    ]

    let segments2 : [[(x:CGFloat, y:CGFloat)]] = [
      [( 3, 154), (84, 154), (65, 139), (21, 139)], // A
      [(70,  79), (70, 137), (86, 151), (86,  79)], // B
      [(70,  21), (70,  75), (86,  75), (86,   2)], // C
      [( 2,   0), (21,  16), (69,  16), (82,   1)], // D
      [( 0,   2), ( 0,  75), (16,  75), (16,  17)], // E
      [( 0,  79), ( 0, 151), (16, 138), (16,  79)], // F
      [(21,  69), (21,  85), (65,  85), (65,  69)], // G
    ]

    NSColor.setStrokeColor(color: color)
    NSColor.setFillColor(color: color)
    
    for segment in 0...6 {
      
      if let d = SevenSegmentDigit(rawValue: digit), d.drawSegment(segment: segment) {
        
        let path = NSBezierPath()
        
        path.lineWidth = 1
        
        var first = true
        
        for point in segments[segment] {
          
          let x = xPos + ((point.x + 6.0) / 98.0) * xSize
          let y = yPos + ((point.y + 6.0) / 167.0) * ySize
          
          if first {
            path.move(to: NSMakePoint(x, y))
            first = false
          }
          else {
            path.line(to: NSMakePoint(x, y))
          }
        }
        
        path.close()
        
        path.stroke()
    
        path.fill()

      }

    }
    

  }
  
  // MARK: Public Properties
  
  public var date : Date = Date() {
    didSet {
      needsDisplay = true
    }
  }
  
  
}

