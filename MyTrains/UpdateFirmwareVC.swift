//
//  UpdateFirmwareVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/05/2022.
//

import Foundation
import Cocoa

class UpdateFirmwareVC: NSViewController, NSWindowDelegate, InterfaceDelegate, DMFDelegate {

  // MARK: Window & View Control
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }

  func windowWillClose(_ notification: Notification) {
    
    if observerId != -1 {
      interface?.removeObserver(id: observerId)
      observerId = -1
    }
    
  }

  override func viewWillAppear() {
    
    self.view.window?.delegate = self
    
    interfacesUpdated(interfaces: networkController.networkInterfaces)

//    dmfPath = UserDefaults.standard.string(forKey: DEFAULT.IPL_DMF_FILENAME) ?? ""
    
    setupControls()
    
  }
  
  // MARK: Private Properties
  
  private var observerId : Int = -1
  
  private var interface : Interface? = nil
  
  private var timer : Timer?
  
  private var dmf : DMF?
  
  private var _dmfPath : String = ""
  
  private enum Mode {
    case idle
    case setup
    case erase
    case setaddr
    case dataload
    case endProgBlock
  }
  
  
  private var setAddrTotal : TimeInterval = 0.0
  
  private var setAddrCount : Int = 0
  
  private var loadDelayTotal : TimeInterval = 0.0
  
  private var loadDelayCount : Int = 0
  
  private var progBlockDelayTotal : TimeInterval = 0.0
  
  private var progBlockDelayCount : Int = 0
  
  private var lastTimeStamp : TimeInterval = 0.0
  
  private var chunkCount : Int = 0
  
  private var loadCount : Int = 0
  
  private var mode : Mode = .idle
  
  private var dmfPath : String {
    get {
      return _dmfPath
    }
    set(value) {
      _dmfPath = value
      lblDMF.stringValue = dmfURL?.lastPathComponent ?? ""
      UserDefaults.standard.set(value, forKey: DEFAULT.IPL_DMF_FILENAME)
      mode = .idle
   }
  }

  private var dmfURL : URL? {
    get {
      let sfn = _dmfPath
      return sfn == "" ? nil : URL(fileURLWithPath: sfn)
    }
  }
  
  // MARK: Private Methods
  
  private func setupControls() {
    
    let noPath = dmfURL == nil
    
    tabView.isHidden = noPath
    
    btnStart.isEnabled = !noPath
    
    btnCancel.isEnabled = !noPath
    
    
    
  }
  
  func interfacesUpdated(interfaces: [Interface]) {
    
    if observerId != -1 {
      self.interface?.removeObserver(id: observerId)
      observerId = -1
    }
    
    let interfaceId = UserDefaults.standard.string(forKey: DEFAULT.IPL_INTERFACE_ID) ?? ""

    cboInterface.removeAllItems()
    cboInterface.deselectItem(at: cboInterface.indexOfSelectedItem)
    
    for interface in interfaces {
      
      let name = interface.deviceName
      
      cboInterface.addItem(withObjectValue: name)
      
      if interfaceId == name {
        cboInterface.selectItem(at: cboInterface.numberOfItems-1)
        self.interface = interface
        observerId = interface.addObserver(observer: self)
      }
      
    }
    
  }
  
  // MARK: DMFDelegate Methods
  
  func update(progress: Double) {
    btnStart.isEnabled = false
    barProgress.isHidden = false
    barProgress.doubleValue = progress
  }
  
  func aborted() {
    barProgress.isHidden = true
    btnStart.isEnabled = true
  }
  
  func completed() {
    barProgress.isHidden = true
    btnStart.isEnabled = true
  }
  
  // MARK: InterfaceDelegate Methods
  
  @objc func networkMessageReceived(message:NetworkMessage) {
    
    if let dmf = self.dmf {
      
      switch message.messageType {
      case .iplSetup:
     
        if mode != .idle && mode != .setup {
          mode = .idle
        }
        
        if dmf.bootloaderVersion == 2 {
          
          if mode == .idle {
            mode = .setup
            setAddrTotal = 0.0
            setAddrCount = 0
            loadDelayTotal = 0.0
            loadDelayCount = 0
            progBlockDelayTotal = 0.0
            progBlockDelayCount = 0
          }
          else {
            let delay = (message.timeStamp - lastTimeStamp) * 1000.0
            lblSetupDelay.stringValue = String(format: "%1.1f", delay)
            mode = .erase
          }
          

        }
        else {
          mode = .erase
          setAddrTotal = 0.0
          setAddrCount = 0
          loadDelayTotal = 0.0
          loadDelayCount = 0
          progBlockDelayTotal = 0.0
          progBlockDelayCount = 0
        }
        
        lastTimeStamp = message.timeStamp

      case .iplSetAddr:
        
        if dmf.bootloaderVersion == 2 {

          let delay = (message.timeStamp - lastTimeStamp) * 1000.0
          
          loadCount = dmf.chunkSize / 8

          if mode == .erase {
            lblEraseDelayActual.stringValue = String(format: "%1.1f", delay)
            chunkCount = dmf.chunksPerProgBlock
          }
          else {
            chunkCount -= 1
            if chunkCount == 0 {
              chunkCount = dmf.chunksPerProgBlock
              progBlockDelayTotal += delay
              progBlockDelayCount += 1
              let average = progBlockDelayTotal / Double(progBlockDelayCount)
              lblEndOfProgBlockDelay.stringValue = String(format: "%1.1f", average)
            }
            else {
              loadDelayTotal += delay
              loadDelayCount += 1
              let average = loadDelayTotal / Double(loadDelayCount)
              lblDataLoadDelay.stringValue = String(format: "%1.1f", average)
           }
            
          }

        }
        else {
          
          let delay = (message.timeStamp - lastTimeStamp) * 1000.0
          
          loadCount = dmf.chunkSize / 8

          if mode == .erase {
            lblEraseDelayActual.stringValue = String(format: "%1.1f", delay)
            chunkCount = dmf.chunksPerProgBlock
          }
          else {
            progBlockDelayTotal += delay
            progBlockDelayCount += 1
            let average = progBlockDelayTotal / Double(progBlockDelayCount)
            lblEndOfProgBlockDelay.stringValue = String(format: "%1.1f", average)
          }

        }
        
        mode = .setaddr

        lastTimeStamp = message.timeStamp

      case .iplDataLoad:

        let delay = (message.timeStamp - lastTimeStamp) * 1000.0

        if dmf.bootloaderVersion == 2 {
          if mode == .setaddr {
            setAddrTotal += delay
            setAddrCount += 1
            let average = setAddrTotal / Double(setAddrCount)
            lblSetAddressDelay.stringValue = String(format: "%1.1f", average)
            mode = .dataload
          }
          else {
            loadDelayTotal += delay
            loadDelayCount += 1
            let average = loadDelayTotal / Double(loadDelayCount)
            lblDataLoadDelay.stringValue = String(format: "%1.1f", average)
          }
        }
        else {
          
          if mode == .setaddr {
            setAddrTotal += delay
            setAddrCount += 1
            let average = setAddrTotal / Double(setAddrCount)
            lblSetAddressDelay.stringValue = String(format: "%1.1f", average)
            mode = .dataload
          }
          else {
            loadDelayTotal += delay
            loadDelayCount += 1
            let average = loadDelayTotal / Double(loadDelayCount)
            lblDataLoadDelay.stringValue = String(format: "%1.1f", average)
          }
          
          loadCount -= 1
          
          if loadCount == 0 {
            mode = .endProgBlock
          }

        }
        
        lastTimeStamp = message.timeStamp

      case .iplEndLoad:
        mode = .idle
      default:
        break
      }
      
    }
    
  }

  // MARK: Outlets & Actions
  
  @IBOutlet weak var cboInterface: NSComboBox!
  
  @IBAction func cboInterfaceAction(_ sender: NSComboBox) {
    
    let name = cboInterface.stringValue
    
    UserDefaults.standard.set(name, forKey: DEFAULT.IPL_INTERFACE_ID)
    
    if let x = interface {
      if name != x.deviceName && observerId != -1 {
        x.removeObserver(id: observerId)
      }
    }
    
    for x in networkController.networkInterfaces {
      if x.deviceName == name {
        interface = x
        observerId = interface?.addObserver(observer: self) ?? -1
      }
    }

  }
  
  @IBOutlet weak var lblDMF: NSTextField!
  
  @IBOutlet weak var btnSelect: NSButton!
  
  @IBAction func btnSelectAction(_ sender: NSButton) {
    
    let dialog = NSOpenPanel()
    
    dialog.title                     = "Select"
    dialog.showsResizeIndicator      = true
    dialog.showsHiddenFiles          = false
    dialog.canChooseDirectories      = false
    dialog.canCreateDirectories      = true
    dialog.allowsMultipleSelection   = false
    dialog.canChooseFiles            = true
    dialog.allowedFileTypes          = ["dmf"]
    dialog.allowsOtherFileTypes      = true
    
    if let url = dmfURL {
      dialog.nameFieldStringValue = url.lastPathComponent
    }
    
    if dialog.runModal() == .OK {
      
      if let result = dialog.url {
        dmfPath = result.path
        if let dmf = DMF(path: _dmfPath) {
          self.dmf = dmf
          lblOptions.integerValue = Int(dmf.options)
          lblProduct.stringValue = dmf.locoNetProductInfo?.productName ?? ""
          lblManufacturer.integerValue = Int(dmf.manufacturerCode)
          lblTXDelay.integerValue = dmf.txDelay
          lblChunkSize.integerValue = dmf.chunkSize
          lblEraseDelay.integerValue = dmf.eraseDelay
          lblLastAddress.integerValue = dmf.lastAddress
          lblFirstAddress.integerValue = dmf.firstAddress
          lblHardwareVersion.integerValue = Int(dmf.hardwareVersion)
          lblSoftwareVersion.integerValue = Int(dmf.softwareVersion)
          lblBootloaderVersion.integerValue = dmf.bootloaderVersion
          lblProgBlockSize.integerValue = dmf.progBlockSize
          lblEraseBlockSize.integerValue = dmf.eraseBlockSize
          let boot2 = dmf.bootloaderVersion == 2
          
          lblSetupDelay.isHidden = !boot2
          lblSetupDelayLabel.isHidden = !boot2
          
          lblSetupDelay.stringValue = ""
          lblEraseDelayActual.stringValue = ""
          lblSetAddressDelay.stringValue = ""
          lblDataLoadDelay.stringValue = ""
          lblEndOfProgBlockDelay.stringValue = ""
          
          lblEndOfProgBlockLaabelLabel.stringValue = boot2 ? "End of Prog Block Delay" : "End of Chunk Delay"
          
        }
        else {
          dmfPath = ""
          self.dmf = nil
        }
        setupControls()
      }
      else {
      // User clicked on "Cancel"
      }
    }
  }
  
  @IBOutlet weak var btnStart: NSButton!
  
  @IBAction func btnStartAction(_ sender: NSButton) {
    
    mode = .idle
    dmf?.start(interface: interface!, delegate: self)
    
  }
  
  @IBOutlet weak var btnCancel: NSButton!
  
  @IBAction func btnCancelAction(_ sender: NSButton) {
    dmf?.cancel()
    mode = .idle
  }
  
  @IBOutlet weak var barProgress: NSProgressIndicator!
  
  @IBOutlet weak var lblManufacturer: NSTextField!
  
  @IBOutlet weak var lblHardwareVersion: NSTextField!
  
  @IBOutlet weak var lblBootloaderVersion: NSTextField!
  
  @IBOutlet weak var lblTXDelay: NSTextField!
  
  @IBOutlet weak var lblOptions: NSTextField!
  
  @IBOutlet weak var lblFirstAddress: NSTextField!
  
  @IBOutlet weak var lblProgBlockSize: NSTextField!
  
  @IBOutlet weak var lblProduct: NSTextField!
  
  @IBOutlet weak var lblSoftwareVersion: NSTextField!
  
  @IBOutlet weak var lblChunkSize: NSTextField!
  
  @IBOutlet weak var lblLastAddress: NSTextField!
  
  @IBOutlet weak var lblEraseBlockSize: NSTextField!
  
  @IBOutlet weak var lblSetupDelay: NSTextField!
  
  @IBOutlet weak var lblSetAddressDelay: NSTextField!
  
  @IBOutlet weak var lblDataLoadDelay: NSTextField!
  
  @IBOutlet weak var lblEndOfProgBlockDelay: NSTextField!
  
  @IBOutlet weak var lblEraseDelayActual: NSTextField!
  
  @IBOutlet weak var lblEraseDelay: NSTextField!
  
  @IBOutlet weak var tabView: NSTabView!
  
  @IBOutlet weak var lblSetupDelayLabel: NSTextField!
  
  @IBOutlet weak var lblEndOfProgBlockLaabelLabel: NSTextField!
  
}

