//
//  CDIDataView2.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/12/2023.
//

import Foundation
import AppKit

class CDIDataView: CDIView {
  
  // MARK: Private & Internal Methods
  
  internal var box = NSBox()
  
  internal var stackView = NSStackView()
  
  internal var elementSize : Int?
  
  internal var needsRefreshWrite : Bool {
    guard let viewType = viewType() else {
      return false
    }
    let needs : Set<OpenLCBCDIViewType> = [.eventid, .float, .int, .string]
    return needs.contains(viewType)
  }

  internal var needsCopyPaste : Bool {
    guard let viewType = viewType() else {
      return false
    }
    let needs : Set<OpenLCBCDIViewType> = [.eventid]
    return needs.contains(viewType)
  }

  // MARK: Public Properties
  
  public var name : String {
    get {
      return box.title
    }
    set(value) {
      box.title = value
    }
  }
  
  // MARK: Private & Internal Methods
  
  internal func addButtons(view:NSView) {
    
    guard self.viewType() != nil else {
      return
    }
    
    dataButtonView.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(dataButtonView)

    var constraints : [NSLayoutConstraint] = []
    
    constraints.append(contentsOf: [
      dataButtonView.topAnchor.constraint(equalTo: view.topAnchor),
      dataButtonView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      dataButtonView.heightAnchor.constraint(equalToConstant: 20.0),
    ])
    
    var trailingAnchor = dataButtonView.trailingAnchor

    if needsCopyPaste {
      
      dataButtonView.addSubview(pasteButton)
      pasteButton.title = "Paste"
      pasteButton.translatesAutoresizingMaskIntoConstraints = false
      
      dataButtonView.addSubview(copyButton)
      copyButton.title = "Copy"
      copyButton.translatesAutoresizingMaskIntoConstraints = false
      
      constraints.append(contentsOf: [
        pasteButton.topAnchor.constraint(equalTo: dataButtonView.topAnchor),
        pasteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -gap),
        copyButton.topAnchor.constraint(equalTo: dataButtonView.topAnchor),
        copyButton.trailingAnchor.constraint(equalTo: pasteButton.leadingAnchor, constant: -gap),
      ])
      
      trailingAnchor = copyButton.leadingAnchor

    }

    if needsRefreshWrite {
      
      dataButtonView.addSubview(writeButton)
      writeButton.title = "Write"
      writeButton.translatesAutoresizingMaskIntoConstraints = false
      
      dataButtonView.addSubview(refreshButton)
      refreshButton.title = "Refresh"
      refreshButton.translatesAutoresizingMaskIntoConstraints = false
      
      constraints.append(contentsOf: [
        writeButton.topAnchor.constraint(equalTo: dataButtonView.topAnchor),
        writeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -gap),
        refreshButton.topAnchor.constraint(equalTo: dataButtonView.topAnchor),
        refreshButton.trailingAnchor.constraint(equalTo: writeButton.leadingAnchor, constant:  -gap),
        dataButtonView.leadingAnchor.constraint(equalTo: refreshButton.leadingAnchor)
      ])
      
    }

    NSLayoutConstraint.activate(constraints)
    
  }
  
  override internal func setup() {
    
    guard needsInit else {
      return
    }
    
    super.setup()
    
    addSubview(box)
    
    box.boxType = .primary
    box.fillColor = .windowBackgroundColor
    box.translatesAutoresizingMaskIntoConstraints = false
    box.cornerRadius = 5.0
    box.titlePosition = .atTop
    box.titleFont = NSFont(name: box.titleFont.familyName!, size: 13.0)!

    NSLayoutConstraint.activate([
      box.topAnchor.constraint(equalTo: self.topAnchor, constant: gap),
      box.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      box.trailingAnchor.constraint(equalTo: self.trailingAnchor),
    ])
    
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.orientation = .vertical
    stackView.alignment = .leading
    
    box.addSubview(stackView)

    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: box.topAnchor, constant: 23.0),
      stackView.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: gap),
      stackView.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -gap),
      box.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: gap),
      self.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: gap),
    ])

    needsInit = false

  }
  
  // MARK: Public Methods
  
  public func addDescription(description:String) {
    
    let field = NSTextField(labelWithString: description)
    
    field.translatesAutoresizingMaskIntoConstraints = false
    
    field.lineBreakMode = .byWordWrapping
    field.isEditable = false
    field.isBordered = false
    field.drawsBackground = false
    field.font = NSFont(name: field.font!.familyName!, size: 11.0)
    field.maximumNumberOfLines = 0
    field.stringValue = description
    field.preferredMaxLayoutWidth = 500.0

    stackView.addArrangedSubview(field)
    
    NSLayoutConstraint.activate([
      field.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: gap),
      field.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -gap),
    ])

  }
  
  // MARK: Controls
  
  internal var refreshButton = NSButton()
  
  internal var writeButton = NSButton()
  
  internal var copyButton = NSButton()
  
  internal var pasteButton = NSButton()
  
  internal var dataButtonView = NSView()
  
}

