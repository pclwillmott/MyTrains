//
//  LokProgrammerVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/08/2024.
//

import Foundation
import AppKit
import ORSSerial
import SGDCC
import SGProgrammerCore

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
  
  var decoder : Decoder?
  
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
    
    //

//    commandPort = ORSSerialPort(path: "/dev/cu.usbserial-A9BCNNZI") // LokProgrammer
    commandPort = ORSSerialPort(path: "/dev/cu.usbserial-A506ARJW") // USB Adaptee

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
    
//    let string = "AD 96 C1 72 D3 30 10 86 EF CC F0 0E 3B 3E 95 43 63 CB 4E 9B D0 71 D2 49 E2 52 A0 F5 24 93 10 3A C3 4D C4 4A ED 41 96 52 4B 72 DA 3E 0F 6F C1 81 03 0F C4 2B 20 B9 29 03 43 A8 65 C3 31 8E B4 FF 97 CD FE FF FA FB 97 AF E1 E9 6D 4E A1 24 85 C8 38 1B 38 A8 E3 39 40 D8 8A 27 19 BB 1E 38 4A AE 0F FB CE E9 F0 F9 B3 30 27 12 83 3E CB C4 C0 49 A5 DC 9C B8 EE 76 BB ED 10 A1 3A 44 B9 BE 87 3C F7 72 7A 31 9B 4F CF E7 A3 38 3E 9B BB B1 BE 90 60 89 1D 7D 1B 20 14 5C B1 44 50 2E 21 4B 06 8E F7 F0 54 3F 4F 88 58 15 D9 46 6A 79 53 FE 84 62 23 9C 10 67 F8 1E 79 1E 1C 1C 75 BB 81 FF 22 74 7F 39 F7 F4 55 C2 9C E1 E2 2A 02 E4 23 88 17 30 9A 80 66 3B 42 01 94 3E FC 59 26 74 7F 82 ED E3 44 35 9C 46 6C A4 24 87 39 CE 74 1B 83 C6 02 BE 45 23 52 5E 30 F0 5B B6 E0 B5 B9 3C C7 2C E1 39 CC 28 BE C3 1F 29 69 4C 19 D8 52 A2 FF 40 F9 8E 73 29 1A 23 1E 5B FC 53 46 6D A9 87 5B 6D 5A F4 A0 67 D1 83 AA B4 76 4E 8B 2E 4C 2A 2A 58 6E 1A 83 BD B4 00 BB D4 4E 38 D6 26 85 19 C9 D6 04 CC 17 2D 18 CF 15 2E 12 01 57 69 26 A4 66 2D 7B 80 BC 3E 4C 19 BD 6B 6E AC BA 04 A8 34 CD 69 0F 21 18 17 F8 13 01 04 55 8D E6 5A 36 26 AB 24 5A F4 E4 0D 93 84 D2 6C 87 18 41 D9 6D CE D7 B5 E0 BB 50 45 49 D8 8D CA 88 14 AB 94 B0 16 A8 AF CC 47 02 E2 46 11 AC C3 6A 4F A2 D4 81 D6 79 C0 28 9D CD E0 76 5F 0E D4 D5 EE DB D6 6E C1 6D 63 91 DD 70 8F D5 FD 3D 29 DA C4 98 B6 C2 AE 86 0B 51 51 FE B5 52 DD 46 B0 D9 8D BF C1 3E 91 EB 56 E1 3B CA 0A 5D 29 A3 89 4E 1F D0 2D 6E 31 C2 BE 8D C5 96 0B 88 32 F3 AA A1 67 50 12 9C C3 21 BC E5 29 13 FA E0 18 17 70 D0 0B BA A8 D7 76 D5 47 FA 47 4C D2 6A C0 5B 4C B6 5F B7 E1 1E A5 A2 78 09 11 E7 05 2C 28 CE 9B EF D1 BA F7 09 D3 A6 0F 6A 8D 29 15 D7 A4 F8 F6 59 19 AF 37 EC C8 6E 8D 3E 28 37 47 B4 0B 4B 92 8B 7F 49 A3 2A D8 83 00 62 45 E5 63 76 56 1C 50 1E D5 21 87 AE 79 17 1D FE 00 83 E4 19 9E BD 0A"
    
