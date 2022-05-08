//
//  ORSSerialPortManagerExtensions.swift
//  MyTrains
//
//  Created by Paul Willmott on 08/05/2022.
//

import Foundation
import ORSSerial
import AppKit

extension ORSSerialPortManager {

  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    for port in ORSSerialPortManager.shared().availablePorts {
      comboBox.addItem(withObjectValue: port.path)
    }
  }
  
}
