//
//  MonitorVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 27/11/2021.
//

import Foundation
import Cocoa

private enum TimeStampType : Int {
  case none = 0
  case millisecondsSinceLastMessage = 1
}

class MonitorVC: NSViewController, NSWindowDelegate, OpenLCBLocoNetMonitorDelegate {
  
  // MARK: Window & View Control
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
   
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }

  func windowWillClose(_ notification: Notification) {
    
    guard let monitorNode else {
      return
    }
    
    myTrainsController.openLCBNetworkLayer?.releaseLocoNetMonitor(monitor: monitorNode)
    
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
    
    self.view.window?.delegate = self
    
    self.view.window?.title = "LocoNet Monitor"
    
    if let monitorNode {
      self.view.window?.title = "\(monitorNode.userNodeName) (\(monitorNode.nodeId.toHexDotFormat(numberOfBytes: 6)))"
    }
    
    networkLayer = monitorNode!.networkLayer
    
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
    
  }
  
  // MARK: Private Properties
  
  private var updateLock : NSLock = NSLock()
  
  private var networkLayer : OpenLCBNetworkLayer?
  
  private var gatewayDS = ComboBoxSimpleDS()
  
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
  
  private var addLabels : Bool {
    get {
      return chkAddLabels.state == .on
    }
  }
  
  private var timeStampType : TimeStampType {
    get {
      return TimeStampType(rawValue: cboTimeStampType.indexOfSelectedItem) ?? .none
    }
  }
  
  private var addByteNumber : Bool {
    get {
      return chkAddByteNumber.state == .on
    }
  }
  
  private var numberBase : NumberBase {
    get {
      return NumberBase(rawValue: cboNumberBase.indexOfSelectedItem) ?? .hex
    }
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
    get {
      let sfn = sendFilename
      return sfn == "" ? nil : URL(fileURLWithPath: sfn)
    }
  }
  
  private var isPaused : Bool {
    get {
      return btnPauseMonitor.state == .on
    }
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
  
  // MARK: OpenLCBLocoNetMonitorDelegate Methods
  
  @objc public func locoNetGatewaysUpdated(monitorNode:OpenLCBLocoNetMonitorNode, gateways:[UInt64:String]) {
    
    gatewayDS.dictionary = gateways
    cboInterface.dataSource = gatewayDS
    cboInterface.reloadData()
    
    let gatewayId = UInt64(UserDefaults.standard.integer(forKey: DEFAULT.MONITOR_INTERFACE_ID))
    
    if let index = gatewayDS.indexWithKey(key: gatewayId) {
      cboInterface.selectItem(at: index)
      monitorNode.gatewayId = gatewayId
    }

  }

  @objc public func locoNetMessageReceived(message:LocoNetMessage) {

    var item : String = ""
    
    var byteNumber : Int = 0
    
    if addLabels {
      
      item += "\(message.messageType)\n"
      
      switch message.messageType {
      case .sensRepGenIn:
        item += "sensorAddress: \(message.sensorAddress!) sensorState: \(message.sensorState!)\n"
      case .setSw:
        item += "switchAddress: \(message.switchAddress!) switchState: \(message.swState!)\n"
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
    
    if !isPaused {
      
      txtMonitor.string += "\(item)\n"
      
      let maxSize = 1 << 15
      
      updateLock.lock()
      if txtMonitor.string.count > maxSize {
        var newString = ""
        let temp = txtMonitor.string.split(separator: "\n")
        var index = temp.count - 1
        while index >= 0 && newString.count < maxSize {
          newString = "\(temp[index])\n\(newString)"
          index -= 1
        }
        txtMonitor.string = newString
      }
      updateLock.unlock()
      
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
  }
  
  @IBAction func btnPauseMonitorAction(_ sender: NSButton) {
  }
  
  @IBOutlet weak var btnPauseMonitor: NSButton!
  
  @IBOutlet weak var btnTest: NSButton!
  
  @IBAction func btnTestAction(_ sender: NSButton) {
  }
  
}


