//
//  AppDelegate.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/10/2021.
//

import Cocoa
import ORSSerial

@main
class AppDelegate: NSObject, NSApplicationDelegate {

  


  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // Insert code here to initialize your application
    let serialPort = ORSSerialPort(path: "/dev/tty.usbmodemDxP470881")
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }

  func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }


}

