//
//  SwitchboardEditorVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 13/04/2024.
//

import Foundation
import AppKit

class LayoutBuilderVC: MyTrainsViewController {
  
  // MARK: Window & View Methods
  
  override func windowWillClose(_ notification: Notification) {
    NSLayoutConstraint.deactivate(constraints)
    constraints.removeAll()
    view.subviews.removeAll()
    cboPanel?.removeAllItems()
    cboPanel = nil
    splitView?.removeArrangedSubview(paletteView!)
    splitView?.removeArrangedSubview(layoutView!)
    splitView?.removeArrangedSubview(inspectorView!)
    paletteView?.subviews.removeAll()
    paletteView = nil
    layoutView?.subviews.removeAll()
    layoutView = nil
    inspectorView?.subviews.removeAll()
    inspectorView = nil
    panelStripView?.subviews.removeAll()
    panelStripView = nil
    btnShowPanelView?.target = nil
    btnShowPanelView = nil
    btnShowPaletteView?.target = nil
    btnShowPaletteView = nil
    btnShowInspectorView?.target = nil
    btnShowInspectorView = nil
    super.windowWillClose(notification)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewType = .switchboardPanel
  }
  
  private enum DEFAULT {
    static let SHOW_PANEL_VIEW     = "SHOW_PANEL_VIEW"
    static let SHOW_PALETTE_VIEW   = "SHOW_PALETTE_VIEW"
    static let SHOW_INSPECTOR_VIEW = "SHOW_INSPECTOR_VIEW"
  }
  
