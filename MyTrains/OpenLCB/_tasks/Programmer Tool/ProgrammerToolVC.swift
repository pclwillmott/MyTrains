//
//  ProgrammerToolVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 01/08/2023.
//

import Foundation
import Cocoa

// https://github.com/JMRI/JMRI/blob/master/xml/decoders/esu/v4decoderInfoCVs.xml

class ProgrammerToolVC : MyTrainsViewController, OpenLCBProgrammerToolDelegate, CSVParserDelegate {
  
  // MARK: Window & View Control
  
  override func windowWillClose(_ notification: Notification) {
//    appDelegate.networkLayer?.releaseProgrammerTool(programmerTool: programmerTool!)
    super.windowWillClose(notification)
  }
  
  override func viewWillAppear() {
    
    super.viewWillAppear()
    
    cboProgrammingTrack.dataSource = cboProgrammingTrackDS

    let programmingTrackId = UInt64(UserDefaults.standard.integer(forKey: DEFAULT.PROGRAMMING_TRACK_ID))
    
    if let index = cboProgrammingTrackDS.indexWithKey(key: programmingTrackId) {
      cboProgrammingTrack.selectItem(at: index)
      programmerTool?.programmingTrackId = programmingTrackId
    }

    cboTrainNode.dataSource = cboTrainNodeDS
    
    self.view.window?.title = "\(programmerTool!.userNodeName) (\(programmerTool!.nodeId.toHexDotFormat(numberOfBytes: 6)))"
    
    programmerTool?.cvs = []
    tableViewDS.programmerTool = programmerTool
    tableView.dataSource = tableViewDS
    tableView.delegate = tableViewDS
    tableView.reloadData()

  }
  
  // MARK: Private Properties
  
  private var cboProgrammingTrackDS = ComboBoxSimpleDS()
  
  private var cboTrainNodeDS = ComboBoxSimpleDS()
  
  private var tableViewDS = ProgrammerToolTableViewDS()
  
  private var csvParser : CSVParser?
  
  // MARK: Public Properties
  
  public var programmerTool : OpenLCBProgrammerToolNode?
  
  // MARK: CSVParserDelegate Methods
  
  func csvParserDidStartDocument() {
  }
  
  func csvParserDidEndDocument() {
    tableView.reloadData()
  }
  
  func csvParser(didStartRow row: Int) {
    cvNumber = nil
  }
  
  func csvParser(didEndRow row: Int) {
  }
  
  private var cvNumber : Int?
  
