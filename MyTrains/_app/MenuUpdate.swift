//
//  MenuUpdate.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/01/2024.
//

import Foundation
import AppKit

public let fileMenu = NSMenuItem()
public let newMenu = NSMenuItem()
public let layoutMenuItem = NSMenuItem()
public let operationsMenu = NSMenuItem()
public let throttleMenuItem = NSMenuItem()
public let appModeMenuItem = NSMenuItem()
public let configurationMenu = NSMenuItem()
public let createAppNodeMenuItem = NSMenuItem()
public let networkMenuItem = NSMenuItem()
public let fastClockMenuItem = NSMenuItem()
public let dccProgrammerToolMenuItem = NSMenuItem()
public let switchBoardMenuItem = NSMenuItem()
public let speedProfilerMenuItem = NSMenuItem()
public let locoNetFirmwareUpdateMenuItem = NSMenuItem()
public let locoNetWirelessSetupMenuItem = NSMenuItem()
public let toolsMenu = NSMenuItem()
public let openLCBTrafficMonitorMenuItem = NSMenuItem()
public let locoNetTrafficMonitorMenuItem = NSMenuItem()
public let locoNetSlotViewMenuItem = NSMenuItem()
public let locoNetDashboardMenuItem = NSMenuItem()

public func menuUpdate() {
 
  let initialized = appNodeId != nil
  
  fileMenu.isHidden = !initialized
  newMenu.isHidden = !initialized
  operationsMenu.isHidden = !initialized
  toolsMenu.isHidden = !initialized
  appModeMenuItem.isHidden = !initialized
  createAppNodeMenuItem.isHidden = initialized
  networkMenuItem.isHidden = !initialized
  fastClockMenuItem.isHidden = !initialized
  dccProgrammerToolMenuItem.isHidden = !initialized
  switchBoardMenuItem.isHidden = !initialized
  speedProfilerMenuItem.isHidden = !initialized
  locoNetFirmwareUpdateMenuItem.isHidden = !initialized
  locoNetWirelessSetupMenuItem.isHidden = !initialized
  
}
