//
//  ProgrammerToolVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 01/08/2023.
//

import Foundation
import AppKit

// https://github.com/JMRI/JMRI/blob/master/xml/decoders/esu/v4decoderInfoCVs.xml

class ProgrammerToolVC : MyTrainsViewController, OpenLCBProgrammerToolDelegate, MyTrainsAppDelegate, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate, DecoderDelegate {
  
  // MARK: Constructors & Destructors
  
  deinit {

    NSLayoutConstraint.deactivate(inspectorConstraints)
    inspectorConstraints.removeAll()

    NSLayoutConstraint.deactivate(settingsConstraints)
    settingsConstraints.removeAll()

    NSLayoutConstraint.deactivate(constraints)
    constraints.removeAll()
    
    inspectorFields.removeAll()
    
    selectorStackView?.subviews.removeAll()
    selectorStackView = nil
    
    pnlInspectorView.removeAll()
    
    pnlInspectorButtons?.subviews.removeAll()
    pnlInspectorButtons = nil
    
    cboProgrammingTrack?.removeAllItems()
    cboProgrammingTrack = nil
    
    for view in pnlGroups {
      view.subviews.removeAll()
    }
    pnlGroups.removeAll()
    
    btnGroups.removeAll()
    
    lblGroups.removeAll()

    pnlSettings?.subviews.removeAll()
    pnlSettings = nil
    
    for index in 0 ... pnlSettingsView.count - 1 {
      if let group = ProgrammerToolSettingsGroup(rawValue: index) {
        switch group {
        case .manualCVInput:
          break
        default:
          pnlSettingsView[index].subviews.removeAll()
        }
      }
    }
    pnlSettingsView.removeAll()
    
    tableView?.delegate = nil
    tableView = nil
    
    tableColumns.removeAll()
    
    changedCVsScrollView?.documentView = nil
    changedCVsScrollView = nil
    
    lblChangedCVs = nil
    
  }
  
  // MARK: Controls
  
  private var constraints : [NSLayoutConstraint] = []
  
  private var inspectorConstraints : [NSLayoutConstraint] = []
  
  private var cboProgrammingTrack : MyComboBox? = MyComboBox()
  
  private var pnlInspectorButtons : NSView? = NSView()
  
  private var pnlInspectorView : [ProgrammerToolInspector:NSView] = [:]

  internal var inspectorFields : [ProgrammerToolInspectorPropertyField] = []

  internal var settingsFields : [ProgrammerToolSettingsPropertyField] = []

  internal var settingsGroupFields : [ProgrammerToolSettingsSection:ProgrammerToolSettingsSectionField] = [:]
  
  internal var settingsGroupSeparators : [ProgrammerToolSettingsSection:ProgrammerToolSettingsSectionField] = [:]

  internal var settingsPropertyConstraints : [NSLayoutConstraint] = []
  
  private var lblInspectorTitles : [NSTextField] = []
  
  private var pnlGroups : [NSView] = []
  
  private var btnGroups : [NSButton] = []
  
  private var lblGroups : [NSTextField] = []
  
  private var settingsConstraints : [NSLayoutConstraint] = []
  
  private var selectorStackView : ScrollVerticalStackView? = ScrollVerticalStackView()
  
  private var pnlSettings : NSView? = NSView()
  
  private var pnlSettingsView : [NSView] = []
  
  private var tableView : NSTableView? = NSTableView()
  
  private var columnIds : [NSUserInterfaceItemIdentifier] = []
  
  private var tableColumns : [NSTableColumn?] = []
  
  private var changedCVsScrollView : NSScrollView? = NSScrollView()
  
  private var lblChangedCVs : NSTextField? = NSTextField(labelWithString: "")
  
  private var decoder : Decoder? {
    didSet {
      tableView?.reloadData()
    }
  }
  
  // MARK: Window & View Control
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewType = .programmerTool
  }
  
  override func windowWillClose(_ notification: Notification) {
    
    if let programmerTool {
      programmerTool.delegate = nil
      appDelegate.networkLayer?.releaseProgrammerTool(programmerTool: programmerTool)
      self.programmerTool = nil
    }
    
    if let observerId, let appNode {
      appNode.removeObserver(observerId: observerId)
    }
    
    super.windowWillClose(notification)
    
  }

  override func viewWillAppear() {
    
    super.viewWillAppear()
   
    guard let appNode, let cboProgrammingTrack, let pnlInspectorButtons, let selectorStackView, let pnlSettings, let tableView, let lblChangedCVs else {
      return
    }
    
    observerId = appNode.addObserver(observer: self)
    
    // Selection Section
    
    cboProgrammingTrack.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(cboProgrammingTrack)
    
    constraints.append(cboProgrammingTrack.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 1.0))
    constraints.append(cboProgrammingTrack.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1.0))
    constraints.append(view.trailingAnchor.constraint(equalToSystemSpacingAfter: cboProgrammingTrack.trailingAnchor, multiplier: 1.0))
    
    pnlInspectorButtons.translatesAutoresizingMaskIntoConstraints = false
