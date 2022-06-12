//
//  Network.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/12/2021.
//

import Foundation

public class Network : EditorObject {
  
  // MARK: Constructors
  
  init(reader:SqliteDataReader) {
    super.init(primaryKey: -1)
    decode(sqliteDataReader: reader)
  }
  
  init() {
    super.init(primaryKey: -1)
  }
  
  // MARK: Public properties
  
  public var networkName : String = "" {
    didSet {
      modified = true
    }
  }
  
  public var interfaceId : Int = -1 {
    didSet {
      modified = true
    }
  }
  
  public var interface : Interface? {
    get {
      return networkController.interfaceDevices[interfaceId]
    }
  }
  
  public var layoutId : Int = -1 {
    didSet {
      modified = true
    }
  }
  
  public var locoNetId : Int = -1 {
    didSet {
      modified = true
    }
  }
  
  public var duplexGroupName : String = "" {
    didSet {
      modified = true
    }
  }
  
  public var duplexGroupPassword : String = "" {
    didSet {
      modified = true
    }
  }
  
  public var duplexGroupChannel : Int = -1 {
    didSet {
      modified = true
    }
  }
  
  public var duplexGroupId : Int = -1 {
    didSet {
      modified = true
    }
  }
  
  public var commandStationId : Int = -1 {
    didSet {
      modified = true
    }
  }
  
  public var commandStation : Interface? {
    get {
      return networkController.commandStations[commandStationId]
    }
  }
  
  // MARK: Public Methods
  
  override public func displayString() -> String {
    return networkName
  }
  
  // MARK: Database Methods

  private func decode(sqliteDataReader: SqliteDataReader?) {
  
    if let reader = sqliteDataReader {
      
      primaryKey = reader.getInt(index: 0)!
      
      if !reader.isDBNull(index: 1) {
        networkName = reader.getString(index: 1)!
      }
      
      if !reader.isDBNull(index: 2) {
        interfaceId = reader.getInt(index: 2)!
      }
      
      if !reader.isDBNull(index: 3) {
        layoutId = reader.getInt(index: 3)!
      }
      
      if !reader.isDBNull(index: 4) {
        locoNetId = reader.getInt(index: 4)!
      }
      
      if !reader.isDBNull(index: 5) {
        duplexGroupName = reader.getString(index: 5)!
      }
      
      if !reader.isDBNull(index: 6) {
        duplexGroupPassword = reader.getString(index: 6)!
      }
      
      if !reader.isDBNull(index: 7) {
        duplexGroupChannel = reader.getInt(index: 7)!
      }
      
      if !reader.isDBNull(index: 8) {
        duplexGroupId = reader.getInt(index: 8)!
      }
      
      if !reader.isDBNull(index: 9) {
        commandStationId = reader.getInt(index: 9)!
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
        "[\(NETWORK.INTERFACE_ID)], " +
        "[\(NETWORK.LAYOUT_ID)], " +
        "[\(NETWORK.LOCONET_ID)], " +
        "[\(NETWORK.DUPLEX_GROUP_NAME)], " +
        "[\(NETWORK.DUPLEX_GROUP_PASSWORD)], " +
        "[\(NETWORK.DUPLEX_GROUP_CHANNEL)], " +
        "[\(NETWORK.DUPLEX_GROUP_ID)], " +
        "[\(NETWORK.COMMAND_STATION_ID)]" +
        ") VALUES (" +
        "@\(NETWORK.NETWORK_ID), " +
        "@\(NETWORK.NETWORK_NAME), " +
        "@\(NETWORK.INTERFACE_ID), " +
        "@\(NETWORK.LAYOUT_ID)," +
        "@\(NETWORK.LOCONET_ID)," +
        "@\(NETWORK.DUPLEX_GROUP_NAME), " +
        "@\(NETWORK.DUPLEX_GROUP_PASSWORD), " +
        "@\(NETWORK.DUPLEX_GROUP_CHANNEL), " +
        "@\(NETWORK.DUPLEX_GROUP_ID), " +
        "@\(NETWORK.COMMAND_STATION_ID)" +
        ")"
        primaryKey = Database.nextCode(tableName: TABLE.NETWORK, primaryKey: NETWORK.NETWORK_ID)!
      }
      else {
        sql = "UPDATE [\(TABLE.NETWORK)] SET " +
        "[\(NETWORK.NETWORK_NAME)] = @\(NETWORK.NETWORK_NAME), " +
        "[\(NETWORK.INTERFACE_ID)] = @\(NETWORK.INTERFACE_ID), " +
        "[\(NETWORK.LAYOUT_ID)] = @\(NETWORK.LAYOUT_ID), " +
        "[\(NETWORK.LOCONET_ID)] = @\(NETWORK.LOCONET_ID), " +
        "[\(NETWORK.DUPLEX_GROUP_NAME)] = @\(NETWORK.DUPLEX_GROUP_NAME), " +
        "[\(NETWORK.DUPLEX_GROUP_PASSWORD)] = @\(NETWORK.DUPLEX_GROUP_PASSWORD), " +
        "[\(NETWORK.DUPLEX_GROUP_CHANNEL)] = @\(NETWORK.DUPLEX_GROUP_CHANNEL), " +
        "[\(NETWORK.DUPLEX_GROUP_ID)] = @\(NETWORK.DUPLEX_GROUP_ID), " +
        "[\(NETWORK.COMMAND_STATION_ID)] = @\(NETWORK.COMMAND_STATION_ID) " +
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
      cmd.parameters.addWithValue(key: "@\(NETWORK.INTERFACE_ID)", value: interfaceId)
      cmd.parameters.addWithValue(key: "@\(NETWORK.LAYOUT_ID)", value: layoutId)
      cmd.parameters.addWithValue(key: "@\(NETWORK.LOCONET_ID)", value: locoNetId)
      cmd.parameters.addWithValue(key: "@\(NETWORK.DUPLEX_GROUP_NAME)", value: duplexGroupName)
      cmd.parameters.addWithValue(key: "@\(NETWORK.DUPLEX_GROUP_PASSWORD)", value: duplexGroupPassword)
      cmd.parameters.addWithValue(key: "@\(NETWORK.DUPLEX_GROUP_CHANNEL)", value: duplexGroupChannel)
      cmd.parameters.addWithValue(key: "@\(NETWORK.DUPLEX_GROUP_ID)", value: duplexGroupId)
      cmd.parameters.addWithValue(key: "@\(NETWORK.COMMAND_STATION_ID)", value: commandStationId)

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
        "[\(NETWORK.INTERFACE_ID)], " +
        "[\(NETWORK.LAYOUT_ID)], " +
        "[\(NETWORK.LOCONET_ID)], " +
        "[\(NETWORK.DUPLEX_GROUP_NAME)], " +
        "[\(NETWORK.DUPLEX_GROUP_PASSWORD)], " +
        "[\(NETWORK.DUPLEX_GROUP_CHANNEL)], " +
        "[\(NETWORK.DUPLEX_GROUP_ID)], " +
        "[\(NETWORK.COMMAND_STATION_ID)]"
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
