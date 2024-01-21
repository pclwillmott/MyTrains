//
//  CreateVirtualNodeVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/01/2024.
//

import Foundation
import AppKit

class CreateVirtualNodeVC: NSViewController, NSWindowDelegate {
  
  // MARK: Window & View Control
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }
  
  func windowWillClose(_ notification: Notification) {
  }
  
  override func viewWillAppear() {
    
    self.view.window?.delegate = self
    
    self.view.window?.title = ""
    
    lblMessage.translatesAutoresizingMaskIntoConstraints = false
    lblMessage.stringValue = String(localized: "Creating virtual node. This may take several seconds to complete.")
    lblMessage.lineBreakMode = .byWordWrapping
    lblMessage.maximumNumberOfLines = 0
    lblMessage.preferredMaxLayoutWidth = 300.0
    lblMessage.alignment = .center
//    lblMessage.font = NSFont(name: lblMessage.font!.familyName!, size: 11.0)

    barProgress.translatesAutoresizingMaskIntoConstraints = false
    barProgress.isIndeterminate = true
    barProgress.usesThreadedAnimation = true
    barProgress.style = .spinning
    barProgress.startAnimation(self)

    view.addSubview(lblMessage)
    view.addSubview(barProgress)
    
    NSLayoutConstraint.activate([
      barProgress.heightAnchor.constraint(equalToConstant: 30),
      barProgress.widthAnchor.constraint(equalToConstant: 30),
      barProgress.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      barProgress.topAnchor.constraint(equalToSystemSpacingBelow: lblMessage.bottomAnchor, multiplier: 3),
      lblMessage.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 1.0),
      lblMessage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      view.bottomAnchor.constraint(equalToSystemSpacingBelow: barProgress.bottomAnchor, multiplier: 1.0),
    ])
    
  }
  
  // MARK: Public Methods
  
  public func stop() {
    self.view.window?.close()
  }
  
  // MARK: Controls
  
  let lblMessage = NSTextField(labelWithString: "")
  
  let barProgress = NSProgressIndicator()
  
  // MARK: Actions
  
}
