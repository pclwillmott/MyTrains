//
//  SensorType.swift
//  MyTrains
//
//  Created by Paul Willmott on 10/02/2024.
//

import Foundation

public enum SensorType : UInt8 {
  
  case other       = 0
  case lightSensor = 1
  case reedSwitch  = 2
  case rfid        = 3
  case button      = 4
  
  // MARK: Public Properties
  
  public var title : String {
    return SensorType.titles[Int(self.rawValue)]
  }

  // MARK: Private Class Properties
  
  private static let titles = [
    String(localized: "Other"),
    String(localized: "Light Sensor"),
    String(localized: "Reed Switch"),
    String(localized: "RFID Reader"),
    String(localized: "Push Button"),
  ]

  private static var map : String {
    
    let items : [SensorType] = [
      .lightSensor,
      .reedSwitch,
      .rfid,
      .button,
      .other,
    ]
    
    var map = "<default>\(defaultValue.rawValue)</default>\n<map>\n"

    for item in items {
      map += "<relation><property>\(item.rawValue)</property><value>\(item.title)</value></relation>\n"
    }

    map += "</map>\n"
    
    return map
    
  }
  // MARK: Public Class Properties
  
  public static let defaultValue : SensorType = .other

  // MARK: Public Class Methods
  
  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: CDI.SENSOR_TYPE, with: map)
  }

}
