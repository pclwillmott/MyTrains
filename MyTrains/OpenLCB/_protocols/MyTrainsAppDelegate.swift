//
//  MyTrainsAppDelegate.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/01/2024.
//

import Foundation

public protocol MyTrainsAppDelegate {
  func layoutListUpdated(layoutList:[LayoutListItem])
  func panelListUpdated(panelList:[PanelListItem])
  func switchboardItemListUpdated(switchboardItemList:[SwitchboardItemListItem])
}
