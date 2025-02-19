//
//  MonitorVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 27/11/2021.
//

import Foundation
import AppKit
import ORSSerial
import SGDCC

private enum TimeStampType : Int {
  case none = 0
  case millisecondsSinceLastMessage = 1
}

class MonitorVC: MyTrainsViewController, OpenLCBLocoNetMonitorDelegate, MyTrainsAppDelegate, ORSSerialPortDelegate {
  
  func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
    
  }
  
  var snifferBuffer : String = ""
  var processingSniffer = false
  var snifferLock = NSLock()
  
  func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
    
    var bytes : [UInt8] = []
    bytes.append(contentsOf: data)
    bytes.append(0)
    snifferBuffer += String(cString: bytes)
    
    snifferLock.lock()
    
    var ok = !processingSniffer
    
    if ok {
      processingSniffer = true
    }
    
    snifferLock.unlock()
    
    if !ok {
      return
    }
    
    while snifferBuffer.count >= 6 {
      
      var found = false
      
      while snifferBuffer.count > 0 {
        if snifferBuffer.prefix(1) == "[" {
          found = true
          break
        }
        snifferBuffer.removeFirst(1)
      }
      
      if !found {
        break
      }
      
      var message = ""
      
      found = false
      
      for char in snifferBuffer {
        message += String(char)
        if char == "]" {
          found = true
          break
        }
      }
      
      if !found {
        break
      }
      
      snifferBuffer.removeFirst(message.count)

      message.removeFirst(1)
      message.removeLast(1)
      
      var packet : [UInt8] = []
      
      while !message.isEmpty {
        packet.append(UInt8(hex: message.prefix(2))!)
        message.removeFirst(2)
      }
      
      var item = ""
      
      if let dccPacket = SGDCCPacket(packet: packet) {
        item = dccPacket.packetType.title
      }

      if !item.isEmpty {
        
        lineBuffer.append(item)
        
        while lineBuffer.count > 500 {
          lineBuffer.removeFirst()
        }
        
        
        // https://www.locgeek.com/2013/01/hands-on-uhlenbrock-marco-railcomloconet/
        // THIS LINK IS FOR GOOD INFO ON UhlenBrock 68510 MARCo Receiver
        // See also YaMoRc site
        
        if !isPaused {
          
          var newString = ""

          for line in lineBuffer {
            newString += "\(line)\n"
          }

          txtMonitor.string = "\(newString)"
          
          let range = NSMakeRange(txtMonitor.string.count - 1, 0)

          txtMonitor.scrollRangeToVisible(range)
          
        }

        item += "\n"

        captureWrite(message: item)
        
      }
      
    }
    
    snifferLock.lock()
    processingSniffer = false
    snifferLock.unlock()

  }


  
  // MARK: Window & View Control
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewType = .locoNetTrafficMonitor
  }

  override func windowWillClose(_ notification: Notification) {
    
    guard monitorNode != nil else {
      return
    }
    
//    appDelegate.networkLayer?.releaseLocoNetMonitor(monitor: monitorNode)
    
    appNode?.removeObserver(observerId: observerId)
    
    super.windowWillClose(notification)
    
  }
  
  private enum NumberBase : Int {
    case hex = 0
    case decimal = 1
    case binary = 2
    case octal = 3
    case hexBinary = 4
    case character = 5
  }
  
  override func viewWillAppear() {
    
    super.viewWillAppear()
    
    let x1 : UInt32 = 9999
    
    self.view.window?.title = "LocoNet Monitor"
    
    if let monitorNode {
      self.view.window?.title = "\(monitorNode.userNodeName) (\(monitorNode.nodeId.dotHex(numberOfBytes: 6)))"
    }
    
    monitorNode?.delegate = self

    sendFilename = UserDefaults.standard.string(forKey: DEFAULT.MONITOR_SEND_FILENAME) ?? ""
    
    captureFilename = UserDefaults.standard.string(forKey: DEFAULT.MONITOR_CAPTURE_FILENAME) ?? ""
    
    chkCaptureActive.state = .off
    
    cboTimeStampType.selectItem(at: UserDefaults.standard.integer(forKey: DEFAULT.MONITOR_TIMESTAMP_TYPE))

    cboNumberBase.selectItem(at: UserDefaults.standard.integer(forKey: DEFAULT.MONITOR_NUMBER_BASE))

    chkAddByteNumber.state = NSControl.StateValue(UserDefaults.standard.integer(forKey: DEFAULT.MONITOR_ADD_BYTE_NUMBER))
 
    chkAddLabels.state = NSControl.StateValue(UserDefaults.standard.integer(forKey: DEFAULT.MONITOR_ADD_LABELS))
 
    txtMessage1.stringValue = UserDefaults.standard.string(forKey: DEFAULT.MONITOR_MESSAGE1) ?? ""
    txtMessage2.stringValue = UserDefaults.standard.string(forKey: DEFAULT.MONITOR_MESSAGE2) ?? ""
    txtMessage3.stringValue = UserDefaults.standard.string(forKey: DEFAULT.MONITOR_MESSAGE3) ?? ""
    txtMessage4.stringValue = UserDefaults.standard.string(forKey: DEFAULT.MONITOR_MESSAGE4) ?? ""

    txtNote.stringValue = UserDefaults.standard.string(forKey: DEFAULT.MONITOR_NOTE) ?? ""

    txtMonitor.font = NSFont(name: "Menlo", size: 12)
    
    observerId = appNode!.addObserver(observer: self)
    
    dccSniffer = ORSSerialPort(path: "/dev/cu.usbmodem14101")
    
    if let dccSniffer {
      dccSniffer.baudRate = 115200
      dccSniffer.numberOfDataBits = 8
      dccSniffer.numberOfStopBits = 1
      dccSniffer.parity = .none
      dccSniffer.open()
      dccSniffer.delegate = self
    }
    
  }
  
  // MARK: Private Properties
  
  private var observerId : Int = -1
  
  private var updateLock : NSLock = NSLock()
  
  private var gatewayDS = ComboBoxNodeDS()
  
  private var lineBuffer : [String] = []
  
  private var dccSniffer : ORSSerialPort?
  
  private var captureFilename : String {
    get {
      return lblCaptureFileName.stringValue
    }
    set(value) {
      lblCaptureFileName.stringValue = value
      UserDefaults.standard.set(value, forKey: DEFAULT.MONITOR_CAPTURE_FILENAME)
      let controlsEnabled = value != ""
      btnEditCaptureFile.isEnabled = controlsEnabled
      chkCaptureActive.isEnabled = controlsEnabled
      txtNote.isEnabled = controlsEnabled
      btnNote.isEnabled = controlsEnabled
    }
  }
  
  private var captureURL : URL? {
    let cfn = captureFilename
    return cfn == "" ? nil : URL(fileURLWithPath: cfn)
  }
  
  private var isCaptureActive : Bool {
    return chkCaptureActive.state == .on
  }
  
  private var addLabels : Bool {
    return chkAddLabels.state == .on
  }
  
  private var timeStampType : TimeStampType {
    return TimeStampType(rawValue: cboTimeStampType.indexOfSelectedItem) ?? .none
  }
  
  private var addByteNumber : Bool {
    return chkAddByteNumber.state == .on
  }
  
  private var numberBase : NumberBase {
    return NumberBase(rawValue: cboNumberBase.indexOfSelectedItem) ?? .hex
  }
  
  private var sendFilename : String {
    get {
      return lblSendFileName.stringValue
    }
    set(value) {
      lblSendFileName.stringValue = value
      UserDefaults.standard.set(value, forKey: DEFAULT.MONITOR_SEND_FILENAME)
      let controlsEnabled = value != ""
      btnEditSendFile.isEnabled = controlsEnabled
      btnSendFile.isEnabled = controlsEnabled
   }
  }

  private var sendURL : URL? {
    let sfn = sendFilename
    return sfn == "" ? nil : URL(fileURLWithPath: sfn)
  }
  
  private var isPaused : Bool {
    return btnPauseMonitor.state == .on
  }
  
  // MARK: Public Properties
  
  public var monitorNode : OpenLCBLocoNetMonitorNode?

  // MARK: Private Methods
  
  private func captureWrite(message:String) {
    
    let data = message.data(using: String.Encoding.utf8)
    
    if isCaptureActive {
      if FileManager.default.fileExists(atPath: lblCaptureFileName.stringValue) {
        
        if let fileHandle = try? FileHandle(forWritingTo: captureURL!) {
          fileHandle.seekToEndOfFile()
          fileHandle.write(data!)
          fileHandle.closeFile()
        }
      }
      else {
         try? data!.write(to: captureURL!, options: .atomicWrite)
       }
    }
    
  }
  
  private func sendMessage(rawMessage:String, isLocoNet:Bool) {
    
    var good = true
    
    let parts = rawMessage.split(separator: " ")
    
    var numbers : [UInt8] = []
    
    var index = 0
    
    for p in parts {
      
      let part = String(p)
      
      if part.prefix(2) == "0x" {
        if let nn = UInt8(part.suffix(part.count-2), radix: 16) {
          numbers.append(nn)
        }
        else {
          good = false
        }
      }
      else if part.prefix(2) == "0b" {
        if let nn = UInt8(part.suffix(part.count-2), radix: 2) {
          numbers.append(nn)
       }
        else {
          good = false
        }
      }
      else if part.prefix(1) == "0" {
        if let nn = UInt8(part.suffix(part.count), radix: 8) {
          numbers.append(nn)
       }
        else {
          good = false
        }
      }
      else {
        if let nn = UInt8(part.suffix(part.count), radix: 10) {
          numbers.append(nn)
        }
        else {
          good = false
        }
      }
      
      if good && isLocoNet {
        let test = numbers[index]
        if test < 0 || (index == 0 && test > 255) || (index > 0 && test > 127) || (index == 0 && (test & 0x80 == 0) ) {
          good = false
        }
      }
      
      index += 1
      
    }
    
    if good, let monitorNode {
      let message = LocoNetMessage(data: numbers, appendCheckSum: true)
      monitorNode.sendMessage(message: message)
    }

  }
  
  // MARK: MyTrainsAppDelegate Methods
  
  @objc func locoNetGatewayListUpdated(appNode: OpenLCBNodeMyTrains) {
    
    gatewayDS.dictionary = appNode.locoNetGateways
    cboInterface.dataSource = gatewayDS
    cboInterface.reloadData()
    
    let gatewayId = UInt64(UserDefaults.standard.integer(forKey: DEFAULT.MONITOR_INTERFACE_ID))
    
    if let index = gatewayDS.indexWithKey(key: gatewayId) {
      cboInterface.selectItem(at: index)
      monitorNode?.gatewayId = gatewayId
    }
    
  }
  
  // MARK: OpenLCBLocoNetMonitorDelegate Methods
  
  @objc public func locoNetMessageReceived(message:LocoNetMessage) {

    var item : String = ""
    
    var byteNumber : Int = 0
    
    if addLabels {
      
      item += "\(message.messageType)\n"
      
      switch message.messageType {
        /*
      case .getQuerySlot:
        let slot = message.message[1] & 0x07
        var data : [UInt8] = [
          0xe6,
          0x15,
          0x01,
          0x78 + slot,
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
          0x1d,
          0x00,
          0x1d,
          0x00,
          0x10,
          0x00,
          
        ]
        switch slot {
        case 0:
          data[4] = 0b00000000
          data[5] = 0b00100000
          data[6] = UInt8(6998 & 0x7f)
          data[7] = UInt8((6998 >> 7) & 0x7f)
          data[8] = UInt8(6997 & 0x7f)
          data[9] = UInt8((6997 >> 7) & 0x7f)
          data[10] = UInt8(6996 & 0x7f)
          data[11] = UInt8((6996 >> 7) & 0x7f)
          data[12] = UInt8(6995 & 0x7f)
          data[13] = UInt8((6995 >> 7) & 0x7f)
          data[14] = UInt8(6997 & 0x7f)
          data[15] = UInt8((6997 >> 7) & 0x7f)
          data[16] = 0b00001110 // 1.6
          data[17] = 0b00010010 // 2.2
        case 1:
          data[4] = 60 // 12V
          data[5] = 70 // 14V
          data[6] = 2 // 20A
          data[7] = 50 // 5A
          data[10] = 77 // 15.4v
          data[12] = 45 // 9v
          data[14] = UInt8(6997 & 0x7f)
          data[15] = UInt8((6997 >> 7) & 0x7f)
        case 2:
          data[4] = UInt8(9999 & 0x7f)
          data[5] = UInt8((9999 >> 7) & 0x7f)
          data[6] = UInt8(9998 & 0x7f)
          data[7] = UInt8((9998 >> 7) & 0x7f)
          data[8] = UInt8(9997 & 0x7f)
          data[9] = UInt8((9997 >> 7) & 0x7f)
          data[10] = UInt8(9996 & 0x7f)
          data[11] = UInt8((9996 >> 7) & 0x7f)
          data[12] = UInt8(9995 & 0x7f)
          data[13] = UInt8((9995 >> 7) & 0x7f)
          data[14] = UInt8(7997 & 0x7f)
          data[15] = UInt8((7997 >> 7) & 0x7f)
        case 3:
          data[4] = UInt8(7999 & 0x7f)
          data[5] = UInt8((7999 >> 7) & 0x7f)
          data[6] = UInt8(7998 & 0x7f)
          data[7] = UInt8((7998 >> 7) & 0x7f)
        case 4:
          data[4] = UInt8(8999 & 0x7f)
          data[5] = UInt8((8999 >> 7) & 0x7f)
          data[6] = UInt8(8998 & 0x7f)
          data[7] = UInt8((8998 >> 7) & 0x7f)
          data[16] = UInt8(8997 & 0x7f)
          data[17] = UInt8((8997 >> 7) & 0x7f)
        default:
          break
        }
        let newMessage = LocoNetMessage(data: data, appendCheckSum: true)
        monitorNode?.sendMessage(message: newMessage)
         */
      case .locoSlotDataP1, .setLocoSlotDataP1:
        item += "slot: \(message.slotNumber!) speed:\(message.speed!)\nlocoAddress: \(message.locomotiveAddress!) decoderType: \(message.mobileDecoderType!.title) slotState: \(message.slotState!.title)  consistState: \(message.consistState!.title)\n"
      case .locoSlotDataP2, .setLocoSlotDataP2:
        item += "slot: \(message.slotNumber!) speed:\(message.speed!)\nlocoAddress: \(message.locomotiveAddress!) decoderType: \(message.mobileDecoderType!.title) slotState: \(message.slotState!.title)  consistState: \(message.consistState!.title)\n"
      case .locoSpdP1:
        item += "slot: \(message.slotNumber!) speed:\(message.speed!)\n"
      case .locoSpdDirP2:
        item += "slot: \(message.slotNumber!) speed:\(message.speed!)\n"
      case .getDataFormatU:
        item += "locoAddress: \(message.locomotiveAddress!)\n"
      case .setDataFormatU, .dataFormatU:
        item += "locoAddress: \(message.locomotiveAddress!) decoderType: \(message.mobileDecoderType!.title)\n"
      case .readCVU:
        item += "CV#: \(message.cvNumber!)\n"
      case .writeCVU:
        item += "CV#: \(message.cvNumber!) cvValue: \(message.cvValue!)\n"
      case .lncvDataU:
        item += "partNumber: \(message.partNumber!) cv: \(message.cvNumber!) value: \(message.lncvValue!)\n"
      case .setLNCVU:
        item += "partNumber: \(message.partNumber!) lncv: \(message.cvNumber!) lncvValue: \(message.lncvValue!)\n"
      case .getLNCVU:
        item += "partNumber: \(message.partNumber!) moduleAddr: \(message.moduleAddress!) cv: \(message.cvNumber!)\n"
      case .progOnMainU:
        item += "locoAddress: \(message.locomotiveAddress!) cv: \(message.cvNumber!) value: \(message.cvValue!)\n"
      case .pmRepBXPA1:
        item += "boardID: \(message.boardId!)\n"
      case .sensRepGenIn:
        item += "sensorAddress: \(message.sensorAddress!) sensorState: \(message.sensorState!)\n"
      case .setSw:
        item += "switchAddress: \(message.switchAddress!)\n"
      case .s7Info, .setS7BaseAddr:
        item += "productCode: \(message.productCode!) serialNumber: \(UInt16(message.serialNumber!).hex(numberOfBytes: 2)!) baseAddress: \(message.baseAddress!)\n"
      case .s7CVState:
        item += "cvValue: \(message.cvValue!)\n"
      case .immPacket, .s7CVRW:
        var result = ""
        for byte in message.dccPacket!.packet {
          result += "\(byte.hex()) "
        }
        item += "repeat: \(message.immPacketRepeatCount!) dccPacket: \(result) "
        /*
        if let address = message.dccBasicAccessoryDecoderAddress, let cvNumber = message.cvNumber, let cvValue = message.cvValue {
          item += " decoderAddress: \(address) cvNumber: \(cvNumber) accessMode: \(message.dccCVAccessMode!) cvValue: \(cvValue)"
        }
         */
        
        item += "\n"
        
      default:
        break
      }
            
    }
    
    switch timeStampType {
    case .millisecondsSinceLastMessage:
      let ms = (message.timeSinceLastMessage) * 1000.0
      item += String(format:"%10.1f", ms) + "ms "
      break
    default:
      break
    }
    
    for byte in message.message {
      
      if addByteNumber {
        
        item += "<D\(byteNumber)> "
        
        byteNumber += 1
        
      }
      
      switch numberBase {
      case .binary:
        var padded = String(byte, radix: 2)
        for _ in 0..<(8 - padded.count) {
          padded = "0" + padded
        }
        item += "0b" + padded + " "
        break
      case .decimal:
        item += "\(String(format: "%d", byte)) "
        break
      case .octal:
        item += "\(String(format: "%03o", byte)) "
        break
      case .hexBinary:
        var padded = String(byte, radix: 2)
        for _ in 0..<(8 - padded.count) {
          padded = "0" + padded
        }
        item += "0x\(String(format: "%02x", byte)) " + "0b" + padded + " "
        break
      case .character:
        item += String(format:"%C", byte)
      default:
        item += "0x\(String(format: "%02x", byte)) "
        break
      }
      
      if addByteNumber {
        item += "\n"
      }
    }
    
    if !item.isEmpty {
      lineBuffer.append(item)
      
      while lineBuffer.count > 2000 {
        lineBuffer.removeFirst()
      }
    }
    
    if !isPaused {
      
      var newString = ""

      for line in lineBuffer {
        newString += "\(line)\n\n"
      }

      txtMonitor.string = "\(newString)"
      
      let range = NSMakeRange(txtMonitor.string.count - 1, 0)

      txtMonitor.scrollRangeToVisible(range)
      
    }

    item += "\n"

    captureWrite(message: item)

  }

  // MARK: Outlets & Actions
  
  @IBAction func cboInterfaceAction(_ sender: NSComboBox) {
    
    let id = gatewayDS.keyForItemAt(index: cboInterface.indexOfSelectedItem)
    
    UserDefaults.standard.set(id, forKey: DEFAULT.MONITOR_INTERFACE_ID)

    if let id, let monitorNode {
      monitorNode.gatewayId = id
    }

  }

  @IBOutlet weak var cboInterface: NSComboBox!
    
  @IBOutlet weak var lblSendFileName: NSTextField!
  
  @IBOutlet weak var btnSendFile: NSButton!
  
  @IBAction func btnSelectSendFileAction(_ sender: NSButton) {
    
    let dialog = NSOpenPanel()
    
    dialog.title                     = "Send File"
    dialog.showsResizeIndicator      = true
    dialog.showsHiddenFiles          = false
    dialog.canChooseDirectories      = false
    dialog.canCreateDirectories      = true
    dialog.allowsMultipleSelection   = false
    dialog.canChooseFiles            = true
//    dialog.allowedFileTypes          = ["txt", "snd"]
    dialog.allowedContentTypes       = [.text]
    dialog.allowsOtherFileTypes      = true
    
    if let url = sendURL {
      dialog.nameFieldStringValue = url.lastPathComponent
    }
    
    if dialog.runModal() == .OK {
      
      if let result = dialog.url {
        sendFilename = result.path
      }
      else {
      // User clicked on "Cancel"
      }
    }
  
  }
  
  @IBOutlet weak var btnEditSendFile: NSButton!
  
  @IBAction func btnEditSendFileAction(_ sender: NSButton) {
    Process.launchedProcess(launchPath: "/usr/bin/open", arguments: [
        "-a",
        "TextEdit",
        sendFilename
    ])
 
  }
  
  @IBAction func btnSendFileAction(_ sender: NSButton) {
    
    if FileManager.default.fileExists(atPath: sendFilename) {
      
      if let _ = FileHandle(forReadingAtPath: sendFilename) {
        
        let contents = try! String(contentsOfFile: sendFilename)

        let lines = contents.split(separator:"\n")

        for line in lines {
          sendMessage(rawMessage: String(line), isLocoNet: true)
       }
        
      }
    }

  }
  
  @IBAction func btnSelectCaptureFileAction(_ sender: NSButton) {
    
    let dialog = NSSavePanel()
    
    dialog.title                = "Capture File"
    dialog.showsResizeIndicator = true
    dialog.showsHiddenFiles     = false
    dialog.canCreateDirectories = true
//    dialog.allowedFileTypes     = ["txt", "cap"]
    dialog.allowedContentTypes  = [.text]
    dialog.allowsOtherFileTypes = true
    
    if let url = captureURL {
      dialog.nameFieldStringValue = url.lastPathComponent
    }
    
    if dialog.runModal() == .OK {
      
      if let result = dialog.url {
        captureFilename = result.path
      }
      else {
      // User clicked on "Cancel"
      }
      
      chkCaptureActive.isEnabled = lblCaptureFileName.stringValue != ""
      
    }
  }
  
  @IBOutlet weak var lblCaptureFileName: NSTextField!
  
  @IBOutlet weak var btnEditCaptureFile: NSButton!
  
  @IBAction func btnEditCaptureFileAction(_ sender: NSButton) {
    Process.launchedProcess(launchPath: "/usr/bin/open", arguments: [
        "-a",
        "TextEdit",
        captureFilename
    ])
  }
  
  @IBOutlet weak var chkAddLabels: NSButton!
  
  @IBAction func chkAddLabelsAction(_ sender: NSButton) {
    UserDefaults.standard.set(chkAddLabels.state.rawValue, forKey: DEFAULT.MONITOR_ADD_LABELS)
  }
  
  @IBOutlet weak var chkCaptureActive: NSButton!
  
  @IBAction func chkCaptureActiveAction(_ sender: NSButton) {
  }
  
  @IBOutlet weak var txtNote: NSTextField!
  
  @IBAction func txtNoteAction(_ sender: NSTextField) {
    UserDefaults.standard.set(txtNote.stringValue, forKey: DEFAULT.MONITOR_NOTE)
  }
  
  @IBOutlet weak var btnNote: NSButton!
  
  @IBAction func btnNoteAction(_ sender: NSButton) {
    captureWrite(message: "\(txtNote.stringValue)\n")
  }
  
  @IBOutlet weak var cboTimeStampType: NSComboBox!
  
  @IBAction func cboTimeStampTypeAction(_ sender: NSComboBox) {
    UserDefaults.standard.set(cboTimeStampType.indexOfSelectedItem, forKey: DEFAULT.MONITOR_TIMESTAMP_TYPE)
  }
  
  @IBOutlet weak var cboNumberBase: NSComboBox!
  
  @IBAction func cboNumberBaseAction(_ sender: NSComboBox) {
    UserDefaults.standard.set(cboNumberBase.indexOfSelectedItem, forKey: DEFAULT.MONITOR_NUMBER_BASE)
  }
  
  @IBOutlet weak var chkAddByteNumber: NSButton!
  
  @IBAction func cboAddByteNumberAction(_ sender: NSButton) {
    UserDefaults.standard.set(chkAddByteNumber.state.rawValue, forKey: DEFAULT.MONITOR_ADD_BYTE_NUMBER)
  }
  
  @IBOutlet weak var txtMessage1: NSTextField!
  
  @IBAction func txtMessage1Action(_ sender: NSTextField) {
    UserDefaults.standard.set(txtMessage1.stringValue, forKey: DEFAULT.MONITOR_MESSAGE1)
  }
  
  @IBOutlet weak var txtMessage2: NSTextField!
  
  @IBAction func txtMessage2Action(_ sender: NSTextField) {
    UserDefaults.standard.set(txtMessage2.stringValue, forKey: DEFAULT.MONITOR_MESSAGE2)
  }
  
  @IBOutlet weak var txtMessage3: NSTextField!
  
  @IBAction func txtMessage3Action(_ sender: NSTextField) {
    UserDefaults.standard.set(txtMessage3.stringValue, forKey: DEFAULT.MONITOR_MESSAGE3)
  }
  
  @IBOutlet weak var txtMessage4: NSTextField!
  
  @IBAction func txtMessage4Action(_ sender: NSTextField) {
    UserDefaults.standard.set(txtMessage4.stringValue, forKey: DEFAULT.MONITOR_MESSAGE4)
  }
  
  @IBAction func btnSendMessage1(_ sender: NSButton) {
    sendMessage(rawMessage: txtMessage1.stringValue, isLocoNet: true)
  }
  
  @IBAction func btnSendMessage2(_ sender: NSButton) {
    sendMessage(rawMessage: txtMessage2.stringValue, isLocoNet: true)
  }
  
  @IBAction func btnSendMessage3(_ sender: NSButton) {
    sendMessage(rawMessage: txtMessage3.stringValue, isLocoNet: true)
  }
  
  @IBAction func btnSendMessage4(_ sender: NSButton) {
    sendMessage(rawMessage: txtMessage4.stringValue, isLocoNet: true)
  }
  
  @IBOutlet weak var scvMonitor: NSScrollView!
 
  @IBOutlet var txtMonitor: NSTextView!
  
  @IBAction func btnClearMonitorAction(_ sender: NSButton) {
    txtMonitor.string = ""
    lineBuffer.removeAll()
  }
  
  @IBAction func btnPauseMonitorAction(_ sender: NSButton) {
  }
  
  @IBOutlet weak var btnPauseMonitor: NSButton!
  
  @IBOutlet weak var btnTest: NSButton!
  
  @IBAction func btnTestAction(_ sender: NSButton) {
  }
  
}


