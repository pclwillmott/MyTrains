//
//  SwitchBoardItemPropertySheetVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/06/2022.
//

import Cocoa

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
      for (key, item) in layout.switchBoardItems {
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
      
      chkCriticalSection.state = item.isCritical ? .on : .off
      
      chkScenicSection.state = item.isScenicSection ? .on : .off
      
      chkAllowShunt.state = item.allowShunt ? .on : .off
      
      UnitLength.populate(comboBox: cboDimensionUnits)
      UnitLength.select(comboBox: cboDimensionUnits, value: item.unitsDimension)
      
      // FEEDBACK
      
      // DIRECTION NEXT
      
      
    }

  }
  
  // MARK: Private Properties
  
  private var item : SwitchBoardItem {
    get {
      return switchBoardItem!
    }
  }
  
  // MARK: Public Properties
  
  public var switchBoardItem : SwitchBoardItem?

  /*
   enum SWITCHBOARD_ITEM {
     static let SWITCHBOARD_ITEM_ID         = "SWITCHBOARD_ITEM_ID"         x
     static let LAYOUT_ID                   = "LAYOUT_ID"                   x
     static let PANEL_ID                    = "PANEL_ID"                    x
     static let GROUP_ID                    = "GROUP_ID"                    x
     static let ITEM_PART_TYPE              = "ITEM_PART_TYPE"              x
     static let ORIENTATION                 = "ORIENTATION"                 x
     static let XPOS                        = "XPOS"                        x
     static let YPOS                        = "YPOS"                        x
     static let BLOCK_NAME                  = "BLOCK_NAME"                  x
     static let BLOCK_DIRECTION             = "BLOCK_DIRECTION"             x
     static let TRACK_PART_ID               = "TRACK_PART_ID"               x
     static let DIMENSIONA                  = "DIMENSIONA"                  x
     static let DIMENSIONB                  = "DIMENSIONB"                  x
     static let DIMENSIONC                  = "DIMENSIONC"                  x
     static let DIMENSIOND                  = "DIMENSIOND"                  x
     static let DIMENSIONE                  = "DIMENSIONE"                  x
     static let DIMENSIONF                  = "DIMENSIONF"                  x
     static let DIMENSIONG                  = "DIMENSIONG"                  x
     static let DIMENSIONH                  = "DIMENSIONH"                  x
     static let UNITS_DIMENSION             = "UNITS_DIMENSION"             x
     static let ALLOW_SHUNT                 = "ALLOW_SHUNT"                 x
     static let TRACK_GAUGE                 = "TRACK_GAUGE"                 x
     static let TRACK_ELECTRIFICATION_TYPE  = "TRACK_ELECTRIFICATION_TYPE"  x
     static let GRADIENT                    = "GRADIENT"                    x
     static let IS_CRITICAL                 = "IS_CRITICAL"                 x
     static let UNITS_SPEED                 = "UNITS_SPEED"                 x
     static let UNITS_POSITION              = "UNITS_POSITION"              x
     static let DN_BRAKE_POSITION           = "DN_BRAKE_POSITION"           x
     static let DN_STOP_POSITION            = "DN_STOP_POSITION"            x
     static let DN_SPEED_MAX                = "DN_SPEED_MAX"                x
     static let DN_SPEED_STOP_EXPECTED      = "DN_SPEED_STOP_EXPECTED"      x
     static let DN_SPEED_RESTRICTED         = "DN_SPEED_RESTRICTED"         x
     static let DN_SPEED_BRAKE              = "DN_SPEED_BRAKE"              x
     static let DN_SPEED_SHUNT              = "DN_SPEED_SHUNT"              x
     static let DN_SPEED_MAX_UD             = "DN_SPEED_MAX_UD"             x
     static let DN_SPEED_STOP_EXPECTED_UD   = "DN_SPEED_STOP_EXPECTED_UD"   x
     static let DN_SPEED_RESTRICTED_UD      = "DN_SPEED_RESTRICTED_UD"      x
     static let DN_SPEED_BRAKE_UD           = "DN_SPEED_BRAKE_UD"           x
     static let DN_SPEED_SHUNT_UD           = "DN_SPEED_SHUNT_UD"           x
     static let DP_BRAKE_POSITION           = "DP_BRAKE_POSITION"           x
     static let DP_STOP_POSITION            = "DP_STOP_POSITION"            x
     static let DP_SPEED_MAX                = "DP_SPEED_MAX"                x
     static let DP_SPEED_STOP_EXPECTED      = "DP_SPEED_STOP_EXPECTED"      x
     static let DP_SPEED_RESTRICTED         = "DP_SPEED_RESTRICTED"         x
     static let DP_SPEED_BRAKE              = "DP_SPEED_BRAKE"              x
     static let DP_SPEED_SHUNT              = "DP_SPEED_SHUNT"              x
     static let DP_SPEED_MAX_UD             = "DP_SPEED_MAX_UD"             x
     static let DP_SPEED_STOP_EXPECTED_UD   = "DP_SPEED_STOP_EXPECTED_UD"   x
     static let DP_SPEED_RESTRICTED_UD      = "DP_SPEED_RESTRICTED_UD"      x
     static let DP_SPEED_BRAKE_UD           = "DP_SPEED_BRAKE_UD"           x
     static let DP_SPEED_SHUNT_UD           = "DP_SPEED_SHUNT_UD"           x
     static let SW1_LOCONET_DEVICE_ID       = "SW1_LOCONET_DEVICE_ID"
     static let SW1_PORT                    = "SW1_PORT"
     static let SW1_TURNOUT_MOTOR_TYPE      = "SW1_TURNOUT_MOTOR_TYPE"
     static let SW1_SENSOR_ID               = "SW1_SENSOR_ID"
     static let SW2_LOCONET_DEVICE_ID       = "SW2_LOCONET_DEVICE_ID"
     static let SW2_PORT                    = "SW2_PORT"
     static let SW2_TURNOUT_MOTOR_TYPE      = "SW2_TURNOUT_MOTOR_TYPE"
     static let SW2_SENSOR_ID               = "SW2_SENSOR_ID"
     static let IS_SCENIC_SECTION           = "IS_SCENIC_SECTION"           x
   }

   */
  
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
  }
  
  @IBAction func btnDoneAction(_ sender: NSButton) {
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
  }
  
  @IBOutlet weak var chkDNStopExpectedUD: NSButton!
  
  @IBAction func chkDNStopExpectedUDAction(_ sender: NSButton) {
  }
  
  @IBOutlet weak var chkDNRestrictedUD: NSButton!
  
  @IBAction func chkDNRestrictedUDAction(_ sender: NSButton) {
  }
  
  @IBOutlet weak var chkDNBrakeUD: NSButton!
  
  @IBAction func chkDNBrakeUDAction(_ sender: NSButton) {
  }
  
  @IBOutlet weak var chkDNShuntUD: NSButton!
  
  @IBAction func chkDNShuntUDAction(_ sender: NSButton) {
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
  }
  
  @IBOutlet weak var chkDPMaxUD: NSButton!
  
  @IBAction func chkDPMaxUDAction(_ sender: NSButton) {
  }
  
  @IBOutlet weak var chkDPStopExpectedUD: NSButton!
  
  @IBAction func chkDPStopExpectedUDAction(_ sender: NSButton) {
  }
  
  @IBOutlet weak var chkDPRestrictedUD: NSButton!
  
  @IBAction func chkDPRestrictedUDAction(_ sender: NSButton) {
  }
  
  @IBOutlet weak var chkDPBrakeUD: NSButton!
  
  @IBAction func chkDPBrakeUDAction(_ sender: NSButton) {
  }
  
  @IBOutlet weak var chkDPShuntUD: NSButton!
  
  @IBAction func chkDPShuntUDAction(_ sender: NSButton) {
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
  }
  
  @IBOutlet weak var cboSpeedUnits: NSComboBox!
  
  @IBAction func btnSpeedUnitsAction(_ sender: NSComboBox) {
  }
  
  
  
}
