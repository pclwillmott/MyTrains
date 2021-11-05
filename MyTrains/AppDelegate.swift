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
  
  func LoconetLongAcknowledgeMessageReceived(message: LoconetLongAcknowledgeMessage) {
    print("opCode:           \(message.opCode)")
    print("opCodeResponding: \(message.opCodeResponding)")
    print("responseCode:     \(message.responseCode)")
    print("")
}
  
  func LoconetTurnoutOutputMessageReceived(message: LoconetTurnoutOutputMessage) {
    print("opCode:              \(message.opCode)")
    print("turnoutAddress:      \(message.turnoutAddress)")
    print("turnoutId:           \(message.turnoutId)")
    print("turnoutClosedOutput: \(message.turnoutClosedOutput)")
    print("turnoutThrownOutput: \(message.turnoutThrownOutput)")
    print("")
}
  
  func LoconetSlotDataMessageReceived(message: LoconetSlotDataMessage) {
    print("opCode:        \(message.opCode)")
    print("slotNumber:    \(message.slotNumber)")
    print("locoAddress:   \(message.locoAddress)")
    print("speedType:     \(message.speedType)")
    print("speed:         \(message.speed)")
    print("locoDirection: \(message.locoDirection)")
    print("stateF0:       \(message.stateF0)")
    print("stateF1:       \(message.stateF1)")
    print("stateF2:       \(message.stateF2)")
    print("stateF3:       \(message.stateF3)")
    print("stateF4:       \(message.stateF4)")
    print("decoderType:   \(message.decoderType)")
    print("locoUsage:     \(message.locoUsage)")
    print("progTrackBusy: \(message.progTrackBusy)")
    print("MLOK1:         \(message.MLOK1)")
    print("trackPaused:   \(message.trackPaused)")
    print("trackPower:    \(message.trackPower)")
    print("")
  }
  
  func LoconetSwitchRequestMessageReceived(message: LoconetSwitchRequestMessage) {
    print("opCode:          \(message.opCode)")
    print("switchAddress:   \(message.switchAddress)")
    print("switchId:        \(message.switchId)")
    print("switchDirection: \(message.switchDirection)")
    print("switchOutput:    \(message.switchOutput)")
    print("")
  }
    
  func LoconetSensorMessageReceived(message: LoconetSensorMessage) {
    print("opCode:            \(message.opCode)")
    print("sensorAddress:     \(message.sensorAddress)")
    print("sensorId:          \(message.sensorId)")
    print("sensorMessageType: \(message.sensorMessageType)")
    print("sensorState:       \(message.sensorState)")
    print("")
  }
  
  private var loconetMessenger : LoconetMessenger? = nil
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    
    // Insert code here to initialize your application
    
    // "/dev/tty.usbmodemDxP470881"
    // /dev/cu.usbmodemDxP470881
    
    loconetMessenger = LoconetMessenger(path: "/dev/cu.usbmodemDxP470881")
    loconetMessenger?.delegate = self
    /*
    let availablePorts = ORSSerialPortManager.shared().availablePorts
    for port in availablePorts {
      print("\(port.name)")
      print("\(port.baudRate)")
      print("\(port.path)")
      print("\(port.usesRTSCTSFlowControl)")
    }
     */
    
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }

  func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }


}

