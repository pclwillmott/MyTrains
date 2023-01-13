//
//  IODeviceBXP88.swift
//  MyTrains
//
//  Created by Paul Willmott on 12/01/2023.
//

import Foundation

public class IODeviceBXP88 : IODevice {
  
  // MARK: Public Properties
 
  public var baseSensorAddress : Int {
    get {
      return (boardId - 1) * 8 + 1
    }
  }

  override public var sensorAddresses : Set<Int> {
    get {
      
      var result : Set<Int> = []

      for ioChannel in ioChannels {
        if let ioFunction = ioChannel.ioFunctions[0] as? IOFunctionBXP88Input {
          result.insert(ioFunction.address)
        }
      }
      
      return result

    }
  }

  // MARK: Public Methods
  
  override public func decode(sqliteDataReader:SqliteDataReader?) {
    
    super.decode(sqliteDataReader: sqliteDataReader)

    for channelNumber in 1...8 {
      let ioChannel = IOChannelInput(ioDevice: self, ioChannelNumber: channelNumber)
      ioChannels.append(ioChannel)
      ioChannel.ioFunctions = IOFunction.functions(ioChannel: ioChannel)
    }

  }
  
  override public func save() {
    
    super.save()
    
    if ioChannels.count == 0 {
      
      for channelNumber in 1...8 {
        let ioChannel = IOChannelInput(ioDevice: self, ioChannelNumber: channelNumber)
        ioChannels.append(ioChannel)
        let ioFunction = IOFunctionBXP88Input(ioChannel: ioChannel, ioFunctionNumber: 1)
        ioChannel.ioFunctions.append(ioFunction)
      }

    }
    
    for ioChannel in ioChannels {
      ioChannel.save()
    }
    
  }
  
}
