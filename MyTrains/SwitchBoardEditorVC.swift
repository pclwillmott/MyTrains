//
//  SwitchBoardEditorVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 30/04/2022.
//

import Cocoa

class SwitchBoardEditorVC: NSViewController, NSWindowDelegate, SwitchBoardViewDelegate {

  // MARK: Window & View Control
  
  override func viewDidLoad() {
      super.viewDidLoad()
      // Do view setup here.
  }

  @objc func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }

  @objc func windowWillClose(_ notification: Notification) {
    stopModal()
  }
  
  override func viewWillAppear() {
    
    self.view.window?.delegate = self
    
    for x in self.view.subviews {
      if x is SwitchBoardShapeButton {
        let button = x as! SwitchBoardShapeButton
        button.action = #selector(self.buttonAction(_:))
        shapeButtons.append(button)
      }
    }
    
    groupButtons.append(btnAddToGroup)
    groupButtons.append(btnRemoveFromGroup)

    switchBoardView.delegate = self
    
    switchBoardView.groupId = -1

    for index in 0...15 {
      let panel = SwitchBoardPanel(panelId: index, panelName: "Panel #\(index + 1)", numberOfColumns: 20, numberOfRows: 20)
      panels.append(panel)
    }
    switchBoardView.panels = panels
          
    scrollView.documentView?.frame = NSMakeRect(0.0, 0.0, 2000.0, 2000.0)
    scrollView.allowsMagnification = true
    scrollView.magnification = 1.0
  }
  
  // MARK: Private Properties
  
  private var shapeButtons : [SwitchBoardShapeButton] = []
  
  private var groupButtons : [NSButton] = []
  
  private var panels : [SwitchBoardPanel] = []

  // MARK: Private Methods
  
  // MARK: SwitchBoardViewDelegate
  
  func groupChanged(groupNames: [String], selectedIndex: Int) {
    cboGroupId.removeAllItems()
    cboGroupId.addItems(withObjectValues: groupNames)
    cboGroupId.selectItem(at: selectedIndex)
  }
  
  func panelsChanged() {
    cboPanelId.removeAllItems()
    for panel in switchBoardView.panels {
      let name = "\(panel.panelId + 1): \(panel.panelName)"
      cboPanelId.addItem(withObjectValue: name)
    }
    cboPanelId.selectItem(at: switchBoardView.panelId)
    txtGridX.integerValue = switchBoardView.panels[switchBoardView.panelId].numberOfColumns
    txtGridY.integerValue = switchBoardView.panels[switchBoardView.panelId].numberOfRows
    txtPanelName.stringValue = switchBoardView.panels[switchBoardView.panelId].panelName
  }
  
  // MARK: Outlets & Actions
  
  @IBOutlet weak var switchBoardView: SwitchBoardEditorView!
  
  @IBAction func buttonAction(_ sender: SwitchBoardShapeButton) {
    for button in shapeButtons {
      if button != sender {
        button.state = .off
      }
    }
    if sender.state == .on {
      switchBoardView.mode = .arrange
      switchBoardView.nextPart = sender.partType
    }
    else {
      switchBoardView.mode = .arrange
      switchBoardView.nextPart = .none
    }
  }

  @IBOutlet weak var scrollView: NSScrollView!
  
  @IBOutlet weak var btnArrangeMode: NSButton!
  
  @IBAction func btnArrangeModeAction(_ sender: NSButton) {
    btnGroupMode.state = sender.state == .on ? .off : .on
    for button in groupButtons {
      button.isEnabled = btnGroupMode.state == .on
    }
    for button in shapeButtons {
      button.isEnabled = btnGroupMode.state == .off
    }
    switchBoardView.mode = sender.state == .on ? .arrange : .group
  }
  
  @IBOutlet weak var btnRotateLeft: NSButton!
  
  @IBAction func btnRotateLeftAction(_ sender: Any) {
    switchBoardView.rotateLeft()
  }
  
  @IBOutlet weak var btnRotateRight: NSButton!
  
  @IBAction func btnRotateRightAction(_ sender: Any) {
    switchBoardView.rotateRight()
  }
  
  @IBOutlet weak var btnZoomIn: NSButton!
  
  @IBAction func btnZoomInAction(_ sender: Any) {
    scrollView.magnification += 0.25
  }
  
  @IBOutlet weak var btnZoomOut: NSButton!
  
  @IBAction func btnZoomOutAction(_ sender: Any) {
    scrollView.magnification -= 0.25
  }
  
  @IBOutlet weak var btnSizeToFit: NSButton!
  
  @IBAction func btnSizeToFitAction(_ sender: Any) {

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

  }
  
  @IBOutlet weak var btnGroupMode: NSButton!
  
  @IBAction func btnGroupModeAction(_ sender: NSButton) {
    btnArrangeMode.state = sender.state == .on ? .off : .on
    for button in groupButtons {
      button.isEnabled = btnGroupMode.state == .on
    }
    for button in shapeButtons {
      button.isEnabled = btnGroupMode.state == .off
    }
    switchBoardView.mode = sender.state == .off ? .arrange : .group
  }
  
  @IBOutlet weak var btnAddToGroup: NSButton!
  
  @IBAction func btnAddToGroupAction(_ sender: Any) {
    switchBoardView.addToGroup(groupName: cboGroupId.stringValue)
  }
  
  @IBOutlet weak var btnRemoveFromGroup: NSButton!
  
  @IBAction func btnRemoveFromGroupAction(_ sender: Any) {
    switchBoardView.removeFromGroup()
  }
  
  @IBOutlet weak var btnDelete: NSButton!
  
  @IBAction func btnDeleteAction(_ sender: Any) {
    switchBoardView.delete()
  }
  
  @IBOutlet weak var cboGroupId: NSComboBox!
  
  @IBAction func cboGroupIdAction(_ sender: NSComboBox) {
    switchBoardView.changeGroup(groupName: sender.stringValue)
  }
  
  @IBOutlet weak var cboPanelId: NSComboBox!
  
  @IBAction func cboPanelIdAction(_ sender: NSComboBox) {
    switchBoardView.panelId = sender.indexOfSelectedItem
  }
  
  @IBOutlet weak var txtGridX: NSTextField!
  
  @IBAction func txtGridXAction(_ sender: NSTextField) {
    panels[switchBoardView.panelId].numberOfColumns = sender.integerValue
    switchBoardView.panels = panels
  }
  
  @IBOutlet weak var txtGridY: NSTextField!
  
  @IBAction func txtGridYAction(_ sender: NSTextField) {
    panels[switchBoardView.panelId].numberOfRows = sender.integerValue
    switchBoardView.panels = panels
  }
  
  @IBOutlet weak var txtPanelName: NSTextField!
  
  @IBAction func txtPanelNameAction(_ sender: NSTextField) {
    panels[switchBoardView.panelId].panelName = sender.stringValue
    switchBoardView.panels = panels
  }
  
  @IBAction func btnCancelAction(_ sender: NSButton) {
  }
  
  @IBAction func btnSaveAction(_ sender: NSButton) {
  }
  
}
