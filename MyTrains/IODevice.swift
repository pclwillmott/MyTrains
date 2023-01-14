//
//  IODevice.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/01/2023.
//

import Foundation

public class IODevice : LocoNetDevice {
  
  // MARK: Constructors & Destructors
  
  // MARK: Public Properties
  
  public var upDateDelegate : UpdateDelegate?
 
  public var hasPropertySheet : Bool {
    get {
      return false
    }
  }
  
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
  
  public var addressCollision : Bool {
    get {
      for ioFunction in networkController.ioFunctions(networkId: networkId) {
        let ioDevice = ioFunction.ioDevice
        if ioDevice != self {
          if !ioDevice.switchAddresses.intersection(self.switchAddresses).isEmpty || !ioDevice.sensorAddresses.intersection(self.sensorAddresses).isEmpty {
            return true
          }
        }
      }
      return false
    }
  }

  // MARK: Public Methods
  
  public func propertySheet() {
  }
  
  public func setDefaults() {
  }
  
  public func setBoardId(newBoardId:Int) {
    
  }
  
}
