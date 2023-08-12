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
  @objc optional func cvDataUpdated(programmerTool:OpenLCBProgrammerToolNode, cvData:[UInt8])
  @objc optional func statusUpdate(ProgrammerTool:OpenLCBProgrammerToolNode, status:String)
  @objc optional func programmingModeUpdated(ProgrammerTool:OpenLCBProgrammerToolNode, programmingMode:Int)
}
