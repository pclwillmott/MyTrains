//
//  SwitchboardEditorVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 13/04/2024.
//

import Foundation
import AppKit

class LayoutBuilderVC: MyTrainsViewController, SwitchboardEditorViewDelegate, NSTextFieldDelegate, NSControlTextEditingDelegate {
  
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
    viewType = .layoutBuilder
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
  
  override func viewDidDisappear() {
    appDelegate.rebootRequest()
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
    ]
    
    inspectorButtons[InspectorButton.showInformationInspector.rawValue]?.toolTip = String(localized: "Show Identity Inspector")
    inspectorButtons[InspectorButton.showQuickHelpInspector.rawValue]?.toolTip = String(localized: "Show Quick Help Inspector")
    inspectorButtons[InspectorButton.showAttributesInspector.rawValue]?.toolTip = String(localized: "Show Attributes Inspector")
    inspectorButtons[InspectorButton.showEventsInspector.rawValue]?.toolTip = String(localized: "Show Events Inspector")
    inspectorButtons[InspectorButton.showSpeedConstraintsInspector.rawValue]?.toolTip = String(localized: "Show Speed Constraints Inspector")

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
    
    for field in panelControls {
      if let textField = field.control as? NSTextField {
        textField.tag = field.property.rawValue
        textField.delegate = self
      }
      
    }
    
    inspectorFields = LayoutInspectorProperty.inspectorPropertyFields
    
    for temp in inspectorFields {
      if let comboBox = temp.control as? MyComboBox {
        comboBox.target = self
        comboBox.action = #selector(self.cboAction(_:))
      }
      else if let chkBox = temp.control as? NSButton {
        chkBox.target = self
        chkBox.action = #selector(self.chkAction(_:))
      }
      else if let field = temp.control as? NSTextField {
        field.delegate = self
      }
    }
    
    inspectorGroupFields = LayoutInspectorGroup.inspectorGroupFields
    
