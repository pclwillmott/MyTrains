//
//  LokProgrammerVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/08/2024.
//

import Foundation
import AppKit
import ORSSerial

class LokProgrammerVC : MyTrainsViewController, MTSerialPortDelegate, ORSSerialPortDelegate {
  
  func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
    
  }
  
  
  // MARK: Window & View Control
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewType = .lokProgrammerMonitor
  }
  
  override func windowWillClose(_ notification: Notification) {
    
    super.windowWillClose(notification)
    
    txPort?.close()
    
    rxPort?.close()
    
    commandPort?.close()
    
  }
  
  override func viewWillAppear() {
    
    super.viewWillAppear()
    
    txPort = ORSSerialPort(path: "/dev/cu.usbserial-FTDNXFY0")
    
    if let txPort {
      
      txPort.baudRate = 115200
      txPort.numberOfDataBits = 8
      txPort.numberOfStopBits = 1
      txPort.parity = .none
      txPort.usesRTSCTSFlowControl = false
      txPort.delegate = self
      txPort.open()
      
    }
    else {
      debugLog("TX Port failed to Open")
    }

    rxPort = ORSSerialPort(path: "/dev/cu.usbserial-FTDNZS1T")
    
    if let rxPort {
      
      rxPort.baudRate = 115200
      rxPort.numberOfDataBits = 8
      rxPort.numberOfStopBits = 1
      rxPort.parity = .none
      rxPort.usesRTSCTSFlowControl = false
      rxPort.delegate = self
      rxPort.open()
      
    }
    else {
      debugLog("RX Port failed to Open")
    }
    
    commandPort = ORSSerialPort(path: "/dev/cu.usbserial-A9BCNNZI")
    
    if let commandPort {
      
      commandPort.baudRate = 115200
      commandPort.numberOfDataBits = 8
      commandPort.numberOfStopBits = 1
      commandPort.parity = .none
      commandPort.usesRTSCTSFlowControl = false
      commandPort.rts = true
      commandPort.delegate = self
      commandPort.open()
      
    }
    else {
      debugLog("Command Port failed to Open")
    }
    
    txtView.font = NSFont(name: "Menlo", size: 12)

  }
  
  // MARK: Private Properties
  
  private var rxPort : ORSSerialPort?
  
  private var txPort : ORSSerialPort?
  
  private var commandPort : ORSSerialPort?
  
  // MARK: Outlets & Actions
  
  @IBOutlet var txtView: NSTextView!
 
  @IBAction func btnClearAction(_ sender: Any) {
    txtView.string = ""
  }
  
  @IBAction func btnCommandsAction(_ sender: Any) {
    
  }
  
  @IBOutlet weak var txtSend: NSTextField!
  
  @IBAction func btnSendAction(_ sender: Any) {
    
    let bits = txtSend.stringValue.split(separator: " ")
    
    var command : [UInt8] = []
    
    for bit in bits {
      if let byte = UInt8(hex: bit) {
        command.append(byte)
      }
    }
    
    if command.count != bits.count {
      return
    }
    
    command[3] = nextTag
    
    nextTag += 1
    
    if nextTag == 0x7f {
      nextTag = 0x00
    }
    
    lastCommand = LokPacket(packet: command)
    
    commandPort?.send(Data(lastCommand!.packetToSend))
    
  }
  
  private var nextTag : UInt8 = 0x00
  
  private var lastCommand : LokPacket?
  
  // MARK: MTSerialPortDelegate Methods
  
  private var buffer : [[UInt8]] = [[], []]
  
  func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
    
    if serialPort === commandPort {
      return
    }
    
    let port = serialPort == txPort ? 0 : 1
    
    buffer[port].append(contentsOf: data)
    
    scanBuffer(port: port)

  }
  
  public func serialPortDidClose(_ serialPort: MTSerialPort) {
  }
  
  public func serialPortDidDetach(_ serialPort: MTSerialPort) {
  }
  
  private func scanBuffer(port:Int) {

    var temp = ""
    for byte in buffer[1] {
      temp += byte.toHex(numberOfDigits: 2) + " "
    }
    print("port 2: \(buffer[1].count) \(temp)")

    var found = true
    
    while found && buffer[port].count >= 6 {
      
      var packet : [UInt8] = [0x7f, 0x7f]
      
      found = false
      
      while buffer[port].count > 1  {
        if buffer[port][0] == 0x7f && buffer[port][1] == 0x7f {
          found = true
          break
        }
        buffer[port].removeFirst()
      }
      
      if found {
        
        found = false
        
        var isEscape = false
        
        var index = 2
        
        while index < buffer[port].count {
          
          let byte = buffer[port][index]
          
          if isEscape {
            packet.append(byte)
            isEscape = false
          }
          else if byte == 0x80 {
            isEscape = true
          }
          else {
            
            packet.append(byte)
            
            if byte == 0x81 {
              found = true
              buffer[port].removeFirst(index + 1)
              packetReceived(packet: LokPacket(packet: packet))
              break
            }
            /*
            else if byte == 0x7f {
              found = true
              buffer[port].removeFirst(index)
              break
            }
            */
          }

          index += 1
          
        }

      }

    }
    
    temp = ""
    for byte in buffer[1] {
      temp += byte.toHex(numberOfDigits: 2) + " "
    }
    print("port 1: \(buffer[0].count) port 2: \(buffer[1].count) \(temp)")
    
  }
  
  private let preamble : [String] = [
    /*
    "7F 7F 01 6E 00 81",
    "7F 7F 01 6F 01 81",
    "7F 7F 01 70 02 00 81",
    "7F 7F 01 71 02 01 81",
    "7F 7F 01 72 02 02 81",
    "7F 7F 01 73 02 03 81",
    "7F 7F 01 74 02 04 81",
    "7F 7F 01 75 02 05 81",
    "7F 7F 01 76 02 06 81",
    "7F 7F 01 77 02 07 81",
    "7F 7F 01 78 02 08 81",
    */
    /*
    "7F 7F 01 79 00 81",
    "7F 7F 01 7A 10 02 00 20 19 81",
    
    "7F 7F 01 7B 34 0C 0C 64 64 00 00 81",
    "7F 7F 01 7C 16 02 81",
    
    "7F 7F 01 7D 34 0C 0C 64 64 64 00 81",
    "7F 7F 01 7E 16 00 81",
    "7F 7F 01 00 18 05 81",
    
    "7F 7F 01 01 34 14 14 14 0A 00 00 81",
    "7F 7F 01 02 16 02 81",
    
    "7F 7F 01 03 34 14 14 14 0A 04 00 81",
    
    "7F 7F 01 04 34 64 64 04 02 00 00 81",
    "7F 7F 01 05 16 02 81",
    "7F 7F 01 06 19 10 81",
    "7F 7F 01 07 16 00 81",
    "7F 7F 01 08 18 05 81",
    
    "7F 7F 01 09 2A 14 79 00 02 00 02 81",
    "7F 7F 01 0A 18 01 81",
    "7F 7F 01 0B 2B 14 79 05 81",
    
    "7F 7F 01 0C 34 64 64 04 02 00 00 81",
    "7F 7F 01 0D 16 02 81",
    "7F 7F 01 0E 19 18 81",
    "7F 7F 01 0F 16 00 81",
    "7F 7F 01 10 18 05 81",
    
    "7F 7F 01 11 2A 14 79 00 02 00 02 81",
    "7F 7F 01 12 18 01 81",
    "7F 7F 01 13 2B 14 79 05 81",
    
    "7F 7F 01 14 34 64 64 04 02 00 00 81",
    "7F 7F 01 15 16 02 81",
    "7F 7F 01 16 19 16 81",
    "7F 7F 01 17 16 00 81",
    "7F 7F 01 18 18 05 81",
    
    "7F 7F 01 19 2A 14 79 00 02 00 02 81",
    "7F 7F 01 1A 18 01 81",
    "7F 7F 01 1B 2B 14 79 05 81",
    
    "7F 7F 01 1C 34 64 64 04 02 00 00 81",
    "7F 7F 01 1D 16 02 81",
    "7F 7F 01 1E 19 1A 81",
    "7F 7F 01 1F 16 00 81",
    "7F 7F 01 20 18 05 81",
    
    "7F 7F 01 21 2A 14 79 00 02 00 02 81",
    "7F 7F 01 22 18 01 81",
    "7F 7F 01 23 2B 14 79 05 81",
    
    "7F 7F 01 24 34 64 64 04 02 00 00 81",
    "7F 7F 01 25 16 02 81",
    "7F 7F 01 26 19 14 81",
    "7F 7F 01 27 16 00 81",
    "7F 7F 01 28 18 05 81",
    
    "7F 7F 01 29 2A 14 79 00 02 00 02 81",
    "7F 7F 01 2A 18 01 81",
    "7F 7F 01 2B 2B 14 79 05 81",
    "7F 7F 01 2C 2A 14 79 01 02 00 03 81",
    "7F 7F 01 2D 18 01 81",
    "7F 7F 01 2E 2B 14 79 C8 81",
    "7F 7F 01 2F 2A 14 79 02 02 01 01 81",
    "7F 7F 01 30 18 01 81",
    "7F 7F 01 31 2B 14 79 C8 81",
    "7F 7F 01 32 2A 14 79 03 02 02 03 81",
    "7F 7F 01 33 18 01 81",
    "7F 7F 01 34 2B 14 79 C8 81",
    "7F 7F 01 35 2A 14 79 04 02 03 05 81",
    "7F 7F 01 36 18 01 81",
    "7F 7F 01 37 2B 14 79 C8 81",
    "7F 7F 01 38 2A 14 79 05 02 04 03 81",
    "7F 7F 01 39 18 01 81",
    "7F 7F 01 3A 2B 14 79 C8 81",
    "7F 7F 01 3B 2A 14 79 06 02 05 01 81",
    "7F 7F 01 3C 18 01 81",
    "7F 7F 01 3D 2B 14 79 C8 81",
    "7F 7F 01 3E 2A 14 79 07 02 06 03 81",
    "7F 7F 01 3F 18 01 81",
    "7F 7F 01 40 2B 14 79 C8 81",
    "7F 7F 01 41 2A 14 79 08 02 07 0D 81",
    "7F 7F 01 42 18 01 81",
    "7F 7F 01 43 2B 14 79 C8 81",
    "7F 7F 01 44 2A 14 79 09 02 08 03 81",
    "7F 7F 01 45 18 01 81",
    "7F 7F 01 46 2B 14 79 C8 81",
    "7F 7F 01 47 2A 14 79 0A 02 09 01 81",
    "7F 7F 01 48 18 01 81",
    "7F 7F 01 49 2B 14 79 C8 81",
    
    "7F 7F 01 4A 2A 14 79 01 08 09 81",
    "7F 7F 01 4B 18 4B 81",
    "7F 7F 01 4C 2B 14 79 C8 81",
    
    "7F 7F 01 4D 2A 14 79 01 04 00 00 E0 E5 81",
    "7F 7F 01 4E 18 4B 81",
    "7F 7F 01 4F 2B 14 79 C8 81",
    "7F 7F 01 50 10 00 00 00 00 81",
    "7F 7F 01 51 16 00 81",
    
    */
    
    "7F 7F 01 52 10 02 00 20 19 81",
    
    "7F 7F 01 53 34 0C 0C 64 64 64 00 81",
    "7F 7F 01 54 18 05 81",

    "7F 7F 01 55 34 14 14 14 0A 04 00 81",
    "7F 7F 01 56 18 05 81",

    "7F 7F 01 57 34 64 64 04 02 00 00 81",
    "7F 7F 01 58 16 02 81",
    "7F 7F 01 59 19 16 81",
    "7F 7F 01 5A 16 00 81",
    "7F 7F 01 5B 18 05 81",
    
    "7F 7F 01 5C 2A 14 79 02 04 00 00 E0 E6 81",
    "7F 7F 01 5D 18 4B 81",
    "7F 7F 01 5E 2B 14 79 C8 81",
    "7F 7F 01 5F 2A 14 79 03 04 E0 00 E0 07 81",
    "7F 7F 01 60 18 4B 81",
    "7F 7F 01 61 2B 14 79 C8 81",
    "7F 7F 01 62 2A 14 79 04 04 C0 01 E0 21 81",
    "7F 7F 01 63 18 4B 81",
    "7F 7F 01 64 2B 14 79 C8 81",
    "7F 7F 01 65 2A 14 79 05 04 A0 02 E0 43 81",
    "7F 7F 01 66 18 4B 81",
    "7F 7F 01 67 2B 14 79 C8 81",
    "7F 7F 01 68 2A 14 79 06 04 80 03 E0 61 81",
    "7F 7F 01 69 18 4B 81",
    "7F 7F 01 6A 2B 14 79 C8 81",
    "7F 7F 01 6B 2A 14 79 07 04 60 04 E0 87 81",
    "7F 7F 01 6C 18 4B 81",
    "7F 7F 01 6D 2B 14 79 C8 81",
    "7F 7F 01 6E 2A 14 79 08 04 40 05 E0 A9 81",
    "7F 7F 01 6F 18 4B 81",
    "7F 7F 01 70 2B 14 79 C8 81",
    "7F 7F 01 71 2A 14 79 09 04 20 06 E0 CB 81",
    "7F 7F 01 72 18 4B 81",
    "7F 7F 01 73 2B 14 79 C8 81",
    "7F 7F 01 74 2A 14 79 0A 04 00 07 E0 E9 81",
    "7F 7F 01 75 18 4B 81",
    "7F 7F 01 76 2B 14 79 C8 81",
    "7F 7F 01 77 2A 14 79 0B 04 E0 07 E0 08 81",
    "7F 7F 01 78 18 4B 81",
    "7F 7F 01 79 2B 14 79 C8 81",
    "7F 7F 01 7A 2A 14 79 0C 04 C0 08 E0 20 81",
    "7F 7F 01 7B 18 4B 81",
    "7F 7F 01 7C 2B 14 79 C8 81",
    "7F 7F 01 7D 2A 14 79 0D 04 A0 09 E0 40 81",
    "7F 7F 01 7E 18 4B 81",
    "7F 7F 01 00 2B 14 79 C8 81",

    "7F 7F 01 01 10 00 00 00 00 81",
  ]
  
  private var preambleStep = 0
  private var isSendingPreamble = false
  
  private func sendNextStep() {
    
    guard isSendingPreamble else {
      return
    }
    
    let bits = preamble[preambleStep].split(separator: " ")
    
    preambleStep += 1
    
    isSendingPreamble = preambleStep < preamble.count

    var command : [UInt8] = []
    
    for bit in bits {
      if let byte = UInt8(hex: bit) {
        command.append(byte)
      }
    }
    
    if command.count != bits.count {
      print("error")
      return
    }
    
    command[3] = nextTag
    
    nextTag += 1
    
    if nextTag == 0x7f {
      nextTag = 0x00
    }
    
    lastCommand = LokPacket(packet: command)
    
    if let commandPort {
      
//      repeat {
        
//      } while !commandPort.cts
      
      commandPort.send(Data(lastCommand!.packetToSend))
      
    }

  }
  
  @IBAction func btnPreambleAction(_ sender: Any) {
    
    preambleStep = 0
    
    isSendingPreamble = true
    
    sendNextStep()
    
  }
  
  private func packetReceived(packet:LokPacket) {
    
/*    if packet.isTX {
      print("    \"\(packet.hex)\",")
    }
 */
    if isSendingPreamble && packet.isRX  {
      sendNextStep()
    }
    
    var dump = "\(packet.isRX ? "RX: " : "TX: ") \(packet.hex)\n"

    dump += "\(packet.packetType)\n"
    
    if packet.isCarryingPayload {
      dump += "CheckSum: \(packet.isCheckSumOK) Count: \(packet.payload.count)\n"
    }

    // The following only works if this app sent the command
    
    if packet.isRX {
      
      if let lastCommand, lastCommand.sequenceNumber == packet.sequenceNumber {

        switch lastCommand.packetType {
        case .getLokProgrammerManufacturerCode:
          dump += "LokProgrammer Manufacturer Code: \(packet.dword!.toHex(numberOfDigits: 8))\n"
        case .getLokProgrammerProductId:
          dump += "LokProgrammer Product ID: \(packet.dword!.toHex(numberOfDigits: 8))\n"
        case .getLokProgrammerInfoA:
          dump += "LokProgrammer Info A: \(packet.dword!.toHex(numberOfDigits: 8))\n"
        case .getLokProgrammerInfoB:
          dump += "LokProgrammer Info B: \(packet.dword!.toHex(numberOfDigits: 8))\n"
        case .getLokProgrammerBootCodeVersion:
          dump += "LokProgrammer Boot Code Version: \(LokPacket.versionNumber(dword: packet.dword!))\n"
        case .getLokProgrammerBootCodeDate:
          dump += "LokProgrammer Boot Code Date: \(LokPacket.date(dword: packet.dword!))\n"
        case .getLokProgrammerACodeVersion:
          dump += "LokProgrammer A Code Version: \(LokPacket.versionNumber(dword: packet.dword!))\n"
        case .getLokProgrammerACodeDate:
          dump += "LokProgrammer A Code Date: \(LokPacket.date(dword: packet.dword!))\n"
        case .getLokProgrammerInfoC:
          dump += "LokProgrammer Info C: \(packet.dword!.toHex(numberOfDigits: 8))\n"
        default:
          break
        }
        
      }
      
      switch packet.packetType {
      case .lokProgrammerCommandError:
        dump += "Error Code: \(packet.errorCode!)\n"
      default:
        break
      }
      
    }
    
    txtView.string += dump
    
  }
  
}

