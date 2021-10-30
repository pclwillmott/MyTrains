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
class AppDelegate: NSObject, NSApplicationDelegate {

  private var loconet : Loconet? = nil
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    
    // Insert code here to initialize your application
    
    // "/dev/tty.usbmodemDxP470881"
    // /dev/cu.usbmodemDxP470881
    
    loconet = Loconet(path: "/dev/cu.usbmodemDxP470881")
    
    let availablePorts = ORSSerialPortManager.shared().availablePorts
    for port in availablePorts {
      print("\(port.name)")
      print("\(port.baudRate)")
      print("\(port.path)")
      print("\(port.usesRTSCTSFlowControl)")
    }
    
    print(String(0x88, radix: 2))
    
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }

  func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }


}

