//
//  CDITextView2.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/12/2023.
//

import Foundation
import AppKit

class CDITextView: CDIDataView, NSTextFieldDelegate, NSControlTextEditingDelegate {
  
  // MARK: Private & Internal Properties

  internal var textView = NSView()
  
  internal var textField = NSTextField()
  
  internal var needsTextField = true
  
  // MARK: Public Properties
  
  override public var getData : [UInt8] {

    guard let data = getData(string: textField.stringValue) else {
      return []
    }
    
    return data
    
  }
    
  // MARK: Private & Internal Methods

  override internal func dataWasSet() {
    
    guard let string = setString() else {
      return
    }
    
    if elementType == .eventid, let value = UInt64(bigEndianData: bigEndianData) {
      textField.stringValue = value == 0 ? "" : value.toHexDotFormat(numberOfBytes: 8)
    }
    else {
      textField.stringValue = string
    }
    
  }
  
  public func addTextField() {
  
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

    textField.delegate = self
    
    NSLayoutConstraint.activate([
      textField.topAnchor.constraint(equalTo: textView.topAnchor),
      textField.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
      textView.heightAnchor.constraint(equalTo: textField.heightAnchor),
    ])

    if needsCopyPaste {

      if let elementType, elementType == .eventid {
        NSLayoutConstraint.activate([
          textField.widthAnchor.constraint(equalToConstant: 160)
        ])
        textField.placeholderString = "00.00.00.00.00.00.00.00"
      }
      else {
        NSLayoutConstraint.activate([
   //       textField.trailingAnchor.constraint(equalTo: dataButtonView.leadingAnchor, constant: -gap),
          dataButtonView.leadingAnchor.constraint(equalToSystemSpacingAfter: textField.trailingAnchor, multiplier: 1.0),
        ])
      }

      copyButton.target = self
      copyButton.action = #selector(self.btnCopyAction(_:))
      
      pasteButton.target = self
      pasteButton.action = #selector(self.btnPasteAction(_:))

    }
    else {

      NSLayoutConstraint.activate([
 //       textField.trailingAnchor.constraint(equalTo: dataButtonView.leadingAnchor, constant: -gap),
        dataButtonView.leadingAnchor.constraint(equalToSystemSpacingAfter: textField.trailingAnchor, multiplier: 1.0),
      ])

    }

    needsTextField = false
    
  }
  
  // MARK: NSTextFieldDelegate, NSControlTextEditingDelegate Methods

  @objc func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
    return isValid(string: control.stringValue)
  }

  @objc func controlTextDidChange(_ obj: Notification) {
    writeButton.isEnabled = isValid(string: textField.stringValue)
    delegate?.cdiDataViewSetWriteAllEnabledState?(writeButton.isEnabled)
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