public enum lokPacketType : CaseIterable {

  case unknown
  case ack
  case initRead
  case bufferData
  case readData
  case data
  case getLokProgrammerManufacturerCode
  case getLokProgrammerProductId
  case getLokProgrammerInfoA
  case getLokProgrammerInfoB
  case getLokProgrammerBootCodeVersion
  case getLokProgrammerBootCodeDate
  case getLokProgrammerACodeVersion
  case getLokProgrammerACodeDate
  case getLokProgrammerInfoC
  case dword
  case lokProgrammerCommandAccepted
  case lokProgrammerCommandError
  case lokProgrammerTidyUp
  case setLokProgrammerMode
  case lokProgrammerTestA
  case lokProgrammerTestB
}

public enum LokDataType : UInt8 {
  
  case manufacturerCode = 0
  case productId = 2
  case serialNumber = 3
  case productionDate = 4
  case productionInfo = 5
  case bootcodeVersion = 6
  case bootcodeDate = 7
  case firmwareVersion = 8
  case firmwareDate = 9
  case firmwareType = 10
  
}

public class LokPacket {
  
  init(packet:[UInt8]) {
    self.packet = packet
  }
  
  var packet : [UInt8]
  
  var _packetType : lokPacketType?
  
  public var packetType : lokPacketType {
    
    if _packetType == nil {
      
      switch packet[2] {
      // TX
      case 0x01:
        switch packet[4] {
        case 0x00: // 7F 7F 01 XX 00 81
          if packet.count == 6 {
            _packetType = .lokProgrammerTestA
          }
        case 0x01: // 7F 7F 01 XX 01 81
          if packet.count == 6 {
            _packetType = .lokProgrammerTestB
          }
        case 0x02:
          switch packet[5] {
          case 0x00: // 7F 7F 01 XX 02 00 81
            _packetType = .getLokProgrammerManufacturerCode
          case 0x01: // 7F 7F 01 XX 02 01 81
            _packetType = .getLokProgrammerProductId
          case 0x02: // 7F 7F 01 XX 02 02 81
            _packetType = .getLokProgrammerInfoA
          case 0x03: // 7F 7F 01 XX 02 03 81
            _packetType = .getLokProgrammerInfoB
          case 0x04: // 7F 7F 01 XX 02 04 81
            _packetType = .getLokProgrammerBootCodeVersion
          case 0x05: // 7F 7F 01 XX 02 05 81
            _packetType = .getLokProgrammerBootCodeDate
          case 0x06: // 7F 7F 01 XX 02 06 81
            _packetType = .getLokProgrammerACodeVersion
          case 0x07: // 7F 7F 01 XX 02 07 81
            _packetType = .getLokProgrammerACodeDate
          case 0x08: // 7F 7F 01 XX 02 08 81
            _packetType = .getLokProgrammerInfoC
          default:
            break
          }
        case 0x18:
          if packet.count == 7 {
            // 7F 7F 01 XX 18 4B 81
            if packet[5] == 0x4B {
              _packetType = .bufferData
            }
            else {
            }
          }
        case 0x2a:
          _packetType = .initRead
        case 0x2b:
          _packetType = .readData
        case 0x10:
          if packet.count == 10 {
            
            // 7F 7F 01 XX 10 00 00 00 00 81
            if packet[5] == 0 && packet[6] == 0 && packet[7] == 0 && packet[8] == 0 {
              _packetType = .lokProgrammerTidyUp
            }
            // 7F 7F 01 XX 10 02 00 20 19 81
            else if packet[5] == 0x02 && packet[6] == 0x00 && packet[7] == 0x20 && packet[8] == 0x19 {
              _packetType = .setLokProgrammerMode
            }
            
          }
          
        default:
          break
        }
      // RX
      case 0x02:
        switch packet[4] {
        case 0x01:
          // 7F 7F 02 XX 01 00 5C 00 01 00 81
          if packet[5] == 0x00 && packet.count == 11 {
            _packetType = .dword
          }
          else if packet.count == 7 {
            
            // 7F 7F 02 XX 01 00 81
            if packet[5] == 0 {
              _packetType = .lokProgrammerCommandAccepted
            }
            // 7F 7F 02 XX 01 04 81
            else {
              _packetType = .lokProgrammerCommandError
            }
          }
        case 0x07:
          if packet.count == 7 {
            _packetType = .ack
          }
          else if packet.count > 7 {
            _packetType = .data
          }
          else {
            debugLog("TX Packet 0x07 less than 7 bytes long. \(packet)")
          }
        default:
          break
        }
      default:
        break
      }
      
    }
    
    return _packetType ?? .unknown
    
  }
  
