//
//  EditorObject.swift
//  MyTrains
//
//  Created by Paul Willmott on 22/12/2021.
//

import Foundation

public class EditorObject : NSObject {
  
  // Constructor
  
  init(primaryKey:Int) {
    self.primaryKey = primaryKey
    super.init()
  }
  
  // Public Properties
  
  public var primaryKey : Int
  
  // Public Methods
  
  public func sortString() -> String {
    return displayString()
  }
  
  public func displayString() -> String {
    return ""
  }
  
  public func deleteCheck() -> String {
    return "Are you sure you want to delete \"\(displayString())\"?"
  }
  
}
