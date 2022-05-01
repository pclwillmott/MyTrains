//
//  SwitchBoardItem.swift
//  MyTrains
//
//  Created by Paul Willmott on 30/04/2022.
//

import Foundation

public enum SwitchBoardItemAction {
  case delete
  case save
  case noAction
}

class SwitchBoardItem : NSObject {

  // MARK: Constructors
  
  init(location: SwitchBoardLocation, partType: SwitchBoardPart, orientation: Int, groupId: Int, panelId: Int) {
    super.init()
    self.location = location
    self.partType = partType
    self.orientation = orientation
    self.groupId = groupId
    self.panelId = panelId
  }
  
  // MARK: Private Properties
  
  private var modified : Bool = false
  
  // MARK: Public Properties
  
  public var location : SwitchBoardLocation = (x: 0, y: 0) {
    didSet {
      modified = true
    }
  }
  
  public var partType : SwitchBoardPart = .none {
    didSet {
      modified = true
    }
  }
  
  public var orientation : Int = 0 {
    didSet {
      modified = true
    }
  }
  
  public var groupId : Int = -1 {
    didSet {
      modified = true
    }
  }
  
  public var panelId : Int = -1 {
    didSet {
      modified = true
    }
  }
  
  public var nextAction : SwitchBoardItemAction = .noAction
  
  public var key : Int {
    get {
      return SwitchBoardItem.createKey(panelId: panelId, location: location, nextAction: nextAction)
    }
  }
  
  public var isDatabaseItem : Bool {
    get {
      return false
    }
  }
  
  // MARK: Private Methods
  
  // MARK: Public Methods
  
  public func rotateRight() {
    var orientation = self.orientation
    orientation += 1
    if orientation > 7 {
      orientation = 0
    }
    self.orientation = orientation
  }
  
  public func rotateLeft() {
    var orientation = self.orientation
    orientation -= 1
    if orientation < 0 {
      orientation = 7
    }
    self.orientation = orientation
  }
  
  // MARK: Class Methods
  
  public static func createKey(panelId: Int, location: SwitchBoardLocation, nextAction: SwitchBoardItemAction) -> Int {
    return (location.x & 0xffff) | ((location.y & 0xffff) << 16) | ((panelId & 0xff) << 32) | ((nextAction == .delete) ? (1 << 40) : 0)
  }
  
}