  public var ackStatus : UInt8? {
    if packetType == .ack {
      return packet[5]
    }
    return nil
  }
  
  public var sequenceNumber : UInt8 {
    return packet[3]
  }
  
  public var isCarryingPayload : Bool {
    return !payload.isEmpty
  }
  
  private var _payload : [UInt8]?
  
  public var payload : [UInt8] {
    
    if _payload == nil {
      
      var result : [UInt8] = []
      
      if packet.count > 9 {
        for index in 6 ... packet.count - 3 {
          result.append(packet[index])
        }
      }
      
      _payload = result
      
    }
    
    return _payload!
    
  }
  
  public var isTX : Bool {
    return packet[2] == 0x01
  }

  public var isRX : Bool {
    return packet[2] == 0x02
  }

  public var hex : String {
    var result = ""
    for byte in packet {
      if !result.isEmpty {
        result += " "
      }
      result += byte.toHex(numberOfDigits: 2)
    }
    return result
  }
  
  public var dword : UInt32? {
    guard packetType == .dword else {
      return nil
    }
    // 7F 7F 02 XX 01 00 86 00 01 00 81
    var result : UInt32 = 0
    for index in (6 ... 10).reversed() {
      result <<= 8
      result |= UInt32(packet[index])
    }
    return result
  }
  