/*    let bits = string.split(separator: " ")
    
    var result = ""
    for bit in bits {
      if let byte = UInt8(bit, radix: 16) {
        if let str = String(bytes: [byte], encoding: .utf8), let char = str.first {
          if char.isLetter || char.isNumber || char.isPunctuation {
            result += "\(char)"
          }
        }
      }
    }
    print(result)
*/
    
    
    DecoderType.populate(comboBox: cboDecoder)
    
    DecoderEditorLoadType.populate(comboBox: cboBlock)
    cboBlock.removeItem(at: 0)
    cboBlock.selectItem(at: 0)

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
    
  }
  
  private let preamble : [String] = [
    
    // LOKPROGRAMMER INFO
    
   
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
    
    
    // DECODER INFO
  
    
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
    
    // READING CVs
    
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
     /*
    "7F 7F 01 7B 2A 14 79 01 09 00 00 08 81",
    "7F 7F 01 7C 18 4B 81",
    "7F 7F 01 7D 2B 14 79 C8 81",
    
    "7F 7F 01 7E 2A 14 79 01 09 12 03 19 81",
    "7F 7F 01 00 18 4B 81",
    "7F 7F 01 01 2B 14 79 C8 81",
    */
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
    
    if let commandPort, let lastCommand {
      
      if lastCommand.packet[4] == 0x2a {
        last2A = lastCommand
      }
      
      commandPort.send(Data(lastCommand.packetToSend))
      
    }

  }
  
  private var last2A : LokPacket?
  private var last18 : LokPacket?
  
  @IBAction func btnPreambleAction(_ sender: Any) {
    
    preambleStep = 0
    
    isSendingPreamble = true
    
    sendNextStep()
    
  }
  
  @IBOutlet weak var txtSequence: NSTextField!
  
  @IBOutlet weak var txtAddress: NSTextField!
  
  @IBOutlet weak var txtCount: NSTextField!
  
  public func sendPacket(packet:[UInt8]) {
    
    var command = packet
    
    command[3] = nextTag
    
    nextTag += 1
    
    if nextTag == 0x7f {
      nextTag = 0x00
    }
    
    lastCommand = LokPacket(packet: command)
    
    if let commandPort, let lastCommand {
      
      if lastCommand.packet[4] == 0x2a {
        last2A = lastCommand
      }
      
      commandPort.send(Data(lastCommand.packetToSend))
      
    }

  }
  
  @IBAction func btnReadAction(_ sender: Any) {
    
    if let sequence = UInt8(hex: txtSequence.stringValue), let address = UInt16(hex: txtAddress.stringValue), let count = UInt8(hex: txtCount.stringValue) {
      // 7F 7F 01 2E 2A 14 79 02 04 E0 00 E0 06 81
      var packet : [UInt8] = [0x7f, 0x7f, 0x01, 0x00, 0x2a, 0x14, 0x79, sequence, 0x04, UInt8(address & 0xff), UInt8(address >> 8), count]
      var crc = packet[7]
      for index in 8 ... packet.count - 1 {
        crc ^= packet[index]
      }
      packet.append(crc)
      packet.append(0x81)
      
      sendPacket(packet: packet)
      
      sendPacket(packet: [0x7F, 0x7F, 0x01, 0x25, 0x18, 0x4B, 0x81])
      sendPacket(packet: [0x7F, 0x7F, 0x01, 0x26, 0x2B, 0x14, 0x79, 0xC8, 0x81])

    }
        
        
  }
  
  private func packetReceived(packet:LokPacket) {
    // \(packet.isRX ? "RX: " : "TX: ")
    
    var dump = ""
    
    if prettyPrint {
      let bits = packet.hex.split(separator: " ")
      var count = 0
      for bit in bits {
        if count == 16 {
          dump += "\n"
          count = 0
        }
        dump += "\(bit) "
        count += 1
      }
      dump += "(\(packet.packetType.title))\n"
    }
    else {
      dump = "\(packet.hex) (\(packet.packetType.title))\n"
    }
    
    if packet.isCarryingPayload, let isCheckSumOK = packet.isCheckSumOK {
      dump += "CheckSum: \(isCheckSumOK ? "OK" : "Fail") Count: \(packet.payload.count)\n"
    }

    // The following only works if this app sent the command
    
    if packet.isRX {
      
      if let lastCommand, lastCommand.sequenceNumber == packet.sequenceNumber {

        if packet.dword != nil {
          
          switch lastCommand.packetType {
          case .getLokProgrammerManufacturerCode:
            dump += "LokProgrammer Manufacturer Code: \(packet.dword!.hex(numberOfBytes: 4)!)\n"
          case .getLokProgrammerProductId:
            dump += "LokProgrammer Product ID: \(packet.dword!.hex(numberOfBytes: 4)!)\n"
          case .getLokProgrammerInfoA:
            dump += "LokProgrammer Info A: \(packet.dword!.hex(numberOfBytes: 4)!)\n"
          case .getLokProgrammerInfoB:
            dump += "LokProgrammer Info B: \(packet.dword!.hex(numberOfBytes: 4)!)\n"
          case .getLokProgrammerBootCodeVersion:
            dump += "LokProgrammer Boot Code Version: \(LokPacket.versionNumber(dword: packet.dword!))\n"
          case .getLokProgrammerBootCodeDate:
            dump += "LokProgrammer Boot Code Date: \(LokPacket.date(dword: packet.dword!))\n"
          case .getLokProgrammerACodeVersion:
            dump += "LokProgrammer A Code Version: \(LokPacket.versionNumber(dword: packet.dword!))\n"
          case .getLokProgrammerACodeDate:
            dump += "LokProgrammer A Code Date: \(LokPacket.date(dword: packet.dword!))\n"
          case .getLokProgrammerInfoC:
            dump += "LokProgrammer Info C: \(packet.dword!.hex(numberOfBytes: 4)!)\n"
          case .readData:
            
            if let last2A {
              
              switch last2A.packetType {
              case .initReadForDecoderProductId:
                dump += "Decoder Product ID: \(packet.dword!.hex(numberOfBytes: 4)!)\n"
                if let dword = packet.dword, let decoderType = DecoderType.esuProductIdLookup[dword] {
                  dump += "Decoder Type: \(decoderType.title)\n"
                }
              case .initReadForDecoderManufacturerCode:
                dump += "Decoder Manufacturer Code: \(packet.dword!.hex(numberOfBytes: 4)!)\n"
              case .initReadForDecoderProductionInfo:
                dump += "Decoder Production Info: \(packet.dword!.hex(numberOfBytes: 4)!)\n"
              case .initReadForDecoderSerialNumber:
                dump += "Decoder Serial Number: \(packet.dword!.hex(numberOfBytes: 4)!)\n"
              case .initReadForDecoderBootcodeVersion:
                dump += "Decoder Bootcode Version: \(LokPacket.versionNumber(dword: packet.dword!))\n"
              case .initReadForDecoderFirmwareVersion:
                dump += "Decoder Firmware Version: \(LokPacket.versionNumber(dword: packet.dword!))\n"
              case .initReadForDecoderProductionDate:
                dump += "Decoder Production Date: \(LokPacket.date(dword: packet.dword!))\n"
              case .initReadForDecoderBootcodeDate:
                dump += "Decoder Bootcode Date: \(LokPacket.date(dword: packet.dword!))\n"
              case .initReadForDecoderFirmwareDate:
                dump += "Decoder Firmware Date: \(LokPacket.date(dword: packet.dword!))\n"
              case .initReadForDecoderFirmwareType:
                dump += "Decoder Firmware Type: \(packet.dword!)\n"
              default:
                break
              }
            }
            
          default:
            break
          }
        }
        else if let last2A, lastCommand.packetType == .readData, let address = last2A.address, let ok = packet.isCheckSumOK, ok {
          for index in 0 ... packet.payload.count - 3 {
            cvs[Int(address) + index] = packet.payload[index + 2]
          }
          if address == 0x9a0 {
            for index : UInt16 in 0 ... UInt16(cvs.count) - 1 {
              print("\(index.hex(numberOfBytes: 2)!): \(cvs[Int(index)])")
            }
          }
        }
      }
      
      switch packet.packetType {
      case .lokProgrammerCommandError:
        dump += "Error Code: \(packet.errorCode!)\n"
      default:
        break
      }
      
    }
    
    if packet.isTX {
      
      switch packet.packetType {
      case .initReadDataBlock:
        if let sequenceNumber = packet.sequenceNumberForRead, let address = packet.address, let count = packet.numberOfBytesToRead {
          dump += "Sequence number: \(sequenceNumber.hex()) Address: \(address.hex(numberOfBytes: 2)!) Number of bytes: \(count)\n"
        }
      case .initWriteDataBlock:
        if let address = packet.address {
          dump += "Address: \(address.hex(numberOfBytes: 2)!) Number of bytes: \(packet.payload.count)\n"
        }
      case .sendServiceModePacket:
        if let dccPacket = packet.dccPacket(decoderMode: .serviceModeDirectMode) {
          var extra = ""
          if let cvNumber = dccPacket.cvNumber {
            extra = "CV\(cvNumber)"
            if let bitNumber = dccPacket.cvBitNumber {
              extra += " d\(bitNumber)"
              if let cvBitValue = dccPacket.cvBitValue {
                extra += " value: \(cvBitValue)"
              }
            }
            else if let cvValue = dccPacket.cvValue {
              extra += " value: \(cvValue)"
            }
          }
          dump += "\(dccPacket.packetType.title) \(extra)\n"
        }
      case .sendOperationsModePacket:
        if let dccPacket = packet.dccPacket(decoderMode: .operationsMode) {
          dump += "\(dccPacket.packetType)\n"
        }
      default:
        break
      }
      
    }
    
    txtView.string += dump + "\n"
 
    if isSendingPreamble && packet.isRX  {
      sendNextStep()
    }
    
//    print(dump)
    
    // ****** THIS IS THE LokProgrammer EMULATOR ******
    
    if !prettyPrint && packet.isTX {
      
      switch packet.packetType {
      case .lokProgrammerTestA:
        sendResponse(original: packet, response: "7F 7F 02 00 01 00 81")
      case .lokProgrammerTestB:
        count16A = 0
        countReadData = 0
        cvbufferThisWrite = [UInt8](repeating: 0x0, count: 2688)
        sendResponse(original: packet, response: "7F 7F 02 00 01 00 81")
      case .getLokProgrammerManufacturerCode:
        sendResponse(original: packet, response: "7F 7F 02 03 01 00 97 00 00 00 81")
      case .getLokProgrammerProductId:
        sendResponse(original: packet, response: "7F 7F 02 04 01 00 57 00 00 01 81")
      case .getLokProgrammerInfoA:
        sendResponse(original: packet, response: "7F 7F 02 05 01 00 FF FF FF FF 81")
      case .getLokProgrammerInfoB:
        sendResponse(original: packet, response: "7F 7F 02 06 01 00 FF FF FF FF 81")
      case .getLokProgrammerBootCodeVersion:
        sendResponse(original: packet, response: "7F 7F 02 07 01 00 5C 00 01 00 81")
      case .getLokProgrammerBootCodeDate:
        sendResponse(original: packet, response: "7F 7F 02 08 01 00 9B 3A E7 18 81")
      case .getLokProgrammerACodeVersion:
        sendResponse(original: packet, response: "7F 7F 02 09 01 00 86 00 01 00 81")
      case .getLokProgrammerACodeDate:
        sendResponse(original: packet, response: "7F 7F 02 0A 01 00 F8 0C 48 20 81")
      case .getLokProgrammerInfoC:
        sendResponse(original: packet, response: "7F 7F 02 0B 01 00 00 00 00 00 81")
      case .setLokProgrammerMode:
        sendResponse(original: packet, response: "7F 7F 02 0D 01 00 81")
      case .TX34_A:
        sendResponse(original: packet, response: "7F 7F 02 0E 01 00 81")
      case .TX34_B:
        sendResponse(original: packet, response: "7F 7F 02 10 07 00 81")
      case .TX34_C:
        sendResponse(original: packet, response: "7F 7F 02 10 07 00 81")
      case .TX34_D:
        sendResponse(original: packet, response: "7F 7F 02 10 07 00 81")
      case .TX34_E:
        sendResponse(original: packet, response: "7F 7F 02 10 07 00 81")
      case .TX34_F:
        // 7F 7F 02 XX 01 00 81
        sendResponse(original: packet, response: "7F 7F 02 0E 01 00 81") // THIS IS NOT CORRECT
      case .TX16_A:
        switch count16A {
        case 0:
          sendResponse(original: packet, response: "7F 7F 02 0F 03 00 81")
        default:
          sendResponse(original: packet, response: "7F 7F 02 11 07 00 81")
        }
        count16A += 1
      case .TX16_B:
        sendResponse(original: packet, response: "7F 7F 02 11 07 00 81")
      case .TX19_A:
        sendResponse(original: packet, response: "7F 7F 02 18 07 00 81")
      case .lokProgrammerTidyUp:
        sendResponse(original: packet, response: "7F 7F 02 6F 01 00 81")
        
        for index in 0 ..< cvbufferThisWrite.count {
          if cvbufferLastWrite[index] != cvbufferThisWrite[index] {
            print("address: \(UInt64(index).dotHex(numberOfBytes: 4)!) \(cvbufferLastWrite[index].hex()) to  \(cvbufferThisWrite[index].hex())")
          }
        }
        
        cvbufferLastWrite = cvbufferThisWrite
        
      case .bufferDataBlock, .bufferDataDWord, .TX18_A:
        sendResponse(original: packet, response: "7F 7F 02 1A 07 00 81")
      case .initWriteDataBlock:         
        nextDataRead = "7F 7F 02 3A 07 00 01 00 01 81"
        if let address = packet.address {
          for index in 0 ..< packet.payload.count {
            cvbufferThisWrite[Int(address) + index] = packet.payload[index]
          }
        }
        sendResponse(original: packet, response: "7F 7F 02 1A 07 00 81")
      case .initReadForDecoderManufacturerCode:
        switch countReadData {
        case 0, 2:
          nextDataRead = "7F 7F 02 1D 07 00 00 7F 81"
        case 1:
          nextDataRead = "7F 7F 02 25 07 00 00 00 97 00 7F 81"
        case 5:
          nextDataRead = "7F 7F 02 45 07 00 7F 81"
        case 7:
          nextDataRead = "7F 7F 02 50 07 00 01 00 97 00 00 00 96 81"
        default:
          nextDataRead = "7F 7F 02 35 07 00 00 00 97 00 00 00 97 81"
        }
        sendResponse(original: packet, response: "7F 7F 02 1A 07 00 81")
        countReadData += 1
      case .initReadForDecoderProductId:
        nextDataRead = "7F 7F 02 53 07 00 02 00 96 00 00 02 96 81"
        nextDataRead = readDecoderInfoResponse(initPacket: packet)
        sendResponse(original: packet, response: "7F 7F 02 1A 07 00 81")
      case .initReadForDecoderSerialNumber:
        nextDataRead = "7F 7F 02 56 07 00 03 00 87 29 F8 F9 AC 81"
        sendResponse(original: packet, response: "7F 7F 02 1A 07 00 81")
      case .initReadForDecoderProductionDate:
        nextDataRead = "7F 7F 02 59 07 00 04 00 D5 2C E7 27 3D 81"
        sendResponse(original: packet, response: "7F 7F 02 1A 07 00 81")
      case .initReadForDecoderProductionInfo:
        nextDataRead = "7F 7F 02 5C 07 00 05 00 FF FF FF FF 05 81"
        nextDataRead = readDecoderInfoResponse(initPacket: packet)
        sendResponse(original: packet, response: "7F 7F 02 1A 07 00 81")
      case .initReadForDecoderBootcodeVersion:
        nextDataRead = "7F 7F 02 5F 07 00 06 00 05 00 00 05 06 81"
        sendResponse(original: packet, response: "7F 7F 02 1A 07 00 81")
      case .initReadForDecoderBootcodeDate:
        nextDataRead = "7F 7F 02 62 07 00 07 00 BA 4D 03 22 D1 81"
        sendResponse(original: packet, response: "7F 7F 02 1A 07 00 81")
      case .initReadForDecoderFirmwareVersion:
        nextDataRead = "7F 7F 02 65 07 00 08 00 A6 00 0A 05 A1 81"
        nextDataRead = readDecoderInfoResponse(initPacket: packet)
        sendResponse(original: packet, response: "7F 7F 02 1A 07 00 81")
      case .initReadForDecoderFirmwareDate:
        nextDataRead = "7F 7F 02 68 07 00 09 00 23 7B C2 2D BE 81"
        sendResponse(original: packet, response: "7F 7F 02 1A 07 00 81")
      case .initReadForDecoderFirmwareType:
        nextDataRead = "7F 7F 02 6B 07 00 0A 00 3F 00 00 00 35 81"
        nextDataRead = readDecoderInfoResponse(initPacket: packet)
        sendResponse(original: packet, response: "7F 7F 02 1A 07 00 81")
      case .initRead:
        nextDataRead = "7F 7F 02 6E 07 00 01 00 EF 40 18 B6 81"
        sendResponse(original: packet, response: "7F 7F 02 1A 07 00 81")
      case .readData:
        sendResponse(original: packet, response: nextDataRead)
      case .initReadDataBlock:
        nextDataRead = dataBlockResponse(initPacket: packet)
/*
        switch packet.address {
        case 0x0000:
          nextDataRead = "7F 7F 02 51 07 00 01 00 0E 07 00 00 96 00 FF 97 28 00 00 00 01 01 00 00 D3 A1 00 00 00 00 00 00 00 00 00 83 1A 00 00 FC 00 00 00 00 00 00 00 00 00 00 00 00 00 00 07 00 01 02 0A 0A 8C 30 0A FF 1E 14 00 00 00 00 60 0C 06 00 01 09 12 1C 25 2F 38 42 4B 56 5E 67 71 7A 84 8D 97 A0 AB B3 BC C6 CF D9 E2 EC F5 FF 00 00 00 00 00 00 40 0C 60 FF 00 00 00 00 00 00 00 2B 28 5C 5C 32 96 0F 14 00 00 00 64 34 55 82 5A 82 0F 05 40 4F 00 1E 03 00 00 80 80 00 00 00 00 96 00 00 00 00 00 2A 55 7F AA D4 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 40 28 28 00 7E 7E 00 00 00 00 00 00 00 00 00 00 00 10 10 00 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 71 81"
          nextDataRead = dataBlockResponse(initPacket: packet)
        case 0x00e0:
          nextDataRead = "7F 7F 02 54 07 00 02 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 F4 7A 00 00 00 00 00 00 00 00 14 00 00 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00 00 00 18 00 00 00 00 00 00 00 00 00 02 00 00 00 00 00 00 00 00 00 40 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 00 00 00 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 04 00 00 00 00 04 00 00 00 00 00 00 00 00 00 00 00 00 00 00 08 00 00 00 00 10 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 80 00 40 40 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 10 00 00 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 80 00 00 00 00 00 04 00 00 00 00 00 00 00 00 00 00 00 00 00 40 00 00 00 00 00 10 00 00 00 00 00 00 00 00 00 9F 81"
          nextDataRead = dataBlockResponse(initPacket: packet)
        case 0x01c0:
          nextDataRead = "7F 7F 02 57 07 00 03 00 00 04 00 00 00 04 00 00 40 00 40 00 00 00 00 00 00 00 00 00 00 00 00 00 00 40 00 00 40 00 00 01 00 00 00 00 00 00 00 00 00 00 00 00 02 00 00 00 00 00 00 04 00 00 00 00 00 00 00 00 00 00 00 00 00 02 00 00 00 00 00 10 00 00 00 00 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00 40 00 00 00 00 00 00 04 00 00 00 00 00 00 00 00 00 00 00 00 00 01 00 00 00 00 00 08 00 00 00 00 00 00 00 00 00 00 00 00 00 04 00 00 00 00 00 00 00 00 40 00 00 00 00 00 00 06 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0A 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 05 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 09 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 1E 81"
          nextDataRead = dataBlockResponse(initPacket: packet)
        case 0x02a0:
          nextDataRead = "7F 7F 02 5A 07 00 04 00 00 00 00 00 00 00 00 00 00 00 00 00 40 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 10 00 00 00 00 00 00 00 00 00 80 00 00 00 00 00 00 00 00 00 40 00 00 00 00 00 10 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 00 00 00 00 20 00 00 00 00 00 00 00 00 00 00 00 00 00 00 04 00 00 00 00 40 00 00 00 00 00 00 00 00 00 00 00 00 00 00 10 00 00 00 00 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 40 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 04 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 10 00 00 00 00 00 00 00 00 00 00 00 00 00 25 81"
          nextDataRead = dataBlockResponse(initPacket: packet)
        case 0x0380:
          nextDataRead = "7F 7F 02 5D 07 00 05 00 00 00 00 00 00 00 40 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 04 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00 00 00 00 80 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 44 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 40 00 48 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 40 00 40 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 10 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 9D 81"
          nextDataRead = dataBlockResponse(initPacket: packet)
        case 0x0460:
          nextDataRead = "7F 7F 02 60 07 00 06 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 06 81"
          nextDataRead = dataBlockResponse(initPacket: packet)
        case 0x0540:
          nextDataRead = "7F 7F 02 63 07 00 07 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 07 81"
          nextDataRead = dataBlockResponse(initPacket: packet)
        case 0x0620:
          nextDataRead = "7F 7F 02 66 07 00 08 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 00 00 0F 00 00 00 01 00 00 0F 00 00 00 01 00 00 0F 00 00 00 01 00 00 0F 00 00 00 01 00 00 0F 00 00 00 01 00 00 0F 00 00 00 01 00 00 0F 00 00 00 01 00 00 0F 00 00 00 01 00 00 0F 00 00 00 01 00 00 1F 00 00 00 1F 00 00 1F 00 00 00 01 00 00 1F 00 00 00 01 00 00 1F 00 00 1F 01 00 00 1F 00 19 81"
          nextDataRead = dataBlockResponse(initPacket: packet)
        case 0x0700:
          nextDataRead = "7F 7F 02 69 07 00 09 00 00 1F 01 00 00 1F 00 00 00 01 00 00 1F 00 00 00 01 00 00 1F 00 00 1F 01 00 00 1F 00 00 1F 01 00 00 1F 00 00 1F 01 00 00 1F 00 00 1F 00 00 00 1F 00 00 00 00 00 00 1F 00 00 00 00 00 00 1F 00 00 00 00 00 00 1F 00 00 00 80 00 80 E0 00 60 00 10 CD 00 80 01 80 80 00 80 01 80 80 00 80 01 80 80 00 80 01 80 80 00 80 01 80 80 00 80 01 80 80 00 80 01 80 80 00 60 01 80 80 00 40 01 80 80 00 80 00 80 80 00 50 01 80 80 00 80 00 80 80 00 60 01 80 80 00 80 00 80 80 00 80 00 80 80 00 60 00 80 80 00 60 01 80 80 00 80 01 80 80 00 80 01 80 80 00 80 00 40 FF 00 40 00 80 80 00 40 00 80 80 00 80 00 80 80 00 80 00 80 80 00 80 00 80 80 00 80 00 80 80 00 80 00 80 80 00 80 00 80 80 00 80 00 64 81"
          nextDataRead = dataBlockResponse(initPacket: packet)
        case 0x07e0:
          nextDataRead = "7F 7F 02 6C 07 00 0A 00 80 80 00 80 00 80 80 00 20 00 80 80 00 80 00 80 80 00 FE 28 3C 01 02 00 28 3C 01 02 00 28 3C 01 02 00 28 3C 01 02 00 28 3C 01 02 00 28 3C 01 02 00 28 3C 01 02 00 28 3C 01 02 00 00 01 00 02 00 04 00 08 00 10 00 20 00 40 00 80 00 00 01 00 02 00 04 00 08 00 10 00 20 00 40 00 80 41 00 00 01 53 57 44 20 43 6C 61 73 73 20 31 32 31 20 42 55 54 20 4C 65 79 6C 61 6E 64 00 00 00 00 00 03 40 06 C0 10 C0 10 40 46 40 07 40 1E 40 1E 40 17 40 26 40 1F 40 22 60 4D 20 02 20 02 20 0B C0 06 20 02 20 02 20 01 20 01 20 01 20 01 20 01 20 01 20 01 20 01 20 01 20 01 00 01 20 01 00 01 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 54 81"
          nextDataRead = dataBlockResponse(initPacket: packet)
        case 0x08c0:
          nextDataRead = "7F 7F 02 6F 07 00 0B 00 00 03 03 00 07 07 00 87 25 00 87 25 00 07 07 00 08 08 00 07 07 05 07 07 05 07 07 01 07 07 2B 07 07 06 07 07 08 02 02 00 06 06 00 06 06 00 06 20 00 87 07 00 06 06 00 06 06 00 01 01 00 01 01 00 01 01 00 01 01 00 01 01 00 01 01 00 01 01 00 01 01 00 01 01 00 01 01 00 00 00 00 01 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 89 81"
          nextDataRead = dataBlockResponse(initPacket: packet)
        case 0x09a0:
          nextDataRead = "7F 7F 02 72 07 00 0C 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00 00 00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 0C 81"
          nextDataRead = dataBlockResponse(initPacket: packet)
        default:
          nextDataRead = ""
        }
 */
        sendResponse(original: packet, response: "7F 7F 02 1A 07 00 81")
      default:
   //     print("UNKNOWN: \(packet.hex)")
        sendResponse(original: packet, response: "7F 7F 02 1A 07 00 81")
      }
      
    }
    
  }
  
  private var prettyPrint = false
  
  private func readDecoderInfoResponse(initPacket:LokPacket) -> String {

    guard let sequenceNumberForRead = initPacket.sequenceNumberForRead, let decoder else {
      return ""
    }
    
    var packet : [UInt8] = [0x7f, 0x7f, 0x02, initPacket.sequenceNumber, 0x07, 0x00, sequenceNumberForRead, 0x00]

    var data : [UInt8] = []
    
    switch initPacket.packetType {
    case .initReadForDecoderProductId:
      data = decoder.esuProductIds[0].bigEndianData.reversed()
//    case .initReadForDecoderBootcodeDate:
//    case .initReadForDecoderFirmwareDate:
    case .initReadForDecoderFirmwareType:
  //    let value = UInt8(txtSequence.stringValue)! // 0x3F
      data = [0x3f, 0, 0, 0] // 0 for LokSound3.5
//    case .initReadForDecoderSerialNumber:
//    case .initReadForDecoderProductionDate:
    case .initReadForDecoderProductionInfo:
      data = [0xff, 0xff, 0xff, 0xff]
//    case .initReadForDecoderBootcodeVersion:
    case .initReadForDecoderFirmwareVersion:
      if decoder.firmwareVersions.count > 0 {
        let item = decoder.firmwareVersions[0]
        data.append(contentsOf: UInt16(item[2]).bigEndianData.reversed())
        data.append(UInt8(item[1]))
        data.append(UInt8(item[0]))
      }
    case .initReadForDecoderManufacturerCode:
      data = UInt32(0x97).bigEndianData.reversed()
    default:
      break
    }
    
    for byte in data {
      packet.append(byte)
    }

    var checksum = packet[6]
    
    for index in 7 ..< packet.count {
      checksum ^= packet[index]
    }
    
    packet.append(checksum)
    
    packet.append(0x81)
    
    var result = ""
    
    for byte in packet {
      result += byte.hex() + " "
    }
    
    return result.trimmingCharacters(in: .whitespaces)

  }

  var cvbufferLastWrite : [UInt8] = [UInt8](repeating: 0x0, count: 2688)
  var cvbufferThisWrite : [UInt8] = [UInt8](repeating: 0x0, count: 2688)

  private func dataBlockResponse(initPacket:LokPacket) -> String {
    
    guard let sequenceNumberForRead = initPacket.sequenceNumberForRead, let block = DecoderEditorLoadType(title: cboBlock.stringValue) else {
      return ""
    }
    
    var packet : [UInt8] = [0x7f, 0x7f, 0x02, initPacket.sequenceNumber, 0x07, 0x00, sequenceNumberForRead, 0x00]
    
    var cvbuffer : [UInt8] = [UInt8](repeating: 0x0, count: 2688)
    
//    for index in 0 ... 255 {
//      cvbuffer[index] = decoder.getUInt8(index:index)
//    }
    
    if block != .lastWrite {
      for index in 1 ... 224 {
        cvbuffer[block.rawValue + index - 1] = UInt8(index)
      }
    }

    for address in Int(initPacket.address!) ... Int(initPacket.address!) + Int(initPacket.numberOfBytesToRead!) - 1 {
      if block == .lastWrite {
        packet.append(cvbufferLastWrite[address])
      }
      else {
        packet.append(cvbuffer[address])
      }
    }
    
    var checksum = packet[6]
    
    for index in 7 ..< packet.count {
      checksum ^= packet[index]
    }
    
    packet.append(checksum)
    
    packet.append(0x81)
    
    var result = ""
    
    for byte in packet {
      result += byte.hex() + " "
    }
    
    return result.trimmingCharacters(in: .whitespaces)
    
  }
  
  private var count16A = 0
  private var countReadData = 0
  
  private var nextDataRead : String = ""
  
  private func sendResponse(original:LokPacket, response:String) {

    let bits = response.split(separator: " ")
    
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
    
    command[3] = original.sequenceNumber
    
    lastCommand = LokPacket(packet: command)
    
    if let commandPort, let lastCommand {
      
      commandPort.send(Data(lastCommand.packetToSend))
      
    }

  }

  @IBOutlet weak var cboDecoder: NSComboBox!
  
  @IBAction func cboDecoderAction(_ sender: NSComboBox) {
    
    guard let decoderType = DecoderType(title: sender.stringValue) else {
      return
    }
    
    decoder = Decoder(decoderType: decoderType)
    
  }
  
  @IBOutlet weak var cboBlock: NSComboBox!
  
  @IBAction func cboBlockAction(_ sender: NSComboBox) {
  }
  
  
  struct SortItem {
    
    var command : LokPacket?
    
    var response : LokPacket?
    
    var pageNumber : Int?
    
    var sequenceNumber : UInt8? {
      if let command {
        return command.sequenceNumber
      }
      if let response {
        return response.sequenceNumber
      }
      return nil
    }
    
    var isMatched : Bool {
      return command != nil && response != nil
    }
    
    var sortPageNumber : String {
      guard let pageNumber else {
        return "00000000"
      }
      return String(("00000000\(pageNumber)").suffix(8))
    }
    
    var sortCode : String {
      guard isMatched, let command else {
        return ""
      }
      return "\(sortPageNumber) \(command.packet[3].hex()) \(command.packet[2].hex())"
    }
    
  }
  
  @IBAction func btnSortAction(_ sender: NSButton) {
    
    var sort : [SortItem] = []
    
 //   var firmware : [UInt8] = []
    
    let lines = txtView.string.split(separator: "\n")
    
    var pageNumber = 0
    var inTransition = false
    
    for line in lines {
      
      // 7F 7F 01 0D
      if line.prefix(5) == "7F 7F" {
        
        let bits = line.split(separator: "(")
        
        let packetString = bits[0].trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let packet = LokPacket(packet: packetString) {
          /*
          if packet.packetType == .writeDecoderFirmwareUpdate {
            if let isCheckSumOK = packet.isCheckSumOK, isCheckSumOK {
              var bytes = packet.payload
              bytes.removeFirst(2)
              firmware.append(contentsOf: bytes)
            }
            else {
              print("Checksum failure")
            }
          }
          */
          var found = false
          
          if !sort.isEmpty {
            for index in (0 ..< sort.count).reversed() {
              var sortItem = sort[index]
              if !sortItem.isMatched, let sequenceNumber = sortItem.sequenceNumber, packet.sequenceNumber == sequenceNumber {
                found = true
                if packet.isTX {
                  sortItem.command = packet
                }
                else if packet.isRX {
                  sortItem.response = packet
                }
                if !inTransition && sequenceNumber == 0 {
                  inTransition = true
                  pageNumber += 1
                  sortItem.pageNumber = pageNumber
                }
                else if inTransition {
                  if sequenceNumber == 0x3F {
                    inTransition = false
                    sortItem.pageNumber = pageNumber
                  }
                  else if sequenceNumber > 0x3F {
                    sortItem.pageNumber = pageNumber - 1
                  }
                  else {
                    sortItem.pageNumber = pageNumber
                  }
                }
                else {
                  sortItem.pageNumber = pageNumber
                }
                sort[index] = sortItem
                break
              }
            }
          }
          
          if !found {
            var sortItem = SortItem()
            if packet.isTX {
              sortItem.command = packet
            }
            else if packet.isRX {
              sortItem.response = packet
            }
            if !inTransition && packet.sequenceNumber == 0 {
              inTransition = true
              pageNumber += 1
              sortItem.pageNumber = pageNumber
            }
            else if inTransition {
              if packet.sequenceNumber == 0x3F {
                inTransition = false
                sortItem.pageNumber = pageNumber
              }
              else if packet.sequenceNumber > 0x3F {
                sortItem.pageNumber = pageNumber - 1
              }
              else {
                sortItem.pageNumber = pageNumber
              }
            }
            else {
              sortItem.pageNumber = pageNumber
            }
            sort.append(sortItem)
          }
          
        }
        
      }
      
    }
    
    sort.sort {$0.sortCode < $1.sortCode}
    
    txtView.string = ""
    
    prettyPrint = true
    
    for sortItem in sort {
      if let command = sortItem.command, let response = sortItem.response {
        packetReceived(packet: command)
        packetReceived(packet: response)
      }
      else {
        print("error")
      }
    }
    
    prettyPrint = false
    /*
    do {
      let data = Data(firmware)
      let url = URL(fileURLWithPath: "/Users/paul/Desktop/FIRMWARE.txt")
      try data.write(to: url)
    } catch {
    }
     */
  }
  
}


