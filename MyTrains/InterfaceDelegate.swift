//
//  InterfaceDelegate.swift
//  MyTrains
//
//  Created by Paul Willmott on 14/05/2022.
//

import Foundation

@objc public protocol InterfaceDelegate {
  @objc optional func networkMessageReceived(message:NetworkMessage)
  @objc optional func interfaceWasDisconnected(interface:Interface)
  @objc optional func interfaceWasOpened(interface:Interface)
  @objc optional func interfaceWasClosed(interface:Interface)
  @objc optional func progMessageReceived(message: NetworkMessage) 
  @objc optional func slotsUpdated(interface:Interface)
  @objc optional func trackStatusChanged(interface: Interface)
}
