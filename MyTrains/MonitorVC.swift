//
//  MonitorVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 27/11/2021.
//

import Foundation
import Cocoa

class MonitorVC: NSViewController, NetworkMessengerDelegate, NSWindowDelegate {

  enum TimeStampType : Int {
    case none = 0
    case millisecondsSinceLastMessage = 1
  }
  
  enum NumberBase : Int {
    case hex = 0
    case decimal = 1
    case binary = 2
    case octal = 3
    case hexBinary = 4
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }

  func windowWillClose(_ notification: Notification) {
    if observerId != -1 {
      if let mess = messenger {
        mess.removeObserver(id: observerId)
        observerId = -1
      }
    }
  }
  
  override func viewWillAppear() {
    
    self.view.window?.delegate = self

    let interface = UserDefaults.standard.string(forKey: DEFAULT.MONITOR_INTERFACE_ID) ?? ""
 
    cboInterface.removeAllItems()
    var index = 0
    for x in networkController.networkMessengers {
      let path = x.value.devicePath
      cboInterface.addItem(withObjectValue: path)
      if interface == path {
        cboInterface.selectItem(at: index)
        messenger = x.value
        observerId = messenger?.addObserver(observer: self) ?? -1
      }
      index += 1
    }
    
    sendFilename = UserDefaults.standard.string(forKey: DEFAULT.MONITOR_SEND_FILENAME) ?? ""
    
    captureFilename = UserDefaults.standard.string(forKey: DEFAULT.MONITOR_CAPTURE_FILENAME) ?? ""
    
    chkCaptureActive.state = .off
    
    cboTimeStampType.selectItem(at: UserDefaults.standard.integer(forKey: DEFAULT.MONITOR_TIMESTAMP_TYPE))

    cboDataType.selectItem(at: UserDefaults.standard.integer(forKey: DEFAULT.MONITOR_DATA_TYPE))

    cboNumberBase.selectItem(at: UserDefaults.standard.integer(forKey: DEFAULT.MONITOR_NUMBER_BASE))

    chkAddByteNumber.state = NSControl.StateValue(UserDefaults.standard.integer(forKey: DEFAULT.MONITOR_ADD_BYTE_NUMBER))
 
    txtMessage1.stringValue = UserDefaults.standard.string(forKey: DEFAULT.MONITOR_MESSAGE1) ?? ""
    txtMessage2.stringValue = UserDefaults.standard.string(forKey: DEFAULT.MONITOR_MESSAGE2) ?? ""
    txtMessage3.stringValue = UserDefaults.standard.string(forKey: DEFAULT.MONITOR_MESSAGE3) ?? ""
    txtMessage4.stringValue = UserDefaults.standard.string(forKey: DEFAULT.MONITOR_MESSAGE4) ?? ""

    txtNote.stringValue = UserDefaults.standard.string(forKey: DEFAULT.MONITOR_NOTE) ?? ""

    txtMonitor.font = NSFont(name: "Menlo", size: 12)
  }
  
  private var observerId : Int = -1
  
  private var messenger : NetworkMessenger? = nil
  
  private var lastTime = Date.timeIntervalSinceReferenceDate
  
  func NetworkTimeOut(message: NetworkMessage) {
    print("Timeout")
  }

  func NetworkMessageReceived(message: NetworkMessage) {
    
    var item : String = ""
    var byteNumber : Int = 0
    
    let timeNow = Date.timeIntervalSinceReferenceDate
    
    switch timeStampType {
    case .millisecondsSinceLastMessage:
      let ms = (timeNow - lastTime) * 1000.0
      item += String(format:"%10.1f", ms) + "ms "
      lastTime = timeNow
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
      default:
        item += "0x\(String(format: "%02x", byte)) "
        break
      }
      
      if addByteNumber {
        item += "\n"
      }
    }
    
    if !isPaused {
      txtMonitor.string += "\(item)\n"
      let range = NSMakeRange(txtMonitor.string.count - 1, 0)
      txtMonitor.scrollRangeToVisible(range)
    }

    item += "\n"

