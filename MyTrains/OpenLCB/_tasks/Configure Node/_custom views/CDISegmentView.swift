//
//  CDISegmentView.swift
//  MyTrains
//
//  Created by Paul Willmott on 28/12/2023.
//

import Foundation
import AppKit

class CDISegmentView: CDIView, CDIStackViewManagerDelegate {
  
  // MARK: Private & Internal Methods
  
  internal var contentView = NSStackView()
  
  internal var disclosureButton = NSButton()
  
  internal var title = NSTextField()
  
  internal var lastDisclosureConstraint : NSLayoutConstraint?

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
  
  override internal func setup() {
    
    guard needsInit else {
      return
    }
    
    super.setup()
    
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
    
    contentView.orientation = .vertical
    contentView.alignment = .leading
    contentView.translatesAutoresizingMaskIntoConstraints = false
    contentView.isHidden = true
    
    addSubview(contentView)
    
    NSLayoutConstraint.activate([
      contentView.topAnchor.constraint(equalTo: title.bottomAnchor, constant: gap),
      contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: gap),
      contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -gap),
    ])
    
    lastDisclosureConstraint = self.heightAnchor.constraint(equalToConstant: 25)
    
    NSLayoutConstraint.activate([
      lastDisclosureConstraint!,
    ])
    
    needsInit = false

  }
  
  internal func doDisclosure() {
    
    NSLayoutConstraint.deactivate([
      lastDisclosureConstraint!,
    ])

    let disclosed = disclosureButton.state == .on
    
    if disclosed {
      lastDisclosureConstraint = self.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: gap)
    }
    else {
      lastDisclosureConstraint = self.heightAnchor.constraint(equalToConstant: 25.0)
    }
    
    contentView.isHidden = !disclosed
    
    NSLayoutConstraint.activate([
      lastDisclosureConstraint!,
    ])

  }
  
  // MARK: Public Methods
  
  public func addArrangedSubview(_ view:NSView) {
  
    contentView.addArrangedSubview(view)
 
    NSLayoutConstraint.activate([
      view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: gap),
      view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -gap),
    ])

  }
  
  // MARK: Outlets & Actions
  
  @IBAction func btnDisclosureAction(_ sender: NSButton) {
    doDisclosure()
  }

}

