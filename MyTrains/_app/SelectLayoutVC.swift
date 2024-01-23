//
//  SelectLayoutVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/01/2024.
//

import Foundation
import AppKit

class SelectLayoutVC: NSViewController, NSWindowDelegate, MyTrainsAppDelegate {
  
  // MARK: Window & View Control
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }
  
  func windowWillClose(_ notification: Notification) {
    myTrainsController.openLCBNetworkLayer?.myTrainsNode?.removeObserver(observerId: observerId)
  }
  
  override func viewWillAppear() {
    
    self.view.window?.delegate = self
    
    self.view.window?.title = String(localized: "Select Layout", comment: "Used for the title of the Select Layout window")
    
    if let appNode = myTrainsController.openLCBNetworkLayer?.myTrainsNode {
      observerId = appNode.addObserver(observer: self)
    }
    
    boxSelectLayout.translatesAutoresizingMaskIntoConstraints = false
    boxView.translatesAutoresizingMaskIntoConstraints = false
    btnOK.translatesAutoresizingMaskIntoConstraints = false
    btnClear.translatesAutoresizingMaskIntoConstraints = false
    lblInstructions.translatesAutoresizingMaskIntoConstraints = false
    cboLayout.translatesAutoresizingMaskIntoConstraints = false

    boxSelectLayout.title = String(localized: "Select Layout", comment: "Used for the title of the Select Layout box")
    boxSelectLayout.boxType = .primary

    lblInstructions.stringValue = String(localized: "You may either select any layout stored locally on this MyTrains workstation or an active layout stored on another MyTrains workstation connected to this LCC/OpenLCB network. You can only modify layouts that are stored locally.")

    lblInstructions.lineBreakMode = .byWordWrapping
    lblInstructions.maximumNumberOfLines = 0
    lblInstructions.preferredMaxLayoutWidth = 300.0
    lblInstructions.font = NSFont(name: lblInstructions.font!.familyName!, size: 11.0)

    btnOK.title = String(localized: "Select", comment: "Used for the Select Layout button title")
    btnOK.target = self
    btnOK.action = #selector(self.btnOKAction(_:))

    btnClear.title = String(localized: "Clear", comment: "Used for the Clear Layout Selection button title")
    btnClear.target = self
    btnClear.action = #selector(self.btnClearAction(_:))

    view.addSubview(boxSelectLayout)
    view.addSubview(btnOK)
    view.addSubview(btnClear)

    boxSelectLayout.addSubview(boxView)

    boxView.addSubview(lblInstructions)
    boxView.addSubview(cboLayout)
    
    cboLayout.isEditable = false

    NSLayoutConstraint.activate([
      boxSelectLayout.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 1.0),
      boxSelectLayout.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1.0),
      boxSelectLayout.widthAnchor.constraint(equalTo: boxView.widthAnchor),
      boxSelectLayout.heightAnchor.constraint(equalTo: boxView.heightAnchor, constant: 0.0),
      boxView.topAnchor.constraint(equalTo: boxSelectLayout.topAnchor),
      boxView.leadingAnchor.constraint(equalTo: boxSelectLayout.leadingAnchor),
      boxView.trailingAnchor.constraint(equalToSystemSpacingAfter: lblInstructions.trailingAnchor, multiplier: 1.0),
      boxView.bottomAnchor.constraint(equalToSystemSpacingBelow: cboLayout.bottomAnchor, multiplier: 1.0),
      lblInstructions.topAnchor.constraint(equalToSystemSpacingBelow: boxView.topAnchor, multiplier: 1.0),
      lblInstructions.leadingAnchor.constraint(equalToSystemSpacingAfter: boxView.leadingAnchor, multiplier: 1.0),
      cboLayout.topAnchor.constraint(equalToSystemSpacingBelow: lblInstructions.bottomAnchor, multiplier: 1.0),
      cboLayout.leadingAnchor.constraint(equalTo: lblInstructions.leadingAnchor),
      cboLayout.trailingAnchor.constraint(equalTo: lblInstructions.trailingAnchor),
      btnOK.leadingAnchor.constraint(equalToSystemSpacingAfter: boxSelectLayout.trailingAnchor, multiplier: 2.0),
      btnOK.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 1.0),
      btnClear.topAnchor.constraint(equalToSystemSpacingBelow: btnOK.bottomAnchor, multiplier: 1.0),
      btnClear.leadingAnchor.constraint(equalTo: btnOK.leadingAnchor),
      btnOK.widthAnchor.constraint(greaterThanOrEqualTo: btnClear.widthAnchor),
      btnClear.widthAnchor.constraint(greaterThanOrEqualTo: btnOK.widthAnchor),
      view.bottomAnchor.constraint(equalToSystemSpacingBelow: boxSelectLayout.bottomAnchor, multiplier: 1.0),
      view.trailingAnchor.constraint(equalToSystemSpacingAfter: btnOK.trailingAnchor, multiplier: 1.0),
    ])

  }
  
  // MARK: Private Properties
  
  private var layoutList : [LayoutListItem] = []
  
  private var observerId : Int = -1
  
  // MARK: MyTrainsAppDelete Methods
  
  func LayoutListUpdated(layoutList: [LayoutListItem]) {
    
    cboLayout.removeAllItems()
    self.layoutList.removeAll()
    
    for item in layoutList {
      if item.masterNodeId == appNodeId! || item.layoutState == .activated {
        self.layoutList.append(item)
        cboLayout.addItem(withObjectValue: item.layoutName)
        if item.layoutId == appLayoutId {
          cboLayout.selectItem(withObjectValue: item.layoutName)
        }
      }
    }

  }
  
  // MARK: Controls
  
  let boxSelectLayout = NSBox()
  
  let boxView = NSView()
  
  let lblInstructions = NSTextField(labelWithString: "")
  
  let cboLayout = NSComboBox()
  
  let btnOK = NSButton()
  
  let btnClear = NSButton()
  
  // MARK: Actions
  
  @IBAction func btnOKAction(_ sender: NSButton) {
    if let networkLayer = myTrainsController.openLCBNetworkLayer {
      networkLayer.layoutNodeId = (cboLayout.indexOfSelectedItem == -1) ? nil : layoutList[cboLayout.indexOfSelectedItem].layoutId
      menuUpdate()
    }
    view.window?.close()
  }

  @IBAction func btnClearAction(_ sender: NSButton) {
    cboLayout.deselectItem(at: cboLayout.indexOfSelectedItem)
  }

}
