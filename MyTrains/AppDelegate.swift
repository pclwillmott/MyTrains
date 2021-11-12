//
//  AppDelegate.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/10/2021.
//

import Cocoa
import Foundation
import ORSSerial

@main
class AppDelegate: NSObject, NSApplicationDelegate, LoconetMessengerDelegate {
  
  func LoconetRequestSlotDataMessageReceived(message: LoconetRequestSlotDataMessage) {
    print("id:         \(message.interfaceId)")
    print("opCode:     \(message.opCode)")
    print("slotNumber: \(String(format:"0x%02x", message.slotNumber))")
    print("")
  }
  
  func LoconetLongAcknowledgeMessageReceived(message: LoconetLongAcknowledgeMessage) {
    print("id:                   \(message.interfaceId)")
    print("opCode:               \(message.opCode)")
    print("opCodeResponding:     \(message.opCodeResponding)")
    print("responseCode:         \(message.responseCode)")
    print("responseCodeRawValue: \(String(format:"0x%04x",message.responseCodeRawValue))")
    print("")
}
  
  func LoconetTurnoutOutputMessageReceived(message: LoconetTurnoutOutputMessage) {
    print("id:                  \(message.interfaceId)")
    print("opCode:              \(message.opCode)")
    print("turnoutAddress:      \(message.turnoutAddress)")
    print("turnoutId:           \(message.turnoutId)")
    print("turnoutClosedOutput: \(message.turnoutClosedOutput)")
    print("turnoutThrownOutput: \(message.turnoutThrownOutput)")
    print("")
}
  
  func LoconetSlotDataMessageReceived(message: LoconetSlotDataMessage) {
    print("id:            \(message.interfaceId)")
    print("opCode:        \(message.opCode)")
    print("slotNumber:    \(String(format:"0x%02x", message.slot!.slotNumber))")
    print("locoAddress:   \(message.slot!.locoAddress)")
    print("speedType:     \(message.slot!.speedType)")
    print("speed:         \(message.slot!.speed)")
    print("XCNT:          \(message.slot!.stateXCNT)")
    print("locoDirection: \(message.slot!.locoDirection)")
    print("stateF0:       \(message.slot!.stateF0)")
    print("stateF1:       \(message.slot!.stateF1)")
    print("stateF2:       \(message.slot!.stateF2)")
    print("stateF3:       \(message.slot!.stateF3)")
    print("stateF4:       \(message.slot!.stateF4)")
    print("sound1:        \(message.slot!.sound1)")
    print("sound2:        \(message.slot!.sound2)")
    print("sound3:        \(message.slot!.sound3)")
    print("sound4:        \(message.slot!.sound4)")
    print("decoderType:   \(message.slot!.decoderType)")
    print("locoUsage:     \(message.slot!.locoUsage)")
    print("progTrackBusy: \(message.slot!.progTrackBusy)")
    print("MLOK1:         \(message.slot!.MLOK1)")
    print("trackPaused:   \(message.slot!.trackPaused)")
    print("trackPower:    \(message.slot!.trackPower)")
    print("")
  }
  
  func LoconetSwitchRequestMessageReceived(message: LoconetSwitchRequestMessage) {
    print("id:              \(message.interfaceId)")
    print("opCode:          \(message.opCode)")
    print("switchAddress:   \(message.switchAddress)")
    print("switchId:        \(message.switchId)")
    print("switchDirection: \(message.switchDirection)")
    print("switchOutput:    \(message.switchOutput)")
    print("")
  }
    
  func LoconetSensorMessageReceived(message: LoconetSensorMessage) {
    print("id:                \(message.interfaceId)")
    print("opCode:            \(message.opCode)")
    print("sensorAddress:     \(message.sensorAddress)")
    print("sensorId:          \(message.sensorId)")
    print("sensorMessageType: \(message.sensorMessageType)")
    print("sensorState:       \(message.sensorState)")
    print("")
  }
  
  private var loconetMessenger : LoconetMessenger? = nil
  private var loconetController : LoconetController? = nil
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    
    // Insert code here to initialize your application
    
    // "/dev/tty.usbmodemDxP470881"
    // /dev/cu.usbmodemDxP470881
    
//    loconetMessenger = LoconetMessenger(path: "/dev/cu.usbmodemDxP470881")
//    loconetMessenger = LoconetMessenger(id: "id1", path: "/dev/cu.usbmodemDxP431751")
//    loconetMessenger?.delegate = self
    
    
    let availablePorts = ORSSerialPortManager.shared().availablePorts
    for port in availablePorts {
      print("\(port.name)")
      print("\(port.baudRate)")
      print("\(port.path)")
      print("\(port.usesRTSCTSFlowControl)")
    }
     
    
    loconetController = LoconetController()
    
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }

  func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }


}

