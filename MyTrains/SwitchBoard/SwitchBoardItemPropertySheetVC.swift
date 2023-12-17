//
//  SwitchBoardItemPropertySheetVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/06/2022.
//

import Cocoa
import SQLite3

class SwitchBoardItemPropertySheetVC: NSViewController, NSWindowDelegate {

  // MARK: Window & View Control
  
  override func viewDidLoad() {
      super.viewDidLoad()
      // Do view setup here.
  }

  @objc func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }

  @objc func windowWillClose(_ notification: Notification) {
    stopModal()
  }
  
  override func viewWillAppear() {
        
    self.view.window?.delegate = self
    
    if let layout = item.layout {
      
      // GENERAL TAB
      
      lblItemId.integerValue = item.primaryKey
      
      lblLayout.stringValue = layout.layoutName
      
      cboPanel.removeAllItems()
      let panels = layout.switchBoardPanels
      for panel in panels {
        let name = "\(panel.panelId + 1): \(panel.panelName)"
        cboPanel.addItem(withObjectValue: name)
      }
      cboPanel.selectItem(at: item.panelId)
      
      var groupIds : Set<Int> = []
      for (_, item) in layout.switchBoardItems {
        if item.groupId != -1 {
          groupIds.insert(item.groupId)
        }
      }
      if item.groupId != -1 {
        cboGroupId.integerValue = item.groupId
      }

      cboGroupId.removeAllItems()
      for id in groupIds.sorted() {
        cboGroupId.addItem(withObjectValue: "\(id)")
      }
      
      lblPartType.stringValue = item.itemPartType.partName
      
      
      var x : CGFloat = 60.0
      var y : CGFloat = 497.0
      var tab = 2
      var index = 0
      
      let requiredEvents = item.itemPartType.eventsSupported
      
      lblTurnoutMotorType2.isHidden = item.itemPartType.numberOfTurnoutSwitches != 2
      cboTurnoutMotorType2.isHidden = lblTurnoutMotorType2.isHidden
      
      for title in SwitchBoardEventType.titles {

        if let eventType = SwitchBoardEventType(rawValue: index) {
          
          let label : NSTextField = NSTextField(labelWithString: title)
          label.tag = index
          eventLabels.append(label)
          
          var eventText : String
          
          switch eventType {
          case .enterDetectionZone:
            eventText = item.enterOccupancyZoneEventId?.toHexDotFormat(numberOfBytes: 8) ?? ""
          case .exitDetectionZone:
            eventText = item.exitOccupancyZoneEventId?.toHexDotFormat(numberOfBytes: 8) ?? ""
          case .transponder:
            eventText = item.transpondingZoneEventId?.toHexDotFormat(numberOfBytes: 8) ?? ""
          case .trackFault:
            eventText = item.trackFaultEventId?.toHexDotFormat(numberOfBytes: 8) ?? ""
          case .trackFaultCleared:
            eventText = item.trackFaultClearedEventId?.toHexDotFormat(numberOfBytes: 8) ?? ""
          case .sw1Thrown:
            eventText = item.sw1ThrownEventId?.toHexDotFormat(numberOfBytes: 8) ?? ""
          case .sw1Closed:
            eventText = item.sw1ClosedEventId?.toHexDotFormat(numberOfBytes: 8) ?? ""
          case .sw2Thrown:
            eventText = item.sw2ThrownEventId?.toHexDotFormat(numberOfBytes: 8) ?? ""
          case .sw2Closed:
            eventText = item.sw2ClosedEventId?.toHexDotFormat(numberOfBytes: 8) ?? ""
          case .throwSW1:
            eventText = item.sw1ThrowEventId?.toHexDotFormat(numberOfBytes: 8) ?? ""
          case .closeSW1:
            eventText = item.sw1CloseEventId?.toHexDotFormat(numberOfBytes: 8) ?? ""
          case .throwSW2:
            eventText = item.sw2ThrowEventId?.toHexDotFormat(numberOfBytes: 8) ?? ""
          case .closeSW2:
            eventText = item.sw2CloseEventId?.toHexDotFormat(numberOfBytes: 8) ?? ""
          }
          
          let textField = NSTextField(string: eventText)
          textField.tag = index
          textField.placeholderString = "00.00.00.00.00.00.00.00"
          eventIDs.append(textField)
          
          let copyButton : NSButton = NSButton(title: "Copy", target: self, action: #selector(self.btnCopyAction(_:)))
          copyButton.tag = index
          copyButtons.append(copyButton)
          
          let pasteButton : NSButton = NSButton(title: "Paste", target: self, action: #selector(self.btnPasteAction(_:)))
          pasteButton.tag = index
          pasteButtons.append(pasteButton)
          
          if requiredEvents.contains(eventType) {
            
            label.frame = NSRect(x: x, y: y, width: 230.0, height: 16.0)
            tabs.tabViewItems[tab].view?.addSubview(label)
            y -= 30.0
            textField.frame = NSRect(x: x, y: y, width: 160.0, height: 21.0)
            tabs.tabViewItems[tab].view?.addSubview(textField)
            copyButton.frame = NSRect(x: x + 220, y: y, width: 60.0, height: 20.0)
            tabs.tabViewItems[tab].view?.addSubview(copyButton)
            pasteButton.frame = NSRect(x: x + 280, y: y, width: 60.0, height: 20.0)
            tabs.tabViewItems[tab].view?.addSubview(pasteButton)
            y -= 25.0
            
          }
          
          if index == SwitchBoardEventType.sw2Closed.rawValue {
            tab = 1
            x = 232.0
            y = 204.0
          }
          
        }
        
        index += 1
        
      }

      switchBoardItemView.switchBoardItem = item

      lblOrientation.stringValue = item.orientation.title
      
      txtXPos.integerValue = item.location.x
      
      txtYPos.integerValue = item.location.y
      
      txtName.stringValue = item.blockName
      
      if txtName.stringValue.isEmpty {
        txtName.stringValue = item.layout!.nextItemName(switchBoardItem: item)
      }
      
      lblLink.isHidden = !item.isLink
      cboLink.isHidden = !item.isLink
      
      cboLinkDS.dictionary = layout.links(item: item)
      cboLink.dataSource = cboLinkDS
      cboLink.selectItem(at: cboLinkDS.indexWithKey(key: item.linkItem) ?? -1)
      
      // OPTIONS TAB
      
      tabs.tabViewItems[1].view?.isHidden = item.isTrack || item.isScenic

      TrackGauge.populate(comboBox: cboTrackGauge)
      TrackGauge.select(comboBox: cboTrackGauge, value: item.trackGauge)
      
      TrackElectrificationType.populate(comboBox: cboTrackElectrificationType)
      TrackElectrificationType.select(comboBox: cboTrackElectrificationType, value: item.trackElectrificationType)
      
      BlockDirection.populate(comboBox: cboDirection)
      BlockDirection.select(comboBox: cboDirection, value: item.blockDirection)
      
      TurnoutMotorType.populate(comboBox: cboTurnoutMotorType)
      TurnoutMotorType.select(comboBox: cboTurnoutMotorType, value: item.sw1TurnoutMotorType)
      
      TurnoutMotorType.populate(comboBox: cboTurnoutMotorType2)
      TurnoutMotorType.select(comboBox: cboTurnoutMotorType2, value: item.sw2TurnoutMotorType)
      
      txtGradient.doubleValue = item.gradient
      
      chkCriticalSection.boolValue = item.isCritical
      
      chkScenicSection.boolValue = item.isScenicSection
      
      chkAllowShunt.boolValue = item.allowShunt
      
      chkAllowShunt.isHidden = !item.isBlock
      
      UnitLength.populate(comboBox: cboDimensionUnits)
      UnitLength.select(comboBox: cboDimensionUnits, value: item.unitsDimension)
      
      BlockType.populate(comboBox: cboBlockType)
      BlockType.select(comboBox: cboBlockType, value: item.blockType)
      cboBlockType.isEnabled = item.isBlock
      
      cboTrackPartTypeDS.dictionary = TrackPart.dictionary(itemPartType: item.itemPartType, trackGauge: item.trackGauge)
      cboTrackPartType.dataSource = cboTrackPartTypeDS
      cboTrackPartType.selectItem(at: cboTrackPartTypeDS.indexWithKey(key: item.trackPartId) ?? -1)
      
      dimensions = [
        (lblA, txtA),
        (lblB, txtB),
        (lblC, txtC),
        (lblD, txtD),
        (lblE, txtE),
        (lblF, txtF),
        (lblG, txtG),
        (lblH, txtH),
      ]
      
      let labels = item.itemPartType.routeLabels(orientation: item.orientation)
      
      index = 0
      for dimension in dimensions {
        let isHidden = index >= labels.count
        dimension.label.isHidden = isHidden
        dimension.value.isHidden = isHidden
        if index < labels.count {
          dimension.label.stringValue = labels[index].label
          dimension.value.doubleValue = item.getDimension(index: labels[index].index)
          dimension.value.tag = labels[index].index
        }
        index += 1
      }
      
      
      // FEEDBACK
     
      UnitLength.populate(comboBox: cboPositionUnits)
      
      UnitLength.select(comboBox: cboPositionUnits, value: item.sensorPositionUnits)
      
      txtGeneralSensorPosition.doubleValue = item.sensorPosition

      // DIRECTION NEXT
      
      tabs.tabViewItems[3].view?.isHidden = !item.isBlock

      txtDNBrakePosition.doubleValue = item.dirNextBrakePosition
      
      txtDNStopPosition.doubleValue = item.dirNextStopPosition
      
      UnitLength.populate(comboBox: cboDNPositionUnits)
      UnitLength.select(comboBox: cboDNPositionUnits, value: item.dirNextUnitsPosition)
      
      // DIRECTION PREVIOUS
      
      tabs.tabViewItems[4].view?.isHidden = !item.isBlock

      txtDPBrakePosition.doubleValue = item.dirPreviousBrakePosition
      
      txtDPStopPosition.doubleValue = item.dirPreviousStopPosition
      
      UnitLength.populate(comboBox: cboDPPositionUnits)
      UnitLength.select(comboBox: cboDPPositionUnits, value: item.dirPreviousUnitsPosition)
      
      // SPEED
      
      tabs.tabViewItems[5].view?.isHidden = item.isTrack || item.isScenic

      txtDNMax.doubleValue = item.dirNextSpeedMax
      txtDNStopExpected.doubleValue = item.dirNextSpeedStopExpected
      txtDNRestricted.doubleValue = item.dirNextSpeedRestricted
      txtDNBrake.doubleValue = item.dirNextSpeedBrake
      txtDNShunt.doubleValue = item.dirNextSpeedShunt
      
      txtDPMax.doubleValue = item.dirPreviousSpeedMax
      txtDPStopExpected.doubleValue = item.dirPreviousSpeedStopExpected
      txtDPRestricted.doubleValue = item.dirPreviousSpeedRestricted
      txtDPBrake.doubleValue = item.dirPreviousSpeedBrake
      txtDPShunt.doubleValue = item.dirPreviousSpeedShunt
      
      chkDNMaxUD.boolValue = item.dirNextSpeedMaxAllowEdit
      chkDNStopExpectedUD.boolValue = item.dirNextSpeedStopExpectedAllowEdit
      chkDNRestrictedUD.boolValue = item.dirNextSpeedRestrictedAllowEdit
      chkDNBrakeUD.boolValue = item.dirNextSpeedBrakeAllowEdit
      chkDNShuntUD.boolValue = item.dirNextSpeedShuntAllowEdit
      
      chkDPMaxUD.boolValue = item.dirPreviousSpeedMaxAllowEdit
      chkDPStopExpectedUD.boolValue = item.dirPreviousSpeedStopExpectedAllowEdit
      chkDPRestrictedUD.boolValue = item.dirPreviousSpeedRestrictedAllowEdit
      chkDPBrakeUD.boolValue = item.dirPreviousSpeedBrakeAllowEdit
      chkDPShuntUD.boolValue = item.dirPreviousSpeedShuntAllowEdit
      
      UnitSpeed.populate(comboBox: cboSpeedUnits)
      UnitSpeed.select(comboBox: cboSpeedUnits, value: item.unitsSpeed)
      
      if !(item.isBlock || item.isTurnout || item.isFeedback) {
        tabs.removeTabViewItem(tabs.tabViewItems[5])
        tabs.removeTabViewItem(tabs.tabViewItems[4])
        tabs.removeTabViewItem(tabs.tabViewItems[3])
        tabs.removeTabViewItem(tabs.tabViewItems[2])
        tabs.removeTabViewItem(tabs.tabViewItems[1])
      }
      else if item.isFeedback || item.isBlock {
        tabs.removeTabViewItem(tabs.tabViewItems[5])
        tabs.removeTabViewItem(tabs.tabViewItems[4])
        tabs.removeTabViewItem(tabs.tabViewItems[3])
        tabs.removeTabViewItem(tabs.tabViewItems[1])
      }
      else if item.isTurnout {
        tabs.removeTabViewItem(tabs.tabViewItems[4])
        tabs.removeTabViewItem(tabs.tabViewItems[3])
        boxSpeedPrevious.isHidden = true
        boxSpeedNext.title = ""

      }
      lblGeneralSensorPosition.isHidden = item.itemPartType != .feedback
      txtGeneralSensorPosition.isHidden = item.itemPartType != .feedback
      lblPositionUnits.isHidden = item.itemPartType != .feedback
      cboPositionUnits.isHidden = item.itemPartType != .feedback
    }
    
    setupControls()

  }
  
  // MARK: Private Properties
  
  private var item : SwitchBoardItem {
    get {
      return switchBoardItem!
    }
  }
  
  private var cboTrackPartTypeDS : ComboBoxDictDS = ComboBoxDictDS()

  private var cboLinkDS : ComboBoxDictDS = ComboBoxDictDS()

  private var dimensions : [(label:NSTextField, value:NSTextField)] = []
  
  private var copyButtons : [NSButton] = []
  
  private var pasteButtons : [NSButton] = []
  
  private var eventIDs : [NSTextField] = []
  
  private var eventLabels : [NSTextField] = []
  
  // MARK: Public Properties
  
  public var switchBoardItem : SwitchBoardItem?

  // MARK: Private Methods
  
  private func setupControls() {
    
    // GENERAL
    
    let hideName = !(item.isBlock || item.isTurnout || item.isLink)
    
    lblName.isHidden = hideName
    txtName.isHidden = hideName
    
    // OPTIONS
    
    if let trackPart = cboTrackPartTypeDS.editorObjectAt(index: cboTrackPartType.indexOfSelectedItem) as? TrackPartEditorObject {
      let allowEdit = trackPart.trackPart == .custom
      for dimension in dimensions {
        dimension.value.isEnabled = allowEdit
        if !allowEdit {
          dimension.value.doubleValue = trackPart.trackPart.partInfo?.dimensions[dimension.value.tag] ?? 0.0
        }
      }
      cboDimensionUnits.isEnabled = allowEdit
      if !allowEdit {
        UnitLength.select(comboBox: cboDimensionUnits, value: .centimeters)
      }
    }
    
    let trackGauge = TrackGauge.selected(comboBox: cboTrackGauge)
    let lastValue = cboTrackPartType.stringValue
    cboTrackPartTypeDS.dictionary = TrackPart.dictionary(itemPartType: item.itemPartType, trackGauge: trackGauge)
    cboTrackPartType.dataSource = cboTrackPartTypeDS
    cboTrackPartType.stringValue = lastValue
    
    cboDirection.isEnabled = item.isBlock

    // FEEDBACK
    
    // DIRECTION NEXT
    
    // DIRECTION PREVIOUS
    
    // SPEED
    
    txtDNMax.isEnabled = chkDNMaxUD.boolValue
    txtDNStopExpected.isEnabled = chkDNStopExpectedUD.boolValue
    txtDNRestricted.isEnabled = chkDNRestrictedUD.boolValue
    txtDNBrake.isEnabled = chkDNBrakeUD.boolValue
    txtDNShunt.isEnabled = chkDNShuntUD.boolValue
    
    txtDPMax.isEnabled = chkDPMaxUD.boolValue
    txtDPStopExpected.isEnabled = chkDPStopExpectedUD.boolValue
    txtDPRestricted.isEnabled = chkDPRestrictedUD.boolValue
    txtDPBrake.isEnabled = chkDPBrakeUD.boolValue
    txtDPShunt.isEnabled = chkDPShuntUD.boolValue
    
  }
  
  // MARK: Outlets & Actions
  
  @IBOutlet weak var lblItemId: NSTextField!
  
  @IBOutlet weak var lblLayout: NSTextField!
  
  @IBOutlet weak var cboPanel: NSComboBox!
  
  @IBAction func cboPanelAction(_ sender: NSComboBox) {
  }
  
  @IBOutlet weak var cboGroupId: NSComboBox!
  
  @IBAction func cboGroupIdAction(_ sender: NSComboBox) {
  }
  
  @IBOutlet weak var txtXPos: NSTextField!
  
  @IBAction func txtXPosAction(_ sender: NSTextField) {
  }
  
  @IBOutlet weak var txtYPos: NSTextField!
  
  @IBAction func txtYPosAction(_ sender: NSTextField) {
  }
  
  @IBOutlet weak var lblName: NSTextField!
  
  @IBOutlet weak var txtName: NSTextField!
  
  @IBOutlet weak var cboTrackPartType: NSComboBox!
  
  @IBAction func cboTrackPartTypeAction(_ sender: NSComboBox) {
    setupControls()
  }
  
  @IBOutlet weak var lblA: NSTextField!
  
  @IBOutlet weak var lblB: NSTextField!
  
  @IBOutlet weak var lblC: NSTextField!
  
  @IBOutlet weak var lblD: NSTextField!
  
  @IBOutlet weak var lblE: NSTextField!
  
  @IBOutlet weak var lblF: NSTextField!
  
  @IBOutlet weak var lblG: NSTextField!
  
  @IBOutlet weak var lblH: NSTextField!
  
  @IBOutlet weak var txtA: NSTextField!
  
  @IBAction func txtAAction(_ sender: NSTextField) {
  }
  
  @IBOutlet weak var txtB: NSTextField!
  
  @IBAction func txtBAction(_ sender: NSTextField) {
  }
  
  @IBOutlet weak var txtC: NSTextField!
  
  @IBAction func txtCAction(_ sender: NSTextField) {
  }
  
  @IBOutlet weak var txtD: NSTextField!
  
  @IBAction func txtDAction(_ sender: NSTextField) {
  }
  
  @IBOutlet weak var txtE: NSTextField!
  
  @IBAction func txtEAction(_ sender: NSTextField) {
  }
  
  @IBOutlet weak var txtF: NSTextField!
  
  @IBAction func txtFAction(_ sender: NSTextField) {
  }
  
  @IBOutlet weak var txtG: NSTextField!
  
  @IBAction func txtGAction(_ sender: NSTextField) {
  }
  
  @IBOutlet weak var txtH: NSTextField!
  
  @IBAction func txtHAction(_ sender: NSTextField) {
  }
  
  @IBOutlet weak var cboTrackGauge: NSComboBox!
  
  @IBAction func cboTrackGaugeAction(_ sender: NSComboBox) {
    setupControls()
  }
  
  @IBOutlet weak var cboTrackElectrificationType: NSComboBox!
  
  @IBAction func cboTrackElectrificationTypeAction(_ sender: NSComboBox) {
  }
  
  @IBOutlet weak var cboDirection: NSComboBox!
  
  @IBAction func cboDirectionAction(_ sender: NSComboBox) {
  }
  
  @IBOutlet weak var txtGradient: NSTextField!
  
  @IBAction func txtGradientAction(_ sender: NSTextField) {
  }
  
  @IBOutlet weak var chkCriticalSection: NSButton!
  
  @IBOutlet weak var chkScenicSection: NSButton!
  
  @IBOutlet weak var chkAllowShunt: NSButton!
  
  @IBOutlet weak var cboDimensionUnits: NSComboBox!
  
  @IBAction func cboDimensionUnitsAction(_ sender: NSComboBox) {
  }
  
  @IBAction func btnCancelAction(_ sender: NSButton) {
    view.window?.close()
  }
  
  @IBAction func btnDoneAction(_ sender: NSButton) {
    
    item.blockType = BlockType.selected(comboBox: cboBlockType)
    
    item.groupId = -1
    if cboGroupId.integerValue > 0 {
      item.groupId = cboGroupId.integerValue
    }
    
    item.dirNextSpeedMaxAllowEdit = chkDNMaxUD.boolValue
    item.dirNextSpeedStopExpectedAllowEdit = chkDNStopExpectedUD.boolValue
    item.dirNextSpeedRestrictedAllowEdit = chkDNRestrictedUD.boolValue
    item.dirNextSpeedBrakeAllowEdit = chkDNBrakeUD.boolValue
    item.dirNextSpeedShuntAllowEdit = chkDNShuntUD.boolValue
    
    item.dirPreviousSpeedMaxAllowEdit = chkDPMaxUD.boolValue
    item.dirPreviousSpeedStopExpectedAllowEdit = chkDPStopExpectedUD.boolValue
    item.dirPreviousSpeedRestrictedAllowEdit = chkDPRestrictedUD.boolValue
    item.dirPreviousSpeedBrakeAllowEdit = chkDPBrakeUD.boolValue
    item.dirPreviousSpeedShuntAllowEdit = chkDPShuntUD.boolValue
    
    item.dirNextSpeedMax = txtDNMax.doubleValue
    item.dirNextSpeedStopExpected = txtDNStopExpected.doubleValue
    item.dirNextSpeedRestricted = txtDNRestricted.doubleValue
    item.dirNextSpeedBrake = txtDNBrake.doubleValue
    item.dirNextSpeedShunt = txtDNShunt.doubleValue
    
    item.dirPreviousSpeedMax = txtDPMax.doubleValue
    item.dirPreviousSpeedStopExpected = txtDPStopExpected.doubleValue
    item.dirPreviousSpeedRestricted = txtDPRestricted.doubleValue
    item.dirPreviousSpeedBrake = txtDPBrake.doubleValue
    item.dirPreviousSpeedShunt = txtDPShunt.doubleValue
    
    item.unitsSpeed = UnitSpeed.selected(comboBox: cboSpeedUnits)
    
    item.allowShunt = chkAllowShunt.boolValue
    
    item.blockDirection = BlockDirection.selected(comboBox: cboDirection)
    
    item.blockName = txtName.stringValue
    
    item.dirNextBrakePosition = txtDNBrakePosition.doubleValue
    
    item.dirNextStopPosition = txtDNStopPosition.doubleValue
    
    item.dirNextUnitsPosition = UnitLength.selected(comboBox: cboDNPositionUnits)
    
    item.dirPreviousBrakePosition = txtDPBrakePosition.doubleValue
    
    item.dirPreviousStopPosition = txtDPStopPosition.doubleValue
    
    item.dirPreviousUnitsPosition = UnitLength.selected(comboBox: cboDPPositionUnits)
    
    item.gradient = txtGradient.doubleValue
    
    item.isCritical = chkCriticalSection.boolValue
    
    item.isScenicSection = chkScenicSection.boolValue
    
    item.trackElectrificationType = TrackElectrificationType.selected(comboBox: cboTrackElectrificationType)
    
    item.trackGauge = TrackGauge.selected(comboBox: cboTrackGauge)
    
    item.unitsDimension = UnitLength.selected(comboBox: cboDimensionUnits)
    
    item.sensorPosition = txtGeneralSensorPosition.doubleValue
    
    item.sensorPositionUnits = UnitLength.selected(comboBox: cboPositionUnits)
    
    item.sw1TurnoutMotorType = TurnoutMotorType.selected(comboBox: cboTurnoutMotorType)
    
    item.sw2TurnoutMotorType = TurnoutMotorType.selected(comboBox: cboTurnoutMotorType2)
    
    item.location = (x: txtXPos.integerValue, y: txtYPos.integerValue)
    
    item.linkItem = -1
    
    if let item2 = cboLinkDS.editorObjectAt(index: cboLink.indexOfSelectedItem) as? SwitchBoardItem {
      item.linkItem = item2.primaryKey
      item2.linkItem = item.primaryKey
    }
    
    if let edObj = cboTrackPartTypeDS.editorObjectAt(index: cboTrackPartType.indexOfSelectedItem) {
      item.trackPartId = edObj.primaryKey
    }
    else {
      item.trackPartId = -1
    }
    
    let labels = item.itemPartType.routeLabels(orientation: item.orientation)
    
    var index = 0
    for dimension in dimensions {
      if index < labels.count {
        item.setDimension(index: labels[index].index, value: dimension.value.doubleValue)
      }
      index += 1
    }
    
    for textField in eventIDs {
      if let eventType = SwitchBoardEventType(rawValue: textField.tag), let eventId = UInt64(dotHex: textField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)) {
        switch eventType {
        case .enterDetectionZone:
          item.enterOccupancyZoneEventId = eventId
        case .exitDetectionZone:
          item.exitOccupancyZoneEventId = eventId
        case .transponder:
          item.transpondingZoneEventId = eventId
        case .trackFault:
          item.trackFaultEventId = eventId
        case .trackFaultCleared:
          item.trackFaultClearedEventId = eventId
        case .sw1Thrown:
          item.sw1ThrownEventId = eventId
        case .sw1Closed:
          item.sw1ClosedEventId = eventId
        case .sw2Thrown:
          item.sw2ThrownEventId = eventId
        case .sw2Closed:
          item.sw2ClosedEventId = eventId
        case .throwSW1:
          item.sw1ThrowEventId = eventId
        case .closeSW1:
          item.sw1CloseEventId = eventId
        case .throwSW2:
          item.sw2ThrowEventId = eventId
        case .closeSW2:
          item.sw2CloseEventId = eventId
        }
      }
      else {
        
      }
    }

    view.window?.close()
    
  }
  
  @IBOutlet weak var txtDNBrakePosition: NSTextField!
  
  @IBAction func txtDNBrakePositionAction(_ sender: NSTextField) {
  }
  
  @IBOutlet weak var txtDNStopPosition: NSTextField!
  
  @IBAction func txtDNStopPositionAction(_ sender: NSTextField) {
  }
  
  @IBOutlet weak var cboDNPositionUnits: NSComboBox!
  
  @IBAction func cboDNPositionUnitsAction(_ sender: NSComboBox) {
  }
  
  @IBOutlet weak var txtDPBrakePosition: NSTextField!
  
  @IBAction func txtDPBrakePositionAction(_ sender: NSTextField) {
  }
  
  @IBOutlet weak var txtDPStopPosition: NSTextField!
  
  @IBAction func txtDPStopPositionAction(_ sender: NSTextField) {
  }
  
  @IBOutlet weak var cboDPPositionUnits: NSComboBox!
  
  @IBAction func cboDPPositionUnitsAction(_ sender: NSComboBox) {
  }
  
  @IBOutlet weak var chkDNMaxUD: NSButton!
  
  @IBAction func chkDNMaxUDAction(_ sender: NSButton) {
    setupControls()
  }
  
  @IBOutlet weak var chkDNStopExpectedUD: NSButton!
  
  @IBAction func chkDNStopExpectedUDAction(_ sender: NSButton) {
    setupControls()
  }
  
  @IBOutlet weak var chkDNRestrictedUD: NSButton!
  
  @IBAction func chkDNRestrictedUDAction(_ sender: NSButton) {
    setupControls()
  }
  
  @IBOutlet weak var chkDNBrakeUD: NSButton!
  
  @IBAction func chkDNBrakeUDAction(_ sender: NSButton) {
    setupControls()
  }
  
  @IBOutlet weak var chkDNShuntUD: NSButton!
  
  @IBAction func chkDNShuntUDAction(_ sender: NSButton) {
    setupControls()
  }
  
  @IBOutlet weak var txtDNMax: NSTextField!
  
  @IBAction func txtDNMaxAction(_ sender: NSTextField) {
  }
  
  @IBOutlet weak var txtDNStopExpected: NSTextField!
  
  @IBAction func txtDNStopExpectedAction(_ sender: NSTextField) {
  }
  
  @IBOutlet weak var txtDNRestricted: NSTextField!
  
  @IBAction func txtDNRestrictedAction(_ sender: NSTextField) {
  }
  
  @IBOutlet weak var txtDNBrake: NSTextField!
  
  @IBAction func txtDNBrakeAction(_ sender: NSTextField) {
  }
  
  @IBOutlet weak var txtDNShunt: NSTextField!
  
  @IBAction func txtDNShuntAction(_ sender: Any) {
  }
  
  @IBAction func btnDNSetDefaults(_ sender: NSButton) {
    
    let blockType = BlockType.selected(comboBox: cboBlockType)
    
    txtDNMax.doubleValue = SwitchBoardItem.defaultSpeedMax(blockType: blockType)
    txtDNStopExpected.doubleValue = SwitchBoardItem.defaultSpeedStopExpected(blockType: blockType)
    txtDNRestricted.doubleValue = SwitchBoardItem.defaultSpeedRestricted(blockType: blockType)
    txtDNBrake.doubleValue = SwitchBoardItem.defaultSpeedBrake(blockType: blockType)
    txtDNShunt.doubleValue = SwitchBoardItem.defaultSpeedShunt(blockType: blockType)
    
    chkDNMaxUD.boolValue = false
    chkDNStopExpectedUD.boolValue = false
    chkDNRestrictedUD.boolValue = false
    chkDNBrakeUD.boolValue = false
    chkDNShuntUD.boolValue = false
    
    setupControls()
    
  }
  
  @IBOutlet weak var chkDPMaxUD: NSButton!
  
  @IBAction func chkDPMaxUDAction(_ sender: NSButton) {
    setupControls()
  }
  
  @IBOutlet weak var chkDPStopExpectedUD: NSButton!
  
  @IBAction func chkDPStopExpectedUDAction(_ sender: NSButton) {
    setupControls()
  }
  
  @IBOutlet weak var chkDPRestrictedUD: NSButton!
  
  @IBAction func chkDPRestrictedUDAction(_ sender: NSButton) {
    setupControls()
  }
  
  @IBOutlet weak var chkDPBrakeUD: NSButton!
  
  @IBAction func chkDPBrakeUDAction(_ sender: NSButton) {
    setupControls()
  }
  
  @IBOutlet weak var chkDPShuntUD: NSButton!
  
  @IBAction func chkDPShuntUDAction(_ sender: NSButton) {
    setupControls()
  }
  
  @IBOutlet weak var txtDPMax: NSTextField!
  
  @IBAction func txtDPMaxAction(_ sender: NSTextField) {
  }
  
  @IBOutlet weak var txtDPStopExpected: NSTextField!
  
  @IBAction func txtDPStopExpected(_ sender: NSTextField) {
  }
  
  @IBOutlet weak var txtDPRestricted: NSTextField!
  
  @IBAction func txtDPRestrictedAction(_ sender: NSTextField) {
  }
  
  @IBOutlet weak var txtDPBrake: NSTextField!
  
  @IBAction func txtDPBrakeAction(_ sender: NSTextField) {
  }
  
  @IBOutlet weak var txtDPShunt: NSTextField!
  
  @IBAction func txtDPShuntAction(_ sender: NSTextField) {
  }
  
  @IBAction func btnDPSetDefaults(_ sender: NSButton) {
    
    let blockType = BlockType.selected(comboBox: cboBlockType)
    
    txtDPMax.doubleValue = SwitchBoardItem.defaultSpeedMax(blockType: blockType)
    txtDPStopExpected.doubleValue = SwitchBoardItem.defaultSpeedStopExpected(blockType: blockType)
    txtDPRestricted.doubleValue = SwitchBoardItem.defaultSpeedRestricted(blockType: blockType)
    txtDPBrake.doubleValue = SwitchBoardItem.defaultSpeedBrake(blockType: blockType)
    txtDPShunt.doubleValue = SwitchBoardItem.defaultSpeedShunt(blockType: blockType)
    
    chkDPMaxUD.boolValue = false
    chkDPStopExpectedUD.boolValue = false
    chkDPRestrictedUD.boolValue = false
    chkDPBrakeUD.boolValue = false
    chkDPShuntUD.boolValue = false
    
    setupControls()
     
  }
  
  @IBOutlet weak var cboSpeedUnits: NSComboBox!
  
  @IBAction func btnSpeedUnitsAction(_ sender: NSComboBox) {
  }
  
  @IBOutlet weak var cboBlockType: NSComboBox!
  
  @IBAction func cboBlockTypeAction(_ sender: NSComboBox) {
    
    let blockType = BlockType.selected(comboBox: sender)
    
    if !chkDNMaxUD.boolValue {
      txtDNMax.doubleValue = SwitchBoardItem.defaultSpeedMax(blockType: blockType)
    }
    if !chkDNStopExpectedUD.boolValue {
      txtDNStopExpected.doubleValue = SwitchBoardItem.defaultSpeedStopExpected(blockType: blockType)
    }
    if !chkDNRestrictedUD.boolValue {
      txtDNRestricted.doubleValue = SwitchBoardItem.defaultSpeedRestricted(blockType: blockType)
    }
    if !chkDNBrakeUD.boolValue {
      txtDNBrake.doubleValue = SwitchBoardItem.defaultSpeedBrake(blockType: blockType)
    }
    if !chkDNShuntUD.boolValue {
      txtDNShunt.doubleValue = SwitchBoardItem.defaultSpeedShunt(blockType: blockType)
    }
    
    if !chkDPMaxUD.boolValue {
      txtDPMax.doubleValue = SwitchBoardItem.defaultSpeedMax(blockType: blockType)
    }
    if !chkDPStopExpectedUD.boolValue {
      txtDPStopExpected.doubleValue = SwitchBoardItem.defaultSpeedStopExpected(blockType: blockType)
    }
    if !chkDPRestrictedUD.boolValue {
      txtDPRestricted.doubleValue = SwitchBoardItem.defaultSpeedRestricted(blockType: blockType)
    }
    if !chkDPBrakeUD.boolValue {
      txtDPBrake.doubleValue = SwitchBoardItem.defaultSpeedBrake(blockType: blockType)
    }
    if !chkDPShuntUD.boolValue {
      txtDPShunt.doubleValue = SwitchBoardItem.defaultSpeedShunt(blockType: blockType)
    }
    
  }
  
  @IBOutlet weak var switchBoardItemView: SwitchBoardItemView!
  
  @IBOutlet weak var lblPartType: NSTextField!
  
  @IBOutlet weak var lblOrientation: NSTextField!
  
  @IBOutlet weak var cboLink: NSComboBox!
  
  @IBAction func cboLinkAction(_ sender: NSComboBox) {
  }
  
  @IBOutlet weak var lblLink: NSTextField!
  
  @IBOutlet weak var tabs: NSTabView!
  
  @IBOutlet weak var boxSpeedNext: NSBox!
  
  @IBOutlet weak var boxSpeedPrevious: NSBox!
  
  @IBOutlet weak var lblTurnoutMotorType: NSTextField!
  
  @IBOutlet weak var cboTurnoutMotorType: NSComboBox!
  
  @IBAction func cboTurnoutMotorTypeAction(_ sender: NSComboBox) {
  }
  
  @IBOutlet weak var lblTurnoutMotorType2: NSTextField!
  
  @IBOutlet weak var cboTurnoutMotorType2: NSComboBox!
  
  @IBAction func cboTurnoutMotorType2Action(_ sender: NSComboBox) {
  }
    
  @IBOutlet weak var lblGeneralSensorPosition: NSTextField!
  
  @IBOutlet weak var txtGeneralSensorPosition: NSTextField!
  
  @IBAction func txtGeneralSensorPositionAction(_ sender: NSTextField) {
  }
  
  @IBOutlet weak var lblPositionUnits: NSTextField!
  
  @IBOutlet weak var cboPositionUnits: NSComboBox!
  
  @IBAction func cboPositionUnitsAction(_ sender: NSComboBox) {
  }
  
  @IBAction func btnCopyAction(_ sender: NSButton) {
    let textField = eventIDs[sender.tag]
    let pasteboard = NSPasteboard.general
    pasteboard.declareTypes([.string], owner: nil)
    pasteboard.setString(textField.stringValue, forType: .string)

  }

  @IBAction func btnPasteAction(_ sender: NSButton) {
    let textField = eventIDs[sender.tag]
    let pasteboard = NSPasteboard.general
    textField.stringValue = pasteboard.string(forType: .string) ?? ""
  }

}
