//
//  LayoutBuilderPaletteGroupingArea.swift
//  MyTrains
//
//  Created by Paul Willmott on 27/05/2024.
//

import Foundation
import AppKit

extension LayoutBuilderVC {
  
  // MARK: Internal Properties
  
  internal var isGroupMode : Bool {
    get {
      return userSettings!.bool(forKey: DEFAULT.IS_GROUP_MODE)
    }
    set(value) {
      userSettings?.set(value, forKey: DEFAULT.IS_GROUP_MODE)
      arrangeView?.isHidden = value
      groupView?.isHidden = !value
      switchboardView.mode = value ? .group : .arrange
    }
  }
  
  internal var currentPalette : SwitchboardItemPalette {
    get {
      guard let palette = SwitchboardItemPalette(rawValue: userSettings!.integer(forKey: DEFAULT.CURRENT_PALETTE)) else {
        return SwitchboardItemPalette.defaultValue
      }
      return palette
    }
    set(value) {
      for (_, view) in paletteViews {
        view.isHidden = true
      }
      userSettings?.set(value.rawValue, forKey: DEFAULT.CURRENT_PALETTE)
      paletteViews[value]?.isHidden = false
    }
  }
  
  // MARK: Internal Methods
  
  internal func setupPaletteGroupingArea() {
        
    if let arrangeView, let arrangeStripView, let paletteView, let cboPalette, let layout = appNode?.layout, let groupView, let groupStripView {
      
      arrangeView.translatesAutoresizingMaskIntoConstraints = false
      
      paletteView.addSubview(arrangeView)
      
      constraints.append(arrangeView.topAnchor.constraint(equalTo: paletteView.topAnchor))
      constraints.append(arrangeView.centerXAnchor.constraint(equalTo: paletteView.centerXAnchor))
      constraints.append(arrangeView.leadingAnchor.constraint(equalTo: paletteView.leadingAnchor))
      constraints.append(paletteView.trailingAnchor.constraint(greaterThanOrEqualTo: arrangeView.trailingAnchor))
      constraints.append(paletteView.bottomAnchor.constraint(greaterThanOrEqualTo: arrangeView.bottomAnchor))
      constraints.append(paletteView.widthAnchor.constraint(greaterThanOrEqualTo: arrangeView.widthAnchor))
      
      arrangeStripView.translatesAutoresizingMaskIntoConstraints = false
      
      arrangeView.addSubview(arrangeStripView)
      
      constraints.append(arrangeStripView.topAnchor.constraint(equalTo: arrangeView.topAnchor))
      constraints.append(arrangeStripView.centerXAnchor.constraint(equalTo: arrangeView.centerXAnchor))
      constraints.append(arrangeStripView.heightAnchor.constraint(equalToConstant: 20.0))
      constraints.append(arrangeView.bottomAnchor.constraint(greaterThanOrEqualTo: arrangeStripView.bottomAnchor))
      
      var lastButton : NSButton? = nil

      for arrangeButton in ArrangeButton.allCases {
        
        if let button = arrangeButton.icon.button(target: self, action: #selector(btnArrangeAction(_:))) {
          
          arrangeButtons.append(button)
          
          button.translatesAutoresizingMaskIntoConstraints = false
          button.isBordered = false
          button.tag = arrangeButton.rawValue
          button.toolTip = arrangeButton.tooltip
          
          arrangeStripView.addSubview(button)
          
          constraints.append(button.centerYAnchor.constraint(equalTo: arrangeStripView.centerYAnchor))
          
          if let lastButton {
            constraints.append(button.leadingAnchor.constraint(equalToSystemSpacingAfter: lastButton.trailingAnchor, multiplier: 1.0))
          }
          else {
            constraints.append(button.leadingAnchor.constraint(equalToSystemSpacingAfter: arrangeStripView.leadingAnchor, multiplier: 1.0))
          }
          
          lastButton = button
          
        }
        
      }
      
      constraints.append(arrangeStripView.trailingAnchor.constraint(equalToSystemSpacingAfter: lastButton!.trailingAnchor, multiplier: 1.0))
      constraints.append(arrangeView.widthAnchor.constraint(greaterThanOrEqualTo: arrangeStripView.widthAnchor))
      
      cboPalette.translatesAutoresizingMaskIntoConstraints = false
      
      SwitchboardItemPalette.populate(comboBox: cboPalette, country: layout.countryCode)
      
      arrangeView.addSubview(cboPalette)
      
      constraints.append(cboPalette.topAnchor.constraint(equalToSystemSpacingBelow: arrangeStripView.bottomAnchor, multiplier: 1.0))
      constraints.append(cboPalette.centerXAnchor.constraint(equalTo: arrangeStripView.centerXAnchor))
      constraints.append(arrangeView.trailingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: cboPalette.trailingAnchor, multiplier: 1.0))
      constraints.append(arrangeView.bottomAnchor.constraint(greaterThanOrEqualToSystemSpacingBelow: cboPalette.bottomAnchor, multiplier: 1.0))
      
      SwitchboardItemPalette.select(comboBox: cboPalette, value: currentPalette)
      
      for palette in SwitchboardItemPalette.availablePalettes(country: layout.countryCode) {
        let view = NSView()
        view.translatesAutoresizingMaskIntoConstraints = false
        /// Palette Buttons are created here!
        constraints.append(contentsOf: SwitchboardItemPalette.populate(paletteView: view, palette: palette, target: self, action: #selector(btnPartType(_:))))
        
        paletteViews[palette] = view
        arrangeView.addSubview(view)
        constraints.append(view.topAnchor.constraint(equalTo: cboPalette.bottomAnchor))
        constraints.append(view.centerXAnchor.constraint(equalTo: arrangeView.centerXAnchor))
        constraints.append(arrangeView.bottomAnchor.constraint(greaterThanOrEqualTo: view.bottomAnchor))
      }
      
      arrangeButtons[ArrangeButton.addItemToPanel.rawValue]?.keyEquivalent = "+"
      arrangeButtons[ArrangeButton.removeItemFromPanel.rawValue]?.keyEquivalent = "-"
      
      groupView.translatesAutoresizingMaskIntoConstraints = false

      paletteView.addSubview(groupView)
      
      constraints.append(groupView.topAnchor.constraint(equalTo: paletteView.topAnchor))
      constraints.append(groupView.centerXAnchor.constraint(equalTo: paletteView.centerXAnchor))
      constraints.append(paletteView.bottomAnchor.constraint(greaterThanOrEqualTo: groupView.bottomAnchor))
      constraints.append(paletteView.widthAnchor.constraint(greaterThanOrEqualTo: groupView.widthAnchor))
      
      groupStripView.translatesAutoresizingMaskIntoConstraints = false

      groupView.addSubview(groupStripView)
      
      constraints.append(groupStripView.topAnchor.constraint(equalTo: groupView.topAnchor))
      constraints.append(groupStripView.centerXAnchor.constraint(equalTo: groupView.centerXAnchor))
      constraints.append(groupStripView.heightAnchor.constraint(equalToConstant: 20.0))
      
      cboGroup?.translatesAutoresizingMaskIntoConstraints = false
      cboGroup?.target = self
      cboGroup?.action = #selector(cboGroupAction(_:))
      
      groupView.addSubview(cboGroup!)
      
      constraints.append(cboGroup!.topAnchor.constraint(equalToSystemSpacingBelow: groupStripView.bottomAnchor, multiplier: 1.0))
      constraints.append(groupView.bottomAnchor.constraint(greaterThanOrEqualTo: cboGroup!.bottomAnchor))
      constraints.append(cboGroup!.leadingAnchor.constraint(equalTo: groupView.leadingAnchor))
      constraints.append(cboGroup!.trailingAnchor.constraint(equalTo: groupView.trailingAnchor))

      lastButton = nil

      for groupButton in GroupButton.allCases {
        
        if let button = groupButton.icon.button(target: self, action: #selector(btnGroupAction(_:))) {
          
          groupButtons.append(button)
          
          button.translatesAutoresizingMaskIntoConstraints = false
          button.isBordered = false
          button.tag = groupButton.rawValue
          button.toolTip = groupButton.tooltip
          
          groupStripView.addSubview(button)
          
          constraints.append(button.centerYAnchor.constraint(equalTo: groupStripView.centerYAnchor))
          
          if let lastButton {
            constraints.append(button.leadingAnchor.constraint(equalToSystemSpacingAfter: lastButton.trailingAnchor, multiplier: 1.0))
          }
          else {
            constraints.append(button.leadingAnchor.constraint(equalToSystemSpacingAfter: groupStripView.leadingAnchor, multiplier: 1.0))
          }

          lastButton = button

        }

      }

      constraints.append(groupStripView.trailingAnchor.constraint(equalToSystemSpacingAfter: lastButton!.trailingAnchor, multiplier: 1.0))
      constraints.append(groupView.widthAnchor.constraint(greaterThanOrEqualTo: groupStripView.widthAnchor))

      self.cboPalette?.target = self
      self.cboPalette?.action = #selector(self.cboPaletteAction(_:))
      
      cboPaletteAction(cboPalette)

    }
    
  }
  
  internal func releasePaletteGroupingAreaControls() {
    
    arrangeView?.removeSubViews()
    arrangeView = nil
    
    arrangeStripView?.removeSubViews()
    arrangeStripView = nil
    
    groupView?.removeSubViews()
    groupView = nil
    
    groupStripView?.removeSubViews()
    groupStripView = nil
    
    for (_, view) in paletteViews {
      view.removeSubViews()
    }
    paletteViews.removeAll()
    
    cboPalette?.target = nil
    cboPalette?.action = nil
    cboPalette?.removeAllItems()
    cboPalette = nil
    
    cboGroup?.target = nil
    cboGroup?.action = nil
    cboGroup?.removeAllItems()
    cboGroup = nil
    
    for index in 0 ... arrangeButtons.count - 1 {
      if let button = arrangeButtons[index] {
        button.image = nil
        button.target = nil
        button.action = nil
      }
      arrangeButtons[index] = nil
    }
    arrangeButtons.removeAll()

    for index in 0 ... groupButtons.count - 1 {
      if let button = groupButtons[index] {
        button.image = nil
        button.target = nil
        button.action = nil
      }
      groupButtons[index] = nil
    }
    groupButtons.removeAll()
    
  }
  
  private func resetPartButtons() {
    for (_, paletteView) in paletteViews {
      for view in paletteView.subviews {
        for control in view.subviews {
          if let button = control as? SwitchboardShapeButton {
            button.state = .off
          }
        }
      }
    }
  }
    
  // MARK: Actions
  
  @objc func btnArrangeAction(_ sender: NSButton) {
    
    guard let button = ArrangeButton(rawValue: sender.tag) else {
      return
    }
    
    switch button {
    case .addItemToPanel:
      guard let currentPartType else {
        return
      }
      switchboardView.addItem(partType: currentPartType)
    case .removeItemFromPanel:
      switchboardView.deleteItem()
    case .rotateCounterClockwise:
      switchboardView.rotateLeft()
    case .rotateClockwise:
      switchboardView.rotateRight()
    case .switchToGroupingMode:
      isGroupMode = true
    }
    
  }
  
  @objc func btnGroupAction(_ sender: NSButton) {
    
    guard let button = GroupButton(rawValue: sender.tag) else {
      return
    }
    
    switch button {
    case .addItemToGroup:
      switchboardView.addToGroup()
    case .removeItemFromGroup:
      switchboardView.removeFromGroup()
    case .switchToArrangeMode:
      isGroupMode = false
    }
    
  }
  
  @objc func btnPartType(_ sender: NSButton) {
    guard let button = sender as? SwitchboardShapeButton else {
      return
    }
    let state = button.state
    resetPartButtons()
    button.state = state
    currentPartType = state == .on ? button.partType : nil
  }
  
  @objc func cboPaletteAction(_ sender: NSComboBox) {
    let lastPalette = currentPalette
    currentPalette = SwitchboardItemPalette.selected(comboBox: sender)
    if lastPalette != currentPalette {
      resetPartButtons()
      currentPartType = nil
    }
  }

  @objc func cboGroupAction(_ sender: NSComboBox) {
    switchboardView.groupId = appNode?.selectedGroup(comboBox: sender)?.nodeId ?? 0
  }
  
}