private var cvs : [UInt8] = [UInt8](repeating: 0x00, count: 2688)

public enum LokPacketType : CaseIterable {
  
  case unknown
  case ack
  case initRead
  case initReadDataBlock
  case initReadDataDWord
  case initReadForDecoderManufacturerCode
  case initReadForDecoderProductId
  case initReadForDecoderSerialNumber
  case initReadForDecoderFirmwareVersion
  case initReadForDecoderFirmwareDate
  case initReadForDecoderFirmwareType
  case initReadForDecoderBootcodeVersion
  case initReadForDecoderBootcodeDate
  case initReadForDecoderProductionInfo
  case initReadForDecoderProductionDate
  case initWriteDataBlock
  case bufferDataBlock
  case bufferDataDWord
  case readData
  case data
  case readError
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
  case setSingleCVMode
  case setDriversCabMode
  case lokProgrammerTestA
  case lokProgrammerTestB
  case sendServiceModePacket
  case sendOperationsModePacket
  case sendMotorolaPacket
  case writeDecoderFirmwareUpdate
  case TX34_A
  case TX34_B
  case TX34_C
  case TX34_D
  case TX34_E
  case TX34_F
  case TX16_A
  case TX16_B
  case TX16_C
  case TX18_A
  case TX18_B
  case TX19_A
  case RX03_A
  case TX12_A
  case TX14_A
  