  func csvParser(foundCharacters column: Int, string: String) {
    if column == 0 {
      if string == "CV" {
        return
      }
      cvNumber = Int(string.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    else if column == 1 {
      if string == "Default Value" {
        return
      }
      if let cvNumber, let value = UInt8(string.trimmingCharacters(in: .whitespacesAndNewlines)) {
        programmerTool?.cvs[cvNumber - 1 + programmerTool!.defaultOffset] = value
      }
    }
    else if column == 2 {
      if string == "Value" {
        return
      }
      if let cvNumber, let value = UInt8(string.trimmingCharacters(in: .whitespacesAndNewlines)) {
        programmerTool?.cvs[cvNumber - 1] = value
      }
    }
  }

  // MARK: OpenLCBProgrammerToolDelegate Methods
  
  @objc public func programmingModeUpdated(ProgrammerTool:OpenLCBProgrammerToolNode, programmingMode:Int) {
    cboProgrammingTrackMode.selectItem(at: programmingMode)
  }

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
    txtCV31.integerValue = Int(cvData[30])
    txtCV32.integerValue = Int(cvData[31])
  }

  @objc public func statusUpdate(ProgrammerTool:OpenLCBProgrammerToolNode, status:String) {
    var text = txtActions.string
    if status.isEmpty {
      text = ""
    }
    if !txtActions.string.isEmpty && txtActions.string.last! != " " {
      text += "\n"
    }
    text += status
    txtActions.string = text
    if !text.isEmpty {
      let range = NSMakeRange(text.count - 1, 0)
      txtActions.scrollRangeToVisible(range)
    }

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
    programmerTool?.getAllValues()
  }
  
  @IBAction func btnSetAllAction(_ sender: NSButton) {
    programmerTool?.setAllValues()
  }
  
  @IBAction func btnCancelAction(_ sender: NSButton) {
    programmerTool?.cancelOperation()
  }
  
  @IBAction func btnImportCSVAction(_ sender: NSButton) {
    
    let panel = NSOpenPanel()
    
    panel.directoryURL = lastCSVPath
    panel.canChooseDirectories = false
    panel.canChooseFiles = true
    panel.allowsOtherFileTypes = true
    panel.allowedContentTypes = [.csv]
    
    if (panel.runModal() == .OK) {
      
      lastCSVPath = panel.directoryURL!.deletingLastPathComponent()
      
      csvParser = CSVParser(withURL: panel.url!)
      csvParser?.delegate = self
      csvParser?.columnSeparator = ","
      csvParser?.lineTerminator = "\n"
      csvParser?.stringDelimiter = "\""
      csvParser?.parse()
    }

  }
  
  @IBAction func btnExportCSVAction(_ sender: NSButton) {
    
    let panel = NSSavePanel()
    
    panel.directoryURL = lastCSVPath
    
    panel.nameFieldStringValue = cboTrainNode.stringValue

    panel.canCreateDirectories = true
    
    panel.allowedContentTypes = [.csv]
    
    if (panel.runModal() == .OK) {
      
      lastCSVPath = panel.directoryURL!.deletingLastPathComponent()
      
      var output = "\"CV\",\"Default Value\",\"Value\"\n"
      
      for cvNumber in 1...256 {
        output += "\(cvNumber), \(programmerTool!.cvs[cvNumber - 1 + programmerTool!.defaultOffset]), \(programmerTool!.cvs[cvNumber - 1])\n"
      }
      
      try? output.write(to: panel.url!, atomically: true, encoding: .utf8)

    }

  }
  
  @IBAction func btnGetDefaultAction(_ sender: NSButton) {
    programmerTool?.getDefaultValue(cvNumber: sender.tag)
  }
  
  @IBAction func btnSetDefaultAction(_ sender: NSButton) {
    programmerTool?.setDefaultValue(cvNumber: sender.tag)
  }
  
  @IBAction func btnGetValueAction(_ sender: NSButton) {
    programmerTool?.getValue(cvNumber: sender.tag)
  }
  
  @IBAction func btnSetValueAction(_ sender: NSButton) {
    programmerTool?.setValue(cvNumber: sender.tag)
  }
  
  @IBAction func btnSetToDefaultAction(_ sender: NSButton) {
    programmerTool?.setValueToDefault(cvNumber: sender.tag)
  }
  
  @IBAction func cboNumberBaseAction(_ sender: NSComboBox) {
    programmerTool!.setNumberBase(cvNumber: sender.tag, value: UInt8(NumberBase.selected(comboBox: sender).rawValue))
    tableView.reloadData()
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
  
  @IBOutlet weak var cboProgrammingTrackMode: NSComboBox!
  
  @IBAction func cboProgrammingTrackModeAction(_ sender: NSComboBox) {
    programmerTool?.programmingMode = cboProgrammingTrackMode.indexOfSelectedItem
  }
  
  @IBOutlet weak var txtCV31: NSTextField!
  
  @IBAction func txtCV31Action(_ sender: NSTextField) {
    if let value = UInt8(sender.stringValue) {
      programmerTool?.cvs[30] = value
      programmerTool?.setValue(cvNumber: 30)
    }
  }
  
  @IBOutlet weak var txtCV32: NSTextField!
  
  @IBAction func txtCV32Action(_ sender: NSTextField) {
    if let value = UInt8(sender.stringValue) {
      programmerTool?.cvs[31] = value
      programmerTool?.setValue(cvNumber: 31)
    }
  }
  
  @IBAction func btnGetAllIndexedAction(_ sender: NSButton) {
    programmerTool?.getAllValuesIndexed()
  }
  
  @IBAction func btnSetAllIndexedAction(_ sender: NSButton) {
    programmerTool?.setAllValuesIndexed()
  }
  
  @IBAction func btnGetAllExtendedAction(_ sender: NSButton) {
    programmerTool?.getAllValuesExtended()
  }
  
  @IBAction func btnSetAllExtendedAction(_ sender: NSButton) {
    programmerTool?.setAllValuesExtended()
  }
  
  @IBOutlet var txtActions: NSTextView!
  
}
