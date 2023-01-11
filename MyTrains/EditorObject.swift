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
  
  // MARK: Public Properties
  
  public var primaryKey : Int
  
  public var modified = false
  
  // Public Methods
  
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
