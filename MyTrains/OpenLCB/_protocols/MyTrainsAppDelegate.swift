//
//  MyTrainsAppDelegate.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/01/2024.
//

import Foundation

@objc public protocol MyTrainsAppDelegate {
  @objc optional func layoutListUpdated(appNode:OpenLCBNodeMyTrains)
  @objc optional func locoNetGatewayListUpdated(appNode:OpenLCBNodeMyTrains)
  @objc optional func panelListUpdated(appNode:OpenLCBNodeMyTrains)
  @objc optional func panelUpdated(panel:SwitchboardPanelNode)
  @objc optional func locomotiveListUpdated(appNode:OpenLCBNodeMyTrains)
}
