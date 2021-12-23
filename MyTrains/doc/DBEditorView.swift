//
//  DBEditorView.swift
//  MyTrains
//
//  Created by Paul Willmott on 20/12/2021.
//

import Cocoa

public enum DBEditorState {
  case select
  case selectAndDisplay
  case editNew
  case editExisting
}

public protocol DBEditorDelegate {
  
}

class DBEditorView: NSView {

  // View Control
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)

    // Drawing code here.
    
  }

  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)!
    initSubviews()
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    initSubviews()
  }

  func initSubviews() {
    
    // standard initialization logic
    
    if let nib = NSNib(nibNamed: "DBEditorView", bundle: nil) {
      nib.instantiate(withOwner: self, topLevelObjects: nil)
      contentView.frame = bounds
      addSubview(contentView)
    }

    // custom initialization logic
    
  }
  
  // Private Properties
  
  private var editorState : DBEditorState = .select
  
  private var dataSource : ComboBoxDictDS = ComboBoxDictDS()
  
  private var _dictionary : [Int:Any]?
  
  private var modified = false

  private var _tabView : NSTabView?

  // Public Properties
  
  public var tabView : NSTabView? {
    get {
      return _tabView
    }
    set(value) {
      _tabView = value
      if let tv = _tabView {

        for control in tv.subviews {
          print(control)
          if let button = control as? NSButton {
            button.isEnabled = false
          }
        }
      }
    }
  }
  
  public var delegate : DBEditorDelegate?
  
  public var dictionary : [Int:Any]? {
    get {
      return _dictionary
    }
    set(value) {
      _dictionary = value
      if let dict = _dictionary {
        dataSource.dictionary = dict
      }
      else {
        dataSource.dictionary = [:]
      }
      cboSelect.dataSource = dataSource
      cboSelect.reloadData()
    }
  }
  
  // Private Methods
  
  private func setControls() {
    
    switch editorState {
    case .select, .selectAndDisplay:
      btnNew.isEnabled = true
      btnEdit.isEnabled = cboSelect.numberOfItems > 0
      btnSave.isEnabled = false
      btnCancel.isEnabled = false
      btnDelete.isEnabled = cboSelect.numberOfItems > 0
    case .editExisting, .editNew:
      btnNew.isEnabled = false
      btnEdit.isEnabled = false
      btnSave.isEnabled = modified
      btnCancel.isEnabled = true
      btnDelete.isEnabled = false
    }
    
  }
  
  // Outlets & Actions
  
  @IBOutlet var contentView: DBEditorView!
  
  @IBOutlet weak var cboSelect: NSComboBox!
  
  @IBAction func cboSelectAction(_ sender: NSComboBox) {
  }
  
  @IBOutlet weak var btnNew: NSButton!
  
  @IBAction func btnNewAction(_ sender: NSButton) {
    editorState = .editNew
    setControls()
  }
  
  @IBOutlet weak var btnEdit: NSButton!
  
  @IBAction func btnEditAction(_ sender: NSButton) {
    editorState = .editExisting
    setControls()
 }
  
  @IBOutlet weak var btnSave: NSButton!
  
  @IBAction func btnSaveAction(_ sender: NSButton) {
    editorState = .select
    setControls()
  }
  
  @IBOutlet weak var btnCancel: NSButton!
  
  @IBAction func btnCancelAction(_ sender: NSButton) {
    editorState = .select
    setControls()
  }
  
  @IBOutlet weak var btnDelete: NSButton!
  
  @IBAction func btnDeleteAction(_ sender: NSButton) {
    editorState = .select
    setControls()
  }
  
}
