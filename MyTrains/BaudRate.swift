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
