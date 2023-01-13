//
//  IODeviceNewVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 13/01/2023.
//

import Foundation
import Cocoa

class IODeviceNewVC: NSViewController, NSWindowDelegate {
  
  // MARK: Window & View Control
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }
  
  func windowWillClose(_ notification: Notification) {
    stopModal()
  }
  
  override func viewWillAppear() {
    
    self.view.window?.delegate = self

    cboDeviceTypeDS.dictionary = LocoNetProducts.productDictionaryForIODevices()
    
    cboDeviceType.dataSource = cboDeviceTypeDS

  }
  
  // MARK: Private Properties
  
  private var cboDeviceTypeDS = ComboBoxDictDS()

  // MARK: Private Methods
  
  private func checkOKToSave() {
    
    btnSave.isEnabled = cboDeviceType.indexOfSelectedItem != -1 && txtBoardId.integerValue > 0
  }
  
  // MARK: Public Properties
  
  public var network : Network?
  
  // MARK: Outlets & Actions
  
  @IBOutlet weak var cboDeviceType: NSComboBox!
  
  @IBAction func cboDeviceTypeAction(_ sender: NSComboBox) {
    checkOKToSave()
  }
  
  @IBOutlet weak var txtBoardId: NSTextField!
  
  @IBAction func txtBoardIdAction(_ sender: NSTextField) {
    checkOKToSave()
  }
  
  @IBAction func btnSaveAction(_ sender: NSButton) {
  
    if let editorObject = cboDeviceTypeDS.editorObjectAt(index: cboDeviceType.indexOfSelectedItem), let locoNetProductId = LocoNetProductId(rawValue: editorObject.primaryKey) {

      var ioDevice : IODevice?

      switch locoNetProductId {
      case .BXP88:
        ioDevice = IODeviceBXP88(primaryKey: -1)
      case .DS64:
        ioDevice = IODeviceDS64(primaryKey: -1)
      case .TowerControllerMarkII:
        ioDevice = IODeviceTC64MkII(primaryKey: -1)
      default:
        break
      }
      
      if let device = ioDevice {
        
        device.locoNetProductId = locoNetProductId
        device.boardId = txtBoardId.integerValue
        device.networkId = network!.primaryKey
        
        device.deviceName = "\(device.locoNetProductInfo!.manufacturer.title) \(device.locoNetProductInfo!.productName) \(device.boardId)"
        
        device.save()
        
        networkController.addDevice(device: device)
        
        view.window?.close()
        
      }
      
    }
    
  }
  
  @IBOutlet weak var btnSave: NSButton!
  
}

