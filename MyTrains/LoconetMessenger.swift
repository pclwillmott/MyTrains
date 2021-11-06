//
//  LoconetMessenger.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/10/2021.
//

import Foundation
import ORSSerial

public protocol LoconetMessengerDelegate {
  func LoconetSensorMessageReceived(message:LoconetSensorMessage)
  func LoconetSwitchRequestMessageReceived(message:LoconetSwitchRequestMessage)
  func LoconetSlotDataMessageReceived(message:LoconetSlotDataMessage)
  func LoconetTurnoutOutputMessageReceived(message:LoconetTurnoutOutputMessage)
  func LoconetLongAcknowledgeMessageReceived(message:LoconetLongAcknowledgeMessage)
  func LoconetRequestSlotDataMessageReceived(message:LoconetRequestSlotDataMessage)
}

public class LoconetMessenger : NSObject, ORSSerialPortDelegate {

  // Constructor
  
  init(id:String, path:String) {
    self.id = id
    super.init()
    if let sp = ORSSerialPort(path: path) {
      sp.delegate = self
      sp.baudRate = 57600
      sp.numberOfDataBits = 8
      sp.numberOfStopBits = 1
      sp.parity = .none
      sp.usesRTSCTSFlowControl = false
      sp.usesDTRDSRFlowControl = false
      sp.usesDCDOutputFlowControl = false
      serialPort = sp
      sp.open()
    }
  }
  
  // Private Properties
  
  private var serialPort : ORSSerialPort? = nil
  private var buffer : [UInt8] = [UInt8](repeating: 0x00, count:256)
  private var readPtr : Int = 0
  private var writePtr : Int = 0
  private var bufferCount : Int = 0
  private var bufferLock : NSLock = NSLock()
  
  // Public Properties
  
  public var id : String
  
  public var delegate : LoconetMessengerDelegate? = nil
  
  // ORSSerialPortDelegate Methods
  
  public func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
    self.serialPort = nil
  }
  
  public func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
    bufferLock.lock()
    bufferCount += data.count
    for x in data {
      buffer[writePtr] = x
      writePtr = (writePtr + 1) & 0xff
    }
    bufferLock.unlock()
    decode()
  }
  
  private func decode() {
    
    var doAgain : Bool = true
    
    while doAgain {
      
      doAgain = false
      
      // find the start of a message
      
      var opCodeFound : Bool
      
      opCodeFound = false
      
      bufferLock.lock()
      while bufferCount > 0 {
        if ((buffer[readPtr] & 0x80) != 0) {
          opCodeFound = true
          break
        }
        readPtr = (readPtr + 1) & 0xff
        bufferCount -= 1
      }
      bufferLock.unlock()
      
      if opCodeFound {
        
        var length = (buffer[readPtr] & 0b01100000) >> 5
        
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
          length = bufferCount > 1 ? buffer[(readPtr+1) & 0xff] : 0xff
          break
        }
        
        if length < 0xff && bufferCount >= length {
          
          var message : [UInt8] = [UInt8](repeating: 0x00, count:Int(length))
          
          var restart : Bool = false
          
          bufferLock.lock()
          
          var index : Int = 0
          
          while index < length {
            
            let cc = buffer[readPtr]
            
            // check that there are no high bits set in the data bytes
            
            if index > 0 && ((cc & 0x80) != 0x00) {
              restart = true
              break
            }
            
            message[index] = cc
            
            readPtr = (readPtr + 1) & 0xff
            index += 1
            bufferCount -= 1
            
          }
          
          // Do another loop if there are at least 2 bytes in the buffer
          
          doAgain = bufferCount > 1
          
          bufferLock.unlock()
          
          // Process message if no high bits set in data
          
          if !restart {
          
            let loconetMessage = LoconetMessage(interfaceId:self.id, message: message)
            
            if loconetMessage.checkSumOK {
              
              let opCode = loconetMessage.opCode
              
              switch opCode {
              case .OPC_UNKNOWN:
                print("OPC_UNKNOWN \(String(format: "%02X", loconetMessage.opCodeRawValue))")
                print("message Length = \(loconetMessage.messageLength)\n")
                break
              case .OPC_BUSY:
                // Ignore these opcodes
                break
    /*          case .OPC_GPOFF:
                break
              case .OPC_GPON:
                break
              case .OPC_IDLE:
                break
              case .OPC_LOCO_SPD:
                break
              case .OPC_LOCO_DIRF:
                break
              case .OPC_LOCO_SND:
                break */
              case .OPC_SW_REQ, .OPC_SW_ACK, .OPC_SW_STATE:
                delegate?.LoconetSwitchRequestMessageReceived(message: LoconetSwitchRequestMessage(interfaceId:self.id, message: message))
                break
              case .OPC_SW_REP:
                if (message[2] & 0b01000000) != 0x00 {
                  delegate?.LoconetSensorMessageReceived(message: LoconetSensorMessage(interfaceId:self.id, message: message))
                }
                else {
                  delegate?.LoconetTurnoutOutputMessageReceived(message: LoconetTurnoutOutputMessage(interfaceId:self.id, message: message))
                }
                break
              case .OPC_INPUT_REP:
                delegate?.LoconetSensorMessageReceived(message: LoconetSensorMessage(interfaceId:self.id, message: message))
               break
              case .OPC_LONG_ACK:
                delegate?.LoconetLongAcknowledgeMessageReceived(message: LoconetLongAcknowledgeMessage(interfaceId:self.id, message: message))
                break
    /*          case .OPC_SLOT_STAT1:
                break
              case .OPC_CONSIST_FUNC:
                break
              case .OPC_UNLINK_SLOTS:
                break
              case .OPC_LINK_SLOTS:
                break
              case .OPC_MOVE_SLOTS:
                break
     */
              case .OPC_RQ_SL_DATA:
                delegate?.LoconetRequestSlotDataMessageReceived(message: LoconetRequestSlotDataMessage(interfaceId:self.id, message: message))
                break
                /*
              case .OPC_SW_ACK:
                break
              case .OPC_LOCO_ADR:
                break */
              case .OPC_SL_RD_DATA /*, .OPC_WR_SL_DATA */:
                delegate?.LoconetSlotDataMessageReceived(message: LoconetSlotDataMessage(interfaceId:self.id, message: message))
                break
              default:
                print("\(opCode)")
                break
              }
              
            }

          }
          
        }

      }

    }
    
  }

}
