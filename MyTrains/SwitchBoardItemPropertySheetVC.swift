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
      
      let numberOfSwitches = item.itemPartType.numberOfTurnoutSwitches
      
      lblTurnoutSwitch1.isHidden = numberOfSwitches < 1
      cboTurnoutSwitch1.isHidden = lblTurnoutSwitch1.isHidden
      lblTurnoutMotorType.isHidden = lblTurnoutSwitch1.isHidden
      cboTurnoutMotorType.isHidden = lblTurnoutSwitch1.isHidden
      btnClearTurnoutSwitch1.isHidden = lblTurnoutSwitch1.isHidden

      lblTurnoutSwitch2.isHidden = numberOfSwitches < 2
      cboTurnoutSwitch2.isHidden = lblTurnoutSwitch2.isHidden
      lblTurnoutMotorType2.isHidden = lblTurnoutSwitch2.isHidden
      cboTurnoutMotorType2.isHidden = lblTurnoutSwitch2.isHidden
      btnClearTurnoutSwitch2.isHidden = lblTurnoutSwitch2.isHidden
      
      if lblTurnoutSwitch2.isHidden {
        lblTurnoutSwitch1.stringValue = "Turnout Switch"
        lblTurnoutMotorType.stringValue = "Turnout Motor Type"
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
      
      var index = 0
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
      
      turnoutSwitches = networkController.turnoutSwitches
      turnoutSwitch1DS.items = turnoutSwitches
      turnoutSwitch2DS.items = turnoutSwitches
      cboTurnoutSwitch1.dataSource = turnoutSwitch1DS
      cboTurnoutSwitch2.dataSource = turnoutSwitch2DS
//      if let index = turnoutSwitch1DS.indexWithKey(deviceId: item.sw1LocoNetDeviceId, channelNumber: item.sw1ChannelNumber) {
//        cboTurnoutSwitch1.selectItem(at: index)
//      }
//      if let index = turnoutSwitch1DS.indexWithKey(deviceId: item.sw2LocoNetDeviceId, channelNumber: item.sw2ChannelNumber) {
//        cboTurnoutSwitch2.selectItem(at: index)
//      }
      
      // FEEDBACK
     
      if item.isFeedback {
        generalSensors = networkController.sensors(sensorTypes: [.position])
        lblTransponderSensor.isHidden = true
        cboTransponderSensor.isHidden = true
        btnClearTransponderSensor.isHidden = true
        lblTrackFaultSensor.isHidden = true
        cboTrackFaultSensor.isHidden = true
        btnClearTrackFaultSensor.isHidden = true
      }
      else {
        generalSensors = networkController.sensors(sensorTypes: [.occupancy])
      }
        
      generalSensorDS.items = generalSensors
      
      cboGeneralSensor.dataSource = generalSensorDS
      
      if let index = generalSensorDS.indexWithKey(ioFunctionId: item.generalSensorId) {
        cboGeneralSensor.selectItem(at: index)
      }
      
      transponderSensors = networkController.sensors(sensorTypes: [.transponder])
      
      transponderSensorDS.items = transponderSensors
      
      cboTransponderSensor.dataSource = transponderSensorDS
      
      if let index = transponderSensorDS.indexWithKey(ioFunctionId: item.transponderSensorId) {
        cboTransponderSensor.selectItem(at: index)
      }
      
      trackFaultSensors = networkController.sensors(sensorTypes: [.trackFault])
      
      trackFaultSensorDS.items = trackFaultSensors
      
      cboTrackFaultSensor.dataSource = trackFaultSensorDS
      
      if let index = trackFaultSensorDS.indexWithKey(ioFunctionId: item.trackFaultSensorId) {
        cboTrackFaultSensor.selectItem(at: index)
      }
      
      turnoutSensors = networkController.sensors(sensorTypes: [.turnoutState])
      
      sw1ClosedDS.items = turnoutSensors
      cboSW1Closed.dataSource = sw1ClosedDS
      
      if let index = sw1ClosedDS.indexWithKey(ioFunctionId: item.sw1Sensor2Id) {
        cboSW1Closed.selectItem(at: index)
      }

      sw1ThrownDS.items = turnoutSensors
      cboSW1Thrown.dataSource = sw1ThrownDS

      if let index = sw1ThrownDS.indexWithKey(ioFunctionId: item.sw1Sensor1Id) {
        cboSW1Thrown.selectItem(at: index)
      }

      sw2ClosedDS.items = turnoutSensors
      cboSW2Closed.dataSource = sw2ClosedDS

      if let index = sw2ClosedDS.indexWithKey(ioFunctionId: item.sw2Sensor2Id) {
        cboSW2Closed.selectItem(at: index)
      }

      sw2ThrownDS.items = turnoutSensors
      cboSW2Thrown.dataSource = sw2ThrownDS

      if let index = sw2ThrownDS.indexWithKey(ioFunctionId: item.sw2Sensor1Id) {
        cboSW2Thrown.selectItem(at: index)
      }
      
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
        lblSW1Closed.isHidden = true
        lblSW1Thrown.isHidden = true
        cboSW1Closed.isHidden = true
        cboSW1Thrown.isHidden = true
        btnClearSW1Closed.isHidden = true
        btnClearSW1Thrown.isHidden = true
        lblSW2Closed.isHidden = true
        lblSW2Thrown.isHidden = true
        cboSW2Closed.isHidden = true
        cboSW2Thrown.isHidden = true
        btnClearSW2Closed.isHidden = true
        btnClearSW2Thrown.isHidden = true
        if item.isFeedback {
          lblGeneralSensor.stringValue = "Position Sensor"
        }
        else {
          lblGeneralSensorPosition.isHidden = true
          txtGeneralSensorPosition.isHidden = true
          lblPositionUnits.isHidden = true
          cboPositionUnits.isHidden = true
        }
      }
      else if item.isTurnout {
        tabs.removeTabViewItem(tabs.tabViewItems[4])
        tabs.removeTabViewItem(tabs.tabViewItems[3])
        boxSpeedPrevious.isHidden = true
        boxSpeedNext.title = ""
        lblGeneralSensorPosition.isHidden = true
        txtGeneralSensorPosition.isHidden = true
        lblPositionUnits.isHidden = true
        cboPositionUnits.isHidden = true

        if numberOfSwitches < 2 {
          lblSW2Closed.isHidden = true
          lblSW2Thrown.isHidden = true
          cboSW2Closed.isHidden = true
          cboSW2Thrown.isHidden = true
          btnClearSW2Closed.isHidden = true
          btnClearSW2Thrown.isHidden = true
          lblSW1Closed.stringValue = "Turnout Switch - Closed Sensor"
          lblSW1Thrown.stringValue = "Turnout Switch - Thrown Sensor"
        }
      }
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
  
  private var turnoutSwitches : [TurnoutSwitch] = []
  
  private var generalSensors : [IOFunction] = []
  
  private var transponderSensors : [IOFunction] = []
  
  private var trackFaultSensors : [IOFunction] = []

  private var turnoutSensors : [IOFunction] = []

  private var turnoutSwitch1DS : TurnoutSwitchComboDS = TurnoutSwitchComboDS()
  private var turnoutSwitch2DS : TurnoutSwitchComboDS = TurnoutSwitchComboDS()
  
  private var generalSensorDS : SensorComboDS = SensorComboDS()
  
  private var transponderSensorDS : SensorComboDS = SensorComboDS()
  
  private var trackFaultSensorDS : SensorComboDS = SensorComboDS()
  
  private var sw1ThrownDS : SensorComboDS = SensorComboDS()
  private var sw1ClosedDS : SensorComboDS = SensorComboDS()
  private var sw2ThrownDS : SensorComboDS = SensorComboDS()
  private var sw2ClosedDS : SensorComboDS = SensorComboDS()

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

    
    item.sw1Id = -1
    if cboTurnoutSwitch1.indexOfSelectedItem != -1 {
      let turnoutSwitch = turnoutSwitches[cboTurnoutSwitch1.indexOfSelectedItem]
      item.sw1Id = turnoutSwitch.locoNetDeviceId
    }
    
    item.sw2Id = -1
    if cboTurnoutSwitch2.indexOfSelectedItem != -1 {
      let turnoutSwitch = turnoutSwitches[cboTurnoutSwitch2.indexOfSelectedItem]
      item.sw2Id = turnoutSwitch.locoNetDeviceId
    }
    
    item.generalSensorId = -1
    if cboGeneralSensor.indexOfSelectedItem != -1 {
      let sensor = generalSensors[cboGeneralSensor.indexOfSelectedItem]
      item.generalSensorId = sensor.primaryKey
    }

    item.transponderSensorId = -1
    if cboTransponderSensor.indexOfSelectedItem != -1 {
      let transponderSensor = transponderSensors[cboTransponderSensor.indexOfSelectedItem]
      item.transponderSensorId = transponderSensor.primaryKey
    }
    
    item.trackFaultSensorId = -1
    if cboTrackFaultSensor.indexOfSelectedItem != -1 {
      let trackFaultSensor = trackFaultSensors[cboTrackFaultSensor.indexOfSelectedItem]
      item.trackFaultSensorId = trackFaultSensor.primaryKey
    }
    
    item.sw1Sensor1Id = -1
    item.sw1Sensor2Id = -1
    item.sw2Sensor1Id = -1
    item.sw2Sensor2Id = -1
    
    if cboSW1Thrown.indexOfSelectedItem != -1 {
      let sensor = turnoutSensors[cboSW1Thrown.indexOfSelectedItem]
      item.sw1Sensor1Id = sensor.primaryKey
    }

    if cboSW1Closed.indexOfSelectedItem != -1 {
      let sensor = turnoutSensors[cboSW1Closed.indexOfSelectedItem]
      item.sw1Sensor2Id = sensor.primaryKey
    }

    if cboSW2Thrown.indexOfSelectedItem != -1 {
      let sensor = turnoutSensors[cboSW2Thrown.indexOfSelectedItem]
      item.sw2Sensor1Id = sensor.primaryKey
    }

    if cboSW2Closed.indexOfSelectedItem != -1 {
      let sensor = turnoutSensors[cboSW2Closed.indexOfSelectedItem]
      item.sw2Sensor2Id = sensor.primaryKey
    }
    
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
  
  @IBOutlet weak var lblTurnoutSwitch1: NSTextField!
  
  @IBOutlet weak var cboTurnoutSwitch1: NSComboBox!
  
  @IBAction func cboTurnoutSwitch1Action(_ sender: NSComboBox) {
  }
  
  @IBOutlet weak var lblTurnoutSwitch2: NSTextField!
  
  @IBOutlet weak var cboTurnoutSwitch2: NSComboBox!
  
  @IBAction func cboTurnoutSwitch2Action(_ sender: NSComboBox) {
  }
  
  @IBOutlet weak var btnClearTurnoutSwitch1: NSButton!
  
  @IBAction func btnClearTurnoutSwitch1Action(_ sender: NSButton) {
    cboTurnoutSwitch1.deselectItem(at: cboTurnoutSwitch1.indexOfSelectedItem)
  }
  
  @IBOutlet weak var btnClearTurnoutSwitch2: NSButton!
  
  @IBAction func btnClearTurnoutSwitch2Action(_ sender: NSButton) {
    cboTurnoutSwitch2.deselectItem(at: cboTurnoutSwitch2.indexOfSelectedItem)
  }
  
  @IBOutlet weak var lblGeneralSensor: NSTextField!
  
  @IBOutlet weak var cboGeneralSensor: NSComboBox!
  
  @IBAction func cboGeneralSensorAction(_ sender: NSComboBox) {
  }
  
  @IBOutlet weak var lblTransponderSensor: NSTextField!
  
  @IBOutlet weak var cboTransponderSensor: NSComboBox!
  
  @IBOutlet weak var lblTrackFaultSensor: NSTextField!
  
  @IBOutlet weak var cboTrackFaultSensor: NSComboBox!
  
  @IBOutlet weak var lblSW1Thrown: NSTextField!
  
  @IBOutlet weak var cboSW1Thrown: NSComboBox!
  
  @IBAction func cboSW1ThrownAction(_ sender: NSComboBox) {
  }
  
  @IBOutlet weak var lblSW1Closed: NSTextField!
  
  @IBOutlet weak var cboSW1Closed: NSComboBox!
  
  @IBAction func cboSW1ClosedAction(_ sender: NSComboBox) {
  }
  
  @IBOutlet weak var lblSW2Thrown: NSTextField!
  
  @IBOutlet weak var cboSW2Thrown: NSComboBox!
  
  @IBAction func cboSw2ThrownAction(_ sender: NSComboBox) {
  }
  
  @IBOutlet weak var lblSW2Closed: NSTextField!
  
  @IBOutlet weak var cboSW2Closed: NSComboBox!
  
  @IBAction func cboSW2ClosedAction(_ sender: NSComboBox) {
  }
  
  @IBOutlet weak var btnClearGeneralSensor: NSButton!
  
  @IBAction func btnClearGeneralSensorAction(_ sender: NSButton) {
    cboGeneralSensor.deselectItem(at: cboGeneralSensor.indexOfSelectedItem)
  }
  
  @IBOutlet weak var btnClearTransponderSensor: NSButton!
  
  @IBAction func btnClearTransponderSensorAction(_ sender: NSButton) {
  }
  
  @IBAction func btnClearTrackFaultSensor(_ sender: NSButton) {
  }
  
  @IBOutlet weak var btnClearTrackFaultSensor: NSButton!
  
  
  
  @IBOutlet weak var btnClearSW1Thrown: NSButton!
  
  
  @IBAction func btnClearSW1ThrownAction(_ sender: NSButton) {
    cboSW1Thrown.deselectItem(at: cboSW1Thrown.indexOfSelectedItem)
  }
  
  @IBOutlet weak var btnClearSW1Closed: NSButton!
  
  @IBAction func btnClearSW1ClosedAction(_ sender: NSButton) {
    cboSW1Closed.deselectItem(at: cboSW1Closed.indexOfSelectedItem)
  }
  
  @IBOutlet weak var btnClearSW2Thrown: NSButton!
  
  @IBAction func btnClearSW2ThrownAction(_ sender: NSButton) {
    cboSW2Thrown.deselectItem(at: cboSW2Thrown.indexOfSelectedItem)
  }
  
  @IBOutlet weak var btnClearSW2Closed: NSButton!
  
  @IBAction func btnClearSW2ClosedAction(_ sender: NSButton) {
    cboSW2Closed.deselectItem(at: cboSW2Closed.indexOfSelectedItem)
  }
  
  @IBOutlet weak var lblGeneralSensorPosition: NSTextField!
  
  @IBOutlet weak var txtGeneralSensorPosition: NSTextField!
  
  @IBAction func txtGeneralSensorPositionAction(_ sender: NSTextField) {
  }
  
  @IBOutlet weak var lblPositionUnits: NSTextField!
  
  @IBOutlet weak var cboPositionUnits: NSComboBox!
  
  @IBAction func cboPositionUnitsAction(_ sender: NSComboBox) {
  }
  
  
  
}
