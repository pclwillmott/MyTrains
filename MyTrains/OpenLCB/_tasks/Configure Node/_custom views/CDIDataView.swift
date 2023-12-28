//
//  CDIDataView.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/12/2023.
//

import Foundation
import AppKit

class CDIDataView: CDIView {
  
  // MARK: Drawing Stuff
  
  override func draw(_ dirtyRect: NSRect) {
    setup()
  }
  
  // MARK: Private & Internal Methods
  
  internal let gap : CGFloat = 5.0
  
  internal var nextGap : CGFloat = 20.0
  
  internal var nextTop : NSLayoutYAxisAnchor?
  
  internal var refreshButton = NSButton()
  
  internal var writeButton = NSButton()
  
  internal var needsInit = true
  
  internal var elementSize : Int?
  
  internal var needsRefreshWrite : Bool {
    guard let viewType = viewType() else {
      return false
    }
    let needs : Set<OpenLCBCDIViewType> = [.eventid, .float, .int, .string]
    return needs.contains(viewType)
  }

  internal var box = NSBox()
  
  var boxBottomAnchorConstraint : NSLayoutConstraint?

  var viewBottomAnchorConstraint : NSLayoutConstraint?

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
        writeButton.topAnchor.constraint(equalTo: nextTop!, constant: gap),
        writeButton.rightAnchor.constraint(equalTo: box.rightAnchor, constant: -gap),
      ])

      box.addSubview(refreshButton)
      
      refreshButton.title = "Refresh"
      refreshButton.translatesAutoresizingMaskIntoConstraints = false
      
      NSLayoutConstraint.activate([
        refreshButton.topAnchor.constraint(equalTo: nextTop!, constant: gap),
        refreshButton.rightAnchor.constraint(equalTo: writeButton.leftAnchor, constant:  -gap),
        writeButton.widthAnchor.constraint(equalTo: refreshButton.widthAnchor),
      ])

    }
    
  }
  
  internal func setup() {
    
    guard needsInit else {
      return
    }
    
    addSubview(box)
    
    box.boxType = .primary
    box.fillColor = .windowBackgroundColor
    box.translatesAutoresizingMaskIntoConstraints = false
    box.cornerRadius = 5.0
    box.titlePosition = .atTop
    box.titleFont = NSFont(name: box.titleFont.familyName!, size: 16.0)!

    NSLayoutConstraint.activate([
      box.topAnchor.constraint(equalTo: self.topAnchor, constant: gap),
      box.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      box.trailingAnchor.constraint(equalTo: self.trailingAnchor),
    ])
        
    nextTop = box.topAnchor
    
    needsInit = false

  }
  
  internal func setBottomToLastItem(lastItem:NSLayoutYAxisAnchor) {

    // Remove any existing constants on the view and box bottoms
    
    if let viewBottomAnchorConstraint {
      NSLayoutConstraint.deactivate([
        viewBottomAnchorConstraint
      ])
    }
    
    // Remove any existing constants on the view and box bottoms
    
    if let boxBottomAnchorConstraint {
      NSLayoutConstraint.deactivate([
        boxBottomAnchorConstraint
      ])
    }
    
    // Calculate and store new box bottom constraint
    
    boxBottomAnchorConstraint = box.bottomAnchor.constraint(greaterThanOrEqualTo: lastItem, constant: gap)

    if let boxBottomAnchorConstraint {
      NSLayoutConstraint.activate([
        boxBottomAnchorConstraint
      ])
    }

    
//    viewBottomAnchorConstraint = self.heightAnchor.constraint(equalTo: box.heightAnchor, constant: gap)
    
    viewBottomAnchorConstraint = self.heightAnchor.constraint(equalToConstant: box.fittingSize.height)

    
    if let viewBottomAnchorConstraint {
      NSLayoutConstraint.activate([
        viewBottomAnchorConstraint
      ])
    }

    self.updateConstraints()

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

    box.addSubview(field)
    
    NSLayoutConstraint.activate([
      
      field.topAnchor.constraint(equalTo: nextTop == nil ? box.topAnchor : nextTop!, constant: nextGap),
      field.leftAnchor.constraint(equalTo: box.leftAnchor, constant: gap),
      field.rightAnchor.constraint(equalTo: box.rightAnchor, constant: -gap),
      
    ])


    nextTop = field.bottomAnchor
    
    nextGap = gap
    
    setBottomToLastItem(lastItem: nextTop!)

  }
  
}

