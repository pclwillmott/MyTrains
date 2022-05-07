//
//  SwitchBoardPanel.swift
//  MyTrains
//
//  Created by Paul Willmott on 01/05/2022.
//

import Foundation

class SwitchBoardPanel : EditorObject {
  
  // MARK: Constructors
  
  init(reader:SqliteDataReader) {
    super.init(primaryKey: -1)
    decode(sqliteDataReader: reader)
  }
  
  init(layoutId: Int, panelId: Int, panelName: String, numberOfColumns: Int, numberOfRows: Int) {
    self.layoutId = layoutId
    self.panelId = panelId
    self.panelName = panelName
    self.numberOfColumns = numberOfColumns
    self.numberOfRows = numberOfRows
    super.init(primaryKey: -1)
  }
  
  // MARK: Public Properties
  
  public var layoutId : Int = -1 {
    didSet {
      modified = true
    }
  }
  
  public var panelId : Int = -1 {
    didSet {
      modified = true
    }
  }
  
  public var panelName : String = "" {
    didSet {
      modified = true
    }
  }
  
  public var numberOfColumns : Int = 0{
    didSet {
      modified = true
    }
  }
  
  public var numberOfRows : Int = 0{
    didSet {
      modified = true
    }
  }
  
  // MARK: Database Methods
  
  private func decode(sqliteDataReader:SqliteDataReader?) {
    
    if let reader = sqliteDataReader {
      
      primaryKey = reader.getInt(index: 0)!

      if !reader.isDBNull(index: 1) {
        layoutId = reader.getInt(index: 1)!
      }
      
      if !reader.isDBNull(index: 2) {
        panelId = reader.getInt(index: 2)!
      }

      if !reader.isDBNull(index: 3) {
        panelName = reader.getString(index: 3)!
      }
      
      if !reader.isDBNull(index: 4) {
        numberOfColumns = reader.getInt(index: 4)!
      }
      
      if !reader.isDBNull(index: 5) {
        numberOfRows = reader.getInt(index: 5)!
      }

    }
    
    modified = false
    
  }

  public func save() {
    
    if modified {
      
      var sql = ""
      
      if !Database.codeExists(tableName: TABLE.SWITCHBOARD_PANEL, primaryKey: SWITCHBOARD_PANEL.SWITCHBOARD_PANEL_ID, code: primaryKey)! {
        sql = "INSERT INTO [\(TABLE.SWITCHBOARD_PANEL)] (" +
        "[\(SWITCHBOARD_PANEL.SWITCHBOARD_PANEL_ID)], " +
        "[\(SWITCHBOARD_PANEL.LAYOUT_ID)], " +
        "[\(SWITCHBOARD_PANEL.PANEL_ID)], " +
        "[\(SWITCHBOARD_PANEL.PANEL_NAME)], " +
        "[\(SWITCHBOARD_PANEL.NUMBER_OF_COLUMNS)], " +
        "[\(SWITCHBOARD_PANEL.NUMBER_OF_ROWS)]" +
        ") VALUES (" +
        "@\(SWITCHBOARD_PANEL.SWITCHBOARD_PANEL_ID), " +
        "@\(SWITCHBOARD_PANEL.LAYOUT_ID), " +
        "@\(SWITCHBOARD_PANEL.PANEL_ID), " +
        "@\(SWITCHBOARD_PANEL.PANEL_NAME), " +
        "@\(SWITCHBOARD_PANEL.NUMBER_OF_COLUMNS), " +
        "@\(SWITCHBOARD_PANEL.NUMBER_OF_ROWS)" +
        ")"
        primaryKey = Database.nextCode(tableName: TABLE.SWITCHBOARD_PANEL, primaryKey: SWITCHBOARD_PANEL.SWITCHBOARD_PANEL_ID)!
      }
      else {
        sql = "UPDATE [\(TABLE.SWITCHBOARD_PANEL)] SET " +
        "[\(SWITCHBOARD_PANEL.LAYOUT_ID)] = @\(SWITCHBOARD_PANEL.LAYOUT_ID), " +
        "[\(SWITCHBOARD_PANEL.PANEL_ID)] = @\(SWITCHBOARD_PANEL.PANEL_ID), " +
        "[\(SWITCHBOARD_PANEL.PANEL_NAME)] = @\(SWITCHBOARD_PANEL.PANEL_NAME), " +
        "[\(SWITCHBOARD_PANEL.NUMBER_OF_COLUMNS)] = @\(SWITCHBOARD_PANEL.NUMBER_OF_COLUMNS), " +
        "[\(SWITCHBOARD_PANEL.NUMBER_OF_ROWS)] = @\(SWITCHBOARD_PANEL.NUMBER_OF_ROWS) " +
        "WHERE [\(SWITCHBOARD_PANEL.SWITCHBOARD_PANEL_ID)] = @\(SWITCHBOARD_PANEL.SWITCHBOARD_PANEL_ID)"
      }

      let conn = Database.getConnection()
      
      let shouldClose = conn.state != .Open
       
      if shouldClose {
         _ = conn.open()
      }
       
      let cmd = conn.createCommand()
       
      cmd.commandText = sql
      
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_PANEL.SWITCHBOARD_PANEL_ID)", value: primaryKey)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_PANEL.LAYOUT_ID)", value: layoutId)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_PANEL.PANEL_ID)", value: panelId)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_PANEL.PANEL_NAME)", value: panelName)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_PANEL.NUMBER_OF_COLUMNS)", value: numberOfColumns)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_PANEL.NUMBER_OF_ROWS)", value: numberOfRows)

      _ = cmd.executeNonQuery()

      if shouldClose {
        conn.close()
      }
      
      modified = false
      
    }

  }

  // MARK: Class Properties
  
  public static var columnNames : String {
    get {
      return
        "[\(SWITCHBOARD_PANEL.SWITCHBOARD_PANEL_ID)], " +
        "[\(SWITCHBOARD_PANEL.LAYOUT_ID)], " +
        "[\(SWITCHBOARD_PANEL.PANEL_ID)], " +
        "[\(SWITCHBOARD_PANEL.PANEL_NAME)], " +
        "[\(SWITCHBOARD_PANEL.NUMBER_OF_COLUMNS)], " +
        "[\(SWITCHBOARD_PANEL.NUMBER_OF_ROWS)]"
    }
  }

}
