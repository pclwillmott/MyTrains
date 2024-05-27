//
//  LayoutBuilderGeneralArea.swift
//  MyTrains
//
//  Created by Paul Willmott on 27/05/2024.
//

import Foundation
import AppKit

extension LayoutBuilderVC {
  
  // MARK: Internal Methods
  
  internal func setupGeneralAreaControls() {

    view.window?.title = String(localized: "Layout Builder", comment:"Used for the title of the Layout Builder window.")
    
    view.subviews.removeAll()
    
    switchboardView.delegate = self
    
    if let cboPanel, let splitView, let paletteView, let inspectorView, let layoutView {
      
      cboPanel.translatesAutoresizingMaskIntoConstraints = false
      cboPanel.isEditable = false
      
      view.addSubview(cboPanel)
      
      constraints.append(cboPanel.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 1.0))
      constraints.append(cboPanel.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1.0))
      constraints.append(view.trailingAnchor.constraint(equalToSystemSpacingAfter: cboPanel.trailingAnchor, multiplier: 1.0))
      
      splitView.translatesAutoresizingMaskIntoConstraints = false
      splitView.isVertical = true
      splitView.arrangesAllSubviews = true
      userSettings?.splitView = splitView
      
      view.addSubview(splitView)
      
      constraints.append(splitView.topAnchor.constraint(equalToSystemSpacingBelow: cboPanel.bottomAnchor, multiplier: 1.0))
      constraints.append(splitView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1.0))
      constraints.append(view.trailingAnchor.constraint(equalToSystemSpacingAfter: splitView.trailingAnchor, multiplier: 1.0))
      
      paletteView.translatesAutoresizingMaskIntoConstraints = false
      splitView.addArrangedSubview(paletteView)
      
      layoutView.translatesAutoresizingMaskIntoConstraints = false
      splitView.addArrangedSubview(layoutView)
      
      inspectorView.translatesAutoresizingMaskIntoConstraints = false
      splitView.addArrangedSubview(inspectorView)
      
    }
    
  }
  
  internal func releaseGeneralAreaControls() {
    
    view.subviews.removeAll()
    
    cboPanel?.target = nil
    cboPanel?.action = nil
    cboPanel?.removeAllItems()
    cboPanel = nil
    
    splitView?.removeSubViews()
    splitView = nil
    
    inspectorView?.removeSubViews()
    inspectorView = nil
    
    paletteView?.removeSubViews()
    paletteView = nil
    
    layoutView?.removeSubViews()
    layoutView = nil
    
  }
  
  // MARK: Actions
  
  @objc func cboPanelAction(_ sender: NSComboBox) {
    if sender.indexOfSelectedItem == -1 {
      switchboardPanel = nil
    }
    else {
      switchboardPanel = panels[sender.indexOfSelectedItem]
    }
    displayInspector()
  }

}
