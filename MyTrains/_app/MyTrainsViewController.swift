//
//  MyTrainsViewController.swift
//  MyTrains
//
//  Created by Paul Willmott on 02/03/2024.
//

import Foundation
import AppKit

public class MyTrainsViewController: NSViewController, NSWindowDelegate {
  
  // MARK: View Control
  
  public override func viewDidLoad() {

    super.viewDidLoad()

    #if DEBUG
    debugLog("viewDidLoad")
    #endif

  }
  
  public override func viewWillAppear() {

    super.viewWillAppear()
    
    #if DEBUG
    debugLog("viewWillAppear")
    #endif

    view.window?.delegate = self
    
  }
  
  public override func viewDidAppear() {
    
    super.viewDidAppear()
    
    #if DEBUG
    debugLog("viewDidAppear")
    #endif
    
  }
  
  public func windowShouldClose(_ sender: NSWindow) -> Bool {
    
    #if DEBUG
    debugLog("windowShouldClose")
    #endif
    
    return true
    
  }
  
  public func windowWillClose(_ notification: Notification) {
    
    #if DEBUG
    debugLog("windowWillClose")
    #endif
    
    appDelegate.removeViewController(self)
    
  }
  
  public override func viewWillDisappear() {
    
    super.viewWillDisappear()
    
    #if DEBUG
    debugLog("viewWillDisappear")
    #endif
    
  }

  public override func viewDidDisappear() {
    
    super.viewWillDisappear()
    
    #if DEBUG
    debugLog("viewDidDisappear")
    #endif
    
  }
  
  // MARK: Public Properties
  
  public var objectIdentifier : ObjectIdentifier?

  // MARK: Public Methods
  
  public func showWindow() {
    view.window?.windowController?.showWindow(nil)
  }
  
  public func closeWindow() {
    view.window?.close()
  }

}
