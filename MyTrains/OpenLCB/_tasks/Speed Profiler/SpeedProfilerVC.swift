//
//  SpeedProfilerVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 01/08/2022.
//

import Foundation
import AppKit

class SpeedProfilerVC: MyTrainsViewController, OpenLCBConfigurationToolDelegate, NSTableViewDataSource, NSTableViewDelegate, MyTrainsAppDelegate, NSTextFieldDelegate, NSControlTextEditingDelegate, SpeedProfileDelegate {
 
  // MARK: Window & View Control

  deinit {
    
    constraints.removeAll()
    
    inspectorConstraints.removeAll()
    
    cboLocomotive?.removeAllItems()
    cboLocomotive = nil
    
    cboValueTypes?.removeAllItems()
    cboValueTypes = nil
    
    for view in sptSplitView!.arrangedSubviews {
      sptSplitView?.removeArrangedSubview(view)
    }
    sptSplitView = nil
    
    for view in sptResultsView!.arrangedSubviews {
      sptResultsView?.removeArrangedSubview(view)
    }
    sptResultsView = nil
    
    pnlInspectorStackView.removeAll()
    
    pnlDisclosure?.subviews.removeAll()
    pnlDisclosure = nil
    
    pnlButtons?.subviews.removeAll()
    pnlButtons = nil
    
    pnlValues?.subviews.removeAll()
    pnlValues = nil
    
    pnlInspector?.subviews.removeAll()
    pnlInspector = nil
    
    btnReset = nil
    
    btnDiscardChanges = nil
    
    btnSaveChanges = nil
    
    btnStartStop = nil
    
    btnShowValuesPanel = nil
    
    btnShowInspectorPanel = nil
    
    pnlValuesScrollView?.documentView = nil
    pnlValuesScrollView = nil
    
    for index in 0 ... tblValuesColumns.count - 1 {
      tblValuesTableView?.removeTableColumn(tblValuesColumns[index]!)
      tblValuesColumns[index] = nil
    }
    tblValuesColumns.removeAll()
    
    tblValuesTableView = nil
    
    pnlInspectorButtons?.subviews.removeAll()
    pnlInspectorButtons = nil
    
    pnlChart = nil
    
    debugLog("DEINIT - REMOVE BEFORE FLIGHT!")
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewType = .speedProfiler
  }
  
  override func windowWillClose(_ notification: Notification) {
    
    if let configurationTool {
      configurationTool.delegate = nil
      appDelegate.networkLayer?.releaseConfigurationTool(configurationTool: configurationTool)
      self.configurationTool = nil
    }
    
    if let observerId, let appNode {
      appNode.removeObserver(observerId: observerId)
    }
    
    super.windowWillClose(notification)

  }
  
  override func viewWillAppear() {
    
    super.viewWillAppear()
    
    guard let cboLocomotive, let sptSplitView, let pnlDisclosure, let pnlButtons, let btnReset, let btnDiscardChanges, let btnSaveChanges, let btnStartStop, let btnShowValuesPanel, let btnShowInspectorPanel, let pnlChart, let pnlValues, let cboValueTypes, let pnlInspector, let pnlValuesScrollView, let tblValuesTableView, let pnlInspectorButtons, let sptResultsView else {
      return
    }
    
    appNode?.layout?.linkSwitchboardItems()

    // cboLocomotive
    
    cboLocomotive.translatesAutoresizingMaskIntoConstraints = false
    cboLocomotive.isEditable = false
    cboLocomotive.target = self
    cboLocomotive.action = #selector(cboLocomotiveAction(_:))
    
    view.addSubview(cboLocomotive)
    
    constraints.append(cboLocomotive.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 1.0))
    constraints.append(cboLocomotive.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1.0))
    constraints.append(view.trailingAnchor.constraint(equalToSystemSpacingAfter: cboLocomotive.trailingAnchor, multiplier: 1.0))
    
    // sptSplitView
    
    sptSplitView.translatesAutoresizingMaskIntoConstraints = false
    sptSplitView.isVertical = true
    sptSplitView.arrangesAllSubviews = true

    view.addSubview(sptSplitView)
    
    constraints.append(sptSplitView.topAnchor.constraint(equalToSystemSpacingBelow: cboLocomotive.bottomAnchor, multiplier: 2.0))
    constraints.append(sptSplitView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1.0))
    constraints.append(view.trailingAnchor.constraint(equalToSystemSpacingAfter: sptSplitView.trailingAnchor, multiplier: 1.0))
    
    // sptResultsView
    
    sptResultsView.translatesAutoresizingMaskIntoConstraints = false
    sptResultsView.isVertical = false
    sptResultsView.arrangesAllSubviews = true
    
    sptSplitView.addArrangedSubview(sptResultsView)
    
    // pnlValues
    
    pnlValues.translatesAutoresizingMaskIntoConstraints = false
    pnlValues.backgroundColor = nil
    
    sptResultsView.addArrangedSubview(pnlValues)
    
    cboValueTypes.translatesAutoresizingMaskIntoConstraints = false
    cboValueTypes.isEditable = false
    cboValueTypes.target = self
    cboValueTypes.action = #selector(cboValueTypesAction(_:))
    
    SpeedProfilerValueType.populate(comboBox: cboValueTypes)
    valueType = SpeedProfilerValueType(rawValue: userSettings!.integer(forKey: DEFAULT.CURRENT_VALUES_MODE)) ?? .actualSamples
    SpeedProfilerValueType.select(comboBox: cboValueTypes, valueType: valueType)
    
    pnlValues.addSubview(cboValueTypes)
    
    constraints.append(cboValueTypes.topAnchor.constraint(equalTo: pnlValues.topAnchor))
    constraints.append(cboValueTypes.centerXAnchor.constraint(equalTo: pnlValues.centerXAnchor))
    constraints.append(cboValueTypes.leadingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: pnlValues.leadingAnchor, multiplier: 1.0))
    constraints.append(pnlValues.trailingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: cboValueTypes.trailingAnchor, multiplier: 1.0))
