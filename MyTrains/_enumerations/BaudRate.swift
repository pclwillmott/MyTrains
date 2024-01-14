//
//  BaudRate.swift
//  MyTrains
//
//  Created by Paul Willmott on 08/05/2022.
//

import Foundation
import AppKit

public enum BaudRate : UInt8 {
  
  case br9600   = 0
  case br19200  = 1
  case br28800  = 2
  case br38400  = 3
  case br57600  = 4
  case br76800  = 5
  case br115200 = 6
  case br125000 = 7
  case br230400 = 8
  case br460800 = 9
  case br576000 = 10
  case br921600 = 11
  
  // MARK: Public Properties
  
  public var baudRate : speed_t {
    return BaudRate.rates[Int(self.rawValue)]
  }
  
  public var title : String {
    
    let formatter = NumberFormatter()
    
    formatter.usesGroupingSeparator = true
    formatter.groupingSize = 3

    formatter.alwaysShowsDecimalSeparator = false
    formatter.minimumFractionDigits = 0
    formatter.maximumFractionDigits = 0

    let x = Double(BaudRate.rates[Int(self.rawValue)])
    return formatter.string(from: x as NSNumber)!

  }
  
  // MARK: Private Class Properties
  
  private static let rates : [speed_t] =
  [
     9600,
    19200,
    28800,
    38400,
    57600,
    76800,
   115200,
   125000,
   230400,
   460800,
   576000,
   921600,
  ]
  
  // MARK: Public Class Properties
  
  public static let mapPlaceholder = CDI.BAUD_RATE
  
  public static var numberOfRates : Int {
    return BaudRate.rates.count
  }
  
  private static var map : String {
    
    let items : [BaudRate] = [
      .br9600,
      .br19200,
      .br28800,
      .br38400,
      .br57600,
      .br76800,
      .br115200,
      .br125000,
      .br230400,
      .br460800,
      .br576000,
      .br921600,
    ]
    
    var map = "<map>\n"
    
    for item in items {
      map += "<relation><property>\(item.rawValue)</property><value>\(item.title)</value></relation>\n"
    }
    
    map += "</map>\n"

    return map
    
  }
  
  // MARK: Public Class Methods

  public static func baudRate(speed: speed_t) -> BaudRate {
    for index in 0...rates.count-1 {
      if rates[index] == speed {
        return BaudRate(rawValue: UInt8(index))!
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

  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: mapPlaceholder, with: map)
  }

}
