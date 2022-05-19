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
  
  public var baudRate : UInt {
    
    get {
      return BaudRate.rates[self.rawValue]
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

      let x = Double(BaudRate.rates[self.rawValue])
      if let string = formatter.string(from: x as NSNumber) {
        return string
      }
      
      return ""
      
    }
    
  }
  
  public static var numberOfRates : Int {
    get {
      return BaudRate.rates.count
    }
  }
  
  private static let rates : [UInt] =
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
  
  public static func populate(comboBox:NSComboBox) {
    
    comboBox.removeAllItems()
    
    for rate in rates {
      comboBox.addItem(withObjectValue: "\(rate)")
    }
    
  }

}
