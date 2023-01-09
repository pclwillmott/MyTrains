//
//  IOFunction.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/01/2023.
//

import Foundation

public class IOFunction : NSObject {

  // MARK: Constructors & Destructors
  
  init(ioChannel:IOChannel, functionNumber:Int) {
    self.ioChannel = ioChannel
    self.functionNumber = functionNumber
    super.init()
  }
  
  // MARK: Public Properties
  
  public var ioDevice : IODevice {
    get {
      return ioChannel.ioDevice
    }
  }
  
  public var ioChannel : IOChannel
  
  public var functionNumber : Int
  
  // MARK: Public Methods
  
  public func save() {
    
  }

}
