//
//  IODeviceDS64.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/01/2023.
//

import Foundation

public class IODeviceDS64 : IODevice {
  
  // MARK: Public Properties
 
  public var isGeneralReporting : Bool {
    get {
      return getState(switchNumber: 21) == .thrown
    }
  }
  
  public var baseSensorAddress : Int {
    get {
      return (boardId - 1) * 8 + 1
    }
  }

  override public var sensorAddresses : Set<Int> {
    get {
      
      var result : Set<Int> = []

      for sensor in 0...7 {
        result.insert(baseSensorAddress + sensor)
      }
    
      return result
      
    }
  }

  override public var switchAddresses : Set<Int> {
    get {

      var result : Set<Int> = []

      for ioChannel in ioChannels {
        if let ioFunction = ioChannel.ioFunctions[0] as? IOFunctionDS64Output {
          result.insert(ioFunction.switchAddress)
        }
      }
      
      return result
      
    }
  }

  // MARK: Public Methods
  
  override public func decode(sqliteDataReader:SqliteDataReader?) {
    
    super.decode(sqliteDataReader: sqliteDataReader)
    
  }
  
  override public func save() {
    
    super.save()
    
    if ioChannels.count == 0 {
      
      for channelNumber in 0...7 {
        let ioChannel = IOChannelInput(ioDevice: self, channelNumber: channelNumber, channelType: .input)
        ioChannels.append(ioChannel)
        let ioFunction = IOFunctionDS64Input(ioChannel: ioChannel, functionNumber: 0)
        ioChannel.ioFunctions.append(ioFunction)
      }

      for channelNumber in 8...11 {
        let ioChannel = IOChannelOutput(ioDevice: self, channelNumber: channelNumber, channelType: .output)
        ioChannels.append(ioChannel)
        let ioFunction = IOFunctionDS64Output(ioChannel: ioChannel, functionNumber: 0)
        ioChannel.ioFunctions.append(ioFunction)
      }

    }
    
    for ioChannel in ioChannels {
      ioChannel.save()
    }
    
  }
  
}
