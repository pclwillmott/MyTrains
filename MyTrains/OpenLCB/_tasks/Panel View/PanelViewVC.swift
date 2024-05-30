//
//  PanelViewVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 11/04/2024.
//

import Foundation
import AppKit

class PanelViewVC: MyTrainsViewController, MyTrainsAppDelegate {
  
  // MARK: Window & View Methods
  
  override func windowWillClose(_ notification: Notification) {
    appNode?.removeObserver(observerId: appObserverId)
    switchboardView.switchboardPanel?.panelIsVisible = !isManualClose
    super.windowWillClose(notification)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewType = .switchboardPanel
    switchboardView.switchboardPanel?.panelIsVisible = false
  }
  
  override func viewWillAppear() {
    
    super.viewWillAppear()
    
    view.window?.title = ""
    
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.documentView?.frame = NSMakeRect(0.0, 0.0, 2000.0, 2000.0)
    scrollView.allowsMagnification = true
    scrollView.magnification = switchboardMagnification
    cboPanel?.translatesAutoresizingMaskIntoConstraints = false
    cboPanel?.isEditable = false
    btnZoomIn.translatesAutoresizingMaskIntoConstraints = false
    btnZoomOut.translatesAutoresizingMaskIntoConstraints = false
    btnFitToSize.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      btnZoomIn.heightAnchor.constraint(equalToConstant: 20.0),
      btnZoomIn.widthAnchor.constraint(equalToConstant: 20.0),
      btnZoomOut.heightAnchor.constraint(equalTo: btnZoomIn.heightAnchor),
      btnZoomOut.widthAnchor.constraint(equalTo: btnZoomIn.widthAnchor),
      btnFitToSize.heightAnchor.constraint(equalTo: btnZoomIn.heightAnchor),
      btnFitToSize.widthAnchor.constraint(equalTo: btnZoomIn.widthAnchor),
      cboPanel!.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 1.0),
      cboPanel!.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1.0),
      btnZoomIn.leadingAnchor.constraint(equalToSystemSpacingAfter: cboPanel.trailingAnchor, multiplier: 1.0),
      btnZoomOut.leadingAnchor.constraint(equalToSystemSpacingAfter: btnZoomIn.trailingAnchor, multiplier: 1.0),
      btnFitToSize.leadingAnchor.constraint(equalToSystemSpacingAfter: btnZoomOut.trailingAnchor, multiplier: 1.0),
      view.trailingAnchor.constraint(equalToSystemSpacingAfter: btnFitToSize.trailingAnchor, multiplier: 1.0),
      btnZoomIn.centerYAnchor.constraint(equalTo: cboPanel!.centerYAnchor),
      btnZoomOut.topAnchor.constraint(equalTo: btnZoomIn.topAnchor),
      btnFitToSize.topAnchor.constraint(equalTo: btnZoomIn.topAnchor),
      scrollView.topAnchor.constraint(equalToSystemSpacingBelow: cboPanel!.bottomAnchor, multiplier: 1.0),
      scrollView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1.0),
      view.trailingAnchor.constraint(equalToSystemSpacingAfter: scrollView.trailingAnchor, multiplier: 1.0),
      view.bottomAnchor.constraint(equalToSystemSpacingBelow: scrollView.bottomAnchor, multiplier: 1.0),
    ])
    
    switchboardView.showGridLines = false

    appObserverId = appNode!.addObserver(observer: self)
    
  }
  
  private enum DEFAULT {
    static let MAGNIFICATION = "MAGNIFICATION"
  }
  
  // MARK: Private Properties
  
  private var panels : [SwitchboardPanelNode] = []
  
  private var switchboardMagnification : CGFloat {
    get {
      return userSettings?.cgFloat(forKey: DEFAULT.MAGNIFICATION) ?? 1.0
    }
    set(value) {
      userSettings?.set(value, forKey: DEFAULT.MAGNIFICATION)
    }
  }
  
  private var appObserverId : Int = -1

  // MARK: Private Methods
  
  private func updatePanelComboBox() {
  
    if let appNode, let cboPanel {
      
      cboPanel.target = nil
      
      panels.removeAll()
      for (_, item) in appNode.panelList {
        panels.append(item)
      }
      panels.sort {$0.userNodeName.sortValue < $1.userNodeName.sortValue}
      
      let selectedItem = cboPanel.objectValueOfSelectedItem
      
      cboPanel.removeAllItems()
      for item in panels {
        cboPanel.addItem(withObjectValue: item.userNodeName)
      }
      
      cboPanel.selectItem(withObjectValue: selectedItem)
      
      cboPanel.target = self
 
      if cboPanel.indexOfSelectedItem == -1, cboPanel.numberOfItems > 0 {
        if let panel = switchboardView.switchboardPanel {
          cboPanel.selectItem(withObjectValue: panel.userNodeName)
        }
        else {
          cboPanel.selectItem(at: 0)
        }
      }
      
      switchboardView.needsDisplay = true
      
    }

  }

  // MARK: Outlets & Actions
  
  @IBOutlet weak var scrollView: NSScrollView!
  
  @IBOutlet weak var switchboardView: SwitchboardView! {
    didSet {
      userSettings?.node = switchboardView.switchboardPanel
      scrollView.magnification = switchboardMagnification
    }
  }
  
  @IBAction func cboPanelAction(_ sender: NSComboBox) {
    guard sender.indexOfSelectedItem != -1 else {
      return
    }
    userSettings?.node = panels[sender.indexOfSelectedItem]
    scrollView.magnification = switchboardMagnification
    switchboardView.switchboardPanel = panels[sender.indexOfSelectedItem]
    view.window?.title = "\(switchboardView.switchboardPanel!.userNodeName) (\(switchboardView.switchboardPanel!.nodeId.toHexDotFormat(numberOfBytes: 6)))"
    switchboardView.switchboardPanel?.panelIsVisible = false
  }
  
  @IBOutlet weak var cboPanel: NSComboBox!
  
  @IBOutlet weak var btnZoomIn: NSButton!
  
  @IBAction func btnZoomInAction(_ sender: NSButton) {
    switchboardMagnification += 0.1
    scrollView.magnification = switchboardMagnification
  }
  
  @IBOutlet weak var btnZoomOut: NSButton!
  
  @IBAction func btnZoomOutAction(_ sender: NSButton) {
    switchboardMagnification -= 0.1
    scrollView.magnification = switchboardMagnification
  }
  
  @IBOutlet weak var btnFitToSize: NSButton!
  
  @IBAction func btnFitToSizeAction(_ sender: NSButton) {

    scrollView.magnification = 1.0

    let sWidth = scrollView.frame.width
    let sHeight = scrollView.frame.height
    let gWidth = switchboardView.width
    let gHeight = switchboardView.height

    var scale = 1.0

    if gWidth > gHeight {
      scale = sWidth / gWidth
    }
    else {
      scale = sHeight / gHeight
    }
    switchboardMagnification = scale
    scrollView.magnification = switchboardMagnification

  }
  
  // MARK: MyTrainsAppDelegate Methods
  
  func panelListUpdated(appNode:OpenLCBNodeMyTrains) {
    updatePanelComboBox()
  }

  func panelUpdated(panel:SwitchboardPanelNode) {
    if panel === switchboardView.switchboardPanel {
      switchboardView.needsDisplay = true
    }
  }

}
