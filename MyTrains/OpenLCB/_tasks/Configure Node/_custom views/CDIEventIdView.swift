//
//  CDIEventIdView.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/12/2023.
//

import Foundation
import AppKit

class CDIEventIdView: CDITextView {
  
  // MARK: Private & Internal Properties
  

  // MARK: Public Properties

  public var eventIdValue : UInt64 {
    get {
      return UInt64(dotHex: textField.stringValue) ?? 0
    }
    set(value) {
      textField.stringValue = value == 0 ? "" : value.toHexDotFormat(numberOfBytes: 8)
      textField.placeholderString = "00.00.00.00.00.00.00.00"
    }
  }

  // MARK: Private & Internal Methods
  
  override internal func viewType() -> OpenLCBCDIViewType? {
    return .eventid
  }
  
  override internal func isValid(value:String) -> Bool {
    
    if UInt64(dotHex: value) == nil {
      displayErrorMessage(message: "Invalid Event Id.")
      return false
    }

    return true
    
  }
  
}

