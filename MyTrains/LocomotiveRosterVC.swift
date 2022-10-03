//
//  LocomotiveRosterVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 02/10/2022.
//

import Foundation
import Cocoa

class LocomotiveRosterVC: NSViewController, InterfaceDelegate, NSWindowDelegate {
  
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
    
    cboCommandStationDS.dictionary = networkController.commandStations
    
    cboCommandStation.dataSource = cboCommandStationDS
    
    if cboCommandStation.numberOfItems > 0 {
      
      let key = UserDefaults.standard.integer(forKey: DEFAULT.LOCOMOTIVE_ROSTER_COMMAND_STATION)
      
      if let index = cboCommandStationDS.indexWithKey(key: key), let cs = cboCommandStationDS.editorObjectAt(index: index) as? Interface {
        cboCommandStation.selectItem(at: index)
        commandStation = cs
      }
      else if let cs = cboCommandStationDS.editorObjectAt(index: 0) as? Interface {
        cboCommandStation.selectItem(at: 0)
        commandStation = cs
      }
      
    }
    
  }

  // MARK: Private Properties
  
  private var cboCommandStationDS : ComboBoxDictDS = ComboBoxDictDS()
  
  private var observerId : Int = -1
  
  private var interface : Interface?
  
  private var commandStation : Interface? {
    willSet {
      if observerId != -1 {
        interface?.removeObserver(id: observerId)
        observerId = -1
      }
      interface = nil
    }
    didSet {
      if let cs = commandStation, let interface = cs.network?.interface {
        self.interface = interface
        observerId = interface.addObserver(observer: self)
      }
    }
  }

  // MARK: Outlets & Actions
  
  
  @IBOutlet weak var cboCommandStation: NSComboBox!
  
  @IBAction func cboCommandStationAction(_ sender: NSComboBox) {
    if let cs = cboCommandStationDS.editorObjectAt(index: cboCommandStation.indexOfSelectedItem) as? Interface {
      commandStation = cs
      UserDefaults.standard.set(cs.primaryKey, forKey: DEFAULT.LOCOMOTIVE_ROSTER_COMMAND_STATION)
    }
  }
  
  @IBOutlet weak var btnReset: NSButton!
  
  @IBAction func btnResetAction(_ sender: NSButton) {
  }
  
  @IBOutlet weak var btnRead: NSButton!
  
  @IBAction func btnReadAction(_ sender: NSButton) {
  }
  
  @IBOutlet weak var btnWrite: NSButton!
  
  @IBAction func btnWriteAction(_ sender: NSButton) {
  }
  
}

