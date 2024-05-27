//
//  LayoutBuilderPanelArea.swift
//  MyTrains
//
//  Created by Paul Willmott on 27/05/2024.
//

import Foundation
import AppKit

extension LayoutBuilderVC {
  
  // MARK: Internal Properties
  
  internal var switchboardMagnification : CGFloat {
    get {
      return userSettings?.cgFloat(forKey: DEFAULT.MAGNIFICATION) ?? 1.0
    }
    set(value) {
      userSettings?.set(value, forKey: DEFAULT.MAGNIFICATION)
    }
  }
  
  // MARK: Internal Methods
  
  internal func setupPanelArea() {
    
    
    if let layoutView, let layoutStripView {
      
      layoutStripView.translatesAutoresizingMaskIntoConstraints = false
      
      layoutView.addSubview(layoutStripView)
      
      constraints.append(layoutStripView.topAnchor.constraint(equalTo: layoutView.topAnchor))
      constraints.append(layoutStripView.centerXAnchor.constraint(equalTo: layoutView.centerXAnchor))
      constraints.append(layoutStripView.heightAnchor.constraint(equalToConstant: 20.0))
      
      var lastButton : NSButton?
      
      for layoutButton in LayoutButton.allCases {
        if let button = layoutButton.icon.button(target: self, action: #selector(btnLayoutAction(_:))) {
          layoutButtons.append(button)
          button.translatesAutoresizingMaskIntoConstraints = false
          button.isBordered = false
          button.tag = layoutButton.rawValue
          button.toolTip = layoutButton.tooltip
          layoutStripView.addSubview(button)
          constraints.append(button.centerYAnchor.constraint(equalTo: layoutStripView.centerYAnchor))
          if let lastButton {
            constraints.append(button.leadingAnchor.constraint(equalToSystemSpacingAfter: lastButton.trailingAnchor, multiplier: 1.0))
          }
          else {
            constraints.append(button.leadingAnchor.constraint(equalToSystemSpacingAfter: layoutStripView.leadingAnchor, multiplier: 1.0))
          }
          lastButton = button
        }
      }

      constraints.append(layoutStripView.trailingAnchor.constraint(equalToSystemSpacingAfter: lastButton!.trailingAnchor, multiplier: 1.0))
      constraints.append(layoutView.widthAnchor.constraint(greaterThanOrEqualTo: layoutStripView.widthAnchor, multiplier: 1.0))
      
      scrollView.translatesAutoresizingMaskIntoConstraints = false
      scrollView.documentView?.frame = NSMakeRect(0.0, 0.0, 2000.0, 2000.0)
      scrollView.allowsMagnification = true
      scrollView.magnification = switchboardMagnification
      
      layoutView.addSubview(scrollView)
      
      constraints.append(scrollView.topAnchor.constraint(equalToSystemSpacingBelow: layoutStripView.bottomAnchor, multiplier: 1.0))
      constraints.append(scrollView.leadingAnchor.constraint(equalTo: layoutView.leadingAnchor))
      constraints.append(scrollView.trailingAnchor.constraint(equalTo: layoutView.trailingAnchor))
      constraints.append(scrollView.bottomAnchor.constraint(equalTo: layoutView.bottomAnchor))
      
      
    }

  }
  
  internal func releasePanelAreaControls() {
    
    layoutStripView?.subviews.removeAll()
    layoutStripView = nil
    
    for index in 0 ... layoutButtons.count - 1 {
      if let button = layoutButtons[index] {
        button.image = nil
        button.target = nil
        button.action = nil
      }
      layoutButtons[index] = nil
    }
    layoutButtons.removeAll()
    
  }
  
  // MARK: Actions
  
  @objc func btnLayoutAction(_ sender: NSButton) {
    
    guard let button = LayoutButton(rawValue: sender.tag) else {
      return
    }
    
    switch button {
    case .zoomIn:
      switchboardMagnification += 0.1
      scrollView.magnification = switchboardMagnification
    case .zoomOut:
      switchboardMagnification -= 0.1
      scrollView.magnification = switchboardMagnification
    case .fitToSize:
      
      scrollView.magnification = 1.0

      let sWidth = scrollView.frame.width
      let sHeight = scrollView.frame.height
      let gWidth = switchboardView.width
      let gHeight = switchboardView.height

      var scale = 1.0

      if gWidth > gHeight {
        scale = sWidth / gWidth
      }
      else {
        scale = sHeight / gHeight
      }
      switchboardMagnification = scale
      scrollView.magnification = switchboardMagnification
      
    }
    
  }

}
