//
//  QuerySlot2.swift
//  MyTrains
//
//  Created by Paul Willmott on 09/04/2022.
//

import Foundation

public class QuerySlot2 : NetworkMessage {
  
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

  public var trackVoltage : Double {
    get {
      return Double(message[4]) * 2.0 / 10.0
    }
  }
  
  public var inputVoltage : Double {
    get {
      return Double(message[5]) * 2.0 / 10.0
    }
  }
  
  public var currentDrawn : Double {
    get {
      return Double(message[6]) / 10.0
    }
  }
  
  public var currentLimit : Double {
    get {
      return Double(message[7]) / 10.0
    }
  }
  
  public var railSyncVoltage : Double {
    get {
      return Double(message[10]) * 2.0 / 10.0
    }
  }
  
  public var locoNetVoltage : Double {
    get {
      return Double(message[12]) * 2.0 / 10.0
    }
  }
  
  public var comboName : String {
    get {
      return "Digitrax \(productName) SN: \(serialNumber)"
    }
  }

}
