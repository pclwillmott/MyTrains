//
//  CDIStringView.swift
//  MyTrains
//
//  Created by Paul Willmott on 20/12/2023.
//

import Foundation
import AppKit

class CDIStringView: CDITextView {
  
  // MARK: Private & Internal Properties
  

  // MARK: Public Properties

  public var minValue : String?
  
  public var maxValue : String?
  
  public var stringValue : String {
    get {
      return textField.stringValue
    }
    set(value) {
      textField.stringValue = value
    }
  }

  // MARK: Private & Internal Methods
  
  override internal func viewType() -> OpenLCBCDIViewType? {
    return .string
  }
  
  override internal func isValid(value:String) -> Bool {
    
    if let maxValue, value > maxValue {
      displayErrorMessage(message: "The value is greater than the maximum value of \"\(maxValue)\".")
      return false
    }

    if let minValue, value < minValue {
      displayErrorMessage(message: "The value is less than the minimum value of \"\(minValue)\".")
      return false
    }
    
    if let elementSize, value.count >= elementSize {
      displayErrorMessage(message: "Text has too many characters. The maximum length is \(elementSize - 1) characters.")
      return false
    }

    return true
    
  }
  
}

