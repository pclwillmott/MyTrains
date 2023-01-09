//
//  IOChannel.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/01/2023.
//

import Foundation

public enum IOChannelType : Int {
  case input = 0
  case output = 1
  case ioTC64MkII = 2
}

public class IOChannel : NSObject {
  
  // MARK: Constructors & Destructors
  
  init(ioDevice:IODevice, channelNumber:Int, channelType:IOChannelType) {
    self.ioDevice = ioDevice
    self.channelNumber = channelNumber
    self.channelType = channelType
    super.init()
  }
  
  // MARK: Public Properties
  
  public var channelNumber : Int
  
  public var ioDevice : IODevice
  
  public var channelType : IOChannelType
  
  public var ioFunctions : [IOFunction] = []
  
  // MARK: Public Methods
  
  public func save() {

    for ioFunction in ioFunctions {
      ioFunction.save()
    }
    
  }
  
}