//    constraints.append(cboValueTypes.widthAnchor.constraint(greaterThanOrEqualToConstant: 100))
    
    pnlValuesScrollView.translatesAutoresizingMaskIntoConstraints = false
    pnlValuesScrollView.backgroundColor = nil
    pnlValuesScrollView.drawsBackground = false
    pnlValuesScrollView.hasVerticalScroller = true
    pnlValuesScrollView.hasHorizontalScroller = true
    pnlValuesScrollView.autoresizesSubviews = true
    
    pnlValues.addSubview(pnlValuesScrollView)
    
    constraints.append(pnlValuesScrollView.topAnchor.constraint(equalToSystemSpacingBelow: cboValueTypes.bottomAnchor, multiplier: 1.0))
    constraints.append(pnlValuesScrollView.leadingAnchor.constraint(equalTo: pnlValues.leadingAnchor))
    constraints.append(pnlValuesScrollView.trailingAnchor.constraint(equalTo: pnlValues.trailingAnchor))
//    constraints.append(pnlValuesScrollView.centerXAnchor.constraint(equalTo: pnlValues.centerXAnchor))
//    constraints.append(pnlValuesScrollView.widthAnchor.constraint(equalToConstant: 718))
    constraints.append(pnlValues.bottomAnchor.constraint(equalTo: pnlValuesScrollView.bottomAnchor))
    constraints.append(pnlValues.widthAnchor.constraint(greaterThanOrEqualTo: pnlValuesScrollView.widthAnchor))
    
    tblValuesTableView.allowsColumnReordering = true
    tblValuesTableView.selectionHighlightStyle = .none
//    tblValuesTableView.columnAutoresizingStyle = .noColumnAutoresizing
    tblValuesTableView.allowsColumnResizing = true
    tblValuesTableView.usesAlternatingRowBackgroundColors = true
    
    let columnNames = [
      "Sample Number",
      "Commanded Speed",
      "Forward Speed",
      "Delta Forward Speed",
      "Reverse Speed",
      "Delta Reverse Speed"
    ]

    let columnTitles = [
      String(localized:"Sample"),
      String(localized:"Commanded (%%SCALE_SPEED_UNITS%%)"),
      String(localized:"Forward (%%SCALE_SPEED_UNITS%%)"),
      String(localized:"δ Forward (%%SCALE_SPEED_UNITS%%)"),
      String(localized:"Reverse (%%SCALE_SPEED_UNITS%%)"),
      String(localized:"δ Reverse (%%SCALE_SPEED_UNITS%%)"),
    ]
    
    let columnToolTips = [
      String(localized: "Number of the sample"),
      String(localized: "Speed that the locomotive was commanded to travel at"),
      String(localized: "Speed that the train actually travelled at in the forward direction"),
      String(localized: "Difference between commanded speed and actual speed in the forward direction"),
      String(localized: "Speed that the train actually travelled at in the reverse direction"),
      String(localized: "Difference between commanded speed and actual speed in the reverse direction"),
    ]

    for index in 0 ... columnNames.count - 1 {
      let id = NSUserInterfaceItemIdentifier(rawValue: columnNames[index])
      columnIds.append(id)
      tblValuesColumns.append(NSTableColumn(identifier: id))
      if let column = tblValuesColumns[index] {
        column.minWidth = 60
        tblValuesTableView.addTableColumn(column)
        column.headerCell.alignment = .left
        column.title = columnTitles[index].replacingOccurrences(of: "%%SCALE_SPEED_UNITS%%", with: appNode!.unitsScaleSpeed.symbol)
        column.headerToolTip = columnToolTips[index]
      }
    }

    pnlValuesScrollView.documentView = tblValuesTableView
    
    // pnlChart
    
    pnlChart.translatesAutoresizingMaskIntoConstraints = false

    sptResultsView.addArrangedSubview(pnlChart)
    
    constraints.append(pnlChart.heightAnchor.constraint(greaterThanOrEqualToConstant: 250))
    constraints.append(pnlChart.widthAnchor.constraint(greaterThanOrEqualToConstant: 450))

    // pnlInspector
    
    inspectorFields = SpeedProfilerInspectorProperty.inspectorPropertyFields
    
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
    
    inspectorGroupFields = SpeedProfilerInspectorGroup.inspectorGroupFields
    
    inspectorGroupSeparators = SpeedProfilerInspectorGroup.inspectorGroupSeparators
    
    pnlInspector.translatesAutoresizingMaskIntoConstraints = false
