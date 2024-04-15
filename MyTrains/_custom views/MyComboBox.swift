//
//  MyComboBox.swift
//  MyTrains
//
//  Created by Paul Willmott on 15/04/2024.
//

import Foundation
import AppKit

class MyComboBox : NSComboBox, NSComboBoxDelegate {
  
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    self.delegate = self
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    self.delegate = self
  }
  
  @objc func comboBoxSelectionDidChange(_ notification: Notification) {
    _ = target?.perform(action, with: self)
  }
  
}
