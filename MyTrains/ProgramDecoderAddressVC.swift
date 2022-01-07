//
//  ProgramDecoderAddressVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/01/2022.
//

import Foundation
import Cocoa

class ProgramDecoderAddressVC : NSViewController, NSWindowDelegate, CommandStationDelegate {

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
  
  private var readCV : Int = 1
  
  private var cancelRead : Bool = false
  
  private var cvTableViewDS = CVTableViewDS()
  
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
      txtMaxCVNumber.stringValue = "\(loco.maxCVNumber)"
    }
    else {
      txtAddress.stringValue = "0"
      txtMaxCVNumber.stringValue = "255"
    }
    
    btnWrite.isEnabled = cboLocomotive.indexOfSelectedItem >= 0 && cboCommandStation.indexOfSelectedItem >= 0
    
    btnRead.isEnabled = btnWrite.isEnabled
    
    btnCancelReadCVValues.isEnabled = false
    btnReadCVValues.isEnabled = true
    txtMaxCVNumber.isEnabled = true
    chkSetDefaults.isEnabled = true
    chkSetDefaults.state = .off

    if let loco = locomotive {
      cvTableViewDS.cvs = loco.cvs
      cvTableView.dataSource = cvTableViewDS
      cvTableView.delegate = cvTableViewDS
      cvTableView.reloadData()
    }

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
      
      if let cv = Int(txtMaxCVNumber.stringValue) {
        
        if cv < 1 || cv > 1024 {
          good = false
        }
      }
      else {
        good = false
      }
      
      if !good {
        let alert = NSAlert()

        alert.messageText = "Invalid Maximum CV Number"
        alert.informativeText = "A CV number in the range 1 to 1024 is required."
        alert.addButton(withTitle: "OK")
     // alert.addButton(withTitle: "Cancel")
        alert.alertStyle = .critical

        let _ = alert.runModal() // == NSAlertFirstButtonReturn
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
  
  func trackStatusChanged(commandStation: CommandStation) {
    
  }
  
  func locomotiveMessageReceived(message: NetworkMessage) {
  }
  
  func progMessageReceived(message: NetworkMessage) {
    
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
        case .waitingForReadCVData:
          if let loco = locomotive {
            let cv = loco.cvs[readCV-1]
            cv.cvValue = psd.value
            if chkSetDefaults.state == .on {
              cv.defaultValue = psd.value
            }
            cv.save()
            if let loco = locomotive {
              cvTableViewDS.cvs = loco.cvs
              cvTableView.dataSource = cvTableViewDS
              cvTableView.delegate = cvTableViewDS
              cvTableView.reloadData()
            }
            if cancelRead {
              programmerState = .idle
              lblReadCVStatus.stringValue = "Read Aborted"
              btnCancelReadCVValues.isEnabled = false
              btnReadCVValues.isEnabled = true
              txtMaxCVNumber.isEnabled = true
              chkSetDefaults.isEnabled = true
              chkSetDefaults.state = .off
              cancelRead = false
            }
            else if readCV < txtMaxCVNumber.integerValue {
              readCV += 1
              programmerState = .waitingForReadCVAck
              commandStation?.readCV(cv: readCV)
            }
            else {
              programmerState = .idle
              lblReadCVStatus.stringValue = "Read Completed"
              btnCancelReadCVValues.isEnabled = false
              btnReadCVValues.isEnabled = true
              txtMaxCVNumber.isEnabled = true
              chkSetDefaults.isEnabled = true
              chkSetDefaults.state = .off
              cancelRead = false
            }
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
  
  @IBOutlet weak var txtMaxCVNumber: NSTextField!
  
  @IBAction func txtMaxCVNumberAction(_ sender: NSTextField) {
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
        txtMaxCVNumber.isEnabled = false
        chkSetDefaults.isEnabled = false
        
        locomotive?.maxCVNumber = txtMaxCVNumber.integerValue
        
        locomotive?.save()
        
        programmerState = .waitingForReadCVAck
        
        readCV = 1
        
        cs.readCV(cv: readCV)
        
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
  
}
