//
//  SpeedProfilerVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 01/08/2022.
//

import Foundation
import AppKit

private enum SpeedProfilerState {

  // MARK: Enumeration
  
  case idle
  case settingTurnouts
  case connectingToLoco
  case initializing
  case gettingUpToSpeed
  case sampling
  
}

class SpeedProfilerVC: MyTrainsViewController, OpenLCBThrottleDelegate, NSTableViewDataSource, NSTableViewDelegate, MyTrainsAppDelegate, NSTextFieldDelegate, NSControlTextEditingDelegate, SpeedProfileDelegate {
  
  // MARK: Window & View Control
  
  deinit {
    
    constraints.removeAll()
    
    inspectorConstraints.removeAll()
    
    cboLocomotive?.removeAllItems()
    cboLocomotive = nil
    
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
    
    lblStatus = nil
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewType = .speedProfiler
  }
  
  override func windowWillClose(_ notification: Notification) {
    
    if let throttle {
      throttle.delegate = nil
      appDelegate.networkLayer?.releaseThrottle(throttle: throttle)
      self.throttle = nil
    }
    
    if let observerId, let appNode {
      appNode.removeObserver(observerId: observerId)
    }
    
    super.windowWillClose(notification)
    
  }
  
  override func viewWillAppear() {
    
    super.viewWillAppear()
    
    guard let cboLocomotive, let sptSplitView, let pnlDisclosure, let pnlButtons, let btnReset, let btnDiscardChanges, let btnSaveChanges, let btnStartStop, let btnShowValuesPanel, let btnShowInspectorPanel, let pnlChart, let pnlValues, let pnlInspector, let pnlValuesScrollView, let tblValuesTableView, let pnlInspectorButtons, let sptResultsView, let lblStatus else {
      return
    }
    
    appNode?.layout?.linkSwitchboardItems()
    
    formatter.alwaysShowsDecimalSeparator = true
    formatter.maximumFractionDigits = 3
    formatter.minimumFractionDigits = 3
    formatter.numberStyle = .decimal

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
    
    pnlValuesScrollView.translatesAutoresizingMaskIntoConstraints = false
    pnlValuesScrollView.backgroundColor = nil
    pnlValuesScrollView.drawsBackground = false
    pnlValuesScrollView.hasVerticalScroller = true
    pnlValuesScrollView.hasHorizontalScroller = true
    pnlValuesScrollView.autoresizesSubviews = true
    
    pnlValues.addSubview(pnlValuesScrollView)
    
    constraints.append(pnlValuesScrollView.topAnchor.constraint(equalTo: pnlValues.topAnchor))
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
    
    lblStatus.translatesAutoresizingMaskIntoConstraints = false
    lblStatus.alignment = .center
    lblStatus.drawsBackground = false
    
    pnlDisclosure.addSubview(lblStatus)
    
    constraints.append(lblStatus.centerXAnchor.constraint(equalTo: pnlDisclosure.centerXAnchor))
    constraints.append(lblStatus.centerYAnchor.constraint(equalTo: pnlDisclosure.centerYAnchor))
    
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
    btnStartStop.target = self
    btnStartStop.action = #selector(btnStartProfilingAction(_:))
    
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
  
  private var state : SpeedProfilerState = .idle {
    didSet {
      switch state {
      case .initializing:
        lblStatus?.stringValue = String(localized: "Initializing")
      case .idle:
        throttle?.speed = isForward ? 0.0 : -0.0
        throttle?.releaseController()
        btnStartStop?.title = String(localized: "Start Profiling")
        lblStatus?.stringValue = ""
      default:
        btnStartStop?.title = String(localized: "Stop Profiling")
      }
    }
  }
  
  private var retryCount = 0
  
  private var nextSampleNumber : UInt16 = 0
  
  private var sampleOnNextEvent = false
  
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
      .useRFIDReaders,
      .useLightSensors,
      .useReedSwitches,
      .useOccupancyDetectors,
      .routeType,
      .startBlockId,
      .totalRouteLength,
      .routeSegments,
      .profilerMode,
    ]
    
    if profile.speedProfilerMode == .sampleAllSpeeds {
      commonProperties.insert(.startSampleNumber)
      commonProperties.insert(.stopSampleNumber)
      commonProperties.insert(.bestFitMethod)
      commonProperties.insert(.showTrendline)
      commonProperties.insert(.showSamples)
      commonProperties.insert(.directionToChart)
      commonProperties.insert(.colourForward)
      commonProperties.insert(.colourReverse)
    }
    else {
      commonProperties.insert(.commandedSampleNumber)
    }
    
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
              else if field.property == .commandedSampleNumber {
                if let comboBox = field.control as? NSComboBox {
                  comboBox.target = nil
                  comboBox.action = nil
                  comboBox.removeAllItems()
                  for sample in 0 ... profile.numberOfSamples - 1 {
                    comboBox.addItem(withObjectValue: profile.commandedSampleTitle(sampleNumber: sample))
                  }
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
    case .readCV:
      break
    case .writeCV:
      break
    case .bits8:
      break
    }
    
  }
  
