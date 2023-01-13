//
//  IOChannelOutput.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/01/2023.
//

import Foundation

public class IOChannelOutput : IOChannel {
 
  // MARK: Public Properties
  
  override public var allowedChannelTypes : Set<InputOutput> {
    get {
      return [.output]
    }
  }
  
  override public var channelType : InputOutput {
    get {
      return .output
    }
    set(value) {
      _ = value
      _channelType = channelType
    }
  }

}
