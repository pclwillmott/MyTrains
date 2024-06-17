//
//  SpeedProfilerVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 01/08/2022.
//

import Foundation
import AppKit

class SpeedProfilerVC: MyTrainsViewController, OpenLCBConfigurationToolDelegate, NSTableViewDataSource, NSTableViewDelegate {
 
  // MARK: Window & View Control

  deinit {
  
    constraints.removeAll()
    
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
    
    super.windowWillClose(notification)

  }
  
  override func viewWillAppear() {
    
    super.viewWillAppear()
    
    guard let cboLocomotive, let sptSplitView, let pnlDisclosure, let pnlButtons, let btnReset, let btnDiscardChanges, let btnSaveChanges, let btnStartStop, let btnShowValuesPanel, let btnShowInspectorPanel, let pnlChart, let pnlValues, let cboValueTypes, let pnlInspector, let pnlValuesScrollView, let tblValuesTableView, let pnlInspectorButtons, let sptResultsView else {
      return
    }
    
    for index in 0 ... 50 {
      test.append(index)
    }
    
    // cboLocomotive
    
    cboLocomotive.translatesAutoresizingMaskIntoConstraints = false
    
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
      String(localized:"Commanded"),
      String(localized:"Forward"),
      String(localized:"δ Forward"),
      String(localized:"Reverse"),
      String(localized:"δ Reverse"),
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
      tblValuesColumns.append(NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: columnNames[index])))
      if let column = tblValuesColumns[index] {
        column.minWidth = 60
        tblValuesTableView.addTableColumn(column)
        column.headerCell.alignment = .left
        column.title = columnTitles[index]
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
    
    pnlInspector.translatesAutoresizingMaskIntoConstraints = false
    pnlInspector.backgroundColor = NSColor.white.cgColor
    
    sptSplitView.addArrangedSubview(pnlInspector)
    
    pnlInspectorButtons.translatesAutoresizingMaskIntoConstraints = false
    
    pnlInspector.addSubview(pnlInspectorButtons)
    
    constraints.append(pnlInspector.widthAnchor.constraint(greaterThanOrEqualTo: pnlInspectorButtons.widthAnchor))
    
    constraints.append(pnlInspectorButtons.centerXAnchor.constraint(equalTo: pnlInspector.centerXAnchor))
    constraints.append(pnlInspectorButtons.topAnchor.constraint(equalToSystemSpacingBelow: pnlInspector.topAnchor, multiplier: 1.0))
    
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
      stackView.backgroundColor = item.backgroundColor
      
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
    
    pnlButtons.addSubview(btnReset)
    
    constraints.append(btnReset.centerYAnchor.constraint(equalTo: pnlButtons.centerYAnchor))
    constraints.append(btnReset.leadingAnchor.constraint(equalTo: pnlButtons.leadingAnchor))
    
    btnDiscardChanges.translatesAutoresizingMaskIntoConstraints = false
    btnDiscardChanges.title = String(localized: "Discard Changes")
    
    pnlButtons.addSubview(btnDiscardChanges)
    
    constraints.append(btnDiscardChanges.centerYAnchor.constraint(equalTo: pnlButtons.centerYAnchor))
    constraints.append(btnDiscardChanges.leadingAnchor.constraint(equalToSystemSpacingAfter: btnReset.trailingAnchor, multiplier: 1.0))

    btnSaveChanges.translatesAutoresizingMaskIntoConstraints = false
    btnSaveChanges.title = String(localized: "Save Changes")

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
  
  // MARK: Public Properties
  
  public var configurationTool : OpenLCBNodeConfigurationTool?
  
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
    
    if let item = SpeedProfilerInspector(rawValue: sender.tag), let pnlInspectorButtons {
      currentInspector = item
    }
    
  }
  
  // MARK: ValuesTableView Datasource
  
  public var test : [Int] = []
    
  // MARK: NSTableViewDataSource Delegate Methods
  
  // MARK: NSTableViewDelegate Methods
  
  // Returns the number of records managed for aTableView by the data source object.
   public func numberOfRows(in tableView: NSTableView) -> Int {
     return test.count
   }
  
  // Sets the data object for an item in the specified row and column.
  public func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
  }
  
  public func tableView(_ tableView: NSTableView,
                        viewFor tableColumn: NSTableColumn?,row: Int) -> NSView? {
    
    let item = test[row]
    
    let columnName = tableColumn!.title
    
    let isEditable = columnName != "Step"

    let text = NSTextField()
    text.stringValue = "\(item)"
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

}


