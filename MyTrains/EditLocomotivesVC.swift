//
//  EditLocomotivesVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 20/12/2021.
//

import Foundation
import Cocoa

class EditLocomotivesVC: NSViewController, NSWindowDelegate, DBEditorDelegate {
 
  // MARK: Window & View Control
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }

  func windowWillClose(_ notification: Notification) {
    stopModal()
  }
  
  override func viewWillAppear() {
    
    self.view.window?.delegate = self
    
    editorView.delegate = self
    
    editorView.tabView = tabView
    
    cboNetwork.dataSource = cboNetworkDS
    
    editorView.dictionary = networkController.locomotives

  }
  
  // MARK: Private Properties
  
  private var cboNetworkDS = ComboBoxDBDS(tableName: TABLE.NETWORK, codeColumn: NETWORK.NETWORK_ID, displayColumn: NETWORK.NETWORK_NAME, sortColumn: NETWORK.NETWORK_NAME)
  
  
  // MARK: DBEditorDelegate Methods
  
  func clearFields(dbEditorView: DBEditorView) {
    txtLocomotiveName.stringValue = ""
    cboPowerSource.selectItem(at: 0)
    cboTrackRestrictions.selectItem(at: 0)
    txtLength.stringValue = "0.0"
    cboLengthUnits.selectItem(at: UserDefaults.standard.integer(forKey: DEFAULT.UNITS_LENGTH))
    txtScale.stringValue = "\(UserDefaults.standard.double(forKey: DEFAULT.SCALE))"
    cboTrackGuage.selectItem(at: UserDefaults.standard.integer(forKey: DEFAULT.TRACK_GAUGE))
    cboDecoderType.selectItem(at: MobileDecoderType.dcc128A.rawValue)
    txtAddress.stringValue = "1"
    txtOccupancyFeedbackOffsetFront.stringValue = "0.0"
    txtOccupancyFeedbackOffsetRear.stringValue = "0.0"
    cboOccupancyFeedbackOffsetUnits.selectItem(at: UserDefaults.standard.integer(forKey: DEFAULT.UNITS_FBOFF_OCC))
    txtMaximumForwardSpeed.stringValue = "75.0"
    txtMaximumReverseSpeed.stringValue = "75.0"
    cboMaximumSpeedUnits.selectItem(at: UserDefaults.standard.integer(forKey: DEFAULT.UNITS_SPEED))
    cboNetwork.deselectItem(at: cboNetwork.indexOfSelectedItem)
    txtMaxCVNumber.stringValue = "255"
    lblManufacturer.stringValue = "Unknown"

  }
  
  func setupFields(dbEditorView: DBEditorView, editorObject: EditorObject) {
    if let locomotive = editorObject as? Locomotive {
      txtLocomotiveName.stringValue = locomotive.locomotiveName
      cboPowerSource.selectItem(at: locomotive.locomotiveType.rawValue)
      cboTrackRestrictions.selectItem(at: locomotive.trackRestriction.rawValue)
      txtLength.stringValue = "\(locomotive.length)"
      cboLengthUnits.selectItem(at: locomotive.lengthUnits.rawValue)
      txtScale.stringValue = "\(locomotive.locomotiveScale)"
      cboTrackGuage.selectItem(at: locomotive.trackGauge.rawValue)
      cboDecoderType.selectItem(at: locomotive.mobileDecoderType.rawValue)
      txtAddress.stringValue = "\(locomotive.address)"
      txtOccupancyFeedbackOffsetFront.stringValue = "\(locomotive.occupancyFeedbackOffsetFront)"
      txtOccupancyFeedbackOffsetRear.stringValue = "\(locomotive.occupancyFeedbackOffsetRear)"
      cboOccupancyFeedbackOffsetUnits.selectItem(at: locomotive.occupancyFeedbackOffsetUnits.rawValue)
      txtMaximumForwardSpeed.stringValue = "\(locomotive.maxForwardSpeed)"
      txtMaximumReverseSpeed.stringValue = "\(locomotive.maxBackwardSpeed)"
      cboMaximumSpeedUnits.selectItem(at: locomotive.speedUnits.rawValue)
      if let netIndex = cboNetworkDS.indexOfItemWithCodeValue(code: locomotive.networkId) {
        cboNetwork.selectItem(at: netIndex)
      }
      txtMaxCVNumber.stringValue = "\(locomotive.maxCVNumber)"
      lblManufacturer.stringValue = locomotive.decoderManufacturerName
    }
  }
  
  func validate(dbEditorView: DBEditorView) -> String? {
    if txtLocomotiveName.stringValue.trimmingCharacters(in: .whitespaces) == "" {
      txtLocomotiveName.becomeFirstResponder()
      return "The locomotive must have a name."
    }
    if let _ = Double(txtLength.stringValue) {
    }
    else {
      txtLength.becomeFirstResponder()
      return "A length greater than zero is required."
    }
    if let _ = Double(txtScale.stringValue) {
    }
    else {
      txtScale.becomeFirstResponder()
      return "A scale greater than zero is required."
    }
    if let maxCV = Int(txtMaxCVNumber.stringValue) {
      if maxCV < 1 || maxCV > 1024 {
        txtMaxCVNumber.becomeFirstResponder()
        return "An CV number in the range 1 to 1024 is required."
      }
    }
    else {
      txtMaxCVNumber.becomeFirstResponder()
      return "An CV number in the range 1 to 1024 is required."
    }
    if let address = Int(txtAddress.stringValue) {
      if address < 0 || address > 9983 {
        txtAddress.becomeFirstResponder()
        return "An address in the range 0 to 9983 is required."
      }
    }
    else {
      return "An address in the range 0 to 9983 is required."
    }
    if let _ = Double(txtOccupancyFeedbackOffsetFront.stringValue) {
    }
    else {
      txtOccupancyFeedbackOffsetFront.becomeFirstResponder()
      return "An offset greater than or equal to 0.0 is required."
    }
    if let _ = Double(txtOccupancyFeedbackOffsetRear.stringValue) {
    }
    else {
      txtOccupancyFeedbackOffsetRear.becomeFirstResponder()
      return "An offset greater than or equal to zero is required."
    }
    if let speed = Double(txtMaximumForwardSpeed.stringValue) {
      if speed <= 0.0 {
        return "A speed greater than zero is required."
      }
    }
    else {
      txtMaximumForwardSpeed.becomeFirstResponder()
      return "A speed greater than zero is required."
    }
    if let speed = Double(txtMaximumReverseSpeed.stringValue) {
      if speed <= 0.0 {
        return "A speed greater than zero is required."
      }
    }
    else {
      return "A speed greater than zero is required."
    }
    if cboNetwork.indexOfSelectedItem == -1 {
      cboNetwork.becomeFirstResponder()
      return "The locomotive must belong to a network."
    }
    return nil
  }
  
  func setFields(locomotive:Locomotive) {
    locomotive.locomotiveName = txtLocomotiveName.stringValue
    locomotive.locomotiveType = LocomotiveType(rawValue: cboPowerSource.indexOfSelectedItem) ?? .diesel
    locomotive.trackRestriction = TrackRestriction(rawValue: cboTrackRestrictions.indexOfSelectedItem) ?? .none
    locomotive.length = Double(txtLength.stringValue) ?? 0.0
    locomotive.lengthUnits = LengthUnit(rawValue: cboLengthUnits.indexOfSelectedItem) ?? .centimeters
    locomotive.locomotiveScale = Double(txtScale.stringValue) ?? 1.0
    locomotive.trackGauge = TrackGauge(rawValue: cboTrackGuage.indexOfSelectedItem) ?? .oo
    locomotive.mobileDecoderType = MobileDecoderType(rawValue: cboDecoderType.indexOfSelectedItem) ?? .dcc128A
    locomotive.address = Int(txtAddress.stringValue) ?? 1
    locomotive.occupancyFeedbackOffsetFront = Double(txtOccupancyFeedbackOffsetFront.stringValue) ?? 0.0
    locomotive.occupancyFeedbackOffsetRear = Double(txtOccupancyFeedbackOffsetRear.stringValue) ?? 0.0
    locomotive.occupancyFeedbackOffsetUnits = LengthUnit(rawValue: cboOccupancyFeedbackOffsetUnits.indexOfSelectedItem) ?? .centimeters
    locomotive.maxForwardSpeed = Double(txtMaximumForwardSpeed.stringValue) ?? 0.0
    locomotive.maxBackwardSpeed = Double(txtMaximumReverseSpeed.stringValue) ?? 0.0
    locomotive.speedUnits = SpeedUnit(rawValue: cboMaximumSpeedUnits.indexOfSelectedItem) ?? .kilometersPerHour
    locomotive.networkId = cboNetworkDS.codeForItemAt(index: cboNetwork.indexOfSelectedItem) ?? -1
    locomotive.maxCVNumber = Int(txtMaxCVNumber.stringValue) ?? 255
    locomotive.save()
  }

  func saveNew(dbEditorView: DBEditorView) -> EditorObject {
    let locomotive = Locomotive()
    setFields(locomotive: locomotive)
    networkController.addLocomotive(locomotive: locomotive)
    editorView.dictionary = networkController.locomotives
    editorView.setSelection(key: locomotive.primaryKey)
    return locomotive
  }
  
  func saveExisting(dbEditorView: DBEditorView, editorObject: EditorObject) {
    if let locomotive = editorObject as? Locomotive {
      setFields(locomotive: locomotive)
      editorView.dictionary = networkController.locomotives
      editorView.setSelection(key: locomotive.primaryKey)
    }
  }
  
  func delete(dbEditorView: DBEditorView, primaryKey: Int) {
    networkController.removeLocomotive(primaryKey: primaryKey)
    Locomotive.delete(primaryKey: primaryKey)
    editorView.dictionary = networkController.locomotives
  }
  
  // MARK: Outlets & Actions
  
  @IBOutlet weak var tabView: NSTabView!
  
  @IBOutlet weak var editorView: DBEditorView!
  
  @IBOutlet weak var txtLocomotiveName: NSTextField!
  
  @IBAction func txtLocomotiveAction(_ sender: NSTextField) {
    editorView.modified = true
  }
  
  @IBOutlet weak var cboPowerSource: NSComboBox!
  
  @IBAction func cboPowerSourceAction(_ sender: NSComboBox) {
    editorView.modified = true
  }
  
  @IBOutlet weak var cboTrackRestrictions: NSComboBox!
  
  @IBAction func cboTrackRestrictionsAction(_ sender: NSComboBox) {
    editorView.modified = true
  }
  
  @IBOutlet weak var txtLength: NSTextField!
  
  @IBAction func txtLengthAction(_ sender: NSTextField) {
  }
  
  @IBOutlet weak var cboLengthUnits: NSComboBox!
  
  @IBAction func cboLengthUnitsAction(_ sender: NSComboBox) {
    editorView.modified = true
    UserDefaults.standard.set(cboLengthUnits.indexOfSelectedItem, forKey: DEFAULT.UNITS_LENGTH)
  }
  
  @IBOutlet weak var txtScale: NSTextField!
  
  @IBAction func txtScaleAction(_ sender: NSTextField) {
    editorView.modified = true
    if let scale = Double(txtScale.stringValue) {
      UserDefaults.standard.set(scale, forKey: DEFAULT.SCALE)
    }
  }
  
  @IBOutlet weak var cboTrackGuage: NSComboBox!
  
  @IBAction func cboTrackGaugeAction(_ sender: NSComboBox) {
    editorView.modified = true
    UserDefaults.standard.set(cboTrackGuage.indexOfSelectedItem, forKey: DEFAULT.TRACK_GAUGE)
  }
  
  @IBOutlet weak var cboDecoderType: NSComboBox!
    
  @IBAction func cboDecoderTypeAction(_ sender: NSComboBox) {
    editorView.modified = true
  }
  
  @IBOutlet weak var txtAddress: NSTextField!
  
  @IBAction func txtAddressAction(_ sender: NSTextField) {
    editorView.modified = true
  }
  
  @IBOutlet weak var txtOccupancyFeedbackOffsetFront: NSTextField!
    
  @IBAction func txtOccupancyFeedbackOffsetFrontAction(_ sender: NSTextField) {
    editorView.modified = true
  }
  
  @IBOutlet weak var txtOccupancyFeedbackOffsetRear: NSTextField!
  
  @IBAction func txtOccupancyFeedbackOffsetRearAction(_ sender: NSTextField) {
    editorView.modified = true
  }
  
  @IBOutlet weak var cboOccupancyFeedbackOffsetUnits: NSComboBox!
  
  @IBAction func cboOccupancyFeedbackOffsetUnitsAction(_ sender: NSComboBox) {
    editorView.modified = true
    UserDefaults.standard.set(cboOccupancyFeedbackOffsetUnits.indexOfSelectedItem, forKey: DEFAULT.UNITS_FBOFF_OCC)
  }
  
  @IBOutlet weak var txtMaximumForwardSpeed: NSTextField!
  
  @IBAction func txtMaximumForwardSpeedAction(_ sender: NSTextField) {
    editorView.modified = true
  }
  
  @IBOutlet weak var txtMaximumReverseSpeed: NSTextField!
  
  @IBAction func txtMaximumReverseSpeedAction(_ sender: NSTextField) {
    editorView.modified = true
  }
  
  @IBOutlet weak var cboMaximumSpeedUnits: NSComboBox!
  
  @IBAction func cboMaximumSpeedUnitsAction(_ sender: NSComboBox) {
    editorView.modified = true
    UserDefaults.standard.set(cboMaximumSpeedUnits.indexOfSelectedItem, forKey: DEFAULT.UNITS_SPEED)
  }
  
  @IBOutlet weak var cboNetwork: NSComboBox!
  
  @IBAction func cboNetworkAction(_ sender: NSComboBox) {
    editorView.modified = true
  }
  
  @IBOutlet weak var txtMaxCVNumber: NSTextField!
  
  @IBAction func txtMaxCVNumberAction(_ sender: NSTextField) {
    editorView.modified = true
  }
 
  @IBOutlet weak var lblManufacturer: NSTextField!
  
}
