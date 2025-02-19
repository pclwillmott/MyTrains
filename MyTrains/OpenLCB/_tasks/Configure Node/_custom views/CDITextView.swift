//
//  CDITextView2.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/12/2023.
//

import Foundation
import AppKit

class CDITextView: CDIDataView, NSTextFieldDelegate, NSControlTextEditingDelegate {
  
  // MARK: Destructors

  deinit {
    textView?.subviews.removeAll()
    textView = nil
    textField = nil
    textField?.target = nil
    textField?.delegate = nil
    subviews.removeAll()
  }
  
  // MARK: Private & Internal Properties

  internal var textView : NSView? = NSView()
  
  internal var textField : NSTextField? = NSTextField()
  
  internal var needsTextField = true
  
  // MARK: Public Properties
  
  override public var getData : [UInt8] {

    guard let textField, let data = getData(string: textField.stringValue) else {
      return []
    }
    
    return data
    
  }
    
  // MARK: Private & Internal Methods

  override internal func dataWasSet() {
    
    guard let textField, let string = setString() else {
      return
    }
    
    if elementType == .eventid, let value = UInt64(bigEndianData: bigEndianData) {
      textField.stringValue = value == 0 ? "" : value.dotHex(numberOfBytes: 8)!
    }
    else {
      textField.stringValue = string
    }
    
  }
  
  public func addTextField() {
  
    guard needsTextField, let stackView, let copyButton, let pasteButton, let dataButtonView, let newEventId, let textView, let textField else {
      return
    }

    textView.translatesAutoresizingMaskIntoConstraints = false
    
    stackView.addArrangedSubview(textView)

    cdiConstraints.append(contentsOf:[
      textView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
      textView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
    ])

    addButtons(view:textView)

    textField.translatesAutoresizingMaskIntoConstraints = false
    
    textView.addSubview(textField)

    textField.delegate = self
    
    cdiConstraints.append(contentsOf:[
      textField.topAnchor.constraint(equalTo: textView.topAnchor),
      textField.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
      textView.heightAnchor.constraint(equalTo: textField.heightAnchor),
    ])

    if needsCopyPaste {

      if let elementType, elementType == .eventid {
        cdiConstraints.append(contentsOf:[
          textField.widthAnchor.constraint(equalToConstant: 170)
        ])
        textField.placeholderString = "00.00.00.00.00.00.00.00"
        cdiConstraints.append(contentsOf:[
//          dataButtonView.leadingAnchor.constraint(equalTo: newEventId.leadingAnchor)
        ])

      }
      else {
        cdiConstraints.append(contentsOf:[
   //       textField.trailingAnchor.constraint(equalTo: dataButtonView.leadingAnchor, constant: -siblingGap),
          dataButtonView.leadingAnchor.constraint(lessThanOrEqualTo: dataButtonView.leadingAnchor, constant: -siblingGap),
        ])
      }
      
      copyButton.target = self
      copyButton.action = #selector(self.btnCopyAction(_:))
      
      pasteButton.target = self
      pasteButton.action = #selector(self.btnPasteAction(_:))

      newEventId.target = self
      newEventId.action = #selector(self.newEventIdAction(_:))
      
    }
    else {

      cdiConstraints.append(contentsOf:[
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
    guard let textField, let writeButton else {
      return
    }
    writeButton.isEnabled = isValid(string: textField.stringValue)
    delegate?.cdiDataViewSetWriteAllEnabledState?(writeButton.isEnabled)
  }

  // MARK: Outlets & Actions
  
  @IBAction func btnCopyAction(_ sender: NSButton) {
    guard let textField else {
      return
    }
    let pasteboard = NSPasteboard.general
    pasteboard.declareTypes([.string], owner: nil)
    pasteboard.setString(textField.stringValue, forType: .string)
  }

  @IBAction func btnPasteAction(_ sender: NSButton) {
    guard let textField else {
      return
    }
    let pasteboard = NSPasteboard.general
    let value = pasteboard.string(forType: .string) ?? ""
    textField.stringValue = value
  }

  @IBAction func newEventIdAction(_ sender: NSButton) {
    guard let textField else {
      return
    }
    delegate?.cdiDataViewGetNewEventId?(textField: textField)
  }

}
