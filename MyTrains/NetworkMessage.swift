//
//  NetworkMessage.swift
//  MyTrains
//
//  Created by Paul Willmott on 30/10/2021.
//

import Foundation

public class NetworkMessage : NSObject {
  
  // MARK: Constructors
  
  init(networkId: Int, data:[UInt8], appendCheckSum: Bool) {
    self.networkId = networkId
    self.message = data
    if appendCheckSum {
      self.message.append(NetworkMessage.checkSum(data: Data(message), length: data.count))
    }
    super.init()
  }

  init(networkId: Int, data:[Int], appendCheckSum: Bool) {
    self.networkId = networkId
    self.message = []
    for x in data {
      self.message.append(UInt8(x & 0xff))
    }
    if appendCheckSum {
      self.message.append(NetworkMessage.checkSum(data: Data(message), length: data.count))
    }
    super.init()
  }

  init(networkId: Int, data:[UInt8]) {
    self.networkId = networkId
    self.message = data
    super.init()
  }
  
  init(message: NetworkMessage) {
    self.networkId = message.networkId
    self.message = message.message
    super.init()
  }
  
  init(networkId: Int, timeoutCode: TimeoutCode) {
    self.networkId = networkId
    self.message = [0x7f, timeoutCode.rawValue]
    self._messageType = .timeout
    super.init()
  }
  
  // MARK: Private Properties
  
  private var _messageType : NetworkMessageType = .uninitialized
  
  private var _slotsChanged : Set<Int> = []
  
  // MARK: Public Properties
  
  public var message : [UInt8]
  
  public var networkId : Int
  
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
  
  public var timeStamp : TimeInterval = 0.0
  
  public var timeSinceLastMessage : TimeInterval = 0.0
  
