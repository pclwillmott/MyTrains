//
//  IODeviceTC64MkII.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/01/2023.
//

import Foundation

public class IODeviceTC64MkII : IODevice {
  
  // MARK: Public Properties
  
  // MARK: Public Methods
  
  override public func decode(sqliteDataReader:SqliteDataReader?) {
    
    super.decode(sqliteDataReader: sqliteDataReader)
    
  }
  
  override public func save() {
    
    super.save()
    
    if ioChannels.count == 0 {
      
      for channelNumber in 0...63 {
        let ioChannel = IOChannelTC64MkII(ioDevice: self, channelNumber: channelNumber, channelType: .ioTC64MkII)
        ioChannels.append(ioChannel)
        for functionNumber in 0...2 {
          let ioFunction = IOFunctionTC54MkII(ioChannel: ioChannel, functionNumber: functionNumber)
          ioChannel.ioFunctions.append(ioFunction)
        }
      }

    }
    
    for ioChannel in ioChannels {
      ioChannel.save()
    }
    
  }
  
}
