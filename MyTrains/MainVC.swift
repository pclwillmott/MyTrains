//
//  ViewController.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/10/2021. 
//

import Cocoa

class MainVC: NSViewController, NetworkControllerDelegate {

  // MARK: Window & View Control
  
  override func viewDidLoad() {
    
    super.viewDidLoad()

    // Do any additional setup after loading the view.
 
  }

  override var representedObject: Any? {
    didSet {
    // Update the view, if already loaded.
    }
  }
  
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }

  func windowWillClose(_ notification: Notification) {
    if controllerDelegateId != -1 {
      networkController.removeDelegate(id: controllerDelegateId)
      controllerDelegateId = -1
    }
  }
  
  override func viewWillAppear() {
    
    controllerDelegateId = networkController.appendDelegate(delegate: self)
    
  }
  
  // MARK: Private Properties
  
  private var cboLayoutDS : ComboBoxDBDS? = nil
  
  private var controllerDelegateId : Int = -1

  // MARK: Private Methods
  
  private func updateStatus() {
    
    swConnect.state = networkController.connected ? .on : .off
    
    if let _ = networkController.layout {
      
      boxStatus.contentView?.subviews.removeAll()
      
      var xPos : CGFloat = 20
      let yPos : CGFloat = 15
      /*
      for device in networkController.layoutDevices {
        
        var color : NSColor = NSColor.black
        
        let label1: NSTextField = NSTextField()
        label1.frame = NSRect(x: xPos, y: yPos, width: 200, height: 21)
        label1.backgroundColor = boxStatus.fillColor
        
        color = device.messenger.isOpen ? .systemGreen : device.messenger.isConnected ? .systemRed : .black
        
        label1.textColor = color
  //      label1.stringValue = "\(device.messenger.interface.interfaceName) → "
        label1.isEditable = false
        label1.isBezeled = false
        
        label1.sizeToFit()

        boxStatus.contentView?.addSubview(label1)
        
        xPos += label1.frame.width + 0

        let label2: NSTextField = NSTextField()
        label2.frame = NSRect(x: xPos, y: yPos, width: 200, height: 21)
        label2.backgroundColor = boxStatus.fillColor
      
        color =  device.commandStation.powerIsOn ? .systemGreen : device.commandStation.trackIsPaused ? .orange : .red
 
        label2.textColor = color
        
  //      label2.stringValue = "\(device.commandStation.commandStationName)"
        label2.isEditable = false
        label2.isBezeled = false
        label2.sizeToFit()

        boxStatus.contentView?.addSubview(label2)
        
        xPos += label2.frame.width + 10

      }
      */
    }
        
  }
  
  // MARK: NetworkController Delegate Methods
  
  func statusUpdated(networkController: NetworkController) {
 
    updateStatus()
    
  }
  
  func networkControllerUpdated(netwokController: NetworkController) {
    
    cboLayout.deselectItem(at: cboLayout.indexOfSelectedItem)
    
    cboLayoutDS = ComboBoxDBDS(tableName: TABLE.LAYOUT, codeColumn: LAYOUT.LAYOUT_ID, displayColumn: LAYOUT.LAYOUT_NAME, sortColumn: LAYOUT.LAYOUT_NAME)
    
    cboLayout.dataSource = cboLayoutDS
    
    if let index = cboLayoutDS!.indexOfItemWithCodeValue(code: networkController.layoutId) {
      cboLayout.selectItem(at: index)
    }
    
    updateStatus()
    
  }
  
  // MARK: Outlets & Actions
  
  @IBOutlet weak var cboLayout: NSComboBox!
  
  @IBAction func cboLayoutAction(_ sender: NSComboBox) {
    
    networkController.layoutId = cboLayoutDS!.codeForItemAt(index: cboLayout.indexOfSelectedItem) ?? -1
    
    updateStatus()
    
  }
  
  @IBOutlet weak var boxStatus: NSBox!
  
  @IBOutlet weak var swConnect: NSSwitch!
  
  @IBAction func swConnectAction(_ sender: NSSwitch) {
    
    swConnect.state == .on ? networkController.connect() : networkController.disconnect()
    
  }
  
  @IBOutlet weak var btnPowerOn: NSButton!
  
  @IBAction func btnPowerOnAction(_ sender: NSButton) {
//    networkController.powerOn()
  }
  
  @IBOutlet weak var btnPowerOff: NSButton!
  
  @IBAction func btnPowerOffAction(_ sender: NSButton) {
//    networkController.powerOff()
  }
  
  @IBOutlet weak var btnPause: NSButton!
  
  @IBAction func btnPauseAction(_ sender: NSButton) {
//    networkController.powerIdle()
  }
  
}