  public var timeoutCode : UInt8 {
    get {
      return message.count == 2 && message[0] == 0x7f ? message[1] : 0x00
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
  
  public var slotsChanged : Set<Int> {
    get {
      let _ = messageType
      return _slotsChanged
    }
  }
  
  public var messageType : NetworkMessageType {
    
    get {
      
      if _messageType == .uninitialized {

        _messageType = .unknown
        
        switch message[0] {
        
        // MARK: 0x81
          
        case 0x81: // OPC_BUSY
          
          _messageType = .busy
        
        // MARK: 0x82
          
        case 0x82: // OPC_GPOFF
          
          _messageType = .pwrOff
        
        // MARK: 0x83
          
        case 0x83: // OPC_GPON
          
          _messageType = .pwrOn
          
        // MARK: 0x85
          
        case 0x85: // OPC_IDLE
          
          _messageType = .setIdleState
 
        // MARK: 0x8A
          
        case 0x8a:
          
          _messageType = .reset

        // MARK: 0xA0
          
        case 0xa0: // OPC_LOCO_SPD
          
          if message[1] > 0 && message[1] < 0x78 {
            _messageType = .locoSpdP1
            _slotsChanged.insert(LocoSlotData.encodeID(slotPage: 0, slotNumber: message[1]))
          }

        // MARK: 0xA1
          
        case 0xa1: // OPC_LOCO_DIRF
          
          if message[1] > 0 && message[1] < 0x78 && (message[2] & 0b01000000) == 0x00 {
            _messageType = .locoDirF0F4P1
            _slotsChanged.insert(LocoSlotData.encodeID(slotPage: 0, slotNumber: message[1]))
          }
          
        // MARK: 0xA2
          
        case 0xa2: // OPC_LOCO_SND
          
          if message[1] > 0 && message[1] < 0x78 &&
            (message[2] & 0b11110000) == 0x00 {
            _messageType = .locoF5F8P1
            _slotsChanged.insert(LocoSlotData.encodeID(slotPage: 0, slotNumber: message[1]))
          }

        // MARK: 0xB0
          
        case 0xb0: // OPC_SW_REQ
          
          if (message[1] & 0b01111000) == 0b01111000 && (message[2] & 0b11011111) == 0b00000111 {
            _messageType = .interrogate
          }
          else if (message[2] & 0b11000000) == 0b00000000 {
            _messageType = .setSw
          }

        // MARK: 0xB1
          
        case 0xb1: // OPC_SW_REP
          
          let test = message[2] & 0b11000000
          if test == 0b01000000 {
            _messageType = .sensRepTurnIn
          }
          else if test == 0b00000000 {
            _messageType = .sensRepTurnOut
          }

        // MARK: 0xB2
          
        case 0xb2: // OPC_INPUT_REP
          
          if (message[2] & 0b11000000) == 0b01000000 {
            _messageType = .sensRepGenIn
          }
          
        // MARK: 0xB4
          
        case 0xb4: // OPC_LONG_ACK
          
          switch message[1] {
          case 0x30:
            switch message[2] {
            case 0x00:
              _messageType = .setSwRejected
            case 0x7f:
              _messageType = .setSwAccepted
            default:
              break
            }
          case 0x38:
            switch message[2] {
            case 0x00:
              _messageType = .invalidUnlinkP1
            default:
              break
            }
          case 0x39:
            switch message[2] {
            case 0x00:
              _messageType = .invalidLinkP1
            default:
              break
            }
          case 0x3a:
            switch message[2] {
            case 0x00:
              _messageType = .illegalMoveP1
            default:
              break
            }
          case 0x3b:
            switch message[2] {
            case 0x00:
              _messageType = .slotNotImplemented
            default:
              break
            }
          case 0x3c:
            _messageType = .swState
          case 0x3d:
            switch message[2] {
            case 0x00:
              _messageType = .setSwWithAckRejected
            case 0x7f:
              _messageType = .setSwWithAckAccepted
            default:
              break
            }
          case 0x3e:
            switch message[2] {
            case 0x00:
              _messageType = .noFreeSlotsP2
            default:
              break
            }
          case 0x3f:
            switch message[2] {
            case 0x00:
              _messageType = .noFreeSlotsP1
            default:
              break
            }
          case 0x50:
            if (message[2] & 0b01011111) == 0b00010000 {
              _messageType = .brdOpSwState
            }
            else if message[2] == 0x7f {
              _messageType = .setBrdOpSwOK
            }
          case 0x54:
            switch message[2] {
            case 0x00:
              _messageType = .d4Error
            default:
              break
            }
          case 0x6d:
            switch message[2] {
              case 0x00:
              _messageType = .immPacketBufferFull
              case 0x7f:
              _messageType = .immPacketOK
            default:
              _messageType = .s7CVState
              break
            }
          case 0x6e:
            switch message[2] {
            case 0x00:
              _messageType = .routesDisabled
            case 0x7f:
              _messageType = .setSlotDataOKP2
            default:
              _messageType = .s7CVState
              break
            }
          case 0x6f:
            switch message[2] {
            case 0x00:
              _messageType = .programmerBusy
            case 0x01:
              _messageType = .progCmdAccepted
            case 0x40:
              _messageType = .progCmdAcceptedBlind
            case 0x7f:
              _messageType = .setSlotDataOKP1
            default:
              break
            }
          case 0x7e:
            _messageType = .immPacketLMOK
         default:
            break
          }
          
        // MARK: 0xB5
          
        case 0xb5: // OPC_SLOT_STAT1
          
          if message[1] > 0 && message[1] < 0x78 {
            _messageType = .setLocoSlotStat1P1
            _slotsChanged.insert(LocoSlotData.encodeID(slotPage: 0, slotNumber: message[1]))
          }

        // MARK: 0xB6
          
        case 0xb6: // OPC_CONSIST_FUNC
          
          if message[1] > 0 && message[1] < 0x78 && (message[2] & 0b11100000) == 0 {
            _messageType = .consistDirF0F4
            _slotsChanged.insert(LocoSlotData.encodeID(slotPage: 0, slotNumber: message[1]))
          }
        
        // MARK: 0xB8
          
        case 0xb8: // OPC_UNLINK_SLOTS
          
          if message[1] > 0 && message[1] < 0x78 && message[2] > 0 && message[2] < 0x78 {
            _messageType = .unlinkSlotsP1
            _slotsChanged.insert(LocoSlotData.encodeID(slotPage: 0, slotNumber: message[1]))
            _slotsChanged.insert(LocoSlotData.encodeID(slotPage: 0, slotNumber: message[2]))
          }
          
        // MARK: 0xB9
          
        case 0xb9: // OPC_LINK_SLOTS
          
          if message[1] > 0 && message[1] < 0x78 &&
             message[2] > 0 && message[2] < 0x78 {
            _messageType = .linkSlotsP1
            _slotsChanged.insert(LocoSlotData.encodeID(slotPage: 0, slotNumber: message[1]))
            _slotsChanged.insert(LocoSlotData.encodeID(slotPage: 0, slotNumber: message[2]))
          }
          
       // MARK: 0xBA
            
        case 0xba: // OPC_MOVE_SLOTS
          
          if message[1] == 0x00 {
            _messageType = .dispatchGetP1
          }
          else if message[2] == 0x00 && message[1] > 0 && message[1] < 0x78 {
            _messageType = .dispatchPutP1
          }
          else if message[1] == message[2] && message[1] > 0 && message[1] < 0x78 {
            _messageType = .setLocoSlotInUseP1
            _slotsChanged.insert(LocoSlotData.encodeID(slotPage: 0, slotNumber: message[1]))
          }
          else if message[1] < 0x78 && message[2] < 0x78 {
            _messageType = .moveSlotP1
            _slotsChanged.insert(LocoSlotData.encodeID(slotPage: 0, slotNumber: message[1]))
            _slotsChanged.insert(LocoSlotData.encodeID(slotPage: 0, slotNumber: message[2]))
          }

        // MARK: 0xBB
            
        case 0xbb: // OPC_RQ_SL_DATA
          
          if message[2] == 0x00 {
            
            switch message[1] {
            case 0x78:
              break
            case 0x79:
              break
            case 0x7a:
              break
            case 0x7b:
              _messageType = .getFastClockDataP1
            case 0x7c:
              break
            case 0x7d:
              break
            case 0x7e:
              _messageType = .getOpSwDataBP1
            case 0x7f:
              _messageType = .getOpSwDataAP1
            default:
              _messageType = .getLocoSlotData
            }
            
          }
          else if message[1] >= 0x78 && message[1] <= 0x7c && message[2] == 0x41 {
            _messageType = .getQuerySlot
          }
          else if message[1] == 0x7e && message[2] == 0x40 {
            _messageType = .getOpSwDataP2
          }
          else if message[1] == 0x7f && message[2] == 0x40 {
            _messageType = .getOpSwDataP2
          }
          else if message[1] < 0x78 && (message[2] & 0b10111000) == 0 {
            _messageType = .getLocoSlotData
          }
          
        // MARK: 0xBC
          
        case 0xbc: // OPC_SW_STATE
          if (message[2] & 0b11110000) == 0 {
            _messageType = .getSwState
          }
          
        // MARK: 0xBD
          
        case 0xbd: // OPC_SW_ACK
          
          if (message[2] & 0b11000000) == 0 {
            _messageType = .setSwWithAck
          }

        // MARK: 0xBE
          
        case 0xbe:
          
          _messageType = message[1] == 0 ? .getLocoSlotDataSAdrP2 : .getLocoSlotDataLAdrP2

        // MARK: 0xBF
          
        case 0xbf: // OPC_LOCO_ADR
          
          _messageType = message[1] == 0 ? .getLocoSlotDataSAdrP1 : .getLocoSlotDataLAdrP1
          
        // MARK: 0xD0
            
        case 0xd0:
          
          if (message[1] & 0b11111110) == 0b01100010 &&
             (message[3] & 0b11110000) == 0b01110000 {
            _messageType = .getBrdOpSwState
          }
          else if (message[1] & 0b11111110) == 0b01110010 &&
                  (message[3] & 0b11110000) == 0b01110000 {
            _messageType = .setBrdOpSwState
          }
          else if message[1] == 0x62 &&
                 (message[3] & 0b11110000) == 0b00110000 &&
                 (message[4] & 0b11100000) == 0 {
            _messageType = .pmRep
          }
          else if message[1] & 0b01111110 == 0b01100010 &&
                 (message[3] & 0b10010000) == 0 &&
                 (message[4] & 0b10010000) == 0 {
            _messageType = .pmRepBXP88
          }
          else if message[1] == 0x60 &&
                 (message[4] & 0b11111110) == 0 {
            _messageType = .trkShortRep
          }
          else if (message[1] & 0b11010000) == 0 {
            _messageType = .transRep
          }

        // MARK: 0xD3
          
        case 0xd3:
          
          if message[1] == 0x10 &&
            (message[2] & 0b11111100) == 0 &&
             message[3] == 0x00 &&
             message[4] == 0x00 {
            _messageType = .prMode
          }

        // MARK: 0xD4
          
        case 0xd4:
          
          if (message[1] & 0b11111000) == 0b00111000 {
            
            let subCode = message[3] & 0b11111000
            
            let srcPage = message[1] & 0b00000111
            let src = message[2]
            let dstPage = message[3] & 0b00000111
            let dst = message[4]
            
            switch subCode {
            case 0b00000000:
              
              if message[2] == 0x00 && (message[3] & 0b11111000) == 0 {
                _messageType = .dispatchGetP2
              }
              else if message[3] == 0 && dst == 0 && src > 0 && src < 0x78 {
                _messageType = .dispatchPutP2
              }
              else if srcPage == dstPage && src == dst && src > 0 && src > 0 && src < 0x78 && (message[3] & 0b11111000) == 0 {
                _messageType = .setLocoSlotInUseP2
                _slotsChanged.insert(LocoSlotData.encodeID(slotPage: srcPage, slotNumber: src))
              }
              else if src > 0 && src < 0x78 && dst > 0 && dst < 0x78 && (message[3] & 0b11111000) == 0 {
                _messageType = .moveSlotP2
                _slotsChanged.insert(LocoSlotData.encodeID(slotPage: srcPage, slotNumber: src))
                _slotsChanged.insert(LocoSlotData.encodeID(slotPage: dstPage, slotNumber: dst))
              }
              
            case 0b01000000:
              
              if src > 0 && src < 0x78 && dst > 0 && dst < 0x78 {
                _messageType = .linkSlotsP2
                _slotsChanged.insert(LocoSlotData.encodeID(slotPage: srcPage, slotNumber: src))
                _slotsChanged.insert(LocoSlotData.encodeID(slotPage: dstPage, slotNumber: dst))
              }
              
            case 0b01100000:
              
              if src > 0 && src < 0x78 {
                _messageType = .setLocoSlotStat1P2
                _slotsChanged.insert(LocoSlotData.encodeID(slotPage: srcPage, slotNumber: src))
              }
              
            case 0b01010000:
              
              if src > 0 && src < 0x78 && dst > 0 && dst < 0x78 {
                _messageType = .unlinkSlotsP2
                _slotsChanged.insert(LocoSlotData.encodeID(slotPage: srcPage, slotNumber: src))
                _slotsChanged.insert(LocoSlotData.encodeID(slotPage: dstPage, slotNumber: dst))
              }
              
            default:
              break
            }
            
          }
          
        // MARK: 0xD5
          
        case 0xd5:
          
          if message[2] > 0 && message[2] < 0x78 {
            
            let subCode = message[1] & 0b11111000
            
            switch subCode {
            case 0b00000000, 0b00001000:
              _messageType = .locoSpdDirP2
            case 0b00010000:
              _messageType = .locoF0F6P2
            case 0b00011000:
              _messageType = .locoF7F13P2
            case 0b00100000:
              _messageType = .locoF14F20P2
            case 0b00101000, 0b00110000:
              _messageType = .locoF21F28P2
            default:
              break
            }
            
            if _messageType != .unknown {
              _slotsChanged.insert(LocoSlotData.encodeID(slotPage: message[1], slotNumber: message[2]))
            }
            
          }
          
        // MARK: 0xD7
          
        case 0xd7:
          
          if message[2] == 0 &&
            (message[3] & 0b11110000) == 0 &&
             message[4] == 0x20 {
            _messageType = .receiverRep
          }

        // MARK: 0xDF
            
        case 0xdf:
          
          if message[1] == 0x00 &&
             message[2] == 0x00 &&
             message[3] == 0x00 &&
             message[4] == 0x00 {
            _messageType = .findReceiver
          }
          else if message[1] == 0x40 &&
                  message[2] == 0x1f &&
                 (message[3] & 0b11111000) == 0 &&
                  message[4] == 0x00 {
            _messageType = .setLocoNetID
          }

        // MARK: 0xE5
            
        case 0xe5: // OPC_PEER_XFER
            
          switch message[1] {
            
          case 0x09:
            
            if message[2] == 0x01 &&
               message[3] == 0x00 {
              _messageType = .ezRouteConfirm
            }
            else if message[2] == 0x40 &&
               message[5] == 0x00 &&
               message[6] == 0x00 &&
               message[7] == 0x00 {
              _messageType = .findLoco
            }
            else if message[2] == 0x00 &&
              (message[5] & 0b11110000) == 0 &&
               message[7] == 0x00 {
              _messageType = .locoRep
            }

          case 0x10:
            
            if message[ 2] == 0x22 &&
               message[ 3] == 0x22 &&
               message[ 4] == 0x01 &&
               message[ 5] == 0x00 &&
               (message[7] & 0b11100000) == 0x00 &&
               (message[8] & 0b11110000) == 0b00010000 &&
               message[10] == 0x00 {
              _messageType = .interfaceData
            }
            else if message[ 2] == 0x50 &&
               message[ 3] == 0x50 &&
               message[ 4] == 0x01 &&
              (message[ 5] & 0b11110000) == 0x00 &&
              (message[10] & 0b11110000) == 0x00 {
              _messageType = .interfaceDataLB
            }
            else if message[ 2] == 0x22 &&
               message[ 3] == 0x22 &&
               message[ 4] == 0x01 &&
               message[ 5] == 0x00 &&
               message[10] == 0x00 {
              _messageType = .interfaceDataPR3
            }
            else if message[2] == 0x7f &&
               message[3] == 0x7f &&
               message[4] == 0x7f &&
              (message[5] & 0b11110000) == 0b01000000 {
              
              let subCode = message[10] & 0b11110000
              
              switch subCode {
              case 0b00000000:
                if message[12] == 0x00 &&
                   message[14] == 0x00 {
                  _messageType = .iplSetup
                }
                break
              case 0b00010000:
                if message[9 ] == 0x00 &&
                   message[11] == 0x00 &&
                   message[12] == 0x00 &&
                   message[13] == 0x00 &&
                   message[14] == 0x00 {
                  _messageType = .iplSetAddr
                }
              case 0b00100000:
                _messageType = .iplDataLoad
              case 0b01000000:
                if message[6 ] == 0x00 &&
                   message[7 ] == 0x00 &&
                   message[8 ] == 0x00 &&
                   message[9 ] == 0x00 &&
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
            
          case 0x14:
            
            switch message[2] {
            case 0x02:
              switch message[3] {
              case 0x00:
                if message[4 ] == 0x00 &&
                   message[6 ] == 0x00 &&
                   message[7 ] == 0x00 &&
                   message[8 ] == 0x00 &&
                   message[9 ] == 0x00 &&
                   message[10] == 0x00 &&
                   message[11] == 0x00 &&
                   message[12] == 0x00 &&
                   message[13] == 0x00 &&
                   message[14] == 0x00 &&
                   message[15] == 0x00 &&
                   message[16] == 0x00 &&
                   message[17] == 0x00 &&
                   message[18] == 0x00 {
                  _messageType = .setDuplexGroupChannel
                }
              case 0x08:
                if message[4 ] == 0x00 &&
                   message[5 ] == 0x00 &&
                   message[6 ] == 0x00 &&
                   message[7 ] == 0x00 &&
                   message[8 ] == 0x00 &&
                   message[9 ] == 0x00 &&
                   message[10] == 0x00 &&
                   message[11] == 0x00 &&
                   message[12] == 0x00 &&
                   message[13] == 0x00 &&
                   message[14] == 0x00 &&
                   message[15] == 0x00 &&
                   message[16] == 0x00 &&
                   message[17] == 0x00 &&
                   message[18] == 0x00 {
                  _messageType = .getDuplexGroupChannel
                }
              case 0x10:
                if message[4 ] == 0x00 &&
                   message[6 ] == 0x00 &&
                   message[7 ] == 0x00 &&
                   message[8 ] == 0x00 &&
                   message[9 ] == 0x00 &&
                   message[10] == 0x00 &&
                   message[11] == 0x00 &&
                   message[12] == 0x00 &&
                   message[13] == 0x00 &&
                   message[14] == 0x00 &&
                   message[15] == 0x00 &&
                   message[16] == 0x00 &&
                   message[17] == 0x00 &&
                   message[18] == 0x00 {
                  _messageType = .duplexGroupChannel
                }
              default:
                break
              }
            case 0x03:
              switch message[3] {
              case 0x00:
                if (message[4 ] & 0b11110000) == 0 &&
                   (message[9 ] & 0b11110000) == 0 &&
                   (message[14] & 0b11110000) == 0 {
                  _messageType = .setDuplexGroupData
                }
              case 0x08:
                if message[4 ] == 0x00 &&
                   message[5 ] == 0x00 &&
                   message[6 ] == 0x00 &&
                   message[7 ] == 0x00 &&
                   message[8 ] == 0x00 &&
                   message[9 ] == 0x00 &&
                   message[10] == 0x00 &&
                   message[11] == 0x00 &&
                   message[12] == 0x00 &&
                   message[13] == 0x00 &&
                   message[14] == 0x00 &&
                   message[15] == 0x00 &&
                   message[16] == 0x00 &&
                   message[17] == 0x00 &&
                   message[18] == 0x00 {
                  _messageType = .getDuplexGroupData
                }
              case 0x10:
                  if (message[4 ] & 0b11110000) == 0 &&
                     (message[9 ] & 0b11110000) == 0 &&
                     (message[14] & 0b11110000) == 0 {
                    _messageType = .duplexGroupData
                  }
              default:
                break
              }
            case 0x04:
              switch message[3] {
              case 0x00:
                if message[4 ] == 0x00 &&
                   message[6 ] == 0x00 &&
                   message[7 ] == 0x00 &&
                   message[8 ] == 0x00 &&
                   message[9 ] == 0x00 &&
                   message[10] == 0x00 &&
                   message[11] == 0x00 &&
                   message[12] == 0x00 &&
                   message[13] == 0x00 &&
                   message[14] == 0x00 &&
                   message[15] == 0x00 &&
                   message[16] == 0x00 &&
                   message[17] == 0x00 &&
                   message[18] == 0x00 {
                  _messageType = .setDuplexGroupID
                }
              case 0x08:
                if message[4 ] == 0x00 &&
                   message[5 ] == 0x00 &&
                   message[6 ] == 0x00 &&
                   message[7 ] == 0x00 &&
                   message[8 ] == 0x00 &&
                   message[9 ] == 0x00 &&
                   message[10] == 0x00 &&
                   message[11] == 0x00 &&
                   message[12] == 0x00 &&
                   message[13] == 0x00 &&
                   message[14] == 0x00 &&
                   message[15] == 0x00 &&
                   message[16] == 0x00 &&
                   message[17] == 0x00 &&
                   message[18] == 0x00 {
                  _messageType = .getDuplexGroupID
                }
              case 0x10:
                if message[4 ] == 0x00 &&
                   message[6 ] == 0x00 &&
                   message[7 ] == 0x00 &&
                   message[8 ] == 0x00 &&
                   message[9 ] == 0x00 &&
                   message[10] == 0x00 &&
                   message[11] == 0x00 &&
                   message[12] == 0x00 &&
                   message[13] == 0x00 &&
                   message[14] == 0x00 &&
                   message[15] == 0x00 &&
                   message[16] == 0x00 &&
                   message[17] == 0x00 &&
                   message[18] == 0x00 {
                  _messageType = .duplexGroupID
                }
              default:
                break
              }
            case 0x07:
              switch message[3] {
              case 0x00:
                if (message[4 ] & 0b11110000) == 0 &&
                    message[9 ] == 0x00 &&
                    message[10] == 0x00 &&
                    message[11] == 0x00 &&
                    message[12] == 0x00 &&
                    message[13] == 0x00 &&
                    message[14] == 0x00 &&
                    message[15] == 0x00 &&
                    message[16] == 0x00 &&
                    message[17] == 0x00 &&
                    message[18] == 0x00 {
                  _messageType = .setDuplexGroupPassword
                }
              case 0x08:
                if message[4 ] == 0x00 &&
                   message[5 ] == 0x00 &&
                   message[6 ] == 0x00 &&
                   message[7 ] == 0x00 &&
                   message[8 ] == 0x00 &&
                   message[9 ] == 0x00 &&
                   message[10] == 0x00 &&
                   message[11] == 0x00 &&
                   message[12] == 0x00 &&
                   message[13] == 0x00 &&
                   message[14] == 0x00 &&
                   message[15] == 0x00 &&
                   message[16] == 0x00 &&
                   message[17] == 0x00 &&
                   message[18] == 0x00 {
                  _messageType = .getDuplexGroupPassword
                }
              case 0x10:
                if message[4 ] == 0x00 &&
                   message[9 ] == 0x00 &&
                   message[10] == 0x00 &&
                   message[11] == 0x00 &&
                   message[12] == 0x00 &&
                   message[13] == 0x00 &&
                   message[14] == 0x00 &&
                   message[15] == 0x00 &&
                   message[16] == 0x00 &&
                   message[17] == 0x00 &&
                   message[18] == 0x00 {
                  _messageType = .duplexGroupPassword
                }
              default:
                break
              }
            case 0x0f:
              switch message[3] {
              case 0x08:
                if message[4 ] == 0x00 &&
                   message[6 ] == 0x00 &&
                   message[7 ] == 0x00 &&
                   message[8 ] == 0x00 &&
                   message[9 ] == 0x00 &&
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
              case 0x10:
                if (message[4 ] & 0b11110000) == 0x00 &&
                   (message[9 ] & 0b11110000) == 0x00 &&
                   (message[14] & 0b11110000) == 0x00 {
                  _messageType = .iplDevData
                }
              default:
                break
              }
            case 0x10:
              switch message[3] {
              case 0x08:
                if message[4 ] == 0x00 &&
                   message[6 ] == 0x00 &&
                   message[7 ] == 0x00 &&
                   message[8 ] == 0x00 &&
                   message[9 ] == 0x00 &&
                   message[10] == 0x00 &&
                   message[11] == 0x00 &&
                   message[12] == 0x00 &&
                   message[13] == 0x00 &&
                   message[14] == 0x00 &&
                   message[15] == 0x00 &&
                   message[16] == 0x00 &&
                   message[17] == 0x00 &&
                   message[18] == 0x00 {
                  _messageType = .getDuplexSignalStrength
                }
              case 0x10:
                if (message[4 ] & 0b11110000) == 0 &&
                    message[9 ] == 0x00 &&
                    message[10] == 0x00 &&
                    message[11] == 0x00 &&
                    message[12] == 0x00 &&
                    message[13] == 0x00 &&
                    message[14] == 0x00 &&
                    message[15] == 0x00 &&
                    message[16] == 0x00 &&
                    message[17] == 0x00 &&
                    message[18] == 0x00 {
                  _messageType = .duplexSignalStrength
                }
                else if (message[4 ] & 0b11110000) == 0 &&
                    message[ 5] != 0x00 &&
                    message[ 6] != 0x00 &&
                    message[ 7] != 0x00 &&
                    message[ 8] != 0x00 &&
                    (message[9] & 0b11110000) == 0x00 &&
                    message[10] != 0x00 &&
                    message[11] != 0x00 &&
                    message[12] != 0x00 &&
                    message[13] != 0x00 &&
                   (message[14] & 0b11110000) == 0x00 {
                  _messageType = .lnwiData
                }

              default:
                break
              }
              
            default:
              break
            }

          default:
            break
          }

        // MARK: 0xE6
            
        case 0xe6:
          
          if message[1] == 0x15 && (message[2] & 0b11111000) == 0 {
            
            if message[3] > 0 && message[3] < 0x78 && (message[7] & 0b10110000) == 00 {
              _messageType = .locoSlotDataP2
            }
            else if message[3] >= 0x78 && message[3] <= 0x7c && message[2] == 0x01 {
              switch message[3] {
              case 0x78:
                _messageType = .querySlot1
              case 0x79:
                _messageType = .querySlot2
              case 0x7a:
                _messageType = .querySlot3
              case 0x7b:
                _messageType = .querySlot4
              case 0x7c:
                _messageType = .querySlot5
              default:
                break
              }
            }
            else if message[3] == 0x7f && message[2] == 0x00 {
              _messageType = .opSwDataP2
            }
            
          }
          else if message[1] == 0x10 {
                    
            if message[2] == 0x01 {
              
              if message[3] == 0x00 &&
                 message[10] == 0x00 &&
                 message[11] == 0x00 &&
                 message[12] == 0x00 &&
                 message[13] == 0x00 &&
                 message[14] == 0x00 {
                _messageType = .routeTableInfoA
              }
              else if message[3] == 0x02 &&
                (message[5] & 0b11111110) == 0x00 &&
                 message[6] == 0x0f {
                _messageType = .routeTablePage
              }
              
            }
            else if message[2] == 0x02 {
              
              if message[ 3] == 0x00 &&
                 message[ 4] == 0x10 &&
                 message[ 5] == 0x00 &&
                 message[ 6] == 0x00 &&
                 message[ 7] == 0x02 &&
                 message[ 8] == 0x08 &&
                 message[10] == 0x00 &&
                 (message[12] & 0b11000000) == 0x00 &&
                 (message[14] & 0b11110000) == 0x00 {
                _messageType = .s7Info
              }

            }
            
          }

        // MARK: 0xE7
            
        case 0xe7: // OPC_SL_RD_DATA
          
          if message[ 1] == 0x0e &&
            (message[ 7] &  0b00110000) == 0x00 /* TRK */ {
            
            switch message[2] {
            case 0x78:
              break
            case 0x79:
              break
            case 0x7a:
              break
            case 0x7b:
              _messageType = .fastClockDataP1
            case 0x7c:
              if (message[ 4] & 0b11110000) == 0 {
                _messageType = .progSlotDataP1
              }
            case 0x7d:
              break
            case 0x7e:
              _messageType = .opSwDataBP1
            case 0x7f:
              _messageType = .opSwDataAP1
            default:
              if message[ 2] > 0 && message[2] < 0x78 &&
                (message[ 6] & 0b11000000) == 0 && /* DIRF */
                (message[ 7] & 0b10110000) == 0 &&
                (message[ 8] & 0b11110010) == 0 && /* SS@  */
                (message[10] & 0b11110000) == 0    /* SND  */ {
                _messageType = .locoSlotDataP1
              }
            }
            
          }
          
        // MARK: 0xED
          
        case NetworkMessageOpcode.OPC_IMM_PACKET.rawValue:
          
          if message[1] == 0x0b && message[2] == 0x7f {
            
            if (message[3] & 0b10001000) == 0 &&
               (message[4] & 0b11100000) == 0b00100000 {
              _messageType = .immPacket
            }
            else if message[3] == 0x54 &&
              (message[4] & 0b11100111) == 0b00000111 &&
              (message[7] & 0b11110111) == 0b01100100 {
              _messageType = .s7CVRW
            }
            
          }

        // MARK: 0xEE
            
        case 0xee:
          
          if message[1] == 0x15 {
            if message[2] == 0 && message[3] == 0x7f {
              _messageType = .setOpSwDataP2
            }
            else if message[2] == 0x19 && message[3] == 0x7b {
              _messageType = .resetQuerySlot4
            }
            else if message[3] > 0 && message[3] < 0x78 {
              _messageType = .setLocoSlotDataP2
              _slotsChanged.insert(LocoSlotData.encodeID(slotPage: message[2], slotNumber: message[3]))
            }
          }
          else if message[1] == 0x10 {
            
            if message[2] == 0x01 {
              
              if message[ 3] == 0x00 &&
                 message[ 4] == 0x00 &&
                 message[ 5] == 0x00 &&
                 message[ 6] == 0x00 &&
                 message[ 7] == 0x00 &&
                 message[ 8] == 0x00 &&
                 message[ 9] == 0x00 &&
                 message[10] == 0x00 &&
                 message[11] == 0x00 &&
                 message[12] == 0x00 &&
                 message[13] == 0x00 {
                _messageType = .getRouteTableInfoA
              }
              else if message[ 3] == 0x02 &&
                 (message[5] & 0b11111110) == 0x00 &&
                 message[ 6] == 0x00 &&
                 message[ 7] == 0x00 &&
                 message[ 8] == 0x00 &&
                 message[ 9] == 0x00 &&
                 message[10] == 0x00 &&
                 message[11] == 0x00 &&
                 message[12] == 0x00 &&
                 message[13] == 0x00 {
                _messageType = .getRouteTablePage
              }
              else if message[ 3] == 0x03 &&
                 (message[5] & 0b11111110) == 0x00 {
                _messageType = .setRouteTablePage
              }

            }
            else if message[2] == 0x02 {
              
              if message[ 3] == 0x00 &&
                 message[ 4] == 0x00 &&
                 message[ 5] == 0x00 &&
                 message[ 6] == 0x00 &&
                 message[ 7] == 0x00 &&
                 message[ 8] == 0x00 &&
                 message[ 9] == 0x00 &&
                 message[10] == 0x00 &&
                 message[11] == 0x00 &&
                 message[12] == 0x00 &&
                 message[13] == 0x00 &&
                 message[14] == 0x00 {
                _messageType = .getRouteTableInfoB
              }
              else if message[3] == 0x0f &&
                 message[ 4] == 0x00 &&
                 message[ 5] == 0x00 &&
                 message[ 6] == 0x00 &&
                 message[ 7] == 0x00 &&
                 message[ 8] == 0x00 &&
                 message[10] == 0x00 &&
                 (message[12] & 0b11000000) == 0x00 &&
                 (message[14] & 0b11110000) == 0x00 {
                _messageType = .setS7BaseAddr
              }

            }
            
          }
          
        // MARK: 0xEF
            
        case 0xef: // OPC_WR_SL_DATA
          
          if message[1] == 0x0e {
            
            if message[2] > 0 && message[ 2] <  0x78 && /* SLOT */
              (message[ 6] &  0b11000000) == 0x00 && /* DIRF */
              (message[ 7] &  0b10110000) == 0x00 && /* TRK  */
              (message[ 8] &  0b11110010) == 0x00 && /* SS@  */
              (message[10] &  0b11110000) == 0x00    /* SND  */ {
              _messageType = .setLocoSlotDataP1
              _slotsChanged.insert(LocoSlotData.encodeID(slotPage: 0, slotNumber: message[2]))
            }
            else if message[ 2] == 0x7b {
              _messageType = .setFastClockDataP1
            }
            else if message[ 2] == 0x7c &&                /* PROG SLOT */
                    message[ 4] == 0x00 &&
                    message[ 7] == 0x00 &&
                   (message[ 8] &  0b11001100) == 0x00 {
              _messageType = .progCV
            }
            else if message[2] == 0x7e {
              _messageType = .setOpSwDataBP1
            }
            else if message[2] == 0x7f {
              _messageType = .setOpSwDataAP1
            }
            
          }

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
  
  public var sensorAddress : Int {
    get {
      var addr = Int(message[1])
      addr |= (Int(message[2] & 0b00001111) << 7)
      addr <<= 1
      addr |= (Int(message[2] & 0b00100000) >> 5)
      return addr + 1
    }
  }
  
  public var turnoutReportAddress : Int {
    get {
      var addr = Int(message[1])
      addr |= (Int(message[2] & 0b00001111) << 7)
//      addr <<= 1
//      addr |= (Int(message[2] & 0b00100000) >> 5)
      return addr + 1
    }
  }
  
  public var sensorState : Bool {
    get {
      let mask : UInt8 = 0b00010000
      return (message[2] & mask) == mask
    }
  }

  // MARK: Class Methods
  
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