  public var title : String {
    return LokPacketType.titles[self] ?? LokPacketType.unknown.title
  }
  
  private static let titles : [LokPacketType:String] = [
    .unknown : String(localized: "Unknown"),
    .readError : String(localized: "Read Error"),
    .RX03_A : String(localized: "RX03_A"),
    .TX12_A : String(localized: "TX12_A"),
    .TX14_A : String(localized: "TX14_A"),
    .ack  : String(localized: "Ack"),
    .writeDecoderFirmwareUpdate  : String(localized: "Init Write Decoder Firmware Update"),
    .sendMotorolaPacket  : String(localized: "Send Motorola Packet"),
    .setDriversCabMode : String(localized: "LokProgrammer Driver's Cab Mode"),
    .initRead  : String(localized: "Init Read"),
    .initReadDataBlock  : String(localized: "Init Read Data Block"),
    .initReadDataDWord  : String(localized: "Init Read Data DWord"),
    .initReadForDecoderManufacturerCode : String(localized: "Init Read For Decoder Manufactuer Code"),
    .initReadForDecoderProductId  : String(localized: "Init Read For Decoder Product Id"),
    .initReadForDecoderSerialNumber  : String(localized: "Init Read For Decoder Serial Number"),
    .initReadForDecoderFirmwareVersion  : String(localized: "Init Read For Decoder Firmware Version"),
    .initReadForDecoderFirmwareDate  : String(localized: "Init Read For Decoder Firmware Date"),
    .initReadForDecoderFirmwareType  : String(localized: "Init Read For Decoder Firmware Type"),
    .initReadForDecoderBootcodeVersion  : String(localized: "Init Read For Decoder Boot Code Version"),
    .initReadForDecoderBootcodeDate : String(localized: "Init Read For Decoder Boot Code Date"),
    .initReadForDecoderProductionInfo : String(localized: "Init Read For Decoder Production Info"),
    .initReadForDecoderProductionDate  : String(localized: "Init Read For Decoder Production Date"),
    .initWriteDataBlock  : String(localized: "Init Write Data Block"),
    .bufferDataBlock  : String(localized: "Buffer Data Block"),
    .bufferDataDWord : String(localized: "Buffer Data DWord"),
    .readData : String(localized: "Read/Write Data"),
    .data : String(localized: "Data"),
    .getLokProgrammerManufacturerCode : String(localized: "Get LokProgrammer Manufacturer Code"),
    .getLokProgrammerProductId : String(localized: "Get LokProgrammer Product Id"),
    .getLokProgrammerInfoA : String(localized: "Get LokProgrammer Info A"),
    .getLokProgrammerInfoB : String(localized: "Get LokProgrammer Info B"),
    .getLokProgrammerBootCodeVersion : String(localized: "Get LokProgrammer Boot Code Version"),
    .getLokProgrammerBootCodeDate : String(localized: "Get LokProgrammer Boot Code Date"),
    .getLokProgrammerACodeVersion : String(localized: "Get LokProgrammer ACode Version"),
    .getLokProgrammerACodeDate : String(localized: "Get LokProgrammer ACode Date"),
    .getLokProgrammerInfoC : String(localized: "Get LokProgrammer Info C"),
    .dword : String(localized: "DWord"),
    .lokProgrammerCommandAccepted : String(localized: "Command Accepted"),
    .lokProgrammerCommandError : String(localized: "Command Error"),
    .lokProgrammerTidyUp : String(localized: "LokProgrammer Tidy Up"),
    .setLokProgrammerMode : String(localized: "Set LokProgrammer Mode"),
    .setSingleCVMode : String(localized: "Set LokProgrammer Single CV Mode"),
    .lokProgrammerTestA : String(localized: "Test A"),
    .lokProgrammerTestB : String(localized: "Test B"),
    .sendServiceModePacket : String(localized: "Send Service Mode Packet"),
    .sendOperationsModePacket : String(localized: "Send Operations Mode Packet"),
    .TX34_A : String(localized: "TX34_A"),
    .TX34_B : String(localized: "TX34_B"),
    .TX34_C : String(localized: "TX34_C"),
    .TX34_D : String(localized: "TX34_D"),
    .TX34_E : String(localized: "TX34_E"),
    .TX34_F : String(localized: "TX34_F"),
    .TX16_A : String(localized: "TX16_A"),
    .TX16_B : String(localized: "TX16_B"),
    .TX16_C : String(localized: "TX16_C"),
    .TX18_A : String(localized: "TX18_A"),
    .TX18_B : String(localized: "TX18_B"),
    .TX19_A : String(localized: "TX19_A"),
  ]
  
  
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
  
