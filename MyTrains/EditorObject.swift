//
//  EditorObject.swift
//  MyTrains
//
//  Created by Paul Willmott on 22/12/2021.
//

import Foundation

public class EditorObject {
  
  // Constructor
  
  init(primaryKey:Int) {
    self.primaryKey = primaryKey
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
  
}
