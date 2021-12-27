//
//  Network.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/12/2021.
//

import Foundation

public class Network : EditorObject {
  
  // Constructors
  
  init(reader:SqliteDataReader) {
    super.init(primaryKey: -1)
    decode(sqliteDataReader: reader)
  }
  
  init() {
    super.init(primaryKey: -1)
  }
  
  // Destructors
  
  deinit {
    
  }
  
  // Private properties
  
  private var _networkName : String = ""
  private var _commandStationId : Int = -1
  private var _layoutId : Int = -1
  private var  modified : Bool = false
  
  // Public properties
  
  override public func displayString() -> String {
    return networkName
  }
  
  public var networkName : String {
    get {
      return _networkName
    }
    set(value) {
      if value != _networkName {
        _networkName = value
        modified = true
      }
    }
  }
  
  public var commandStationId : Int {
    get {
      return _commandStationId
    }
    set(value) {
      if value != _commandStationId {
        _commandStationId = value
        modified = true
      }
    }
  }
  
  public var layoutId : Int {
    get {
      return _layoutId
    }
    set(value) {
      if value != _layoutId {
        _layoutId = value
        modified = true
      }
    }
  }
  
  // Database Methods
  
  private func decode(sqliteDataReader:SqliteDataReader?) {
    
    if let reader = sqliteDataReader {
      
      primaryKey = reader.getInt(index: 0)!
      
      if !reader.isDBNull(index: 1) {
        networkName = reader.getString(index: 1)!
      }
      
      if !reader.isDBNull(index: 2) {
        commandStationId = reader.getInt(index: 2)!
      }
      
      if !reader.isDBNull(index: 3) {
        layoutId = reader.getInt(index: 3)!
      }
      
    }
    
    modified = false
    
  }

  public func save() {
    
    if modified {
      
      var sql = ""
      
      if primaryKey == -1 {
        sql = "INSERT INTO [\(TABLE.NETWORK)] (" +
        "[\(NETWORK.NETWORK_ID)], " +
        "[\(NETWORK.NETWORK_NAME)], " +
        "[\(NETWORK.COMMAND_STATION_ID)], " +
        "[\(NETWORK.LAYOUT_ID)]" +
        ") VALUES (" +
        "@\(NETWORK.NETWORK_ID), " +
        "@\(NETWORK.NETWORK_NAME), " +
        "@\(NETWORK.COMMAND_STATION_ID), " +
        "@\(NETWORK.LAYOUT_ID)" +
        ")"
        primaryKey = Database.nextCode(tableName: TABLE.NETWORK, primaryKey: NETWORK.NETWORK_ID)!
      }
      else {
        sql = "UPDATE [\(TABLE.NETWORK)] SET " +
        "[\(NETWORK.NETWORK_NAME)] = @\(NETWORK.NETWORK_NAME), " +
        "[\(NETWORK.COMMAND_STATION_ID)] = @\(NETWORK.COMMAND_STATION_ID), " +
        "[\(NETWORK.LAYOUT_ID)] = @\(NETWORK.LAYOUT_ID) " +
        "WHERE [\(NETWORK.NETWORK_ID)] = @\(NETWORK.NETWORK_ID)"
      }

      let conn = Database.getConnection()
      
      let shouldClose = conn.state != .Open
       
      if shouldClose {
         _ = conn.open()
      }
       
      let cmd = conn.createCommand()
       
      cmd.commandText = sql
      
      cmd.parameters.addWithValue(key: "@\(NETWORK.NETWORK_ID)", value: primaryKey)
      cmd.parameters.addWithValue(key: "@\(NETWORK.NETWORK_NAME)", value: networkName)
      cmd.parameters.addWithValue(key: "@\(NETWORK.COMMAND_STATION_ID)", value: commandStationId)
      cmd.parameters.addWithValue(key: "@\(NETWORK.LAYOUT_ID)", value: layoutId)

      _ = cmd.executeNonQuery()

      if shouldClose {
        conn.close()
      }
      
      modified = false
      
    }

  }

  // Class Properties
  
  public static var columnNames : String {
    get {
      return
        "[\(NETWORK.NETWORK_ID)], " +
        "[\(NETWORK.NETWORK_NAME)], " +
        "[\(NETWORK.COMMAND_STATION_ID)], " +
        "[\(NETWORK.LAYOUT_ID)]"
    }
  }
  
  public static var networks : [Int:Network] {
    
    get {
    
      let conn = Database.getConnection()
      
      let shouldClose = conn.state != .Open
       
      if shouldClose {
        _ = conn.open()
      }
       
      let cmd = conn.createCommand()
       
      cmd.commandText = "SELECT \(columnNames) FROM [\(TABLE.NETWORK)] ORDER BY [\(NETWORK.NETWORK_NAME)]"

      var result : [Int:Network] = [:]
      
      if let reader = cmd.executeReader() {
           
        while reader.read() {
          let network = Network(reader: reader)
          result[network.primaryKey] = network
        }
           
        reader.close()
           
      }
      
      if shouldClose {
        conn.close()
      }

      return result
      
    }
    
  }
  
  public static func delete(primaryKey: Int) {
    let sql = "DELETE FROM [\(TABLE.NETWORK)] WHERE [\(NETWORK.NETWORK_ID)] = \(primaryKey)"
    Database.execute(commands: [sql])
  }
  
}
