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
    
    cboTrainNode.dataSource = cboTrainNodeDS
    
    self.view.window?.title = "\(programmerTool!.userNodeName) (\(programmerTool!.nodeId.toHexDotFormat(numberOfBytes: 6)))"
    
  }
  
  // MARK: Private Properties
  
  private var cboProgrammingTrackDS = ComboBoxSimpleDS()
  
  private var cboTrainNodeDS = ComboBoxSimpleDS()
  
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

  // MARK: Outlets & Actions
  
  @IBOutlet weak var cboProgrammingTrack: NSComboBox!
  
  @IBAction func cboProgrammingTrackAction(_ sender: NSComboBox) {
    
    if let id = cboProgrammingTrackDS.keyForItemAt(index: cboProgrammingTrack.indexOfSelectedItem) {
      
      UserDefaults.standard.set(id, forKey: DEFAULT.PROGRAMMING_TRACK_ID)
      
    }

  }
  
  @IBOutlet weak var cboTrainNode: NSComboBox!
  
  @IBAction func cboTrainNodeAction(_ sender: NSComboBox) {
  }
  
}
