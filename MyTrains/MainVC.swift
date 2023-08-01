//
//  ViewController.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/10/2021. 
//

import Cocoa

class MainVC: NSViewController, MyTrainsControllerDelegate, LayoutDelegate, OpenLCBClockDelegate {

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
      myTrainsController.removeDelegate(id: controllerDelegateId)
      controllerDelegateId = -1
    }
    if layoutDelegateId != -1 {
      myTrainsController.layout?.removeDelegate(delegateId: layoutDelegateId)
    }
    if fastClockObserverId != -1 {
      myTrainsController.fastClock.removeObserver(observerId: fastClockObserverId)
    }
    
  }
  
  override func viewWillAppear() {
    
    controllerDelegateId = myTrainsController.appendDelegate(delegate: self)
    
    switchBoardView.layout = myTrainsController.layout
    
    scrollView.documentView?.frame = NSMakeRect(0.0, 0.0, 2000.0, 2000.0)
    scrollView.allowsMagnification = true
    scrollView.magnification = UserDefaults.standard.double(forKey: DEFAULT.SWITCHBOARD_EDITOR_MAG)

    if let layout = myTrainsController.layout {
      layoutDelegateId = layout.addDelegate(delegate: self)
    }
    
    fastClockObserverId = myTrainsController.openLCBNetworkLayer!.fastClock!.addObserver(observer: self)
    
  }
  
  // MARK: Private Properties
  
  private var fastClockObserverId : Int = -1
  
  private var cboLayoutDS : ComboBoxDBDS? = nil
  
  private var controllerDelegateId : Int = -1
  
  private var layoutDelegateId : Int = -1
  
  // MARK: Private Methods
  
  private func updateStatus() {
    
 //   swConnect.state = myTrainsController.connected ? .on : .off
    
    if let _ = myTrainsController.layout {
      
      boxStatus.contentView?.subviews.removeAll()
      
      var xPos : CGFloat = 20
      let yPos : CGFloat = 15
      
      for interface in myTrainsController.networkInterfaces {
        
        var color : NSColor = NSColor.black
        
        let label1: NSTextField = NSTextField()
        label1.frame = NSRect(x: xPos, y: yPos, width: 200, height: 21)
        label1.backgroundColor = boxStatus.fillColor
        
        color = interface.isOpen ? .systemGreen : .systemRed
        
        label1.textColor = color
        label1.stringValue = "\(interface.deviceName) "
        label1.isEditable = false
        label1.isBezeled = false
        
        label1.sizeToFit()

        boxStatus.contentView?.addSubview(label1)
        
        xPos += label1.frame.width + 0

        if let locoNetInterface = interface as? InterfaceLocoNet, let cs = locoNetInterface.commandStation {
          
          let label2: NSTextField = NSTextField()
          label2.frame = NSRect(x: xPos, y: yPos, width: 200, height: 21)
          label2.backgroundColor = boxStatus.fillColor
        
       //   color =  cs.powerIsOn ? .systemGreen : device.commandStation.trackIsPaused ? .orange : .red
   
          label2.textColor = color
          
          label2.stringValue = "→ \(cs.deviceName)"
          label2.isEditable = false
          label2.isBezeled = false
          label2.sizeToFit()

          boxStatus.contentView?.addSubview(label2)
          
          xPos += label2.frame.width + 10

        }

      }
      
    }
        
  }
  
  // MARK: OpenLCBClockDelegate Methods
  
  func clockTick(clock: OpenLCBClock) {
    clockView.subState = clock.subState
    clockView.date = clock.date
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .full
    dateFormatter.timeStyle = .none
    lblFastClock.stringValue = dateFormatter.string(from: clock.date)
  }
  
  // MARK: LayoutDelegate Methods
  
  func needsDisplay() {
    switchBoardView.needsDisplay = true
  }
  
  // MARK: MyTrainsController Delegate Methods
  
  func statusUpdated(myTrainsController: MyTrainsController) {
 
    updateStatus()
    
  }
  
  func switchBoardUpdated() {
    switchBoardView.needsDisplay = true
  }
  
  func myTrainsControllerUpdated(myTrainsController: MyTrainsController) {
    
    cboLayout.deselectItem(at: cboLayout.indexOfSelectedItem)
    
    cboLayoutDS = ComboBoxDBDS(tableName: TABLE.LAYOUT, codeColumn: LAYOUT.LAYOUT_ID, displayColumn: LAYOUT.LAYOUT_NAME, sortColumn: LAYOUT.LAYOUT_NAME)
    
    cboLayout.dataSource = cboLayoutDS
    
    if let index = cboLayoutDS!.indexOfItemWithCodeValue(code: myTrainsController.layoutId) {
      cboLayout.selectItem(at: index)
    }
    
    updateStatus()
    
  }
  
  // MARK: Outlets & Actions
  
  @IBOutlet weak var cboLayout: NSComboBox!
  
  @IBAction func cboLayoutAction(_ sender: NSComboBox) {
    
    myTrainsController.layoutId = cboLayoutDS!.codeForItemAt(index: cboLayout.indexOfSelectedItem) ?? -1
    
    updateStatus()
    
  }
  
  @IBOutlet weak var boxStatus: NSBox!
  
  @IBOutlet weak var swConnect: NSSwitch!
  
  @IBAction func swConnectAction(_ sender: NSSwitch) {
    sender.state == .on ? myTrainsController.connect() : myTrainsController.disconnect()
  }
  
  @IBOutlet weak var btnPowerOn: NSButton!
  
  @IBAction func btnPowerOnAction(_ sender: NSButton) {
  }
  
  @IBOutlet weak var btnPowerOff: NSButton!
  
  @IBAction func btnPowerOffAction(_ sender: NSButton) {
  }
  
  @IBOutlet weak var btnPause: NSButton!
  
  @IBAction func btnPauseAction(_ sender: NSButton) {
  }
  
  @IBOutlet weak var scrollView: NSScrollView!
  
  @IBOutlet weak var switchBoardView: SwitchBoardOperationsView!
  
  @IBAction func btnZoomIn(_ sender: NSButton) {
    scrollView.magnification += 0.25
    UserDefaults.standard.set(scrollView.magnification, forKey: DEFAULT.MAIN_SWITCHBOARD_MAG)
  }
  
  @IBAction func btnZoomOut(_ sender: NSButton) {
    scrollView.magnification -= 0.25
    UserDefaults.standard.set(scrollView.magnification, forKey: DEFAULT.MAIN_SWITCHBOARD_MAG)
  }
  
  @IBAction func btnZoomToFit(_ sender: NSButton) {
    
    scrollView.magnification = 1.0

    let sWidth = scrollView.frame.width
    let sHeight = scrollView.frame.height
    let gWidth = switchBoardView.bounds.width
    let gHeight = switchBoardView.bounds.height

    var scale = 1.0

    if gWidth > gHeight {
      scale = sWidth / gWidth
    }
    else {
      scale = sHeight / gHeight
    }
    
    scrollView.magnification = scale
    UserDefaults.standard.set(scrollView.magnification, forKey: DEFAULT.MAIN_SWITCHBOARD_MAG)
    
  }
  
  @IBOutlet weak var lblFastClock: NSTextField!
  
  @IBOutlet weak var clockView: ClockView!
  
}

