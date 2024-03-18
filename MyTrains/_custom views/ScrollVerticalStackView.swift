//
//  CDIElementContainerView.swift
//  MyTrains
//
//  Created by Paul Willmott on 20/12/2023.
//

import Foundation
import AppKit

class ScrollVerticalStackView : NSView, CDIStackViewManagerDelegate {
  
  // MARK: Destructors
  
  deinit {
    debugLog("deinit")
    scrollView?.documentView = nil
    scrollView = nil
    for view in stackView!.arrangedSubviews {
      stackView?.removeArrangedSubview(view)
    }
    stackView = nil
  }
  
  // MARK: Drawing Methods
  
  override func draw(_ dirtyRect: NSRect) {
    setup()
  }
  
  // MARK: Private & Internal Properties
  
  internal var scrollView : NSScrollView? = NSScrollView()
  
  internal var stackView : NSStackView? = NSStackView()
  
  // MARK: Private & Internal Methods
  
  private func setup() {
    
    guard let scrollView, let stackView, scrollView.documentView == nil else {
      return
    }
    
    addSubview(scrollView)

    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.contentView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.allowsMagnification = false
    scrollView.autohidesScrollers = false
    scrollView.hasVerticalScroller = true

    NSLayoutConstraint.activate([
      scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      scrollView.topAnchor.constraint(equalTo: self.topAnchor),
      scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
    ])
    
    stackView.orientation = .vertical
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.alignment = .leading

    scrollView.documentView = stackView

    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
      stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
    ])

  }
  
  // MARK: Public Properties
  
  public var arrangedSubViews : [NSView] {
    return stackView!.arrangedSubviews
  }
  
  // MARK: Public Methods
  
  public func addArrangedSubview(_ view:NSView) {
    
    guard let stackView else {
      return
    }
    
    view.translatesAutoresizingMaskIntoConstraints = false
    
    stackView.addArrangedSubview(view)
    
    NSLayoutConstraint.activate([
      view.widthAnchor.constraint(equalTo: stackView.widthAnchor)
    ])
    
  }
  
}
