//
//  LocoSlotData.swift
//  MyTrains
//
//  Created by Paul Willmott on 22/01/2022.
//

import Foundation

public class LocoSlotData {
  
  // MARK: Constructors
  
  init?(message: LocoNetMessage) {
    
    guard message.messageType == .locoSlotDataP1 || message.messageType == .locoSlotDataP2 else {
      return nil
    }
    
    slotBank = message.slotBank ?? 0x00
    
    slotNumber = message.slotNumber!
    
    slotID = LocoSlotData.encodeID(slotBank: slotBank, slotNumber: slotNumber)
    
    address = message.locomotiveAddress!
    
    slotState = message.slotState!
    
    consistState = message.consistState!
    
    mobileDecoderType = message.mobileDecoderType!
    
    rawMobileDecodeType = message.rawMobileDecoderType!
    
    direction = message.direction!
    
    speed = message.speed!
    
    throttleID = message.throttleID!
    
    functions = message.functions!
    
    isF9F28Available = message.isF9F28Available!
    
  }
  
  init(slotID: Int) {
    
    self.slotID = slotID
    
    let decoded = LocoSlotData.decodeID(slotID: slotID)
    
    slotBank = decoded.bank
    
    slotNumber = decoded.number
    
    address = 0
    
    slotState = .free
    
    consistState = .NotLinked
    
    mobileDecoderType = SpeedSteps.defaultValue
    
    rawMobileDecodeType = 0
    
    direction = .forward
    
    speed = 0
    
    throttleID = 0
    
    functions = 0
    
    isF9F28Available = false
    
    isDirty = true

  }
  
  // MARK: Private Properties
  
  // MARK: Public Properties
  
  public var slotID : Int
  
  public var slotBank : UInt8
  
  public var slotNumber : UInt8
  
  public var address : UInt16
  
  public var slotState : LocoNetSlotState
  
  public var consistState : ConsistState
  
  public var mobileDecoderType : SpeedSteps
  
  public var rawMobileDecodeType : UInt8
  
  public var direction : LocomotiveDirection
  
  public var speed : Int
  
  public var speedForDisplay : String {
    get {
      switch speed {
      case 0:
        return "0"
      case 1:
        return "ES"
      default:
        return "\(speed-1)"
      }
    }
  }
  
  public var throttleID : UInt16
  
  public var functions : UInt64
  
  public var isF9F28Available : Bool
  
  public var displaySlotNumber : String {
    get {
      let bank = UnicodeScalar(65+slotBank)
      return "\(bank).\(slotNumber)"
    }
  }
  
  public var locomotiveName : String {
    get {
      /*
      for locomotive in myTrainsController.locomotives {
        if address == locomotive.value.mDecoderAddress {
          return locomotive.value.rollingStockName
        }
      }
       */
      return "Unknown"
    }
  }
  
  public var isDirty : Bool = false
  
  public var slotStatus1 : UInt8 {
    get {
      var stat1 : UInt8 = 0x00
      
      stat1 |= consistState.stat1Mask
      
      stat1 |= UInt8(slotState.rawValue << 4)
      
      stat1 |= UInt8(mobileDecoderType.rawValue)
      
      return stat1
    }
    set(stat1) {
      
      mobileDecoderType = SpeedSteps(rawValue: stat1 & 0x7) ?? SpeedSteps.defaultValue
      
      slotState = LocoNetSlotState(rawValue: stat1 & ~LocoNetSlotState.protectMask)!

      var temp : Int = 0x00
      
      temp |= (((stat1 & 0b00001000) == 0b00001000) ? 0b10 : 0)
      temp |= (((stat1 & 0b01000000) == 0b01000000) ? 0b01 : 0)

      consistState = ConsistState(rawValue: temp) ?? .NotLinked
      
    }
  }
  
