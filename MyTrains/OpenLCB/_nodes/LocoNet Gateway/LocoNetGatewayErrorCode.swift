//
//  LocoNetGatewayErrorCode.swift
//  MyTrains
//
//  Created by Paul Willmott on 12/06/2024.
//

import Foundation

public enum LocoNetGatewayErrorCode : Int {
  
  // MARK: Enumeration
  
  case success = 0
  case noSerialPortConnection = 1
  case maximumRetriesExceeded = 2
  case serialPortRemoved = 3

}
