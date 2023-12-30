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
      comboView.leftAnchor.constraint(equalTo: stackView.leftAnchor),
      comboView.rightAnchor.constraint(equalTo: stackView.rightAnchor),
    ])

    addButtons(view:comboView)
    
    comboBox.translatesAutoresizingMaskIntoConstraints = false
    
    comboView.addSubview(comboBox)

    NSLayoutConstraint.activate([
      comboBox.topAnchor.constraint(equalTo: comboView.topAnchor),
      comboBox.leftAnchor.constraint(equalTo: comboView.leftAnchor, constant: gap),
      comboBox.rightAnchor.constraint(equalTo: refreshButton.leftAnchor, constant: -gap),
      comboView.heightAnchor.constraint(equalTo: comboBox.heightAnchor),
    ])
    
    map.populate(comboBox: comboBox)
    
  }
  
  // MARK: Public Properties
  
  public var map : LCCCDIMap? {
    didSet {
      addComboBox()
    }
  }

}
