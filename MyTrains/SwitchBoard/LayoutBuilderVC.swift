//
//  SwitchboardEditorVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 13/04/2024.
//

import Foundation
import AppKit

class LayoutBuilderVC: MyTrainsViewController, SwitchboardEditorViewDelegate {
  
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
    cboPalette?.removeAllItems()
    cboPalette = nil
    groupButtons.removeAll()
    groupStripView?.subviews.removeAll()
    groupStripView = nil
    layoutStripView?.subviews.removeAll()
    layoutStripView = nil
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
    static let IS_GROUP_MODE       = "IS_GROUP_MODE"
    static let CURRENT_PALETTE     = "CURRENT_PALETTE"
    static let MAGNIFICATION       = "MAGNIFICATION"
  }
  
  private enum ArrangeButton : Int {
    case addItemToPanel = 0
    case removeItemFromPanel = 1
    case rotateCounterClockwise = 2
    case rotateClockwise = 3
    case switchToGroupingMode = 4
  }
  
  private enum InspectorButton : Int {
    case showInformationInspector = 0
    case showQuickHelpInspector = 1
    case showAttributesInspector = 2
    case showEventsInspector = 3
    case showSpeedConstraintsInspector = 4
    case showTurnoutInspector = 5
  }
  
  private enum GroupButton : Int {
    case addItemToGroup = 0
    case removeItemFromGroup = 1
    case switchToArrangeMode = 2
  }
  
  private enum LayoutButton : Int {
    case zoomIn = 0
    case zoomOut = 1
    case fitToSize = 2
  }
  
  private enum PanelProperty : Int {
    case layoutId = 1
    case layoutName = 2
    case panelId = 3
    case panelName = 4
    case panelDescription = 5
    case numberOfRows = 6
    case numberOfColumns = 7
  }

  private enum AttributeProperty : Int {
    case name = 1
    case description = 2
    case xPos = 3
    case yPos = 4
    case orientation = 5
    case group = 6
    case directionality = 7
    case allowShunt = 8
    case trackElectrificationType = 9
    case isCriticalSection = 10
    case isHiddenSection = 11
    case trackGradient = 12
    case trackGauge = 13
    case lengthRoute1 = 14
    case lengthRoute2 = 15
    case lengthRoute3 = 16
    case lengthRoute4 = 17
    case lengthRoute5 = 18
    case lengthRoute6 = 19
    case lengthRoute7 = 20
    case lengthRoute8 = 21
  }
  
  override func viewWillAppear() {
    
    super.viewWillAppear()
    
    view.window?.title = String(localized: "Layout Builder", comment:"Used for the title of the Layout Builder window.")
    
    switchboardView.delegate = self
    
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
    
    inspectorButtons[InspectorButton.showInformationInspector.rawValue]?.toolTip = String(localized: "Show Information Inspector")
    inspectorButtons[InspectorButton.showQuickHelpInspector.rawValue]?.toolTip = String(localized: "Show Quick Help Inspector")
    inspectorButtons[InspectorButton.showAttributesInspector.rawValue]?.toolTip = String(localized: "Show Attributes Inspector")
    inspectorButtons[InspectorButton.showEventsInspector.rawValue]?.toolTip = String(localized: "Show Events Inspector")
    inspectorButtons[InspectorButton.showSpeedConstraintsInspector.rawValue]?.toolTip = String(localized: "Show Speed Constraints Inspector")
    inspectorButtons[InspectorButton.showTurnoutInspector.rawValue]?.toolTip = String(localized: "Show Turnout Inspector")

    arrangeButtons = [
      MyIcon.addItem.button(target: self, action: nil),
      MyIcon.removeItem.button(target: self, action: nil),
      MyIcon.rotateCounterClockwise.button(target: self, action: nil),
      MyIcon.rotateClockwise.button(target: self, action: nil),
      MyIcon.groupMode.button(target: self, action: nil),
    ]
    
    arrangeButtons[ArrangeButton.addItemToPanel.rawValue]?.toolTip = String(localized: "Add Item to Panel")
    arrangeButtons[ArrangeButton.removeItemFromPanel.rawValue]?.toolTip = String(localized: "Remove Item from Panel")
    arrangeButtons[ArrangeButton.rotateCounterClockwise.rawValue]?.toolTip = String(localized: "Rotate Item Counter Clockwise")
    arrangeButtons[ArrangeButton.rotateClockwise.rawValue]?.toolTip = String(localized: "Rotate Item Clockwise")
    arrangeButtons[ArrangeButton.switchToGroupingMode.rawValue]?.toolTip = String(localized: "Switch to Grouping Mode")

    arrangeButtons[ArrangeButton.addItemToPanel.rawValue]?.keyEquivalent = "+"
    arrangeButtons[ArrangeButton.removeItemFromPanel.rawValue]?.keyEquivalent = "-"
    
    groupButtons = [
      MyIcon.addToGroup.button(target: self, action: nil),
      MyIcon.removeFromGroup.button(target: self, action: nil),
      MyIcon.cursor.button(target: self, action: nil),
    ]

    groupButtons[GroupButton.addItemToGroup.rawValue]?.toolTip = String(localized: "Add Item to Group")
    groupButtons[GroupButton.removeItemFromGroup.rawValue]?.toolTip = String(localized: "Remove Item from Group")
    groupButtons[GroupButton.switchToArrangeMode.rawValue]?.toolTip = String(localized: "Switch to Arrange Mode")
    
    layoutButtons = [
      MyIcon.zoomIn.button(target: self, action: nil),
      MyIcon.zoomOut.button(target: self, action: nil),
      MyIcon.fitToSize.button(target: self, action: nil),
    ]
    
    panelControls = [
      (
        NSTextField(labelWithString: String(localized: "Layout ID")),
        NSTextField(labelWithString: ""),
        .layoutId
      ),
      (
        NSTextField(labelWithString: String(localized: "Layout Name")),
        NSTextField(labelWithString: ""),
        .layoutName
      ),
      (
        NSTextField(labelWithString: String(localized: "Panel ID")),
        NSTextField(labelWithString: ""),
        .panelId
      ),
      (
        NSTextField(labelWithString: String(localized: "Panel Name")),
        NSTextField(),
        .panelName
      ),
      (
        NSTextField(labelWithString: String(localized: "Panel Description")),
        NSTextField(),
        .panelDescription
      ),
      (
        NSTextField(labelWithString: String(localized: "Number of Rows")),
        NSTextField(),
        .numberOfRows
      ),
      (
        NSTextField(labelWithString: String(localized: "Number of Columns")),
        NSTextField(),
        .numberOfColumns
      ),
    ]
    
    attributeControls = [
      (
        "Identity",
        NSTextField(labelWithString: String(localized: "Name")),
        NSTextField(),
        .name
      ),
      (
        "Identity",
        NSTextField(labelWithString: String(localized: "Description")),
        NSTextField(),
        .description
      ),
      (
        "General Settings",
        NSTextField(labelWithString: String(localized: "X Coordinate")),
        NSTextField(),
        .xPos
      ),
      (
        "General Settings",
        NSTextField(labelWithString: String(localized: "Y Coordinate")),
        NSTextField(),
        .yPos
      ),
      (
        "General Settings",
        NSTextField(labelWithString: String(localized: "Orientation")),
        NSComboBox(),
        .orientation
      ),
      (
        "General Settings",
        NSTextField(labelWithString: String(localized: "Group")),
        NSComboBox(),
        .group
      ),
      (
        "Block Settings",
        NSTextField(labelWithString: String(localized: "Directionality")),
        NSComboBox(),
        .directionality
      ),
      (
        "Block Settings",
        NSTextField(labelWithString: String(localized: "Allow Shunt")),
        NSComboBox(),
        .allowShunt
      ),
      (
        "Block Settings",
        NSTextField(labelWithString: String(localized: "Electrification")),
        NSComboBox(),
        .trackElectrificationType
      ),
      (
        "Block Settings",
        NSTextField(labelWithString: String(localized: "Is Critical Section")),
        NSComboBox(),
        .isCriticalSection
      ),
      (
        "Block Settings",
        NSTextField(labelWithString: String(localized: "Is Hidden Section")),
        NSComboBox(),
        .isHiddenSection
      ),
      (
        "Track Configuration",
        NSTextField(labelWithString: String(localized: "Track Gradient")),
        NSTextField(),
        .trackGradient
      ),
      (
        "Track Configuration",
        NSTextField(labelWithString: String(localized: "Track Guage")),
        NSComboBox(),
        .isHiddenSection
      ),
      (
        "Track Configuration",
        NSTextField(labelWithString: String(localized: "Length of Route #1")),
        NSTextField(),
        .lengthRoute1
      ),
      (
        "Track Configuration",
        NSTextField(labelWithString: String(localized: "Length of Route #2")),
        NSTextField(),
        .lengthRoute2
      ),
      (
        "Track Configuration",
        NSTextField(labelWithString: String(localized: "Length of Route #3")),
        NSTextField(),
        .lengthRoute3
      ),
      (
        "Track Configuration",
        NSTextField(labelWithString: String(localized: "Length of Route #4")),
        NSTextField(),
        .lengthRoute4
      ),
      (
        "Track Configuration",
        NSTextField(labelWithString: String(localized: "Length of Route #5")),
        NSTextField(),
        .lengthRoute5
      ),
      (
        "Track Configuration",
        NSTextField(labelWithString: String(localized: "Length of Route #6")),
        NSTextField(),
        .lengthRoute6
      ),
      (
        "Track Configuration",
        NSTextField(labelWithString: String(localized: "Length of Route #7")),
        NSTextField(),
        .lengthRoute7
      ),
      (
        "Track Configuration",
        NSTextField(labelWithString: String(localized: "Length of Route #8")),
        NSTextField(),
        .lengthRoute8
      ),
    ]
    
    layoutButtons[LayoutButton.zoomIn.rawValue]?.toolTip = String(localized: "Zoom In")
    layoutButtons[LayoutButton.zoomOut.rawValue]?.toolTip = String(localized: "Zoom Out")
    layoutButtons[LayoutButton.fitToSize.rawValue]?.toolTip = String(localized: "Fit to Size")

    guard let cboPanel, let splitView, let paletteView, let layoutView, let inspectorView, let panelView, let panelStripView, let btnShowPanelView, let btnShowInspectorView, let btnShowPaletteView, let inspectorStripView, let arrangeView, let arrangeStripView, let groupView, let groupStripView, let layout = appNode?.layout, let cboPalette, let layoutStripView, let panelStack else {
      return
    }
    
    view.subviews.removeAll()
    
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
    constraints.append(splitView.trailingAnchor.constraint(equalTo: view.trailingAnchor))
    
    paletteView.translatesAutoresizingMaskIntoConstraints = false
    layoutView.translatesAutoresizingMaskIntoConstraints = false
    inspectorView.translatesAutoresizingMaskIntoConstraints = false
    
    splitView.arrangesAllSubviews = true
    splitView.addArrangedSubview(paletteView)
    splitView.addArrangedSubview(layoutView)
    splitView.addArrangedSubview(inspectorView)
    
 //   paletteView.wantsLayer = true
 //   paletteView.layer?.backgroundColor = NSColor.blue.cgColor
    
//    layoutView.wantsLayer = true
//    layoutView.layer?.backgroundColor = NSColor.red.cgColor
    
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    switchboardView.translatesAutoresizingMaskIntoConstraints = false
    
    layoutStripView.translatesAutoresizingMaskIntoConstraints = false
//    layoutStripView.wantsLayer = true
//    layoutStripView.layer?.backgroundColor = NSColor.white.cgColor

    layoutView.addSubview(layoutStripView)
    
    constraints.append(layoutStripView.topAnchor.constraint(equalTo: layoutView.topAnchor))
    constraints.append(layoutStripView.centerXAnchor.constraint(equalTo: layoutView.centerXAnchor))
    constraints.append(layoutStripView.heightAnchor.constraint(equalToConstant: 20.0))
    
    var lastButton : NSButton?
    
    var index = 0
    for button in layoutButtons {
      if let button {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isBordered = false
        button.tag = index
        index += 1
        button.target = self
        button.action = #selector(btnLayoutAction(_:))
        layoutStripView.addSubview(button)
        constraints.append(button.centerYAnchor.constraint(equalTo: layoutStripView.centerYAnchor))
        if let lastButton {
          constraints.append(button.leadingAnchor.constraint(equalToSystemSpacingAfter: lastButton.trailingAnchor, multiplier: 1.0))
        }
        else {
          constraints.append(button.leadingAnchor.constraint(equalToSystemSpacingAfter: layoutStripView.leadingAnchor, multiplier: 1.0))
        }
        lastButton = button
      }
    }
    constraints.append(layoutStripView.trailingAnchor.constraint(equalToSystemSpacingAfter: lastButton!.trailingAnchor, multiplier: 1.0))
    constraints.append(layoutView.widthAnchor.constraint(greaterThanOrEqualTo: layoutStripView.widthAnchor, multiplier: 1.0))
    
    layoutView.addSubview(scrollView)
    constraints.append(scrollView.topAnchor.constraint(equalToSystemSpacingBelow: layoutStripView.bottomAnchor, multiplier: 1.0))
    constraints.append(scrollView.leadingAnchor.constraint(equalTo: layoutView.leadingAnchor))
    constraints.append(scrollView.trailingAnchor.constraint(equalTo: layoutView.trailingAnchor))
    constraints.append(scrollView.bottomAnchor.constraint(equalTo: layoutView.bottomAnchor))

    scrollView.documentView?.frame = NSMakeRect(0.0, 0.0, 2000.0, 2000.0)
    scrollView.allowsMagnification = true
    scrollView.magnification = switchboardMagnification

    // MARK: PanelView
    
    panelView.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(panelView)

 //   panelView.backgroundColor = NSColor.yellow.cgColor

    constraints.append(panelView.topAnchor.constraint(equalToSystemSpacingBelow: splitView.bottomAnchor, multiplier: 1.0))
    constraints.append(panelView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1.0))
    constraints.append(panelView.trailingAnchor.constraint(equalTo: cboPanel.trailingAnchor))
    constraints.append(view.bottomAnchor.constraint(equalToSystemSpacingBelow: panelView.bottomAnchor, multiplier: 1.0))
    
    panelStripView.translatesAutoresizingMaskIntoConstraints = false
    
    panelView.addSubview(panelStripView)
    
    panelStack.translatesAutoresizingMaskIntoConstraints = false
    
    panelView.addSubview(panelStack)
    
    panelStack.orientation = .vertical
    panelStack.spacing = 4
    
    constraints.append(panelStack.topAnchor.constraint(equalToSystemSpacingBelow: panelStripView.bottomAnchor, multiplier: 1.0))
    constraints.append(panelStack.leadingAnchor.constraint(equalTo: panelView.leadingAnchor))
    constraints.append(panelView.trailingAnchor.constraint(equalTo: panelStack.trailingAnchor))
    
    let labelFontSize : CGFloat = 10.0
    let textFontSize  : CGFloat = 11.0
    
    let longFields : Set<PanelProperty> = [
      .layoutName,
      .panelName,
      .panelDescription,
    ]

    for field in panelControls {
      
      let fieldView = NSView()
      fieldView.translatesAutoresizingMaskIntoConstraints = false
//      fieldView.backgroundColor = NSColor.orange.cgColor
      
      panelStack.addArrangedSubview(fieldView)
      
      constraints.append(fieldView.leadingAnchor.constraint(equalTo: panelStack.leadingAnchor))
      constraints.append(fieldView.trailingAnchor.constraint(equalTo: panelStack.trailingAnchor))
      
      field.label.translatesAutoresizingMaskIntoConstraints = false
      field.label.fontSize = labelFontSize
      field.label.alignment = .right
      
      fieldView.addSubview(field.label)
      
      field.control.translatesAutoresizingMaskIntoConstraints = false
      field.control.fontSize = textFontSize
      field.control.tag = field.property.rawValue
      
      fieldView.addSubview(field.control)
      
      constraints.append(field.label.centerYAnchor.constraint(equalTo: field.control.centerYAnchor))
      constraints.append(field.control.topAnchor.constraint(equalTo: fieldView.topAnchor))
      constraints.append(field.label.leadingAnchor.constraint(equalTo: fieldView.leadingAnchor))
      constraints.append(field.control.leadingAnchor.constraint(equalToSystemSpacingAfter: field.label.trailingAnchor, multiplier: 1.0))
      constraints.append(fieldView.trailingAnchor.constraint(equalTo: panelStack.trailingAnchor))
      constraints.append(fieldView.heightAnchor.constraint(equalTo: field.control.heightAnchor))
      
      if longFields.contains(field.property) {
        constraints.append(fieldView.trailingAnchor.constraint(equalTo: field.control.trailingAnchor))
      }
      
    }
    
    constraints.append(panelControls[0].control.widthAnchor.constraint(equalToConstant: 100))
    constraints.append(panelControls[2].control.widthAnchor.constraint(equalToConstant: 100))
    constraints.append(panelControls[5].control.widthAnchor.constraint(equalToConstant: 50))
    constraints.append(panelControls[6].control.widthAnchor.constraint(equalToConstant: 50))

    for field in panelControls {
      for other in panelControls {
        if !(field.control === other.control) {
          constraints.append(field.label.widthAnchor.constraint(greaterThanOrEqualTo: other.label.widthAnchor))
        }
      }
    }
    
    panelStripView.backgroundColor = NSColor.white.cgColor

    constraints.append(panelStripView.topAnchor.constraint(equalTo: panelView.topAnchor))
    constraints.append(panelStripView.leadingAnchor.constraint(equalTo: layoutView.leadingAnchor))
    constraints.append(panelStripView.trailingAnchor.constraint(equalTo: layoutView.trailingAnchor))
    constraints.append(panelStripView.heightAnchor.constraint(equalToConstant: 20.0))
    
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
    
    constraints.append(inspectorView.trailingAnchor.constraint(equalTo: splitView.trailingAnchor))

    inspectorStripView.translatesAutoresizingMaskIntoConstraints = false
    
    inspectorView.addSubview(inspectorStripView)
    
