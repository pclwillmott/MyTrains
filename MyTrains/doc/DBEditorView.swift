//
//  DBEditorView.swift
//  MyTrains
//
//  Created by Paul Willmott on 20/12/2021.
//

import Cocoa

public enum DBEditorState {
  case select
  case editNew
  case editExisting
}

protocol DBEditorDelegate {
  func clearFields(dbEditorView:DBEditorView)
  func setupFields(dbEditorView:DBEditorView, editorObject:EditorObject)
  func validate(dbEditorView:DBEditorView) -> String?
  func saveNew(dbEditorView:DBEditorView) -> EditorObject
  func saveExisting(dbEditorView:DBEditorView, editorObject:EditorObject)
  func delete(dbEditorView:DBEditorView, primaryKey: Int)
}

class DBEditorView: NSView {

  // View Control
  
  public override func draw(_ dirtyRect: NSRect) {
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
  
  private var _modified = false

  private var _tabView : NSTabView?
  
  private var first = true

  // Public Properties
  
  public var tabView : NSTabView? {
    get {
      return _tabView
    }
    set(value) {
      _tabView = value
      setControls()
    }
  }
  
  public func setSelection(key:Int) {
    if dataSource.numberOfItems(in: cboSelect) > 0 {
      if let index = dataSource.indexWithKey(key: key) {
        cboSelect.selectItem(at: index)
        if let editorObject = dataSource.editorObjectAt(index: cboSelect.indexOfSelectedItem) {
          delegate?.setupFields(dbEditorView: self, editorObject: editorObject)
        }
      }
    }
    setControls()
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
      cboSelect.dataSource = nil
      cboSelect.dataSource = dataSource
      cboSelect.reloadData()
      
      if first {
        if dataSource.numberOfItems(in: cboSelect) > 0 {
          cboSelect.selectItem(at: 0)
          if let editorObject = dataSource.editorObjectAt(index: cboSelect.indexOfSelectedItem) {
            delegate?.setupFields(dbEditorView: self, editorObject: editorObject)
          }
        }
        setControls()
        first = false
      }
      
    }
  }
  
  public var modified : Bool {
    get {
      return _modified
    }
    set(value) {
      if value != _modified {
        _modified = value
        setControls()
      }
    }
  }
  
  // Private Methods
  
  private func setControls() {
    
    var enableTabs = false
    
    switch editorState {
    case .select:
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
      enableTabs = true
    }
    
    if let tv = _tabView {
      for tab in tv.tabViewItems {
        for control in tab.view!.subviews {
          if let text = control as? NSTextField {
            text.isEnabled = enableTabs
          }
          else if let combo = control as? NSComboBox {
            combo.isEnabled = enableTabs
          }
          else if let button = control as? NSButton {
            button.isEnabled = enableTabs
          }
          else if let box = control as? NSBox {
            for subControl in box.contentView!.subviews {
              if let text = subControl as? NSTextField {
                text.isEnabled = enableTabs
              }
              else if let combo = subControl as? NSComboBox {
                combo.isEnabled = enableTabs
              }
              else if let button = subControl as? NSButton {
                button.isEnabled = enableTabs
              }
            }
          }

        }
      }
    }
    
  }
  
  // Outlets & Actions
  
  @IBOutlet var contentView: DBEditorView!
  
  @IBOutlet weak var cboSelect: NSComboBox!
  
  @IBAction func cboSelectAction(_ sender: NSComboBox) {
    if let editorObject = dataSource.editorObjectAt(index: cboSelect.indexOfSelectedItem) {
      delegate?.setupFields(dbEditorView: self, editorObject: editorObject)
    }
  }
  
  @IBOutlet weak var btnNew: NSButton!
  
  @IBAction func btnNewAction(_ sender: NSButton) {
    editorState = .editNew
    setControls()
    delegate?.clearFields(dbEditorView: self)
    modified = false
  }
  
  @IBOutlet weak var btnEdit: NSButton!
  
  @IBAction func btnEditAction(_ sender: NSButton) {
    editorState = .editExisting
    if let editorObject = dataSource.editorObjectAt(index: cboSelect.indexOfSelectedItem) {
      delegate?.setupFields(dbEditorView: self, editorObject: editorObject)
    }
    setControls()
  }
  
  @IBOutlet weak var btnSave: NSButton!
  
  @IBAction func btnSaveAction(_ sender: NSButton) {
    
    var okToSave = true
    
    if let del = delegate, let message = del.validate(dbEditorView: self) {
      
      let alert = NSAlert()

      alert.messageText = "Error"
      alert.informativeText = message
      alert.addButton(withTitle: "OK")
   // alert.addButton(withTitle: "Cancel")
      alert.alertStyle = .critical

      let _ = alert.runModal() // == NSAlertFirstButtonReturn
      
      okToSave = false

    }
    
    if okToSave {
      
      var key : Int = -1
      
      switch editorState {
      case .editNew:
        if let editorObject = delegate?.saveNew(dbEditorView: self) {
          key = editorObject.primaryKey
        }
        break
      case .editExisting:
        if let editorObject = dataSource.editorObjectAt(index: cboSelect.indexOfSelectedItem) {
          delegate?.saveExisting(dbEditorView: self, editorObject: editorObject)
          key = editorObject.primaryKey
        }
        break
      default:
        break
      }
      
      if key == -1 {
        cboSelect.deselectItem(at: cboSelect.indexOfSelectedItem)
      }
      else if let index = dataSource.indexWithKey(key: key) {
        cboSelect.selectItem(at: index)
      }

      editorState = .select
      setControls()
      
    }
  }
  
  @IBOutlet weak var btnCancel: NSButton!
  
  @IBAction func btnCancelAction(_ sender: NSButton) {
    switch editorState {
    case .editNew:
      delegate?.clearFields(dbEditorView: self)
      break
    case .editExisting:
      if let editorObject = dataSource.editorObjectAt(index: cboSelect.indexOfSelectedItem) {
        delegate?.setupFields(dbEditorView: self, editorObject: editorObject)
      }
      break
    default:
      break
    }
    editorState = .select
    setControls()
  }
  
  @IBOutlet weak var btnDelete: NSButton!
  
  @IBAction func btnDeleteAction(_ sender: NSButton) {
    
    var deleted = false
    
    if let editorObject = dataSource.editorObjectAt(index: cboSelect.indexOfSelectedItem) {
      
      let alert = NSAlert()

      alert.messageText = editorObject.deleteCheck()
      alert.informativeText = ""
      alert.addButton(withTitle: "No")
      alert.addButton(withTitle: "Yes")
      alert.alertStyle = .warning

      if alert.runModal() == NSApplication.ModalResponse.alertSecondButtonReturn {
        delegate?.delete(dbEditorView: self, primaryKey: editorObject.primaryKey)
        delegate?.clearFields(dbEditorView: self)
        deleted = true
      }
    }
    if deleted {
      cboSelect.deselectItem(at: cboSelect.indexOfSelectedItem)
      editorState = .select
      setControls()
    }
  }
  
}
