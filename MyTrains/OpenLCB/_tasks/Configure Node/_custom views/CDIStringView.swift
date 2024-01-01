//
//  CDIStringView.swift
//  MyTrains
//
//  Created by Paul Willmott on 20/12/2023.
//

import Foundation
import AppKit

class CDIStringView: CDITextView {
  
  // MARK: Public Properties

  public var stringValue : String {
    get {
      return textField.stringValue
    }
    set(value) {
      addTextField()
      textField.stringValue = value
    }
  }

  // MARK: Private & Internal Methods
  
  override internal func viewType() -> OpenLCBCDIViewType? {
    return .string
  }
  
  // MARK: NSTextFieldDelegate, NSControlTextEditingDelegate Methods

  @objc func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
    
    if let maxValue, control.stringValue > maxValue {
      return false
    }

    if let minValue, control.stringValue < minValue {
      return false
    }
    
    if let elementSize, control.stringValue.count >= elementSize {
      return false
    }

    return true
    
  }

}

