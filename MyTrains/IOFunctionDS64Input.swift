//
//  IOFunctionInput.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/01/2023.
//

import Foundation

public class IOFunctionDS64Input : IOFunction {
  
  // MARK: Public Properties
  
  override public var address : Int {
    get {
      if let device = ioDevice as? IODeviceDS64 {
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