    inspectorGroupSeparators = LayoutInspectorGroup.inspectorGroupSeparators
    
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
    constraints.append(view.trailingAnchor.constraint(equalToSystemSpacingAfter: splitView.trailingAnchor, multiplier: 1.0))
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
        let noSelection = NSTextField(labelWithString: String(localized: "No Selection"))
        noSelection.textColor = NSColor.gray
        noSelection.fontSize = 16.0
        inspectorNoSelection.append(noSelection)
        let notApplicable = NSTextField(labelWithString: String(localized: "Not Applicable"))
        notApplicable.textColor = NSColor.gray
        notApplicable.fontSize = 16.0
        inspectorNotApplicable.append(notApplicable)
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
        constraints.append(view.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: 0))
        
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
      /// Palette Buttons are created here!
      constraints.append(contentsOf: SwitchboardItemPalette.populate(paletteView: view, palette: palette, target: self, action: #selector(btnPartType(_:))))
      
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
    
    cboGroup?.translatesAutoresizingMaskIntoConstraints = false
    cboGroup?.target = self
    cboGroup?.action = #selector(cboGroupAction(_:))
    
    groupView.addSubview(cboGroup!)
    
    constraints.append(cboGroup!.topAnchor.constraint(equalToSystemSpacingBelow: groupStripView.bottomAnchor, multiplier: 1.0))
    constraints.append(groupView.bottomAnchor.constraint(greaterThanOrEqualTo: cboGroup!.bottomAnchor))
    constraints.append(cboGroup!.leadingAnchor.constraint(equalTo: groupView.leadingAnchor))
    constraints.append(cboGroup!.trailingAnchor.constraint(equalTo: groupView.trailingAnchor))

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
    
    if let quickHelpView, let lblQuickHelp, let lblQuickHelpSummary, let lblQuickHelpSummaryText, let lblQuickHelpDiscussion, let lblQuickHelpDiscussionText, let sepQuickHelpSummary {
      
      var constraints : [NSLayoutConstraint] = []
      
      quickHelpView.translatesAutoresizingMaskIntoConstraints = false
      lblQuickHelp.translatesAutoresizingMaskIntoConstraints = false
      lblQuickHelpSummary.translatesAutoresizingMaskIntoConstraints = false
      lblQuickHelpSummaryText.translatesAutoresizingMaskIntoConstraints = false
      lblQuickHelpDiscussion.translatesAutoresizingMaskIntoConstraints = false
      lblQuickHelpDiscussionText.translatesAutoresizingMaskIntoConstraints = false
      sepQuickHelpSummary.translatesAutoresizingMaskIntoConstraints = false
      
      lblQuickHelp.stringValue = String(localized: "Quick Help")
      lblQuickHelp.font = NSFont.systemFont(ofSize: 12, weight: .bold)
      lblQuickHelp.textColor = NSColor.systemGray
      lblQuickHelp.alignment = .left
      quickHelpView.addSubview(lblQuickHelp)
      
      lblQuickHelpSummary.stringValue = String(localized: "Summary")
      lblQuickHelpSummary.font = NSFont.systemFont(ofSize: 12, weight: .bold)
      lblQuickHelpSummary.alignment = .left
      quickHelpView.addSubview(lblQuickHelpSummary)
            
      lblQuickHelpSummaryText.font = NSFont.systemFont(ofSize: 10, weight: .regular)
      lblQuickHelpSummaryText.alignment = .left
      lblQuickHelpSummaryText.lineBreakMode = .byWordWrapping
      lblQuickHelpSummaryText.maximumNumberOfLines = 0
      lblQuickHelpSummaryText.preferredMaxLayoutWidth = 250
      quickHelpView.addSubview(lblQuickHelpSummaryText)

      quickHelpView.addSubview(sepQuickHelpSummary)
      
      lblQuickHelpDiscussion.stringValue = String(localized: "Discussion")
      lblQuickHelpDiscussion.font = NSFont.systemFont(ofSize: 12, weight: .bold)
      lblQuickHelpDiscussion.alignment = .left
      quickHelpView.addSubview(lblQuickHelpDiscussion)

      lblQuickHelpDiscussionText.font = NSFont.systemFont(ofSize: 10, weight: .regular)
      lblQuickHelpDiscussionText.alignment = .left
      lblQuickHelpDiscussionText.lineBreakMode = .byWordWrapping
      lblQuickHelpDiscussionText.maximumNumberOfLines = 0
      lblQuickHelpDiscussionText.preferredMaxLayoutWidth = 250
      quickHelpView.addSubview(lblQuickHelpDiscussionText)

      NSLayoutConstraint.activate(constraints)

    }

    updatePanelComboBox()
    
    userSettings?.node = switchboardPanel
    self.cboPanel?.target = self
    self.cboPanel?.action = #selector(self.cboPanelAction(_:))

    self.cboPalette?.target = self
    self.cboPalette?.action = #selector(self.cboPaletteAction(_:))
    cboPaletteAction(cboPalette)

    if cboPanel.indexOfSelectedItem == -1, cboPanel.numberOfItems > 0 {
      cboPanel.selectItem(at: 0)
    }

    setStates()
    
    displayInspector()
 
    
  }
  
  // MARK: Private Properties
  
  private var constraints : [NSLayoutConstraint] = []
  
  private var inspectorConstraints : [NSLayoutConstraint] = []
  
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
  
  private func updatePanelComboBox() {
  
    if let appNode, let cboPanel {
      
      cboPanel.target = nil
      
      panels.removeAll()
      for (_, item) in appNode.panelList {
        panels.append(item)
      }
      panels.sort {$0.userNodeName.sortValue < $1.userNodeName.sortValue}
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
      
      cboPanel.target = self
      
    }

  }
  
  private func setStates() {
    
    guard let appNode, let btnShowPanelView, let btnShowPaletteView, let btnShowInspectorView, let cboPalette else {
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
    switchboardView.mode = isGroupMode ? .group : .arrange
    
    SwitchboardItemPalette.select(comboBox: cboPalette, value: currentPalette)
    
    cboPaletteAction(cboPalette)

    scrollView.magnification = switchboardMagnification
    
    for field in panelControls {
      switch field.property {
      case .layoutId:
        field.control.stringValue = appNode.layout?.nodeId.toHexDotFormat(numberOfBytes: 6) ?? ""
      case .layoutName:
        field.control.stringValue = appNode.layout?.userNodeName ?? ""
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
    
    appNode.populateGroup(comboBox: cboGroup!, panelId: switchboardPanel?.nodeId ?? 0)
    cboGroupAction(cboGroup!)
    
    switchboardView.needsDisplay = true

  }
  
  private func displayInspector() {
    
    NSLayoutConstraint.deactivate(inspectorConstraints)
    inspectorConstraints.removeAll()
    
    var fieldCount = [Int](repeating: 0, count: inspectorViews.count)
    
    for index in 0 ... inspectorViews.count - 1 {
      
      let stackView = (inspectorViews[index] as! NSScrollView).documentView as! NSStackView
      stackView.backgroundColor = NSColor.clear.cgColor
      stackView.orientation = .vertical
      stackView.spacing = 4
      stackView.subviews.removeAll()
      
      if switchboardView.selectedItems.isEmpty {
        
        if index == 1 {
          
          stackView.alignment = .left
          stackView.addArrangedSubview(quickHelpView!)
          
          lblQuickHelpSummaryText?.stringValue = String(localized: "A layout is defined by one or more switchboard panels. A small layout may only require a single panel. Larger layouts will require more than one panel. A panel may be viewed as a single signal box, interlocking tower, or signal cabin. All the items relating to the operation of that box, tower, or cabin are defined on the panel. Where a track exits the operational area of a panel it moves to the operational area of another panel. The Layout Builder is used to configure switchboard panels.")
          
          lblQuickHelpDiscussionText?.stringValue = String(localized: "Layout Builder is divided into 4 sections. The central top section is the panel upon which you will add switchboard items. Below the panel are 3 disclosure buttons which will hide and show the other operational sections of Layout Builder. Screen space may be limited so these buttons allow you to hide those sections that you don't currently need.\n\nAt the bottom of Layout Builder is the panel configuration section. Here you can give the panel a user defined name and description and set the grid size.\n\nOn the leading (right hand) side of Layout Builder are the controls to create, delete, arrange, and group items on a panel. This section operates in 2 mutually exclusive modes - \"Arrange Mode\" and \"Grouping Mode\". Buttons are provided to switch between the 2 modes.\n\nArrange Mode\n\nThe various switchboard items are grouped into palettes by functional type. The required palette is selected from the dropdown list. To place an item on the panel press the item button in the palette. The button will be outlined in red. Now click on the grid square on the panel where you want to place the item. The selected grid square will be outlined in blue. Now press the \"Add Item to Panel\" button. To remove an item from a panel select it by clicking on the item in the panel and then press the \"Remove Item from Panel\" button. You will be asked to confirm that you really want to delete the item (and all of its configuration information such as event ids). You can select multiple items on a panel using the shift modifier key when clicking on an item. Buttons are provided to rotate the selected items. Some of the items in the palettes (e.g. signals) are specific to the country specified in the layout configuration.\n\nGrouping Mode\n\nGrouping mode is used to create blocks of track or groups. A group is controlled by a block item or a turnout/crossing item. A group may only have one controlling item. The controlling item defines the properties of the block of track, such as its route lengths, event ids, speed constraints etc. All switchboard items, with the exception of certain purely scenic items such as platforms, must belong to a group. To select a group for editing choose the required group from the drop down list. Groups are named after their controlling block or turnot/crossing. Alternatively you can select a given item's current group by clicking on the item on the panel while pressing the ⌘ modifier key. The members of the current group will be displayed with an orange background. Items that have been added to a group but are not members of the selected group will be displayed with a dark grey background. Items will no group set will be displayed with a black background. To add an item or items to a group select the item or items in the same way as in arrange mode and then press the \"Add Item to Group\" button. To remove an item or items from a group, select the item or items and press the \"Remove Item from Group\" button. Removing an item from a group only removes it from the group, nothing is deleted and you are free to add it to another group.\n\nOn the trailing (right hand) side of Layout Builder is the inspector area. There are 5 inspectors each of which is selected by pressing the appropriate button at the top of the inspector area. Inspectors allow you to view and edit the properties of one or more switchboard items. The inspectors display the common properties of the currently selected items.\n\nIdentity Inspector\n\nThis inspector displays the id and type of the item and information about the panel it belongs to.\n\nQuick Help Inspector\n\nIf you are reading this then you have already found this inspector. Selecting a single item on the panel will give context help about the item and how to configure it. Quick help does not work with multiple item selections. If you click on an unpopulated grid square you will see this Layout Builder quick help page.\n\nAttributes Inspector\n\nThis inspector allows you to edit the properties of the selected items. Only those properties that all the selected items have in common are displayed. A blank or unselected field indicates that not all selected items have the same value for that property.\n\nEvents Inspector\n\nThis inspector is used to edit the events applicable to the item. The \"New\" button may be used to get a new event id from the application's pool of event ids. The copy and paste buttons are provided as a convenience for copying event ids to and/or from a configuration tool or another Layout Builder instance\n\nSpeed Constraints Inspector\n\nThe speed limits applicable for the item can be set by using the \"Speed Constraints Inspector\". Any speed constraints set for an item will override any speed constraints set in the layout properties. You can set your preferred units of speed in the application preferences. Different speed constarints can be set for \"Direction Next\" and \"Direction Previous\".")
          
          inspectorConstraints.append(lblQuickHelp!.topAnchor.constraint(equalToSystemSpacingBelow: quickHelpView!.topAnchor, multiplier: 1.0))
          inspectorConstraints.append(lblQuickHelp!.leadingAnchor.constraint(equalToSystemSpacingAfter: quickHelpView!.leadingAnchor, multiplier: 1.0))
          
          inspectorConstraints.append(lblQuickHelpSummary!.topAnchor.constraint(equalToSystemSpacingBelow: lblQuickHelp!.bottomAnchor, multiplier: 2.0))
          inspectorConstraints.append(lblQuickHelpSummary!.leadingAnchor.constraint(equalToSystemSpacingAfter: quickHelpView!.leadingAnchor, multiplier: 1.0))
          inspectorConstraints.append(lblQuickHelpSummaryText!.topAnchor.constraint(equalToSystemSpacingBelow: lblQuickHelpSummary!.bottomAnchor, multiplier: 2.0))
          inspectorConstraints.append(lblQuickHelpSummaryText!.leadingAnchor.constraint(equalToSystemSpacingAfter: quickHelpView!.leadingAnchor, multiplier: 1.0))
          inspectorConstraints.append(lblQuickHelpSummaryText!.trailingAnchor.constraint(equalTo: quickHelpView!.trailingAnchor))
          
          
          inspectorConstraints.append(sepQuickHelpSummary!.topAnchor.constraint(equalToSystemSpacingBelow: lblQuickHelpSummaryText!.bottomAnchor, multiplier: 1.0))
          inspectorConstraints.append(sepQuickHelpSummary!.leadingAnchor.constraint(equalTo: lblQuickHelp!.leadingAnchor))
          inspectorConstraints.append(sepQuickHelpSummary!.trailingAnchor.constraint(equalTo: quickHelpView!.trailingAnchor))
          lblQuickHelpSummaryText!.setContentHuggingPriority(NSLayoutConstraint.Priority(rawValue: 1), for: .horizontal)
          
          inspectorConstraints.append(lblQuickHelpDiscussion!.topAnchor.constraint(equalToSystemSpacingBelow: sepQuickHelpSummary!.bottomAnchor, multiplier: 1.0))
          inspectorConstraints.append(lblQuickHelpDiscussion!.leadingAnchor.constraint(equalTo: lblQuickHelpSummary!.leadingAnchor))
          
          inspectorConstraints.append(lblQuickHelpDiscussionText!.topAnchor.constraint(equalToSystemSpacingBelow: lblQuickHelpDiscussion!.bottomAnchor, multiplier: 1.0))
          inspectorConstraints.append(lblQuickHelpDiscussionText!.leadingAnchor.constraint(equalTo: lblQuickHelpSummaryText!.leadingAnchor))
          lblQuickHelpDiscussionText!.setContentHuggingPriority(NSLayoutConstraint.Priority(rawValue: 1), for: .horizontal)
          lblQuickHelpDiscussionText!.setContentHuggingPriority(NSLayoutConstraint.Priority(rawValue: 1), for: .vertical)
          inspectorConstraints.append(lblQuickHelpDiscussionText!.trailingAnchor.constraint(equalTo: quickHelpView!.trailingAnchor))
          
          inspectorConstraints.append(quickHelpView!.bottomAnchor.constraint(greaterThanOrEqualTo: lblQuickHelpDiscussionText!.bottomAnchor))
          
          NSLayoutConstraint.activate(inspectorConstraints)
          
        }
        else {
          stackView.alignment = .centerX
          stackView.addArrangedSubview(inspectorNoSelection[index])
        }
        
      }
              
    }
    
    let selectedItems = switchboardView.selectedItems
    
    if selectedItems.isEmpty {
      return
    }
    
    var commonProperties : Set<LayoutInspectorProperty>?
    
    for item in selectedItems {
      if commonProperties == nil {
        commonProperties = item.itemType.properties
      }
      else {
        commonProperties = commonProperties!.intersection(item.itemType.properties)
      }
    }
    
    var usedFields : [LayoutInspectorPropertyField] = []
    
    var index = 0
    while index < inspectorFields.count {
      
      let inspector = inspectorFields[index].property.inspector
      let stackView = (inspectorViews[inspector.rawValue] as! NSScrollView).documentView as! NSStackView
      stackView.alignment = .right

      while index < inspectorFields.count && inspectorFields[index].property.inspector == inspector {
        
        let group = inspectorFields[index].property.group
        
        var showGroupHeader = true
        var showGroupSeparator = false
        
        while index < inspectorFields.count && inspectorFields[index].property.group == group {
          
          let field = inspectorFields[index]
          
          if let commonProperties, commonProperties.contains(field.property) {
            
            fieldCount[inspector.rawValue] += 1
            
            if showGroupHeader {
              stackView.addArrangedSubview(inspectorGroupFields[group]!.view!)
              showGroupHeader = false
              showGroupSeparator = true
            }
            
            stackView.addArrangedSubview(field.view!)
            
            /// Note to self: Views within a StackView must not have constraints to the outside world as this will lock the StackView size.
            /// They must only have internal constraints to the view that is added to the StackView.
            ///  https://manasaprema04.medium.com/autolayout-fundamental-522f0a6e5790
            
            inspectorConstraints.append(field.view!.heightAnchor.constraint(greaterThanOrEqualTo: field.label!.heightAnchor))
            inspectorConstraints.append(field.view!.heightAnchor.constraint(greaterThanOrEqualTo: field.control!.heightAnchor))
            inspectorConstraints.append(field.control!.leadingAnchor.constraint(equalToSystemSpacingAfter: field.label!.trailingAnchor, multiplier: 1.0))
            inspectorConstraints.append(field.label!.leadingAnchor.constraint(equalTo: field.view!.leadingAnchor, constant: 20))
            
            if field.property.controlType == .eventId {
              
              inspectorConstraints.append(field.control!.widthAnchor.constraint(greaterThanOrEqualToConstant: 140))
              
              inspectorConstraints.append(field.new!.leadingAnchor.constraint(equalToSystemSpacingAfter: field.control!.trailingAnchor, multiplier: 1.0))
              inspectorConstraints.append(field.copy!.leadingAnchor.constraint(equalToSystemSpacingAfter: field.new!.trailingAnchor, multiplier: 1.0))
              inspectorConstraints.append(field.paste!.leadingAnchor.constraint(equalToSystemSpacingAfter: field.copy!.trailingAnchor, multiplier: 1.0))
              inspectorConstraints.append(field.view!.trailingAnchor.constraint(equalTo: field.paste!.trailingAnchor))
              
              inspectorConstraints.append(field.new!.centerYAnchor.constraint(equalTo: field.view!.centerYAnchor))
              inspectorConstraints.append(field.copy!.centerYAnchor.constraint(equalTo: field.view!.centerYAnchor))
              inspectorConstraints.append(field.paste!.centerYAnchor.constraint(equalTo: field.view!.centerYAnchor))

              inspectorConstraints.append(field.view!.heightAnchor.constraint(greaterThanOrEqualTo: field.new!.heightAnchor))
              
              field.new?.target = self
              field.new?.action = #selector(newEventIdAction(_:))
              field.copy?.target = self
              field.copy?.action = #selector(btnCopyAction(_:))
              field.paste?.target = self
              field.paste?.action = #selector(btnPasteAction(_:))

            }
            else {
              inspectorConstraints.append(field.control!.widthAnchor.constraint(greaterThanOrEqualToConstant: 100))
              inspectorConstraints.append(field.view!.trailingAnchor.constraint(equalTo: field.control!.trailingAnchor))
              
            }
            inspectorConstraints.append(field.control!.centerYAnchor.constraint(equalTo: field.view!.centerYAnchor))
            inspectorConstraints.append(field.label!.centerYAnchor.constraint(equalTo: field.view!.centerYAnchor))
            
            usedFields.append(field)
            
            setValue(field: field)
            
          }
          
          index += 1
          
        }
        
        if showGroupSeparator {
          stackView.addArrangedSubview(inspectorGroupSeparators[group]!.view!)
        }
        
      }
            
    }
    
    for field1 in usedFields {
      for field2 in usedFields {
        if !(field1.label! === field2.label) && field1.property.inspector == field2.property.inspector {
          inspectorConstraints.append(field1.label!.widthAnchor.constraint(greaterThanOrEqualTo: field2.label!.widthAnchor))
        }
      }
    }
    
    for index in 0 ... inspectorViews.count - 1 {
      
      let stackView = (inspectorViews[index] as! NSScrollView).documentView as! NSStackView
      
      if fieldCount[index] == 0, (index != 1 || selectedItems.count > 1) {
        stackView.alignment = .centerX
        stackView.addArrangedSubview(inspectorNotApplicable[index])
      }
      
      if index == 1 && selectedItems.count == 1, let item = selectedItems.first {
        stackView.alignment = .left
        stackView.addArrangedSubview(quickHelpView!)
        
        lblQuickHelpSummaryText?.stringValue = item.itemType.quickHelpSummary
        lblQuickHelpDiscussionText?.stringValue = item.itemType.quickHelpDiscussion
        
        inspectorConstraints.append(lblQuickHelp!.topAnchor.constraint(equalToSystemSpacingBelow: quickHelpView!.topAnchor, multiplier: 1.0))
        inspectorConstraints.append(lblQuickHelp!.leadingAnchor.constraint(equalToSystemSpacingAfter: quickHelpView!.leadingAnchor, multiplier: 1.0))

        inspectorConstraints.append(lblQuickHelpSummary!.topAnchor.constraint(equalToSystemSpacingBelow: lblQuickHelp!.bottomAnchor, multiplier: 2.0))
        inspectorConstraints.append(lblQuickHelpSummary!.leadingAnchor.constraint(equalToSystemSpacingAfter: quickHelpView!.leadingAnchor, multiplier: 1.0))
        inspectorConstraints.append(lblQuickHelpSummaryText!.topAnchor.constraint(equalToSystemSpacingBelow: lblQuickHelpSummary!.bottomAnchor, multiplier: 2.0))
        inspectorConstraints.append(lblQuickHelpSummaryText!.leadingAnchor.constraint(equalToSystemSpacingAfter: quickHelpView!.leadingAnchor, multiplier: 1.0))
        inspectorConstraints.append(lblQuickHelpSummaryText!.trailingAnchor.constraint(equalTo: quickHelpView!.trailingAnchor))
        

        inspectorConstraints.append(sepQuickHelpSummary!.topAnchor.constraint(equalToSystemSpacingBelow: lblQuickHelpSummaryText!.bottomAnchor, multiplier: 1.0))
        inspectorConstraints.append(sepQuickHelpSummary!.leadingAnchor.constraint(equalTo: lblQuickHelp!.leadingAnchor))
        inspectorConstraints.append(sepQuickHelpSummary!.trailingAnchor.constraint(equalTo: quickHelpView!.trailingAnchor))
        lblQuickHelpSummaryText!.setContentHuggingPriority(NSLayoutConstraint.Priority(rawValue: 1), for: .horizontal)

        inspectorConstraints.append(lblQuickHelpDiscussion!.topAnchor.constraint(equalToSystemSpacingBelow: sepQuickHelpSummary!.bottomAnchor, multiplier: 1.0))
        inspectorConstraints.append(lblQuickHelpDiscussion!.leadingAnchor.constraint(equalTo: lblQuickHelpSummary!.leadingAnchor))
        
        inspectorConstraints.append(lblQuickHelpDiscussionText!.topAnchor.constraint(equalToSystemSpacingBelow: lblQuickHelpDiscussion!.bottomAnchor, multiplier: 1.0))
        inspectorConstraints.append(lblQuickHelpDiscussionText!.leadingAnchor.constraint(equalTo: lblQuickHelpSummaryText!.leadingAnchor))
        lblQuickHelpDiscussionText!.setContentHuggingPriority(NSLayoutConstraint.Priority(rawValue: 1), for: .horizontal)
        lblQuickHelpDiscussionText!.setContentHuggingPriority(NSLayoutConstraint.Priority(rawValue: 1), for: .vertical)
        inspectorConstraints.append(lblQuickHelpDiscussionText!.trailingAnchor.constraint(equalTo: quickHelpView!.trailingAnchor))
 
        inspectorConstraints.append(quickHelpView!.bottomAnchor.constraint(greaterThanOrEqualTo: lblQuickHelpDiscussionText!.bottomAnchor))

      }
      
    }
    
    NSLayoutConstraint.activate(inspectorConstraints)

  }
  
  private func setValue(field:LayoutInspectorPropertyField) {
    
    var value : String?
    
    for item in switchboardView.selectedItems {
      let newValue = item.getValue(property: field.property)
      if value == nil {
        value = newValue
      }
      else if newValue != value {
        value = ""
        break
      }
    }
    
    if let value {
      switch field.property.controlType {
      case .textField:
        (field.control as? NSTextField)?.stringValue = value
      case .label:
        (field.control as? NSTextField)?.stringValue = value
      case .checkBox:
        (field.control as? NSButton)?.state = value == "true" ? .on : .off
      case .comboBox:
        if let comboBox = field.control as? NSComboBox {
          comboBox.deselectItem(at: comboBox.indexOfSelectedItem)
          var index = 0
          while index < comboBox.numberOfItems {
            if let title = comboBox.itemObjectValue(at: index) as? String, title == value {
              comboBox.selectItem(at: index)
              break
            }
            index += 1
          }
        }
      case .eventId:
        (field.control as? NSTextField)?.stringValue = value
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
    displayInspector()
  }
  
  private var splitView : NSSplitView? = NSSplitView()
  
  private var paletteView   : NSView? = NSView()
  private var layoutView    : NSView? = NSView()
  private var inspectorView : NSView? = NSView()
  
  private var panelView : NSView? = NSView()
  
  private var panelStripView : NSView? = NSView()
  
  private var panelControls : [(label:NSTextField, control:NSControl, property:PanelProperty)] = []
  
  private var panelStack : NSStackView? = NSStackView()
  
  private var btnShowInspectorView : NSButton?
  
  private var inspectorStripView : NSView? = NSView()
  
  private var inspectorButtons : [NSButton?] = []
  
  private var inspectorViews : [NSView] = []
  private var inspectorNoSelection : [NSTextField] = []
  private var inspectorNotApplicable : [NSTextField] = []

  private var inspectorFields : [LayoutInspectorPropertyField] = []
  
  private var inspectorGroupFields : [LayoutInspectorGroup:LayoutInspectorGroupField] = [:]
  
  private var inspectorGroupSeparators : [LayoutInspectorGroup:LayoutInspectorGroupField] = [:]
  
  private var arrangeView : NSView? = NSView()
  
  private var arrangeStripView : NSView? = NSView()
  
  private var arrangeButtons : [NSButton?] = []
  
  private var cboPalette : MyComboBox? = MyComboBox()
  
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
      guard let currentPartType else {
        return
      }
      switchboardView.addItem(partType: currentPartType)
    case .removeItemFromPanel:
      switchboardView.deleteItem()
    case .rotateCounterClockwise:
      switchboardView.rotateLeft()
    case .rotateClockwise:
      switchboardView.rotateRight()
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
      switchboardView.addToGroup()
    case .removeItemFromGroup:
      switchboardView.removeFromGroup()
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
  }
  
  @IBOutlet weak var scrollView: NSScrollView!
  
  @IBOutlet weak var switchboardView: SwitchboardEditorView!
  
  @IBAction func cboAction(_ sender: NSComboBox) {
    
    if let property = LayoutInspectorProperty(rawValue: sender.tag), sender.indexOfSelectedItem >= 0, let string = sender.itemObjectValue(at: sender.indexOfSelectedItem) as? String  {
      
      for item in switchboardView.selectedItems {
        item.setValue(property: property, string: string)
        item.saveMemorySpaces()
      }
      
      switchboardView.needsDisplay = true

    }
    
  }

  @IBAction func chkAction(_ sender: NSButton) {

    if let property = LayoutInspectorProperty(rawValue: sender.tag) {
      
      let string = sender.state == .on ? "true" : "false"
      
      for item in switchboardView.selectedItems {
        item.setValue(property: property, string: string)
        item.saveMemorySpaces()
      }
      
      switchboardView.needsDisplay = true
      
    }
    
  }
  
  // MARK: SwitchboardEditorViewDelegate Methods
  
  @objc func selectedItemChanged(_ switchboardEditorView:SwitchboardEditorView) {
    displayInspector()
  }
  
  @objc func groupChanged(_ switchboardEditorView:SwitchboardEditorView) {
    guard let cboGroup, let appNode else {
      return
    }
    appNode.selectGroup(comboBox: cboGroup, nodeId: switchboardEditorView.groupId)
  }
  
  // MARK: NSTextFieldDelegate, NSControlTextEditingDelegate Methods

  /// This is called when the user presses return.
  @objc func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
    
    var isValid = true
    
    if let textField = control as? NSTextField {
      
      let trimmed = textField.stringValue.trimmingCharacters(in: .whitespaces)
      
      if let property = LayoutInspectorProperty(rawValue: textField.tag) {
        
        isValid = property.isValid(string: trimmed)
        
        if isValid {
          for item in switchboardView.selectedItems {
            item.setValue(property: property, string: trimmed)
            item.saveMemorySpaces()
          }
        }
        
      }
      else if let property = PanelProperty(rawValue: textField.tag) {

        isValid = property.isValid(string: trimmed)

        if isValid, let switchboardPanel {
          switchboardPanel.setValue(property: property, string: trimmed)
          switchboardPanel.saveMemorySpaces()
        }
        
        displayInspector()
        
        updatePanelComboBox()
        
      }
 
      switchboardView.needsDisplay = true
      switchboardView.needsDisplay = true

    }
    
    return isValid
    
  }

  /// This is called when the user changes the text.
  @objc func controlTextDidChange(_ obj: Notification) {
    if let textField = obj.object as? NSTextField, let property = LayoutInspectorProperty(rawValue: textField.tag) {
    }
  }

  // MARK: Actions
  
  private func getTextField(button:NSButton) -> NSTextField? {
    guard let item = LayoutInspectorProperty(rawValue: button.tag) else {
      return nil
    }
    for field in inspectorFields {
      if field.property == item, let textField = field.control as? NSTextField {
        return textField
      }
    }
    return nil
  }
  
  @IBAction func btnCopyAction(_ sender: NSButton) {
    guard let textField = getTextField(button: sender), let _ = UInt64(dotHex: textField.stringValue, numberOfBytes: 8) else {
      return
    }
    let pasteboard = NSPasteboard.general
    pasteboard.declareTypes([.string], owner: nil)
    pasteboard.setString(textField.stringValue, forType: .string)
  }

  @IBAction func btnPasteAction(_ sender: NSButton) {
    guard let textField = getTextField(button: sender) else {
      return
    }
    let pasteboard = NSPasteboard.general
    let value = pasteboard.string(forType: .string) ?? ""
    if let _ = UInt64(dotHex: value, numberOfBytes: 8) {
      textField.stringValue = value
      _ = control(textField, textShouldEndEditing: NSText())
    }
  }

  @IBAction func newEventIdAction(_ sender: NSButton) {
    guard let textField = getTextField(button: sender), let appNode else {
      return
    }
    textField.stringValue = appNode.nextUniqueEventId.toHexDotFormat(numberOfBytes: 8)
    _ = control(textField, textShouldEndEditing: NSText())
  }
  
  private func resetPartButtons() {
    for (_, paletteView) in paletteViews {
      for view in paletteView.subviews {
        for control in view.subviews {
          if let button = control as? SwitchboardShapeButton {
            button.state = .off
          }
        }
      }
    }
  }
  
  private var currentPartType : SwitchboardItemType?
  
  @IBAction func btnPartType(_ sender: NSButton) {
    guard let button = sender as? SwitchboardShapeButton else {
      return
    }
    let state = button.state
    resetPartButtons()
    button.state = state
    currentPartType = state == .on ? button.partType : nil
  }
  
  @objc func cboPaletteAction(_ sender: NSComboBox) {
    let lastPalette = currentPalette
    currentPalette = SwitchboardItemPalette.selected(comboBox: sender)
    if lastPalette != currentPalette {
      resetPartButtons()
      currentPartType = nil
    }
  }
  
  private var cboGroup : MyComboBox? = MyComboBox()
  
  @objc func cboGroupAction(_ sender: NSComboBox) {
    switchboardView.groupId = appNode?.selectedGroup(comboBox: sender)?.nodeId ?? 0
  }
  
  private var lblQuickHelp : NSTextField? = NSTextField(labelWithString: "")
  private var lblQuickHelpSummary : NSTextField? = NSTextField(labelWithString: "")
  private var lblQuickHelpSummaryText : NSTextField? = NSTextField(labelWithString: "")
  private var sepQuickHelpSummary : SeparatorView? = SeparatorView()
  private var lblQuickHelpDiscussion : NSTextField? = NSTextField(labelWithString: "")
  private var lblQuickHelpDiscussionText : NSTextField? = NSTextField(labelWithString: "")
  private var quickHelpView : NSView? = NSView()

}
