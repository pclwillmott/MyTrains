//
//  CDIIdentificationItemView.swift
//  MyTrains
//
//  Created by Paul Willmott on 01/01/2024.
//

import Foundation
import AppKit

class CDIIdentificationItemView : CDIView {

  // MARK: Public Properties
  
  public var name : String {
    get {
      return lblName.stringValue
    }
    set(value) {
      lblName.stringValue = value
    }
  }

  public var value : String {
    get {
      return lblValue.stringValue
    }
    set(value) {
      lblValue.stringValue = value
    }
  }

  // MARK: Private & Internal Methods
  
  override internal func setup() {
    
    guard needsInit else {
      return
    }
    
    super.setup()
    
    addSubview(lblName)
    addSubview(lblValue)
    
    lblName.translatesAutoresizingMaskIntoConstraints = false
    lblValue.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      lblName.topAnchor.constraint(equalTo: self.topAnchor, constant: gap),
      lblName.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: gap),
      lblName.widthAnchor.constraint(greaterThanOrEqualToConstant: 100.0),
      lblValue.topAnchor.constraint(equalTo: self.topAnchor, constant: gap),
      lblValue.leadingAnchor.constraint(equalTo: lblName.trailingAnchor, constant: gap),
      lblValue.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -gap),
      self.bottomAnchor.constraint(equalTo: lblName.bottomAnchor, constant: gap),
    ])
    
  }

  // MARK: Controls

  internal var lblName = NSTextField(labelWithString: "")
  
  internal var lblValue = NSTextField(labelWithString: "")
  
}
