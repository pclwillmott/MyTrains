//
//  CDIMapView.swift
//  MyTrains
//
//  Created by Paul Willmott on 30/12/2023.
//

import Foundation
import AppKit

class CDIMapView : CDIDataView {

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
    comboView?.subviews.removeAll()
    comboView = nil
    comboBox?.target = nil
    comboBox = nil
    subviews.removeAll()
    addDeinit()
  }
  
  // MARK: Private & Internal Properties

  internal var comboView : NSView? = NSView()
  
  internal var comboBox : NSComboBox? = NSComboBox()
  
  // MARK: Private & Internal Methods
  
  override internal func dataWasSet() {
    
    guard let comboBox, let string = setString() else {
      return
    }
    
    if let map {
      map.selectItem(comboBox: comboBox, property: string)
    }

  }

  internal func addComboBox() {
    
    guard let map, let stackView, let dataButtonView, let comboView, let comboBox else {
      return
    }
    
    comboView.translatesAutoresizingMaskIntoConstraints = false
    
    stackView.addArrangedSubview(comboView)

    NSLayoutConstraint.activate([
      comboView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
      comboView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
    ])

    addButtons(view:comboView)
    
    comboBox.translatesAutoresizingMaskIntoConstraints = false
    
    comboBox.isEditable = false
    
    comboView.addSubview(comboBox)

    NSLayoutConstraint.activate([
      comboBox.topAnchor.constraint(equalTo: comboView.topAnchor),
      comboBox.leadingAnchor.constraint(equalTo: comboView.leadingAnchor),
      comboBox.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
      comboView.heightAnchor.constraint(equalTo: comboBox.heightAnchor),
      comboBox.trailingAnchor.constraint(lessThanOrEqualTo: dataButtonView.leadingAnchor, constant: -8.0),
    ])
    
    map.populate(comboBox: comboBox)
    
  }

  // MARK: Public Properties
  
  public var map : CDIMap? {
    didSet {
      addComboBox()
    }
  }

  override public var getData : [UInt8] {

    guard let map, let comboBox, let textValue = map.selectedItem(comboBox: comboBox), let data = getData(string: textValue) else {
      return []
    }

    return data
    
  }

}
