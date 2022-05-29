//
//  UpdateFirmwareVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/05/2022.
//

import Foundation
import Cocoa

class UpdateFirmwareVC: NSViewController, NSWindowDelegate, InterfaceDelegate {

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
  
  private var dmfPath : String {
    get {
      return _dmfPath
    }
    set(value) {
      _dmfPath = value
      lblDMF.stringValue = dmfURL?.lastPathComponent ?? ""
      UserDefaults.standard.set(value, forKey: DEFAULT.IPL_DMF_FILENAME)
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
    
    boxSettings.isHidden = noPath
    
    btnStart.isEnabled = !noPath
    
    btnCancel.isEnabled = !noPath
    
  }
  
  @objc func timerAction() {
    
  }
  
  func startTimer() {
    stopTimer()
    let timeInterval = 300.0 / 1000.0
    timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
  }
  
  func stopTimer() {
    timer?.invalidate()
    timer = nil
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
    dialog.allowsOtherFileTypes      = false
    
    if let url = dmfURL {
      dialog.nameFieldStringValue = url.lastPathComponent
    }
    
    if dialog.runModal() == .OK {
      
      if let result = dialog.url {
        dmfPath = result.path
        if let dmf = DMF(path: _dmfPath) {
          self.dmf = dmf
          lblOptions.integerValue = dmf.options
          lblProduct.stringValue = dmf.locoNetProductInfo?.productName ?? ""
          lblManufacturer.integerValue = dmf.manufacturerCode
          lblTXDelay.integerValue = dmf.txDelay
          lblChunkSize.integerValue = dmf.chunkSize
          lblEraseDelay.integerValue = dmf.eraseDelay
          lblLastAddress.integerValue = dmf.lastAddress
          lblFirstAddress.integerValue = dmf.firstAddress
          lblHardwareVersion.integerValue = dmf.hardwareVersion
          lblSoftwareVersion.integerValue = dmf.softwareVersion
          lblBootloaderVersion.integerValue = dmf.bootloaderVersion
          lblProgBlockSize.integerValue = dmf.progBlockSize
          lblEraseBlockSize.integerValue = dmf.eraseBlockSize
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
    
    
  }
  
  @IBOutlet weak var btnCancel: NSButton!
  
  @IBAction func btnCancelAction(_ sender: NSButton) {
  }
  
  @IBOutlet weak var barProgress: NSProgressIndicator!
  
  @IBOutlet weak var boxSettings: NSBox!
  
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
  
  @IBOutlet weak var lblEraseDelay: NSTextField!
  
  @IBOutlet weak var lblLastAddress: NSTextField!
  
  @IBOutlet weak var lblEraseBlockSize: NSTextField!
  
}

