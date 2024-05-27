//
//  LayoutBuilderInspectorArea.swift
//  MyTrains
//
//  Created by Paul Willmott on 27/05/2024.
//

import Foundation
import AppKit

extension LayoutBuilderVC {
  
  // MARK: Internal Methods
  
  internal func setupInspectorArea() {
    
    inspectorFields = LayoutInspectorProperty.inspectorPropertyFields
    
    for temp in inspectorFields {
      if let comboBox = temp.control as? MyComboBox {
        comboBox.target = self
        comboBox.action = #selector(self.cboAction(_:))
      }
      else if let chkBox = temp.control as? NSButton {
        chkBox.target = self
        chkBox.action = #selector(self.chkAction(_:))
      }
      else if let field = temp.control as? NSTextField {
        field.delegate = self
      }
    }
    
    inspectorGroupFields = LayoutInspectorGroup.inspectorGroupFields
    
    inspectorGroupSeparators = LayoutInspectorGroup.inspectorGroupSeparators
    
    if let splitView, let inspectorView, let inspectorStripView {
      
      constraints.append(inspectorView.trailingAnchor.constraint(equalTo: splitView.trailingAnchor))
      
      inspectorStripView.translatesAutoresizingMaskIntoConstraints = false
      
      inspectorView.addSubview(inspectorStripView)
      
      constraints.append(inspectorStripView.topAnchor.constraint(equalTo: inspectorView.topAnchor))
      constraints.append(inspectorStripView.centerXAnchor.constraint(equalTo: inspectorView.centerXAnchor))
      constraints.append(inspectorStripView.heightAnchor.constraint(equalToConstant: 20.0))
      
      var lastButton : NSButton? = nil

      for inspector in LayoutInspector.allCases {
        
        if let button = inspector.icon.button(target: self, action: #selector(btnInspectorAction(_:))) {
          
          inspectorButtons.append(button)
          button.translatesAutoresizingMaskIntoConstraints = false
          button.toolTip = inspector.tooltip
          button.isBordered = false
          button.tag = inspector.rawValue
          
          inspectorStripView.addSubview(button)
          
          constraints.append(button.centerYAnchor.constraint(equalTo: inspectorStripView.centerYAnchor))

          if let lastButton {
            constraints.append(button.leadingAnchor.constraint(equalToSystemSpacingAfter: lastButton.trailingAnchor, multiplier: 1.0))
          }
          else {
            constraints.append(button.leadingAnchor.constraint(equalToSystemSpacingAfter: inspectorStripView.leadingAnchor, multiplier: 1.0))
          }
          
          lastButton = button
          
          let scrollView = NSScrollView()
          
          scrollView.translatesAutoresizingMaskIntoConstraints = false
          scrollView.drawsBackground = false
          scrollView.contentView = FlippedNSClipView()
          scrollView.contentView.drawsBackground = false
          scrollView.hasVerticalScroller = true
          scrollView.autohidesScrollers = true
          
          inspectorViews.append(scrollView)
          
          let noSelection = NSTextField(labelWithString: String(localized: "No Selection"))
          noSelection.textColor = NSColor.gray
          noSelection.fontSize = 16.0
          
          inspectorNoSelection.append(noSelection)
          
          let notApplicable = NSTextField(labelWithString: String(localized: "Not Applicable"))
          
          notApplicable.textColor = NSColor.gray
          notApplicable.fontSize = 16.0
          inspectorNotApplicable.append(notApplicable)
          
          inspectorView.addSubview(scrollView)
          
          let view = NSStackView()
          view.translatesAutoresizingMaskIntoConstraints = false
          view.backgroundColor = nil
          
          scrollView.documentView = view
          
          constraints.append(scrollView.topAnchor.constraint(equalToSystemSpacingBelow: inspectorStripView.bottomAnchor, multiplier: 1.0))
          constraints.append(scrollView.trailingAnchor.constraint(equalTo: inspectorView.trailingAnchor))
          constraints.append(scrollView.leadingAnchor.constraint(equalTo: inspectorView.leadingAnchor))
          constraints.append(scrollView.bottomAnchor.constraint(equalTo: inspectorView.bottomAnchor))
          constraints.append(view.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: 0))
          
        }
        
      }
      
      constraints.append(inspectorStripView.trailingAnchor.constraint(equalToSystemSpacingAfter: lastButton!.trailingAnchor, multiplier: 1.0))
      constraints.append(inspectorView.widthAnchor.constraint(greaterThanOrEqualTo: inspectorStripView.widthAnchor, multiplier: 1.0))

      inspectorButtons[currentInspectorIndex]?.contentTintColor = NSColor.systemBlue
      
    }
    
  }
  
  internal func releaseInspectorAreaControls() {
    
    inspectorStripView?.removeSubViews()
    inspectorStripView = nil
    
    for index in 0 ... inspectorNoSelection.count - 1 {
      inspectorNoSelection[index] = nil
    }
    inspectorNoSelection.removeAll()
    
    for index in 0 ... inspectorNotApplicable.count - 1 {
      inspectorNotApplicable[index] = nil
    }
    inspectorNotApplicable.removeAll()
    
    for index in 0 ... inspectorButtons.count - 1 {
      if let button = inspectorButtons[index] {
        button.image = nil
        button.target = nil
        button.action = nil
      }
      inspectorButtons[index] = nil
    }
    inspectorButtons.removeAll()
    
    // TODO: inspectorViews

    inspectorFields.removeAll()
    inspectorGroupFields.removeAll()
    inspectorGroupSeparators.removeAll()
    
  }
  
  // MARK: Actions
  
  @objc func btnInspectorAction(_ sender: NSButton) {
    
    currentInspectorIndex = sender.tag
    
    userSettings?.set(currentInspectorIndex, forKey: DEFAULT.CURRENT_INSPECTOR)
    
    for button in inspectorButtons {
      if let button, let view = inspectorViews[button.tag] {
        button.contentTintColor = nil
        view.isHidden = true
      }
    }
    
    if let button = inspectorButtons[currentInspectorIndex], let view = inspectorViews[button.tag] {
      button.contentTintColor = NSColor.systemBlue
      view.isHidden = false
    }
    
  }


  
}
