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
    
    if cboLocomotive.numberOfItems > 0 {
      cboLocomotive.selectItem(at: 0)
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
    case waitingForWriteAck
    case waitingForWriteData
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
      txtAddress.integerValue = loco.address
    }
    else {
      txtAddress.integerValue = 0
    }
    
    btnWrite.isEnabled = cboLocomotive.indexOfSelectedItem >= 0 && cboCommandStation.indexOfSelectedItem >= 0
    
    btnRead.isEnabled = btnWrite.isEnabled

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
      alert.informativeText = "An address in the range 0 to 9983 is expected."
      alert.addButton(withTitle: "OK")
   // alert.addButton(withTitle: "Cancel")
      alert.alertStyle = .critical

      let _ = alert.runModal() // == NSAlertFirstButtonReturn
    }
    
    return good
    
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
          programmerState = .idle
          break
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
  }
  
  @IBOutlet weak var txtAddress: NSTextField!
  
  @IBAction func txtAddressAction(_ sender: NSTextField) {
  }
  
  @IBOutlet weak var lblStatus: NSTextField!
  
  @IBOutlet weak var cboCommandStation: NSComboBox!
  
  @IBAction func cboCommandStationAction(_ sender: NSComboBox) {
    
    setup()
    
  }
  
}
