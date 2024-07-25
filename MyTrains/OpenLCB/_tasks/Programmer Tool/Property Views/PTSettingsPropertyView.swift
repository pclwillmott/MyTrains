//
//  PTSettingsPropertyView.swift
//  MyTrains
//
//  Created by Paul Willmott on 25/07/2024.
//

import Foundation
import AppKit

public class PTSettingsPropertyView : NSView, NSTextFieldDelegate {

  // MARK: Destructors
  
  deinit {
    
    NSLayoutConstraint.deactivate(viewConstraints)
    
    viewConstraints.removeAll()
    
    self.subviews.removeAll()
    
    cvLabel = nil
    
    label = nil
    
    checkBox = nil
    
    comboBox = nil
    
    textField = nil
    
    slider = nil
    
    info = nil
    
  }
  
  // MARK: Controls
  
  private var cvLabel : NSTextField?
  
  private var label : NSTextField?
  
  private var checkBox : NSButton?
  
  private var comboBox : MyComboBox?
  
  private var textField : NSTextField?
  
  private var slider : NSSlider?
  
  private var info : NSTextField?
  
  // MARK: Private Properties
  
  private var _property : ProgrammerToolSettingsProperty?
  
  private var _definition : ProgrammerToolSettingsPropertyDefinition?
  
  private let leadingOffset : CGFloat = 20.0
  
  private let comboWidth : CGFloat = 300.0
  
  private let textWidth : CGFloat = 50.0
  
  private let sliderWidth : CGFloat = 150.0
  
  private var viewConstraints : [NSLayoutConstraint] = []
  
  // MARK: Internal Properties
  
  // MARK: Public Properties
  
  public var property : ProgrammerToolSettingsProperty {
    get {
      return _property!
    }
  }
  
  public var definition : ProgrammerToolSettingsPropertyDefinition {
    get {
      return _definition!
    }
  }
  
  public var indexingMethod : CVIndexingMethod? {
    return definition.cvIndexingMethod
  }
  
  public var section : ProgrammerToolSettingsSection {
    return definition.section
  }
  
  public var group : ProgrammerToolSettingsGroup {
    return definition.section.inspector
  }
  
  public var decoder : Decoder? {
    didSet {
      reload()
    }
  }
  
  // MARK: Private Methods
  
  private func buildInterface() {
    
    // Info Labels
    
    if definition.infoType != .none {
      
      info = NSTextField(labelWithString: "")
      
      if let info {
        
        info.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(info)
        
        viewConstraints.append(self.bottomAnchor.constraint(greaterThanOrEqualTo: info.bottomAnchor))
        
        viewConstraints.append(self.trailingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: info.trailingAnchor, multiplier: 1.0))
        
      }
      
    }
    
    // CV Labels
    
