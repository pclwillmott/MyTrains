//
//  SpeedProfilerVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 01/08/2022.
//

import Foundation
import Cocoa

class SpeedProfilerVC: NSViewController, NSWindowDelegate {
 
  // MARK: Window & View Control
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }

  func windowWillClose(_ notification: Notification) {
  }
  
  override func viewWillAppear() {
    
    self.view.window?.delegate = self
    
    cboProfilerMode.selectItem(at: 0)
    
    UnitSpeed.populate(comboBox: cboUnits)
    
    cboLocomotiveDS.dictionary = networkController.locomotives
    
    cboLocomotive.dataSource = cboLocomotiveDS
    
    if cboLocomotive.numberOfItems > 0 {
      cboLocomotive.selectItem(at: 0)
    }
    
    cboRoute.removeAllItems()
    if let layout = networkController.layout {
      for loopName in layout.loopNames {
        cboRoute.addItem(withObjectValue: loopName)
      }
    }
    
    setupLoco()
    
  }
  
  // MARK: Private Properties
  
  private var cboLocomotiveDS = ComboBoxDictDS()
  
  private var tableViewDS = SpeedProfileTableViewDS()
  
  private var locomotive : RollingStock?
  
  // MARK: Private Methods
  
  private func setupLoco() {
    
    scrollView.isHidden = true
    lblStatus.isHidden = true
    
    tableViewDS.speedProfile = nil
    tableView.dataSource = nil
    tableView.delegate = nil
    
    if cboLocomotive.indexOfSelectedItem != -1 {
      
      if let locomotive = cboLocomotiveDS.editorObjectAt(index: cboLocomotive.indexOfSelectedItem) as? RollingStock {
        
        self.locomotive = locomotive
        
        tableViewDS.speedProfile = locomotive.speedProfile
        tableView.dataSource = tableViewDS
        tableView.delegate = tableViewDS
        
        scrollView.isHidden = false
        lblStatus.isHidden = false

      }

    }
    
    tableView.reloadData()

  }
  
  // MARK: Outlets & Actions
  
  @IBOutlet weak var cboProfilerMode: NSComboBox!
  
  @IBAction func cboProfilerModeAction(_ sender: NSComboBox) {
  }
  
  @IBOutlet weak var cboRoute: NSComboBox!
  
  @IBAction func cboRouteAction(_ sender: NSComboBox) {
  }
  
  @IBOutlet weak var cboLocomotive: NSComboBox!
  
  @IBAction func cboLocomotiveAction(_ sender: NSComboBox) {
    setupLoco()
  }
  
  @IBOutlet weak var tableView: NSTableView!
  
  @IBOutlet weak var lblStatus: NSTextField!
  
  @IBOutlet weak var cboUnits: NSComboBox!
  
  @IBAction func cboUnitsAction(_ sender: NSComboBox) {
  }
  
  @IBOutlet weak var btnStartProfiler: NSButton!
  
  @IBAction func btnStartProfilerAction(_ sender: NSButton) {
  }
  
  @IBOutlet weak var btnSave: NSButton!
  
  @IBAction func btnSaveAction(_ sender: NSButton) {
  }
  
  @IBOutlet weak var scrollView: NSScrollView!
  
}

