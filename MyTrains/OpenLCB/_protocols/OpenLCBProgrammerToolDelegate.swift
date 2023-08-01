//
//  OpenLCBProgrammerToolDelegate.swift
//  MyTrains
//
//  Created by Paul Willmott on 01/08/2023.
//

import Foundation

@objc public protocol OpenLCBProgrammerToolDelegate {
  @objc optional func programmingTracksUpdated(programmerTool:OpenLCBProgrammerToolNode, programmingTracks:[UInt64:String])
  @objc optional func dccTrainsUpdated(programmerTool:OpenLCBProgrammerToolNode, dccTrainNodes:[UInt64:String])
}
