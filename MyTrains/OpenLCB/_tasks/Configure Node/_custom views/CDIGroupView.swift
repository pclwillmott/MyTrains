//
//  CDIGroupView.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/12/2023.
//

import Foundation
import AppKit

class CDIGroupView: CDIView, CDIStackViewManagerDelegate {
 
  // MARK: Destructors
 
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    addInit()
  }
  
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    addInit()
  }

  deinit {
    for view in contentView!.arrangedSubviews {
      contentView?.removeArrangedSubview(view)
    }
    contentView = nil
    disclosureButton?.target = nil
    disclosureButton = nil
    title = nil
    lastDisclosureConstraint = nil
    subviews.removeAll()
    addDeinit()
  }
  
  // MARK: Private & Internal Methods
  
  internal var contentView : NSStackView? = NSStackView()
  
  internal var disclosureButton : NSButton? = NSButton()
  
  internal var title : NSTextField? = NSTextField()
  
  internal var lastDisclosureConstraint : NSLayoutConstraint?

  // MARK: Public Properties
  
  public var name : String {
    get {
      return title!.stringValue
    }
    set(value) {
      title?.stringValue = value
    }
  }
  
  // MARK: Private & Internal Methods
  
  override internal func setup() {
    
    guard needsInit, let disclosureButton, let title, let contentView else {
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
      disclosureButton.topAnchor.constraint(equalTo: self.topAnchor, constant: parentGap),
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
      title.topAnchor.constraint(equalTo: self.topAnchor, constant: parentGap),
      title.leadingAnchor.constraint(equalTo: disclosureButton.trailingAnchor, constant: siblingGap),
      title.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: parentGap),
    ])
    
    contentView.orientation = .vertical
    contentView.alignment = .leading
    contentView.translatesAutoresizingMaskIntoConstraints = false
    contentView.isHidden = true
    
    addSubview(contentView)
    
    NSLayoutConstraint.activate([
      contentView.topAnchor.constraint(equalTo: title.bottomAnchor, constant: siblingGap),
      contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: parentGap),
      contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -parentGap),
    ])
    
    lastDisclosureConstraint = self.bottomAnchor.constraint(equalToSystemSpacingBelow: title.bottomAnchor, multiplier: 1.0)

    NSLayoutConstraint.activate([
      lastDisclosureConstraint!,
    ])
    
    needsInit = false

  }
  
  internal func doDisclosure() {
    
    guard let disclosureButton, let contentView, let title else {
      return
    }
    
    NSLayoutConstraint.deactivate([
      lastDisclosureConstraint!,
    ])

    let disclosed = disclosureButton.state == .on
    
    if disclosed {
      lastDisclosureConstraint = self.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: parentGap)
    }
    else {
      lastDisclosureConstraint = self.bottomAnchor.constraint(equalToSystemSpacingBelow: title.bottomAnchor, multiplier: 1.0)
    }
    
    contentView.isHidden = !disclosed
    
    NSLayoutConstraint.activate([
      lastDisclosureConstraint!,
    ])

  }
  
  // MARK: Public Methods
  
  public func addArrangedSubview(_ view:NSView) {
  
    guard let contentView else {
      return
    }
    
    contentView.addArrangedSubview(view)
 
    NSLayoutConstraint.activate([
      view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
    ])

  }
  
  public func addDescription(description:[String]) {
    
    for desc in description {
      
      if !desc.trimmingCharacters(in: .whitespaces).isEmpty {
        
        let field = NSTextField(labelWithString: desc)
        
        field.translatesAutoresizingMaskIntoConstraints = false
        
        field.lineBreakMode = .byWordWrapping
        field.isEditable = false
        field.isBordered = false
        field.drawsBackground = false
        field.font = NSFont(name: field.font!.familyName!, size: 11.0)
        field.maximumNumberOfLines = 0
        field.preferredMaxLayoutWidth = 500.0
        
        addArrangedSubview(field)
        
      }
    }
  }

  // MARK: Outlets & Actions
  
  @IBAction func btnDisclosureAction(_ sender: NSButton) {
    doDisclosure()
  }

}

