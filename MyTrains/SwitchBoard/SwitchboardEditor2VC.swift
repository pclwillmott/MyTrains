//
//  SwitchboardEditorVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 13/04/2024.
//

import Foundation
import AppKit

class SwitchboardEditor2VC: MyTrainsViewController {
  
  // MARK: Window & View Methods
  
  override func windowWillClose(_ notification: Notification) {
    super.windowWillClose(notification)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewType = .switchboardPanel
  }
  
  override func viewWillAppear() {
    
    super.viewWillAppear()
    
    view.window?.title = ""
    
    
    NSLayoutConstraint.activate([
    ])
    
    /*
     if let appNode {
     for (_, item) in appNode.panelList {
     panels.append(item)
     }
     panels.sort {$0.userNodeName < $1.userNodeName}
     cboPanel.removeAllItems()
     var index = -1
     var test = 0
     for item in panels {
     cboPanel?.addItem(withObjectValue: item.userNodeName)
     if let panel = switchboardView.switchboardPanel, panel.nodeId == item.nodeId {
     index = test
     }
     test += 1
     }
     if index != -1 {
     cboPanel.selectItem(at: index)
     }
     }
     */
    
  }
  
}
