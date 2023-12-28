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
  
  internal var needsTextField = true

  internal var needsCopyPaste : Bool {
    guard let viewType = viewType() else {
      return false
    }
    let needs : Set<OpenLCBCDIViewType> = [.eventid]
    return needs.contains(viewType)
  }
  
  internal var textField = NSTextField()
  
  // MARK: Public Properties

  public var minValue : String?
  
  public var maxValue : String?
  
  // MARK: Private & Internal Methods
  
  override internal func addButtons() {
    
    guard self.viewType() != nil else {
      return
    }
    
    super.addButtons()
    
    if needsCopyPaste {
      
      box.addSubview(pasteButton)
      pasteButton.title = "Paste"
      pasteButton.translatesAutoresizingMaskIntoConstraints = false
      
      NSLayoutConstraint.activate([
        pasteButton.topAnchor.constraint(equalTo: nextTop!, constant: nextGap),
        pasteButton.rightAnchor.constraint(equalTo: refreshButton.leftAnchor, constant: -gap),
        pasteButton.widthAnchor.constraint(equalTo: refreshButton.widthAnchor),
      ])

      box.addSubview(copyButton)
      copyButton.title = "Copy"
      copyButton.translatesAutoresizingMaskIntoConstraints = false
      
      NSLayoutConstraint.activate([
        copyButton.topAnchor.constraint(equalTo: nextTop!, constant: nextGap),
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

  internal func addTextField() {
    
    guard needsTextField else {
      return
    }
    
    addButtons()
    
    textField.translatesAutoresizingMaskIntoConstraints = false
    
    box.addSubview(textField)

    NSLayoutConstraint.activate([
      textField.topAnchor.constraint(equalTo: nextTop!, constant: nextGap),
      textField.leftAnchor.constraint(equalTo: box.leftAnchor, constant: gap),
    ])

    nextTop = textField.bottomAnchor
    
    nextGap = gap
    
    setBottomToLastItem(lastItem: nextTop!)

    if needsCopyPaste {

      if let viewType = self.viewType(), viewType == .eventid {
        NSLayoutConstraint.activate([
          textField.widthAnchor.constraint(equalToConstant: 160)
        ])
      }
      else {
        NSLayoutConstraint.activate([
          textField.rightAnchor.constraint(equalTo: copyButton.leftAnchor, constant: -gap),
        ])
      }

      copyButton.target = self
      copyButton.action = #selector(self.btnCopyAction(_:))
      
      pasteButton.target = self
      pasteButton.action = #selector(self.btnPasteAction(_:))
      
    }
    else {
      
      NSLayoutConstraint.activate([
        textField.rightAnchor.constraint(equalTo: refreshButton.leftAnchor, constant: -gap),
      ])
      
    }
    
    needsTextField = false
    
  }
  
  // MARK: Public Methods
  
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

