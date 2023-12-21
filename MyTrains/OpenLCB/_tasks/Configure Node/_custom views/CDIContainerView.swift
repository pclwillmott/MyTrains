//
//  CDIElementContainerView.swift
//  MyTrains
//
//  Created by Paul Willmott on 20/12/2023.
//

import Foundation
import AppKit

class CDIContainerView : NSView {
  
  // MARK: Drawing Stuff
  
  override func draw(_ dirtyRect: NSRect) {
  }
  
  // MARK: Private & Internal Properties
  
  internal var views : [NSView] = []
  
  internal var _scrollView : NSScrollView?
  
  internal var last : NSLayoutYAxisAnchor?
  
  internal var scrollView : NSScrollView {
    
    if _scrollView == nil {
      
      let scroll = NSScrollView()

      addSubview(scroll)

      scroll.documentView = NSView()
      scroll.documentView?.frame = NSMakeRect(0.0, 0.0, frame.width, 2000.0)
      scroll.allowsMagnification = false
      scroll.autohidesScrollers = true
      scroll.hasVerticalScroller = true

      scroll.translatesAutoresizingMaskIntoConstraints = false
      
      NSLayoutConstraint.activate([
        scroll.topAnchor.constraint(equalTo: self.topAnchor),
        scroll.leftAnchor.constraint(equalTo: self.leftAnchor),
        scroll.rightAnchor.constraint(equalTo: self.rightAnchor),
        scroll.bottomAnchor.constraint(equalTo: self.bottomAnchor)
      ])

      NSLayoutConstraint.activate([
        scroll.documentView!.leftAnchor.constraint(equalTo: scroll.leftAnchor),
        scroll.documentView!.rightAnchor.constraint(equalTo: scroll.rightAnchor),
      ])

      _scrollView = scroll
      
      last = _scrollView!.documentView!.topAnchor
      
    }
    
    return _scrollView!

  }
  
  // MARK: Private & Internal Methods
  
  // MARK: Public Methods
  
  public func append(view:NSView) {
    
    scrollView.documentView?.addSubview(view)

    view.translatesAutoresizingMaskIntoConstraints = false
    
    views.append(view)
    
    NSLayoutConstraint.activate([
      view.topAnchor.constraint(equalTo: last!),
      view.leftAnchor.constraint(equalTo: scrollView.documentView!.leftAnchor),
      view.rightAnchor.constraint(equalTo: scrollView.documentView!.rightAnchor),
    ])

    last = view.bottomAnchor

  }
  
}
