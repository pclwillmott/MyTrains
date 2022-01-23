//
//  ProgramDecoderAddressVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/01/2022.
//

import Foundation
import Cocoa

class ProgramDecoderAddressVC : NSViewController, NSWindowDelegate, CommandStationDelegate, CSVParserDelegate {

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
    
    cboLocomotiveDS.dictionary = networkController.locomotives
    
    cboLocomotive.dataSource = cboLocomotiveDS
    
    cboCommandStationDS.dictionary = networkController.commandStations
    
    cboCommandStation.dataSource = cboCommandStationDS
    
    if cboCommandStation.numberOfItems > 0 {
      cboCommandStation.selectItem(at: 0)
    }
    
    setup()
    
  }
  
  // MARK: Private Enums
  
  private enum ProgrammerState {
    case idle
    case waitingForReadCV29Ack
    case waitingForReadCV29Data
    case waitingForReadCV01Ack
    case waitingForReadCV01Data
    case waitingForReadCV17Ack
    case waitingForReadCV17Data
    case waitingForReadCV18Ack
    case waitingForReadCV18Data
    case waitingForWriteReadCV29Ack
    case waitingForWriteReadCV29Data
    case waitingForWriteCV29Ack
    case waitingForWriteCV29Data
    case waitingForWriteCV01Ack
    case waitingForWriteCV01Data
    case waitingForWriteCV17Ack
    case waitingForWriteCV17Data
    case waitingForWriteCV18Ack
    case waitingForWriteCV18Data
    case waitingForReadCVAck
    case waitingForReadCVData
    case waitingForIndexedReadWriteCV31Ack
    case waitingForIndexedReadWriteCV31Data
    case waitingForIndexedReadWriteCV32Ack
    case waitingForIndexedReadWriteCV32Data
    case waitingForIndexedWriteWriteCV31Ack
    case waitingForIndexedWriteWriteCV31Data
    case waitingForIndexedWriteWriteCV32Ack
    case waitingForIndexedWriteWriteCV32Data
    case waitingForWriteCVAck
    case waitingForWriteCVData
    case writeMultipleState1
    case writeMultipleState2
    case writeMultipleState3
    case writeMultipleState4
    case writeMultipleState5
    case writeMultipleState6
  }
  
  // MARK: Private Properties
  
  private var cboLocomotiveDS : ComboBoxDictDS = ComboBoxDictDS()
  
  private var cboCommandStationDS : CommmandStationComboBoxDS = CommmandStationComboBoxDS()
  
  private var locomotive : Locomotive? {
    get {
      var result : Locomotive? = nil
      if let editorObject = cboLocomotiveDS.editorObjectAt(index: cboLocomotive.indexOfSelectedItem) {
        result = networkController.locomotives[editorObject.primaryKey]
      }
      return result
    }
  }
  
  private var delegateId : Int = -1
  
  private var commandStation : CommandStation?
  
  private var programmerState : ProgrammerState = .idle
  
  private var shortAddress : Bool = true
  
  private var cv29 : Int = 0
  
  private var cv01 : Int = 0
  
  private var cv17 : Int = 0
  
  private var cv18 : Int = 0
  
  private var address : Int = 0
  
  private var writeValue : Int = 0
  
  private var writeCV : LocomotiveCV?
  
  private var startAddress : Int = 1
  
  private var endAddress : Int = 256
  
  private var isIndexedMode : Bool = false
  
  private var cv31 : Int = 16
  
  private var cv32 : Int = 0
  
  private var readCV : Int = 1
  
  private var cancelRead : Bool = false
  
  private var cvTableViewDS = CVTableViewDS()
  
  private var writeMultipleIndex : Int = 0
  
  private var csvParser : CSVParser?
  
  // MARK: Private Methods
  
  private func setup() {
  
    if delegateId != -1 {
      commandStation?.removeDelegate(id: delegateId)
      delegateId = -1
      commandStation = nil
    }
    
    if let cs = cboCommandStationDS.commandStationAt(index: cboCommandStation.indexOfSelectedItem) {
      commandStation = cs
      delegateId = cs.addDelegate(delegate: self)
    }
    
    if let loco = locomotive {
      txtAddress.stringValue = "\(loco.address)"
    }
    else {
      txtAddress.stringValue = "0"
    }
    
    btnWrite.isEnabled = cboLocomotive.indexOfSelectedItem >= 0 && cboCommandStation.indexOfSelectedItem >= 0
    
    btnRead.isEnabled = btnWrite.isEnabled
    
    btnCancelReadCVValues.isEnabled = false
    btnReadCVValues.isEnabled = cboLocomotive.indexOfSelectedItem != -1
    chkSetDefaults.isEnabled = true
    chkSetDefaults.state = .off
    btnWriteCVValues.isEnabled = btnReadCVValues.isEnabled
    btnImportCVs.isEnabled = btnReadCVValues.isEnabled
    btnExportCVs.isEnabled = btnReadCVValues.isEnabled

    if let loco = locomotive {
      cvTableViewDS.cvs = loco.cvsSorted
      cvTableView.dataSource = cvTableViewDS
      cvTableView.delegate = cvTableViewDS
      cvTableView.reloadData()
      txtPrimaryPageIndex.stringValue = "\(loco.getCV(cvNumber: 31)?.cvValue ?? 16)"
      txtSecondaryPageIndex.stringValue = "\(loco.getCV(cvNumber: 32)?.cvValue ?? 1)"
    }
    
    radRegularCVs.state = isIndexedMode ? .off : .on
    radIndexedCVs.state = isIndexedMode ? .on : .off
    
    txtPrimaryPageIndex.isEnabled = isIndexedMode
    txtSecondaryPageIndex.isEnabled = isIndexedMode
    
  }
  
  private func findNextCVToWrite() -> LocomotiveCV? {
    
    while writeMultipleIndex < cvTableView.numberOfRows {
      
      let cv = cvTableViewDS.cvs[writeMultipleIndex]

      if cv.newValue != "" {
        return cv
      }
      
      writeMultipleIndex += 1
      
    }
    
    return nil
  }
  
  private func validate() -> Bool {
    
    var good = true
    
    if let address = Int(txtAddress.stringValue) {
      
      if address < 0 || address > 9983 {
        good = false
      }
    }
    else {
      good = false
    }
    
    if !good {
      let alert = NSAlert()

      alert.messageText = "Invalid Address"
      alert.informativeText = "An address in the range 0 to 9983 is required."
      alert.addButton(withTitle: "OK")
   // alert.addButton(withTitle: "Cancel")
      alert.alertStyle = .critical

      let _ = alert.runModal() // == NSAlertFirstButtonReturn
    }
    
    if good {
      
      if let cv = Int(txtPrimaryPageIndex.stringValue) {
        
        if cv < 0 || cv > 255 {
          good = false
        }
      }
      else {
        good = false
      }
      
      if !good {
        let alert = NSAlert()

        alert.messageText = "Invalid Page Number"
        alert.informativeText = "A page number in the range 0 to 255 is required."
        alert.addButton(withTitle: "OK")
     // alert.addButton(withTitle: "Cancel")
        alert.alertStyle = .critical

        let _ = alert.runModal() // == NSAlertFirstButtonReturn
      }

      if good {
        
        if let cv = Int(txtSecondaryPageIndex.stringValue) {
          
          if cv < 0 || cv > 255 {
            good = false
          }
        }
        else {
          good = false
        }
        
        if !good {
          let alert = NSAlert()

          alert.messageText = "Invalid Page Number"
          alert.informativeText = "A page number in the range 0 to 255 is required."
          alert.addButton(withTitle: "OK")
       // alert.addButton(withTitle: "Cancel")
          alert.alertStyle = .critical

          let _ = alert.runModal() // == NSAlertFirstButtonReturn
        }
      }
    }
    
    return good
    
  }
  
  private func saveAddress(address: Int) {
    if let loco = locomotive {
      loco.address = address
      loco.save()
    }
  }
  
  // MARK: CommandStationDelegate Methods
  
  @objc func progMessageReceived(message: NetworkMessage) {
    
    switch message.messageType {
    case .progCmdAccepted:
      var message = ""
      switch programmerState {
      case .waitingForReadCV29Ack:
        programmerState = .waitingForReadCV29Data
        message = "Reading CV29"
        break
      case .waitingForReadCV01Ack:
        programmerState = .waitingForReadCV01Data
        message = "Reading CV01"
        break
      case .waitingForReadCV17Ack:
        programmerState = .waitingForReadCV17Data
        message = "Reading CV17"
        break
      case .waitingForReadCV18Ack:
        programmerState = .waitingForReadCV18Data
        message = "Reading CV18"
        break
      case .waitingForWriteReadCV29Ack:
        programmerState = .waitingForWriteReadCV29Data
        message = "Reading CV29"
      case .waitingForWriteCV29Ack:
        programmerState = .waitingForWriteCV29Data
        message = "Writing CV29"
      case .waitingForWriteCV01Ack:
        programmerState = .waitingForWriteCV01Data
        message = "Writing CV01"
      case .waitingForWriteCV17Ack:
        programmerState = .waitingForWriteCV17Data
        message = "Writing CV17"
      case .waitingForWriteCV18Ack:
        programmerState = .waitingForWriteCV18Data
        message = "Writing CV18"
      case .waitingForReadCVAck:
        programmerState = .waitingForReadCVData
        lblReadCVStatus.stringValue = "Reading CV\(readCV)"
      case .waitingForIndexedReadWriteCV31Ack:
        programmerState = .waitingForIndexedReadWriteCV31Data
        lblReadCVStatus.stringValue = "Writing CV31"
      case .waitingForIndexedReadWriteCV32Ack:
        programmerState = .waitingForIndexedReadWriteCV32Data
        lblReadCVStatus.stringValue = "Writing CV32"
      case .waitingForIndexedWriteWriteCV31Ack:
        programmerState = .waitingForIndexedWriteWriteCV31Data
        lblReadCVStatus.stringValue = "Writing CV31"
      case .waitingForIndexedWriteWriteCV32Ack:
        programmerState = .waitingForIndexedWriteWriteCV32Data
        lblReadCVStatus.stringValue = "Writing CV32"
      case .waitingForWriteCVAck:
        programmerState = .waitingForWriteCVData
        lblReadCVStatus.stringValue = "Writing CV\(writeCV!.displayCVNumber)"
      case .writeMultipleState1:
        programmerState = .writeMultipleState2
        lblReadCVStatus.stringValue = "Writing CV31"
      case .writeMultipleState3:
        programmerState = .writeMultipleState4
        lblReadCVStatus.stringValue = "Writing CV32"
      case .writeMultipleState5:
        programmerState = .writeMultipleState6
        lblReadCVStatus.stringValue = "Writing CV\(readCV)"
      default:
        break
      }
      lblStatus.stringValue = message
      break
    case .progCmdAcceptedBlind:
      commandStation?.getProgSlotDataP1()
      break
    case .progSlotDataP1:
      
      let psd = ProgSlotDataP1(interfaceId: message.interfaceId, data: message.message)
      
      if psd.status == .success {
        
        var message = ""
        
        switch programmerState {
        case .waitingForReadCV29Data:
          cv29 = psd.value
          shortAddress = cv29 & 0b00100000 == 0x00
          if shortAddress {
            programmerState = .waitingForReadCV01Ack
            commandStation?.readCV(cv: 01)
          }
          else {
            programmerState = .waitingForReadCV17Ack
            commandStation?.readCV(cv: 17)
          }
          break
        case .waitingForReadCV01Data:
          cv01 = psd.value
          address = cv01
          txtAddress.stringValue = "\(address)"
          message = "Read Completed"
          saveAddress(address: address)
          programmerState = .idle
          break
        case .waitingForReadCV17Data:
          cv17 = psd.value
        
          programmerState = .waitingForReadCV18Ack
          commandStation?.readCV(cv: 18)
          break
        case .waitingForReadCV18Data:
          cv18 = psd.value
          address = Locomotive.decoderAddress(cv17: cv17, cv18: cv18)
          txtAddress.stringValue = "\(address)"
          message = "Read Completed"
          saveAddress(address: address)
          programmerState = .idle
          break
        case .waitingForWriteReadCV29Data:
          address = txtAddress.integerValue
          cv29 = psd.value & 0b11011111
          cv29 |= address > 127 ? 0b00100000 : 0x00
          programmerState = .waitingForWriteCV29Ack
          commandStation?.writeCV(cv: 29, value: cv29)
          break
        case .waitingForWriteCV29Data:
          if address > 127 {
            cv17 = Locomotive.cv17(address: address)
            programmerState = .waitingForWriteCV17Ack
            commandStation?.writeCV(cv: 17, value: cv17)
          }
          else {
            cv01 = address
            programmerState = .waitingForWriteCV01Ack
            commandStation?.writeCV(cv: 1, value: cv01)
          }
          break
        case .waitingForIndexedReadWriteCV31Data:
          programmerState = .waitingForIndexedReadWriteCV32Ack
          commandStation?.writeCV(cv: 32, value: cv32)
          break
        case .waitingForIndexedReadWriteCV32Data:
          programmerState = .waitingForReadCVAck
          commandStation?.readCV(cv: readCV)
        case .waitingForWriteCV01Data:
          programmerState = .idle
          saveAddress(address: address)
          message = "Write Completed"
          break
        case .waitingForWriteCV17Data:
          cv18 = Locomotive.cv18(address: address)
          programmerState = .waitingForWriteCV18Ack
          commandStation?.writeCV(cv: 18, value: cv18)
          break
        case .waitingForWriteCV18Data:
          programmerState = .idle
          saveAddress(address: address)
          message = "Write Completed"
          break
        case .waitingForWriteCVData:
          programmerState = .idle
          writeCV!.cvValue = writeValue
          writeCV!.save()
          message = "Write Completed"
          lblReadCVStatus.stringValue = message
        case .waitingForIndexedWriteWriteCV31Data:
          if let cvx = locomotive?.getCV(cvNumber: 31) {
            cvx.cvValue = cv31
            cvx.save()
            txtPrimaryPageIndex.stringValue = "\(cv31)"
          }
          programmerState = .waitingForIndexedWriteWriteCV32Ack
          commandStation?.writeCV(cv: 32, value: cv32)
        case .waitingForIndexedWriteWriteCV32Data:
          if let cvx = locomotive?.getCV(cvNumber: 32) {
            cvx.cvValue = cv32
            cvx.save()
            txtSecondaryPageIndex.stringValue = "\(cv32)"
          }
          programmerState = .waitingForWriteCVAck
          commandStation?.writeCV(cv: readCV, value: writeValue)
        case .waitingForReadCVData:
          if let loco = locomotive {
            var cv : LocomotiveCV?
            if isIndexedMode {
              if let cvx = loco.getCV(primaryPageIndex: cv31, secondaryPageIndex: cv32, cvNumber: readCV) {
                cv = cvx
              }
              else {
                cv = LocomotiveCV(primaryPageIndex: cv31, secondaryPageNumber: cv32, cvNumber: readCV)
              }
            }
            else {
              if let cvx = loco.getCV(cvNumber: readCV) {
                cv = cvx
              }
              else {
                cv = LocomotiveCV.init(cvNumber: readCV)
              }
            }
            if let cvy = cv {
              cvy.cvValue = psd.value
              if chkSetDefaults.state == .on {
                cvy.defaultValue = psd.value
              }
              loco.updateCVS(cv: cvy)
            }
            cvTableViewDS.cvs = loco.cvsSorted
            cvTableView.dataSource = cvTableViewDS
            cvTableView.delegate = cvTableViewDS
            cvTableView.reloadData()
            if cancelRead {
              programmerState = .idle
              lblReadCVStatus.stringValue = "Read Aborted"
              btnCancelReadCVValues.isEnabled = false
              btnReadCVValues.isEnabled = true
              chkSetDefaults.isEnabled = true
              chkSetDefaults.state = .off
              btnWriteCVValues.isEnabled = true
              btnImportCVs.isEnabled = true
              btnExportCVs.isEnabled = true
              cancelRead = false
            }
            else if readCV < endAddress {
              readCV += 1
              programmerState = .waitingForReadCVAck
              commandStation?.readCV(cv: readCV)
            }
            else {
              programmerState = .idle
              lblReadCVStatus.stringValue = "Read Completed"
              btnCancelReadCVValues.isEnabled = false
              btnReadCVValues.isEnabled = true
              chkSetDefaults.isEnabled = true
              chkSetDefaults.state = .off
              cancelRead = false
              btnWriteCVValues.isEnabled = true
              btnImportCVs.isEnabled = true
              btnExportCVs.isEnabled = true
            }
          }
        case .writeMultipleState2:
          programmerState = .writeMultipleState3
          commandStation?.writeCV(cv: 32, value: cv32)
          break
        case .writeMultipleState4:
          programmerState = .writeMultipleState5
          commandStation?.writeCV(cv: readCV, value: writeCV!.newValueNumber!)
          break
        case .writeMultipleState6:
          
          writeCV?.cvValue = writeCV!.newValueNumber!
          writeCV?.newValue = ""
          writeCV?.save()
          cvTableView.reloadData()
          
          if cancelRead {
            programmerState = .idle
            lblReadCVStatus.stringValue = "Write Aborted"
            btnCancelReadCVValues.isEnabled = false
            btnReadCVValues.isEnabled = true
            chkSetDefaults.isEnabled = true
            chkSetDefaults.state = .off
            btnWriteCVValues.isEnabled = true
            btnImportCVs.isEnabled = true
            btnExportCVs.isEnabled = true
            cancelRead = false
            return
          }

          writeMultipleIndex += 1
          
          if let cv = findNextCVToWrite(), let value = cv.newValueNumber {
            
            writeCV = cv

            if cv.isIndexedCV {
              
              let components = LocomotiveCV.cvNumberComponents(cvNumber: cv.cvNumber)
              cv31 = components.primaryPageIndex
              cv32 = components.secondaryPageIndex
              readCV = components.cvNumber
              programmerState = .writeMultipleState1
              commandStation?.writeCV(cv: 31, value: cv31)
              
            }
            else {
              readCV = cv.cvNumber
              programmerState = .writeMultipleState5
              commandStation?.writeCV(cv: readCV, value: value)
            }
          }
          else {
            programmerState = .idle
            lblReadCVStatus.stringValue = "Write Completed"
            btnCancelReadCVValues.isEnabled = false
            btnReadCVValues.isEnabled = true
            chkSetDefaults.isEnabled = true
            chkSetDefaults.state = .off
            cancelRead = false
            btnWriteCVValues.isEnabled = true
            btnImportCVs.isEnabled = true
            btnExportCVs.isEnabled = true
            writeMultipleIndex = 0
          }

        default:
          break
        }
        lblStatus.stringValue = message
      }
      else if psd.status == .noDecoderDetected {
        lblStatus.stringValue = "No Decoder Detected"
        programmerState = .idle
      }
      else if psd.status == .userAborted {
        lblStatus.stringValue = "User Aborted"
        programmerState = .idle
      }
      else if psd.status == .readAckNotDetected {
        lblStatus.stringValue = "Read Ack Not Detected"
        programmerState = .idle
      }
      else if psd.status == .writeAckNotDetected {
        lblStatus.stringValue = "Write Ack Not Detected"
        programmerState = .idle
      }
      else {
        lblStatus.stringValue = "\(psd.status)"
        programmerState = .idle
      }
      
      break
      
    default:
      break
    }
  }
  
  // MARK: CSVParserDelegate Methods
  
  func csvParserDidStartDocument() {
    lblReadCVStatus.stringValue = "Start Import"
  }
  
  func csvParserDidEndDocument() {
    if let loco = locomotive {
      cvTableViewDS.cvs = loco.cvsSorted
      cvTableView.dataSource = cvTableViewDS
      cvTableView.reloadData()
    }
    lblReadCVStatus.stringValue = "Import Completed"
  }
  
  func csvParser(didStartRow row: Int) {
    writeCV = nil
  }
  
  func csvParser(didEndRow row: Int) {
  }
  
  func csvParser(foundCharacters column: Int, string: String) {
    if column == 0 {
      if string == "CV" {
        return
      }
      if let cvNumber = LocomotiveCV.cvNumber(string: string) {
        
        if let loco = locomotive {
          
          if let cv = loco.getCV(cvNumber: cvNumber) {
            writeCV = cv
                }
          else {
            writeCV = LocomotiveCV(cvNumber: cvNumber)
          }
          
        }
      }
    }
    else if column == 1 {
      if string == "Default Value" {
        return
      }
      if let value = Int(string.trimmingCharacters(in: .whitespacesAndNewlines)) {
        if chkSetDefaults.state == .on {
          writeCV?.defaultValue = value
        }
      }
    }
    else if column == 2 {
      if string == "Value" {
        return
      }
      if let value = Int(string.trimmingCharacters(in: .whitespacesAndNewlines)) {
        if value != writeCV!.cvValue {
          if let loco = locomotive, let cv = writeCV {
            cv.newValue = string
            loco.updateCVS(cv: cv)
          }
       
        }
      }
    }
  }
  
  // MARK: Outlets & Actions
  
  @IBOutlet weak var cboLocomotive: NSComboBox!
  
  @IBAction func cboLocomotiveAction(_ sender: NSComboBox) {
    
    setup()

  }
  
  @IBOutlet weak var btnRead: NSButton!
  
  @IBAction func btnReadAction(_ sender: NSButton) {
    
    if validate() {
      
      if let cs = commandStation {
        
        programmerState = .waitingForReadCV29Ack
        
        cs.readCV(cv: 29)
        
      }
      
    }
    
  }
  
  @IBOutlet weak var btnWrite: NSButton!
  
  @IBAction func btnWriteAction(_ sender: NSButton) {
    
    if validate() {
      
      if let cs = commandStation {
        
        programmerState = .waitingForWriteReadCV29Ack
        
        cs.readCV(cv: 29)
        
      }
      
    }

  }
  
  @IBOutlet weak var txtAddress: NSTextField!
  
  @IBAction func txtAddressAction(_ sender: NSTextField) {
  }
  
  @IBOutlet weak var lblStatus: NSTextField!
  
  @IBOutlet weak var cboCommandStation: NSComboBox!
  
  @IBAction func cboCommandStationAction(_ sender: NSComboBox) {
    
    setup()
    
  }
  
  @IBOutlet weak var chkSetDefaults: NSButton!
  
  @IBAction func chkSetDefaultsAction(_ sender: NSButton) {
  }
  
  @IBOutlet weak var lblReadCVStatus: NSTextField!
  
  @IBOutlet weak var btnReadCVValues: NSButton!
  
  @IBAction func btnReadCVValuesAction(_ sender: NSButton) {
    
    if validate() {
      
      if let cs = commandStation {
        
        cancelRead = false
        
        btnCancelReadCVValues.isEnabled = true
        btnReadCVValues.isEnabled = false
        chkSetDefaults.isEnabled = false
        btnWriteCVValues.isEnabled = false
        btnImportCVs.isEnabled = false
        btnExportCVs.isEnabled = false
        
        locomotive?.save()
        
        if isIndexedMode {
          
          cv31 = Int(txtPrimaryPageIndex.stringValue) ?? 0
          cv32 = Int(txtSecondaryPageIndex.stringValue) ?? 0
          
          startAddress = 257
          endAddress = 512
          
          readCV = startAddress
          
          programmerState = .waitingForIndexedReadWriteCV31Ack
          
          cs.writeCV(cv: 31, value: cv31)
          
        }
        else {
          
          programmerState = .waitingForReadCVAck
        
          startAddress = 1
          endAddress = 256
          readCV = startAddress

          cs.readCV(cv: readCV)
          
        }
        
      }
      
    }

  }
  
  @IBOutlet weak var btnCancelReadCVValues: NSButton!
  
  @IBAction func btnCancelReadCVValuesAction(_ sender: NSButton) {
    cancelRead = true
  }
  
  @IBOutlet weak var cvTableView: NSTableView!
  
  @IBAction func cvTableViewAction(_ sender: NSTableView) {
  }
  
  @IBOutlet weak var radRegularCVs: NSButton!
  
  @IBAction func radRegularCVsAction(_ sender: NSButton) {
    
    isIndexedMode = sender.state == .off
    
    radRegularCVs.state = isIndexedMode ? .off : .on
    radIndexedCVs.state = isIndexedMode ? .on : .off
    
    txtPrimaryPageIndex.isEnabled = isIndexedMode
    txtSecondaryPageIndex.isEnabled = isIndexedMode

  }
  
  @IBOutlet weak var radIndexedCVs: NSButton!
  
  @IBAction func radIndexedCVsAction(_ sender: NSButton) {
    
    isIndexedMode = sender.state == .on
    
    radRegularCVs.state = isIndexedMode ? .off : .on
    radIndexedCVs.state = isIndexedMode ? .on : .off
    
    txtPrimaryPageIndex.isEnabled = isIndexedMode
    txtSecondaryPageIndex.isEnabled = isIndexedMode

  }
  
  @IBOutlet weak var txtPrimaryPageIndex: NSTextField!
  
  @IBAction func txtPrimaryPageIndexAction(_ sender: NSTextField) {
  }
  
  @IBOutlet weak var txtSecondaryPageIndex: NSTextField!
  
  @IBAction func txtSecondaryPageIndexAction(_ sender: NSTextField) {
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
    writeCV = cv
    var reset = true
    if let newValue = Int.fromMultiBaseString(stringValue: sender.stringValue) {
      if newValue >= 0 && newValue < 256 {
        reset = false
        writeValue = newValue
        if !cv.isIndexedCV {
          programmerState = .waitingForWriteCVAck
          commandStation?.writeCV(cv: cv.cvNumber, value: writeValue)
        }
        else {
          let components = LocomotiveCV.cvNumberComponents(cvNumber: cv.cvNumber)
          cv31 = components.primaryPageIndex
          cv32 = components.secondaryPageIndex
          readCV = components.cvNumber
          programmerState = .waitingForIndexedWriteWriteCV31Ack
          commandStation?.writeCV(cv: 31, value: cv31)
        }
      }
    }
    if reset {
      sender.stringValue = "\(cv.displayCVValue)"
    }
  }
  
  
  @IBAction func cboNumberBaseAction(_ sender: NSComboBox) {
    let cv = cvTableViewDS.cvs[sender.tag]
    cv.customNumberBase = CVNumberBase(rawValue: sender.indexOfSelectedItem) ?? .decimal
    cv.save()
    cvTableView.reloadData()
  }
  
  @IBOutlet weak var txtNewValue: NSTextField!
  
  @IBAction func txtNewValueAction(_ sender: NSTextField) {
    let strVal = sender.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
    let cv = cvTableViewDS.cvs[sender.tag]
    var reset = true
    if let newValue = Int.fromMultiBaseString(stringValue: strVal) {
      if newValue >= 0 && newValue < 256 {
        reset = false
        cv.newValue = sender.stringValue
      }
    }
    else if strVal == "" {
      cv.newValue = strVal
      reset = false
    }
    if reset {
      sender.stringValue = "\(cv.newValue)"
    }
  }
  
  @IBOutlet weak var btnWriteCVValues: NSButton!
  
  @IBAction func btnWriteCVValuesAction(_ sender: NSButton) {
    
    writeMultipleIndex = 0
    
    cancelRead = false
    
    if let cv = findNextCVToWrite(), let value = cv.newValueNumber {
      
      btnCancelReadCVValues.isEnabled = true
      btnReadCVValues.isEnabled = false
      chkSetDefaults.isEnabled = false
      btnWriteCVValues.isEnabled = false
      btnImportCVs.isEnabled = false
      btnExportCVs.isEnabled = false

      writeCV = cv

      if cv.isIndexedCV {
        
        let components = LocomotiveCV.cvNumberComponents(cvNumber: cv.cvNumber)
        cv31 = components.primaryPageIndex
        cv32 = components.secondaryPageIndex
        readCV = components.cvNumber
        programmerState = .writeMultipleState1
        commandStation?.writeCV(cv: 31, value: cv31)
        
      }
      else {
        readCV = cv.cvNumber
        programmerState = .writeMultipleState5
        commandStation?.writeCV(cv: readCV, value: value)
      }
    }
    
  }
  
  @IBOutlet weak var btnImportCVs: NSButton!
  
  @IBAction func btnImportCVsAction(_ sender: NSButton) {
    
    if let savedCVsPath = UserDefaults.standard.string(forKey: DEFAULT.SAVED_CVS_PATH) {
    
      let url = URL(fileURLWithPath: savedCVsPath)
      
      let fm = FileManager()
      
      try? fm.createDirectory(at: url, withIntermediateDirectories:true, attributes:nil)

      let panel = NSOpenPanel()
      
      panel.directoryURL = url
      panel.canChooseDirectories = false
      panel.canChooseFiles = true
      panel.allowsOtherFileTypes = true
      panel.allowedFileTypes = ["csv"]
      
      if (panel.runModal() == .OK) {
        
        let newPath = panel.directoryURL!.deletingLastPathComponent()
        
        UserDefaults.standard.set(newPath, forKey: DEFAULT.SAVED_CVS_PATH)
        
        csvParser = CSVParser(withURL: panel.url!)
        csvParser?.delegate = self
        csvParser?.columnSeparator = ","
        csvParser?.lineTerminator = "\n"
        csvParser?.stringDelimiter = "\""
        csvParser?.parse()
      }

    }

  }
  
  @IBOutlet weak var btnExportCVs: NSButton!
  
  @IBAction func btnExportCVsAction(_ sender: NSButton) {
    
    if let savedCVsPath = UserDefaults.standard.string(forKey: DEFAULT.SAVED_CVS_PATH) {
    
      var url = URL(fileURLWithPath: savedCVsPath)
      
      let fm = FileManager()
      
      do{
        try fm.createDirectory(at: url, withIntermediateDirectories:true, attributes:nil)
      }
      catch{
        print("create directory failed")
      }

      let panel = NSSavePanel()
      
      panel.directoryURL = url
      
      panel.nameFieldStringValue = cboLocomotive.stringValue

      panel.canCreateDirectories = true
      
      panel.allowedFileTypes = ["csv"]
      
      if (panel.runModal() == .OK) {
        
        let newPath = panel.directoryURL!.deletingLastPathComponent()
        
        UserDefaults.standard.set(newPath, forKey: DEFAULT.SAVED_CVS_PATH)
        
        if let loco = locomotive {
          
          var output = "\"CV\",\"Default Value\",\"Value\"\n"
          
          for cv in loco.cvsSorted {
            output += "\(cv.displayCVNumber), \(cv.defaultValue), \(cv.cvValue)\n"
          }
          
          try? output.write(to: panel.url!, atomically: true, encoding: .utf8)
          
        }

      }

    }
    
  }
  
}
