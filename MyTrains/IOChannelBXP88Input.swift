//
//  IOChannelBXP88Input.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/01/2023.
//

import Foundation

public class IOChannelBXP88Input : IOChannelInput {
 
  // MARK: Public Properties
  
  override public var canWriteChannel: Bool {
    get {
      return true
    }
  }
  
  // MARK: Public Properties
  
  override public func writeChannel() {
    (ioDevice as! IODeviceBXP88).writeOptionSwitches()
    
  }
  
}
