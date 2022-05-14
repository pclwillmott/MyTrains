//
//  CommandStationConfigurationVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 05/02/2022.
//

import Foundation
import Cocoa

class CommandStationConfigurationVC: NSViewController, NSWindowDelegate, CommandStationDelegate {
 
  // MARK: Window & View Control
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }

  func windowWillClose(_ notification: Notification) {
    if delegateId != -1 {
      commandStation?.removeDelegate(id: delegateId)
    }
    stopModal()
  }
  
  override func viewWillAppear() {
    
    self.view.window?.delegate = self
    
    let css = networkController.commandStations
    var temp : [Int:CommandStation] = [:]
 /*   for y in css {
      if y.value.messengers.count > 0 {
        temp[y.key] = y.value
      }
    } */
    cboCommandStationDS.dictionary = temp
    
    cboCommandStation.dataSource = cboCommandStationDS
    
    if cboCommandStation.numberOfItems > 0 {
      cboCommandStation.selectItem(at: 0)
      commandStation = cboCommandStationDS.commandStationAt(index: 0)
      if let cs = commandStation {
        csConfigurationTableViewDS.options = cs.optionSwitches
        tableView.dataSource = csConfigurationTableViewDS
        tableView.delegate = csConfigurationTableViewDS
        tableView.reloadData()
        delegateId = cs.addDelegate(delegate: self)
      }
    }
    
    let xStart : CGFloat = 55
    var xPos : CGFloat = xStart
    var yPos : CGFloat = 595
    var count = 0
    var index = 1
    while index < 129 {
      
      let button : NSButton = NSButton(title: "\(index)", target: self, action: #selector(self.buttonAction(_:)))
      button.frame = NSRect(x: xPos, y: yPos, width: 50, height: 20)
      button.tag = index
      button.setButtonType(.pushOnPushOff)
      viewBitFinder.subviews.append(button)
      buttons.append(button)
      
      count += 1
      
      index += 1
      if count == 10 {
        yPos -= 30
        xPos = xStart
        count = 0
      }
      else {
        xPos += button.frame.width
      }
      
    }


  }
  
  // MARK: Private Enums
  
  private enum ConfigState {
    case idle
    case waitingForCfgSlotDataP1
    case waitingForReadSwitchAck
    case waitingforMassReadSwitchAck
    case waitingForBaseCase
    case waitingForNewCase
  }
  
  // MARK: Private Properties
  
  private var buttons : [NSButton] = []
  
  private var isDirty : Bool = true
  
  private var baseCase : NetworkMessage?
  
  private var newCase : NetworkMessage?
  
  private var cboCommandStationDS : CommmandStationComboBoxDS = CommmandStationComboBoxDS()

  private var delegateId : Int = -1
  
  private var configState : ConfigState = .idle
  
  private var nextReadIndex : Int = 0
  
  private var readSwitchNumber : Int = -1
  
  private var commandStation : CommandStation? {
    didSet {
      if let cs = commandStation {
        csConfigurationTableViewDS.options = cs.optionSwitches
        tableView.dataSource = csConfigurationTableViewDS
        tableView.reloadData()
      }
    }
  }
  
  private var csConfigurationTableViewDS : CSConfigurationTableViewDS = CSConfigurationTableViewDS()
  
  // MARK: Command Station Delegate Methods
  
  func trackStatusChanged(commandStation: CommandStation) {
 //   tableView.reloadData()
  }
  
  func messageReceived(message:NetworkMessage) {
    
    let options = csConfigurationTableViewDS.options
    
    switch message.messageType {
    case .cfgSlotDataP2:
      if configState == .waitingForBaseCase {
        baseCase = message
        let newState : OptionSwitchState = buttons[readSwitchNumber-1].state == .on ? .closed : .thrown
        configState = .waitingForNewCase
//        commandStation?.swReq(switchNumber: readSwitchNumber, state: newState)
 //       commandStation?.getCfgSlotDataP2()
      }
      else if configState == .waitingForNewCase {
        newCase = message
        if let base = baseCase, let new = newCase {
          var changes : String = ""
          let numBytes = message.message.count-2
          for index in 0...numBytes {
            if base.message[index] != new.message[index] {
              changes += "OpSw\(readSwitchNumber) - Byte \(index) "
              for bit in 0...7 {
                let mask : UInt8 = 1 << bit
                if (base.message[index] & mask) != (new.message[index] & mask) {
                  changes += "Bit \(bit) "
                }
              }
              changes += "\n"
            }
          }
          txtMonitor.string = changes
        }
        configState = .idle
      }
      break

    case .cfgSlotDataP1, .cfgSlotDataBP1:
      if configState == .waitingForBaseCase {
        baseCase = message
        let newState : OptionSwitchState = buttons[readSwitchNumber-1].state == .on ? .closed : .thrown
        configState = .waitingForNewCase
  //      commandStation?.swReq(switchNumber: readSwitchNumber, state: newState)
  //      rad7F.state == .on ? commandStation?.getCfgSlotDataP1() : //commandStation?.getCfgSlotDataBP1()
      }
      else if configState == .waitingForNewCase {
        newCase = message
        if let base = baseCase, let new = newCase {
          var changes : String = "\(rad7F.state == .on ? "0x7F: " : "0x7E: ")"
          let numBytes = message.message.count-2
          for index in 0...numBytes {
            if base.message[index] != new.message[index] {
              changes += "OpSw\(readSwitchNumber) - Byte \(index) "
              for bit in 0...7 {
                let mask : UInt8 = 1 << bit
                if (base.message[index] & mask) != (new.message[index] & mask) {
                  changes += "Bit \(bit) "
                }
              }
              changes += "\n"
            }
          }
          txtMonitor.string = changes
        }
        configState = .idle
      }
      else if configState == .waitingForCfgSlotDataP1 {
        if radOptionSwitches.state == .on {
          nextReadIndex = 0
          while nextReadIndex < options.count && options[nextReadIndex].switchDefinition.configByte != -1 {
            nextReadIndex += 1
          }
          readSwitchNumber = options[nextReadIndex].switchNumber
          configState = .waitingForReadSwitchAck
  //        commandStation?.swState(switchNumber: readSwitchNumber)
          break
        }
        configState = .idle
        commandStation?.save()
        tableView.reloadData()
      }
      break
    case .swState:
      let switchState : OptionSwitchState = message.message[2] & 0x20 == 0 ? .thrown : .closed
      if configState == .waitingForReadSwitchAck {
        options[nextReadIndex].state = switchState
        nextReadIndex += 1
        while nextReadIndex < options.count && options[nextReadIndex].switchDefinition.configByte != -1 {
          nextReadIndex += 1
        }
        if nextReadIndex == options.count {
          configState = .idle
          commandStation?.save()
          tableView.reloadData()
          break
        }
        readSwitchNumber = options[nextReadIndex].switchNumber
        configState = .waitingForReadSwitchAck
  //      commandStation?.swState(switchNumber: readSwitchNumber)
        break
      }
      else if configState == .waitingforMassReadSwitchAck {
        buttons[nextReadIndex-1].state = message.message[2] & 0x20 == 0 ? .off : .on
        if nextReadIndex < 128 {
          nextReadIndex += 1
          configState = .waitingforMassReadSwitchAck
//          commandStation?.swState(switchNumber: nextReadIndex)
          break
        }
        else {
          isDirty = false
          configState = .waitingForBaseCase
//          radProtocol1.state == .on ? commandStation?.getCfgSlotDataP1() : commandStation?.getCfgSlotDataP2()
        }
        break
      }
      configState = .idle
    default:
      break
    }
  }

  // MARK: Outlets & Actions
  
  @IBOutlet weak var cboCommandStation: NSComboBox!
  
  @IBAction func cboCommandStationAction(_ sender: NSComboBox) {
  }
  
  @IBOutlet weak var radConfigurationSlot: NSButton!
  
  @IBAction func radConfigurationSlotAction(_ sender: NSButton) {
    let alert = NSAlert()

 //   alert.messageText = "Has the \(commandStation?.commandStationName ?? "command station") been switched into RUN Mode?"
    alert.informativeText = ""
    alert.addButton(withTitle: "Yes")
    alert.addButton(withTitle: "No")
    alert.alertStyle = .warning

    if alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn {
      radOptionSwitches.state = sender.state == .on ? .off : .on
      csConfigurationTableViewDS.isConfigurationSlotMode = sender.state == .on
      tableView.reloadData()
    }
    else {
      radConfigurationSlot.state = .off
    }
  }
  
  @IBOutlet weak var radOptionSwitches: NSButton!
  
  @IBAction func radOptionSwitchesAction(_ sender: NSButton) {
    
    let alert = NSAlert()

 //   alert.messageText = "Has the \(commandStation?.commandStationName ?? "command station") been switched into OP Mode?"
    alert.informativeText = ""
    alert.addButton(withTitle: "Yes")
    alert.addButton(withTitle: "No")
    alert.alertStyle = .warning

    if alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn {
      radConfigurationSlot.state = sender.state == .on ? .off : .on
      csConfigurationTableViewDS.isConfigurationSlotMode = sender.state == .off
      tableView.reloadData()
    }
    else {
      radOptionSwitches.state = .off
    }
  }
  
  @IBOutlet weak var btnRead: NSButton!
  
  @IBAction func btnReadAction(_ sender: NSButton) {
    configState = .waitingForCfgSlotDataP1
//    commandStation?.getCfgSlotDataP1()
  }
  
  @IBOutlet weak var btnWrite: NSButton!
  
  @IBAction func btnWriteAction(_ sender: NSButton) {
    if radOptionSwitches.state == .on {
      for opsw in csConfigurationTableViewDS.options {
        if opsw.switchDefinition.configByte == -1 {
   //       commandStation?.swReq(switchNumber: opsw.switchNumber, state: opsw.newState)
          isDirty = true
        }
      }
    }
    commandStation?.setOptionSwitches()
  }
  
  @IBOutlet weak var tableView: NSTableView!
  
  @IBAction func tableViewAction(_ sender: NSTableView) {
  }
  
  @IBOutlet var txtMonitor: NSTextView!
  
  @IBOutlet weak var viewBitFinder: NSView!
  
  @IBAction func buttonAction(_ sender: NSButton) {
    
    if radOptionSwitches.state == .off {
      let alert = NSAlert()

  //    alert.messageText = "Has the \(commandStation?.commandStationName ?? "command station") been switched into OP Mode?"
      alert.informativeText = ""
      alert.addButton(withTitle: "Yes")
      alert.addButton(withTitle: "No")
      alert.alertStyle = .warning

      if alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn {
        radConfigurationSlot.state = sender.state == .on ? .off : .on
        csConfigurationTableViewDS.isConfigurationSlotMode = sender.state == .off
        tableView.reloadData()
        radOptionSwitches.state = .on
        radConfigurationSlot.state = .off
      }
      else {
        for button in buttons {
          button.state = .off
        }
        isDirty = true
        return
      }
    }
    
    readSwitchNumber = sender.tag
    
    if isDirty {
      for button in buttons {
        button.state = .off
      }
      nextReadIndex = 1
      configState = .waitingforMassReadSwitchAck
 //     commandStation?.swState(switchNumber: nextReadIndex)
    }
    else {
      configState = .waitingForBaseCase
      if radProtocol1.state == .on {
//        rad7F.state == .on ? commandStation?.getCfgSlotDataP1() : commandStation?.getCfgSlotDataBP1()
      }
      else {
//        commandStation?.getCfgSlotDataP2()
      }
      
    }

  }
  
  @IBOutlet weak var radProtocol1: NSButton!
  
  @IBAction func radProtocol1Action(_ sender: NSButton) {
    radProtocol2.state = sender.state == .on ? .off : .on
  }
  
  @IBOutlet weak var radProtocol2: NSButton!
  
  @IBAction func radProtocol2Action(_ sender: NSButton) {
    radProtocol1.state = sender.state == .on ? .off : .on
  }
  
  @IBOutlet weak var rad7F: NSButton!
  
  @IBAction func rad7FAction(_ sender: NSButton) {
    rad7E.state = sender.state == .on ? .off : .on
  }
  
  @IBOutlet weak var rad7E: NSButton!
  
  @IBAction func rad7EAction(_ sender: NSButton) {
    rad7F.state = sender.state == .on ? .off : .on
  }
  
}


