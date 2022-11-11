//
//  BaudRate.swift
//  MyTrains
//
//  Created by Paul Willmott on 08/05/2022.
//

import Foundation
import Cocoa

public enum BaudRate : Int {
  
  case br9600   = 0
  case br19200  = 1
  case br28800  = 2
  case br38400  = 3
  case br57600  = 4
  case br76800  = 5
  case br115200 = 6
  case br230400 = 7
  case br460800 = 8
  case br576000 = 9
  case br921600 = 10
  
  public var baudRate : speed_t {
    
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
  
  private static let rates : [speed_t] =
  [
     9600,
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
  
  public static func baudRate(speed: speed_t) -> BaudRate {
    for index in 0...rates.count-1 {
      if rates[index] == speed {
        return BaudRate(rawValue: index)!
      }
    }
    return .br19200
  }
  
  public static func populate(comboBox:NSComboBox) {
    
    comboBox.removeAllItems()
    
    for rate in rates {
      comboBox.addItem(withObjectValue: "\(rate)")
    }
    
  }

}
