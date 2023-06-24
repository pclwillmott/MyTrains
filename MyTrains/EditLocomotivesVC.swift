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
    
    editorView.tabView = tabView
    
    LocomotiveType.populate(comboBox: cboPowerSource)
    
    cboNetwork.dataSource = cboNetworkDS
    
    editorView.dictionary = myTrainsController.rollingStock
    
    UnitLength.populate(comboBox: cboLengthUnits)
    UnitLength.populate(comboBox: cboOccupancyFeedbackOffsetUnits)
    TrackGauge.populate(comboBox: cboTrackGuage)
    UnitSpeed.populate(comboBox: cboMaximumSpeedUnits)
    
    SpeedSteps.populate(comboBox: cboDecoderType)
    
    cboDecoderModel.dataSource = cboDecoderModelDS
    
    cboModelManufacturerDS.dictionary = NMRA.manufacturersComboDict
    cboModelManufacturer.dataSource = cboModelManufacturerDS
    
    editorView.delegate = self
    
  }
  
  // MARK: Private Properties
  
  private var cvTableViewDS = CVTableViewDS()

  private var cboNetworkDS = ComboBoxDBDS(tableName: TABLE.NETWORK, codeColumn: NETWORK.NETWORK_ID, displayColumn: NETWORK.NETWORK_NAME, sortColumn: NETWORK.NETWORK_NAME)
  
  private var cboDecoderModelDS = ComboBoxDBDS(tableName: TABLE.ROLLING_STOCK, codeColumn: ROLLING_STOCK.ROLLING_STOCK_ID, displayColumn: ROLLING_STOCK.MDECODER_MODEL, sortColumn: ROLLING_STOCK.MDECODER_MODEL, groupItems: true)
  
  private var cboModelManufacturerDS = ComboBoxDictDS()
  
