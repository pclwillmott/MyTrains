//
//  CDIIdentificationItemView.swift
//  MyTrains
//
//  Created by Paul Willmott on 01/01/2024.
//

import Foundation
import AppKit

class CDIIdentificationItemView : CDIView {

  // MARK: Destructors

  #if DEBUG
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    addInit()
  }
  
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    addInit()
  }
  #endif
  
  deinit {
    lblName = nil
    lblValue = nil
    subviews.removeAll()
    #if DEBUG
    addDeinit()
    #endif
  }
  
  // MARK: Public Properties
  
  public var name : String {
    get {
      return lblName!.stringValue
    }
    set(value) {
      lblName?.stringValue = value
    }
  }

  public var value : String {
    get {
      return lblValue!.stringValue
    }
    set(value) {
      lblValue?.stringValue = value
    }
  }

  // MARK: Private & Internal Methods
  
  override internal func setup() {
    
    guard let lblName, let lblValue else {
      return
    }
    
    super.setup()
    
    addSubview(lblName)
    addSubview(lblValue)
    
    lblName.translatesAutoresizingMaskIntoConstraints = false
    lblValue.translatesAutoresizingMaskIntoConstraints = false
    
    cdiConstraints.append(contentsOf:[
      lblName.topAnchor.constraint(equalTo: self.topAnchor, constant: parentGap),
      lblName.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: parentGap),
      lblName.widthAnchor.constraint(greaterThanOrEqualToConstant: 150.0),
      lblValue.topAnchor.constraint(equalTo: self.topAnchor, constant: parentGap),
      lblValue.leadingAnchor.constraint(equalTo: lblName.trailingAnchor, constant: parentGap),
      self.bottomAnchor.constraint(equalTo: lblName.bottomAnchor, constant: parentGap),
    ])
    
  }

  // MARK: Controls

  internal var lblName : NSTextField? = NSTextField(labelWithString: "")
  
  internal var lblValue : NSTextField? = NSTextField(labelWithString: "")
  
}
