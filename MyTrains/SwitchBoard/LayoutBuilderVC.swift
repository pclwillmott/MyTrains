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
    inspectorButtons.removeAll()
    inspectorStripView?.subviews.removeAll()
    inspectorStripView = nil
    arrangeView?.subviews.removeAll()
    arrangeView = nil
    groupView?.subviews.removeAll()
    groupView = nil
    arrangeButtons.removeAll()
    arrangeStripView?.subviews.removeAll()
    arrangeStripView = nil
    groupButtons.removeAll()
    groupStripView?.subviews.removeAll()
    groupStripView = nil
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
    static let CURRENT_INSPECTOR   = "CURRENT_INSPECTOR"
  }
  
  override func viewWillAppear() {
    
    super.viewWillAppear()
    
    view.window?.title = String(localized: "Layout Builder", comment:"Used for the title of the Layout Builder window.")
    
    btnShowInspectorView = MyIcon.trailingThird.button(target: self, action: #selector(btnShowInspectorViewAction(_:)))

    btnShowPaletteView = MyIcon.leadingThird.button(target: self, action: #selector(btnShowPaletteViewAction(_:)))
    
    btnShowPanelView = MyIcon.bottomThird.button(target: self, action: #selector(btnShowPanelViewAction(_:)))

    inspectorButtons = [
      MyIcon.info.button(target: self, action: nil),
      MyIcon.help.button(target: self, action: nil),
      MyIcon.gear.button(target: self, action: nil),
      MyIcon.bolt.button(target: self, action: nil),
      MyIcon.speedometer.button(target: self, action: nil),
      MyIcon.connection.button(target: self, action: nil),
    ]
    
    inspectorButtons[0]?.toolTip = String(localized: "Show Information Inspector")
    inspectorButtons[1]?.toolTip = String(localized: "Show Quick Help Inspector")
    inspectorButtons[2]?.toolTip = String(localized: "Show Attributes Inspector")
    inspectorButtons[3]?.toolTip = String(localized: "Show Events Inspector")
    inspectorButtons[4]?.toolTip = String(localized: "Show Speed Constraints Inspector")
    inspectorButtons[5]?.toolTip = String(localized: "Show Turnout Inspector")

    arrangeButtons = [
      MyIcon.addItem.button(target: self, action: nil),
      MyIcon.removeItem.button(target: self, action: nil),
      MyIcon.rotateCounterClockwise.button(target: self, action: nil),
      MyIcon.rotateClockwise.button(target: self, action: nil),
      MyIcon.groupMode.button(target: self, action: nil),
    ]

    arrangeButtons[0]?.toolTip = String(localized: "Add Item to Panel")
    arrangeButtons[1]?.toolTip = String(localized: "Remove Item from Panel")
    arrangeButtons[2]?.toolTip = String(localized: "Rotate Item Counter Clockwise")
    arrangeButtons[3]?.toolTip = String(localized: "Rotate Item Clockwise")
    arrangeButtons[4]?.toolTip = String(localized: "Switch to Grouping Mode")

    arrangeButtons[0]?.keyEquivalent = "+"
    arrangeButtons[1]?.keyEquivalent = "-"
    
    groupButtons = [
      MyIcon.addToGroup.button(target: self, action: nil),
      MyIcon.removeFromGroup.button(target: self, action: nil),
      MyIcon.cursor.button(target: self, action: nil),
    ]

    groupButtons[0]?.toolTip = String(localized: "Add Item to Group")
    groupButtons[1]?.toolTip = String(localized: "Remove Item from Group")
    groupButtons[2]?.toolTip = String(localized: "Switch to Arrange Mode")

    guard let cboPanel, let splitView, let paletteView, let layoutView, let inspectorView, let panelView, let panelStripView, let btnShowPanelView, let btnShowInspectorView, let btnShowPaletteView, let inspectorStripView, let arrangeView, let arrangeStripView, let groupView, let groupStripView else {
      return
    }
    
    cboPanel.translatesAutoresizingMaskIntoConstraints = false
    cboPanel.isEditable = false

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
    
//    inspectorView.wantsLayer = true
//    inspectorView.layer?.backgroundColor = NSColor.green.cgColor
    
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
    
    inspectorStripView.translatesAutoresizingMaskIntoConstraints = false
    
    inspectorView.addSubview(inspectorStripView)

//    inspectorStripView.wantsLayer = true
//    inspectorStripView.layer?.backgroundColor = NSColor.white.cgColor

    constraints.append(inspectorStripView.topAnchor.constraint(equalTo: inspectorView.topAnchor))
    constraints.append(inspectorStripView.centerXAnchor.constraint(equalTo: inspectorView.centerXAnchor))
    constraints.append(inspectorStripView.heightAnchor.constraint(equalToConstant: 20.0))

    var lastButton : NSButton?
    
    var index = 0
    for button in inspectorButtons {
      if let button {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isBordered = false
        button.tag = index
        button.target = self
        button.action = #selector(btnInspectorAction(_:))
        let view = NSView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.wantsLayer = true
        view.layer?.backgroundColor = (index % 2 == 0) ? NSColor.brown.cgColor : NSColor.yellow.cgColor
        inspectorViews.append(view)
        inspectorView.addSubview(view)
        constraints.append(view.topAnchor.constraint(equalToSystemSpacingBelow: inspectorStripView.bottomAnchor, multiplier: 1.0))
        constraints.append(view.leadingAnchor.constraint(equalTo: inspectorView.leadingAnchor))
        constraints.append(view.trailingAnchor.constraint(equalTo: inspectorView.trailingAnchor))
        constraints.append(view.heightAnchor.constraint(equalToConstant: 300))
        index += 1
        inspectorStripView.addSubview(button)
        constraints.append(button.centerYAnchor.constraint(equalTo: inspectorStripView.centerYAnchor))
        if let lastButton {
          constraints.append(button.leadingAnchor.constraint(equalToSystemSpacingAfter: lastButton.trailingAnchor, multiplier: 1.0))
        }
        else {
          constraints.append(button.leadingAnchor.constraint(equalToSystemSpacingAfter: inspectorStripView.leadingAnchor, multiplier: 1.0))
        }
        lastButton = button
      }
    }
    constraints.append(inspectorStripView.trailingAnchor.constraint(equalToSystemSpacingAfter: lastButton!.trailingAnchor, multiplier: 1.0))
    constraints.append(inspectorView.widthAnchor.constraint(greaterThanOrEqualTo: inspectorStripView.widthAnchor, multiplier: 1.0))
    inspectorButtons[currentInspectorIndex]?.contentTintColor = NSColor.systemBlue

    arrangeView.translatesAutoresizingMaskIntoConstraints = false
    arrangeStripView.translatesAutoresizingMaskIntoConstraints = false

    arrangeView.wantsLayer = true
    arrangeView.layer?.backgroundColor = NSColor.orange.cgColor
//    arrangeStripView.wantsLayer = true
//    arrangeStripView.layer?.backgroundColor = NSColor.white.cgColor

    paletteView.addSubview(arrangeView)
    
    constraints.append(arrangeView.topAnchor.constraint(equalTo: paletteView.topAnchor))
    constraints.append(arrangeView.centerXAnchor.constraint(equalTo: paletteView.centerXAnchor))
    constraints.append(paletteView.bottomAnchor.constraint(greaterThanOrEqualTo: arrangeView.bottomAnchor))
    constraints.append(paletteView.widthAnchor.constraint(greaterThanOrEqualTo: arrangeView.widthAnchor))
    
    arrangeView.addSubview(arrangeStripView)
    
    constraints.append(arrangeStripView.topAnchor.constraint(equalTo: arrangeView.topAnchor))
    constraints.append(arrangeStripView.centerXAnchor.constraint(equalTo: arrangeView.centerXAnchor))
    constraints.append(arrangeStripView.heightAnchor.constraint(equalToConstant: 20.0))
    constraints.append(arrangeView.bottomAnchor.constraint(greaterThanOrEqualTo: arrangeStripView.bottomAnchor))

    lastButton = nil
    index = 0
    for button in arrangeButtons {
      if let button {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isBordered = false
        button.tag = index
        button.target = self
        button.action = #selector(btnArrangeAction(_:))
        index += 1
        arrangeStripView.addSubview(button)
        constraints.append(button.centerYAnchor.constraint(equalTo: arrangeStripView.centerYAnchor))
        if let lastButton {
          constraints.append(button.leadingAnchor.constraint(equalToSystemSpacingAfter: lastButton.trailingAnchor, multiplier: 1.0))
        }
        else {
          constraints.append(button.leadingAnchor.constraint(equalToSystemSpacingAfter: arrangeStripView.leadingAnchor, multiplier: 1.0))
        }
      }
      lastButton = button
    }
    constraints.append(arrangeStripView.trailingAnchor.constraint(equalToSystemSpacingAfter: lastButton!.trailingAnchor, multiplier: 1.0))
    constraints.append(arrangeView.widthAnchor.constraint(greaterThanOrEqualTo: arrangeStripView.widthAnchor))
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
    
    btnInspectorAction(inspectorButtons[userSettings!.integer(forKey: DEFAULT.CURRENT_INSPECTOR)]!)
    
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

  private var btnShowInspectorView : NSButton?
  
  private var inspectorStripView : NSView? = NSView()
  
  private var inspectorButtons : [NSButton?] = []
  
  private var inspectorViews : [NSView] = []
  
  private var arrangeView : NSView? = NSView()
  
  private var arrangeStripView : NSView? = NSView()
  
  private var arrangeButtons : [NSButton?] = []
  
  private var groupView : NSView? = NSView()
  
  private var groupStripView : NSView? = NSView()
  
  private var groupButtons : [NSButton?] = []
  
  private var currentInspectorIndex = 0

  private var btnShowPaletteView : NSButton?
  
  private var btnShowPanelView : NSButton?
  
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
  
  @IBAction func btnInspectorAction(_ sender: NSButton) {
    currentInspectorIndex = sender.tag
    for button in inspectorButtons {
      button!.contentTintColor = nil
      inspectorViews[button!.tag].isHidden = true
    }
    inspectorButtons[currentInspectorIndex]?.contentTintColor = NSColor.systemBlue
    inspectorViews[currentInspectorIndex].isHidden = false
    userSettings?.set(currentInspectorIndex, forKey: DEFAULT.CURRENT_INSPECTOR)
  }

  @IBAction func btnArrangeAction(_ sender: NSButton) {
    debugLog("\(sender.tag)")
  }
  
}