  init?(packet:String) {
    self.packet = []
    let bits = packet.split(separator: " ")
    for bit in bits {
      if let byte = UInt8(bit, radix: 16) {
        self.packet.append(byte)
      }
      else {
        return nil
      }
    }
  }
  
  var packet : [UInt8]
  
  var _packetType : LokPacketType?
  
  public var packetType : LokPacketType {
    
    // 7F 7F 01 2E 2A 14 79 02 04 E0 00 E0 06 81
    
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
        case 0x16:
          if packet[5] == 0x02 {
            _packetType = .TX16_A
          }
          else if packet[5] == 0x01 {
            _packetType = .TX16_C
          }
          else if packet[5] == 0x00 {
            _packetType = .TX16_B
          }
        case 0x18:
          if packet.count == 7 {
            // 7F 7F 01 XX 18 4B 81
            if packet[5] == 0x4B {
              _packetType = .bufferDataBlock
            }
            else if packet[5] == 0x01 {
              _packetType = .bufferDataDWord
            }
            else if packet[5] == 0x05 {
              _packetType = .TX18_A
            }
          }
        case 0x19:
          _packetType = .TX19_A
        case 0x2a:
          
          _packetType = .initRead
 
          // 7F 7F 01 29 2A 14 79 00 02 00 02 81
          if packet.count == 12 && packet[5] == 0x14 && packet[6] == 0x79 && packet[8] == 0x02 {
            
            switch packet[9] {
            case 0x00:
              _packetType = .initReadForDecoderManufacturerCode
            case 0x01:
              _packetType = .initReadForDecoderProductId
            case 0x02:
              _packetType = .initReadForDecoderSerialNumber
            case 0x03:
              _packetType = .initReadForDecoderProductionDate
            case 0x04:
              _packetType = .initReadForDecoderProductionInfo
            case 0x05:
              _packetType = .initReadForDecoderBootcodeVersion
            case 0x06:
              _packetType = .initReadForDecoderBootcodeDate
            case 0x07:
              _packetType = .initReadForDecoderFirmwareVersion
            case 0x08:
              _packetType = .initReadForDecoderFirmwareDate
            case 0x09:
              _packetType = .initReadForDecoderFirmwareType
            default:
              _packetType = .initReadDataDWord
              break
            }
            
          }
          
          // 7F 7F 01 7D 2A 14 79 0D 04 A0 09 E0 40 81
          else if packet.count == 14 && packet[5] == 0x14 && packet[6] == 0x79 && packet[8] == 0x04 {
            _packetType = .initReadDataBlock
          }
          else if packet.count > 12 && packet[5] == 0x14 && packet[6] == 0x79 && packet[8] == 0x05 {
            _packetType = .initWriteDataBlock
          }
          else if packet.count > 12 && packet[5] == 0x14 && packet[6] == 0x79 && packet[8] == 0x07 {
            _packetType = .writeDecoderFirmwareUpdate
          }

        case 0x2b:
          _packetType = .readData
        case 0x30:
          // 7F 7F 01 XX 30 1A B6 14 0A 02 12 2C 04 40 81 (Unknown)
          if packet[5] == 0x1a && packet[6] == 0xb6 && packet[7] == 0x14 && packet[8] == 0x0a && packet[9] == 0x02 && packet[10] == 0x12 {
            _packetType = .sendMotorolaPacket
          }

        case 0x34:
          if packet.count > 8 {
            if packet[5] == 0x3a && packet[6] == 0x64 {
              _packetType = .sendServiceModePacket
            }
            // 7F 7F 01 25 34 3A 64 12 02 01 00 00 00 00 81
            else if packet[5] == 0x3a && packet[6] == 0x74 {
              _packetType = .sendOperationsModePacket
            }
            else if packet[5] == 0x0c && packet[6] == 0x0c && packet[7] == 0x64 && packet[8] == 0x64 && packet[9] == 0x00 && packet[10] == 0x00 {
              _packetType = .TX34_A
            }
            else if packet[5] == 0x0c && packet[6] == 0x0c && packet[7] == 0x64 && packet[8] == 0x64 && packet[9] == 0x64 && packet[10] == 0x00 {
              _packetType = .TX34_B
            }
            else if packet[5] == 0x14 && packet[6] == 0x14 && packet[7] == 0x14 && packet[8] == 0x0a && packet[9] == 0x00 && packet[10] == 0x00 {
              _packetType = .TX34_C
            }
            else if packet[5] == 0x14 && packet[6] == 0x14 && packet[7] == 0x14 && packet[8] == 0x0a && packet[9] == 0x04 && packet[10] == 0x00 {
              _packetType = .TX34_D
            }
            else if packet[5] == 0x64 && packet[6] == 0x64 && packet[7] == 0x04 && packet[8] == 0x02 && packet[9] == 0x00 && packet[10] == 0x00 {
              _packetType = .TX34_E
            }
            // 7F 7F 01 02 34 0A 0A 14 0A 04 00 81
            else if packet[5] == 0x0a && packet[6] == 0x0a && packet[7] == 0x14 && packet[8] == 0x0a && packet[9] == 0x04 && packet[10] == 0x00 {
              _packetType = .TX34_F
            }
          }
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
            // 7F 7F 01 1F 10 02 00 28 19 81
            else if packet[5] == 0x02 && packet[6] == 0x00 && packet[7] == 0x28 && packet[8] == 0x19 {
              _packetType = .setSingleCVMode
            }
            // 7F 7F 01 02 10 01 00 2D 19 81 (Set LokProgrammer Driver's Cab Mode)
            else if packet[5] == 0x01 && packet[6] == 0x00 && packet[7] == 0x2D && packet[8] == 0x19 {
              _packetType = .setDriversCabMode
            }

          }
        case 0x12:
          _packetType = .TX12_A
        case 0x14:
          _packetType = .TX14_A

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
        case 0x03:
          _packetType = .RX03_A
        case 0x07:
          if packet.count == 7 {
            _packetType = .ack
          }
          // 7F 7F 02 XX 07 00 7F 81
          // 7F 7F 02 6F 07 00 7F 81
          else if packet.count == 8 && packet[6] == 0x7f {
            _packetType = .readError
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
      
      switch packetType {
      case .initWriteDataBlock:
        if packet.count > 12 {
          for index in 11 ... packet.count - 3 {
            result.append(packet[index])
          }
        }
      case .data:
        if packet.count > 9 {
          for index in 6 ... packet.count - 3 {
            result.append(packet[index])
          }
        }
      case .writeDecoderFirmwareUpdate:
        if packet.count > 9 {
          for index in 7 ... packet.count - 3 {
            result.append(packet[index])
          }
        }
        // 7F 7F 01 42 2A 14 79 02 07 6E 91 F8 BA 9D 3F 77 61 79 37 70 49 B5 90 53 C9 86 8C 06 45 AF 24 79 42 8D C0 AD 65 2A 10 B0 68 B7 62 95 1C D1 C8 B0 8B 9E 89 85 09 49 D5 A4 8E FD D8 C6 55 A9 53 A9 C2 85 33 60 43 E0 E6 B6 E7 68 9F 45 52 5D 02 EB B2 00 99 8F C8 7B 8C F5 73 E7 06 5B A7 D3 C7 4D 8B 3B 54 E9 AE 0D 07 8B 01 4C 3B 43 D8 B5 D3 03 D1 71 6B 6C B8 52 62 35 90 3A 7D C0 F8 39 45 EE 17 B4 4D 3F 11 F0 C4 54 D0 77 83 80 DB AE 51 D9 D9 51 A3 A1 91 8C C4 E0 78 FF E3 26 09 67 BC A6 9E E8 22 7D FB 55 66 90 2E B9 37 DF B6 03 18 D2 7B 67 C4 3F B6 BA 19 3F F1 7F 2A 93 A6 DF EB 7D 70 BD C3 B9 81 2D 13 B3 B0 AE BA 25 55 5D A2 AB 32 9E 69 87 4B 74 B9 85 AA 7D 01 EB 5F 39 D7 28 32 F7 A5 5F 8C AB 67 EF 70 F8 25 A4 71 4F 03 40 21 B8 52 B7 38 99 35 FB 0C 92 C3 F7 58 C0 AC E8 88 07 9B B6 0B 7C 82 E0 DB 84 B9 6A 1A BD 9D 45 C7 5D 5E F4 73 CC 32 87 FD E8 81 (Init Read)

      default:
        break
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
      result += byte.hex()
    }
    return result
  }
  
