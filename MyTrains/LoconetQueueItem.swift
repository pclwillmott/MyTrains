//
//  LoconetQueueItem.swift
//  MyTrains
//
//  Created by Paul Willmott on 07/11/2021.
//

import Foundation

public class LoconetOutputQueueItem {
  
  init(message:Data) {
    self.message = message
  }
  
  public var message:Data
  
}
