//
//  IOFunctionType.swift
//  MyTrains
//
//  Created by Paul Willmott on 11/01/2023.
//

import Foundation

public enum IOFunctionType : Int {
  
  case generalSensorReport = 0
  case switchInputReport = 1
  case switchOutputReport = 2
  case setSwitchCommand = 3
  case setSwitch = 4
  
  public static let defaultValue : IOFunctionType = .generalSensorReport
  
}
