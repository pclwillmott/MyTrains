//
//  NetworkMessage.swift
//  MyTrains
//
//  Created by Paul Willmott on 30/10/2021.
//

import Foundation

public class NetworkMessage : NSObject {
  
  // MARK: Constructors
  
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
  
  // MARK: Private Properties
  
  private var _messageType : NetworkMessageType = .uninitialized
  
  private var _willChangeSlot : Bool = false
  
  private var _slotID : Int = 0
  
  // MARK: Public Properties
  
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
  
  public var slotData : [UInt8] {
    
    if messageType == .locoSlotDataP1 || messageType == .locoSlotDataP2 {
    
      let count = Int(messageLength) - 3
    
      var slotData = [UInt8](repeating: 0, count: count)
      
      var index = 0
      while index < count {
        slotData[index] = message[index + 2]
        index += 1
      }
      
      return slotData

    }
    
    return []
    
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
  
  public var willChangeSlot : Bool {
    get {
      let _ = messageType
      return _willChangeSlot
    }
  }
  
  public var slotID : Int {
    get {
      let _ = messageType
      return _slotID
    }
  }
  
  public var messageType : NetworkMessageType {
    
    get {
      
      if _messageType == .uninitialized {

        _messageType = .unknown
        
        var slotPage : Int = 0
        
        var slotNumber : Int = 0
        
        var isP1 : Bool = false

        switch message[0] {
        case NetworkMessageOpcode.OPC_BUSY.rawValue:
          _messageType = .busy
          break
        case NetworkMessageOpcode.OPC_GPOFF.rawValue:
          _messageType = .pwrOff
          break
        case NetworkMessageOpcode.OPC_GPON.rawValue:
          _messageType = .pwrOn
          break
        case NetworkMessageOpcode.OPC_IDLE.rawValue:
          _messageType = .setIdleState
          break
        case NetworkMessageOpcode.OPC_LOCO_ADR.rawValue:
          _messageType = message[1] == 0x00 ? .getLocoSlotDataSAdrP1 : .getLocoSlotDataLAdrP1
          break
        case NetworkMessageOpcode.OPC_LOCO_ADR_P2.rawValue:
          _messageType = message[1] == 0x00 ? .getLocoSlotDataSAdrP2 : .getLocoSlotDataLAdrP2
          break
        case NetworkMessageOpcode.OPC_LONG_ACK.rawValue:
          if message[1] == 0x6f &&
             message[2] == 0x01 {
            _messageType = .progCmdAccepted
          }
          else if message[1] == 0x6f &&
             message[2] == 0x40 {
            _messageType = .progCmdAcceptedBlind
          }
          else if message[1] == 0x3b &&
             message[2] == 0x00 {
            _messageType = .slotNotImplemented
          }
          else if message[1] == 0x6e && message[2] == 0x7f {
            _messageType = .setSlotDataOKP2
          }
          else if message[1] == 0x6f && message[2] == 0x7f {
            _messageType = .setSlotDataOKP1
          }
          else if message[1] == 0x3f && message[2] == 0x00 {
            _messageType = .noFreeSlotsP1
          }
          else if message[1] == 0x3e && message[2] == 0x00 {
            _messageType = .noFreeSlotsP2
          }
          else if message[1] == 0x54 && message[2] == 0x00 {
            _messageType = .illegalMoveP2
          }
          else if message[1] == 0x3a && message[2] == 0x00 {
            _messageType = .illegalMoveP1
          }
          else if message[1] == 0x3c && message[2] == 0x30 {
            _messageType = .swStateClosed
          }
          else if message[1] == 0x3c && message[2] == 0x10 {
            _messageType = .swStateThrown
          }
          else {
            _messageType = .ack
          }
          break
        case NetworkMessageOpcode.OPC_SL_RD_DATA_P2.rawValue:
          if message[1] == 0x15 &&
              (message[2] & 0b11111000) == 0x00 &&
              (message[7] & 0b10110000) == 0x00 {
            if message[3] < 0x78 {
              _messageType = .locoSlotDataP2
            }
          }
        case NetworkMessageOpcode.OPC_SL_RD_DATA.rawValue:
          if   message[ 1] == 0x0e &&
              (message[ 7] &  0b00110000) == 0x00    /* TRK  */ {
            if (message[2] < 0x78) &&
              (message[ 6] &  0b11000000) == 0x00 && /* DIRF */
              (message[ 8] &  0b11110010) == 0x00 && /* SS@  */
              (message[10] &  0b11110000) == 0x00    /* SND  */ {
              _messageType = .locoSlotDataP1
            }
            else if message[2] == 0x7b {
              _messageType = .fastClockDataP1
            }
            else if message[2] == 0x7c {
              _messageType = .progSlotDataP1
            }
            else if message[2] == 0x7f {
              _messageType = .cfgSlotDataP1
            }
          }
          break
        case NetworkMessageOpcode.OPC_WR_SL_DATA_P2.rawValue:
          if message[1] == 0x15 {
            _messageType = .setLocoSlotDataP2
            _willChangeSlot = true
            isP1 = false
            slotPage = Int(message[2] & 0b00000111)
            slotNumber = Int(message[3])
          }
          break
        case NetworkMessageOpcode.OPC_WR_SL_DATA.rawValue:
          if  message[ 1] == 0x0e &&
              message[ 2] <  0x78 &&                /* SLOT */
             (message[ 6] &  0b11000000) == 0x00 && /* DIRF */
             (message[ 7] &  0b10110000) == 0x00 && /* TRK  */
             (message[ 8] &  0b11110010) == 0x00 && /* SS@  */
             (message[10] &  0b11110000) == 0x00    /* SND  */ {
            _messageType = .setLocoSlotDataP1
            _willChangeSlot = true
            isP1 = true
            slotPage = 0
            slotNumber = Int(message[2])
          }
          else if
              message[ 1] == 0x0e &&
              message[ 2] == 0x7c &&                /* PROG SLOT */
              message[ 4] == 0x00 &&
              message[ 7] == 0x00 &&
             (message[ 8] &  0b11001100) == 0x00 {
            _messageType = .progCV
          }

          break
        case NetworkMessageOpcode.OPC_CONSIST_FUNC.rawValue:
          if message[1] < 0x78 &&
              (message[2] & 0b01000000) == 0x00 {
            _messageType = .consistDirF0F4
            _willChangeSlot = true
            isP1 = true
            slotPage = 0
            slotNumber = Int(message[1])
          }
          break
        case NetworkMessageOpcode.OPC_BRD_OPSW.rawValue:
          let test = message[1] & 0b11111110
          if test == 0b01100010 {
            _messageType = .getBrdOpSw
          }
          else if test == 0b01110010 {
            _messageType = .setBrdOpSw
          }
          break
        case NetworkMessageOpcode.OPC_RQ_SL_DATA.rawValue:
          if message[2] == 0x00 {
            let sn = message[1]
            if sn == 0x7f {
              _messageType = .getCfgSlotDataP1
            }
            else if sn == 0x7b {
              _messageType = .getFastClockDataP1
            }
            else if sn < 0x78 {
              _messageType = .getLocoSlotDataP1
            }
          }
          else if message[1] < 0x78 &&
                    (message[2] & 0b11110000) == 0b01000000 {
            _messageType = .getLocoSlotDataP2
          }
          break
        case NetworkMessageOpcode.OPC_IMM_PACKET.rawValue:
          if message[1] == 0x0b &&
             message[2] == 0x7f &&
            (message[3] & 0b10001000) == 0x00 &&
            (message[4] & 0b11100000) == 0b00100000 {
              _messageType = .immPacket
          }
          break
        case NetworkMessageOpcode.OPC_PEER_XFER.rawValue:
          if message[ 1] == 0x10 &&
             message[ 2] == 0x22 &&
             message[ 3] == 0x22 &&
             message[ 4] == 0x01 &&
             message[ 5] == 0x00 &&
             message[10] == 0x00 {
            _messageType = .interfaceData
          }
          else if message[1] == 0x10 {
            if message[2] == 0x7f &&
               message[3] == 0x7f &&
               message[4] == 0x7f &&
              (message[5] & 0b11110000) == 0b01000000 {
              let subcode = message[10] & 0b11110000
              switch subcode {
              case 0b00000000:
                if message[12] == 0x00 &&
                   message[14] == 0x00 {
                  _messageType = .iplSetupBL2
                }
                break
              case 0b00010000:
                if message[11] == 0x00 &&
                   message[12] == 0x00 &&
                   message[13] == 0x00 &&
                   message[14] == 0x00 {
                  _messageType = .iplSetAddr
                }
              case 0b00100000:
                _messageType = .iplDataLoad
              case 0b01000000:
                if message[5] == 0x40 &&
                   message[6] == 0x00 &&
                   message[7] == 0x00 &&
                   message[8] == 0x00 &&
                   message[9] == 0x00 &&
                   message[10] == 0x40 &&
                   message[11] == 0x00 &&
                   message[12] == 0x00 &&
                   message[13] == 0x00 &&
                   message[14] == 0x00 {
                  _messageType = .iplEndLoad
                }
              default:
                break
              }
            }
            else {
              _messageType = .peerXfer16
            }
          }
          else if message[1] == 0x14 {
            if message[2] == 0x0f &&
                message[3] == 0x08 &&
                message[4] == 0x00 &&
                message[5] == 0x00 &&
                message[6] == 0x00 &&
                message[7] == 0x00 &&
                message[8] == 0x00 &&
                message[9] == 0x00 &&
                message[10] == 0x00 &&
                message[11] == 0x01 &&
                message[12] == 0x00 &&
                message[13] == 0x00 &&
                message[14] == 0x00 &&
                message[15] == 0x00 &&
                message[16] == 0x00 &&
                message[17] == 0x00 &&
                message[18] == 0x00 {
              _messageType = .iplDiscover
            }
            else if message[2] == 0x0f &&
                message[3] == 0x10 &&
                (message[ 4] & 0b11110000) == 0x00 &&
                (message[ 9] & 0b11110000) == 0x00 &&
                (message[14] & 0b11110000) == 0x00 {
              _messageType = .iplDevData
            }
          }
          break
        case NetworkMessageOpcode.OPC_LINK_SLOTS.rawValue:
          if message[1] > 0 && message[1] < 0x78 &&
              message[2] > 0 && message[2] < 0x78 {
            _messageType = .linkSlotsP1
            _willChangeSlot = true
            isP1 = true
            slotPage = 0
            slotNumber = Int(message[2])
         }
          break
        case NetworkMessageOpcode.OPC_D4_GROUP.rawValue:
          if      (message[1] & 0b11100000) == 0b00000000 {
            _messageType = .locoBinStateP2
            _willChangeSlot = true
            isP1 = false
            slotPage = Int(message[1] & 0b00000111)
            slotNumber = Int(message[2])
          }
          else if (message[1] & 0b11111000) == 0b00100000 {
            switch message[3] {
            case 0x04:
              _messageType = .locoSpdP2
              _willChangeSlot = true
              isP1 = false
              slotPage = Int(message[1] & 0b00000111)
              slotNumber = Int(message[2])
              break
            case 0x05:
              if (message[4] & 0b11111000) == 0x00 {
                _messageType = .locoF12F20F28P2
                _willChangeSlot = true
                isP1 = false
                slotPage = Int(message[1] & 0b00000111)
                slotNumber = Int(message[2])
              }
              break
            case 0x06:
              if (message[4] & 0b11000000) == 0x00 {
                _messageType = .locoDirF0F4P2
                _willChangeSlot = true
                isP1 = false
                slotPage = Int(message[1] & 0b00000111)
                slotNumber = Int(message[2])
              }
              break
            case 0x07:
              _messageType = .locoF5F11P2
              _willChangeSlot = true
              isP1 = false
              slotPage = Int(message[1] & 0b00000111)
              slotNumber = Int(message[2])
              break
            case 0x08:
              _messageType = .locoF13F19P2
              _willChangeSlot = true
              isP1 = false
              slotPage = Int(message[1] & 0b00000111)
              slotNumber = Int(message[2])
              break
            case 0x09:
              _messageType = .locoF21F27P2
              _willChangeSlot = true
              isP1 = false
              slotPage = Int(message[1] & 0b00000111)
              slotNumber = Int(message[2])
              break
            default:
              break
            }
          }
          else if (message[1] & 0b11111000) == 0b00111000 {
            let test = message[3] & 0b11111000
            switch test {
            case 0b00000000:
              _messageType = .moveSlotsP2
              _willChangeSlot = true
              isP1 = false
              slotPage = Int(message[1] & 0b00000111)
              slotNumber = Int(message[2])
              break
            case 0b01000000:
              _messageType = .linkSlotsP2
              _willChangeSlot = true
              isP1 = false
              slotPage = Int(message[1] & 0b00000111)
              slotNumber = Int(message[2])
              break
            case 0b01010000:
              _messageType = .unlinkSlotsP2
              _willChangeSlot = true
              isP1 = false
              slotPage = Int(message[1] & 0b00000111)
              slotNumber = Int(message[2])
              break
            default:
              break
            }
          }
          break
        case NetworkMessageOpcode.OPC_D5_GROUP.rawValue:
          let test = message[1] & 0b11111000
          switch test {
          case 0b00000000, 0b00001000:
            _messageType = .locoSpdDirP2
            _willChangeSlot = true
            isP1 = false
            slotPage = Int(message[1] & 0b00000111)
            slotNumber = Int(message[2])
          case 0b00010000:
            _messageType = .locoF0F6P2
            _willChangeSlot = true
           isP1 = false
            slotPage = Int(message[1] & 0b00000111)
            slotNumber = Int(message[2])
            break
          case 0b00011000:
            _messageType = .locoF7F13P2
            _willChangeSlot = true
            isP1 = false
            slotPage = Int(message[1] & 0b00000111)
            slotNumber = Int(message[2])
          case 0b00100000:
            _messageType = .locoF14F20P2
            _willChangeSlot = true
            isP1 = false
            slotPage = Int(message[1] & 0b00000111)
            slotNumber = Int(message[2])
          case 0b00101000:
            _messageType = .locoF21F28P2
            _willChangeSlot = true
            isP1 = false
            slotPage = Int(message[1] & 0b00000111)
            slotNumber = Int(message[2])
          case 0b00110000:
            _messageType = .locoF21F28P2
            _willChangeSlot = true
            isP1 = false
            slotPage = Int(message[1] & 0b00000111)
            slotNumber = Int(message[2])
          default:
            break
          }
        case NetworkMessageOpcode.OPC_LOCO_DIRF.rawValue:
          if message[1] < 0x78 &&
            (message[2] & 0b01000000) == 0x00 {
            _messageType = .locoDirF0F4P1
            _willChangeSlot = true
            isP1 = true
            slotPage = 0
            slotNumber = Int(message[1])
          }
        case NetworkMessageOpcode.OPC_LOCO_SND.rawValue:
          if message[1] < 0x78 &&
              (message[2] & 0b11110000) == 0x00 {
            _messageType = .locoF5F8P1
            _willChangeSlot = true
            isP1 = true
            slotPage = 0
            slotNumber = Int(message[1])
          }
          break
        case NetworkMessageOpcode.OPC_LOCO_SPD.rawValue:
          if message[1] < 0x78 {
            _messageType = .locoSpdP1
            _willChangeSlot = true
            isP1 = true
            slotPage = 0
            slotNumber = Int(message[1])
          }
          break
        case NetworkMessageOpcode.OPC_MOVE_SLOTS.rawValue:
          if message[1] < 0x78 &&
              message[2] < 0x78 {
            _messageType = .moveSlotsP1
            _willChangeSlot = true
            isP1 = true
            slotPage = 0
            slotNumber = Int(message[1])
          }
          break
        case NetworkMessageOpcode.OPC_LOCO_RESET.rawValue:
          _messageType = .reset
          break
        case NetworkMessageOpcode.OPC_INPUT_REP.rawValue:
          if (message[2] & 0b11000000) == 0b01000000 {
            _messageType = .sensRepGenIn
          }
          break
        case NetworkMessageOpcode.OPC_SW_REP.rawValue:
          let test = message[2] & 0b11000000
          if test == 0b01000000 {
            _messageType = .sensRepTurnIn
          }
          else if test == 0b00000000 {
            _messageType = .sensRepTurnOut
          }
          break
        case NetworkMessageOpcode.OPC_SLOT_STAT1.rawValue:
          if message[1] < 0x78 {
            _messageType = .setLocoSlotStat1
            _willChangeSlot = true
            isP1 = true
            slotPage = 0
            slotNumber = Int(message[1])
          }
        case NetworkMessageOpcode.OPC_SW_ACK.rawValue:
          if (message[2] & 0b11000000) == 0b00000000 {
            _messageType = .setSwWithAck
          }
          break
        case NetworkMessageOpcode.OPC_SW_REQ.rawValue:
          if (message[2] & 0b11000000) == 0b00000000 {
            _messageType = .swReq
          }
          break
        case NetworkMessageOpcode.OPC_SW_STATE.rawValue:
          if (message[2] & 0b11000000) == 0b00000000 {
            _messageType = .swState
          }
          break
        case NetworkMessageOpcode.OPC_UNLINK_SLOTS.rawValue:
          if message[1] < 0x78 && message[2] < 0x78 {
            _messageType = .unlinkSlotsP1
            _willChangeSlot = true
            isP1 = true
            slotPage = 0
            slotNumber = Int(message[1])
          }
          break
        default:
          break
        }
        
        if _willChangeSlot {
          if isP1 {
            _slotID = LocoSlotData.getID(slotNumber: slotNumber)
          }
          else {
            _slotID = LocoSlotData.getID(slotPage: slotPage, slotNumber: slotNumber)
          }
        }
        
      }
      
      return _messageType
      
    }
    
    set(value) {
      _messageType = value
    }
    
  }

  // MARK: Public Methods
  
  public static func checkSum(data: Data, length: Int) -> UInt8 {
    var cs : UInt8 = 0xff
    var index : Int = 0
    while (index < length) {
      cs ^= data[index]
      index += 1
    }
    return cs
  }
  
}
