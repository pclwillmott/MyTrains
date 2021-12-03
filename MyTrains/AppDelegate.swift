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
  
 
  
  private var loconetMessenger : NetworkMessenger? = nil
  
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
     
  }

  @IBAction func mnuMonitorAction(_ sender: NSMenuItem) {
    let x = ModalWindow.Monitor
    let wc = x.windowController
 // let vc = x.viewController(windowController: wc) as! MonitorVC
    wc.showWindow(nil)
  }
  
  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }

  func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }


}

