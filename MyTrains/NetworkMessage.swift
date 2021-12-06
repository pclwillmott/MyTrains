//
//  NetworkMessage.swift
//  MyTrains
//
//  Created by Paul Willmott on 30/10/2021.
//

import Foundation

public class NetworkMessage {
  
  init(interfaceId: String, data:[UInt8], appendCheckSum: Bool) {
    self.interfaceId = interfaceId
    self.message = data
    if appendCheckSum {
      self.message.append(NetworkMessage.checkSum(data: Data(message), length: data.count))
    }
  }

  init(interfaceId: String, data:[Int], appendCheckSum: Bool) {
    self.interfaceId = interfaceId
    self.message = []
    for x in data {
      self.message.append(UInt8(x & 0xff))
    }
    if appendCheckSum {
      self.message.append(NetworkMessage.checkSum(data: Data(message), length: data.count))
    }
  }

  init(interfaceId: String, data:[UInt8]) {
    self.interfaceId = interfaceId
    self.message = data
  }

  public var message : [UInt8]
  
  public var interfaceId : String
  
  public var checkSumOK : Bool {
    get {
      var checkSum = message[0]
      var index = 1
      while index < message.count {
        checkSum ^= message[index]
        index += 1
      }
      return checkSum == 0xff
    }
  }
  
  public static func checkSum(data: Data, length: Int) -> UInt8 {
    var cs : UInt8 = 0xff
    var index : Int = 0
    while (index < length) {
      cs ^= data[index]
      index += 1
    }
    return cs
  }
  
  public var opCodeRawValue : UInt8 {
    get {
      return message[0]
    }
  }
  
  public var opCode : NetworkMessageOpcode {
    get {
      return NetworkMessageOpcode.init(rawValue: opCodeRawValue) ?? .OPC_UNKNOWN
    }
  }
  
  public var messageLength : UInt8 {
    get {
      
      var length = (message[0] & 0b01100000) >> 5
      
      switch length {
      case 0b00 :
        length = 2
        break
      case 0b01 :
        length = 4
        break
      case 0b10 :
        length = 6
        break
      default :
        length = message[1]
        break
      }
      
      return length
    }
  }
  
  public var messageHex : String {
    get {
      var str : String = ""
      for x in message {
        str += String(format: "%02X ",x)
      }
      return str.trimmingCharacters(in: [" "])
    }
  }
  
  private var _messageType : NetworkMessageType = .uninitialized
  
  public var messageType : NetworkMessageType {
    
    get {
      
      if _messageType == .uninitialized {

        _messageType = .unknown

        switch message[0] {
        case NetworkMessageOpcode.OPC_BUSY.rawValue:
          _messageType = .busy
          break
        case NetworkMessageOpcode.OPC_GPOFF.rawValue:
          _messageType = .globalPowerOff
          break
        case NetworkMessageOpcode.OPC_GPON.rawValue:
          _messageType = .globalPowerOn
          break
        case NetworkMessageOpcode.OPC_IDLE.rawValue:
          _messageType = .forceIdleState
          break
        case NetworkMessageOpcode.OPC_LOCO_ADR.rawValue:
          _messageType = message[1] == 0x00 ? .getLocoSlotDataSAdrV1 : .getLocoSlotDataLAdrV1
          break
        case NetworkMessageOpcode.OPC_LOCO_ADR_V2.rawValue:
          _messageType = message[1] == 0x00 ? .getLocoSlotDataSAdrV2 : .getLocoSlotDataLAdrV2
          break
        case NetworkMessageOpcode.OPC_LONG_ACK.rawValue:
          _messageType = .acknowledgement
          break
        case NetworkMessageOpcode.OPC_SL_RD_DATA.rawValue:
          if  message[ 1] == 0x0e &&
             (message[ 6] &  0b01000000) == 0x00 && /* DIRF */
             (message[ 7] &  0b00110000) == 0x00 && /* TRK  */
             (message[ 8] &  0b01110010) == 0x00 && /* SS@  */
             (message[10] &  0b01110000) == 0x00    /* SND  */ {
            if message[2] < 0x78 {
              _messageType = .locoSlotDataV1
            }
            else if message[2] == 0x7f {
              _messageType = .cfgSlotDataV1
            }
          }
          break
        case NetworkMessageOpcode.OPC_WR_SL_DATA.rawValue:
          if  message[ 1] == 0x0e &&
              message[ 2] <  0x78 &&                /* SLOT */
             (message[ 6] &  0b01000000) == 0x00 && /* DIRF */
             (message[ 7] &  0b00110000) == 0x00 && /* TRK  */
             (message[ 8] &  0b01110010) == 0x00 && /* SS@  */
             (message[10] &  0b01110000) == 0x00    /* SND  */ {
            _messageType = .writeLocoSlotDataV1
          }
          break
        case NetworkMessageOpcode.OPC_PEER_XFER.rawValue:
          if message[ 1] == 0x10 &&
             message[ 2] == 0x22 &&
             message[ 3] == 0x22 &&
             message[ 4] == 0x01 &&
             message[ 5] == 0x00 &&
             message[10] == 0x00 {
            _messageType = .getInterfaceData
          }
          break
        default:
          break
        }
        
      }
      
      return _messageType
      
    }
    
    set(value) {
      _messageType = value
    }
    
  }
    
}
