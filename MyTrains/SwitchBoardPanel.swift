//
//  SwitchBoardPanel.swift
//  MyTrains
//
//  Created by Paul Willmott on 01/05/2022.
//

import Foundation

class SwitchBoardPanel : NSObject {
  
  // MARK: Constructors
  
  init(panelId: Int, panelName: String, numberOfColumns: Int, numberOfRows: Int) {
    self.panelId = panelId
    self.panelName = panelName
    self.numberOfColumns = numberOfColumns
    self.numberOfRows = numberOfRows
    super.init()
  }
  
  // MARK: Private Properties
  
  private var modified : Bool = false
  
  // MARK: Public Properties
  
  public var numberOfColumns : Int {
    didSet {
      modified = true
    }
  }
  
  public var numberOfRows : Int {
    didSet {
      modified = true
    }
  }
  
  public var panelName : String {
    didSet {
      modified = true
    }
  }
  
  public var panelId : Int {
    didSet {
      modified = true
    }
  }
  
  // MARK: Private Methods
  
  // MARK: Public Methods
  
}
