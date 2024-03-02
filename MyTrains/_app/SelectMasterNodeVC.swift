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
    
    self.view.window?.title = String(localized: "Create Application Node", comment: "Used for the title of the Create Application Node window")
    
    boxAppNodeId.translatesAutoresizingMaskIntoConstraints = false
    btnOK.translatesAutoresizingMaskIntoConstraints = false
    boxView.translatesAutoresizingMaskIntoConstraints = false
    lblAppNodeId.translatesAutoresizingMaskIntoConstraints = false
    txtAppNodeId.translatesAutoresizingMaskIntoConstraints = false

    boxAppNodeId.title = String(localized: "Application Node ID", comment: "Used for the title of the Application Node ID box")
    boxAppNodeId.boxType = .primary
    
    lblAppNodeId.stringValue = String(localized: "Enter a node ID from your personal OpenLCB Unique ID Range. This must be a unique value and not be used by any other OpenLCB node. MyTrains requires in total a minimum of 2 node IDs plus 1 node ID for each gateway node, all of which must be consecutive with the node ID that you enter here. OpenLCB Unique ID Ranges are available on request from the OpenLCB website. The Application Node create process cannot be undone so check the node ID carefully before you press the Create button.")
    
    lblAppNodeId.lineBreakMode = .byWordWrapping
    lblAppNodeId.maximumNumberOfLines = 0
    lblAppNodeId.preferredMaxLayoutWidth = 300.0
    lblAppNodeId.font = NSFont(name: lblAppNodeId.font!.familyName!, size: 11.0)

    txtAppNodeId.delegate = self
    
    btnOK.title = String(localized: "Create", comment: "Used for the Create Application Node button title")
    btnOK.target = self
    btnOK.action = #selector(self.btnOKAction(_:))

    view.addSubview(boxAppNodeId)
    view.addSubview(btnOK)

    boxAppNodeId.addSubview(boxView)

    boxView.addSubview(lblAppNodeId)
    boxView.addSubview(txtAppNodeId)

    NSLayoutConstraint.activate([
      boxAppNodeId.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 1.0),
      boxAppNodeId.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1.0),
      boxAppNodeId.widthAnchor.constraint(equalTo: boxView.widthAnchor),
      boxAppNodeId.heightAnchor.constraint(equalTo: boxView.heightAnchor, constant: 0.0),
      boxView.topAnchor.constraint(equalTo: boxAppNodeId.topAnchor),
      boxView.leadingAnchor.constraint(equalTo: boxAppNodeId.leadingAnchor),
      boxView.trailingAnchor.constraint(equalToSystemSpacingAfter: lblAppNodeId.trailingAnchor, multiplier: 1.0),
      boxView.bottomAnchor.constraint(equalToSystemSpacingBelow: txtAppNodeId.bottomAnchor, multiplier: 1.0),
      lblAppNodeId.topAnchor.constraint(equalToSystemSpacingBelow: boxView.topAnchor, multiplier: 1.0),
      lblAppNodeId.leadingAnchor.constraint(equalToSystemSpacingAfter: boxView.leadingAnchor, multiplier: 1.0),
      txtAppNodeId.topAnchor.constraint(equalToSystemSpacingBelow: lblAppNodeId.bottomAnchor, multiplier: 1.0),
      txtAppNodeId.leadingAnchor.constraint(equalTo: lblAppNodeId.leadingAnchor),
      txtAppNodeId.widthAnchor.constraint(equalToConstant: 120),
      btnOK.leadingAnchor.constraint(equalToSystemSpacingAfter: boxAppNodeId.trailingAnchor, multiplier: 2.0),
      btnOK.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 1.0),
      view.bottomAnchor.constraint(equalToSystemSpacingBelow: boxAppNodeId.bottomAnchor, multiplier: 1.0),
      view.trailingAnchor.constraint(equalToSystemSpacingAfter: btnOK.trailingAnchor, multiplier: 1.0),
    ])
    
    txtAppNodeId.becomeFirstResponder()
    txtAppNodeId.placeholderString = "00.00.00.00.00.00"

    btnOK.isEnabled = false

  }
  
  // MARK: Public Properties
  
  public var controller : MyTrainsController?
  
  // MARK: NSTextFieldDelegate, NSControlTextEditingDelegate Methods
 
  @objc func controlTextDidChange(_ obj: Notification) {
    btnOK.isEnabled = false
    if let id = UInt64(dotHex: txtAppNodeId.stringValue, numberOfBytes: 6) {
      let group = id.bigEndianData[2]
      let ok : Set<UInt8> = [2, 3, 5, 8, 9]
      btnOK.isEnabled = ok.contains(group)
    }
  }

  // MARK: Controls
  
  let lblAppNodeId = NSTextField(labelWithString: "")
  
  let txtAppNodeId = NSTextField()
  
  let btnOK = NSButton()
  
  let boxAppNodeId = NSBox()
  
  let boxView = NSView()
  
  // MARK: Actions
  
  @objc func btnOKAction(_ sender: NSButton) {
    view.window?.close()
    controller?.createApplicationNode(nodeId: UInt64(dotHex: txtAppNodeId.stringValue, numberOfBytes: 6)!)
  }

}