//    pnlInspector.backgroundColor = NSColor.white.cgColor
    
    sptSplitView.addArrangedSubview(pnlInspector)
    
    pnlInspectorButtons.translatesAutoresizingMaskIntoConstraints = false
    
    pnlInspector.addSubview(pnlInspectorButtons)
    
    constraints.append(pnlInspector.widthAnchor.constraint(greaterThanOrEqualTo: pnlInspectorButtons.widthAnchor))
    
    constraints.append(pnlInspectorButtons.centerXAnchor.constraint(equalTo: pnlInspector.centerXAnchor))
    constraints.append(pnlInspectorButtons.topAnchor.constraint(equalTo: pnlInspector.topAnchor, constant: 5))
    
    var lastButton : NSButton?
    
    for item in SpeedProfilerInspector.allCases {
      
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
      constraints.append(pnlInspectorButtons.heightAnchor.constraint(equalTo: button.heightAnchor))
      lastButton = button
      
      let stackView = ScrollVerticalStackView()
      
      pnlInspectorStackView[item] = stackView
      
      pnlInspector.addSubview(stackView)
    
      stackView.translatesAutoresizingMaskIntoConstraints = false
      stackView.isHidden = true
//      stackView.backgroundColor = item.backgroundColor
      stackView.backgroundColor = NSColor.clear.cgColor
      stackView.stackView?.orientation = .vertical
      stackView.stackView?.spacing = 4

      constraints.append(stackView.topAnchor.constraint(equalToSystemSpacingBelow: pnlInspectorButtons.bottomAnchor, multiplier: 1.0))
      constraints.append(stackView.leadingAnchor.constraint(equalTo: pnlInspector.leadingAnchor))
      constraints.append(stackView.trailingAnchor.constraint(equalTo: pnlInspector.trailingAnchor))
      constraints.append(pnlInspector.bottomAnchor.constraint(equalTo: stackView.bottomAnchor))
      
    }
    
    constraints.append(pnlInspectorButtons.trailingAnchor.constraint(equalToSystemSpacingAfter: lastButton!.trailingAnchor, multiplier: 1.0))
    
    // pnlDisclosure
    
    pnlDisclosure.translatesAutoresizingMaskIntoConstraints = false
    pnlDisclosure.backgroundColor = NSColor.white.cgColor
