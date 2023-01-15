//
//  IOChannelDS64Output.swift
//  MyTrains
//
//  Created by Paul Willmott on 15/01/2023.
//

import Foundation

public class IOChannelDS64Output : IOChannelOutput {
 
  // MARK: Public Properties
  
  override public var canWriteChannel: Bool {
    get {
      return true
    }
  }
  
  // MARK: Public Properties
  
  override public func writeChannel() {
    
    (ioDevice as! IODeviceDS64).setSwitchAddresses()
    
  }
  
}
