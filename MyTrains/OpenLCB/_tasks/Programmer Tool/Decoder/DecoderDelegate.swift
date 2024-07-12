//
//  DecoderDelegate.swift
//  MyTrains
//
//  Created by Paul Willmott on 07/07/2024.
//

import Foundation

@objc public protocol DecoderDelegate {
  @objc optional func reloadData(_ decoder: Decoder)
  @objc optional func reloadSettings(_ decoder: Decoder)
}

public protocol IdentifyDecoderDelegate {
  func identifyDecoderGetCVs(cvs:[CV])
}