//    inspectorView.backgroundColor = NSColor.yellow.cgColor

 //   inspectorStripView.backgroundColor = NSColor.white.cgColor

    constraints.append(inspectorStripView.topAnchor.constraint(equalTo: inspectorView.topAnchor))
    constraints.append(inspectorStripView.centerXAnchor.constraint(equalTo: inspectorView.centerXAnchor))
    constraints.append(inspectorStripView.heightAnchor.constraint(equalToConstant: 20.0))

    lastButton = nil
    index = 0
    for button in inspectorButtons {
      if let button {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isBordered = false
        button.tag = index
        button.target = self
        button.action = #selector(btnInspectorAction(_:))
        let scrollView = NSScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.drawsBackground = false
        scrollView.contentView = FlippedNSClipView()
        scrollView.contentView.drawsBackground = false
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true
         inspectorViews.append(scrollView)
        inspectorView.addSubview(scrollView)

        let view = NSStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = nil
        //view.backgroundColor = NSColor.green.cgColor
        
        scrollView.documentView = view
        
        constraints.append(scrollView.topAnchor.constraint(equalToSystemSpacingBelow: inspectorStripView.bottomAnchor, multiplier: 1.0))
        constraints.append(scrollView.trailingAnchor.constraint(equalTo: inspectorView.trailingAnchor))
        constraints.append(scrollView.leadingAnchor.constraint(equalTo: inspectorView.leadingAnchor))
        constraints.append(scrollView.bottomAnchor.constraint(equalTo: inspectorView.bottomAnchor))
        constraints.append(view.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -10))
        
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

    // MARK: Attributes Inspector
    
    let attributeStack = (inspectorViews[2] as! NSScrollView).documentView as! NSStackView
    attributeStack.backgroundColor = NSColor.clear.cgColor
    attributeStack.orientation = .vertical
    attributeStack.spacing = 4
    attributeStack.alignment = .right
    
    var attributeIndex = 0
    while attributeIndex < attributeControls.count {
      var showHeader = true
      var showSeparator = false
      let groupField = attributeControls[attributeIndex]
      while attributeIndex < attributeControls.count && groupField.group == attributeControls[attributeIndex].group {
        let isApplicable = true
        if isApplicable {
          if showHeader {
            let labelView = NSView()
            labelView.translatesAutoresizingMaskIntoConstraints = false
            let label = NSTextField(labelWithString: groupField.group)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = NSFont.systemFont(ofSize: 12, weight: .bold)
            label.textColor = NSColor.systemGray
            label.alignment = .left
            label.stringValue = groupField.group
            attributeStack.addArrangedSubview(labelView)
            labelView.addSubview(label)
      //      labelView.backgroundColor = NSColor.black.cgColor
            constraints.append(label.leadingAnchor.constraint(equalTo: labelView.leadingAnchor))
            constraints.append(labelView.heightAnchor.constraint(equalTo: label.heightAnchor))
            showHeader = false
          }
          
          let fieldView = NSView()
 //         fieldView.backgroundColor = NSColor.systemPink.cgColor
          
          fieldView.translatesAutoresizingMaskIntoConstraints = false
          attributeStack.addArrangedSubview(fieldView)
          
          let field = attributeControls[attributeIndex]
          field.label.translatesAutoresizingMaskIntoConstraints = false
          field.label.fontSize = labelFontSize
          field.label.alignment = .right

          fieldView.addSubview(field.label)
          
          field.control.translatesAutoresizingMaskIntoConstraints = false
          field.control.fontSize = textFontSize
          
          fieldView.addSubview(field.control)
   
          /// Note to self: Views within a StackView must not have constraints to the outside world as this will lock the StackView size.
          /// They must only have internal constraints to the view that is added to the StackView.
          ///
          constraints.append(fieldView.heightAnchor.constraint(equalTo: field.control.heightAnchor))
          constraints.append(field.label.leadingAnchor.constraint(equalTo: fieldView.leadingAnchor, constant: 20))
          constraints.append(field.control.leadingAnchor.constraint(equalToSystemSpacingAfter: field.label.trailingAnchor, multiplier: 1.0))
          constraints.append(field.control.trailingAnchor.constraint(equalTo: fieldView.trailingAnchor))
          constraints.append(field.control.widthAnchor.constraint(greaterThanOrEqualToConstant: 100))
          constraints.append(field.control.centerYAnchor.constraint(equalTo: fieldView.centerYAnchor))
          constraints.append(field.label.centerYAnchor.constraint(equalTo: fieldView.centerYAnchor))
    
          showSeparator = true
        
        }
        attributeIndex += 1
      }
      if showSeparator {
        let separator = SeparatorView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        attributeStack.addArrangedSubview(separator)
        constraints.append(separator.heightAnchor.constraint(equalToConstant: 20))
        constraints.append(attributeStack.trailingAnchor.constraint(greaterThanOrEqualTo: separator.trailingAnchor))
        constraints.append(separator.widthAnchor.constraint(equalTo: attributeStack.widthAnchor))
      }
    }
    
    for field1 in attributeControls {
      let applicable = true
      if applicable {
        for field2 in attributeControls {
          let applicable = true
          if applicable && !(field1.label === field2.label) {
            constraints.append(field1.label.widthAnchor.constraint(greaterThanOrEqualTo: field2.label.widthAnchor))
          }
        }
      }
    }

    
    arrangeView.translatesAutoresizingMaskIntoConstraints = false
    arrangeStripView.translatesAutoresizingMaskIntoConstraints = false

//    arrangeView.wantsLayer = true
//    arrangeView.layer?.backgroundColor = NSColor.orange.cgColor
//    arrangeStripView.wantsLayer = true
//    arrangeStripView.layer?.backgroundColor = NSColor.white.cgColor

    paletteView.addSubview(arrangeView)
    
    constraints.append(arrangeView.topAnchor.constraint(equalTo: paletteView.topAnchor))
    constraints.append(arrangeView.centerXAnchor.constraint(equalTo: paletteView.centerXAnchor))
    constraints.append(arrangeView.leadingAnchor.constraint(equalTo: paletteView.leadingAnchor))
    constraints.append(paletteView.trailingAnchor.constraint(greaterThanOrEqualTo: arrangeView.trailingAnchor))
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

    cboPalette.translatesAutoresizingMaskIntoConstraints = false
    
    SwitchboardItemPalette.populate(comboBox: cboPalette, country: layout.countryCode)
    
    arrangeView.addSubview(cboPalette)
    
    constraints.append(cboPalette.topAnchor.constraint(equalToSystemSpacingBelow: arrangeStripView.bottomAnchor, multiplier: 1.0))
    constraints.append(cboPalette.centerXAnchor.constraint(equalTo: arrangeStripView.centerXAnchor))
    constraints.append(arrangeView.trailingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: cboPalette.trailingAnchor, multiplier: 1.0))
    constraints.append(arrangeView.bottomAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: cboPalette.bottomAnchor, multiplier: 1.0))
    
    SwitchboardItemPalette.select(comboBox: cboPalette, value: currentPalette)
    
    for palette in SwitchboardItemPalette.availablePalettes(country: layout.countryCode) {
      let view = NSView()
      view.translatesAutoresizingMaskIntoConstraints = false
      constraints.append(contentsOf: SwitchboardItemPalette.populate(paletteView: view, palette: palette, target: nil, action: nil))
      paletteViews[palette] = view
      arrangeView.addSubview(view)
      constraints.append(view.topAnchor.constraint(equalTo: cboPalette.bottomAnchor))
      constraints.append(view.centerXAnchor.constraint(equalTo: arrangeView.centerXAnchor))
      constraints.append(arrangeView.bottomAnchor.constraint(greaterThanOrEqualTo: view.bottomAnchor))
    }
    
    groupView.translatesAutoresizingMaskIntoConstraints = false
    groupStripView.translatesAutoresizingMaskIntoConstraints = false

