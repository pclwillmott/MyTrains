//
//  QuerySlot5.swift
//  MyTrains
//
//  Created by Paul Willmott on 09/04/2022.
//

import Foundation

public class QuerySlot5 : NetworkMessage {
  
  // MARK: Constructors
  
  // MARK: Public Properties
  
  public var productCode : ProductCode {
    get {
      return ProductCode(rawValue: message[16]) ?? .none
    }
  }
  
  public var productName : String {
    get {
      return productCode.productName()
    }
  }
  
  public var serialNumber : Int {
    get {
      let sn = Int(message[19] & 0b00111111) << 7 | Int(message[18])
      if let device = networkController.deviceForQuerySlot(productCode: productCode, serialNumber: sn) {
        return device.serialNumber
      }
      return 0
    }
  }

  public var boardID : Int? {
    get {
      if productCode == .BXP88 {
        return Int(message[17]) + 1
      }
      return nil
    }
  }

  public var boardIDString : String {
    get {
      if let bid = boardID {
        return "\(bid)"
      }
      return "N/A"
    }
  }

  public var trackFaults : Int {
    get {
      return Int(message[4]) | Int(message[5]) << 7
    }
  }

  // THIS IS A GUESS
  public var autoReverseEvents : Int {
    get {
      return Int(message[6]) | Int(message[7]) << 7
    }
  }

  // THIS IS A GUESS
  public var disturbances : Int {
    get {
      return Int(message[8]) | Int(message[9]) << 7
    }
  }

  public var comboName : String {
    get {
      return "Digitrax \(productName) SN: \(serialNumber)"
    }
  }

}