  public var slotDataP2 : [UInt8] {
    get {
      
      var slot : [UInt8] = [UInt8](repeating: 0x00, count: 20)
      
      slot[0] = LocoNetMessageOpcode.OPC_SL_RD_DATA_P2.rawValue
      slot[1] = 0x15
      slot[2] = slotBank
      slot[3] = slotNumber
      slot[4] = slotStatus1 & 0x7f
      slot[5] = UInt8(address & 0x7f)
      slot[6] = UInt8(address >> 7)
      slot[7] = 0x00
      slot[8] = UInt8(speed)
      
      let fnx = functions
      
      var temp : UInt8 = 0x00
      
      temp |= (((fnx & maskF28) == maskF28) ? 0b01000000 : 0)
      temp |= (((fnx & maskF20) == maskF20) ? 0b00100000 : 0)
      temp |= (((fnx & maskF12) == maskF12) ? 0b00010000 : 0)

      slot[9] = temp
      
      temp = 0x00
      
      temp |= ((direction == .forward)    ? 0b00100000 : 0)
      temp |= (((fnx & maskF0) == maskF0) ? 0b00010000 : 0)
      temp |= (((fnx & maskF4) == maskF4) ? 0b00001000 : 0)
      temp |= (((fnx & maskF3) == maskF3) ? 0b00000100 : 0)
      temp |= (((fnx & maskF2) == maskF2) ? 0b00000010 : 0)
      temp |= (((fnx & maskF1) == maskF1) ? 0b00000001 : 0)

      slot[10] = temp

      temp = 0x00
      
      temp |= (((fnx & maskF11) == maskF11) ? 0b01000000 : 0)
      temp |= (((fnx & maskF10) == maskF10) ? 0b00100000 : 0)
      temp |= (((fnx & maskF9 ) == maskF9 ) ? 0b00010000 : 0)
      temp |= (((fnx & maskF8 ) == maskF8 ) ? 0b00001000 : 0)
      temp |= (((fnx & maskF7 ) == maskF7 ) ? 0b00000100 : 0)
      temp |= (((fnx & maskF6 ) == maskF6 ) ? 0b00000010 : 0)
      temp |= (((fnx & maskF5 ) == maskF5 ) ? 0b00000001 : 0)

      slot[11] = temp
      
      temp = 0x00
      
      temp |= (((fnx & maskF19) == maskF19) ? 0b01000000 : 0)
      temp |= (((fnx & maskF18) == maskF18) ? 0b00100000 : 0)
      temp |= (((fnx & maskF17) == maskF17) ? 0b00010000 : 0)
      temp |= (((fnx & maskF16) == maskF16) ? 0b00001000 : 0)
      temp |= (((fnx & maskF15) == maskF15) ? 0b00000100 : 0)
      temp |= (((fnx & maskF14) == maskF14) ? 0b00000010 : 0)
      temp |= (((fnx & maskF13) == maskF13) ? 0b00000001 : 0)

      slot[12] = temp
      
      temp = 0x00
      
      temp |= (((fnx & maskF27) == maskF27) ? 0b01000000 : 0)
      temp |= (((fnx & maskF26) == maskF26) ? 0b00100000 : 0)
      temp |= (((fnx & maskF25) == maskF25) ? 0b00010000 : 0)
      temp |= (((fnx & maskF24) == maskF24) ? 0b00001000 : 0)
      temp |= (((fnx & maskF23) == maskF23) ? 0b00000100 : 0)
      temp |= (((fnx & maskF22) == maskF22) ? 0b00000010 : 0)
      temp |= (((fnx & maskF21) == maskF21) ? 0b00000001 : 0)

      slot[13] = temp
      
      slot[18] = UInt8(throttleID & 0x7f)
      slot[19] = UInt8(throttleID >> 8) & 0x7f

      return slot
    }
    set(data) {
      
      slotBank = data[2]
      
      slotNumber = data[3]
      
      slotID = LocoSlotData.encodeID(slotBank: 0, slotNumber: slotNumber)

      slotStatus1 = data[4]
      
      address = UInt16(data[5]) | (UInt16(data[6]) << 7)
      
      speed = Int(data[8])
      
      var fnx : UInt64 = 0
      
      var byte = data[9]

      fnx |= (byte & 0b00010000) == 0b00010000 ? maskF12 : 0
      fnx |= (byte & 0b00100000) == 0b00100000 ? maskF20 : 0
      fnx |= (byte & 0b01000000) == 0b01000000 ? maskF28 : 0

      byte = data[10]

      fnx |= (byte & 0b00010000) == 0b00010000 ? maskF0 : 0
      fnx |= (byte & 0b00000001) == 0b00000001 ? maskF1 : 0
      fnx |= (byte & 0b00000010) == 0b00000010 ? maskF2 : 0
      fnx |= (byte & 0b00000100) == 0b00000100 ? maskF3 : 0
      fnx |= (byte & 0b00001000) == 0b00001000 ? maskF4 : 0

      byte = data[11]

      fnx |= (byte & 0b00000001) == 0b00000001 ? maskF5 : 0
      fnx |= (byte & 0b00000010) == 0b00000010 ? maskF6 : 0
      fnx |= (byte & 0b00000100) == 0b00000100 ? maskF7 : 0
      fnx |= (byte & 0b00001000) == 0b00001000 ? maskF8 : 0
      fnx |= (byte & 0b00010000) == 0b00010000 ? maskF9 : 0
      fnx |= (byte & 0b00100000) == 0b00100000 ? maskF10 : 0
      fnx |= (byte & 0b01000000) == 0b01000000 ? maskF11 : 0

      byte = data[12]

      fnx |= (byte & 0b01000000) == 0b01000000 ? maskF19 : 0
      fnx |= (byte & 0b00100000) == 0b00100000 ? maskF18 : 0
      fnx |= (byte & 0b00010000) == 0b00010000 ? maskF17 : 0
      fnx |= (byte & 0b00001000) == 0b00001000 ? maskF16 : 0
      fnx |= (byte & 0b00000100) == 0b00000100 ? maskF15 : 0
      fnx |= (byte & 0b00000010) == 0b00000010 ? maskF14 : 0
      fnx |= (byte & 0b00000001) == 0b00000001 ? maskF13 : 0

      byte = data[13]
 
      fnx |= (byte & 0b01000000) == 0b01000000 ? maskF27 : 0
      fnx |= (byte & 0b00100000) == 0b00100000 ? maskF26 : 0
      fnx |= (byte & 0b00010000) == 0b00010000 ? maskF25 : 0
      fnx |= (byte & 0b00001000) == 0b00001000 ? maskF24 : 0
      fnx |= (byte & 0b00000100) == 0b00000100 ? maskF23 : 0
      fnx |= (byte & 0b00000010) == 0b00000010 ? maskF22 : 0
      fnx |= (byte & 0b00000001) == 0b00000001 ? maskF21 : 0

      functions = fnx
      
      throttleID = UInt16(data[18]) | UInt16(data[19]) << 8
      
    }
  }

  // MARK: Public Methods
  
  public func displayFunctionState(functionNumber: Int) -> String {
    
    if functionNumber < 0 || functionNumber > 28 {
      return "err"
    }
    
    if functionNumber > 8 && !isF9F28Available {
      return "?"
    }
    
    let mask : UInt64 = 1 << functionNumber
    
    return (functions & mask) == mask ? "on" : "off"
    
  }
  
  
  // MARK: Class Methods
  
  public static func encodeID(slotBank: UInt8, slotNumber: UInt8) -> Int {
    return Int(slotBank & 0b00000111) << 8 | Int(slotNumber)
  }
  
  public static func decodeID(slotID: Int) -> (bank: UInt8, number: UInt8) {
    let bank = UInt8(slotID >> 8)
    let number = UInt8(slotID & 0xff)
    return (bank: bank, number: number)
  }
  
}
