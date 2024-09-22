//
//  DCCPacket.swift
//  MyTrains
//
//  Created by Paul Willmott on 26/08/2024.
//

import Foundation

public class DCCPacket : NSObject {
  
  // MARK: Constructors & Destructors
  
  init?(packet:[UInt8], decoderMode:DCCDecoderMode = .operationsMode) {
    
    self.packet = packet
    
    self.decoderMode = decoderMode
    
    super.init()
    
    guard packet.count > 1 && checksumOK else {
      return nil
    }
    
  }
  
  // MARK: Private Properties
  
  private var _packetType : DCCPacketTypeNew?
  
  // MARK: Public Properties
  
  public var packet : [UInt8]
  
  public var decoderMode : DCCDecoderMode
  
  public var checksumOK : Bool {
    var checksum = packet[0]
    for index in 1 ... packet.count - 1 {
      checksum ^= packet[index]
    }
    return checksum == 0
  }
  
  private let validDirectModeCVPackets : Set<DCCPacketTypeNew> = [
    .directModeWriteBit,
    .directModeVerifyBit,
    .directModeWriteByte,
    .directModeVerifyByte,
  ]
  
  public var cvNumber : UInt16? {
    
    guard validDirectModeCVPackets.contains(packetType) else {
      return nil
    }
    
    return ((UInt16(packet[0] & 0b00000011) << 8) | UInt16(packet[1])) + 1
    
  }
  
  public var cvBitNumber : Int? {
    
    guard validDirectModeCVPackets.contains(packetType) && (packet[0] & 0b00001100) == 0b00001000 else {
      return nil
    }
    
    return Int(packet[2] & 0b000000111)
    
  }

  public var cvBitValue : Int? {
    
    guard validDirectModeCVPackets.contains(packetType) && (packet[0] & 0b00001100) == 0b00001000 else {
      return nil
    }
    
    return Int(packet[2] & 0b000001000) >> 3
    
  }

  public var cvValue : UInt8? {
    
    guard packetType == .directModeWriteByte || packetType == .directModeVerifyByte else {
      return nil
    }
    
    return packet[2]
    
  }
  
