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
      cboGroupId.integerValue = item.groupId

      cboGroupId.removeAllItems()
      for id in groupIds.sorted() {
        cboGroupId.addItem(withObjectValue: "\(id)")
      }
      
      SwitchBoardItemPartType.populate(comboBox: cboPartType)
      SwitchBoardItemPartType.select(comboBox: cboPartType, partType: item.itemPartType)
      
      switchBoardItemView.switchBoardItem = item

      Orientation.populate(comboBox: cboOrientation)
      Orientation.select(comboBox: cboOrientation, value: item.orientation)
      
      txtXPos.integerValue = item.location.x
      
      txtYPos.integerValue = item.location.y
      
      txtName.stringValue = item.blockName
      
      // OPTIONS TAB
      
      TrackGauge.populate(comboBox: cboTrackGauge)
      TrackGauge.select(comboBox: cboTrackGauge, value: item.trackGauge)
      
      TrackElectrificationType.populate(comboBox: cboTrackElectrificationType)
      TrackElectrificationType.select(comboBox: cboTrackElectrificationType, value: item.trackElectrificationType)
      
      BlockDirection.populate(comboBox: cboDirection)
      BlockDirection.select(comboBox: cboDirection, value: item.blockDirection)
      
      txtGradient.doubleValue = item.gradient
      
      chkCriticalSection.boolValue = item.isCritical
      
      chkScenicSection.boolValue = item.isScenicSection
      
      chkAllowShunt.boolValue = item.allowShunt
      
      UnitLength.populate(comboBox: cboDimensionUnits)
      UnitLength.select(comboBox: cboDimensionUnits, value: item.unitsDimension)
      
      BlockType.populate(comboBox: cboBlockType)
      BlockType.select(comboBox: cboBlockType, value: item.blockType)
      
      // FEEDBACK
      
      // DIRECTION NEXT
      
      txtDNBrakePosition.doubleValue = item.dirNextBrakePosition
      
      txtDNStopPosition.doubleValue = item.dirNextStopPosition
      
      UnitLength.populate(comboBox: cboDNPositionUnits)
      UnitLength.select(comboBox: cboDNPositionUnits, value: item.dirNextUnitsPosition)
      
      // DIRECTION PREVIOUS
      
      txtDPBrakePosition.doubleValue = item.dirPreviousBrakePosition
      
      txtDPStopPosition.doubleValue = item.dirPreviousStopPosition
      
      UnitLength.populate(comboBox: cboDPPositionUnits)
      UnitLength.select(comboBox: cboDPPositionUnits, value: item.dirPreviousUnitsPosition)
      
      // SPEED
      
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
      
    }
    
    setupControls()

  }
  
  // MARK: Private Properties
  
  private var item : SwitchBoardItem {
    get {
      return switchBoardItem!
    }
  }
  
  // MARK: Public Properties
  
  public var switchBoardItem : SwitchBoardItem?

  // MARK: Private Methods
  
  private func setupControls() {
    
    // GENERAL
    
    // OPTIONS
    
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
  
  @IBOutlet weak var cboPartType: NSComboBox!
  
  @IBAction func cboPartTypeAction(_ sender: NSComboBox) {
  }
  
  @IBOutlet weak var cboOrientation: NSComboBox!
  
  @IBAction func cboOrientationAction(_ sender: NSComboBox) {
  }
  
  @IBOutlet weak var txtXPos: NSTextField!
  
  @IBAction func txtXPosAction(_ sender: NSTextField) {
  }
  
  @IBOutlet weak var txtYPos: NSTextField!
  
  @IBAction func txtYPosAction(_ sender: NSTextField) {
  }
  
  @IBOutlet weak var txtName: NSTextField!
  
  @IBAction func txtNameAction(_ sender: NSTextField) {
  }
  
  @IBOutlet weak var cboTrackPartType: NSComboBox!
  
  @IBAction func cboTrackPartTypeAction(_ sender: NSComboBox) {
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
    
    item.orientation = Orientation.selected(comboBox: cboOrientation)
    
    item.trackElectrificationType = TrackElectrificationType.selected(comboBox: cboTrackElectrificationType)
    
    item.trackGauge = TrackGauge.selected(comboBox: cboTrackGauge)
    
    item.unitsDimension = UnitLength.selected(comboBox: cboDimensionUnits)
    
    item.location = (x: txtXPos.integerValue, y: txtYPos.integerValue)
    
    item.itemPartType = SwitchBoardItemPartType.selected(comboBox: cboPartType)

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
}
