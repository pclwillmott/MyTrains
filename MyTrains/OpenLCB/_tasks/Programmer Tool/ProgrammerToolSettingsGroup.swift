//
//  ProgrammerToolSettingsGroup.swift
//  MyTrains
//
//  Created by Paul Willmott on 05/07/2024.
//

import Foundation
import AppKit

public enum ProgrammerToolSettingsGroup : Int, CaseIterable {
  
  // MARK: Enumeration
  
  case address = 0
  case analogSettings = 1
  case brakeSettings = 2
  case dccSettings = 3
  case drivingCharacteristics = 4
  case functionOutputs = 5
  case functionSettings = 6
  case functionMapping = 7
  case identification = 8
  case compatibility = 9
  case motorSettings = 10
  case smokeUnit = 11
  case specialOptions = 12
  case soundSettings = 13
  case soundSlotSettings = 14
  case manualCVInput = 15
  
  // MARK: Public Properties
  
  public var title : String {
  
    let titles : [ProgrammerToolSettingsGroup:String] = [
      .address                : String(localized: "Address"),
      .analogSettings         : String(localized: "Analog Settings"),
      .brakeSettings          : String(localized: "Brake Settings"),
      .dccSettings            : String(localized: "DCC Settings"),
      .drivingCharacteristics : String(localized: "Driving Characteristics"),
      .functionOutputs        : String(localized: "Function Outputs"),
      .functionSettings       : String(localized: "Function Settings"),
      .functionMapping        : String(localized: "Function Mappings"),
      .identification         : String(localized: "Identification"),
      .compatibility          : String(localized: "Compatibility"),
      .motorSettings          : String(localized: "Motor Settings"),
      .smokeUnit              : String(localized: "Smoke Unit"),
      .specialOptions         : String(localized: "Special Options"),
      .soundSettings          : String(localized: "Sound Settings"),
      .soundSlotSettings      : String(localized: "Sound Slot Settings"),
      .manualCVInput          : String(localized: "Manual CV Input"),
    ]
    
    return titles[self]!

  }
  
  public var button : NSButton {
    
    let icons : [ProgrammerToolSettingsGroup:MyIcon] = [
      .address : .envelope,
      .analogSettings : .speedometer,
      .brakeSettings : .brake,
      .dccSettings : .gear,
      .drivingCharacteristics : .gearshift,
      .functionOutputs : .lightbulb,
      .functionSettings : .button,
      .functionMapping : .button,
      .identification : .id,
      .compatibility : .button,
      .motorSettings : .engine,
      .smokeUnit : .smoke,
      .specialOptions : .button,
      .soundSettings : .speaker,
      .soundSlotSettings : .speaker,
      .manualCVInput : .wrench,
    ]
    
    
    let button = icons[self]!.button(target: nil, action: nil)!
    button.toolTip = title
    button.translatesAutoresizingMaskIntoConstraints = false
    button.isBordered = false
    button.tag = self.rawValue
    
    return button
    
  }
  
}
