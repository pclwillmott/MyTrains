//
//  LCCCANFrameFlag.swift
//  MyTrains
//
//  Created by Paul Willmott on 15/04/2023.
//

import Foundation

public enum OpenLCBCANFrameFlag : UInt8 {
  
  case onlyFrame   = 0b00
  case firstFrame  = 0b01
  case lastFrame   = 0b10
  case middleFrame = 0b11
  
  // MARK: Public Properties
  
  public var title : String {
    return OpenLCBCANFrameFlag.titles[self]!
  }
  // MARK: Private Class Properties
  
  private static let titles : [OpenLCBCANFrameFlag:String] = [
    .onlyFrame : String(localized: "Only Frame"),
    .firstFrame : String(localized: "First Frame"),
    .lastFrame : String(localized: "Last Frame"),
    .middleFrame : String(localized: "Middle Frame"),
  ]
  
}
