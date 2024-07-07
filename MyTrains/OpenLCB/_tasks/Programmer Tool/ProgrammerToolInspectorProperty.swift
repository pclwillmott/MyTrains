//
//  ProgrammerToolInspectorProperty.swift
//  MyTrains
//
//  Created by Paul Willmott on 07/07/2024.
//

import Foundation
import AppKit

public enum ProgrammerToolInspectorProperty : Int, CaseIterable {
  
  // MARK: Enumeration
  
  // Decoder Information
  
  case projectName = 1
  case manufacturer = 2
  case model = 3
  case esuflash = 4
  case manufacturerId = 5
  case esuProductId = 6
  case esuSerialNumber = 7
  case esuSoundLock = 8
  case esuFirmwareVersion = 9
  case esuFirmwareType = 10
  case esuBootcodeVersion = 11
  case esuProductionInfo = 12
  case esuProductionDate = 13
  case cv7 = 14
  case cv8 = 15
  case esuDecoderOperatingTime = 16
  case esuSmokeUnitOperatingTime = 17
  
  // Read and Write CVs
  
  case programmingTrack = 18
  case mainTrackProgramming = 19
  case locoDecoder = 20
  case accessoryDecoder = 21
  case address = 22
  case cv = 23
  case value = 24
  case bits = 25
  case useIndexCVs = 26
  case cv31 = 27
  case cv32 = 28
  
  // Quick Help
  
}
