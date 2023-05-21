//
//  ComboBoxDictEntry.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/05/2023.
//

import Foundation

public class ComboBoxDictEntry : EditorObject {
  
  // MARK: Public Properties
  
  public var title : String = ""
  
  public override func displayString() -> String {
    return title
  }
  
  public override func sortString() -> String {
    return title
  }
  
}
