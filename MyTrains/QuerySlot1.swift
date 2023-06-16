//
//  QuerySlot1.swift
//  MyTrains
//
//  Created by Paul Willmott on 09/04/2022.
//

import Foundation

public class QuerySlot1 : LocoNetMessage {
  
  // MARK: Constructors
  
  // MARK: Public Properties
  
  public var bit40 : Bool {
    get {
      return message[4] & 0b00000001 == 0b00000001
    }
  }

  public var bit41 : Bool {
    get {
      return message[4] & 0b00000010 == 0b00000010
    }
  }

  public var bit42 : Bool {
    get {
      return message[4] & 0b00000100 == 0b00000100
    }
  }

  public var bit43 : Bool {
    get {
      return message[4] & 0b00001000 == 0b00001000
    }
  }

  public var bit44 : Bool {
    get {
      return message[4] & 0b00010000 == 0b00010000
    }
  }

  public var bit45 : Bool {
    get {
      return message[4] & 0b00100000 == 0b00100000
    }
  }

  public var bit46 : Bool {
    get {
      return message[4] & 0b01000000 == 0b01000000
    }
  }

  public var bit50 : Bool {
    get {
      return message[5] & 0b00000001 == 0b00000001
    }
  }

  public var bit51 : Bool {
    get {
      return message[5] & 0b00000010 == 0b00000010
    }
  }

  public var bit52 : Bool {
    get {
      return message[5] & 0b00000100 == 0b00000100
    }
  }

  public var bit53 : Bool {
    get {
      return message[5] & 0b00001000 == 0b00001000
    }
  }

  public var bit54 : Bool {
    get {
      return message[5] & 0b00010000 == 0b00010000
    }
  }

  public var bit55 : Bool {
    get {
      return message[5] & 0b00100000 == 0b00100000
    }
  }

  public var bit56 : Bool {
    get {
      return message[5] & 0b01000000 == 0b01000000
    }
  }
  
  public var productCode : ProductCode {
    get {
      return ProductCode(rawValue: message[14]) ?? .none
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
      if let device = myTrainsController.deviceForQuerySlot(productCode: productCode, serialNumber: sn) {
        return device.serialNumber
      }
      return 0
    }
  }
  
  public var hardwareVersion : Double? {
    get {
      if productCode == .DCS240 || productCode == .DCS210 || productCode == .DCS210Plus || productCode == .PR4 || productCode == .DCS240Plus{
        return Double(message[17] & 0x78) / 8.0 + Double(message[17] & 0x07) / 10.0
      }
      return nil
    }
  }
  
  public var hardwareVersionString : String {
    get {
      if let hw = hardwareVersion {
        return "\(hw)"
      }
      return "Unknown"
    }
  }

  public var boardID : Int? {
    get {
      if productCode == .BXP88 {
        return Int(message[17])
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

  public var softwareVersion : Double {
    get {
      return Double(message[16] & 0x78) / 8.0 + Double(message[16] & 0x07) / 10.0
    }
  }
  
  public var comboName : String {
    get {
      return "Digitrax \(productName) SN: \(serialNumber)"
    }
  }

}