  public var dword : UInt32? {
    switch packetType {
    case .dword:
      // 7F 7F 02 XX 01 00 86 00 01 00 81
      var result : UInt32 = 0
      for index in (6 ... 9).reversed() {
        result <<= 8
        result |= UInt32(packet[index])
      }
      return result
    case .data:
      // 7F 7F 02 XX 07 00 02 00 9C 00 00 02 9C 81
      guard let isCheckSumOK, isCheckSumOK && payload.count == 6 else {
        return nil
      }
      var result : UInt32 = 0
      for index in (8 ... 11).reversed() {
        result <<= 8
        result |= UInt32(packet[index])
      }
      return result
    default:
      return nil
    }
  }
  
  public var address : UInt16? {
    switch packetType {
    case .initReadDataBlock, .initWriteDataBlock:
      // 7F 7F 01 7D 2A 14 79 0D 04 A0 09 E0 40 81
      return UInt16(packet[9]) | (UInt16(packet[10]) << 8)
    default:
      return nil
    }
  }
  
  public func dccPacket(decoderMode:SGDCCDecoderMode = .operationsMode) -> SGDCCPacket? {
    
    guard packetType == .sendServiceModePacket || packetType == .sendOperationsModePacket else {
      return nil
    }
    
    var data : [UInt8] = []
    
    // // 7F 7F 01 25 34 3A 64 12 02 01 00 00 00 00 81
    
    for index in 11 ... packet.count - 2 {
      data.append(packet[index])
    }
    
    return SGDCCPacket(packet: data, decoderMode: decoderMode)
    
  }

