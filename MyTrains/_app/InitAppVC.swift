//
//  InitAppVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 10/03/2024.
//

import Foundation
import AppKit

class InitAppVC : NSViewController {
  
  // MARK: View & Window Control
  
  override func viewWillAppear() {
    
    super.viewWillAppear()
    
    progressIndicator.translatesAutoresizingMaskIntoConstraints = false
    progressIndicator.isIndeterminate = true
    progressIndicator.usesThreadedAnimation = true
    progressIndicator.style = .spinning
    progressIndicator.startAnimation(self)

    view.addSubview(progressIndicator)
    
    info.translatesAutoresizingMaskIntoConstraints = false
    info.lineBreakMode = .byWordWrapping
    info.isEditable = false
    info.isBordered = false
    info.drawsBackground = false
    info.maximumNumberOfLines = 0
    info.preferredMaxLayoutWidth = 500.0

    info.stringValue = String(localized: "MyTrains is initializing. This may take a few seconds.")
    
    view.addSubview(info)
    
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.image = logo
    
    view.addSubview(imageView)
    
    NSLayoutConstraint.activate([
      imageView.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 2.0),
      imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      info.topAnchor.constraint(equalToSystemSpacingBelow: imageView.bottomAnchor, multiplier: 2.0),
      info.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      progressIndicator.heightAnchor.constraint(equalToConstant: 30),
      progressIndicator.widthAnchor.constraint(equalToConstant: 30),
      progressIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      progressIndicator.topAnchor.constraint(equalToSystemSpacingBelow: info.bottomAnchor, multiplier: 3.0),
    ])
    
  }
  
  // MARK: Public Methods
  
  public func showWindow() {
    view.window?.windowController?.showWindow(nil)
  }
  
  public func closeWindow() {
    view.window?.close()
  }
  
  // MARK: Controls
  
  private let progressIndicator = NSProgressIndicator()
  
  private let info = NSTextField(labelWithString: "")
  
  private let logo = NSImage(named: NSImage.applicationIconName)
  
  private let imageView = NSImageView()
  
}