  // MARK: Private Properties
  
  private var observerId : Int?
  
  private var locomotiveLookup : [String:UInt64] = [:]
  
  private var profile : SpeedProfile? {
    didSet {
      pnlChart?.speedProfile = profile
    }
  }
  
  private var sampleTable : [[Double]] = [] {
    didSet {
      pnlChart?.sampleTable = sampleTable
    }
  }
  
  private var isForward = true
  
  private var currentDirection : RouteDirection = .next
  
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
  
  internal var lblStatus : NSTextField? = NSTextField(labelWithString: "")
  
  private var timeoutTimer : Timer?
  
  private var next     : [UInt64:(eventId:UInt64, eventType:SpeedProfilerEventType, position:Double, index:Int)] = [:]
  private var previous : [UInt64:(eventId:UInt64, eventType:SpeedProfilerEventType, position:Double, index:Int)] = [:]
  
  private var eventsTriggeredList : [UInt64] = []
  
  private var eventsTriggered : Set<UInt64> = []
  
//  private var thisLoop : Double = 0.0
  
  private var routeLength : Double = 0.0
  
  private var completedLoopsDistance : Double = 0.0
  
  private var distanceAtStart : Double = 0.0
  
  private var currentPositionInLoop : Double = 0.0
  
  private var distanceCompleted : Double = 0.0
  
  private var sampleStartPosition : Double = 0.0
  
  private var sampleStartTime : TimeInterval = 0.0
  
  private var takeSampleNow = false
  
  private var totalSpeed : Double = 0.0
  
  private var averageSamples : Double = 0.0
  
  private var routeSetNext : SWBRoute?
  
  private var routeSetPrevious : SWBRoute?
  
  private let formatter = NumberFormatter()
  
  // MARK: Public Properties
  
  public var throttle : OpenLCBThrottle?
  
  // MARK: Private Methods
  
  @objc func timeoutTimerAction() {
    
    guard let profile else {
      stopTimeoutTimer()
      state = .idle
      return
    }
    
    switch state {
      
    case .idle:
      
      stopTimeoutTimer()
      
    case .settingTurnouts:
      
      retryCount -= 1
      
      if retryCount == 0 {
        
        stopTimeoutTimer()
        
        let alert = NSAlert()
        
        alert.messageText = String(localized: "Route Set Failed")
        alert.informativeText = String(localized: "One or more turnouts failed to set correctly.")
        alert.addButton(withTitle: String(localized: "OK"))
        alert.alertStyle = .informational
        
        alert.runModal()
        
        state = .idle
        
      }
      else if let routeSetNext, let routeSetPrevious {
        
        for item in routeSetNext {
          if item.fromSwitchboardItem.itemType.isTurnout && !item.fromSwitchboardItem.isRouteConsistent {
            return
          }
        }
        
        stopTimeoutTimer()
        
        // TODO: Setup Event & Distance Table
        
        var index = 0
        
        routeLength = 0.0

        next.removeAll()
                
        for item in routeSetNext {
          
          if let blockLength = item.fromSwitchboardItem.lengthOfRoute {
            
            for event in item.fromSwitchboardItem.getEventsForProfiler(profile: profile) {
              let position = routeLength + (event.eventType == .sensor ? event.position : 0.0)
              next[event.eventId] = (event.eventId, event.eventType, position, index)
              index += 1
            }
            
            routeLength += blockLength
            
          }
          
        }
        
        index = 0
        
        routeLength = 0.0
        
        previous.removeAll()
        
        for item in routeSetPrevious {
          
          if let blockLength = item.fromSwitchboardItem.lengthOfRoute {
            
            for event in item.fromSwitchboardItem.getEventsForProfiler(profile: profile).reversed() {
              let position = routeLength + ((event.eventType == .sensor ? blockLength - event.position : 0.0))
              previous[event.eventId] = (event.eventId, event.eventType, position, index)
              index += 1
            }
            
            routeLength += blockLength
            
          }
          
        }
        
        state = .connectingToLoco
        
        retryCount = 2
        
        startTimeoutTimer(interval: 0.5, repeats: true)
        
        throttle?.assignController(trainNodeId: profile.nodeId)
        
      }
      
    case .connectingToLoco:
      
      retryCount -= 1
      
      if retryCount == 0 {
        
        stopTimeoutTimer()
        
        let alert = NSAlert()
        
        alert.messageText = String(localized: "Connecting to Locomotive Failed")
        alert.informativeText = String(localized: "The throttle was unable to connect to the locomotive.")
        alert.addButton(withTitle: String(localized: "OK"))
        alert.alertStyle = .informational
        
        alert.runModal()
        
        state = .idle
        
        return
        
      }
      
    case .gettingUpToSpeed, .initializing:
      break
    case .sampling:
      takeSampleNow = true
    }
    
  }
  