  public var errorCode : UInt8? {
    switch packetType {
    // 7F 7F 02 XX 01 04 81
    case .lokProgrammerCommandAccepted, .lokProgrammerCommandError:
      return packet[5]
    default:
      return nil
    }
  }

  public var isCheckSumOK : Bool {
    
    guard let checkSum, let checkSumCalculated else {
      return false
    }
    
    return checkSum == checkSumCalculated
    
  }
  
  public var packetToSend : [UInt8] {
    
    var result : [UInt8] = [packet[0], packet[1]]
    
    for index in 2 ... packet.count - 2 {
      let byte = packet[index]
      if byte == 0x7f || byte == 0x80 || byte == 0x81 {
        result.append(0x80)
      }
      result.append(byte)
    }
    
    result.append(packet[packet.count - 1])
    
    if result != packet {
      var temp = ""
      for byte in packet {
        temp += byte.toHex(numberOfDigits: 2) + " "
      }
      print(temp)
      temp = ""
      for byte in result {
        temp += byte.toHex(numberOfDigits: 2) + " "
      }
      print(temp)
    }
    
    return result
    
  }
  
  public var checkSum : UInt8? {
    
    guard isCarryingPayload else {
      return nil
    }
    
    return packet[packet.count - 2]
    
  }
  
  public var checkSumCalculated : UInt8? {
    
    guard isCarryingPayload else {
      return nil
    }
    
    var checkSum = payload[0]
    
    for index in 1 ... payload.count - 1 {
      checkSum ^= payload[index]
    }
    
    return checkSum

  }
  
  public var dataType : LokDataType? {
    
    guard packetType == .readData else {
      return nil
    }
    
    return LokDataType(rawValue: packet[6])
    
  }
  
  // MARK: Public Class Methods
  
  public static func versionNumber(dword:UInt32) -> String {
    return "\(UInt8((dword >> 24) & 0xff)).\(UInt8((dword >> 16) & 0xff)).\(UInt16(dword & 0xffff))"
  }
  
  private static var dateFormatter = DateFormatter()
  
  public static func date(dword:UInt32) -> String {
    
    let date = Date(timeIntervalSince1970: 946684800.0 + Double(dword)) // 1-1-2000
    
    dateFormatter.calendar = NSCalendar(calendarIdentifier: .ISO8601)! as Calendar
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    dateFormatter.dateStyle = .long
    
    return dateFormatter.string(from: date)

  }
  
}
