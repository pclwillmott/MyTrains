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
}

public class LoconetMessenger : NSObject, ORSSerialPortDelegate {

  // Constructor
  
  init(path:String) {
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
          
          var done : Bool = true
          
          bufferLock.lock()
          var index : Int = 0
          while index < length {
            let cc = buffer[readPtr]
            if index > 0 && ((cc & 0x80) != 0x00) {
              done = false
              break
            }
            message[index] = cc
            readPtr = (readPtr + 1) & 0xff
            index += 1
            bufferCount -= 1
          }
          bufferLock.unlock()
          
          if done {
          
            let loconetMessage = LoconetMessage(message: message)
            
            if loconetMessage.checkSumOK {
              
              let opCode = loconetMessage.opCode
              
              switch opCode {
              case .OPC_UNKNOWN:
                print("OPC_UNKNOWN \(String(format: "%02X", loconetMessage.opCodeRawValue))\n")
                break
    /*          case .OPC_BUSY:
                break
              case .OPC_GPOFF:
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
                delegate?.LoconetSwitchRequestMessageReceived(message: LoconetSwitchRequestMessage(message: message))
                break
              case .OPC_SW_REP:
                if (message[2] & 0b01000000) != 0x00 {
                  delegate?.LoconetSensorMessageReceived(message: LoconetSensorMessage(message: message))
                }
                else {
                  delegate?.LoconetTurnoutOutputMessageReceived(message: LoconetTurnoutOutputMessage(message: message))
                }
                break
              case .OPC_INPUT_REP:
                delegate?.LoconetSensorMessageReceived(message: LoconetSensorMessage(message: message))
               break
              case .OPC_LONG_ACK:
                delegate?.LoconetLongAcknowledgeMessageReceived(message: LoconetLongAcknowledgeMessage(message: message))
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
              case .OPC_RQ_SL_DATA:
                break
              case .OPC_SW_ACK:
                break
              case .OPC_LOCO_ADR:
                break */
              case .OPC_SL_RD_DATA, .OPC_WR_SL_DATA:
                delegate?.LoconetSlotDataMessageReceived(message: LoconetSlotDataMessage(message: message))
                break
              default:
                print("\(opCode)")
                break
              }
              
            }

          }
          
        }
        else {
          doAgain = false
        }

      }
      
    }
    
  }

}
