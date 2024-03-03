//
//  CreateVirtualNodeVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/01/2024.
//

import Foundation
import AppKit

class CreateVirtualNodeVC: MyTrainsViewController {
  
  // MARK: Window & View Control
  
  override func viewWillAppear() {
    
    super.viewWillAppear()
    
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
