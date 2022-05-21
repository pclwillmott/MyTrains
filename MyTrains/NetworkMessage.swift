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
  
  private var _willChangeSlot : Bool = false
  
  private var _slotID : Int = 0
  
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
          
        // Ack
          
        case NetworkMessageOpcode.OPC_SW_REQ.rawValue:
          if (message[2] & 0b11000000) == 0b00000000 {
            _messageType = .setSw
          }

        case NetworkMessageOpcode.OPC_LONG_ACK.rawValue:
          
          _messageType = .ack
          
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
          case 0x6e:
            switch message[2] {
            case 0x7f:
              _messageType = .setSlotDataOKP2
            default:
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
          case 0x7d:
            switch message[2] {
              case 0x00:
              _messageType = .immPacketBufferFull
              case 0x7f:
              _messageType = .immPacketOK
            default:
              break
            }
         default:
            break
          }
        
        // Busy
          
        case NetworkMessageOpcode.OPC_BUSY.rawValue:
          _messageType = .busy
        
        // Slot Data P1
          
        case NetworkMessageOpcode.OPC_SL_RD_DATA.rawValue:
          
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
              _messageType = .cfgSlotDataBP1
            case 0x7f:
              _messageType = .cfgSlotDataP1
            default:
              if message[2] < 0x78 &&
                (message[ 6] & 0b11000000) == 0 && /* DIRF */
                (message[ 7] & 0b10110000) == 0 &&
                (message[ 8] & 0b11110010) == 0 && /* SS@  */
                (message[10] & 0b11110000) == 0    /* SND  */ {
                _messageType = .locoSlotDataP1
              }
            }
            
          }
          
        // Get Slot Data
          
        case NetworkMessageOpcode.OPC_RQ_SL_DATA.rawValue:
          
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
              break
            case 0x7f:
              _messageType = .getCfgSlotDataP1
            default:
              _messageType = .getLocoSlotData
            }
            
          }
          else if message[1] >= 0x78 && message[1] <= 0x7c && message[2] == 0x41 {
            _messageType = .getQuerySlot
          }
          else if message[1] == 0x7f && message[2] == 0x40 {
            _messageType = .getCfgSlotDataP2
          }
          else if message[1] < 0x78 && (message[2] & 0b10111000) == 0 {
            _messageType = .getLocoSlotData
          }
          break

        // Slot Data P2
          
        case NetworkMessageOpcode.OPC_SL_RD_DATA_P2.rawValue:
          
          if message[1] == 0x15 && (message[2] & 0b11111000) == 0 {
            
            if message[3] < 0x78 && (message[7] & 0b10110000) == 00 {
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
              _messageType = .cfgSlotDataP2
            }
            
          }

        // ConsistDirF0F4
          
        case NetworkMessageOpcode.OPC_CONSIST_FUNC.rawValue:
          
          if message[1] < 0x78 && (message[2] & 0b01000000) == 0x00 {
            _messageType = .consistDirF0F4
            _willChangeSlot = true
            isP1 = true
            slotPage = 0
            slotNumber = Int(message[1])
          }
  
        // Move Slots P1 Group
          
        case NetworkMessageOpcode.OPC_MOVE_SLOTS.rawValue:
          
          isP1 = true
          slotPage = 0
          
          if message[1] == 0x00 {
            _messageType = .dispatchGetP1
          }
          else if message[2] == 0x00 && message[1] < 0x78 {
            _messageType = .dispatchPutP1
            slotNumber = Int(message[1])
          }
          else if message[1] == message[2] && message[1] < 0x78 {
            _messageType = .setLocoSlotInUseP1
            slotNumber = Int(message[1])
            _willChangeSlot = true
          }
          else if message[1] < 0x78 && message[2] < 0x78 {
            _messageType = .moveSlotP1
            slotNumber = Int(message[2])
            _willChangeSlot = true
          }
  
        // D4 Group
          
        case NetworkMessageOpcode.OPC_D4_GROUP.rawValue:
          
          if (message[1] & 0b11111000) == 0b00111000 {
            
            let subCode = message[3] & 0b11111000
            
            switch subCode {
            case 0b00000000:
              isP1 = false
              let srcPage = Int(message[1] & 0b00000111)
              let src = Int(message[2])
              let dstPage = Int(message[3] & 0b00000111)
              let dst = Int(message[4])
              if message[2] == 0x00 && (message[3] & 0b11111000) == 0 {
                _messageType = .dispatchGetP2
                _willChangeSlot = true
              }
              else if message[3] == 0 && message[4] == 0 && message[2] < 0x78 {
                _messageType = .dispatchPutP2
                slotPage = srcPage
                slotNumber = src
                _willChangeSlot = true
              }
              else if srcPage == dstPage && src == dst && src < 0x78 && (message[3] & 0b11111000) == 0 {
                _messageType = .setLocoSlotInUseP2
                slotPage = srcPage
                slotNumber = src
                _willChangeSlot = true
              }
              else if src < 0x78 && dst < 0x78 && (message[3] & 0b11111000) == 0 {
                _messageType = .moveSlotP2
                slotPage = dstPage
                slotNumber = dst
                _willChangeSlot = true
              }
            case 0b01000000:
              _messageType = .linkSlotsP2
              _willChangeSlot = true
              isP1 = false
              slotPage = Int(message[1] & 0b00000111)
              slotNumber = Int(message[2])
            case 0b01100000:
              if message[2] < 0x78 && message[4] < 0x78 {
                _messageType = .setLocoSlotStat1P2
                _willChangeSlot = true
                isP1 = true
                slotPage = Int(message[1] & 0x7)
                slotNumber = Int(message[2])
              }
            case 0b01010000:
              if message[2] < 0x78 && message[4] < 0x78 {
                _messageType = .unlinkSlotsP2
                _willChangeSlot = true
                isP1 = false
                slotPage = Int(message[1] & 0b00000111)
                slotNumber = Int(message[2])
              }
            default:
              break
            }
          }
          
        // Peer Xfer Group
          
        case NetworkMessageOpcode.OPC_PEER_XFER.rawValue:
          
          switch message[1] {
          case 0x10:
            
            if message[ 2] == 0x22 &&
               message[ 3] == 0x22 &&
               message[ 4] == 0x01 &&
               message[ 5] == 0x00 &&
               message[10] == 0x00 {
              _messageType = .interfaceData
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
                  _messageType = .iplSetupBL2
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
                  _messageType = .setDuplexChannelNumber
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
                  _messageType = .getDuplexChannelNumber
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
                  _messageType = .duplexChannelNumber
                }
              default:
                break
              }
            case 0x03:
              switch message[3] {
              case 0x00:
                if (message[4 ] & 0b11110000) == 0 &&
                   (message[9 ] & 0b11110000) == 0 &&
                   (message[14] & 0b11110000) == 0 &&
                    message[15] == 0x00 &&
                    message[16] == 0x00 &&
                    message[17] == 0x00 &&
                    message[18] == 0x00 {
                  _messageType = .setDuplexGroupName
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
                  _messageType = .getDuplexData
                }
              case 0x10:
                  if (message[4 ] & 0b11110000) == 0 &&
                     (message[9 ] & 0b11110000) == 0 &&
                     (message[14] & 0b11110000) == 0 {
                    _messageType = .duplexData
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
                  _messageType = .setDuplexPassword
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
                  _messageType = .getDuplexPassword
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
                  _messageType = .duplexPassword
                }
              default:
                break
              }
            case 0x0f:
              switch message[3] {
              case 0x08:
                if message[4 ] == 0x00 &&
                   message[5 ] == 0x00 &&
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
              case 0x00:
                break
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
              default:
                break
              }
              
            default:
              break
            }

          default:
            break
          }
        
        // DF Group
          
        case NetworkMessageOpcode.OPC_DF_GROUP.rawValue:
          
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

        // D0 Group
          
        case NetworkMessageOpcode.OPC_D0_GROUP.rawValue:
          
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
          else if message[1] == 0x60 &&
                 (message[4] & 0b11111110) == 0 {
            _messageType = .trkShortRep
          }
        
        case NetworkMessageOpcode.OPC_LOCO_ADR.rawValue:
          _messageType = message[1] == 0 ? .getLocoSlotDataSAdrP1 : .getLocoSlotDataLAdrP1
          
        case NetworkMessageOpcode.OPC_LOCO_ADR_P2.rawValue:
          _messageType = message[1] == 0 ? .getLocoSlotDataSAdrP2 : .getLocoSlotDataLAdrP2

        case NetworkMessageOpcode.OPC_SW_STATE.rawValue:
          if (message[2] & 0b11110000) == 0 {
            _messageType = .getSwState
          }

        case NetworkMessageOpcode.OPC_IMM_PACKET.rawValue:
          if message[1] == 0x0b &&
             message[2] == 0x7f &&
            (message[3] & 0b10001000) == 0 &&
            (message[4] & 0b11100000) == 0b00100000 {
              _messageType = .immPacket
          }

        case NetworkMessageOpcode.OPC_SW_REQ.rawValue:
          if (message[1] & 0b01111000) == 0b01111000 && (message[2] & 0b11101111) == 0b00000111 {
            _messageType = .interrogate
          }
        
        case NetworkMessageOpcode.OPC_LINK_SLOTS.rawValue:
          if message[1] > 0 && message[1] < 0x78 &&
            message[2] > 0 && message[2] < 0x78 {
            _messageType = .linkSlotsP1
            _willChangeSlot = true
            isP1 = true
            slotPage = 0
            slotNumber = Int(message[1])
          }
          
        case NetworkMessageOpcode.OPC_LOCO_DIRF.rawValue:
          if message[1] < 0x78 && (message[2] & 0b01000000) == 0x00 {
            _messageType = .locoDirF0F4P1
            _willChangeSlot = true
            isP1 = true
            slotPage = 0
            slotNumber = Int(message[1])
          }
          
        // D5 Group
          
        case NetworkMessageOpcode.OPC_D5_GROUP.rawValue:
          
          if message[2] < 0x78 {
            
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
              _willChangeSlot = true
              isP1 = false
              slotPage = Int(message[1] & 0b00000111)
              slotNumber = Int(message[2])
            }
            
          }
          
        case NetworkMessageOpcode.OPC_LOCO_SPD.rawValue:
          if message[1] < 0x78 {
            _messageType = .locoSpdP1
            _willChangeSlot = true
            isP1 = true
            slotPage = 0
            slotNumber = Int(message[1])
          }

        case NetworkMessageOpcode.OPC_PR_MODE.rawValue:
          if message[1] == 0x10 &&
            (message[2] & 0b11111100) == 0 &&
             message[3] == 0x00 &&
             message[4] == 0x00 {
            _messageType = .prMode
          }

        // Write Slot P1
          
        case NetworkMessageOpcode.OPC_WR_SL_DATA.rawValue:
          
          if message[1] == 0x0e {
            if message[ 2] <  0x78 &&                /* SLOT */
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
            else if message[ 2] == 0x7b {
              _messageType = .setFastClockDataP1
            }
            else if message[ 2] == 0x7c &&                /* PROG SLOT */
                    message[ 4] == 0x00 &&
                    message[ 7] == 0x00 &&
                   (message[ 8] &  0b11001100) == 0x00 {
              _messageType = .progCV
            }
            else if message[2] == 0x7f {
              _messageType = .setCfgSlotDataP1
            }
          }
        case NetworkMessageOpcode.OPC_GPOFF.rawValue:
          _messageType = .pwrOff
          
        case NetworkMessageOpcode.OPC_GPON.rawValue:
          _messageType = .pwrOn

        case NetworkMessageOpcode.OPC_D7_GROUP.rawValue:
          if message[2] == 0 &&
            (message[3] & 0b11110000) == 0 &&
             message[4] == 0x20 {
            _messageType = .receiverRep
          }

        case NetworkMessageOpcode.OPC_LOCO_RESET.rawValue:
          _messageType = .reset

        case NetworkMessageOpcode.OPC_INPUT_REP.rawValue:
          if (message[2] & 0b11000000) == 0b01000000 {
            _messageType = .sensRepGenIn
          }
          
        case NetworkMessageOpcode.OPC_SW_REP.rawValue:
          let test = message[2] & 0b11000000
          if test == 0b01000000 {
            _messageType = .sensRepTurnIn
          }
          else if test == 0b00000000 {
            _messageType = .sensRepTurnOut
          }

        // Write Slot Data P2
          
        case NetworkMessageOpcode.OPC_WR_SL_DATA_P2.rawValue:
          if message[1] == 0x15 {
            if message[2] == 0 && message[3] == 0x7f {
              _messageType = .setCfgSlotDataP2
            }
            else if message[2] == 0x19 && message[3] == 0x7b {
              _messageType = .resetQuerySlot4
            }
            else if message[3] < 0x78 {
              _messageType = .setLocoSlotDataP2
              _willChangeSlot = true
              isP1 = false
              slotPage = Int(message[2] & 0b00000111)
              slotNumber = Int(message[3])
            }
          }

        case NetworkMessageOpcode.OPC_IDLE.rawValue:
          _messageType = .setIdleState
 
        case NetworkMessageOpcode.OPC_SLOT_STAT1.rawValue:
          if message[1] < 0x78 {
            _messageType = .setLocoSlotStat1P1
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

        case NetworkMessageOpcode.OPC_SW_ACK.rawValue:
          if (message[2] & 0b11000000) == 0 {
            _messageType = .setSwWithAck
          }

        case NetworkMessageOpcode.OPC_INPUT_REP.rawValue:
          if (message[2] & 0b11110000) == 0 {
            _messageType = .transRep
          }
        
        case NetworkMessageOpcode.OPC_UNLINK_SLOTS.rawValue:
          if message[1] < 0x78 && message[2] < 0x78 {
            _messageType = .unlinkSlotsP1
            _willChangeSlot = true
            isP1 = true
            slotPage = 0
            slotNumber = Int(message[1])
          }

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
