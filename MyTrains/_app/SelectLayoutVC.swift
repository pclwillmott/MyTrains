//
//  SelectLayoutVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/01/2024.
//

import Foundation
import AppKit

class SelectLayoutVC: NSViewController, NSWindowDelegate, MyTrainsAppDelegate {
  
  // MARK: Window & View Control
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }
  
  func windowWillClose(_ notification: Notification) {
    myTrainsController.openLCBNetworkLayer?.myTrainsNode?.removeObserver(observerId: observerId)
  }
  
  override func viewWillAppear() {
    
    self.view.window?.delegate = self
    
    self.view.window?.title = String(localized: "Select Layout", comment: "Used for the title of the Select Layout window")
    
    if let appNode = myTrainsController.openLCBNetworkLayer?.myTrainsNode {
      observerId = appNode.addObserver(observer: self)
    }

  }
  
  // MARK: Private Properties
  
  private var layoutList : [LayoutListItem] = []
  
  private var observerId : Int = -1
  
  // MARK: MyTrainsAppDelete Methods
  
  func LayoutListUpdated(layoutList: [LayoutListItem]) {
    
    self.layoutList = []
    
    for item in layoutList {
      switch appMode {
      case .master:
        if item.masterNodeId == appNodeId! {
          self.layoutList.append(item)
        }
      case .delegate:
        if item.masterNodeId != appNodeId! && item.layoutState == .activated {
          self.layoutList.append(item)
        }
      default:
        break
      }
    }
    
    cboLayout.removeAllItems()
    
    for item in self.layoutList {
      cboLayout.addItem(withObjectValue: item.layoutName)
    }
    
  }
  
  // MARK: Controls
  
  let cboLayout = NSComboBox()
  
  // MARK: Actions
  
}