//    pnlDisclosure.setContentHuggingPriority(NSLayoutConstraint.Priority(rawValue: 999), for: .vertical)
    
    view.addSubview(pnlDisclosure)
    
    constraints.append(pnlDisclosure.topAnchor.constraint(equalToSystemSpacingBelow: sptSplitView.bottomAnchor, multiplier: 1.0))
    constraints.append(pnlDisclosure.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1.0))
    constraints.append(view.trailingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: pnlDisclosure.trailingAnchor, multiplier: 1.0))
    
    btnShowValuesPanel.translatesAutoresizingMaskIntoConstraints = false
    btnShowValuesPanel.isBordered = false
    btnShowValuesPanel.target = self
    btnShowValuesPanel.action = #selector(btnShowValuesPanelAction(_:))
    btnShowValuesPanel.state = userSettings!.state(forKey: DEFAULT.SHOW_VALUES_VIEW)

    pnlDisclosure.addSubview(btnShowValuesPanel)
    
    constraints.append(btnShowValuesPanel.centerYAnchor.constraint(equalTo: pnlDisclosure.centerYAnchor))
    constraints.append(btnShowValuesPanel.leadingAnchor.constraint(equalToSystemSpacingAfter: pnlDisclosure.leadingAnchor, multiplier: 1.0))
    constraints.append(pnlDisclosure.heightAnchor.constraint(equalToConstant: 20))

    btnShowInspectorPanel.translatesAutoresizingMaskIntoConstraints = false
    btnShowInspectorPanel.isBordered = false
    btnShowInspectorPanel.target = self
    btnShowInspectorPanel.action = #selector(btnShowInspectorPanelAction(_:))
    btnShowInspectorPanel.state = userSettings!.state(forKey: DEFAULT.SHOW_SETTINGS_VIEW)

    pnlDisclosure.addSubview(btnShowInspectorPanel)

    constraints.append(btnShowInspectorPanel.centerYAnchor.constraint(equalTo: pnlDisclosure.centerYAnchor))
    constraints.append(pnlDisclosure.trailingAnchor.constraint(equalToSystemSpacingAfter: btnShowInspectorPanel.trailingAnchor, multiplier: 1.0))
 
    // pnlButtons
    
    pnlButtons.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(pnlButtons)
    
    constraints.append(pnlButtons.topAnchor.constraint(equalToSystemSpacingBelow: pnlDisclosure.bottomAnchor, multiplier: 1.0))
    constraints.append(pnlButtons.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1.0))
    constraints.append(view.trailingAnchor.constraint(equalToSystemSpacingAfter: pnlButtons.trailingAnchor, multiplier: 1.0))
    constraints.append(pnlButtons.heightAnchor.constraint(equalToConstant: 20))
    
    btnReset.translatesAutoresizingMaskIntoConstraints = false
    btnReset.title = String(localized: "Reset to Defaults")
    btnReset.target = self
    btnReset.action = #selector(btnResetToDefaultsAction(_:))
    
    pnlButtons.addSubview(btnReset)
    
    constraints.append(btnReset.centerYAnchor.constraint(equalTo: pnlButtons.centerYAnchor))
    constraints.append(btnReset.leadingAnchor.constraint(equalTo: pnlButtons.leadingAnchor))
    
    btnDiscardChanges.translatesAutoresizingMaskIntoConstraints = false
    btnDiscardChanges.title = String(localized: "Discard Changes")
    btnDiscardChanges.target = self
    btnDiscardChanges.action = #selector(btnDiscardChangesAction(_:))
    
    pnlButtons.addSubview(btnDiscardChanges)
    
    constraints.append(btnDiscardChanges.centerYAnchor.constraint(equalTo: pnlButtons.centerYAnchor))
    constraints.append(btnDiscardChanges.leadingAnchor.constraint(equalToSystemSpacingAfter: btnReset.trailingAnchor, multiplier: 1.0))

    btnSaveChanges.translatesAutoresizingMaskIntoConstraints = false
    btnSaveChanges.title = String(localized: "Save Changes")
    btnSaveChanges.target = self
    btnSaveChanges.action = #selector(btnSaveChangesAction(_:))

    pnlButtons.addSubview(btnSaveChanges)
    
    constraints.append(btnSaveChanges.centerYAnchor.constraint(equalTo: pnlButtons.centerYAnchor))
    constraints.append(btnSaveChanges.leadingAnchor.constraint(equalToSystemSpacingAfter: btnDiscardChanges.trailingAnchor, multiplier: 1.0))

    btnStartStop.translatesAutoresizingMaskIntoConstraints = false
    btnStartStop.title = String(localized: "Start Profiling")
    
    pnlButtons.addSubview(btnStartStop)
    
    constraints.append(btnStartStop.centerYAnchor.constraint(equalTo: pnlButtons.centerYAnchor))
    constraints.append(btnStartStop.trailingAnchor.constraint(equalTo: pnlButtons.trailingAnchor))
    constraints.append(btnStartStop.leadingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: btnSaveChanges.trailingAnchor, multiplier: 1.0))
    
    constraints.append(pnlButtons.heightAnchor.constraint(equalTo: btnReset.heightAnchor))
    
    constraints.append(view.bottomAnchor.constraint(equalToSystemSpacingBelow: pnlButtons.bottomAnchor, multiplier: 1.0))
    
    // Activate all constraints
    
    NSLayoutConstraint.activate(constraints)

    btnShowValuesPanelAction(btnShowValuesPanel)
    
    btnShowInspectorPanelAction(btnShowInspectorPanel)
    
    currentInspector = SpeedProfilerInspector(rawValue: userSettings!.integer(forKey: DEFAULT.CURRENT_SETTINGS_INSPECTOR)) ?? .quickHelp
 
    userSettings?.splitView = sptSplitView
    userSettings?.splitView2 = sptResultsView

    userSettings?.tableView = tblValuesTableView
    
    tblValuesTableView.dataSource = self
    tblValuesTableView.delegate = self
    
    observerId = appNode?.addObserver(observer: self)
    
    if cboLocomotive.numberOfItems > 0, cboLocomotive.indexOfSelectedItem == -1 {
      cboLocomotive.selectItem(at: 0)
    }
    
    displayInspector()

  }
  
  // MARK: Private Properties
  
  private var constraints : [NSLayoutConstraint] = []
  
  private var valueType : SpeedProfilerValueType = .actualSamples
  
  private var currentInspector : SpeedProfilerInspector = .quickHelp {
    didSet {
      for view in pnlInspectorButtons!.subviews {
        if let button = view as? NSButton {
          button.state = .off
          button.contentTintColor = button.tag == currentInspector.rawValue ? NSColor.systemBlue : nil
        }
      }
      for (key, item) in pnlInspectorStackView {
        item.isHidden = key != currentInspector
      }
      userSettings?.set(currentInspector.rawValue, forKey: DEFAULT.CURRENT_SETTINGS_INSPECTOR)
    }
  }
  
  // MARK: Private Methods
  
  internal func displayInspector() {
    
    guard let profile, let appNode else {
      return
    }
    
    NSLayoutConstraint.deactivate(inspectorConstraints)
    inspectorConstraints.removeAll()

    for (key, stackView) in pnlInspectorStackView {
      stackView.stackView?.subviews.removeAll()
    }
    
    var commonProperties : Set<SpeedProfilerInspectorProperty> = [

      .locomotiveId,
      .locomotiveName,
      .trackProtocol,
      .locomotiveControlBasis,
      .locomotiveFacingDirection,
      .locomotiveTravelDirectionToSample,
      .minimumSamplePeriod,
      .startSampleNumber,
      .stopSampleNumber,
      .useRFIDReaders,
      .useLightSensors,
      .useReedSwitches,
      .useOccupancyDetectors,
      .bestFitMethod,
      .showTrendline,
      .routeType,
      .startBlockId,
      .totalRouteLength,
      .routeSegments,
      
    ]
    
    commonProperties.insert(profile.trackProtocol.isNumberOfSamplesFixed ? .numberOfSamplesLabel : .numberOfSamples)

    commonProperties.insert(profile.trackProtocol.isMaximumSpeedFixed ? .maximumSpeedLabel : .maximumSpeed)
    
    if profile.routeType == .straight {
      commonProperties.insert(.endBlockId)
    }
    else {
      commonProperties.insert(.route)
    }
    
    var usedFields : [SpeedProfilerInspectorPropertyField] = []
    
    var index = 0
    while index < inspectorFields.count {
      
      let inspector = inspectorFields[index].property.inspector
      let stackView = pnlInspectorStackView[inspector]!.stackView!
                       
      stackView.alignment = .right

      while index < inspectorFields.count && inspectorFields[index].property.inspector == inspector {
        
        let group = inspectorFields[index].property.group
        
        var showGroupHeader = true
        var showGroupSeparator = false
        
        while index < inspectorFields.count && inspectorFields[index].property.group == group {
          
          let field = inspectorFields[index]
          
          if commonProperties.contains(field.property) {
            
            if showGroupHeader {
              stackView.addArrangedSubview(inspectorGroupFields[group]!.view!)
              showGroupHeader = false
              showGroupSeparator = true
            }
            
            stackView.addArrangedSubview(field.view!)
            
            /// Note to self: Views within a StackView must not have constraints to the outside world as this will lock the StackView size.
            /// They must only have internal constraints to the view that is added to the StackView.
            ///  https://manasaprema04.medium.com/autolayout-fundamental-522f0a6e5790
            
            if field.property.controlType == .panelView {
              
              if let stackView = field.view as? NSStackView {
                
                for item in stackView.arrangedSubviews {
                  if let view = item as? SwitchboardSpeedProfilerView {
                    let x = CGFloat(view.cellsHigh) / CGFloat(view.cellsWide)
                    inspectorConstraints.append(view.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: x))
                    view.speedProfile = profile
                    view.backgroundColor = NSColor.black.cgColor
                  }
                }
                
              }
              
            }
            else {
              inspectorConstraints.append(field.view!.heightAnchor.constraint(greaterThanOrEqualTo: field.label!.heightAnchor))
              inspectorConstraints.append(field.view!.heightAnchor.constraint(greaterThanOrEqualTo: field.control!.heightAnchor))
              inspectorConstraints.append(field.control!.leadingAnchor.constraint(equalToSystemSpacingAfter: field.label!.trailingAnchor, multiplier: 1.0))
              inspectorConstraints.append(field.label!.leadingAnchor.constraint(equalTo: field.view!.leadingAnchor, constant: 20))
              
              inspectorConstraints.append(field.control!.widthAnchor.constraint(greaterThanOrEqualToConstant: 100))
              inspectorConstraints.append(field.view!.trailingAnchor.constraint(equalTo: field.control!.trailingAnchor))
              
              inspectorConstraints.append(field.control!.centerYAnchor.constraint(equalTo: field.view!.centerYAnchor))
              inspectorConstraints.append(field.label!.centerYAnchor.constraint(equalTo: field.view!.centerYAnchor))
              
              usedFields.append(field)
              
              if field.property == .route {
                if let comboBox = field.control as? NSComboBox {
                  comboBox.target = nil
                  comboBox.action = nil
                  appNode.layout?.populateLoop(comboBox: comboBox , startBlockId: profile.startBlockId)
                  comboBox.target = self
                  comboBox.action = #selector(cboAction(_:))
                }
              }
              
              setValue(field: field)
              
            }
            
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
    
    NSLayoutConstraint.activate(inspectorConstraints)
    
  }
  
  private func setValue(field:SpeedProfilerInspectorPropertyField) {
    
    guard let profile else {
      return
    }
    
    let value = profile.getValue(property: field.property)
    
    switch field.property.controlType {
    case .textField:
      (field.control as? NSTextField)?.stringValue = value
    case .label:
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
    case .eventId:
      (field.control as? NSTextField)?.stringValue = value
    case .panelView:
      break
    }

  }


  // MARK: Private Properties
  
  private var observerId : Int?
  
  private var locomotiveLookup : [String:UInt64] = [:]
  
  private var profile : SpeedProfile?
  
  private var sampleTable : [[Double]] = []
  
  private var columnIds : [NSUserInterfaceItemIdentifier] = []
    
  // MARK: Controls
  
  private var cboLocomotive : MyComboBox? = MyComboBox()
  
  private var sptSplitView : NSSplitView? = NSSplitView()
  
  private var pnlDisclosure : NSView? = NSView()
  
  private var pnlButtons : NSView? = NSView()
  
  private var btnReset : NSButton? = NSButton()
  
  private var btnDiscardChanges : NSButton? = NSButton()
  
  private var btnSaveChanges : NSButton? = NSButton()
  
  private var btnStartStop : NSButton? = NSButton()
  
  private var btnShowValuesPanel : NSButton? = MyIcon.bottomThird.button(target: nil, action: nil)
  
  private var btnShowInspectorPanel : NSButton? = MyIcon.trailingThird.button(target: nil, action: nil)
  
  private var sptResultsView : NSSplitView? = NSSplitView()
  
  private var pnlChart : SpeedResultsView? = SpeedResultsView()
  
  private var pnlValues : NSView? = NSView()
  
  private var cboValueTypes : MyComboBox? = MyComboBox()
  
  private var pnlInspector : NSView? = NSView()
  
  private var pnlValuesScrollView : NSScrollView? = NSScrollView()
  
  private var tblValuesTableView : NSTableView? = NSTableView()
  
  private var tblValuesColumns : [NSTableColumn?] = []
  
  private var pnlInspectorStackView : [SpeedProfilerInspector:ScrollVerticalStackView] = [:]
  
  private var pnlInspectorButtons : NSView? = NSView()
  
  internal var inspectorFields : [SpeedProfilerInspectorPropertyField] = []
  
  internal var inspectorGroupFields : [SpeedProfilerInspectorGroup:SpeedProfilerInspectorGroupField] = [:]
  
  internal var inspectorGroupSeparators : [SpeedProfilerInspectorGroup:SpeedProfilerInspectorGroupField] = [:]
  
  internal var inspectorConstraints : [NSLayoutConstraint] = []
  
  // MARK: Public Properties
  
  public var configurationTool : OpenLCBNodeConfigurationTool?
  
  // MARK: Private Methods
  
  // MARK: Actions
  
  @objc public func btnShowValuesPanelAction(_ sender:NSButton) {
    
    if sender.state == .on {
      pnlChart?.isHidden = true
      btnShowValuesPanel?.contentTintColor = nil
      btnShowValuesPanel?.toolTip = String(localized: "Show the Chart Area")
    }
    else {
      pnlChart?.isHidden = false
      btnShowValuesPanel?.contentTintColor = NSColor.systemBlue
      btnShowValuesPanel?.toolTip = String(localized: "Hide the Chart Area")
    }
    
    userSettings?.set(sender.state, forKey: DEFAULT.SHOW_VALUES_VIEW)

  }

  @objc public func btnShowInspectorPanelAction(_ sender:NSButton) {
    
    if sender.state == .on {
      pnlInspector?.isHidden = true
      btnShowInspectorPanel?.contentTintColor = nil
      btnShowInspectorPanel?.toolTip = String(localized: "Show the Inspector Area")
    }
    else {
      pnlInspector?.isHidden = false
      btnShowInspectorPanel?.contentTintColor = NSColor.systemBlue
      btnShowInspectorPanel?.toolTip = String(localized: "Hide the Inspector Area")
    }
    
    userSettings?.set(sender.state, forKey: DEFAULT.SHOW_SETTINGS_VIEW)

  }
  
  @objc public func cboValueTypesAction(_ sender:NSComboBox) {
    valueType = SpeedProfilerValueType.selected(comboBox: sender) ?? .actualSamples
    userSettings?.set(valueType.rawValue, forKey: DEFAULT.CURRENT_VALUES_MODE)
  }
  
  @objc public func btnInspectorAction(_ sender:NSButton) {
    
    if let item = SpeedProfilerInspector(rawValue: sender.tag) {
      currentInspector = item
    }
    
  }
  
  @objc func cboLocomotiveAction(_ sender:NSComboBox) {
    
    if let value = sender.objectValueOfSelectedItem as? String, let nodeId = locomotiveLookup[value] {
      profile = SpeedProfile(nodeId: nodeId)
      profile?.delegate = self
      sampleTable = profile!.getSampleTable()
      tblValuesTableView?.reloadData()
      displayInspector()
    }
    
  }
  
  @objc func cboAction(_ sender: NSComboBox) {
    
    if let profile, let property = SpeedProfilerInspectorProperty(rawValue: sender.tag) {
      
      if sender.indexOfSelectedItem >= 0, let string = sender.itemObjectValue(at: sender.indexOfSelectedItem) as? String {
        
        profile.setValue(property: property, string: string)
                
      }
      else {
        profile.setValue(property: property, string: "")
      }
      
      if property == .route {
        for item in inspectorFields {
          if item.property == .totalRouteLength {
            setValue(field: item)
          }
          else if item.property == .routeSegments {
            if let view = item.view as? NSStackView {
              for temp in view.arrangedSubviews {
                if let panel = temp as? SwitchboardSpeedProfilerView {
                  panel.needsDisplay = true
                }
              }
            }
          }
        }
      }

    }
    
  }

  @objc func chkAction(_ sender: NSButton) {

    if let profile, let property = SpeedProfilerInspectorProperty(rawValue: sender.tag) {
      profile.setValue(property: property, string: sender.state == .on ? "true" : "false")
    }
    
  }
  
  @objc func btnResetToDefaultsAction(_ sender:NSButton) {
    profile?.resetTable()
  }

  @objc func btnDiscardChangesAction(_ sender:NSButton) {
    guard let profile else {
      return
    }
    sampleTable = profile.getSampleTable()
    tblValuesTableView?.reloadData()
  }
  
  @objc func btnSaveChangesAction(_ sender:NSButton) {
    profile?.setSampleTable(sampleTable: sampleTable)
    debugLog("Here")
  }
  
  // MARK: MyTrainsAppDelegate Methods
  
  @objc func locomotiveListUpdated(appNode:OpenLCBNodeMyTrains) {
    
    guard let cboLocomotive else {
      return
    }
    
    let value = cboLocomotive.objectValueOfSelectedItem
    
    cboLocomotive.removeAllItems()
    
    locomotiveLookup.removeAll()
    
    var list : [String] = []
    
    for (key, item) in appNode.locomotiveList {
      list.append(item)
      locomotiveLookup[item] = key
    }
    
    list.sort {$0 < $1}
    
    cboLocomotive.addItems(withObjectValues: list)
    
    cboLocomotive.selectItem(withObjectValue: value)
    
   }

  // MARK: NSTableViewDelegate Methods
  
  // Returns the number of records managed for aTableView by the data source object.
   public func numberOfRows(in tableView: NSTableView) -> Int {
     return sampleTable.count
   }
  
  // Sets the data object for an item in the specified row and column.
  public func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
  }
  
  public func tableView(_ tableView: NSTableView,
                        viewFor tableColumn: NSTableColumn?,row: Int) -> NSView? {
    
    let item = sampleTable[row]
    
    var isEditable = false

    let text = NSTextField()
    
    let formatter = NumberFormatter()
    formatter.alwaysShowsDecimalSeparator = true
    formatter.maximumFractionDigits = 3
    formatter.minimumFractionDigits = 3
    formatter.numberStyle = .decimal
    
    switch tableColumn!.identifier {
    case columnIds[0]:
      text.stringValue = "\(row)"
    case columnIds[1]:
      let value = UnitSpeed.convert(fromValue: item[0], fromUnits: .defaultValueScaleSpeed, toUnits: appNode!.unitsScaleSpeed)
      text.stringValue = formatter.string(from: NSNumber(value: value)) ?? ""
    case columnIds[2]:
      let value = UnitSpeed.convert(fromValue: item[1], fromUnits: .defaultValueScaleSpeed, toUnits: appNode!.unitsScaleSpeed)
      text.stringValue = (item[1] == 0.0 && row > 0) ? "?" : formatter.string(from: NSNumber(value: value)) ?? ""
      isEditable = true
      text.delegate = self
      text.tag = 1000 + row
    case columnIds[3]:
      let value = UnitSpeed.convert(fromValue: item[1] - item[0], fromUnits: .defaultValueScaleSpeed, toUnits: appNode!.unitsScaleSpeed)
      text.stringValue = (item[1] == 0.0 && row > 0) ? "?" :  formatter.string(from: NSNumber(value: value)) ?? ""
    case columnIds[4]:
      let value = UnitSpeed.convert(fromValue: item[2], fromUnits: .defaultValueScaleSpeed, toUnits: appNode!.unitsScaleSpeed)
      text.stringValue = (item[2] == 0.0 && row > 0) ? "?" :  formatter.string(from: NSNumber(value: value)) ?? ""
      isEditable = true
      text.delegate = self
      text.tag = 2000 + row
    case columnIds[5]:
      let value = UnitSpeed.convert(fromValue: item[2] - item[0], fromUnits: .defaultValueScaleSpeed, toUnits: appNode!.unitsScaleSpeed)
      text.stringValue = (item[2] == 0.0 && row > 0) ? "?" :  formatter.string(from: NSNumber(value: value)) ?? ""
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
    
    if let textField = control as? NSTextField, let profile {
      
      let trimmed = textField.stringValue.trimmingCharacters(in: .whitespaces)
      
      if let property = SpeedProfilerInspectorProperty(rawValue: textField.tag) {
        
        isValid = profile.isValid(property: property, string: trimmed)
        
        if isValid {
          profile.setValue(property: property, string: trimmed)
        }
        
      }
      else {
        let row = textField.tag % 1000
        let column = textField.tag / 1000
        if trimmed == "?" {
          sampleTable[row][column] = 0.0
        }
        else {
          if let value = Double(trimmed), value >= 0.0 {
            sampleTable[row][column] = UnitSpeed.convert(fromValue: value, fromUnits: appNode!.unitsScaleSpeed, toUnits: .defaultValueScaleSpeed)
          }
          else {
            isValid = false
          }
        }
        tblValuesTableView?.reloadData()
      }
 
    }
    
    return isValid
    
  }

  // MARK: SpeedProfileDelegate Methods
  
  @objc func inspectorNeedsUpdate(profile:SpeedProfile) {
    displayInspector()
  }
  
  @objc func tableNeedsUpdate(profile:SpeedProfile) {
    tblValuesTableView?.reloadData()
  }
  
  @objc func chartNeedsUpdate(profile:SpeedProfile) {
    
  }

  @objc func reloadSamples(profile:SpeedProfile) {
    sampleTable = profile.getSampleTable()
    tblValuesTableView?.reloadData()
  }

  // MARK: MyTrainsAppDelegate Methods
  
  func panelUpdated(panel:SwitchboardPanelNode) {
    for item in inspectorFields {
      if item.property == .routeSegments {
        if let view = item.view as? NSStackView {
          for temp in view.arrangedSubviews {
            if let panel = temp as? SwitchboardSpeedProfilerView {
              panel.needsDisplay = true
            }
          }
        }
      }
    }
  }

}


