//
//  CDIDataView.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/12/2023.
//

import Foundation
import AppKit

class CDIDataView: CDIView {
  
  // MARK: Private & Internal Methods
  
  internal let gap : CGFloat = 5.0
  
  internal var nextYGap : CGFloat = 20.0
  
  internal var lastAnchor : NSLayoutYAxisAnchor?
  
  internal var refreshButton = NSButton()
  
  internal var writeButton = NSButton()
  
  internal var elementSize : Int?
  
  internal var needsRefreshWrite : Bool {
    guard let viewType = viewType() else {
      return false
    }
    let needs : Set<OpenLCBCDIViewType> = [.eventid, .float, .int, .string]
    return needs.contains(viewType)
  }

  internal var _box : NSBox?
  
  internal var box : NSBox {
    
    if _box == nil {
      
      let field = NSBox()
      
      addSubview(field)
      
      field.boxType = .primary
      
      field.fillColor = .windowBackgroundColor
      
      field.translatesAutoresizingMaskIntoConstraints = false
      
      field.cornerRadius = 5.0
      
      field.titlePosition = .atTop
      
      NSLayoutConstraint.activate([
        field.topAnchor.constraint(equalTo: self.topAnchor, constant: gap),
        field.leftAnchor.constraint(equalTo: self.leftAnchor, constant: gap),
        field.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -gap),
      ])

      lastAnchor = field.topAnchor
      
      _box = field

    }
    
    return _box!
    
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
  
  internal func addButtons() {
    
    guard let viewType = self.viewType() else {
      return
    }
    
    if needsRefreshWrite {
      
      box.addSubview(writeButton)
      writeButton.title = "Write"
      writeButton.translatesAutoresizingMaskIntoConstraints = false
      
      NSLayoutConstraint.activate([
        writeButton.topAnchor.constraint(equalTo: lastAnchor!, constant: nextYGap),
        writeButton.rightAnchor.constraint(equalTo: box.rightAnchor, constant: -gap),
      ])

      box.addSubview(refreshButton)
      refreshButton.title = "Refresh"
      refreshButton.translatesAutoresizingMaskIntoConstraints = false
      
      NSLayoutConstraint.activate([
        refreshButton.topAnchor.constraint(equalTo: lastAnchor!, constant: nextYGap),
        refreshButton.rightAnchor.constraint(equalTo: writeButton.leftAnchor, constant: -gap),
        writeButton.widthAnchor.constraint(equalTo: refreshButton.widthAnchor)
      ])

    }

  }
  
  // MARK: Public Methods
  
  public func addDescription(description:String) {
    
    let field = NSTextField()
    
    box.addSubview(field)
    
    field.lineBreakMode = .byWordWrapping
    field.stringValue = description
    field.isEditable = false
    field.isBordered = false
    field.backgroundColor = .clear
    
    field.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      field.topAnchor.constraint(equalTo: lastAnchor!, constant: nextYGap),
      field.leftAnchor.constraint(equalTo: box.leftAnchor, constant: gap),
      field.rightAnchor.constraint(equalTo: box.rightAnchor, constant: -gap),
    ])
    
    nextYGap = gap
    
    lastAnchor = field.bottomAnchor

  }
  
}

