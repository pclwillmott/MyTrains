//
//  QuerySlot4.swift
//  MyTrains
//
//  Created by Paul Willmott on 09/04/2022.
//

import Foundation

public class QuerySlot4 : NetworkMessage {
  
  // MARK: Constructors
  
  // MARK: Public Properties
  
  public var productCode : ProductCode {
    get {
      return ProductCode(rawValue: Int(message[16])) ?? .unknown
    }
  }
  
  public var productName : String {
    get {
      return productCode.productName()
    }
  }
  
  public var serialNumber : Int {
    get {
      return Int(message[19] & 0b00111111) << 7 | Int(message[18])
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

  public var goodLocoNetMessages : Int {
    get {
      return Int(message[4]) | Int(message[5] & 0b00111111) << 7
    }
  }

  public var badLocoNetMessages : Int {
    get {
      return Int(message[6]) | Int(message[7] & 0b00111111) << 7
    }
  }

  // THIS IS A GUESS
  public var numberOfSleeps : Int {
    get {
      return Int(message[8]) | Int(message[9] & 0b00111111) << 7
    }
  }

  public var comboName : String {
    get {
      return "Digitrax \(productName) SN: \(serialNumber)"
    }
  }

}
