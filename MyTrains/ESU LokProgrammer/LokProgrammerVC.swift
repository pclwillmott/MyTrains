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
    
    let string = "AD 96 C1 72 D3 30 10 86 EF CC F0 0E 3B 3E 95 43 63 CB 4E 9B D0 71 D2 49 E2 52 A0 F5 24 93 10 3A C3 4D C4 4A ED 41 96 52 4B 72 DA 3E 0F 6F C1 81 03 0F C4 2B 20 B9 29 03 43 A8 65 C3 31 8E B4 FF 97 CD FE FF FA FB 97 AF E1 E9 6D 4E A1 24 85 C8 38 1B 38 A8 E3 39 40 D8 8A 27 19 BB 1E 38 4A AE 0F FB CE E9 F0 F9 B3 30 27 12 83 3E CB C4 C0 49 A5 DC 9C B8 EE 76 BB ED 10 A1 3A 44 B9 BE 87 3C F7 72 7A 31 9B 4F CF E7 A3 38 3E 9B BB B1 BE 90 60 89 1D 7D 1B 20 14 5C B1 44 50 2E 21 4B 06 8E F7 F0 54 3F 4F 88 58 15 D9 46 6A 79 53 FE 84 62 23 9C 10 67 F8 1E 79 1E 1C 1C 75 BB 81 FF 22 74 7F 39 F7 F4 55 C2 9C E1 E2 2A 02 E4 23 88 17 30 9A 80 66 3B 42 01 94 3E FC 59 26 74 7F 82 ED E3 44 35 9C 46 6C A4 24 87 39 CE 74 1B 83 C6 02 BE 45 23 52 5E 30 F0 5B B6 E0 B5 B9 3C C7 2C E1 39 CC 28 BE C3 1F 29 69 4C 19 D8 52 A2 FF 40 F9 8E 73 29 1A 23 1E 5B FC 53 46 6D A9 87 5B 6D 5A F4 A0 67 D1 83 AA B4 76 4E 8B 2E 4C 2A 2A 58 6E 1A 83 BD B4 00 BB D4 4E 38 D6 26 85 19 C9 D6 04 CC 17 2D 18 CF 15 2E 12 01 57 69 26 A4 66 2D 7B 80 BC 3E 4C 19 BD 6B 6E AC BA 04 A8 34 CD 69 0F 21 18 17 F8 13 01 04 55 8D E6 5A 36 26 AB 24 5A F4 E4 0D 93 84 D2 6C 87 18 41 D9 6D CE D7 B5 E0 BB 50 45 49 D8 8D CA 88 14 AB 94 B0 16 A8 AF CC 47 02 E2 46 11 AC C3 6A 4F A2 D4 81 D6 79 C0 28 9D CD E0 76 5F 0E D4 D5 EE DB D6 6E C1 6D 63 91 DD 70 8F D5 FD 3D 29 DA C4 98 B6 C2 AE 86 0B 51 51 FE B5 52 DD 46 B0 D9 8D BF C1 3E 91 EB 56 E1 3B CA 0A 5D 29 A3 89 4E 1F D0 2D 6E 31 C2 BE 8D C5 96 0B 88 32 F3 AA A1 67 50 12 9C C3 21 BC E5 29 13 FA E0 18 17 70 D0 0B BA A8 D7 76 D5 47 FA 47 4C D2 6A C0 5B 4C B6 5F B7 E1 1E A5 A2 78 09 11 E7 05 2C 28 CE 9B EF D1 BA F7 09 D3 A6 0F 6A 8D 29 15 D7 A4 F8 F6 59 19 AF 37 EC C8 6E 8D 3E 28 37 47 B4 0B 4B 92 8B 7F 49 A3 2A D8 83 00 62 45 E5 63 76 56 1C 50 1E D5 21 87 AE 79 17 1D FE 00 83 E4 19 9E BD 0A"
    
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
    
    let decoders : [DecoderType] = [
 /*     .lokPilot5,
      .lokPilot5Basic,
      .lokPilot5micro,
      .lokSound5micro,
      .lokPilot5L,
      .lokSound5L,
      .lokPilot5Fx,
      .lokSound5Fx,
      .lokSound5XL,
      .lokPilot5DCC,
      .lokPilot5MKL,
      .lokSound5DCC,
      .lokSound5MKL,
      .lokPilot5LDCC,
      .lokSound5LDCC,
      .lokPilot5MKLDCC,
      .lokPilot5Fxmicro,
      .lokPilot5nanoDCC,
      .lokSound5nanoDCC,
      .lokPilot5microDCC,
      .lokSound5microDCC,
      .lokSound5microKATO,
      .lokPilot5microNext18,
      .lokPilot5FxDCC,
      .lokSound5FxDCC, */
      .lokSound5,
    ]
    
    let decoder1 = Decoder(decoderType: .lokSound5DCC)
    
    for decoderType in decoders {
      
      let decoder2 = Decoder(decoderType: decoderType)
      
      let common = decoder2.cvSet.intersection(decoder1.cvSet)
      
      let unique = decoder2.cvSet.subtracting(decoder1.cvSet)
      
      print("\(decoderType.title) Common: \(common.count) Unique: \(unique.count) \(unique)")
    }
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
    
    // DECODER INFO
  
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
    
    var dump = "\(packet.isRX ? "RX: " : "TX: ") \(packet.hex)\n"

    dump += "\(packet.packetType)\n"
    
    if packet.isCarryingPayload, let isCheckSumOK = packet.isCheckSumOK {
      dump += "CheckSum: \(isCheckSumOK) Count: \(packet.payload.count)\n"
    }

    // The following only works if this app sent the command
    
    if packet.isRX {
      
      if let lastCommand, lastCommand.sequenceNumber == packet.sequenceNumber {

        if lastCommand.packetType == .readCVBit || lastCommand.packetType == .readIndexedCVBit {
          print(packet.payload)
        }
        else if packet.dword != nil {
          
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
          case .readData:
            
            if let last2A {
              
              switch last2A.packetType {
              case .initReadForDecoderProductId:
                dump += "Decoder Product ID: \(packet.dword!.toHex(numberOfDigits: 8))\n"
                if let dword = packet.dword, let decoderType = DecoderType.esuProductIdLookup[dword] {
                  dump += "Decoder Type: \(decoderType.title)\n"
                }
              case .initReadForDecoderManufacturerCode:
                dump += "Decoder Manufacturer Code: \(packet.dword!.toHex(numberOfDigits: 8))\n"
              case .initReadForDecoderProductionInfo:
                dump += "Decoder Production Info: \(packet.dword!.toHex(numberOfDigits: 8))\n"
              case .initReadForDecoderSerialNumber:
                dump += "Decoder Serial Number: \(packet.dword!.toHex(numberOfDigits: 8))\n"
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
              print("\(index.toHex(numberOfDigits: 4)): \(cvs[Int(index)])")
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
          dump += "Sequence number: \(sequenceNumber.toHex(numberOfDigits: 2)) Address: \(address.toHex(numberOfDigits: 4)) Number of bytes: \(count)\n"
        }
      case .writeCV, .testCVValue, .testIndexedCVValue:
        if let cvNumber = packet.cvNumber, let cvValue = packet.cvValue {
          dump += "CV\(cvNumber) = \(cvValue)\n"
        }
      case .readCVBit:
        if let cvNumber = packet.cvNumber, let cvBit = packet.cvBit {
          dump += "CV\(cvNumber) d\(cvBit)\n"
        }
      default:
        break
      }
      
    }
    
    txtView.string += dump
 
    if isSendingPreamble && packet.isRX  {
      sendNextStep()
    }
    
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
  case bufferDataBlock
  case bufferDataDWord
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
  case setSingleCVMode
  case lokProgrammerTestA
  case lokProgrammerTestB
  case readIndexedCVBit
  case writeIndexedCV
  case readCVBit
  case writeCV
  case activateDecoder
  case testCVValue
  case testIndexedCVValue
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
        case 0x18:
          if packet.count == 7 {
            // 7F 7F 01 XX 18 4B 81
            if packet[5] == 0x4B {
              _packetType = .bufferDataBlock
            }
            else if packet[5] == 0x01 {
              _packetType = .bufferDataDWord
            }
          }
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
          
        case 0x2b:
          _packetType = .readData
        case 0x34:
          if packet.count == 16 {
            if packet[5] == 0x3a && packet[6] == 0x64 && packet[7] == 0x12 && packet[8] == 0x02 && packet[9] == 0x05 && packet[10] == 0x05 {
              // 7F 7F 01 4C 34 3A 64 12 02 05 05 75 00 00 75 81
              if packet[11] == 0x75 {
                _packetType = .testIndexedCVValue
              }
              // 7F 7F 01 5A 34 3A 64 12 02 05 05 74 00 10 64 81
              else if packet[11] == 0x74 {
                _packetType = .testCVValue
              }
              // 7F 7F 01 73 34 3A 64 12 02 05 05 78 00 E0 98 81
              else if packet[11] == 0x78 {
                _packetType = .readCVBit
              }
              // 7F 7F 01 78 34 3A 64 12 02 05 05 79 00 E0 99 81
              else if packet[11] == 0x79 {
                _packetType = .readIndexedCVBit
              }
              // 7F 7F 01 62 34 3A 64 12 02 05 05 7C 1E 10 72 81
              else if packet[11] == 0x7c {
                _packetType = .writeCV
              }
              // 7F 7F 01 76 34 3A 64 12 02 05 05 7D 00 01 7C 81
              else if packet[11] == 0x7d {
                _packetType = .writeIndexedCV
              }
            }
          }
          else if packet.count == 15 {
            // 7F 7F 01 25 34 3A 64 12 02 01 00 00 00 00 81
            if packet[5] == 0x3a && packet[6] == 0x64 && packet[7] == 0x12 && packet[8] == 0x02 && packet[9] == 0x01 && packet[10] == 0x00 && packet[11] == 0x00 && packet[12] == 0x00 && packet[13] == 0x00 {
              _packetType = .activateDecoder
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
      
      if packetType == .data && packet.count > 9 {
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
    guard packetType == .initReadDataBlock else {
      return nil
    }
    // 7F 7F 01 7D 2A 14 79 0D 04 A0 09 E0 40 81
    return UInt16(packet[9]) | (UInt16(packet[10]) << 8)
  }

  public var numberOfBytesToRead : UInt8? {
    guard packetType == .initReadDataBlock else {
      return nil
    }
    // 7F 7F 01 7D 2A 14 79 0D 04 A0 09 E0 40 81
    return packet[11]
  }

  public var sequenceNumberForRead : UInt8? {
    guard packetType == .initReadDataBlock else {
      return nil
    }
    // 7F 7F 01 7D 2A 14 79 0D 04 A0 09 E0 40 81
    return packet[7]
  }
  
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
