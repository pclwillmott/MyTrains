//
//  AppDelegate.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/10/2021.
//

import Cocoa
import ORSSerial
import Foundation

@main
class AppDelegate: NSObject, NSApplicationDelegate, ORSSerialPortDelegate {

  func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
    
  }
  
  func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
    for x in data {
      print(String(format:"%X ", x))
    }
  }


  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // Insert code here to initialize your application
    let serialPort = ORSSerialPort(path: "/dev/tty.usbmodemDxP470881")
    serialPort?.delegate = self
    let availablePorts = ORSSerialPortManager.shared().availablePorts
    for port in availablePorts {
      print("\(port.name)")
      print("\(port.baudRate)")
      print("\(port.path)")
      print("\(port.usesRTSCTSFlowControl)")
    }
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }

  func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }


}