  private func startTimeoutTimer(interval: TimeInterval, repeats:Bool = false) {
    timeoutTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(timeoutTimerAction), userInfo: nil, repeats: repeats)
    RunLoop.current.add(timeoutTimer!, forMode: .common)
  }
  
  private func stopTimeoutTimer() {
    timeoutTimer?.invalidate()
    timeoutTimer = nil
  }
  
  private func getNextSample() {

    takeSampleNow = false

    guard let profile, let throttle else {
      state = .idle
      return
    }
    
    if profile.speedProfilerMode == .sampleAllSpeeds {
      
      if nextSampleNumber > profile.stopSampleNumber {
        if !isForward || profile.locomotiveTravelDirection == .forward {
          state = .idle
          return
        }
        isForward = false
        currentDirection = currentDirection == .next ? .previous : .next
        nextSampleNumber = profile.startSampleNumber
      }
      
      nextSampleNumber = max(1, nextSampleNumber)
      
      state = .gettingUpToSpeed
      
      lblStatus?.stringValue = "Sample #\(nextSampleNumber): getting up to speed"
      
      let speed = Float(UnitSpeed.convert(fromValue: sampleTable[Int(nextSampleNumber)][0], fromUnits: .defaultValueScaleSpeed, toUnits: .metersPerSecond) * (isForward ? 1.0 : -1.0))
      
      throttle.speed = speed
    }
    else if state == .initializing {

      state = .gettingUpToSpeed
      
      lblStatus?.stringValue = "Sample #\(nextSampleNumber): getting up to speed"
      
      throttle.speed = Float(UnitSpeed.convert(fromValue: sampleTable[Int(nextSampleNumber)][0], fromUnits: .defaultValueScaleSpeed, toUnits: .metersPerSecond) * (isForward ? 1.0 : -1.0))
      
    }
    
  }
  
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
  }
  
  @objc func btnStartProfilingAction(_ sender:NSButton) {
    
    esuCVExtract()
    
    return
    
    guard let profile, let appNode, let layout = appNode.layout else {
      return
    }
    
    if state == .idle {
      
      guard let routeSet = profile.routeSetNext else {
        
        let alert = NSAlert()
        
        alert.messageText = String(localized: "Route Not Set")
        alert.informativeText = String(localized: "You have not set a route in the route inspector.")
        alert.addButton(withTitle: String(localized: "OK"))
        alert.alertStyle = .informational
        
        alert.runModal()
        
        return
        
      }
      
      state = .settingTurnouts
      
      for item in routeSet {
        item.fromSwitchboardItem.setRoute(route: item.turnoutConnection)
      }
      
      routeSetNext = profile.routeSetNext
      routeSetPrevious = profile.routeSetPrevious
      
      retryCount = 10
      startTimeoutTimer(interval: 1.0, repeats: true)
      
    }
    else {
      state = .idle
    }
    
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
    pnlChart?.needsDisplay = true
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
  
  // MARK: OpenLCBThrottleDelegate Methods
  
  @objc func trainSearchResultsReceived(throttle:OpenLCBThrottle, results:[UInt64:String]) {
    /*
     cboLocomotive.selectItem(at: -1)
     cboLocomotiveDS.dictionary = results
     cboLocomotive.reloadData()
     if !results.isEmpty && throttle.throttleState == .idle {
     cboLocomotive.selectItem(at: 0)
     }
     */
  }
  
  @objc func speedChanged(throttle:OpenLCBThrottle, speed:Float) {
    
    let smps2mph : Float = 3600.0 / (1000.0 * 1.609344)
    
    let _speed = speed * smps2mph
    
    //    vsThrottle.floatValue = abs(_speed)
    
    //    lblSpeed.stringValue = String(format: "%.0f", vsThrottle.floatValue)
    
    //    lblCurrentSpeed.stringValue = String(format: "%.1f", vsThrottle.floatValue)
    
    let minusZero : Float = -0.0
    
    let isReverse = speed.bitPattern == minusZero.bitPattern || speed < 0.0
    
    //  radForward.state = isReverse ? .off : .on
    //  radReverse.state = isReverse ? .on : .off
    
  }
  
  @objc func throttleStateChanged(throttle:OpenLCBThrottle) {
    
    if state == .connectingToLoco, let trainNode = throttle.trainNode, throttle.throttleState == .activeController, let profile {
      stopTimeoutTimer()
      state = .initializing
      if profile.locomotiveTravelDirection == .reverse {
        isForward = false
        currentDirection = profile.locomotiveFacingDirection == .next ? .previous : .next
      }
      else {
        isForward = true
        currentDirection = profile.locomotiveFacingDirection == .next ? .next : .previous
      }
      let sample = profile.speedProfilerMode == .sampleAllSpeeds ? profile.startSampleNumber : profile.commandedSampleNumber
      throttle.speed = Float(UnitSpeed.convert(fromValue: sampleTable[Int(sample)][0] * (isForward ? 1.0 : -1.0), fromUnits: .defaultValueScaleSpeed, toUnits: .metersPerSecond))

    }
    
  }
  
  @objc func eventReceived(throttle:OpenLCBThrottle, message:OpenLCBMessage) {
  
    let interestingStates : Set<SpeedProfilerState> = [
      .initializing,
      .gettingUpToSpeed,
      .sampling,
    ]
    
    guard interestingStates.contains(state), let profile, message.messageTypeIndicator == .producerConsumerEventReport, let eventId = message.eventId, let layout = appNode?.layout else {
      return
    }
    
    var event : (eventId:UInt64, eventType:SpeedProfilerEventType, position:Double, index:Int)?
    
    switch currentDirection {
    case .next:
      event = next[eventId]
    case .previous:
      event = previous[eventId]
    }
    
    if let event {
      
      if event.eventType == .occupancy {
        
        eventsTriggered.insert(eventId)
        eventsTriggeredList.append(eventId)
        
        while eventsTriggeredList.count > 2 {
          eventsTriggered.remove(eventsTriggeredList.removeFirst())
        }
        
      }
      
      if state == .initializing {
        if event.index == 0 {
          distanceCompleted = 0.0
          currentPositionInLoop = 0.0
          completedLoopsDistance = 0.0
          nextSampleNumber = profile.speedProfilerMode == .sampleAllSpeeds ?  profile.startSampleNumber : profile.commandedSampleNumber
          getNextSample()
          return
        }
      }
      else {
        
        if event.index == 0 {
          completedLoopsDistance += routeLength
          currentPositionInLoop = 0.0
        }
        else {
          currentPositionInLoop = event.position
        }
        
      }
      
      distanceCompleted = completedLoopsDistance + currentPositionInLoop
      
      if profile.speedProfilerMode == .sampleAllSpeeds {
        
        if state == .gettingUpToSpeed {
          sampleStartTime = message.timeStamp
          sampleStartPosition = distanceCompleted
          state = .sampling
          startTimeoutTimer(interval: profile.minimumSamplePeriod.samplePeriod)
          lblStatus?.stringValue = "Sample #\(nextSampleNumber): sampling"
        }
        else if state == .sampling && takeSampleNow {
          let distance = distanceCompleted - sampleStartPosition
          let time = message.timeStamp - sampleStartTime
          let speed = UnitSpeed.convert(fromValue: distance / time, fromUnits: .centimetersPerSecond, toUnits: .defaultValueScaleSpeed) * layout.scale.ratio
          sampleTable[Int(nextSampleNumber)][isForward ? 1 : 2] = speed
          tblValuesTableView?.reloadData()
          nextSampleNumber += 1
          getNextSample()
        }
        
      }
      else {
 
        if state == .gettingUpToSpeed {
          sampleStartTime = message.timeStamp
          sampleStartPosition = distanceCompleted
          state = .sampling
          totalSpeed = 0.0
          averageSamples = 0.0
          startTimeoutTimer(interval: profile.minimumSamplePeriod.samplePeriod)
          lblStatus?.stringValue = "Sampling"
        }
        else if state == .sampling && takeSampleNow {
          takeSampleNow = false
          let distance = distanceCompleted - sampleStartPosition
          let time = message.timeStamp - sampleStartTime
          let speed = UnitSpeed.convert(fromValue: distance / time, fromUnits: .centimetersPerSecond, toUnits: appNode!.unitsScaleSpeed) * layout.scale.ratio
          totalSpeed += speed
          averageSamples += 1
          var result = "Last Sample: \(formatter.string(from: NSNumber(value: speed))!) \(appNode!.unitsScaleSpeed.symbol)"
          if averageSamples > 1.0 {
            result += "   Average of \(Int(round(averageSamples))) Samples: \(formatter.string(from: NSNumber(value: totalSpeed / averageSamples))!) \(appNode!.unitsScaleSpeed.symbol)"
          }
          lblStatus?.stringValue = result
          if profile.commandedSampleNumber == nextSampleNumber {
            sampleStartTime = message.timeStamp
            sampleStartPosition = distanceCompleted
            startTimeoutTimer(interval: profile.minimumSamplePeriod.samplePeriod)
          }
          else {
            state = .initializing
          }
        }

      }
      
    }
    
  }

}


