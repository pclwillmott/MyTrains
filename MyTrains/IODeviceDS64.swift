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

      for ioChannel in ioChannels {
        if let ioFunction = ioChannel.ioFunctions[0] as? IOFunctionDS64Input {
          result.insert(ioFunction.address)
        }
      }
      
      return result

    }
  }

  override public var switchAddresses : Set<Int> {
    get {

      var result : Set<Int> = []

      for ioChannel in ioChannels {
        if let ioFunction = ioChannel.ioFunctions[0] as? IOFunctionDS64Output {
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
      let ioChannel = IOChannelInput(ioDevice: self, ioChannelNumber: channelNumber, ioChannelType: .input)
      ioChannels.append(ioChannel)
      ioChannel.ioFunctions = IOFunction.functions(ioChannel: ioChannel)
    }

    for channelNumber in 9...12 {
      let ioChannel = IOChannelOutput(ioDevice: self, ioChannelNumber: channelNumber, ioChannelType: .output)
      ioChannels.append(ioChannel)
      ioChannel.ioFunctions = IOFunction.functions(ioChannel: ioChannel)
    }

  }
  
  override public func save() {
    
    super.save()
    
    if ioChannels.count == 0 {
      
      for channelNumber in 1...8 {
        let ioChannel = IOChannelInput(ioDevice: self, ioChannelNumber: channelNumber, ioChannelType: .input)
        ioChannels.append(ioChannel)
        let ioFunction = IOFunctionDS64Input(ioChannel: ioChannel, ioFunctionNumber: 1)
        ioChannel.ioFunctions.append(ioFunction)
      }

      for channelNumber in 9...12 {
        let ioChannel = IOChannelOutput(ioDevice: self, ioChannelNumber: channelNumber, ioChannelType: .output)
        ioChannels.append(ioChannel)
        let ioFunction = IOFunctionDS64Output(ioChannel: ioChannel, ioFunctionNumber: 1)
        ioFunction.address = channelNumber - 8
        ioChannel.ioFunctions.append(ioFunction)
      }

    }
    
    for ioChannel in ioChannels {
      ioChannel.save()
    }
    
  }
  
}
