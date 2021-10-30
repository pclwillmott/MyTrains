//
//  Loconet.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/10/2021.
//

import Foundation
import ORSSerial

public class Loconet : NSObject, ORSSerialPortDelegate {

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
  
  // ORSSerialPortDelegate Methods
  
  public func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
    self.serialPort = nil
  }
  
  public func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
    for x in data {
//      print(String(format: "%02X", x))
//      print(String(x, radix: 2))
      buffer[writePtr] = x
      writePtr += 1
      writePtr &= 0xff
      bufferCount += 1
    }
    decode()
  }
  
  private func decode() {
    
    // find the start of a message
    
    var ok : Bool = false
    
    while bufferCount > 0 {
      if ((buffer[readPtr] & 0x80) != 0) {
        ok = true
        break
      }
      readPtr += 1
      readPtr &= 0xff
      bufferCount -= 1
    }
    
    if ok {
      
//      Swift.print("ok: \(ok)")
      
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
        
        if bufferCount > 1 {
          length = buffer[readPtr+1]
        }
        else {
          length = 0xff
        }
        break
        
      }
      
//      Swift.print("length \(length)")
      
      if length < 0xff && bufferCount >= length {
        
        var message : [UInt8] = [UInt8](repeating: 0x00, count:Int(length))
        var index : Int = 0
        
        while index < length {
          message[index] = buffer[readPtr]
          readPtr += 1
          readPtr &= 0xff
          bufferCount -= 1
          index += 1
        }
        
        var loconetMessage = LoconetMessage(message: message)
        
        if loconetMessage.checkSumOK {
          let opCode = loconetMessage.opCode
          
          switch opCode {
          case .OPC_UNKNOWN:
            print("OPC_UNKNOWN \(String(format: "%02X", loconetMessage.opCodeRawValue))")
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
          case .OPC_SW_REQ:
            print("\(opCode) turnout address = \(loconetMessage.turnoutAddress) id = \(loconetMessage.turnoutId) state = \(loconetMessage.turnoutState)")
            break
          case .OPC_INPUT_REP, .OPC_SW_REP:
            print("\(opCode) address = \(loconetMessage.sensorAddress) id = \(loconetMessage.sensorId) state = \(loconetMessage.sensorState)")
           break
/*          case .OPC_LONG_ACK:
            break
          case .OPC_SLOT_STAT1:
            break
          case .OPC_CONSIST_FUNC:
            break
          case .OPC_UNLINK_SLOTS:
            break
          case .OPC_LINK_SLOTS:
            break
          case .OPC_MOVE_SLOTS:
            break */
          case .OPC_RQ_SL_DATA:
            print("\(opCode) slot = \(loconetMessage.slotNumber)")
            break /*
          case .OPC_SW_STATE:
            break
          case .OPC_SW_ACK:
            break
          case .OPC_LOCO_ADR:
            break
          case .OPC_SL_RD_DATA:
            break
          case .OPC_WR_SL_DATA:
            break */
          default:
            print("\(opCode)")
            break
          }
        }
        
      }
      
    }
    
  }

}
