//
//  CDIStringView.swift
//  MyTrains
//
//  Created by Paul Willmott on 20/12/2023.
//

import Foundation
import AppKit

class CDIStringView: CDIView {
  
  // MARK: Drawing Stuff
  
  override func draw(_ dirtyRect: NSRect) {
 //   initialize()
  }
  
  // MARK: Private & Internal Methods
  
  override internal func viewType() -> OpenLCBCDIViewType? {
    return .string
  }
  
  internal var _textField : NSTextField?

  internal var textField : NSTextField {
    
    if _textField == nil {
      
      let field = NSTextField()
      
      addSubview(field)
      
      field.translatesAutoresizingMaskIntoConstraints = false
      
      NSLayoutConstraint.activate([
        field.topAnchor.constraint(equalTo: self.topAnchor),
        field.leftAnchor.constraint(equalTo: self.leftAnchor),
        field.rightAnchor.constraint(equalTo: self.rightAnchor),
        field.bottomAnchor.constraint(equalTo: self.bottomAnchor)
      ])

      _textField = field

    }
    
    return _textField!
    
  }

  // MARK: Public Properties
  
  public var stringValue : String {
    get {
      return textField.stringValue
    }
    set(value) {
      textField.stringValue = value
    }
  }
  
}