    captureWrite(message: item)
    
  }
  
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
    get {
      let cfn = captureFilename
      return cfn == "" ? nil : URL(fileURLWithPath: cfn)
    }
  }
  
  private var isCaptureActive : Bool {
    get {
      return chkCaptureActive.state == .on
    }
  }
  
  @IBAction func cboInterfaceAction(_ sender: NSComboBox) {
    
    let path = cboInterface.stringValue
    
    UserDefaults.standard.set(path, forKey: DEFAULT.MONITOR_INTERFACE_ID)
    
    if let x = messenger {
      if path != x.devicePath && observerId != -1 {
        x.removeObserver(id: observerId)
      }
    }
    
    for x in networkController.networkMessengers {
      if x.value.devicePath == path {
        messenger = x.value
        observerId = messenger?.addObserver(observer: self) ?? -1
      }
    }
    
  }

  @IBOutlet weak var cboInterface: NSComboBox!
  
  @IBAction func swConnectAction(_ sender: NSSwitch) {
  }
  
  @IBOutlet weak var btnPowerOn: NSButton!
  
  @IBAction func btnPowerOnAction(_ sender: NSButton) {
    messenger?.powerOn()
  }
  
  @IBOutlet weak var btnPowerOff: NSButton!
  
  @IBAction func btnPowerOffAction(_ sender: NSButton) {
    messenger?.powerOff()
  }
  
  @IBOutlet weak var btnPowerPause: NSButton!
  
  @IBAction func btnPowerPauseAction(_ sender: NSButton) {
    messenger?.powerIdle()
  }
  
  @IBOutlet weak var lblSendFileName: NSTextField!
  
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
    get {
      let sfn = sendFilename
      return sfn == "" ? nil : URL(fileURLWithPath: sfn)
    }
  }

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
    dialog.allowedFileTypes          = ["txt", "snd"]
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
          sendMessage(rawMessage: String(line))
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
    dialog.allowedFileTypes     = ["txt", "cap"]
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
  
  private var timeStampType : TimeStampType {
    get {
      return TimeStampType(rawValue: cboTimeStampType.indexOfSelectedItem) ?? .none
    }
  }
  
  @IBOutlet weak var cboDataType: NSComboBox!
  
  @IBAction func cboDataTypeAction(_ sender: NSComboBox) {
    UserDefaults.standard.set(cboDataType.indexOfSelectedItem, forKey: DEFAULT.MONITOR_DATA_TYPE)
  }
  
  @IBOutlet weak var cboNumberBase: NSComboBox!
  
  @IBAction func cboNumberBaseAction(_ sender: NSComboBox) {
    UserDefaults.standard.set(cboNumberBase.indexOfSelectedItem, forKey: DEFAULT.MONITOR_NUMBER_BASE)
  }
  
  private var numberBase : NumberBase {
    get {
      return NumberBase(rawValue: cboNumberBase.indexOfSelectedItem) ?? .hex
    }
  }
  
  @IBOutlet weak var chkAddByteNumber: NSButton!
  
  @IBAction func cboAddByteNumberAction(_ sender: NSButton) {
    UserDefaults.standard.set(chkAddByteNumber.state.rawValue, forKey: DEFAULT.MONITOR_ADD_BYTE_NUMBER)
  }
  
  private var addByteNumber : Bool {
    get {
      return chkAddByteNumber.state == .on
    }
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
    sendMessage(rawMessage: txtMessage1.stringValue)
  }
  
  @IBAction func btnSendMessage2(_ sender: NSButton) {
    sendMessage(rawMessage: txtMessage2.stringValue)
  }
  
  @IBAction func btnSendMessage3(_ sender: NSButton) {
    sendMessage(rawMessage: txtMessage3.stringValue)
  }
  
  @IBAction func btnSendMessage4(_ sender: NSButton) {
    sendMessage(rawMessage: txtMessage4.stringValue)
  }
  
  private func sendMessage(rawMessage:String) {
    
    var good = true
    
    let parts = rawMessage.split(separator: " ")
    
    var numbers : [Int] = []
    
    var index = 0
    
    for p in parts {
      
      let part = String(p)
      
      if part.prefix(2) == "0x" {
        if let nn = Int(part.suffix(part.count-2), radix: 16) {
          numbers.append(nn)
        }
        else {
          good = false
        }
      }
      else if part.prefix(2) == "0b" {
        if let nn = Int(part.suffix(part.count-2), radix: 2) {
          numbers.append(nn)
       }
        else {
          good = false
        }
      }
      else if part.prefix(1) == "0" {
        if let nn = Int(part.suffix(part.count), radix: 8) {
          numbers.append(nn)
       }
        else {
          good = false
        }
      }
      else {
        if let nn = Int(part.suffix(part.count), radix: 10) {
          numbers.append(nn)
        }
        else {
          good = false
        }
      }
      
      if good {
        let test = numbers[index]
        if test < 0 || (index == 0 && test > 255) || (index > 0 && test > 127) || (index == 0 && (test & 0x80 == 0) ) {
          good = false
        }
      }
      
      index += 1
      
    }
    
    if good {
      if let messenger = messenger {
        let message = NetworkMessage(interfaceId: messenger.id, data: numbers, appendCheckSum: true)
        messenger.addToQueue(message: message, delay: TIMING.STANDARD, response: [.acknowledgement, .locoSlotDataV1], delegate: self, retryCount: 10)
      }
    }

  }
  
  @IBOutlet weak var scvMonitor: NSScrollView!
 
  @IBOutlet var txtMonitor: NSTextView!
  
  @IBAction func btnClearMonitorAction(_ sender: NSButton) {
    txtMonitor.string = ""
  }
  
  @IBAction func btnPauseMonitorAction(_ sender: NSButton) {
  }
  
  @IBOutlet weak var btnPauseMonitor: NSButton!
  
  private var isPaused : Bool {
    get {
      return btnPauseMonitor.state == .on
    }
  }
  
}


