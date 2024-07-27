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
  
  case info = 0
  case address = 1
  case analogSettings = 2
  case brakeSettings = 3
  case dccSettings = 4
  case drivingCharacteristics = 5
  case functionOutputs = 6
  case functionSettings = 7
  case functionMapping = 8
  case identification = 9
  case compatibility = 10
  case motorSettings = 11
  case smokeUnit = 12
  case specialOptions = 13
  case soundSettings = 14
  case soundSlotSettings = 15
  case manualCVInput = 16
  
  // MARK: Public Properties
  
  public var title : String {
  
    let titles : [ProgrammerToolSettingsGroup:String] = [
      .info                   : String(localized: "Decoder Information"),
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
      .info : .info,
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