  override func viewWillAppear() {
    
    super.viewWillAppear()
    
    view.window?.title = String(localized: "Layout Builder", comment:"Used for the title of the Layout Builder window.")
    
    guard let cboPanel, let splitView, let paletteView, let layoutView, let inspectorView, let panelView, let panelStripView, let btnShowPanelView, let btnShowInspectorView, let btnShowPaletteView else {
      return
    }
    
    cboPanel.translatesAutoresizingMaskIntoConstraints = false
    cboPanel.isEditable = false

    view.subviews.removeAll() // Get rid of the buttons for now!
    
    view.addSubview(cboPanel)

    constraints.append(cboPanel.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 1.0))
    constraints.append(cboPanel.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1.0))
    constraints.append(view.trailingAnchor.constraint(equalToSystemSpacingAfter: cboPanel.trailingAnchor, multiplier: 1.0))
    
    splitView.translatesAutoresizingMaskIntoConstraints = false
    splitView.isVertical = true

    view.addSubview(splitView)
    
    userSettings?.splitView = splitView
    
    constraints.append(splitView.topAnchor.constraint(equalToSystemSpacingBelow: cboPanel.bottomAnchor, multiplier: 1.0))
    constraints.append(splitView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1.0))
    constraints.append(splitView.trailingAnchor.constraint(equalTo: cboPanel.trailingAnchor))
    
    paletteView.translatesAutoresizingMaskIntoConstraints = false
    layoutView.translatesAutoresizingMaskIntoConstraints = false
    inspectorView.translatesAutoresizingMaskIntoConstraints = false
    
    splitView.arrangesAllSubviews = true
    splitView.addArrangedSubview(paletteView)
    splitView.addArrangedSubview(layoutView)
    splitView.addArrangedSubview(inspectorView)
    
    paletteView.wantsLayer = true
    paletteView.layer?.backgroundColor = NSColor.blue.cgColor
    
    layoutView.wantsLayer = true
    layoutView.layer?.backgroundColor = NSColor.red.cgColor
    
    inspectorView.wantsLayer = true
    inspectorView.layer?.backgroundColor = NSColor.green.cgColor
    
    constraints.append(paletteView.widthAnchor.constraint(greaterThanOrEqualToConstant: 100))
    constraints.append(paletteView.heightAnchor.constraint(equalToConstant: 100.0))

    constraints.append(layoutView.widthAnchor.constraint(greaterThanOrEqualToConstant: 100))
    constraints.append(layoutView.heightAnchor.constraint(equalToConstant: 100.0))

    constraints.append(inspectorView.widthAnchor.constraint(greaterThanOrEqualToConstant: 100))
    constraints.append(inspectorView.heightAnchor.constraint(equalToConstant: 100.0))
    constraints.append(inspectorView.trailingAnchor.constraint(equalTo: splitView.trailingAnchor))

    panelView.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(panelView)

    panelView.wantsLayer = true
    panelView.layer?.backgroundColor = NSColor.yellow.cgColor

    constraints.append(panelView.topAnchor.constraint(equalToSystemSpacingBelow: splitView.bottomAnchor, multiplier: 1.0))
    constraints.append(panelView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1.0))
    constraints.append(panelView.trailingAnchor.constraint(equalTo: cboPanel.trailingAnchor))
    constraints.append(view.bottomAnchor.constraint(equalToSystemSpacingBelow: panelView.bottomAnchor, multiplier: 1.0))
    
    panelStripView.translatesAutoresizingMaskIntoConstraints = false
    
    panelView.addSubview(panelStripView)
    
    showPanelConstraint = panelView.heightAnchor.constraint(equalToConstant: 100)
    showPanelConstraint?.isActive = true

    panelStripView.wantsLayer = true
    panelStripView.layer?.backgroundColor = NSColor.white.cgColor

    constraints.append(panelStripView.topAnchor.constraint(equalTo: panelView.topAnchor))
    constraints.append(panelStripView.leadingAnchor.constraint(equalTo: panelView.leadingAnchor))
    constraints.append(panelStripView.trailingAnchor.constraint(equalTo: panelView.trailingAnchor))
    constraints.append(panelStripView.heightAnchor.constraint(equalToConstant: 20.0))
    constraints.append(panelView.bottomAnchor.constraint(greaterThanOrEqualTo: panelStripView.bottomAnchor))
    
    btnShowPanelView.translatesAutoresizingMaskIntoConstraints = false
    btnShowPanelView.isBordered = false
    btnShowPanelView.contentTintColor = NSColor.systemBlue
    btnShowPanelView.toolTip = String(localized: "Hide the Panel Configuration Area")
    
    panelStripView.addSubview(btnShowPanelView)
    
    constraints.append(btnShowPanelView.centerYAnchor.constraint(equalTo: panelStripView.centerYAnchor))
    constraints.append(btnShowPanelView.centerXAnchor.constraint(equalTo: panelStripView.centerXAnchor))
    
    btnShowInspectorView.translatesAutoresizingMaskIntoConstraints = false
    btnShowInspectorView.isBordered = false
    btnShowInspectorView.contentTintColor = NSColor.systemBlue
    btnShowInspectorView.toolTip = String(localized: "Hide the Inspector Area")

    panelStripView.addSubview(btnShowInspectorView)
    
    constraints.append(btnShowInspectorView.centerYAnchor.constraint(equalTo: panelStripView.centerYAnchor))
    constraints.append(panelStripView.trailingAnchor.constraint(equalToSystemSpacingAfter: btnShowInspectorView.trailingAnchor, multiplier: 1.0))
    
    btnShowPaletteView.translatesAutoresizingMaskIntoConstraints = false
    btnShowPaletteView.isBordered = false
    btnShowPaletteView.contentTintColor = NSColor.systemBlue
    btnShowPaletteView.toolTip = String(localized: "Hide the Palette Area")

    panelStripView.addSubview(btnShowPaletteView)
    
    constraints.append(btnShowPaletteView.centerYAnchor.constraint(equalTo: panelStripView.centerYAnchor))
    constraints.append(btnShowPaletteView.leadingAnchor.constraint(equalToSystemSpacingAfter: panelStripView.leadingAnchor, multiplier: 1.0))

    NSLayoutConstraint.activate(constraints)
    
    if let appNode {
      for (_, item) in appNode.panelList {
        panels.append(item)
      }
      panels.sort {$0.userNodeName < $1.userNodeName}
      cboPanel.removeAllItems()
      var index = -1
      var test = 0
      for item in panels {
        cboPanel.addItem(withObjectValue: item.userNodeName)
        if let panel = switchboardPanel, panel.nodeId == item.nodeId {
          index = test
        }
        test += 1
      }
      if index != -1 {
        cboPanel.selectItem(at: index)
      }
    }

    userSettings?.node = switchboardPanel
    self.cboPanel?.target = self
    self.cboPanel?.action = #selector(self.cboPanelAction(_:))

    setStates()
    
  }
  
  // MARK: Private Properties
  
  private var constraints : [NSLayoutConstraint] = []
  
  private var showPanelConstraint : NSLayoutConstraint?
  
  private var panels : [SwitchboardPanelNode] = []
  
  // MARK: Public Properties
  
  public weak var switchboardPanel : SwitchboardPanelNode? {
    didSet {
      userSettings?.node = switchboardPanel
      setStates()
    }
  }
  
  // MARK: Private Methods
  
  private func setStates() {
    
    guard let btnShowPanelView, let btnShowPaletteView, let btnShowInspectorView else {
      return
    }
    
    btnShowPanelView.state = userSettings!.state(forKey: DEFAULT.SHOW_PANEL_VIEW)
    btnShowPaletteView.state = userSettings!.state(forKey: DEFAULT.SHOW_PALETTE_VIEW)
    btnShowInspectorView.state = userSettings!.state(forKey: DEFAULT.SHOW_INSPECTOR_VIEW)

    btnShowPanelViewAction(btnShowPanelView)
    btnShowPaletteViewAction(btnShowPaletteView)
    btnShowInspectorViewAction(btnShowInspectorView)
    
  }
  // MARK: Outlets & Actions
  
  private var cboPanel : NSComboBox? = MyComboBox()
 
  @objc func cboPanelAction(_ sender: NSComboBox) {
    if sender.indexOfSelectedItem == -1 {
      switchboardPanel = nil
    }
    else {
      switchboardPanel = panels[sender.indexOfSelectedItem]
    }
  }
  
  private var splitView : NSSplitView? = NSSplitView()
  
  private var paletteView   : NSView? = NSView()
  private var layoutView    : NSView? = NSView()
  private var inspectorView : NSView? = NSView()
  
  private var panelView : NSView? = NSView()
  
  private var panelStripView : NSView? = NSView()

  private var btnShowInspectorView = MyIcon.trailingThird.button(target: self, action: #selector(btnShowInspectorViewAction(_:)))

  private var btnShowPaletteView = MyIcon.leadingThird.button(target: self, action: #selector(btnShowPaletteViewAction(_:)))
  
  private var btnShowPanelView = MyIcon.bottomThird.button(target: self, action: #selector(btnShowPanelViewAction(_:)))
  
  @IBAction func btnShowPanelViewAction(_ sender: NSButton) {
    showPanelConstraint?.isActive = false
    if sender.state == .on {
      showPanelConstraint = panelView?.bottomAnchor.constraint(equalTo: panelStripView!.bottomAnchor)
      btnShowPanelView?.contentTintColor = nil
      btnShowPanelView?.toolTip = String(localized: "Show the Panel Configuration Area")
    }
    else {
      showPanelConstraint = panelView?.heightAnchor.constraint(equalToConstant: 200)
      btnShowPanelView?.contentTintColor = NSColor.systemBlue
      btnShowPanelView?.toolTip = String(localized: "Hide the Panel Configuration Area")
    }
    showPanelConstraint?.isActive = true
    userSettings?.set(btnShowPanelView!.state, forKey: DEFAULT.SHOW_PANEL_VIEW)
  }

  @IBAction func btnShowInspectorViewAction(_ sender: NSButton) {
    if sender.state == .on {
      splitView?.removeArrangedSubview(inspectorView!)
      btnShowInspectorView?.contentTintColor = nil
      btnShowInspectorView?.toolTip = String(localized: "Show the Inspector Area")
    }
    else {
      splitView?.addSubview(inspectorView!, positioned: .above, relativeTo: layoutView!)
      btnShowInspectorView?.contentTintColor = NSColor.systemBlue
      btnShowInspectorView?.toolTip = String(localized: "Hide the Inspector Area")
    }
    userSettings?.set(btnShowInspectorView!.state, forKey: DEFAULT.SHOW_INSPECTOR_VIEW)
  }
  
  @IBAction func btnShowPaletteViewAction(_ sender: NSButton) {
    if sender.state == .on {
      splitView?.removeArrangedSubview(paletteView!)
      btnShowPaletteView?.contentTintColor = nil
      btnShowPaletteView?.toolTip = String(localized: "Show the Palette Area")
    }
    else {
      splitView?.addSubview(paletteView!, positioned: .below, relativeTo: layoutView!)
      btnShowPaletteView?.contentTintColor = NSColor.systemBlue
      btnShowPaletteView?.toolTip = String(localized: "Hide the Palette Area")
    }
    userSettings?.set(btnShowPaletteView!.state, forKey: DEFAULT.SHOW_PALETTE_VIEW)
  }
  
}