    if definition.cv != nil {
      
      cvLabel = NSTextField(labelWithString: "")
      
      if let cvLabel {
        
        cvLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(cvLabel)
        
        viewConstraints.append(self.trailingAnchor.constraint(equalToSystemSpacingAfter: cvLabel.trailingAnchor, multiplier: 1.0))
        
        viewConstraints.append(self.bottomAnchor.constraint(greaterThanOrEqualTo: cvLabel.bottomAnchor))
        
        if let info {
          
          viewConstraints.append(cvLabel.leadingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: info.trailingAnchor, multiplier: 1.0))
          
        }
        
      }
      
    }
    
    // Label
    
    let controlsWithLabels : Set<ProgrammerToolControlType> = [
      .comboBox,
      .comboBoxDynamic,
      .description,
      .esuSpeedTable,
      .functionsAnalogMode,
      .functionsConsistMode,
      .label,
      .textField,
      .textFieldWithSlider,
      .warning,
    ]
    
    if controlsWithLabels.contains(definition.controlType) {
      
      label = NSTextField(labelWithString: definition.title)
      
      if let label {
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(label)
        
        viewConstraints.append(label.topAnchor.constraint(equalTo: self.topAnchor))
        
        viewConstraints.append(label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: leadingOffset))
        
        viewConstraints.append(self.bottomAnchor.constraint(greaterThanOrEqualTo: label.bottomAnchor))
        
        viewConstraints.append(self.trailingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: label.trailingAnchor, multiplier: 1.0))
        
      }
      
    }
    
    // Controls
    
    switch definition.controlType {
    case .checkBox:
      
      checkBox = NSButton(checkboxWithTitle: definition.title, target: self, action: #selector(checkBoxAction(_:)))
      
      if let checkBox {
        
        checkBox.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(checkBox)
        
        viewConstraints.append(checkBox.topAnchor.constraint(equalTo: self.topAnchor))
        
        viewConstraints.append(checkBox.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: leadingOffset))
        
        viewConstraints.append(self.bottomAnchor.constraint(greaterThanOrEqualTo: checkBox.bottomAnchor))
        
        viewConstraints.append(self.trailingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: checkBox.trailingAnchor, multiplier: 1.0))
        
      }
      
    case .comboBox, .comboBoxDynamic:
      
      comboBox = MyComboBox()

      if let comboBox, let label {
        
        comboBox.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(comboBox)
        
        comboBox.target = self
        comboBox.action = #selector(comboBoxAction(_:))
        comboBox.isEditable = false
        
        viewConstraints.append(comboBox.topAnchor.constraint(equalToSystemSpacingBelow: label.bottomAnchor, multiplier: 1.0))
        
        viewConstraints.append(comboBox.leadingAnchor.constraint(equalTo: label.leadingAnchor))
        
        viewConstraints.append(comboBox.widthAnchor.constraint(equalToConstant: comboWidth))
        
        viewConstraints.append(self.bottomAnchor.constraint(greaterThanOrEqualTo: comboBox.bottomAnchor))
        
        viewConstraints.append(self.trailingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: comboBox.trailingAnchor, multiplier: 1.0))
        
        if let cvLabel {
          
          viewConstraints.append(cvLabel.leadingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: comboBox.trailingAnchor, multiplier: 1.0))
          
          viewConstraints.append(cvLabel.topAnchor.constraint(equalTo: comboBox.topAnchor))
          
        }
        
        if definition.controlType == .comboBox {
          initComboBox()
        }
        
      }
      
    case .label:
      
      textField = NSTextField(labelWithString: "")
      
      if let textField, let label {
      
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(textField)
        
        viewConstraints.append(textField.topAnchor.constraint(equalToSystemSpacingBelow: label.bottomAnchor, multiplier: 1.0))
        
        viewConstraints.append(textField.leadingAnchor.constraint(equalTo: label.leadingAnchor))
        
        viewConstraints.append(self.bottomAnchor.constraint(greaterThanOrEqualTo: textField.bottomAnchor))
        
        viewConstraints.append(self.trailingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: textField.trailingAnchor, multiplier: 1.0))

        if let cvLabel {
          
          viewConstraints.append(cvLabel.leadingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: textField.trailingAnchor, multiplier: 1.0))

          viewConstraints.append(cvLabel.topAnchor.constraint(equalTo: textField.topAnchor))

        }

      }
      
    case .textField:
      
      textField = NSTextField()
      
      if let textField, let label {
      
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(textField)
        
        textField.delegate = self
        
        viewConstraints.append(textField.topAnchor.constraint(equalToSystemSpacingBelow: label.bottomAnchor, multiplier: 1.0))
        
        viewConstraints.append(textField.leadingAnchor.constraint(equalTo: label.leadingAnchor))
        
        viewConstraints.append(textField.widthAnchor.constraint(equalToConstant: textWidth))
        
        viewConstraints.append(self.bottomAnchor.constraint(greaterThanOrEqualTo: textField.bottomAnchor))
        
        viewConstraints.append(self.trailingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: textField.trailingAnchor, multiplier: 1.0))

        if let cvLabel {
          
          viewConstraints.append(cvLabel.leadingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: textField.trailingAnchor, multiplier: 1.0))

          viewConstraints.append(cvLabel.centerYAnchor.constraint(equalTo: textField.centerYAnchor))

          if let info {
            
            viewConstraints.append(info.centerYAnchor.constraint(equalTo: textField.centerYAnchor))
            
            viewConstraints.append(info.leadingAnchor.constraint(equalToSystemSpacingAfter: textField.trailingAnchor, multiplier: 1.0))
            
            viewConstraints.append(cvLabel.leadingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: info.trailingAnchor, multiplier: 1.0))
            
          }
          
        }

      }
      
    case .textFieldWithSlider:
      
      slider = NSSlider(value: 0.0, minValue: definition.minValue!, maxValue: definition.maxValue!, target: self, action: #selector(sliderAction(_:)))
      
      textField = NSTextField()
      
      if let slider, let textField, let label {
      
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(slider)
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(textField)
        
        textField.delegate = self
        
        viewConstraints.append(slider.topAnchor.constraint(equalToSystemSpacingBelow: label.bottomAnchor, multiplier: 1.0))
        
        viewConstraints.append(slider.leadingAnchor.constraint(equalTo: label.leadingAnchor))
        
        viewConstraints.append(slider.widthAnchor.constraint(equalToConstant: sliderWidth))
        
        viewConstraints.append(self.bottomAnchor.constraint(greaterThanOrEqualTo: slider.bottomAnchor))
        
        viewConstraints.append(self.trailingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: slider.trailingAnchor, multiplier: 1.0))
        
        viewConstraints.append(textField.topAnchor.constraint(equalToSystemSpacingBelow: label.bottomAnchor, multiplier: 1.0))
        
        viewConstraints.append(textField.leadingAnchor.constraint(equalToSystemSpacingAfter: slider.trailingAnchor, multiplier: 1.0))
        
        viewConstraints.append(textField.widthAnchor.constraint(equalToConstant: textWidth))
        
        viewConstraints.append(self.bottomAnchor.constraint(greaterThanOrEqualTo: textField.bottomAnchor))
        
        viewConstraints.append(self.trailingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: textField.trailingAnchor, multiplier: 1.0))

        if let cvLabel {
          
          viewConstraints.append(cvLabel.leadingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: textField.trailingAnchor, multiplier: 1.0))

          viewConstraints.append(cvLabel.centerYAnchor.constraint(equalTo: textField.centerYAnchor))

          if let info {
            
            viewConstraints.append(info.centerYAnchor.constraint(equalTo: textField.centerYAnchor))
            
            viewConstraints.append(info.leadingAnchor.constraint(equalToSystemSpacingAfter: textField.trailingAnchor, multiplier: 1.0))
            
            viewConstraints.append(cvLabel.leadingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: info.trailingAnchor, multiplier: 1.0))
            
          }
          
        }

      }
      
    case .esuSpeedTable:
      break
    case .functionsAnalogMode:
      break
    case .functionsConsistMode:
      break
    default:
      break
    }

  }
  
  private func initComboBox() {
    
    guard let comboBox else {
      return
    }
    
    switch property {
    case .locomotiveAddressType:
      LocomotiveAddressType.populate(comboBox: comboBox)
    case .marklinConsecutiveAddresses:
      MarklinConsecutiveAddresses.populate(comboBox: comboBox)
    case .m4MasterDecoderManufacturer:
      ManufacturerCode.populate(comboBox: comboBox)
    case .speedStepMode:
      SpeedStepMode.populate(comboBox: comboBox)
    case .classLightLogicSequenceLength:
      ClassLightLogicSequenceLength.populate(comboBox: comboBox)
    case .decoderSensorSettings:
      DecoderSensorSettings.populate(comboBox: comboBox)
    case .steamChuffMode:
      SteamChuffMode.populate(comboBox: comboBox)
    case .soundControlBasis:
      SoundControlBasis.populate(comboBox: comboBox)
    case .idleOperationTriggeredFunction, .loadOperationTriggeredFunction:
      TriggeredFunction.populate(comboBox: comboBox)
    case .physicalOutputSmokeUnitControlMode:
      SmokeUnitControlMode.populate(comboBox: comboBox)
    case .physicalOutputExternalSmokeUnitType:
      ExternalSmokeUnitType.populate(comboBox: comboBox)
    case .speedTableIndex:
      comboBox.removeAllItems()
      for index in 1 ... 28 {
        comboBox.addItem(withObjectValue: "\(index)")
      }
    case .speedTablePreset:
      SpeedTablePreset.populate(comboBox: comboBox)
    default:
      break
    }
  }
  
  private func initComboBoxDynamic() {
    
    guard let comboBox, let decoder else {
      return
    }

    let target = comboBox.target
    let action = comboBox.action
    
    comboBox.target = nil
    comboBox.action = nil
    
    switch property {
    case .physicalOutput:
      ESUDecoderPhysicalOutput.populate(comboBox: comboBox, decoder: decoder)
    case .physicalOutputOutputMode:
      ESUPhysicalOutputMode.populate(comboBox: comboBox, decoder: decoder)
    default:
      break
    }
    
    comboBox.target = target
    comboBox.action = action
    
  }

  // MARK: Public Methods
  
  public func initialize(property:ProgrammerToolSettingsProperty, definition:ProgrammerToolSettingsPropertyDefinition) {
    
    _property = property
    
    _definition = definition
    
    self.translatesAutoresizingMaskIntoConstraints = false
    
    buildInterface()
    
  }
  
  public func activateConstraints() {
    NSLayoutConstraint.activate(viewConstraints)
  }
  
  public func reload() {
    
    if let decoder {
      
      let value = decoder.getValue(property: property)
      
      switch definition.controlType {
      case .checkBox:
        checkBox!.boolValue = value == "true"
      case .comboBoxDynamic:
        initComboBoxDynamic()
        fallthrough
      case .comboBox:
        comboBox!.selectItem(withObjectValue: value)
      case .textFieldWithSlider:
        slider!.integerValue = Int(value)!
        fallthrough
      case .textField, .label:
        textField!.stringValue = value
      default:
        break
      }
      
      if let info {
        info.stringValue = decoder.getInfo(property: property)
      }
      
      if let cvLabel, let text = property.cvLabel(decoder: decoder) {
        cvLabel.stringValue = text
      }
      
    }

  }
  
  // MARK: Actions
  
  @objc func checkBoxAction(_ sender:NSButton) {
    decoder?.setValue(property: property, string: sender.state == .on ? "true" : "false", definition: definition)
  }
  
  @objc func comboBoxAction(_ sender:MyComboBox) {
    if let string = sender.objectValueOfSelectedItem as? String {
      decoder?.setValue(property: property, string: string, definition: definition)
    }
  }
  
  @objc func sliderAction(_ sender:NSSlider) {
    
    if let decoder, let textField {
      
      let value = "\(sender.integerValue)"
      
      decoder.setValue(property: property, string: "\(value)", definition: definition)
      
      textField.stringValue = value
      
      if let info {
        info.stringValue = decoder.getInfo(property: property, definition: definition)
      }
      
    }
    
  }
  
  // MARK: NSTextFieldDelegate Methods
  
  @objc public func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
    
    var isValid = true
    
    if let decoder {
      
      let string = control.stringValue.trimmingCharacters(in: .whitespaces)
      
      isValid = decoder.isValid(property: property, string: string, definition: definition)
      
      if isValid {
        
        decoder.setValue(property: property, string: string, definition: definition)
        
        if let slider, let value = Int(string) {
          slider.integerValue = value
        }
        
        if let info {
          info.stringValue = decoder.getInfo(property: property, definition: definition)
        }
        
      }
      
    }
    
    return isValid
    
  }

}
