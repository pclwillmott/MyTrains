//
//  MultiTabView.swift
//  MyTrains
//
//  Created by Paul Willmott on 18/12/2023.
//

import Foundation
import Cocoa

@IBDesignable
class MultiTabView: NSView {

  // MARK: Constructors
  
  // MARK: Private Properties
  
  private var tabButtons : [NSButton] = []
  
  private var scrollViews : [NSScrollView] = []
  
  private var nextButton : NSButton?
  
  private var previousButton : NSButton?
  
  private var currentPage : Int {
    guard tabsToShow > 0 else {
      return 0
    }
    return currentTab / tabsToShow
  }
  
  private var currentTab : Int = 0 {
    didSet {
      needsDisplay = true
    }
  }
  
  private var numberOfPages : Int {
    guard tabs > 0 && tabsToShow > 0 else {
      return 0
    }
    return (tabs - 1 ) / tabsToShow + 1
  }
  
  private var tabsToShow : Int {
    guard maxButtonWidth > 0.0, let nextButton, let previousButton else {
      return 0
    }
    return Int((frame.width - nextButton.frame.width - previousButton.frame.width) / maxButtonWidth)
  }
  
  private var tabsStartX : CGFloat {
    guard maxButtonWidth > 0.0, let nextButton, let previousButton else {
      return 0.0
    }
    let number = min(tabsToShow, tabButtons.count - currentTab)
    return (frame.width - (CGFloat(number) * maxButtonWidth)) / 2.0
  }
  
  private var maxButtonWidth : CGFloat = 0.0
  
  // MARK: Public Properties

  public var replicationName : String = "Tab" {
    didSet {
      for button in tabButtons {
        button.title = tabTitle(index: button.tag)
      }
      needsDisplay = true
    }
  }
  
  public var tabs : Int = 0 {
    didSet {
      
      tabButtons.removeAll()
      subviews.removeAll()

      if previousButton == nil {
        let button : NSButton = NSButton(title: "⇦", target: self, action: #selector(self.previousPageAction(_:)))
        previousButton = button
        addSubview(button)
      }

      if nextButton == nil {
        let button : NSButton = NSButton(title: "⇨", target: self, action: #selector(self.nextPageAction(_:)))
        nextButton = button
        addSubview(button)
      }

      maxButtonWidth = 0.0

      for index in 0 ... tabs - 1 {
        let button : NSButton = NSButton(title: tabTitle(index: index), target: self, action: #selector(self.tabAction(_:)))
        maxButtonWidth = max(maxButtonWidth, button.frame.width - 14.0)
        button.tag = index
        tabButtons.append(button)
        addSubview(button)
        let scrollView = NSScrollView()
        scrollView.frame = NSRect(x: 0.0, y: 0.0, width: frame.width - 100, height: frame.height - 60.0)
        let button2 : NSButton = NSButton(title: tabTitle(index: index), target: self, action: #selector(self.tabAction(_:)))
        button2.frame = NSRect(x: 0, y: 500.0, width: button2.frame.width, height: button2.frame.height)
        scrollView.documentView = NSView()
        scrollView.documentView?.addSubview(button2)
        scrollView.documentView?.frame = NSMakeRect(0.0, 0.0, frame.width - 100, 1000.0)
        scrollView.allowsMagnification = false
        scrollView.autohidesScrollers = true
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        scrollView.contentView.backgroundColor = .windowBackgroundColor
        scrollView.contentView.backgroundColor = .underPageBackgroundColor

    //    scrollView.magnification = UserDefaults.standard.double(forKey: DEFAULT.SWITCHBOARD_EDITOR_MAG)
       scrollViews.append(scrollView)
        addSubview(scrollView)
      }
      
      scrollViews[0].scrollsDynamically = true
      
      needsDisplay = true
      
    }
    
  }
  
  override func draw(_ dirtyRect: NSRect) {

    super.draw(dirtyRect)

    guard !tabButtons.isEmpty, let nextButton, let previousButton else {
      return
    }
    
    let startTab = currentPage * tabsToShow
    let endTab = min(startTab + tabsToShow, tabButtons.count) - 1
    
    var x : CGFloat = 0.0
    
    var y : CGFloat = frame.height - 60.0
    
    previousButton.isHidden = currentPage == 0
    previousButton.frame = NSRect(x: x , y: y, width: previousButton.frame.width, height: previousButton.frame.height)

    nextButton.isHidden = currentPage == numberOfPages - 1
    nextButton.frame = NSRect(x: x + frame.width - nextButton.frame.width, y: y, width: nextButton.frame.width, height: nextButton.frame.height)

    x = tabsStartX
    
    for button in tabButtons {
      scrollViews[button.tag].frame = NSRect(x: 0.0, y: 0.0, width: frame.width - 100, height: frame.height - 60.0)
      scrollViews[button.tag].isHidden = currentTab != button.tag
      button.isHidden = button.tag < startTab || button.tag > endTab
      if !button.isHidden {
        button.frame = NSRect(x: x, y: y, width: button.frame.width, height: button.frame.height)
        button.isBordered = button.tag == currentTab
        x += button.frame.width - 14.0
      }
    }
    
    /*
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
  
  // MARK: Private Methods
  
  private func tabTitle(index:Int) -> String {
    return "\(replicationName) \(index + 1)"
  }
  
  @IBAction func tabAction(_ sender: NSButton) {
    currentTab = sender.tag
  }

  @IBAction func nextPageAction(_ sender: NSButton) {
    currentTab = min(currentTab + tabsToShow, tabs - 1)
  }

  @IBAction func previousPageAction(_ sender: NSButton) {
    currentTab = max(0, currentTab - tabsToShow)
  }

}
  