//    groupView.wantsLayer = true
//    groupView.layer?.backgroundColor = NSColor.systemPink.cgColor
//    groupStripView.wantsLayer = true
//    groupStripView.layer?.backgroundColor = NSColor.white.cgColor

    paletteView.addSubview(groupView)
    
    constraints.append(groupView.topAnchor.constraint(equalTo: paletteView.topAnchor))
    constraints.append(groupView.centerXAnchor.constraint(equalTo: paletteView.centerXAnchor))
    constraints.append(paletteView.bottomAnchor.constraint(greaterThanOrEqualTo: groupView.bottomAnchor))
    constraints.append(paletteView.widthAnchor.constraint(greaterThanOrEqualTo: groupView.widthAnchor))
    
    groupView.addSubview(groupStripView)
    
    constraints.append(groupStripView.topAnchor.constraint(equalTo: groupView.topAnchor))
    constraints.append(groupStripView.centerXAnchor.constraint(equalTo: groupView.centerXAnchor))
    constraints.append(groupStripView.heightAnchor.constraint(equalToConstant: 20.0))
    constraints.append(groupView.bottomAnchor.constraint(greaterThanOrEqualTo: groupStripView.bottomAnchor))

    lastButton = nil
    index = 0
    for button in groupButtons {
      if let button {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isBordered = false
        button.tag = index
        button.target = self
        button.action = #selector(btnGroupAction(_:))
        index += 1
        groupStripView.addSubview(button)
        constraints.append(button.centerYAnchor.constraint(equalTo: groupStripView.centerYAnchor))
        if let lastButton {
          constraints.append(button.leadingAnchor.constraint(equalToSystemSpacingAfter: lastButton.trailingAnchor, multiplier: 1.0))
        }
        else {
          constraints.append(button.leadingAnchor.constraint(equalToSystemSpacingAfter: groupStripView.leadingAnchor, multiplier: 1.0))
        }
      }
      lastButton = button
    }
    constraints.append(groupStripView.trailingAnchor.constraint(equalToSystemSpacingAfter: lastButton!.trailingAnchor, multiplier: 1.0))
    constraints.append(groupView.widthAnchor.constraint(greaterThanOrEqualTo: groupStripView.widthAnchor))

    NSLayoutConstraint.activate(constraints)
    
    arrangeView.isHidden = true

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

    self.cboPalette?.target = self
    self.cboPalette?.action = #selector(self.cboPaletteAction(_:))
    cboPaletteAction(cboPalette)

    setStates()
    
  }
  
  // MARK: Private Properties
  
  private var constraints : [NSLayoutConstraint] = []
  
  private var showPanelConstraint : NSLayoutConstraint?
  
  private var panels : [SwitchboardPanelNode] = []
  
  private var switchboardMagnification : CGFloat {
    get {
      return userSettings?.cgFloat(forKey: DEFAULT.MAGNIFICATION) ?? 1.0
    }
    set(value) {
      userSettings?.set(value, forKey: DEFAULT.MAGNIFICATION)
    }
  }
  
  private weak var currentSwitchboardItem : SwitchboardItemNode?

  // MARK: Public Properties
  
  public weak var switchboardPanel : SwitchboardPanelNode? {
    didSet {
      userSettings?.node = switchboardPanel
      switchboardView.switchboardPanel = switchboardPanel
      setStates()
    }
  }
  
  // MARK: Private Methods
  
  private func setStates() {
    
    guard let btnShowPanelView, let btnShowPaletteView, let btnShowInspectorView, let cboPalette else {
      return
    }
    
    btnShowPanelView.state = userSettings!.state(forKey: DEFAULT.SHOW_PANEL_VIEW)
    btnShowPaletteView.state = userSettings!.state(forKey: DEFAULT.SHOW_PALETTE_VIEW)
    btnShowInspectorView.state = userSettings!.state(forKey: DEFAULT.SHOW_INSPECTOR_VIEW)

    btnShowPanelViewAction(btnShowPanelView)
    btnShowPaletteViewAction(btnShowPaletteView)
    btnShowInspectorViewAction(btnShowInspectorView)
    
    btnInspectorAction(inspectorButtons[userSettings!.integer(forKey: DEFAULT.CURRENT_INSPECTOR)]!)
    
    arrangeView?.isHidden = isGroupMode
    groupView?.isHidden = !isGroupMode
    
    SwitchboardItemPalette.select(comboBox: cboPalette, value: currentPalette)
    
    cboPaletteAction(cboPalette)

    scrollView.magnification = switchboardMagnification
    
    for field in panelControls {
      switch field.property {
      case .layoutId:
        field.control.stringValue = appNode?.layout?.nodeId.toHexDotFormat(numberOfBytes: 6) ?? ""
      case .layoutName:
        field.control.stringValue = appNode?.layout?.userNodeName ?? ""
      case .panelId:
        field.control.stringValue = switchboardPanel?.nodeId.toHexDotFormat(numberOfBytes: 6) ?? ""
      case .panelName:
        field.control.stringValue = switchboardPanel?.userNodeName ?? ""
      case .panelDescription:
        field.control.stringValue = switchboardPanel?.userNodeDescription ?? ""
      case .numberOfRows:
        field.control.integerValue = Int(switchboardPanel?.numberOfRows ?? 30)
      case .numberOfColumns:
        field.control.integerValue = Int(switchboardPanel?.numberOfColumns ?? 30)
      }
    }
        
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
  
  private var panelControls : [(label:NSTextField, control:NSControl, property:PanelProperty)] = []
  
  private var attributeControls : [(group:String, label:NSTextField, control:NSControl, property:AttributeProperty)] = []
  
  private var panelStack : NSStackView? = NSStackView()
  
  private var btnShowInspectorView : NSButton?
  
  private var inspectorStripView : NSView? = NSView()
  
  private var inspectorButtons : [NSButton?] = []
  
  private var inspectorViews : [NSView] = []
  
  private var arrangeView : NSView? = NSView()
  
  private var arrangeStripView : NSView? = NSView()
  
  private var arrangeButtons : [NSButton?] = []
  
  private var cboPalette : MyComboBox? = MyComboBox()
  
  @objc func cboPaletteAction(_ sender: NSComboBox) {
    currentPalette = SwitchboardItemPalette.selected(comboBox: sender)
  }
  
  private var paletteViews : [SwitchboardItemPalette:NSView] = [:]
  
  private var groupView : NSView? = NSView()
  
  private var groupStripView : NSView? = NSView()
  
  private var groupButtons : [NSButton?] = []
  
  private var currentInspectorIndex = 0
  
  private var layoutStripView : NSView? = NSView()
  
  private var layoutButtons : [NSButton?] = []

  private var btnShowPaletteView : NSButton?
  
  private var btnShowPanelView : NSButton?
  
  private var isGroupMode : Bool {
    get {
      return userSettings!.bool(forKey: DEFAULT.IS_GROUP_MODE)
    }
    set(value) {
      userSettings?.set(value, forKey: DEFAULT.IS_GROUP_MODE)
      arrangeView?.isHidden = value
      groupView?.isHidden = !value
      switchboardView.mode = isGroupMode ? .group : .arrange
    }
  }
  
  private var currentPalette : SwitchboardItemPalette {
    get {
      guard let palette = SwitchboardItemPalette(rawValue: userSettings!.integer(forKey: DEFAULT.CURRENT_PALETTE)) else {
        return SwitchboardItemPalette.defaultValue
      }
      return palette
    }
    set(value) {
      for (_, view) in paletteViews {
        view.isHidden = true
      }
      userSettings?.set(value.rawValue, forKey: DEFAULT.CURRENT_PALETTE)
      paletteViews[value]?.isHidden = false
    }
  }
  
  @IBAction func btnShowPanelViewAction(_ sender: NSButton) {
    showPanelConstraint?.isActive = false
    if sender.state == .on {
      showPanelConstraint = panelView?.bottomAnchor.constraint(equalTo: panelStripView!.bottomAnchor)
      btnShowPanelView?.contentTintColor = nil
      btnShowPanelView?.toolTip = String(localized: "Show the Panel Configuration Area")
      panelStack?.isHidden = true
    }
    else {
      showPanelConstraint = panelView?.bottomAnchor.constraint(equalTo: panelStack!.bottomAnchor)
      btnShowPanelView?.contentTintColor = NSColor.systemBlue
      btnShowPanelView?.toolTip = String(localized: "Hide the Panel Configuration Area")
      panelStack?.isHidden = false
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
    guard let button = ArrangeButton(rawValue: sender.tag) else {
      return
    }
    switch button {
    case .addItemToPanel:
      break
    case .removeItemFromPanel:
      break
    case .rotateCounterClockwise:
      break
    case .rotateClockwise:
      break
    case .switchToGroupingMode:
      isGroupMode = true
    }
  }
  
  @IBAction func btnGroupAction(_ sender: NSButton) {
    guard let button = GroupButton(rawValue: sender.tag) else {
      return
    }
    switch button {
    case .addItemToGroup:
      break
    case .removeItemFromGroup:
      break
    case .switchToArrangeMode:
      isGroupMode = false
    }
  }
  
  @IBAction func btnLayoutAction(_ sender: NSButton) {
    guard let button = LayoutButton(rawValue: sender.tag) else {
      return
    }
    switch button {
    case .zoomIn:
      switchboardMagnification += 0.1
      scrollView.magnification = switchboardMagnification
    case .zoomOut:
      switchboardMagnification -= 0.1
      scrollView.magnification = switchboardMagnification
    case .fitToSize:
      
      scrollView.magnification = 1.0

      let sWidth = scrollView.frame.width
      let sHeight = scrollView.frame.height
      let gWidth = switchboardView.bounds.width
      let gHeight = switchboardView.bounds.height

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
  }
  
  @IBOutlet weak var scrollView: NSScrollView!
  
  @IBOutlet weak var switchboardView: SwitchboardEditorView!
  
  // MARK: SwitchboardEditorViewDelegate Methods
  
  @objc func selectedItemChanged(_ switchboardEditorView:SwitchboardEditorView, switchboardItem:SwitchboardItemNode?) {
    
  }

}
