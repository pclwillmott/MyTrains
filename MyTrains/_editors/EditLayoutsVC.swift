//
//  EditLayoutsVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 20/12/2021.
//

import Foundation
import Cocoa

class EditLayoutsVC: MyTrainsViewController, DBEditorDelegate {

  // MARK: Window & View Control
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func windowWillClose(_ notification: Notification) {
    stopModal()
    super.windowWillClose(notification)
  }
  
  override func viewWillAppear() {
    
    super.viewWillAppear()
    
    editorView.delegate = self

    editorView.tabView = self.tabView
    
//    editorView.dictionary = myTrainsController.layouts
    
  }
  
  // MARK: DBEditorView Delegate Methods
  
  func clearFields(dbEditorView: DBEditorView) {
    txtLayoutName.stringValue = ""
    txtDescription.stringValue = ""
  }
  
  func setupFields(dbEditorView: DBEditorView, editorObject: EditorObject) {
    if let layout = editorObject as? Layout {
      txtLayoutName.stringValue = layout.layoutName
      txtDescription.stringValue = layout.layoutDescription
      txtScale.stringValue = "\(layout.scale)"
    }
  }
  
  func validate(dbEditorView: DBEditorView) -> String? {
    if txtLayoutName.stringValue.trimmingCharacters(in: .whitespaces) == "" {
      txtLayoutName.becomeFirstResponder()
      return "The layout must have a name."
    }
    if let _ = Double(txtScale.stringValue) {
    }
    else {
      txtScale.becomeFirstResponder()
      return "A scale greater than zero is required."
    }
    return nil
  }
  
  func setFields(layout:Layout) {
    layout.layoutName = txtLayoutName.stringValue
    layout.layoutDescription = txtDescription.stringValue
    layout.scale = Double(txtScale.stringValue) ?? 1.0
    layout.save()
  }
  
  func saveNew(dbEditorView: DBEditorView) -> EditorObject {
    let layout = Layout()
    setFields(layout: layout)
//    myTrainsController.addLayout(layout: layout)
//    editorView.dictionary = myTrainsController.layouts
    editorView.setSelection(key: layout.primaryKey)
    return layout
  }
  
  func saveExisting(dbEditorView: DBEditorView, editorObject: EditorObject) {
    if let layout = editorObject as? Layout {
      setFields(layout: layout)
//      editorView.dictionary = myTrainsController.layouts
      editorView.setSelection(key: layout.primaryKey)
    }
  }

  func delete(dbEditorView: DBEditorView, primaryKey: Int) {
    Layout.delete(primaryKey: primaryKey)
 //   myTrainsController.removeLayout(primaryKey: primaryKey)
//    editorView.dictionary = myTrainsController.layouts
  }

  // MARK: Outlets & Actions
  
  @IBOutlet weak var editorView: DBEditorView!
  
  @IBOutlet weak var txtLayoutName: NSTextField!
  
  @IBAction func txtLayoutNameAction(_ sender: NSTextField) {
    editorView.modified = true
  }
  
  @IBOutlet weak var txtDescription: NSTextField!
  
  @IBAction func txtDescriptionAction(_ sender: NSTextField) {
    editorView.modified = true
  }
  
  @IBOutlet weak var tabView: NSTabView!
  
  @IBOutlet weak var txtScale: NSTextField!
  
  @IBAction func txtScaleAction(_ sender: NSTextField) {
    editorView.modified = true
  }
  
}