  public var numberOfBytesToRead : UInt8? {
    guard packetType == .initReadDataBlock else {
      return nil
    }
    // 7F 7F 01 7D 2A 14 79 0D 04 A0 09 E0 40 81
    return packet[11]
  }

  public var sequenceNumberForRead : UInt8? {
    switch packetType {
    case .initReadDataBlock:
      // 7F 7F 01 7D 2A 14 79 0D 04 A0 09 E0 40 81
      return packet[7]
    case .initReadForDecoderProductId, .initReadForDecoderBootcodeDate, .initReadForDecoderFirmwareDate, .initReadForDecoderFirmwareType, .initReadForDecoderSerialNumber, .initReadForDecoderProductionDate, .initReadForDecoderProductionInfo, .initReadForDecoderBootcodeVersion, .initReadForDecoderFirmwareVersion, .initReadForDecoderManufacturerCode:
      return packet[7]
    default:
      return nil
    }
  }
  /*
  public var cvNumber : UInt16? {
    
    let validTypes : Set<LokPacketType> = [
      .readCVBit, .readIndexedCVBit, .writeCV, .writeIndexedCV, .testCVValue, .testIndexedCVValue]
    
    guard validTypes.contains(packetType) else {
      return nil
    }
    // 7F 7F 01 78 34 3A 64 12 02 05 05 79 00 E0 99 81 indexed
    // 7F 7F 01 4C 34 3A 64 12 02 05 05 75 00 00 75 81 indexed
    // 7F 7F 01 5A 34 3A 64 12 02 05 05 74 00 10 64 81 regular
    var offset : UInt16 = 0
    switch packetType {
    case .readIndexedCVBit, .writeIndexedCV, .testIndexedCVValue:
      offset = 256
    case .testCVValue, .readCVBit, .writeCV:
      offset = 0
    default:
      break
    }
    return offset + UInt16(packet[12]) + 1
    
  }
  */
  /*
  public var cvValue : UInt8? {

    let validTypes : Set<LokPacketType> = [.writeCV, .testCVValue, .testIndexedCVValue, .writeIndexedCV]
    
    guard validTypes.contains(packetType) else {
      return nil
    }

    return packet[13]

  }

  public var cvBit : UInt8? {

    let validTypes : Set<LokPacketType> = [.readCVBit, .readIndexedCVBit]
    
    guard validTypes.contains(packetType) else {
      return nil
    }

    return packet[13] & 0x0f

  }
*/
  public var errorCode : UInt8? {
    switch packetType {
    // 7F 7F 02 XX 01 04 81
    case .lokProgrammerCommandAccepted, .lokProgrammerCommandError:
      return packet[5]
    default:
      return nil
    }
  }

