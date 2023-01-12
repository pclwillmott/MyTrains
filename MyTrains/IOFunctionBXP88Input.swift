//
//  IOFunctionBXP88Input.swift
//  MyTrains
//
//  Created by Paul Willmott on 12/01/2023.
//

import Foundation

public class IOFunctionBXP88Input : IOFunction {
  
  // MARK: Public Properties
  
  override public var address : Int {
    get {
      if let device = ioDevice as? IODeviceBXP88 {
        return device.baseSensorAddress + ioChannel.ioChannelNumber - 1
      }
      return _address
    }
    set(value) {
      _ = value
      _address = address
    }
  }

}
