//
//  EditorObject.swift
//  MyTrains
//
//  Created by Paul Willmott on 22/12/2021.
//

import Foundation

public class EditorObject : NSObject {
  
  // MARK: Constructor
  
  init(primaryKey:Int) {
    self.primaryKey = primaryKey
    super.init()
  }
  
  // MARK: Private Properties
  
  internal var _modified : Bool = false
  
  // MARK: Public Properties
  
  public var primaryKey : Int
  
  public var modified : Bool {
    get {
      return _modified || primaryKey == -1
    }
    set(value) {
      _modified = value
    }
  }
  
  // MARK: Public Methods
  
  public func displayString() -> String {
    return ""
  }
  
  public func sortString() -> String {
    return displayString()
  }
  
  public func deleteCheck() -> String {
    return "Are you sure you want to delete \"\(displayString())\"?"
  }
  
}
