//
//  CDIEventIdView.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/12/2023.
//

import Foundation
import AppKit

class CDIEventIdView: CDITextView {
  
  // MARK: Public Properties

  public var eventIdValue : UInt64 {
    get {
      return UInt64(dotHex: textField.stringValue) ?? 0
    }
    set(value) {
      addTextField()
      textField.stringValue = value == 0 ? "" : value.toHexDotFormat(numberOfBytes: 8)
      textField.placeholderString = "00.00.00.00.00.00.00.00"
    }
  }

  // MARK: Private & Internal Methods
  
  override internal func viewType() -> OpenLCBCDIViewType? {
    return .eventid
  }
  
  // MARK: NSTextFieldDelegate, NSControlTextEditingDelegate Methods

  @objc func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
    return UInt64(dotHex: control.stringValue) != nil
  }

}

