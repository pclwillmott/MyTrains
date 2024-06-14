//
//  SwitchboardEditorVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 13/04/2024.
//

import Foundation
import AppKit

class LayoutBuilderVC: MyTrainsViewController, SwitchboardEditorViewDelegate, NSTextFieldDelegate, MyTrainsAppDelegate, NSControlTextEditingDelegate {
  
  // MARK: Window & View Methods
  
  override func windowWillClose(_ notification: Notification) {
    
    appNode?.removeObserver(observerId: appObserverId)
    
    NSLayoutConstraint.deactivate(constraints)
    
    constraints.removeAll()
    
    inspectorConstraints.removeAll()
    
    releaseInspectorAreaControls()
    releasePanelAreaControls()
    releasePaletteGroupingAreaControls()
    releasePanelConfigAreaControls()
    releaseGeneralAreaControls()

    super.windowWillClose(notification)
    
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    viewType = .layoutBuilder
  }
  
  override func viewDidDisappear() {
    if isManualClose {
 //     appDelegate.rebootRequest()
    }
  }

  override func viewWillAppear() {
    
    super.viewWillAppear()
    
    setupGeneralAreaControls()
    setupPanelConfigArea()
    setupPaletteGroupingArea()
    setupPanelArea()
    setupInspectorArea()
    
    userSettings?.node = switchboardPanel
    
    NSLayoutConstraint.activate(constraints)
    
    arrangeView?.isHidden = true

    if let quickHelpView, let lblQuickHelp, let lblQuickHelpSummary, let lblQuickHelpSummaryText, let lblQuickHelpDiscussion, let lblQuickHelpDiscussionText, let sepQuickHelpSummary {
      
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

    }

    self.cboPanel?.target = self
    self.cboPanel?.action = #selector(self.cboPanelAction(_:))
    
    appObserverId = appNode!.addObserver(observer: self)
 
  }
  
  // MARK: Private Properties
  
  private var inspectorConstraints : [NSLayoutConstraint] = []
  
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
      
      let selectedItem = cboPanel.objectValueOfSelectedItem
      
      cboPanel.removeAllItems()
      for item in panels {
        cboPanel.addItem(withObjectValue: item.userNodeName)
      }
      
      cboPanel.selectItem(withObjectValue: selectedItem)
      
      cboPanel.target = self
      
      if panels.isEmpty {
        btnNewPanelAction(btnNewPanel!)
      }
 
