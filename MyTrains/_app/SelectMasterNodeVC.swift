//
//  SelectMasterNodeVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 17/01/2024.
//

import Foundation
import AppKit

class SelectMasterNodeVC: NSViewController, NSWindowDelegate, NSTextFieldDelegate, NSControlTextEditingDelegate {
  
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
    
    self.view.window?.title = String(localized: "Configure Workstation", comment: "Used for the title of the configure workstation window")
    
    lblMasterNodeId.translatesAutoresizingMaskIntoConstraints = false
    txtMasterNodeId.translatesAutoresizingMaskIntoConstraints = false
    lblWorkstationType.translatesAutoresizingMaskIntoConstraints = false
    cboWorkstationType.translatesAutoresizingMaskIntoConstraints = false
    btnOK.translatesAutoresizingMaskIntoConstraints = false
    
    lblMasterNodeId.stringValue = String(localized: "Master Workstation Node ID", comment: "Used for the title of the Master Workstation Node ID Input field")
    
    lblWorkstationType.stringValue = String(localized: "This Workstation Type", comment: "Used for the title of the Workstation Type combo box")
    
    btnOK.title = String(localized: "Save", comment: "Used for the Save button title to say that all is complete")
    
    txtMasterNodeId.delegate = self
    
    btnOK.target = self
    btnOK.action = #selector(self.btnOKAction(_:))

    view.addSubview(lblMasterNodeId)
    view.addSubview(txtMasterNodeId)
    view.addSubview(lblWorkstationType)
    view.addSubview(cboWorkstationType)
    view.addSubview(btnOK)
    
    WorkstationType.populate(comboBox: cboWorkstationType)
    
    cboWorkstationType.isEditable = false
    
    NSLayoutConstraint.activate([
      lblMasterNodeId.widthAnchor.constraint(greaterThanOrEqualTo: lblWorkstationType.widthAnchor),
      lblWorkstationType.widthAnchor.constraint(greaterThanOrEqualTo: lblMasterNodeId.widthAnchor),
      lblMasterNodeId.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 1.0),
      lblMasterNodeId.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1.0),
      txtMasterNodeId.topAnchor.constraint(equalToSystemSpacingBelow: lblMasterNodeId.bottomAnchor, multiplier: 1.0),
      txtMasterNodeId.leadingAnchor.constraint(equalTo: lblMasterNodeId.leadingAnchor),
      txtMasterNodeId.widthAnchor.constraint(equalToConstant: 120),
      lblWorkstationType.topAnchor.constraint(equalToSystemSpacingBelow: txtMasterNodeId.bottomAnchor, multiplier: 1.0),
      lblWorkstationType.leadingAnchor.constraint(equalTo: lblMasterNodeId.leadingAnchor),
      cboWorkstationType.topAnchor.constraint(equalToSystemSpacingBelow: lblWorkstationType.bottomAnchor, multiplier: 1.0),
      cboWorkstationType.leadingAnchor.constraint(equalTo: lblWorkstationType.leadingAnchor),
      cboWorkstationType.widthAnchor.constraint(equalToConstant: 120),
      btnOK.leadingAnchor.constraint(equalToSystemSpacingAfter: lblMasterNodeId.trailingAnchor, multiplier: 2.0),
      btnOK.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 1.0),
      view.bottomAnchor.constraint(equalToSystemSpacingBelow: cboWorkstationType.bottomAnchor, multiplier: 1.0),
      view.trailingAnchor.constraint(equalToSystemSpacingAfter: btnOK.trailingAnchor, multiplier: 1.0),
    ])
    
    if let masterNodeId = controller?.masterNodeId {
      txtMasterNodeId.stringValue = masterNodeId.toHexDotFormat(numberOfBytes: 6)
    }
    else {
      btnOK.isEnabled = false
      txtMasterNodeId.becomeFirstResponder()
    }
    txtMasterNodeId.placeholderString = "00.00.00.00.00.00"
    
    lblWorkstationType.isEnabled = false
    cboWorkstationType.isEnabled = false
    
  }
  
  // MARK: Public Properties
  
  public var controller : MyTrainsController?
  
  // MARK: NSTextFieldDelegate, NSControlTextEditingDelegate Methods
 
  @objc func controlTextDidBeginEditing(_ obj: Notification) {
    btnOK.isEnabled = false
  }
  
  @objc internal func controlTextDidEndEditing(_ obj: Notification) {
    btnOK.isEnabled = true
  }
  
  @objc func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
    if let id = UInt64(dotHex: control.stringValue, numberOfBytes: 6) {
      let group = id.bigEndianData[2]
      let ok : Set<UInt8> = [2, 3, 5, 8, 9]
      return ok.contains(group)
    }
    return false
  }
  
  // MARK: Controls
  
  let lblMasterNodeId = NSTextField(labelWithString: "")
  
  let txtMasterNodeId = NSTextField()
  
  let lblWorkstationType = NSTextField(labelWithString: "")
  
  let cboWorkstationType = NSComboBox()
  
  let btnOK = NSButton()
  
  // MARK: Actions
  
  @IBAction func btnOKAction(_ sender: NSButton) {
    
    controller?.masterNodeId = UInt64(dotHex: txtMasterNodeId.stringValue, numberOfBytes: 6)
    
    controller?.workstationType = WorkstationType(rawValue: cboWorkstationType.indexOfSelectedItem)
    
    view.window?.close()
    
  }


}

