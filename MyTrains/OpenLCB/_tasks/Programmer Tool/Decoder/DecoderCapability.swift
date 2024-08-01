//
//  DecoderCapability.swift
//  MyTrains
//
//  Created by Paul Willmott on 11/07/2024.
//

import Foundation
public enum DecoderCapability : CaseIterable {
  
  // MARK: Enumeration
  
  case dccProtocol
  case marklinMotorolaProtocol
  case m4Protocol
  case selectrixProtocol
  case respondsToNonDCCCommands
  case acAnalogMode
  case threeValueSpeedTable
  case highFrequencyPWMMotorControl
  case sendZIMOZACKSignals
  
}