//  private var fnTableViewDS = FNTableViewDS()
  
  // MARK: DBEditorDelegate Methods
  
  func clearFields(dbEditorView: DBEditorView) {
    txtLocomotiveName.stringValue = ""
    cboPowerSource.selectItem(at: 0)
    txtLength.stringValue = "0.0"
    cboLengthUnits.selectItem(at: UserDefaults.standard.integer(forKey: DEFAULT.UNITS_LENGTH))
    txtScale.stringValue = "\(UserDefaults.standard.double(forKey: DEFAULT.SCALE))"
    cboTrackGuage.selectItem(at: UserDefaults.standard.integer(forKey: DEFAULT.TRACK_GAUGE))
    chkMobileDecoderInstalled.state = .off
    chkAccessoryDecoderInstalled.state = .off
    SpeedSteps.select(comboBox: cboDecoderType, value: SpeedSteps.defaultValue)
    txtAddress.stringValue = ""
    txtAccessoryDecoderAddress.stringValue = ""
    txtOccupancyFeedbackOffsetFront.stringValue = "0.0"
    txtOccupancyFeedbackOffsetRear.stringValue = "0.0"
    cboOccupancyFeedbackOffsetUnits.selectItem(at: UserDefaults.standard.integer(forKey: DEFAULT.UNITS_FBOFF_OCC))
    txtMaximumForwardSpeed.stringValue = "75.0"
    txtMaximumReverseSpeed.stringValue = "75.0"
    cboMaximumSpeedUnits.selectItem(at: UserDefaults.standard.integer(forKey: DEFAULT.UNITS_SPEED))
    cboNetwork.deselectItem(at: cboNetwork.indexOfSelectedItem)
    lblManufacturer.stringValue = "Unknown"
    lblAccessoryDecoderManufacturer.stringValue = "Unknown"
    cboDecoderModel.stringValue = ""
    cboAccessoryDecoderModel.stringValue = ""
    txtInventoryCode.stringValue = ""
    cboModelManufacturer.stringValue = ""
    txtPurchaseDate.stringValue = ""
    txtNotes.string = ""
    cboModelManufacturer.deselectItem(at: cboModelManufacturer.indexOfSelectedItem)
  }
  
  func setupFields(dbEditorView: DBEditorView, editorObject: EditorObject) {
    
    if let locomotive = editorObject as? RollingStock {
      txtLocomotiveName.stringValue = locomotive.rollingStockName
      cboPowerSource.selectItem(at: locomotive.locomotiveType.rawValue)
      txtLength.stringValue = "\(locomotive.length)"
      cboLengthUnits.selectItem(at: locomotive.unitsLength.rawValue)
      txtScale.stringValue = "\(locomotive.scale)"
      cboTrackGuage.selectItem(at: locomotive.trackGauge.rawValue)
      chkMobileDecoderInstalled.state = locomotive.mDecoderInstalled ? .on : .off
      chkAccessoryDecoderInstalled.state = locomotive.aDecoderInstalled ? .on : .off
      SpeedSteps.select(comboBox: cboDecoderType, value: locomotive.speedSteps)
      txtAddress.stringValue = locomotive.mDecoderAddress == 0 ? "" : "\(locomotive.mDecoderAddress)"
      txtAccessoryDecoderAddress.stringValue = locomotive.aDecoderAddress == -1 ? "" : "\(locomotive.aDecoderAddress)"
      txtOccupancyFeedbackOffsetFront.stringValue = "\(locomotive.feedbackOccupancyOffsetFront)"
      txtOccupancyFeedbackOffsetRear.stringValue = "\(locomotive.feedbackOccupancyOffsetRear)"
      cboOccupancyFeedbackOffsetUnits.selectItem(at: locomotive.unitsFeedbackOccupancyOffset.rawValue)
      txtMaximumForwardSpeed.stringValue = "\(locomotive.maxForwardSpeed)"
      txtMaximumReverseSpeed.stringValue = "\(locomotive.maxBackwardSpeed)"
      cboMaximumSpeedUnits.selectItem(at: locomotive.unitsSpeed.rawValue)
      if let netIndex = cboNetworkDS.indexOfItemWithCodeValue(code: locomotive.networkId) {
        cboNetwork.selectItem(at: netIndex)
      }
      lblManufacturer.stringValue = locomotive.decoderManufacturerName
      cboDecoderModel.stringValue = locomotive.mDecoderModel
      cboAccessoryDecoderModel.stringValue = locomotive.aDecoderModel
      txtInventoryCode.stringValue = locomotive.inventoryCode
      cboModelManufacturer.selectItem(at: cboModelManufacturerDS.indexWithKey(key: locomotive.manufacturerId) ?? -1)
      txtPurchaseDate.stringValue = locomotive.purchaseDate
      txtNotes.string = locomotive.notes
  //    fnTableViewDS.fns = locomotive.functions
  //    fnTableView.dataSource = fnTableViewDS
  //    fnTableView.delegate = fnTableViewDS
      fnTableView.reloadData()
      cvTableViewDS.cvs = locomotive.cvsSorted
      cvTableView.dataSource = cvTableViewDS
      cvTableView.delegate = cvTableViewDS
      cvTableView.reloadData()
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
  
  func setFields(locomotive:RollingStock) {
    locomotive.rollingStockName = txtLocomotiveName.stringValue
    locomotive.locomotiveType = LocomotiveType.getType(forName: cboPowerSource.stringValue)
    locomotive.length = Double(txtLength.stringValue) ?? 0.0
    locomotive.unitsLength = UnitLength(rawValue: cboLengthUnits.indexOfSelectedItem) ?? UnitLength.defaultValue
    locomotive.scale = Double(txtScale.stringValue) ?? 1.0
    locomotive.trackGauge = TrackGauge(rawValue: cboTrackGuage.indexOfSelectedItem) ?? TrackGauge.defaultValue
    locomotive.speedSteps = SpeedSteps.selected(comboBox: cboDecoderType)
    locomotive.mDecoderAddress = UInt16(txtAddress.stringValue) ?? 0
    locomotive.aDecoderAddress = Int(txtAccessoryDecoderAddress.stringValue) ?? -1
    locomotive.mDecoderInstalled = chkMobileDecoderInstalled.state == .on
    locomotive.aDecoderInstalled = chkAccessoryDecoderInstalled.state == .on
    locomotive.feedbackOccupancyOffsetFront = Double(txtOccupancyFeedbackOffsetFront.stringValue) ?? 0.0
    locomotive.feedbackOccupancyOffsetRear = Double(txtOccupancyFeedbackOffsetRear.stringValue) ?? 0.0
    locomotive.unitsFeedbackOccupancyOffset = UnitLength(rawValue: cboOccupancyFeedbackOffsetUnits.indexOfSelectedItem) ?? UnitLength.defaultValue
    locomotive.maxForwardSpeed = Double(txtMaximumForwardSpeed.stringValue) ?? 0.0
    locomotive.maxBackwardSpeed = Double(txtMaximumReverseSpeed.stringValue) ?? 0.0
    locomotive.unitsSpeed = UnitSpeed(rawValue: cboMaximumSpeedUnits.indexOfSelectedItem) ?? UnitSpeed.defaultValue
    locomotive.networkId = cboNetworkDS.codeForItemAt(index: cboNetwork.indexOfSelectedItem) ?? -1
    locomotive.mDecoderModel = cboDecoderModel.stringValue
    locomotive.aDecoderModel = cboAccessoryDecoderModel.stringValue
    locomotive.inventoryCode = txtInventoryCode.stringValue
    locomotive.manufacturerId = cboModelManufacturerDS.editorObjectAt(index: cboModelManufacturer.indexOfSelectedItem)?.primaryKey ?? -1
    locomotive.purchaseDate = txtPurchaseDate.stringValue
    locomotive.notes = txtNotes.string
    locomotive.save()
  }

  func saveNew(dbEditorView: DBEditorView) -> EditorObject {
    
    let locomotive = RollingStock(primaryKey: -1)
    setFields(locomotive: locomotive)
    myTrainsController.addRollingStock(rollingStock: locomotive)
    editorView.dictionary = myTrainsController.rollingStock
    editorView.setSelection(key: locomotive.primaryKey)
    return locomotive
    
  }
  
  func saveExisting(dbEditorView: DBEditorView, editorObject: EditorObject) {
    
    if let locomotive = editorObject as? RollingStock {
      setFields(locomotive: locomotive)
      editorView.dictionary = myTrainsController.rollingStock
      editorView.setSelection(key: locomotive.primaryKey)
    }
     
  }
  
  func delete(dbEditorView: DBEditorView, primaryKey: Int) {
    
    myTrainsController.removeRollingStock(primaryKey: primaryKey)
    RollingStock.delete(primaryKey: primaryKey)
    editorView.dictionary = myTrainsController.rollingStock
     
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
  
  @IBOutlet weak var lblManufacturer: NSTextField!
  
  @IBOutlet weak var cboDecoderModel: NSComboBox!
  
  @IBAction func cboDecoderModelAction(_ sender: NSComboBox) {
    editorView.modified = true
  }
  
  @IBOutlet weak var cboModelManufacturer: NSComboBox!
  
  @IBAction func cboModelManufacturerAction(_ sender: NSComboBox) {
    editorView.modified = true
  }
  
  @IBOutlet weak var txtPurchaseDate: NSTextField!
  
  @IBAction func txtPurchaseDateAction(_ sender: NSTextField) {
    editorView.modified = true
  }
  
  @IBOutlet weak var txtInventoryCode: NSTextField!
  
  @IBAction func txtInventoryCodeAction(_ sender: NSTextField) {
    editorView.modified = true
  }
  
  @IBOutlet var txtNotes: NSTextView!
  
  @IBOutlet weak var fnTableView: NSTableView!
  
  @IBAction func fnTableViewAction(_ sender: NSTableView) {
    editorView.modified = true
  }
  
  @IBAction func chkFNEnabledAction(_ sender: NSButton) {
    /*
    if let loco = editorView.editorObject as? Locomotive {
 //     loco.functions[sender.tag].newIsEnabled = sender.state == .on
    }
    editorView.modified = true
     */
  }
  
  @IBAction func chkFNMomentaryAction(_ sender: NSButton) {
    /*
    if let loco = editorView.editorObject as? Locomotive {
//      loco.functions[sender.tag].newIsMomentary = sender.state == .on
    }
    editorView.modified = true
     */
  }
  
  @IBAction func txtDurationAction(_ sender: NSTextField) {
    /*
    if let loco = editorView.editorObject as? Locomotive {
      var reset = true
      if let duration = Int(sender.stringValue) {
        if duration >= 0 {
  //        loco.functions[sender.tag].newDuration = duration
          reset = false
        }
      }
      if reset {    
 //       sender.stringValue = "\(loco.functions[sender.tag].newDuration)"
      }
    }
    editorView.modified = true
     */
  }
  
  @IBAction func chkFNInvertedAction(_ sender: NSButton) {
    /*
    if let loco = editorView.editorObject as? Locomotive {
//      loco.functions[sender.tag].newIsInverted = sender.state == .on
    }
    editorView.modified = true
     */
  }
  
  @IBAction func cboDescriptionAction(_ sender: NSComboBox) {
    /*
    if let loco = editorView.editorObject as? Locomotive {
//      loco.functions[sender.tag].newFunctionDescription = sender.stringValue
    }
    editorView.modified = true
     */
  }
  
  @IBOutlet weak var cvTableView: NSTableView!
  
  @IBAction func cvTableViewAction(_ sender: NSTableView) {
  }
  
  @IBAction func chkSupportedAction(_ sender: NSButton) {
    let cv = cvTableViewDS.cvs[sender.tag]
    cv.isEnabled = sender.state == .on
    cv.save()
  }
  
  @IBAction func txtDescriptionAction(_ sender: NSTextField) {
    let cv = cvTableViewDS.cvs[sender.tag]
    let trim = sender.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
    cv.customDescription = trim
    if trim == "" {
      sender.stringValue = NMRA.cvDescription(cv: cv.cvNumber)
    }
    cv.save()
  }
  
  @IBAction func cboNumberBaseAction(_ sender: NSComboBox) {
    let cv = cvTableViewDS.cvs[sender.tag]
    cv.customNumberBase = CVNumberBase(rawValue: sender.indexOfSelectedItem) ?? .decimal
    cv.save()
    cvTableView.reloadData()
  }
  
  @IBAction func txtDefaultValueAction(_ sender: NSTextField) {
    let cv = cvTableViewDS.cvs[sender.tag]
    var reset = true
    if let newValue = Int.fromMultiBaseString(stringValue: sender.stringValue) {
      if newValue >= 0 && newValue < 256 {
        reset = false
        cv.defaultValue = newValue
        cv.save()
      }
    }
    if reset {
      sender.stringValue = "\(cv.displayDefaultValue)"
    }
  }
  
  @IBAction func txtValueAction(_ sender: NSTextField) {
    let cv = cvTableViewDS.cvs[sender.tag]
    var reset = true
    if let newValue = Int.fromMultiBaseString(stringValue: sender.stringValue) {
      if newValue >= 0 && newValue < 256 {
        reset = false
        cv.cvValue = newValue
        cv.save()
      }
    }
    if reset {
      sender.stringValue = "\(cv.displayCVValue)"
    }
  }
  
  @IBOutlet weak var chkMobileDecoderInstalled: NSButton!
  
  @IBAction func chkMobileDecoderInstalledAction(_ sender: NSButton) {
  }
  
  @IBOutlet weak var chkAccessoryDecoderInstalled: NSButton!
  
  @IBAction func chkAccessoryDecoderInstalledAction(_ sender: NSButton) {
  }
  
  @IBOutlet weak var lblAccessoryDecoderManufacturer: NSTextField!
  
  @IBOutlet weak var cboAccessoryDecoderModel: NSComboBox!
  
  @IBAction func cboAccessoryDecoderModelAction(_ sender: NSComboBox) {
  }
  
  @IBOutlet weak var txtAccessoryDecoderAddress: NSTextField!
  
  @IBAction func txtAccessoryDecoderAddressAction(_ sender: NSTextField) {
  }
  
  
}
