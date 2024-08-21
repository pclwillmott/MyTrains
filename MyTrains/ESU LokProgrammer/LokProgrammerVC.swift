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
      commandPort.usesRTSCTSFlowControl = true
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
  
  private var commands : Set<UInt8> = []
  
  private var rxPackets : [UInt8:[String]] = [:]
  
  private var txPackets : [UInt8:[String]] = [:]

  // MARK: Outlets & Actions
  
  @IBOutlet var txtView: NSTextView!
 
  @IBAction func btnClearAction(_ sender: Any) {
    txtView.string = ""
    rxPackets.removeAll()
    txPackets.removeAll()
    commands.removeAll()
  }
  
  @IBAction func btnCommandsAction(_ sender: Any) {
    
    for (key, items) in txPackets {
      for item in items {
        txtView.string += "TX: " + item + "\n"
      }
      txtView.string += "\n"
    }

    for (key, items) in rxPackets {
      for item in items {
        txtView.string += "RX: " + item + "\n"
      }
      txtView.string += "\n"
    }

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
    
    commandPort?.send(Data(command))
    
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
    
    stopTimer(port: port)

    bufferLock[port].lock()
    
    buffer[port].append(contentsOf: data)
    
    bufferLock[port].unlock()
    
    scanBuffer(port: port)

  }
  
  public func serialPortDidClose(_ serialPort: MTSerialPort) {
  }
  
  public func serialPortDidDetach(_ serialPort: MTSerialPort) {
  }
  
  private func scanBuffer(port:Int) {
    
    bufferLock[port].lock()
    
    let quit = isScanActive[port]
    
    if !quit {
      isScanActive[port] = true
    }
    
    bufferLock[port].unlock()
    
    if quit {
      return
    }
    
    while buffer[port].count >= 7 {
      
      var packet : [UInt8] = [buffer[port][0], buffer[port][1], buffer[port][2], buffer[port][3], buffer[port][4]]
      
      var index = 5
      var found = false
      
      while index < buffer[port].count - 3 {
        
        packet.append(buffer[port][index])
        
        if buffer[port][index] == 0x81 && buffer[port][index + 1] == 0x7f && buffer[port][index + 2] == 0x7f {
          found = true
          break
        }
        
        index += 1
      }
      
      if !found {
        break
      }
      
      buffer[port].removeFirst(packet.count)
      
      packetReceived(packet: LokPacket(packet: packet))

    }
    
    if !buffer[port].isEmpty {
      startTimer(port: port)
    }

    isScanActive[port] = false
    
  }
  
  private var isScanActive : [Bool] = [false, false]
  
  @objc func timerAction(_ sender:Timer) {
    
    let port = sender === timer[0] ? 0 : 1
    
    scanBuffer(port: port)
    
    if !buffer[port].isEmpty {
      
      bufferLock[port].lock()
      
      let quit = isScanActive[port]
      
      if !quit {
        isScanActive[port] = true
      }
      
      bufferLock[port].unlock()
      
      if quit {
        return
      }

      bufferLock[port].lock()

      var packet : LokPacket?
      
      if let byte = buffer[port].last, byte == 0x81 {
        packet = LokPacket(packet: buffer[port])
        buffer[port].removeAll()
      }
      
      bufferLock[port].unlock()

      if !buffer[port].isEmpty {
        startTimer(port: port)
      }
      
      isScanActive[port] = false
      
      if let packet {
        packetReceived(packet: packet)
      }

    }
    
  }
  
  func startTimer(port:Int, timeInterval:TimeInterval = 10.0 / 1000.0) {
    stopTimer(port: port)
    timer[port] = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(timerAction(_:)), userInfo: nil, repeats: false)
    RunLoop.current.add(timer[port]!, forMode: .common)
  }
  
  func stopTimer(port:Int) {
    timer[port]?.invalidate()
    timer[port] = nil
  }

  private var timer : [Timer?] = [nil, nil]
  
  private var bufferLock : [NSLock] = [NSLock(), NSLock()]

  private func packetReceived(packet:LokPacket) {
    
    var dump = "\(packet.isRX ? "RX: " : "TX: ") \(packet.hex)\n"

    dump += "\(packet.packetType)\n"

    // The following only works if this task sent the command
    
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
              debugLog("Unknown Buffer Data: 0x\(packet[5].toHex(numberOfDigits: 2))")
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
  
  public var payload : [UInt8] {
    var result : [UInt8] = []
    if packet.count > 9 {
      for index in 6 ... packet.count - 3 {
        result.append(packet[index])
      }
    }
    return result
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
