//
//  MyTrainsControllerDelegate.swift
//  MyTrains
//
//  Created by Paul Willmott on 16/06/2023.
//

import Foundation

@objc public protocol MyTrainsControllerDelegate {
  @objc optional func interfacesUpdated(interfaces:[Interface])
  @objc optional func myTrainsControllerUpdated(myTrainsController:MyTrainsController)
  @objc optional func statusUpdated(myTrainsController:MyTrainsController)
  @objc optional func switchBoardUpdated()
}
