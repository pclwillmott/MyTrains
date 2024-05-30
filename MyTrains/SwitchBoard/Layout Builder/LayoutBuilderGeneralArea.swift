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
    
    if let cboPanel, let splitView, let paletteView, let inspectorView, let layoutView, let btnNewPanel, let btnDeletePanel {
      
      cboPanel.translatesAutoresizingMaskIntoConstraints = false
      cboPanel.isEditable = false
      cboPanel.setContentHuggingPriority(NSLayoutConstraint.Priority(rawValue: 1), for: .horizontal)

      view.addSubview(cboPanel)
      
      constraints.append(cboPanel.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 1.0))
      constraints.append(cboPanel.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1.0))
      
      btnNewPanel.translatesAutoresizingMaskIntoConstraints = false
      btnNewPanel.title = String(localized: "New Panel")
      btnNewPanel.setContentHuggingPriority(NSLayoutConstraint.Priority(rawValue: 900), for: .horizontal)
      btnNewPanel.target = self
      btnNewPanel.action = #selector(self.btnNewPanelAction(_:))

      view.addSubview(btnNewPanel)
      
      constraints.append(btnNewPanel.leadingAnchor.constraint(equalToSystemSpacingAfter: cboPanel.trailingAnchor, multiplier: 1.0))
      constraints.append(btnNewPanel.centerYAnchor.constraint(equalTo: cboPanel.centerYAnchor))

      btnDeletePanel.translatesAutoresizingMaskIntoConstraints = false
      btnDeletePanel.title = String(localized: "Delete Panel")
      btnDeletePanel.setContentHuggingPriority(NSLayoutConstraint.Priority(rawValue: 900), for: .horizontal)
      btnDeletePanel.target = self
      btnDeletePanel.action = #selector(self.btnDeletePanelAction(_:))

      view.addSubview(btnDeletePanel)

      constraints.append(btnDeletePanel.leadingAnchor.constraint(equalToSystemSpacingAfter: btnNewPanel.trailingAnchor, multiplier: 1.0))
      constraints.append(btnDeletePanel.centerYAnchor.constraint(equalTo: cboPanel.centerYAnchor))

      constraints.append(view.trailingAnchor.constraint(equalToSystemSpacingAfter: btnDeletePanel.trailingAnchor, multiplier: 1.0))
      
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
    
    cboPanel?.target = nil
    cboPanel?.action = nil
    cboPanel?.removeAllItems()
    cboPanel = nil
    
    splitView?.removeArrangedSubview(paletteView!)
    splitView?.removeArrangedSubview(layoutView!)
    splitView?.removeArrangedSubview(inspectorView!)
    splitView = nil
    
    for view in inspectorView!.subviews {
      if let scrollView = view as? NSScrollView {
        scrollView.documentView?.removeSubViews()
        scrollView.documentView = nil
      }
    }
    inspectorView?.subviews.removeAll(keepingCapacity: false)
    inspectorView = nil
    
    paletteView?.removeSubViews()
    paletteView = nil
    
//    layoutView?.removeSubViews()
    layoutView = nil

    view.subviews.removeAll()
        
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
  
  @objc func btnNewPanelAction(_ sender: NSButton) {
    
    if let appNode, let panel = appNode.createPanel() {
      cboPanel?.selectItem(withObjectValue: panel.userNodeName)
    }
    
  }
  
  @objc func btnDeletePanelAction(_ sender: NSButton) {
    
    guard let switchboardPanel else {
      return
    }
    
    appNode?.deletePanel(panel: switchboardPanel)
    
  }

}
