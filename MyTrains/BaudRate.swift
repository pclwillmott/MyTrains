//
//  BaudRate.swift
//  MyTrains
//
//  Created by Paul Willmott on 08/05/2022.
//

import Foundation
import Cocoa

public enum BaudRate : Int {
  
  case br19200  = 0
  case br28800  = 1
  case br38400  = 2
  case br57600  = 3
  case br76800  = 4
  case br115200 = 5
  case br230400 = 6
  case br460800 = 7
  case br576000 = 8
  case br921600 = 9
  
  public var baudRate : NSNumber {
    
    get {
      
      let rates : [NSNumber] =
      [
        19200,
        28800,
        38400,
        57600,
        76800,
       115200,
       230400,
       460800,
       576000,
       921600,
      ]
      
      return rates[self.rawValue]
      
    }
    
  }
  
  public var title : String {
    
    get {
      
      let formatter = NumberFormatter()
      
      formatter.usesGroupingSeparator = true
      formatter.groupingSize = 3

      formatter.alwaysShowsDecimalSeparator = false
      formatter.minimumFractionDigits = 0
      formatter.maximumFractionDigits = 0

      let x = Double(truncating: self.baudRate)
      if let string = formatter.string(from: NSNumber(value:x)) {
        return string
      }
      
      return ""
      
    }
    
  }
  
  public static var numberOfRates : Int {
    get {
      return 10
    }
  }
  
  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    for index in 0...BaudRate.numberOfRates-1 {
      if let rate = BaudRate(rawValue: index) {
        comboBox.addItem(withObjectValue: rate.title)
      }
    }

  }
  
}
