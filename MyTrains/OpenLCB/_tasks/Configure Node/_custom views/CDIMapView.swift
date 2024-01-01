//
//  CDIMapView.swift
//  MyTrains
//
//  Created by Paul Willmott on 30/12/2023.
//

import Foundation
import AppKit

class CDIMapView : CDIDataView {

  // MARK: Private & Internal Properties

  internal var comboView = NSView()
  
  internal var comboBox = NSComboBox()
  
  // MARK: Private & Internal Methods
  
  internal func addComboBox() {
    
    guard let map else {
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
      comboBox.leadingAnchor.constraint(equalTo: comboView.leadingAnchor, constant: gap),
      comboBox.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
      comboView.heightAnchor.constraint(equalTo: comboBox.heightAnchor),
    ])
    
    map.populate(comboBox: comboBox)
    
  }

  override internal func viewType() -> OpenLCBCDIViewType? {
    return .string
  }

  // MARK: Public Properties
  
  public var map : LCCCDIMap? {
    didSet {
      addComboBox()
    }
  }

}
