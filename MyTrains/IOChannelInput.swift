//
//  IOChannelInput.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/01/2023.
//

import Foundation

public class IOChannelInput : IOChannel {
 
  // MARK: Public Properties
  
  override public var allowedChannelTypes : Set<InputOutput> {
    get {
      return [.input]
    }
  }
  
  override public var channelType : InputOutput {
    get {
      return .input
    }
    set(value) {
      _ = value
      _channelType = channelType
    }
  }

}
