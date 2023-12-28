//
//  CDISegmentView.swift
//  MyTrains
//
//  Created by Paul Willmott on 28/12/2023.
//

import Foundation
import AppKit

class CDISegmentView: CDIView {
  
  // MARK: Drawing Stuff
  
  override func draw(_ dirtyRect: NSRect) {
    setup()
  }
  
  // MARK: Private & Internal Methods
  
  internal let gap : CGFloat = 5.0
  
  internal var needsInit = true
  
  internal var contentView = NSView()
  
  internal var disclosureButton = NSButton()
  
  internal var title = NSTextField()
  
  internal var lastDisclosureConstraint : NSLayoutConstraint?

  internal var isOpen : Bool = false
  
  // MARK: Public Properties
  
  public var name : String {
    get {
      return title.stringValue
    }
    set(value) {
      title.stringValue = value
    }
  }
  
  // MARK: Private & Internal Methods
  
  internal func setup() {
    
    guard needsInit else {
      return
    }
    
    disclosureButton.translatesAutoresizingMaskIntoConstraints = false
    disclosureButton.setButtonType(.onOff)
    disclosureButton.bezelStyle = .disclosure
    disclosureButton.isBordered = true
    disclosureButton.imagePosition = .imageOnly
    disclosureButton.isEnabled = true
    
    disclosureButton.target = self
    disclosureButton.action = #selector(self.btnDisclosureAction(_:))

    addSubview(disclosureButton)
 
    NSLayoutConstraint.activate([
      disclosureButton.topAnchor.constraint(equalTo: self.topAnchor, constant: gap),
      disclosureButton.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      disclosureButton.heightAnchor.constraint(equalToConstant: 20),
      disclosureButton.widthAnchor.constraint(equalToConstant: 20),
    ])
    
    title.translatesAutoresizingMaskIntoConstraints = false
    title.isEditable = false
    title.drawsBackground = false
    title.isBordered = false
    
    addSubview(title)

    NSLayoutConstraint.activate([
      title.topAnchor.constraint(equalTo: self.topAnchor, constant: gap),
      title.leadingAnchor.constraint(equalTo: disclosureButton.trailingAnchor, constant: gap),
      title.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: gap),
    ])
    
    contentView.translatesAutoresizingMaskIntoConstraints = false
    
    addSubview(contentView)
    
    let button = NSTextField(labelWithString: "Freddy")
    
    contentView.addSubview(button)
    
    NSLayoutConstraint.activate([
      contentView.topAnchor.constraint(equalTo: title.bottomAnchor, constant: gap),
      contentView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: gap),
      contentView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -gap),
      contentView.heightAnchor.constraint(equalToConstant: 100),
    ])
    
    lastDisclosureConstraint = self.heightAnchor.constraint(equalToConstant: 20)
    
    NSLayoutConstraint.activate([
      lastDisclosureConstraint!,
    ])
    
    needsInit = false

  }
  
  internal func doDisclosure() {
    
    NSLayoutConstraint.deactivate([
      lastDisclosureConstraint!,
    ])

    lastDisclosureConstraint = self.heightAnchor.constraint(equalToConstant: disclosureButton.state == .on ? contentView.fittingSize.height + 20.0 : 20.0)
    
    contentView.isHidden = disclosureButton.state == .off
    
    NSLayoutConstraint.activate([
      lastDisclosureConstraint!,
    ])

  }
  
  // MARK: Public Methods
  
  // MARK: Outlets & Actions
  
  @IBAction func btnDisclosureAction(_ sender: NSButton) {
    doDisclosure()
  }

}

