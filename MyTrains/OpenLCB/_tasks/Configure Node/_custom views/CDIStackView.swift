//
//  CDIStackView.swift
//  MyTrains
//
//  Created by Paul Willmott on 01/01/2024.
//

import Foundation
import AppKit

class CDIStackView : CDIView, CDIStackViewManagerDelegate {
 
  // MARK: Private & Internal Methods
  
  override internal func setup() {
    
    guard needsInit else {
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
  
    stackView.addArrangedSubview(view)
 
    NSLayoutConstraint.activate([
      view.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
      view.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
    ])

  }
  
  // MARK: Controls
  
  internal var stackView = NSStackView()
  
}
