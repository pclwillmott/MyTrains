//
//  IOChannel.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/01/2023.
//

import Foundation

public class IOChannel : NSObject {
  
  // MARK: Constructors & Destructors
  
  init(ioDevice:IODevice, ioChannelNumber:Int, ioChannelType:IOChannelType) {
    self.ioDevice = ioDevice
    self.ioChannelNumber = ioChannelNumber
    self.ioChannelType = ioChannelType
    super.init()
  }
  
  // MARK: Public Properties
  
  public var ioChannelNumber : Int
  
  public var ioDevice : IODevice
  
  public var ioChannelType : IOChannelType
  
  public var ioFunctions : [IOFunction] = []
  
  // MARK: Public Methods
  
  public func save() {

    for ioFunction in ioFunctions {
      ioFunction.save()
    }
    
  }
  
  public func propertySheet() {
    
  }
  
}
