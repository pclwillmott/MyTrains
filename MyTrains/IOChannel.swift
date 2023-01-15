//
//  IOChannel.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/01/2023.
//

import Foundation

public class IOChannel : NSObject {
  
  // MARK: Constructors & Destructors
  
  init(ioDevice:IODevice, ioChannelNumber:Int) {
    self.ioDevice = ioDevice
    self.ioChannelNumber = ioChannelNumber
    super.init()
  }
  
  // MARK: Private Properties
  
  internal var _channelType : InputOutput = .input
  
  // MARK: Public Properties
  
  public var hasPropertySheet : Bool {
    get {
      return false
    }
  }
  
  public var canWriteChannel : Bool {
    get {
      return false
    }
  }
  
  public var allowedChannelTypes : Set<InputOutput> {
    get {
      return []
    }
  }
  
  public var channelType : InputOutput {
    get {
      return _channelType
    }
    set(value) {
      _channelType = value
    }
  }
  
  public var ioChannelNumber : Int
  
  public var ioDevice : IODevice
  
  public var ioFunctions : [IOFunction] = []
  
  // MARK: Public Methods
  
  public func save() {

    for ioFunction in ioFunctions {
      ioFunction.save()
    }
    
  }
  
  public func propertySheet() {
    
  }
  
  public func writeChannel() {
    
  }
  
}
