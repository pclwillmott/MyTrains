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
  }

  func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }

  func windowWillClose(_ notification: Notification) {
    myTrainsController.layout?.removeDelegate(delegateId: layoutDelegateId)
    myTrainsController.openLCBNetworkLayer!.fastClock!.removeObserver(observerId: fastClockObserverId)
    myTrainsController.removeDelegate(id: controllerDelegateId)
  }
  
  override func viewWillAppear() {
    
    controllerDelegateId = myTrainsController.addDelegate(delegate: self)
    
    fastClockObserverId = myTrainsController.openLCBNetworkLayer!.fastClock!.addObserver(observer: self)
    
    switchBoardView.layout = myTrainsController.layout
    
    scrollView.documentView?.frame = NSMakeRect(0.0, 0.0, 2000.0, 2000.0)
    scrollView.allowsMagnification = true
    scrollView.magnification = UserDefaults.standard.double(forKey: DEFAULT.SWITCHBOARD_EDITOR_MAG)

    if let layout = myTrainsController.layout {
      layoutDelegateId = layout.addDelegate(delegate: self)
    }
    
  }
  
  // MARK: Private Properties
  
  private var cboLayoutDS : ComboBoxDBDS? = nil
  
  private var controllerDelegateId : Int = -1
  
  private var fastClockObserverId : Int = -1
  
  private var layoutDelegateId : Int = -1
  
  // MARK: Private Methods
    
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
    
  }
  
  // MARK: Outlets & Actions
  
  @IBOutlet weak var cboLayout: NSComboBox!
  
  @IBAction func cboLayoutAction(_ sender: NSComboBox) {
    myTrainsController.layoutId = cboLayoutDS!.codeForItemAt(index: cboLayout.indexOfSelectedItem) ?? -1
  }
  
  @IBOutlet weak var boxStatus: NSBox!
  
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
