//
//  CDITextView.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/12/2023.
//

import Foundation
import AppKit

class CDITextView: CDIDataView {
  
  // MARK: Private & Internal Properties

  internal var copyButton = NSButton()
  
  internal var pasteButton = NSButton()

  internal var needsCopyPaste : Bool {
    guard let viewType = viewType() else {
      return false
    }
    let needs : Set<OpenLCBCDIViewType> = [.eventid]
    return needs.contains(viewType)
  }
  
  internal var _textField : NSTextField?

  internal var textField : NSTextField {
    
    if _textField == nil {
      
      addButtons()
      
      let field = NSTextField()
      
      box.addSubview(field)
      
      field.translatesAutoresizingMaskIntoConstraints = false
      
      NSLayoutConstraint.activate([
        field.topAnchor.constraint(equalTo: lastAnchor!, constant: nextYGap),
        field.leftAnchor.constraint(equalTo: box.leftAnchor, constant: gap),
      ])
      
      if needsCopyPaste {

        if let viewType = self.viewType(), viewType == .eventid {
          NSLayoutConstraint.activate([
            field.widthAnchor.constraint(equalToConstant: 160)
          ])
        }
        else {
          NSLayoutConstraint.activate([
            field.rightAnchor.constraint(equalTo: copyButton.leftAnchor, constant: -gap),
          ])
        }

        copyButton.target = self
        copyButton.action = #selector(self.btnCopyAction(_:))
        
        pasteButton.target = self
        pasteButton.action = #selector(self.btnPasteAction(_:))
        
      }
      else {
        
        NSLayoutConstraint.activate([
          field.rightAnchor.constraint(equalTo: refreshButton.leftAnchor, constant: -gap),
        ])
        
      }
      
      lastAnchor = field.bottomAnchor
      
      nextYGap = gap

      _textField = field
   
      NSLayoutConstraint.activate([
        box.bottomAnchor.constraint(equalTo: field.bottomAnchor, constant: 6.0),
        self.heightAnchor.constraint(equalTo: box.heightAnchor, constant: gap),
      ])
      
    }
    
    return _textField!
    
  }

  // MARK: Public Properties

  // MARK: Private & Internal Methods
  
  override internal func addButtons() {
    
    guard let viewType = self.viewType() else {
      return
    }
    
    super.addButtons()
    
    if needsCopyPaste {
      
      box.addSubview(pasteButton)
      pasteButton.title = "Paste"
      pasteButton.translatesAutoresizingMaskIntoConstraints = false
      
      NSLayoutConstraint.activate([
        pasteButton.topAnchor.constraint(equalTo: lastAnchor!, constant: nextYGap),
        pasteButton.rightAnchor.constraint(equalTo: refreshButton.leftAnchor, constant: -gap),
        pasteButton.widthAnchor.constraint(equalTo: refreshButton.widthAnchor)
      ])

      box.addSubview(copyButton)
      copyButton.title = "Copy"
      copyButton.translatesAutoresizingMaskIntoConstraints = false
      
      NSLayoutConstraint.activate([
        copyButton.topAnchor.constraint(equalTo: lastAnchor!, constant: nextYGap),
        copyButton.rightAnchor.constraint(equalTo: pasteButton.leftAnchor, constant: -gap),
        copyButton.widthAnchor.constraint(equalTo: refreshButton.widthAnchor)
      ])

    }

  }

  internal func displayErrorMessage(message: String) {
    
    let alert = NSAlert()

    alert.messageText = "Error"
    alert.informativeText = message
    alert.addButton(withTitle: "OK")
    alert.alertStyle = .critical

    let _ = alert.runModal()

  }

  internal func isValid(value:String) -> Bool {
    return true
  }
  
  // MARK: Outlets & Actions
  
  @IBAction func btnCopyAction(_ sender: NSButton) {
    let pasteboard = NSPasteboard.general
    pasteboard.declareTypes([.string], owner: nil)
    pasteboard.setString(textField.stringValue, forType: .string)
  }

  @IBAction func btnPasteAction(_ sender: NSButton) {
    let pasteboard = NSPasteboard.general
    let value = pasteboard.string(forType: .string) ?? ""
    textField.stringValue = value
  }

}

