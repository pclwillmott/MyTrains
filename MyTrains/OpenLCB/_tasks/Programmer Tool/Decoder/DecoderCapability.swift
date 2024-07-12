//
//  DecoderCapability.swift
//  MyTrains
//
//  Created by Paul Willmott on 11/07/2024.
//

import Foundation
public enum DecoderCapability : Int, CaseIterable {
  
  // MARK: Enumeration
  
  case nmraMandatory = 0
  case nmraSpeedTable = 1
  case esuProprietary = 2
  case esuSpeedTable = 3
  case esuSound = 4
  
}
