//
//  CDIStackView.swift
//  MyTrains
//
//  Created by Paul Willmott on 01/01/2024.
//

import Foundation
import AppKit

class CDIStackView : CDIView, CDIStackViewManagerDelegate {
 
  // MARK: Destructors
  
  deinit {
    for view in stackView!.arrangedSubviews {
      stackView?.removeArrangedSubview(view)
    }
    stackView = nil
  }
  
  // MARK: Private & Internal Methods
  
  override internal func setup() {
    
    guard let stackView, needsInit else {
      return
    }
    
    super.setup()
    
    stackView.orientation = .vertical
    stackView.alignment = .leading
    stackView.translatesAutoresizingMaskIntoConstraints = false
    
    addSubview(stackView)
    
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: parentGap),
      stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: parentGap),
      stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -parentGap),
      self.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: parentGap),
    ])
    
  }
  
  // MARK: Public Methods
  
  public func addArrangedSubview(_ view:NSView) {
  
    guard let stackView else {
      return
    }
    
    stackView.addArrangedSubview(view)
 
    NSLayoutConstraint.activate([
      view.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
      view.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
    ])

  }
  
  // MARK: Controls
  
  internal var stackView : NSStackView? = NSStackView()
  
}