  public var packetType : DCCPacketTypeNew {
    
    if _packetType == nil {
      
      let serviceModeMask : UInt8 = 0b01110000
      
      if decoderMode == .operationsMode {
        
        var isMultiFunctionDecoder = false
        var isShortAddress : Bool?
        
        switch packet[0] {
        case 0:
          break
        case 1 ... 127:
          isMultiFunctionDecoder = true
          isShortAddress = true
        case 128 ... 191:
          break
        case 192 ... 231:
          isMultiFunctionDecoder = true
          isShortAddress = false
        case 232 ... 252:
          break
        case 253 ... 254:
          break
        case 255:
          break
        default:
          break
        }
        
        if isMultiFunctionDecoder, let isShortAddress {
          
          let index = isShortAddress ? 1 : 2
          
          switch packet[index] & 0b11100000 {
          case 0b00000000: // Decoder & Consist Control
            break
          case 0b00100000: // Advanced Operations Instructions
            switch packet[index] & 0b00011111 {
            case 0b00011111:
              _packetType = .speedStepControl128
            case 0b00011101:
              _packetType = .analogFunctionGroup
            default:
              break
            }
          case 0b01000000, 0b01100000:
            _packetType = .speedAndDirectionPacket
          case 0b10000000: // Function Group One Instruction
            _packetType = .functionFLF1F4
          case 0b10100000: // Function Group Two Instruction
            switch packet[index] & 0b00010000 {
            case 0b00000000:
              _packetType = .functionF9F12
            case 0b00010000:
              _packetType = .functionF5F8
            default:
              break
            }
          case 0b11000000: // Feature Expansion
            switch packet[index] & 0b00011111 {
            case 0b00000000:
              _packetType = .binaryStateControlLongForm
            case 0b00000001:
              _packetType = .timeAndDateCommand
            case 0b00000010:
              _packetType = .systemTime
            case 0b00011101:
              _packetType = .binaryStateControlShortForm
            case 0b00011110:
              _packetType = .functionF13F20
            case 0b00011111:
              _packetType = .functionF21F28
            case 0b00011000:
              _packetType = .functionF29F36
            case 0b00011001:
              _packetType = .functionF37F44
            case 0b00011010:
              _packetType = .functionF45F52
            case 0b00011011:
              _packetType = .functionF53F60
            case 0b00011100:
              _packetType = .functionF61F68
            default:
              break
            }
          case 0b11100000: // CV Access Instruction
            switch packet[index] & 0b00010000 {
            case 0b00000000:
              switch packet[index] & 0b00001100 {
              case 0b00000100:
                _packetType = .cvAccessVerifyByte
              case 0b00001100:
                _packetType = .cvAccessWriteByte
              case 0b00001000:
                switch packet[index + 2] & 0b11110000 {
                case 0b11100000:
                  _packetType = .cvAccessVerifyBit
                case 0b11110000:
                  _packetType = .cvAccessWriteBit
                default:
                  break
                }
              default:
                break
              }
            case 0b00010000:
              switch packet[index] & 0b00001111 {
              case 0b00000010:
                _packetType = .cvAccessAccelerationAdjustment
              case 0b00000011:
                _packetType = .cvAccessDeclerationAdjustment
              case 0b00000100:
                _packetType = .cvAccessLongAddress
              case 0b00000101:
                _packetType = .cvAccessIndexedCVs
              default:
                break
              }
            default:
              break
            }
          default:
            break
          }

        }
        
      }
      else {
        
        switch decoderMode {
        case .serviceModeDirectAddressing:
          if packet.count == 4 && (packet[0] & serviceModeMask) == serviceModeMask {
            switch packet[0] & 0b00001100 {
            case 0b00000100:
              _packetType = .directModeVerifyByte
            case 0b00001100:
              _packetType = .directModeWriteByte
            case 0b00001000:
              if (packet[2] & 0b11100000) == 0xe0 {
                switch packet[2] & 0b00010000 {
                case 0b00000000:
                  _packetType = .directModeVerifyBit
                case 0b00010000:
                  _packetType = .directModeWriteBit
                default:
                  break
                }
              }
            default:
              break
            }
          }
        case .serviceModeAddressOnly:
          if packet.count == 3 && (packet[0] & serviceModeMask) == serviceModeMask && (packet[0] & 0b00000111) == 0 && (packet[1] & 0b10000000) == 0 {
            switch packet[0] & 0b00001000 {
            case 0b00001000:
              _packetType = .addressOnlyWriteAddress
            case 0b00000000:
              _packetType = .addressOnlyVerifyAddress
            default:
              break
            }
          }
        case .serviceModePhysicalRegister:
          if packet.count == 3 && (packet[0] & serviceModeMask) == serviceModeMask {
            switch packet[0] & 0b00001000 {
            case 0b00001000:
              _packetType = .physicalRegisterWriteByte
            case 0b00000000:
              _packetType = .physicalRegisterVerifyByte
            default:
              break
            }
          }
        case .serviceModePagedAddressing:
          if packet.count == 3 && (packet[0] & serviceModeMask) == serviceModeMask {
            switch packet[0] & 0b00001000 {
            case 0b00001000:
              _packetType = .pagedModeWriteByte
            case 0b00000000:
              _packetType = .pagedModeVerifyByte
            default:
              break
            }
          }
        default:
          break
        }
        
        if _packetType == nil {
          
          if packet.count == 3 {
            if packet[0] == 0b01111101 && packet[1] == 0b00000001 && packet[2] == 0b01111100 {
              _packetType = .pagePresetInstruction
            }
            
          }
        }
        
      }
      
      if _packetType == nil {
                
        if packet[0] == 0 && packet[1] == 0 && packet[2] == 0 {
          _packetType = .digitalDecoderResetPacket
        }
        else if packet[0] == 0xff && packet[1] == 0 && packet[2] == 0xff {
          _packetType = .digitalDecoderIdlePacket
        }
        else {
          _packetType = .unknown
        }

      }

    }
    
    return _packetType!
    
  }
  
}
