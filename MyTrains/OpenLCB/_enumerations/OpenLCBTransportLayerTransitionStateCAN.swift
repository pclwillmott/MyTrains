//
//  LCCCANTransportLayerState.swift
//  MyTrains
//
//  Created by Paul Willmott on 14/05/2023.
//

import Foundation

public enum OpenLCBTransportTransitionStateCAN {
  case idle
  case testingAlias
  case reservingAlias
  case mappingDeclared
  case tryAgain
}

