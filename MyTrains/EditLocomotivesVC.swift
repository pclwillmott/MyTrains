//
//  EditLocomotivesVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 20/12/2021.
//

import Foundation
import Cocoa

class EditLocomotivesVC: NSViewController, NSWindowDelegate, DBEditorDelegate {
 
  // Window & View Control
  
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
    
    editorView.delegate = self
    
    editorView.tabView = tabView
    
    // do comboBoxDS here
    
    editorView.dictionary = networkController.locomotives

  }
  
  // DBEditorDelegate Methods
  
  func clearFields(dbEditorView: DBEditorView) {
    
  }
  
  func setupFields(dbEditorView: DBEditorView, editorObject: EditorObject) {
    
  }
  
  func validate(dbEditorView: DBEditorView) -> String? {
    return ""
  }
  
  func saveNew(dbEditorView: DBEditorView) -> EditorObject {
    return EditorObject(primaryKey: -1)
  }
  
  func saveExisting(dbEditorView: DBEditorView, editorObject: EditorObject) {
    
  }
  
  func delete(dbEditorView: DBEditorView, primaryKey: Int) {
    
  }
  
  // Outlets & Actions
  
  @IBOutlet weak var tabView: NSTabView!
  
  @IBOutlet weak var editorView: DBEditorView!
  
}
