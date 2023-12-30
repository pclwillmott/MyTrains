//
//  CDITextView2.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/12/2023.
//

import Foundation
import AppKit

class CDITextView: CDIDataView {
  
  // MARK: Private & Internal Properties

  internal var textView = NSView()
  
  internal var textField = NSTextField()
  
  internal var needsTextField = true
  
  // MARK: Public Properties

  public var minValue : String?
  
  public var maxValue : String?
  
  // MARK: Private & Internal Methods
  
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
    
    textView.translatesAutoresizingMaskIntoConstraints = false
    
    stackView.addArrangedSubview(textView)

    NSLayoutConstraint.activate([
      textView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
      textView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
    ])

    addButtons(view:textView)
    
    textField.translatesAutoresizingMaskIntoConstraints = false
    
    textView.addSubview(textField)

    NSLayoutConstraint.activate([
      textField.topAnchor.constraint(equalTo: textView.topAnchor),
      textField.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: gap),
      textView.heightAnchor.constraint(equalTo: textField.heightAnchor),
    ])

    if needsCopyPaste {

      if let viewType = self.viewType(), viewType == .eventid {
        NSLayoutConstraint.activate([
          textField.widthAnchor.constraint(equalToConstant: 160)
        ])
      }
      else {
        NSLayoutConstraint.activate([
          textField.trailingAnchor.constraint(equalTo: dataButtonView.leadingAnchor, constant: -gap),
        ])
      }

      copyButton.target = self
      copyButton.action = #selector(self.btnCopyAction(_:))
      
      pasteButton.target = self
      pasteButton.action = #selector(self.btnPasteAction(_:))
      
    }
    else {
      
      NSLayoutConstraint.activate([
        textField.trailingAnchor.constraint(equalTo: dataButtonView.leadingAnchor, constant: -gap),
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

