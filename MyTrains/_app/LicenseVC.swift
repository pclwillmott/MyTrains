//
//  LicenseVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 27/01/2024.
//

import Foundation
import AppKit

class LicenseVC: MyTrainsViewController {
  
  // MARK: Window & View Control
  
  override func windowWillClose(_ notification: Notification) {
    stopModal()
    super.windowWillClose(notification)
  }
  
  override func viewWillAppear() {
    
    super.viewWillAppear()
    
    self.view.window?.title = String(localized: "Select Layout", comment: "Used for the title of the Select Layout window")
    
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    buttonAccept.translatesAutoresizingMaskIntoConstraints = false
    buttonDecline.translatesAutoresizingMaskIntoConstraints = false
    textView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.documentView?.translatesAutoresizingMaskIntoConstraints = false
    textView.isEditable = false
    
    view.addSubview(scrollView)
    view.addSubview(buttonAccept)
    view.addSubview(buttonDecline)
    
    scrollView.documentView = textView
    scrollView.hasVerticalScroller = true
    
    buttonDecline.keyEquivalent = "\r"
    buttonDecline.keyEquivalentModifierMask = []
    buttonAccept.target = self
    buttonAccept.action = #selector(self.btnAcceptAction(_:))
    buttonDecline.target = self
    buttonDecline.action = #selector(self.btnDeclineAction(_:))

    buttonAccept.title = String(localized: "Accept", comment: "Used to accept license agreement")
    buttonDecline.title = String(localized: "Decline", comment: "Used to decline license agreement")

    buttonDecline.setButtonType(.momentaryPushIn)
    buttonDecline.keyEquivalentModifierMask = []
    buttonDecline.keyEquivalent = "\r"

    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 1.0),
      scrollView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1.0),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.0),
      buttonDecline.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1.0),
      buttonAccept.leadingAnchor.constraint(equalToSystemSpacingAfter: buttonDecline.trailingAnchor, multiplier: 1.0),
      buttonAccept.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant:  -20.0),
      buttonDecline.bottomAnchor.constraint(equalTo: buttonAccept.bottomAnchor),
      scrollView.bottomAnchor.constraint(equalTo: buttonAccept.topAnchor, constant: -8.0),
      textView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
      textView.heightAnchor.constraint(equalToConstant: 1000),
    ])
    
    scrollView.autoresizesSubviews = true
    
    if let filepath = Bundle.main.path(forResource: "License", ofType: "txt") {
      do {
        let text = try String(contentsOfFile: filepath)
        textView.string = text.replacingOccurrences(of: "%%COPYRIGHT%%", with: appCopyright)
      }
      catch {
      }
    }

  }
  
  // MARK: Controls
  
  var scrollView : NSScrollView = NSScrollView()
  
  var buttonAccept = NSButton()
  
  var buttonDecline = NSButton()
  
  var textView = NSTextView()
  
  // MARK: Actions
  
  @IBAction func btnAcceptAction(_ sender: NSButton) {
    eulaAccepted = true
    stopModal()
    view.window?.close()
  }
  
  @IBAction func btnDeclineAction(_ sender: NSButton) {
    exit(0)
  }

}

