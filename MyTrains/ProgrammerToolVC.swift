//
//  ProgrammerToolVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 01/08/2023.
//

import Foundation
import Cocoa

class ProgrammerToolVC : NSViewController, NSWindowDelegate, OpenLCBProgrammerToolDelegate {
  
  // MARK: Window & View Control
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }
  
  func windowWillClose(_ notification: Notification) {
    myTrainsController.openLCBNetworkLayer?.releaseProgrammerTool(programmerTool: programmerTool!)
  }
  
  override func viewWillAppear() {
    
    self.view.window?.delegate = self
    
    cboProgrammingTrack.dataSource = cboProgrammingTrackDS

    let programmingTrackId = UInt64(UserDefaults.standard.integer(forKey: DEFAULT.PROGRAMMING_TRACK_ID))
    
    if let index = cboProgrammingTrackDS.indexWithKey(key: programmingTrackId) {
      cboProgrammingTrack.selectItem(at: index)
      programmerTool?.programmingTrackId = programmingTrackId
    }

    cboTrainNode.dataSource = cboTrainNodeDS
    
    self.view.window?.title = "\(programmerTool!.userNodeName) (\(programmerTool!.nodeId.toHexDotFormat(numberOfBytes: 6)))"
    
    tableViewDS.programmerTool = programmerTool
    tableView.dataSource = tableViewDS
    tableView.delegate = tableViewDS
    tableView.reloadData()

  }
  
  // MARK: Private Properties
  
  private var cboProgrammingTrackDS = ComboBoxSimpleDS()
  
  private var cboTrainNodeDS = ComboBoxSimpleDS()
  
  private var tableViewDS = ProgrammerToolTableViewDS()
  
  // MARK: Public Properties
  
  public var programmerTool : OpenLCBProgrammerToolNode?
  
  // MARK: OpenLCBProgrammerToolDelegate Methods
  
  @objc public func programmingTracksUpdated(programmerTool:OpenLCBProgrammerToolNode, programmingTracks:[UInt64:String]) {
    
    cboProgrammingTrackDS.dictionary = programmingTracks
    cboProgrammingTrack.reloadData()
    
    let programmingTrackId = UInt64(UserDefaults.standard.integer(forKey: DEFAULT.PROGRAMMING_TRACK_ID))
    
    if let index = cboProgrammingTrackDS.indexWithKey(key: programmingTrackId) {
      cboProgrammingTrack.selectItem(at: index)
    }

  }
  
  @objc public func dccTrainsUpdated(programmerTool:OpenLCBProgrammerToolNode, dccTrainNodes:[UInt64:String]) {
    cboTrainNodeDS.dictionary = dccTrainNodes
    cboTrainNode.reloadData()
  }
  
  @objc public func cvDataUpdated(programmerTool:OpenLCBProgrammerToolNode, cvData:[UInt8]) {
    tableView.reloadData()
  }

  @objc public func statusUpdate(ProgrammerTool:OpenLCBProgrammerToolNode, status:String) {
    lblStatus.stringValue = status
  }
  
  // MARK: Outlets & Actions
  
  @IBOutlet weak var cboProgrammingTrack: NSComboBox!
  
  @IBAction func cboProgrammingTrackAction(_ sender: NSComboBox) {
    if let id = cboProgrammingTrackDS.keyForItemAt(index: cboProgrammingTrack.indexOfSelectedItem) {
      UserDefaults.standard.set(id, forKey: DEFAULT.PROGRAMMING_TRACK_ID)
    }
  }
  
  @IBOutlet weak var cboTrainNode: NSComboBox!
  
  @IBAction func cboTrainNodeAction(_ sender: NSComboBox) {
    if let trainNodeId = cboTrainNodeDS.keyForItemAt(index: cboTrainNode.indexOfSelectedItem) {
      programmerTool?.dccTrainNodeId = trainNodeId
    }
  }
  
  @IBAction func btnGetAllAction(_ sender: NSButton) {
  }
  
  @IBAction func btnSetAllAction(_ sender: NSButton) {
  }
  
  @IBAction func btnImportCSVAction(_ sender: NSButton) {
  }
  
  @IBAction func btnExportCSVAction(_ sender: NSButton) {
  }
  
  @IBAction func btnGetDefaultAction(_ sender: NSButton) {
  }
  
  @IBAction func btnSetDefaultAction(_ sender: NSButton) {
  }
  
  @IBAction func btnGetValueAction(_ sender: NSButton) {
  }
  
  @IBAction func btnSetValueAction(_ sender: NSButton) {
  }
  
  @IBAction func btnSetToDefaultAction(_ sender: NSButton) {
  }
  
  @IBAction func cboNumberBaseAction(_ sender: NSComboBox) {
  }
  
  @IBOutlet weak var tableView: NSTableView!
  
  @IBAction func tableViewAction(_ sender: NSTableView) {
  }
  
  @IBAction func txtDefaultAction(_ sender: NSTextField) {
    programmerTool?.cvs[1024 + sender.tag] = UInt8(sender.integerValue & 0xff)
  }
  
  @IBAction func txtValueAction(_ sender: NSTextField) {
    programmerTool?.cvs[sender.tag] = UInt8(sender.integerValue & 0xff)
  }
  
  @IBOutlet weak var lblStatus: NSTextField!
  
}
