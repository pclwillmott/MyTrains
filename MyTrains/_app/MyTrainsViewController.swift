//
//  MyTrainsViewController.swift
//  MyTrains
//
//  Created by Paul Willmott on 02/03/2024.
//

import Foundation
import AppKit

class MyTrainsViewController: NSViewController, NSWindowDelegate {
  
  // MARK: View Control
  
  override func viewDidLoad() {

    super.viewDidLoad()

    #if DEBUG
    debugLog("viewDidLoad")
    #endif

  }
  
  override func viewWillAppear() {

    super.viewWillAppear()
    
    #if DEBUG
    debugLog("viewWillAppear")
    #endif

    view.window?.delegate = self
    
  }
  
  public func windowShouldClose(_ sender: NSWindow) -> Bool {
    
    #if DEBUG
    debugLog("windowShouldClose")
    #endif
    
    return true
    
  }
  
  override func viewDidAppear() {
    
    super.viewDidAppear()
    
    #if DEBUG
    debugLog("viewDidAppear")
    #endif
    
  }
  
  override func viewWillDisappear() {
    
    super.viewWillDisappear()
    
    #if DEBUG
    debugLog("viewWillDisappear")
    #endif
    
  }

  override func viewDidDisappear() {
    
    super.viewWillDisappear()
    
    #if DEBUG
    debugLog("viewDidDisappear")
    #endif
    
  }

}
