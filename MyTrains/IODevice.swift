//
//  IODevice.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/01/2023.
//

import Foundation

public class IODevice : LocoNetDevice {
  
  // MARK: Public Properties
 
  public var ioChannels : [IOChannel] = []
  
  public var sensorAddresses : Set<Int> {
    get {
      return []
    }
  }

  public var switchAddresses : Set<Int> {
    get {
      return []
    }
  }

  // MARK: Public Methods
  
}