  public var isCheckSumOK : Bool? {
    
    guard let checkSum, let checkSumCalculated else {
      return nil
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
        temp += byte.hex() + " "
      }
      temp = ""
      for byte in result {
        temp += byte.hex() + " "
      }
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

    var checkSum : UInt8

    switch packetType {
      
    case .initWriteDataBlock:
      
      checkSum = packet[7]
      
      for index in 8 ... packet.count - 3 {
        checkSum ^= packet[index]
      }

//    case .writeDecoderFirmwareUpdate:
      // 7F 7F 01 42 2A 14 79 02 07 6E 91 F8 BA 9D 3F 77 61 79 37 70 49 B5 90 53 C9 86 8C 06 45 AF 24 79 42 8D C0 AD 65 2A 10 B0 68 B7 62 95 1C D1 C8 B0 8B 9E 89 85 09 49 D5 A4 8E FD D8 C6 55 A9 53 A9 C2 85 33 60 43 E0 E6 B6 E7 68 9F 45 52 5D 02 EB B2 00 99 8F C8 7B 8C F5 73 E7 06 5B A7 D3 C7 4D 8B 3B 54 E9 AE 0D 07 8B 01 4C 3B 43 D8 B5 D3 03 D1 71 6B 6C B8 52 62 35 90 3A 7D C0 F8 39 45 EE 17 B4 4D 3F 11 F0 C4 54 D0 77 83 80 DB AE 51 D9 D9 51 A3 A1 91 8C C4 E0 78 FF E3 26 09 67 BC A6 9E E8 22 7D FB 55 66 90 2E B9 37 DF B6 03 18 D2 7B 67 C4 3F B6 BA 19 3F F1 7F 2A 93 A6 DF EB 7D 70 BD C3 B9 81 2D 13 B3 B0 AE BA 25 55 5D A2 AB 32 9E 69 87 4B 74 B9 85 AA 7D 01 EB 5F 39 D7 28 32 F7 A5 5F 8C AB 67 EF 70 F8 25 A4 71 4F 03 40 21 B8 52 B7 38 99 35 FB 0C 92 C3 F7 58 C0 AC E8 88 07 9B B6 0B 7C 82 E0 DB 84 B9 6A 1A BD 9D 45 C7 5D 5E F4 73 CC 32 87 FD E8 81 (Init Read)

    default:

      checkSum = payload[0]
      
      for index in 1 ... payload.count - 1 {
        checkSum ^= payload[index]
      }

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
  //  dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    dateFormatter.dateStyle = .long
    
    return dateFormatter.string(from: date)

  }
  
  
}
