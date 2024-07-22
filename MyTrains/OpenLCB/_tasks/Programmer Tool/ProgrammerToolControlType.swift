//
//  ProgrammerToolControlType.swift
//  MyTrains
//
//  Created by Paul Willmott on 10/07/2024.
//

import Foundation
import AppKit

public enum ProgrammerToolControlType {
  
  // MARK: Enumeration
  
  case textField
  case label
  case checkBox
  case comboBox
  case comboBoxDynamic
  case description
  case warning
  case textFieldWithSlider
  case functionsConsistMode
  case functionsAnalogMode
  case esuSpeedTable

  // Deprecated
  
  case textFieldWithInfo
  case textFieldWithInfoWithSlider

}
