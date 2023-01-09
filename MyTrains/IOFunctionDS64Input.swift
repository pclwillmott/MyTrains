//
//  IOFunctionInput.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/01/2023.
//

import Foundation

public class IOFunctionDS64Input : IOFunction {
  
  // MARK: Public Properties
  
  public var sensorAddress : Int {
    get {
      if let device = ioDevice as? IODeviceDS64 {
        return device.baseSensorAddress + ioChannel.channelNumber
      }
      return -1
    }
  }
  
}
