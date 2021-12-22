//
//  EditLayoutsVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 20/12/2021.
//

import Foundation
import Cocoa

class EditLayoutsVC: NSViewController, NSWindowDelegate {
    
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }

  func windowWillClose(_ notification: Notification) {
    stopModal()
  }
  
  override func viewWillAppear() {
    
    self.view.window?.delegate = self
    editorView.dataArea = dataArea

  }
  
  @IBOutlet weak var dataArea: NSBox!
  
  @IBOutlet weak var editorView: DBEditorView!
  
}