//    pnlInspectorButtons.backgroundColor = NSColor.orange.cgColor
    
    view.addSubview(pnlInspectorButtons)
    
    // Inspector Section
    
    constraints.append(pnlInspectorButtons.topAnchor.constraint(equalToSystemSpacingBelow: cboProgrammingTrack.bottomAnchor, multiplier: 1.0))
    constraints.append(pnlInspectorButtons.centerXAnchor.constraint(equalTo: view.centerXAnchor))
    
    var lastButton : NSButton?
    
    for item in ProgrammerToolInspector.allCases {
      
      let button = item.button
      button.target = self
      button.action = #selector(btnInspectorAction(_:))
      pnlInspectorButtons.addSubview(button)
      constraints.append(button.centerYAnchor.constraint(equalTo: pnlInspectorButtons.centerYAnchor))
      if lastButton == nil {
        constraints.append(button.leadingAnchor.constraint(equalToSystemSpacingAfter: pnlInspectorButtons.leadingAnchor, multiplier: 1.0))
      }
      else {
        constraints.append(button.leadingAnchor.constraint(equalToSystemSpacingAfter: lastButton!.trailingAnchor, multiplier: 1.0))
      }
      constraints.append(button.heightAnchor.constraint(equalToConstant: 30))
      constraints.append(pnlInspectorButtons.heightAnchor.constraint(equalTo: button.heightAnchor))
      lastButton = button
      
      var inspectorPanel = NSView()
      var subView : NSView?
      
      let inspectorTitle = NSTextField(labelWithString: item.title)
      inspectorTitle.translatesAutoresizingMaskIntoConstraints = false
      inspectorTitle.fontSize = 16.0
      inspectorTitle.textColor = .gray
      
      inspectorPanel.addSubview(inspectorTitle)
      
      constraints.append(inspectorTitle.topAnchor.constraint(equalTo: inspectorPanel.topAnchor))
      constraints.append(inspectorTitle.leadingAnchor.constraint(equalTo: inspectorPanel.leadingAnchor))
      constraints.append(inspectorPanel.widthAnchor.constraint(greaterThanOrEqualTo: inspectorTitle.widthAnchor))
      
      switch item {
      case .identity, .quickHelp, .sound, .rwCVs:
        subView = ScrollVerticalStackView()
        if let stackView = subView as? ScrollVerticalStackView {
          stackView.backgroundColor = NSColor.clear.cgColor
          stackView.stackView?.orientation = .vertical
          stackView.stackView?.spacing = 8
        }
      case .changedCVs:
        
        subView = changedCVsScrollView
        
        if let scrollView = subView as? NSScrollView {
          scrollView.documentView = lblChangedCVs
          lblChangedCVs.translatesAutoresizingMaskIntoConstraints = false
          lblChangedCVs.maximumNumberOfLines = 0
          lblChangedCVs.lineBreakMode = .byWordWrapping
          lblChangedCVs.font = NSFont(name: "Menlo", size: 12)
          lblChangedCVs.stringValue = ""

          constraints.append(lblChangedCVs.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor))
          constraints.append(lblChangedCVs.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor))
          
        }
        
      case .settings:
        subView = NSSplitView()
        if let splitView = subView as? NSSplitView {
          splitView.isVertical = true
          splitView.arrangesAllSubviews = true
          selectorStackView.translatesAutoresizingMaskIntoConstraints = false
          splitView.addArrangedSubview(selectorStackView)
          pnlSettings.translatesAutoresizingMaskIntoConstraints = false
          splitView.addArrangedSubview(pnlSettings)
          userSettings?.splitView = splitView
        }
      }
      
      if let subView {
        
        inspectorPanel.translatesAutoresizingMaskIntoConstraints = false
//        inspectorPanel.backgroundColor = item.backgroundColor
        
        pnlInspectorView[item] = inspectorPanel
        
        view.addSubview(inspectorPanel)
        
        constraints.append(inspectorPanel.topAnchor.constraint(equalToSystemSpacingBelow: pnlInspectorButtons.bottomAnchor, multiplier: 1.0))
        constraints.append(inspectorPanel.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1.0))
        constraints.append(view.trailingAnchor.constraint(equalToSystemSpacingAfter: inspectorPanel.trailingAnchor, multiplier: 1.0))
        constraints.append(view.bottomAnchor.constraint(equalToSystemSpacingBelow: inspectorPanel.bottomAnchor, multiplier: 1.0))
        
        inspectorPanel.addSubview(subView)
        
        subView.translatesAutoresizingMaskIntoConstraints = false
        
        constraints.append(subView.topAnchor.constraint(equalToSystemSpacingBelow: inspectorTitle.bottomAnchor, multiplier: 2.0))
        constraints.append(subView.leadingAnchor.constraint(equalTo: inspectorPanel.leadingAnchor))
        constraints.append(subView.trailingAnchor.constraint(equalTo: inspectorPanel.trailingAnchor))
        constraints.append(subView.bottomAnchor.constraint(equalTo: inspectorPanel.bottomAnchor))
        
      }
      
    }
    
    constraints.append(pnlInspectorButtons.trailingAnchor.constraint(equalToSystemSpacingAfter: lastButton!.trailingAnchor, multiplier: 1.0))
    
    // Settings Group Selectors
    
    for group in ProgrammerToolSettingsGroup.allCases {
      
      var view = NSView()
      
      view.translatesAutoresizingMaskIntoConstraints = false
      view.backgroundColor = nil
      
      let button = group.button
      button.tag = group.rawValue
      button.target = self
      button.action = #selector(btnSelectorAction(_:))
      view.addSubview(button)
      
      btnGroups.append(button)
      
      let label = NSTextField(labelWithString: group.title)
      label.translatesAutoresizingMaskIntoConstraints = false
      label.tag = group.rawValue
      label.alignment = .center
      label.target = self
      label.action = #selector(btnSelectorAction(_:))

      view.addSubview(label)
      
      lblGroups.append(label)
      
      pnlGroups.append(view)
      
      var settingsView : NSView?
      
      switch group {
      case .manualCVInput:
        
        settingsView = NSScrollView()
        
        if let scrollView = settingsView as? NSScrollView {
          
          scrollView.documentView = tableView
          
          scrollView.translatesAutoresizingMaskIntoConstraints = false
          scrollView.backgroundColor = nil
          scrollView.drawsBackground = false
          scrollView.hasVerticalScroller = true
          scrollView.hasHorizontalScroller = true
          scrollView.autoresizesSubviews = true
          
          tableView.allowsColumnReordering = true
          tableView.selectionHighlightStyle = .none
          tableView.allowsColumnResizing = true
          tableView.usesAlternatingRowBackgroundColors = true
          
          let columnNames = [
            "CV31",
            "CV32",
            "CV",
            "Value",
            "Binary",
            "Hex"
          ]
          
          let columnTitles = [
            String(localized:"CV31"),
            String(localized:"CV32"),
            String(localized:"CV"),
            String(localized:"Value"),
            String(localized:"Binary"),
            String(localized:"Hex"),
          ]
          
          for index in 0 ... columnNames.count - 1 {
            let id = NSUserInterfaceItemIdentifier(rawValue: columnNames[index])
            columnIds.append(id)
            tableColumns.append(NSTableColumn(identifier: id))
            if let column = tableColumns[index] {
              column.minWidth = 60
              tableView.addTableColumn(column)
              column.headerCell.alignment = .left
              column.title = columnTitles[index]
            }
          }
          
          userSettings?.tableView = tableView
          
        }
        
      default:
        settingsView = ScrollVerticalStackView()
      }
      
      if let settingsView {
        
        settingsView.translatesAutoresizingMaskIntoConstraints = false
        settingsView.isHidden = true
        
        pnlSettingsView.append(settingsView)
        
        pnlSettings.addSubview(settingsView)
        
      }
      
    }
    
    inspectorFields = ProgrammerToolInspectorProperty.inspectorPropertyFields
    
    for temp in inspectorFields {
      if let comboBox = temp.control as? MyComboBox {
 //       comboBox.target = self
 //       comboBox.action = #selector(self.cboAction(_:))
      }
      else if let chkBox = temp.control as? NSButton {
 //       chkBox.target = self
 //       chkBox.action = #selector(self.chkAction(_:))
      }
      else if let field = temp.control as? NSTextField {
 //       field.delegate = self
      }
    }
    
    settingsFields = ProgrammerToolSettingsProperty.inspectorPropertyFields
    
    for temp in settingsFields {
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
      if let slider = temp.slider {
        slider.target = self
        slider.action = #selector(sliderAction(_:))
      }
    }
    
    settingsGroupFields = ProgrammerToolSettingsSection.inspectorSectionFields
    
    settingsGroupSeparators = ProgrammerToolSettingsSection.inspectorSectionSeparators

    NSLayoutConstraint.activate(constraints)

    currentInspector = ProgrammerToolInspector(rawValue: userSettings!.integer(forKey: DEFAULT.PROGRAMMER_TOOL_CURRENT_INSPECTOR)) ?? .quickHelp

    currentSelector = ProgrammerToolSettingsGroup(rawValue: userSettings!.integer(forKey: DEFAULT.PROGRAMMER_TOOL_CURRENT_SELECTOR)) ?? .address

    tableView.delegate = self
    tableView.dataSource = self
    
    decoder = Decoder(decoderType: .lokSound5)
    decoder?.delegate = self
    
    displaySettings()
    
    displayInspector()
    
  }
  
  // MARK: Private Properties
  
  private var observerId : Int?
  
  private var currentInspector : ProgrammerToolInspector = .quickHelp {
    didSet {
      for view in pnlInspectorButtons!.subviews {
        if let button = view as? NSButton {
          button.state = .off
          button.contentTintColor = button.tag == currentInspector.rawValue ? NSColor.systemBlue : nil
        }
      }
      for (key, item) in pnlInspectorView {
        item.isHidden = key != currentInspector
      }
      userSettings?.set(currentInspector.rawValue, forKey: DEFAULT.PROGRAMMER_TOOL_CURRENT_INSPECTOR)
    }
  }
  
  private var currentSelector : ProgrammerToolSettingsGroup = .address {
    didSet {

      for index in 0 ... btnGroups.count - 1 {
        btnGroups[index].contentTintColor = nil
        lblGroups[index].textColor = nil
        pnlSettingsView[index].isHidden = true
      }
      btnGroups[currentSelector.rawValue].contentTintColor = NSColor.systemBlue
      lblGroups[currentSelector.rawValue].textColor = NSColor.systemBlue
      pnlSettingsView[currentSelector.rawValue].isHidden = false
      
      userSettings?.set(currentSelector.rawValue, forKey: DEFAULT.PROGRAMMER_TOOL_CURRENT_SELECTOR)

    }
  }

  // MARK: Public Properties
  
  public var programmerTool : OpenLCBProgrammerToolNode?

  // MARK: Private Methods
  
  private func displaySettings() {
    
    NSLayoutConstraint.deactivate(settingsConstraints)
    settingsConstraints.removeAll()
    
    if let selectorStackView, let pnlSettings {
      
      selectorStackView.removeSubViews()
      
      for index in 0 ... pnlGroups.count - 1 {
      
        // TODO: Add Test Here
        
        let selectorView = pnlGroups[index]
        
        selectorStackView.addArrangedSubview(selectorView)
        
        let button = btnGroups[index]
        
        let label = lblGroups[index]
        
        let settingsView = pnlSettingsView[index]
        
        settingsConstraints.append(button.topAnchor.constraint(equalToSystemSpacingBelow: selectorView.topAnchor, multiplier: 0.5))
        settingsConstraints.append(button.centerXAnchor.constraint(equalTo: selectorView.centerXAnchor))
        settingsConstraints.append(label.topAnchor.constraint(equalToSystemSpacingBelow: button.bottomAnchor, multiplier: 1.0))
        settingsConstraints.append(label.centerXAnchor.constraint(equalTo: selectorView.centerXAnchor))
        settingsConstraints.append(selectorView.bottomAnchor.constraint(equalToSystemSpacingBelow: label.bottomAnchor, multiplier: 0.5))
        
        settingsConstraints.append(selectorStackView.stackView!.widthAnchor.constraint(greaterThanOrEqualTo: label.widthAnchor))

        settingsConstraints.append(settingsView.topAnchor.constraint(equalTo: pnlSettings.topAnchor))
        settingsConstraints.append(settingsView.leadingAnchor.constraint(equalTo: pnlSettings.leadingAnchor))
        settingsConstraints.append(settingsView.trailingAnchor.constraint(equalTo: pnlSettings.trailingAnchor))
        settingsConstraints.append(settingsView.bottomAnchor.constraint(equalTo: pnlSettings.bottomAnchor))
        
      }
      
    }
    
    NSLayoutConstraint.activate(settingsConstraints)
    
    displaySettingsInspector()
    
  }
  
  // MARK: Private Methods
  
  internal func displayInspector() {
    
    guard let decoder, let appNode else {
      return
    }
    
    NSLayoutConstraint.deactivate(inspectorConstraints)
    inspectorConstraints.removeAll()
    
    for (_, view) in pnlInspectorView {
      if let stackView = view.subviews[1] as? ScrollVerticalStackView {
        stackView.stackView?.subviews.removeAll()
      }
    }
    
    var commonProperties : Set<ProgrammerToolInspectorProperty> = []
    
    for property in ProgrammerToolInspectorProperty.allCases {
      if decoder.decoderType.isInspectorPropertySupported(property: property) {
        commonProperties.insert(property)
      }
    }
    
    var usedFields : [ProgrammerToolInspectorPropertyField] = []
    
    for field in inspectorFields {
      
      if field.control == nil {
   //     continue
      }
      
      if commonProperties.contains(field.property), let inspectorView = pnlInspectorView[field.property.inspector], let stackView = inspectorView.subviews[1] as? ScrollVerticalStackView {

        stackView.addArrangedSubview(field.view!)
        
        /// Note to self: Views within a StackView must not have constraints to the outside world as this will lock the StackView size.
        /// They must only have internal constraints to the view that is added to the StackView.
        ///  https://manasaprema04.medium.com/autolayout-fundamental-522f0a6e5790
        
        inspectorConstraints.append(field.view!.heightAnchor.constraint(greaterThanOrEqualTo: field.label!.heightAnchor))
        
        if let bits = field.bits {
          var lastAnchor : NSLayoutXAxisAnchor? = nil
          for bit in bits {
            if let lastAnchor {
              inspectorConstraints.append(bit.leadingAnchor.constraint(equalTo: lastAnchor, constant: 2))
            }
            else {
              inspectorConstraints.append(bit.leadingAnchor.constraint(equalToSystemSpacingAfter: field.label!.trailingAnchor, multiplier: 1.0))
            }
            lastAnchor = bit.trailingAnchor
            inspectorConstraints.append(field.view!.heightAnchor.constraint(greaterThanOrEqualTo: bit.heightAnchor))
          }
        }
        else {
          inspectorConstraints.append(field.view!.heightAnchor.constraint(greaterThanOrEqualTo: field.control!.heightAnchor))
          inspectorConstraints.append(field.control!.leadingAnchor.constraint(equalToSystemSpacingAfter: field.label!.trailingAnchor, multiplier: 1.0))
        }
        inspectorConstraints.append(field.label!.leadingAnchor.constraint(equalTo: field.view!.leadingAnchor, constant: 20))
        
        if field.property.controlType == .comboBox {
          inspectorConstraints.append(field.control!.widthAnchor.constraint(greaterThanOrEqualToConstant: 200))
        }
        else if field.control != nil {
          inspectorConstraints.append(field.control!.widthAnchor.constraint(greaterThanOrEqualToConstant: 100))
        }
          
   //     inspectorConstraints.append(field.view!.trailingAnchor.constraint(equalTo: field.control!.trailingAnchor))
        
        if field.control != nil {
          inspectorConstraints.append(field.control!.centerYAnchor.constraint(equalTo: field.view!.centerYAnchor))
        }
        inspectorConstraints.append(field.label!.centerYAnchor.constraint(equalTo: field.view!.centerYAnchor))
        
        if let button = field.readButton {
          inspectorConstraints.append(button.leadingAnchor.constraint(equalToSystemSpacingAfter: field.control!.trailingAnchor, multiplier: 1.0))
        }

        if let button = field.writeButton {
          inspectorConstraints.append(button.leadingAnchor.constraint(equalToSystemSpacingAfter: field.control!.trailingAnchor, multiplier: 1.0))
        }
        
        usedFields.append(field)

      }
      
    }
    
    for field1 in usedFields {
      for field2 in usedFields {
        if !(field1.label! === field2.label) && field1.property.inspector == field2.property.inspector {
          inspectorConstraints.append(field1.label!.widthAnchor.constraint(greaterThanOrEqualTo: field2.label!.widthAnchor))
        }
      }
    }
    
    NSLayoutConstraint.activate(inspectorConstraints)
    
  }

  internal func displaySettingsInspector() {
    
    guard let decoder, let appNode else {
      return
    }
    
    NSLayoutConstraint.deactivate(settingsPropertyConstraints)
    settingsPropertyConstraints.removeAll()
    
    for (view) in pnlSettingsView {
      if let stackView = view as? ScrollVerticalStackView {
        stackView.stackView?.subviews.removeAll()
      }
    }
    
    var commonProperties : Set<ProgrammerToolSettingsProperty> = [
    ]
    
    for property in ProgrammerToolSettingsProperty.allCases {
      if decoder.decoderType.isSettingsPropertySupported(property: property) {
        commonProperties.insert(property)
      }
    }
    
    if decoder.locomotiveAddressType == .extended {
      commonProperties.remove(.locomotiveAddressShort)
      commonProperties.remove(.marklinConsecutiveAddresses)
    }
    
    if decoder.locomotiveAddressType == .primary {
      commonProperties.remove(.locomotiveAddressLong)
      commonProperties.remove(.locomotiveAddressWarning)
    }
    
    if !decoder.isConsistAddressEnabled {
      commonProperties.remove(.consistAddress)
      commonProperties.remove(.consistReverseDirection)
    }
    
    if !decoder.isACAnalogModeEnabled {
      commonProperties.remove(.acAnalogModeStartVoltage)
      commonProperties.remove(.acAnalogModeMaximumSpeedVoltage)
    }

    if !decoder.isDCAnalogModeEnabled {
      commonProperties.remove(.dcAnalogModeStartVoltage)
      commonProperties.remove(.dcAnalogModeMaximumSpeedVoltage)
    }
    
    if !(decoder.abcBrakeIfLeftRailMorePositive || decoder.abcBrakeIfRightRailMorePositive) {
      commonProperties.remove(.voltageDifferenceIndicatingABCBrakeSection)
      commonProperties.remove(.abcReducedSpeed)
    }
    
    if !decoder.isABCShuttleTrainEnabled {
      commonProperties.remove(.waitingPeriodBeforeDirectionChange)
    }
    
    if !decoder.isConstantBrakeDistanceEnabled {
      commonProperties.remove(.brakeDistanceLength)
      commonProperties.remove(.differentBrakeDistanceBackwards)
      commonProperties.remove(.brakeDistanceLengthBackwards)
      commonProperties.remove(.driveUntilLocomotiveStopsInSpecifiedPeriod)
      commonProperties.remove(.stoppingPeriod)
      commonProperties.remove(.constantBrakeDistanceOnSpeedStep0)
    }

    if !decoder.isDifferentBrakeDistanceBackwards {
      commonProperties.remove(.brakeDistanceLengthBackwards)
    }

    if !decoder.driveUntilLocomotiveStopsInSpecifiedPeriod {
      commonProperties.remove(.stoppingPeriod)
    }
    
    if !decoder.isRailComFeedbackEnabled {
      commonProperties.remove(.enableRailComPlusAutomaticAnnouncement)
      commonProperties.remove(.sendFollowingToCommandStation)
      commonProperties.remove(.sendAddressViaBroadcastOnChannel1)
      commonProperties.remove(.allowDataTransmissionOnChannel2)
    }
    
    if decoder.detectSpeedStepModeAutomatically {
      commonProperties.remove(.speedStepMode)
    }
    
    if !decoder.isAccelerationEnabled {
      commonProperties.remove(.accelerationRate)
      commonProperties.remove(.accelerationAdjustment)
    }

    if !decoder.isDecelerationEnabled {
      commonProperties.remove(.decelerationRate)
      commonProperties.remove(.decelerationAdjustment)
    }
    
    if !decoder.isForwardTrimEnabled {
      commonProperties.remove(.forwardTrim)
    }

    if !decoder.isReverseTrimEnabled {
      commonProperties.remove(.reverseTrim)
    }

    if !decoder.isShuntingModeTrimEnabled {
      commonProperties.remove(.shuntingModeTrim)
    }
    
    if !decoder.isGearboxBacklashCompensationEnabled {
      commonProperties.remove(.gearboxBacklashCompensation)
    }
    
    if !decoder.isDecoderSynchronizedWithMasterDecoder {
      commonProperties.remove(.m4MasterDecoderManufacturer)
      commonProperties.remove(.m4MasterDecoderSerialNumber)
    }
    
    if !decoder.isAutomaticUncouplingEnabled {
      commonProperties.remove(.automaticUncouplingSpeed)
      commonProperties.remove(.automaticUncouplingPushTime)
      commonProperties.remove(.automaticUncouplingWaitTime)
      commonProperties.remove(.automaticUncouplingMoveTime)
    }
    
    if !decoder.isLoadControlBackEMFEnabled {
      commonProperties.remove(.regulationReference)
      commonProperties.remove(.regulationParameterK)
      commonProperties.remove(.regulationParameterI)
      commonProperties.remove(.regulationParameterKSlow)
      commonProperties.remove(.largestInternalSpeedStepThatUsesKSlow)
      commonProperties.remove(.regulationInfluenceDuringSlowSpeed)
      commonProperties.remove(.slowSpeedBackEMFSamplingPeriod)
      commonProperties.remove(.fullSpeedBackEMFSamplingPeriod)
      commonProperties.remove(.slowSpeedLengthOfMeasurementGap)
      commonProperties.remove(.fullSpeedLengthOfMeasurementGap)
    }
    
    if !decoder.isMotorCurrentLimiterEnabled {
      commonProperties.remove(.motorCurrentLimiterLimit)
    }

    var usedFields : [ProgrammerToolSettingsPropertyField] = []
    
    var index = 0
    while index < settingsFields.count {
      
      let inspector = settingsFields[index].property.section.inspector
      
      let view = pnlSettingsView[inspector.rawValue]
      
      if let stackView = (view as? ScrollVerticalStackView)?.stackView {
        
        stackView.alignment = .right
        
        while index < settingsFields.count && settingsFields[index].property.section.inspector == inspector {
          
          let group = settingsFields[index].property.section
          
          var showGroupHeader = true
          var showGroupSeparator = false
          
          while index < settingsFields.count && settingsFields[index].property.section == group {
            
            let field = settingsFields[index]
            
            if commonProperties.contains(field.property), let control = field.control, let view = field.view, let cvLabel = field.cvLabel {
              
              if showGroupHeader {
                stackView.addArrangedSubview(settingsGroupFields[group]!.view!)
                showGroupHeader = false
                showGroupSeparator = true
              }
              
              stackView.addArrangedSubview(view)
              
              cvLabel.stringValue = field.property.cvLabel
              
              /// Note to self: Views within a StackView must not have constraints to the outside world as this will lock the StackView size.
              /// They must only have internal constraints to the view that is added to the StackView.
              ///  https://manasaprema04.medium.com/autolayout-fundamental-522f0a6e5790

              if let label = field.label {
                settingsPropertyConstraints.append(label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20))
                settingsPropertyConstraints.append(label.topAnchor.constraint(equalTo: view.topAnchor))
                settingsPropertyConstraints.append(view.heightAnchor.constraint(greaterThanOrEqualTo: label.heightAnchor))
                settingsPropertyConstraints.append(control.topAnchor.constraint(equalToSystemSpacingBelow: label.bottomAnchor, multiplier: 1.0))
              }
              else {
                settingsPropertyConstraints.append(control.topAnchor.constraint(equalTo: view.topAnchor))
              }
              settingsPropertyConstraints.append(view.bottomAnchor.constraint(greaterThanOrEqualTo: control.bottomAnchor))
              settingsPropertyConstraints.append(cvLabel.topAnchor.constraint(equalTo: control.topAnchor))
              settingsPropertyConstraints.append(view.bottomAnchor.constraint(greaterThanOrEqualTo: cvLabel.bottomAnchor))
              settingsPropertyConstraints.append(cvLabel.leadingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: control.trailingAnchor, multiplier: 1.0))
              settingsPropertyConstraints.append(view.trailingAnchor.constraint(equalToSystemSpacingAfter: cvLabel.trailingAnchor, multiplier: 1.0))
              
              if let slider = field.slider {
                settingsPropertyConstraints.append(slider.centerYAnchor.constraint(equalTo: control.centerYAnchor))
                settingsPropertyConstraints.append(view.bottomAnchor.constraint(greaterThanOrEqualTo: slider.bottomAnchor))
                settingsPropertyConstraints.append(slider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20))
                settingsPropertyConstraints.append(slider.widthAnchor.constraint(equalToConstant: 200))
              }
              
              if let customView = field.customView {
                settingsPropertyConstraints.append(customView.centerYAnchor.constraint(equalTo: control.centerYAnchor))
                settingsPropertyConstraints.append(view.bottomAnchor.constraint(greaterThanOrEqualTo: customView.bottomAnchor))
                settingsPropertyConstraints.append(cvLabel.leadingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: customView.trailingAnchor, multiplier: 1.0))
              }
              
              switch field.property.controlType {
              case .textField:
                settingsPropertyConstraints.append(control.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20))
                settingsPropertyConstraints.append(control.widthAnchor.constraint(equalToConstant: 100))
              case .textFieldWithSlider:
                if let slider = field.slider {
                  settingsPropertyConstraints.append(control.leadingAnchor.constraint(equalToSystemSpacingAfter: slider.trailingAnchor, multiplier: 1.0))
                  settingsPropertyConstraints.append(control.widthAnchor.constraint(equalToConstant: 100))
                }
              case .warning:
                if let customView = field.customView {
                  settingsPropertyConstraints.append(customView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20))
                  settingsPropertyConstraints.append(control.leadingAnchor.constraint(equalToSystemSpacingAfter: customView.trailingAnchor, multiplier: 1.0))
                }
              case .textFieldWithInfo:
                if let customView = field.customView {
                  settingsPropertyConstraints.append(control.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20))
                  settingsPropertyConstraints.append(control.widthAnchor.constraint(equalToConstant: 100))
                  settingsPropertyConstraints.append(customView.leadingAnchor.constraint(equalToSystemSpacingAfter: control.trailingAnchor, multiplier: 1.0))
                }
              case .textFieldWithInfoWithSlider:
                if let customView = field.customView, let slider = field.slider {
                  settingsPropertyConstraints.append(control.leadingAnchor.constraint(equalToSystemSpacingAfter: slider.trailingAnchor, multiplier: 1.0))
                  settingsPropertyConstraints.append(control.widthAnchor.constraint(equalToConstant: 100))
                  settingsPropertyConstraints.append(customView.leadingAnchor.constraint(equalToSystemSpacingAfter: control.trailingAnchor, multiplier: 1.0))
                }

              default:
                settingsPropertyConstraints.append(control.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20))
                settingsPropertyConstraints.append(control.widthAnchor.constraint(greaterThanOrEqualToConstant: 100))
                settingsPropertyConstraints.append(view.trailingAnchor.constraint(greaterThanOrEqualTo: control.trailingAnchor))
              }

              usedFields.append(field)
                
              setValue(field: field)
                
            }
            
            index += 1
            
          }
          
          if showGroupSeparator {
            stackView.addArrangedSubview(settingsGroupSeparators[group]!.view!)
          }
          
        }
        
      }
      
    }
    /*
    for field1 in usedFields {
      for field2 in usedFields {
        if !(field1.label! === field2.label) && field1.property.section.inspector == field2.property.section.inspector {
          settingsPropertyConstraints.append(field1.label!.widthAnchor.constraint(greaterThanOrEqualTo: field2.label!.widthAnchor))
        }
      }
    }
    */
    NSLayoutConstraint.activate(settingsPropertyConstraints)
    
  }

  private func setValue(field:ProgrammerToolSettingsPropertyField) {
    
    guard let decoder else {
      return
    }
    
    let value = decoder.getValue(property: field.property)
    
    if let slider = field.slider {
      slider.intValue = Int32(value)!
    }
    
    switch field.property.controlType {
    case .textField, .textFieldWithInfo, .textFieldWithSlider, .textFieldWithInfoWithSlider:
      (field.control as? NSTextField)?.stringValue = value
      if field.property.controlType == .textFieldWithInfo || field.property.controlType == .textFieldWithInfoWithSlider {
        (field.customView as? NSTextField)?.stringValue = decoder.getInfo(property: field.property)
      }
    case .label, .warning, .description:
      (field.control as? NSTextField)?.stringValue = value
    case .checkBox:
      (field.control as? NSButton)?.state = value == "true" ? .on : .off
    case .comboBox:
      
      if let comboBox = field.control as? NSComboBox {
        
        comboBox.stringValue = ""
        
        if comboBox.numberOfItems > 0 {
          comboBox.selectItem(withObjectValue: value)
        }
        
      }
    }
    
  }

  // MARK: Actions
  
  @objc public func btnInspectorAction(_ sender:NSButton) {
    
    if let item = ProgrammerToolInspector(rawValue: sender.tag) {
      currentInspector = item
    }
    
  }

  @objc public func btnSelectorAction(_ sender:AnyObject) {
    
    if let item = ProgrammerToolSettingsGroup(rawValue: sender.tag) {
      currentSelector = item
    }
    
  }

  @objc func cboAction(_ sender: NSComboBox) {
    
    if let decoder, let property = ProgrammerToolSettingsProperty(rawValue: sender.tag) {
      
      if sender.indexOfSelectedItem >= 0, let string = sender.itemObjectValue(at: sender.indexOfSelectedItem) as? String {
        
        decoder.setValue(property: property, string: string)
        
      }
      else {
        decoder.setValue(property: property, string: "")
      }
      
    }
    
  }
  
  @objc func chkAction(_ sender: NSButton) {
    
    if let decoder, let property = ProgrammerToolSettingsProperty(rawValue: sender.tag) {
      decoder.setValue(property: property, string: sender.state == .on ? "true" : "false")
    }
    
  }
  
  @objc func sliderAction(_ sender: NSSlider) {
    if let decoder, let property = ProgrammerToolSettingsProperty(rawValue: sender.tag) {
      decoder.setValue(property: property, string: "\(sender.intValue)")
    }
  }

  // MARK: NSTableViewDelegate Methods
  
  // Returns the number of records managed for aTableView by the data source object.
  public func numberOfRows(in tableView: NSTableView) -> Int {
    guard let decoder else {
      return 0
    }
    return decoder.visibleCVs.count
  }
  
  // Sets the data object for an item in the specified row and column.
  public func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
  }
  
  public func tableView(_ tableView: NSTableView,
                        viewFor tableColumn: NSTableColumn?,row: Int) -> NSView? {
    
    guard let decoder else {
      return nil
    }
    
    let cv = decoder.visibleCVs[row].cv
    
    let value = decoder.getUInt8(cv: cv) ?? 0
    
    var isEditable = false
    
    let text = NSTextField()
    
    text.font = NSFont(name: "Menlo", size: 12)
 
    switch tableColumn!.identifier {
    case columnIds[0]:
      text.stringValue = "\(cv.cv31)"
    case columnIds[1]:
      text.stringValue = "\(cv.cv32)"
    case columnIds[2]:
      text.stringValue = "\(cv.cv)"
    case columnIds[3]:
      text.stringValue = "\(value)"
      isEditable = !cv.isReadOnly
      text.delegate = self
      text.tag = 100000 + row * 10 + 0
    case columnIds[4]:
      text.stringValue = "\(value.toBinary(numberOfDigits: 8))"
      isEditable = !cv.isReadOnly
      text.delegate = self
      text.tag = 100000 + row * 10 + 1
    case columnIds[5]:
      text.stringValue = "\(value.toHex(numberOfDigits: 2))"
      isEditable = !cv.isReadOnly
      text.delegate = self
      text.tag = 100000 + row * 10 + 2
    default:
      break
    }
    
    let cell = NSTableCellView()
    cell.addSubview(text)
    text.drawsBackground = false
    text.isBordered = false
    text.isEditable = isEditable
    text.translatesAutoresizingMaskIntoConstraints = false
    cell.addConstraint(NSLayoutConstraint(item: text, attribute: .centerY, relatedBy: .equal, toItem: cell, attribute: .centerY, multiplier: 1, constant: 0))
    cell.addConstraint(NSLayoutConstraint(item: text, attribute: .left, relatedBy: .equal, toItem: cell, attribute: .left, multiplier: 1, constant: 13))
    cell.addConstraint(NSLayoutConstraint(item: text, attribute: .right, relatedBy: .equal, toItem: cell, attribute: .right, multiplier: 1, constant: -13))
    return cell
    
  }

  // MARK: NSTextFieldDelegate, NSControlTextEditingDelegate Methods
  
  /// This is called when the user presses return.
  @objc func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
    
    var isValid = true
    
    if let textField = control as? NSTextField, let decoder {
      
      let trimmed = textField.stringValue.trimmingCharacters(in: .whitespaces)
      
      // This is the tableView validation - all tags are >= 100000
      
      if textField.tag >= 100000 {
        let row = (textField.tag - 100000) / 10
        let column = (textField.tag - 100000) % 10
        let cv = decoder.visibleCVs[row].cv
        switch column {
        case 0:
          if let value = UInt8(trimmed) {
            decoder.setUInt8(cv: cv, value: value)
          }
          else {
            isValid = false
          }
        case 1:
          if let value = UInt8(binary:trimmed) {
            decoder.setUInt8(cv: cv, value: value)
          }
          else {
            isValid = false
          }
        case 2:
          if let value = UInt8(hex:trimmed) {
            decoder.setUInt8(cv: cv, value: value)
          }
          else {
            isValid = false
          }
        default:
          break
        }
      }
      else {
        
        let trimmed = textField.stringValue.trimmingCharacters(in: .whitespaces)
        
        if let property = ProgrammerToolSettingsProperty(rawValue: textField.tag) {
          
          isValid = decoder.isValid(property: property, string: trimmed)
          
          if isValid {
            decoder.setValue(property: property, string: trimmed)
          }
          
        }
        
      }
      
    }
    
    return isValid
    
  }

  // MARK: DecoderDelegate Methods
  
  @objc func reloadData(_ decoder: Decoder) {
    tableView?.reloadData()
    lblChangedCVs?.stringValue = decoder.cvTextList(list: decoder.cvsModified)
  }

  @objc func reloadSettings(_ decoder: Decoder) {
    displaySettingsInspector()
  }

}
