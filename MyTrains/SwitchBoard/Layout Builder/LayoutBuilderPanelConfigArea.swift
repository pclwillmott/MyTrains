//
//  LayoutBuilderPanelConfigArea.swift
//  MyTrains
//
//  Created by Paul Willmott on 27/05/2024.
//

import Foundation
import AppKit

extension LayoutBuilderVC {
  
  // MARK: Internal Methods
  
  internal func setupPanelConfigArea() {
    
    panelControls = [
      (
        NSTextField(labelWithString: String(localized: "Layout ID")),
        NSTextField(labelWithString: ""),
        .layoutId
      ),
      (
        NSTextField(labelWithString: String(localized: "Layout Name")),
        NSTextField(labelWithString: ""),
        .layoutName
      ),
      (
        NSTextField(labelWithString: String(localized: "Panel ID")),
        NSTextField(labelWithString: ""),
        .panelId
      ),
      (
        NSTextField(labelWithString: String(localized: "Panel Name")),
        NSTextField(),
        .panelName
      ),
      (
        NSTextField(labelWithString: String(localized: "Panel Description")),
        NSTextField(),
        .panelDescription
      ),
      (
        NSTextField(labelWithString: String(localized: "Number of Rows")),
        NSTextField(),
        .numberOfRows
      ),
      (
        NSTextField(labelWithString: String(localized: "Number of Columns")),
        NSTextField(),
        .numberOfColumns
      ),
    ]
    
    if let panelStripView, let panelView, let splitView, let cboPanel, let panelStack, let layoutView {
      
      panelView.translatesAutoresizingMaskIntoConstraints = false
      
      view.addSubview(panelView)
      
      constraints.append(panelView.topAnchor.constraint(equalToSystemSpacingBelow: splitView.bottomAnchor, multiplier: 1.0))
      constraints.append(panelView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1.0))
      constraints.append(panelView.trailingAnchor.constraint(equalTo: btnDeletePanel!.trailingAnchor))
      constraints.append(view.bottomAnchor.constraint(equalToSystemSpacingBelow: panelView.bottomAnchor, multiplier: 1.0))
      
      panelStripView.translatesAutoresizingMaskIntoConstraints = false
      
      panelView.addSubview(panelStripView)
      
      panelStack.translatesAutoresizingMaskIntoConstraints = false
      panelStack.orientation = .vertical
      panelStack.spacing = 4

      panelView.addSubview(panelStack)
      
      constraints.append(panelStack.topAnchor.constraint(equalToSystemSpacingBelow: panelStripView.bottomAnchor, multiplier: 1.0))
      constraints.append(panelStack.leadingAnchor.constraint(equalTo: panelView.leadingAnchor))
      constraints.append(panelView.trailingAnchor.constraint(equalTo: panelStack.trailingAnchor))
      
      let labelFontSize : CGFloat = 10.0
      let textFontSize  : CGFloat = 11.0
      
      let longFields : Set<PanelProperty> = [
        .layoutName,
        .panelName,
        .panelDescription,
      ]
      
      for field in panelControls {
        
        let fieldView = NSView()
        
        fieldView.translatesAutoresizingMaskIntoConstraints = false
        
        panelStack.addArrangedSubview(fieldView)
        
        constraints.append(fieldView.leadingAnchor.constraint(equalTo: panelStack.leadingAnchor))
        constraints.append(fieldView.trailingAnchor.constraint(equalTo: panelStack.trailingAnchor))
        
        if let label = field.label, let control = field.control as? NSTextField {
          
          label.translatesAutoresizingMaskIntoConstraints = false
          label.fontSize = labelFontSize
          label.alignment = .right
          
          fieldView.addSubview(label)
          
          control.translatesAutoresizingMaskIntoConstraints = false
          control.fontSize = textFontSize
          control.tag = field.property.rawValue
          control.delegate = self

          fieldView.addSubview(control)
          
          constraints.append(label.centerYAnchor.constraint(equalTo: control.centerYAnchor))
          constraints.append(control.topAnchor.constraint(equalTo: fieldView.topAnchor))
          constraints.append(label.leadingAnchor.constraint(equalTo: fieldView.leadingAnchor))
          constraints.append(control.leadingAnchor.constraint(equalToSystemSpacingAfter: label.trailingAnchor, multiplier: 1.0))
          constraints.append(fieldView.trailingAnchor.constraint(equalTo: panelStack.trailingAnchor))
          constraints.append(fieldView.heightAnchor.constraint(equalTo: control.heightAnchor))
          
          if longFields.contains(field.property) {
            constraints.append(fieldView.trailingAnchor.constraint(equalTo: control.trailingAnchor))
          }
          
        }
        
      }
      
      constraints.append(panelControls[0].control!.widthAnchor.constraint(equalToConstant: 100))
      constraints.append(panelControls[2].control!.widthAnchor.constraint(equalToConstant: 100))
      constraints.append(panelControls[5].control!.widthAnchor.constraint(equalToConstant: 50))
      constraints.append(panelControls[6].control!.widthAnchor.constraint(equalToConstant: 50))
      
      for field in panelControls {
        for other in panelControls {
          if !(field.control === other.control) {
            constraints.append(field.label!.widthAnchor.constraint(greaterThanOrEqualTo: other.label!.widthAnchor))
          }
        }
      }
      
      panelStripView.backgroundColor = NSColor.white.cgColor

      constraints.append(panelStripView.topAnchor.constraint(equalTo: panelView.topAnchor))
      constraints.append(panelStripView.leadingAnchor.constraint(equalTo: layoutView.leadingAnchor))
      constraints.append(panelStripView.trailingAnchor.constraint(equalTo: layoutView.trailingAnchor))
      constraints.append(panelStripView.heightAnchor.constraint(equalToConstant: 20.0))
 
      btnShowInspectorView = MyIcon.trailingThird.button(target: self, action: #selector(btnShowInspectorViewAction(_:)))

      btnShowPaletteView = MyIcon.leadingThird.button(target: self, action: #selector(btnShowPaletteViewAction(_:)))
      
      btnShowPanelView = MyIcon.bottomThird.button(target: self, action: #selector(btnShowPanelViewAction(_:)))
      
      if let btnShowPanelView, let btnShowPaletteView, let btnShowInspectorView {
        
        btnShowPanelView.translatesAutoresizingMaskIntoConstraints = false
        btnShowPanelView.isBordered = false
        btnShowPanelView.contentTintColor = NSColor.systemBlue
        btnShowPanelView.toolTip = String(localized: "Hide the Panel Configuration Area")
        
        panelStripView.addSubview(btnShowPanelView)
        
        constraints.append(btnShowPanelView.centerYAnchor.constraint(equalTo: panelStripView.centerYAnchor))
        constraints.append(btnShowPanelView.centerXAnchor.constraint(equalTo: panelStripView.centerXAnchor))
        
        btnShowInspectorView.translatesAutoresizingMaskIntoConstraints = false
        btnShowInspectorView.isBordered = false
        btnShowInspectorView.contentTintColor = NSColor.systemBlue
        btnShowInspectorView.toolTip = String(localized: "Hide the Inspector Area")
        
        panelStripView.addSubview(btnShowInspectorView)
        
        constraints.append(btnShowInspectorView.centerYAnchor.constraint(equalTo: panelStripView.centerYAnchor))
        constraints.append(panelStripView.trailingAnchor.constraint(equalToSystemSpacingAfter: btnShowInspectorView.trailingAnchor, multiplier: 1.0))
        
        btnShowPaletteView.translatesAutoresizingMaskIntoConstraints = false
        btnShowPaletteView.isBordered = false
        btnShowPaletteView.contentTintColor = NSColor.systemBlue
        btnShowPaletteView.toolTip = String(localized: "Hide the Palette/Grouping Area")
        
        panelStripView.addSubview(btnShowPaletteView)
        
        constraints.append(btnShowPaletteView.centerYAnchor.constraint(equalTo: panelStripView.centerYAnchor))
        constraints.append(btnShowPaletteView.leadingAnchor.constraint(equalToSystemSpacingAfter: panelStripView.leadingAnchor, multiplier: 1.0))
        
      }
      
    }
    
  }
  
  internal func releasePanelConfigAreaControls() {
    
    panelStack?.removeSubViews()
    panelStack = nil
    
    panelStripView?.removeSubViews()
    panelStripView = nil
    
    panelControls.removeAll()
    
    btnShowInspectorView?.target = nil
    btnShowInspectorView?.action = nil
    btnShowInspectorView = nil
    
    btnShowPaletteView?.target = nil
    btnShowPaletteView?.action = nil
    btnShowPaletteView = nil
    
    btnShowPanelView?.target = nil
    btnShowPanelView?.action = nil
    btnShowPanelView = nil
    
  }
  
  // MARK: Actions
  
  @objc func btnShowPanelViewAction(_ sender: NSButton) {
    showPanelConstraint?.isActive = false
    if sender.state == .on {
      showPanelConstraint = panelView?.bottomAnchor.constraint(equalTo: panelStripView!.bottomAnchor)
      btnShowPanelView?.contentTintColor = nil
      btnShowPanelView?.toolTip = String(localized: "Show the Panel Configuration Area")
      panelStack?.isHidden = true
    }
    else {
      showPanelConstraint = panelView?.bottomAnchor.constraint(equalTo: panelStack!.bottomAnchor)
      btnShowPanelView?.contentTintColor = NSColor.systemBlue
      btnShowPanelView?.toolTip = String(localized: "Hide the Panel Configuration Area")
      panelStack?.isHidden = false
    }
    showPanelConstraint?.isActive = true
    userSettings?.set(btnShowPanelView!.state, forKey: DEFAULT.SHOW_PANEL_VIEW)
  }

  @objc func btnShowInspectorViewAction(_ sender: NSButton) {
    if sender.state == .on {
      splitView?.removeArrangedSubview(inspectorView!)
      btnShowInspectorView?.contentTintColor = nil
      btnShowInspectorView?.toolTip = String(localized: "Show the Inspector Area")
    }
    else {
      splitView?.addSubview(inspectorView!, positioned: .above, relativeTo: layoutView!)
      btnShowInspectorView?.contentTintColor = NSColor.systemBlue
      btnShowInspectorView?.toolTip = String(localized: "Hide the Inspector Area")
    }
    userSettings?.set(btnShowInspectorView!.state, forKey: DEFAULT.SHOW_INSPECTOR_VIEW)
  }
  
  @objc func btnShowPaletteViewAction(_ sender: NSButton) {
    if sender.state == .on {
      splitView?.removeArrangedSubview(paletteView!)
      btnShowPaletteView?.contentTintColor = nil
      btnShowPaletteView?.toolTip = String(localized: "Show the Palette Area")
    }
    else {
      splitView?.addSubview(paletteView!, positioned: .below, relativeTo: layoutView!)
      btnShowPaletteView?.contentTintColor = NSColor.systemBlue
      btnShowPaletteView?.toolTip = String(localized: "Hide the Palette Area")
    }
    userSettings?.set(btnShowPaletteView!.state, forKey: DEFAULT.SHOW_PALETTE_VIEW)
  }

}
