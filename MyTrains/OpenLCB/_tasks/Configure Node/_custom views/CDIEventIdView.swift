//
//  CDIEventIdView.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/12/2023.
//

import Foundation
import AppKit

class CDIEventIdView: CDITextView {
  
  // MARK: Private & Internal Methods
  
  override internal func dataWasSet() {
    
 //   addTextField()
    
    if let value = UInt64(bigEndianData: bigEndianData) {
      textField.stringValue = value == 0 ? "" : value.toHexDotFormat(numberOfBytes: 8)
      textField.placeholderString = "00.00.00.00.00.00.00.00"
    }

  }


}

