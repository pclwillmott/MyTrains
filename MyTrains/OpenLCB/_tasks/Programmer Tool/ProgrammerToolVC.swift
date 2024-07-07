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

    NSLayoutConstraint.deactivate(settingsConstraints)
    settingsConstraints.removeAll()

    NSLayoutConstraint.deactivate(constraints)
    constraints.removeAll()
    
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
  
  private var cboProgrammingTrack : MyComboBox? = MyComboBox()
  
  private var pnlInspectorButtons : NSView? = NSView()
  
  private var pnlInspectorView : [ProgrammerToolInspector:NSView] = [:]
  
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
      
      var inspectorPanel : NSView?
      
      switch item {
      case .identity, .quickHelp, .sound:
        inspectorPanel = ScrollVerticalStackView()
        if let stackView = inspectorPanel as? ScrollVerticalStackView {
          stackView.backgroundColor = NSColor.clear.cgColor
          stackView.stackView?.orientation = .vertical
          stackView.stackView?.spacing = 4
        }
      case .changedCVs:
        
        inspectorPanel = changedCVsScrollView
        
        if let scrollView = inspectorPanel as? NSScrollView {
          scrollView.documentView = lblChangedCVs
          lblChangedCVs.translatesAutoresizingMaskIntoConstraints = false
          lblChangedCVs.maximumNumberOfLines = 0
          lblChangedCVs.lineBreakMode = .byWordWrapping
          lblChangedCVs.font = NSFont(name: "Menlo", size: 12)
          lblChangedCVs.stringValue = ""

          constraints.append(lblChangedCVs.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor))
          constraints.append(lblChangedCVs.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor))
          
        }
        
      case .rwCVs:
        inspectorPanel = NSView()
      case .settings:
        inspectorPanel = NSSplitView()
        if let splitView = inspectorPanel as? NSSplitView {
          splitView.isVertical = true
          splitView.arrangesAllSubviews = true
          selectorStackView.translatesAutoresizingMaskIntoConstraints = false
          splitView.addArrangedSubview(selectorStackView)
          pnlSettings.translatesAutoresizingMaskIntoConstraints = false
          splitView.addArrangedSubview(pnlSettings)
          userSettings?.splitView = splitView
        }
      }
      
      if let inspectorPanel {
        
        inspectorPanel.translatesAutoresizingMaskIntoConstraints = false
//        inspectorPanel.backgroundColor = item.backgroundColor
        
        pnlInspectorView[item] = inspectorPanel
        
        view.addSubview(inspectorPanel)
        
        constraints.append(inspectorPanel.topAnchor.constraint(equalToSystemSpacingBelow: pnlInspectorButtons.bottomAnchor, multiplier: 1.0))
        constraints.append(inspectorPanel.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1.0))
        constraints.append(view.trailingAnchor.constraint(equalToSystemSpacingAfter: inspectorPanel.trailingAnchor, multiplier: 1.0))
        constraints.append(view.bottomAnchor.constraint(equalToSystemSpacingBelow: inspectorPanel.bottomAnchor, multiplier: 1.0))
        
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
    
    NSLayoutConstraint.activate(constraints)

    currentInspector = ProgrammerToolInspector(rawValue: userSettings!.integer(forKey: DEFAULT.PROGRAMMER_TOOL_CURRENT_INSPECTOR)) ?? .quickHelp

    currentSelector = ProgrammerToolSettingsGroup(rawValue: userSettings!.integer(forKey: DEFAULT.PROGRAMMER_TOOL_CURRENT_SELECTOR)) ?? .address

    tableView.delegate = self
    tableView.dataSource = self
    
    decoder = Decoder(decoderType: .lokSound5)
    decoder?.delegate = self
    
    displaySettings()
    
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
      
    }
    
    return isValid
    
  }

  // MARK: DecoderDelegate Methods
  
  @objc func reloadData(_ decoder : Decoder) {
    tableView?.reloadData()
    lblChangedCVs?.stringValue = decoder.cvTextList(list: decoder.cvsModified)
  }

}