      if cboPanel.indexOfSelectedItem == -1, cboPanel.numberOfItems > 0 {
        cboPanel.selectItem(at: 0)
      }
      
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
      if let control = field.control {
        switch field.property {
        case .layoutId:
          control.stringValue = appNode.layout?.nodeId.toHexDotFormat(numberOfBytes: 6) ?? ""
        case .layoutName:
          control.stringValue = appNode.layout?.userNodeName ?? ""
        case .panelId:
          control.stringValue = switchboardPanel?.nodeId.toHexDotFormat(numberOfBytes: 6) ?? ""
        case .panelName:
          control.stringValue = switchboardPanel?.userNodeName ?? ""
        case .panelDescription:
          control.stringValue = switchboardPanel?.userNodeDescription ?? ""
        case .numberOfRows:
          control.integerValue = Int(switchboardPanel?.numberOfRows ?? 30)
        case .numberOfColumns:
          control.integerValue = Int(switchboardPanel?.numberOfColumns ?? 30)
        }
      }
    }
    
    appNode.populateGroup(comboBox: cboGroup!, panelId: switchboardPanel?.nodeId ?? 0)
    cboGroupAction(cboGroup!)
    
    switchboardView.needsDisplay = true

  }
  
  internal func displayInspector() {
    
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
          stackView.addArrangedSubview(inspectorNoSelection[index]!)
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
        stackView.addArrangedSubview(inspectorNotApplicable[index]!)
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
  
  // MARK: General Layout Builder Controls
  
  internal var btnShowInspectorView : NSButton?
  
  internal var btnShowPaletteView : NSButton?
  
  internal var btnShowPanelView : NSButton?
  
  internal var cboPanel : NSComboBox? = MyComboBox()
  
  internal var btnNewPanel : NSButton? = NSButton()
  
  internal var btnDeletePanel : NSButton? = NSButton()
 
  internal var constraints : [NSLayoutConstraint] = []
  
  internal var splitView : NSSplitView? = NSSplitView()
  
  internal var paletteView   : NSView? = NSView()
  
  internal var layoutView    : NSView? = NSView()
  
  internal var panelView : NSView? = NSView()
  
  internal var inspectorView : NSView? = NSView()
  
  internal var panels : [SwitchboardPanelNode] = []
  
  internal var appObserverId : Int = -1
  
  // MARK: Palette/Grouping Area Controls
  
  internal var arrangeButtons : [NSButton?] = []
  
  internal var groupButtons : [NSButton?] = []
  
  internal var arrangeView : NSView? = NSView()
  
  internal var arrangeStripView : NSView? = NSView()
  
  internal var groupView : NSView? = NSView()
  
  internal var currentPartType : SwitchboardItemType?
  
  internal var cboPalette : MyComboBox? = MyComboBox()
  
  internal var paletteViews : [SwitchboardItemPalette:NSView] = [:]
  
  internal var groupStripView : NSView? = NSView()
  
  internal var cboGroup : MyComboBox? = MyComboBox()
  
  // MARK: Inspector Area Controls
  
  internal var inspectorButtons : [NSButton?] = []
  
  internal var currentInspectorIndex = 0

  internal var inspectorViews : [NSView?] = []

  internal var inspectorFields : [LayoutInspectorPropertyField] = []
  
  internal var inspectorGroupFields : [LayoutInspectorGroup:LayoutInspectorGroupField] = [:]
  
  internal var inspectorGroupSeparators : [LayoutInspectorGroup:LayoutInspectorGroupField] = [:]
  
  internal var inspectorStripView : NSView? = NSView()
  
  internal var inspectorNoSelection : [NSTextField?] = []
  
  internal var inspectorNotApplicable : [NSTextField?] = []

  // MARK: Panel Area Controls
  
  internal var layoutButtons : [NSButton?] = []
  
  internal var layoutStripView : NSView? = NSView()
  
  // MARK: Panel Config Area
  
  internal var panelControls : [(label:NSTextField?, control:NSControl?, property:PanelProperty)] = []
  
  internal var panelStripView : NSView? = NSView()
  
  internal var panelStack : NSStackView? = NSStackView()
  
  internal var showPanelConstraint : NSLayoutConstraint?
  
  // MARK: Other Controls
  
  @IBOutlet weak var scrollView: NSScrollView!
  
  @IBOutlet weak var switchboardView: SwitchboardEditorView!
  
  @IBAction func cboAction(_ sender: NSComboBox) {
    
    if let property = LayoutInspectorProperty(rawValue: sender.tag), sender.indexOfSelectedItem >= 0, let string = sender.itemObjectValue(at: sender.indexOfSelectedItem) as? String  {
      
      for item in switchboardView.selectedItems {
        item.setValue(property: property, string: string)
        item.saveMemorySpaces()
      }
      
      switchboardView.needsDisplay = true

      appNode?.panelChanged(panelId: switchboardPanel!.nodeId)

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
      
      appNode?.panelChanged(panelId: switchboardPanel!.nodeId)
      
    }
    
  }
  
  // MARK: SwitchboardEditorViewDelegate Methods
  
  @objc func selectedItemChanged(_ switchboardEditorView:SwitchboardEditorView) {
    displayInspector()
    appNode?.panelChanged(panelId: switchboardPanel!.nodeId)
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
  
  @objc func btnCopyAction(_ sender: NSButton) {
    guard let textField = getTextField(button: sender), let _ = UInt64(dotHex: textField.stringValue, numberOfBytes: 8) else {
      return
    }
    let pasteboard = NSPasteboard.general
    pasteboard.declareTypes([.string], owner: nil)
    pasteboard.setString(textField.stringValue, forType: .string)
  }

  @objc func btnPasteAction(_ sender: NSButton) {
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

  @objc func newEventIdAction(_ sender: NSButton) {
    guard let textField = getTextField(button: sender), let appNode else {
      return
    }
    textField.stringValue = appNode.nextUniqueEventId.toHexDotFormat(numberOfBytes: 8)
    _ = control(textField, textShouldEndEditing: NSText())
  }
  
  private var lblQuickHelp : NSTextField? = NSTextField(labelWithString: "")
  private var lblQuickHelpSummary : NSTextField? = NSTextField(labelWithString: "")
  private var lblQuickHelpSummaryText : NSTextField? = NSTextField(labelWithString: "")
  private var sepQuickHelpSummary : SeparatorView? = SeparatorView()
  private var lblQuickHelpDiscussion : NSTextField? = NSTextField(labelWithString: "")
  private var lblQuickHelpDiscussionText : NSTextField? = NSTextField(labelWithString: "")
  private var quickHelpView : NSView? = NSView()

  // MARK: MyTrainsAppDelegate Methods
  
  func panelListUpdated(appNode:OpenLCBNodeMyTrains) {
    updatePanelComboBox()
  }

}
