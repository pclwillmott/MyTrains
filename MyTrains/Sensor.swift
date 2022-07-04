//
//  Sensor.swift
//  MyTrains
//
//  Created by Paul Willmott on 03/07/2022.
//

import Foundation

public class Sensor : EditorObject {
  
  // MARK: Constructors
  
  init(reader:SqliteDataReader) {
    super.init(primaryKey: -1)
    decode(sqliteDataReader: reader)
  }
  
  init() {
    super.init(primaryKey: -1)
  }
  
  // MARK: Public Properties
  
  public var switchBoardItemId : Int = -1 {
    didSet {
      modified = true
    }
  }

  public var nextSwitchBoardItemId : Int = -1 {
    didSet {
      modified = true
    }
  }

  public var locoNetDeviceId : Int = -1 {
    didSet {
      modified = true
    }
  }
  
  public var locoNetDevice : LocoNetDevice? {
    get {
      return networkController.locoNetDevices[locoNetDeviceId]
    }
  }
  
  public var channelNumber : Int = -1 {
    didSet {
      modified = true
    }
  }
  
  public var messageType : Int = 0 {
    didSet {
      modified = true
    }
  }
  
  public var sensorType : Int = 0 {
    didSet {
      modified = true
    }
  }
  
  public var position : Double = 0.0 {
    didSet {
      modified = true
    }
  }
  
  public var unitsPosition : UnitLength = .centimeters {
    didSet {
      modified = true
    }
  }
  
  // MARK: Database Methods
  
  private func decode(sqliteDataReader: SqliteDataReader?) {
  
    if let reader = sqliteDataReader {
      
      primaryKey = reader.getInt(index: 0)!
      
      if !reader.isDBNull(index: 1) {
        switchBoardItemId = reader.getInt(index: 1)!
      }
      
      if !reader.isDBNull(index: 2) {
        locoNetDeviceId = reader.getInt(index: 2)!
      }
      
      if !reader.isDBNull(index: 3) {
        channelNumber = reader.getInt(index: 3)!
      }
      
      if !reader.isDBNull(index: 4) {
        messageType = reader.getInt(index: 4)!
      }
      
      if !reader.isDBNull(index: 5) {
        sensorType = reader.getInt(index: 5)!
      }
      
      if !reader.isDBNull(index: 6) {
        position = reader.getDouble(index: 6)!
      }
      
      if !reader.isDBNull(index: 7) {
        unitsPosition = UnitLength(rawValue: reader.getInt(index: 7)!) ?? UnitLength.defaultValue
      }
      
    }
    
    nextSwitchBoardItemId = switchBoardItemId
    
    modified = false
    
  }

  public func save() {
    
    switchBoardItemId = nextSwitchBoardItemId
    
    if modified {
      
      var sql = ""

      /*
       enum SENSOR {
         static let SENSOR_ID                   = "SENSOR_ID"
         static let SWITCHBOARD_ITEM_ID         = "SWITCHBOARD_ITEM_ID"
         static let LOCONET_DEVICE_ID           = "LOCONET_DEVICE_ID"
         static let CHANNEL_NUMBER              = "CHANNEL_NUMBER"
         static let MESSAGE_TYPE                = "MESSAGE_TYPE"
         static let SENSOR_TYPE                 = "SENSOR_TYPE"
         static let POSITION                    = "POSITION"
         static let UNITS_POSITION              = "UNITS_POSITION"
       }

       */
      


      if primaryKey == -1 {
        sql = "INSERT INTO [\(TABLE.SENSOR)] (" +
        "[\(SENSOR.SENSOR_ID)], " +
        "[\(SENSOR.SWITCHBOARD_ITEM_ID)], " +
        "[\(SENSOR.LOCONET_DEVICE_ID)], " +
        "[\(SENSOR.CHANNEL_NUMBER)], " +
        "[\(SENSOR.MESSAGE_TYPE)], " +
        "[\(SENSOR.SENSOR_TYPE)], " +
        "[\(SENSOR.POSITION)], " +
        "[\(SENSOR.UNITS_POSITION)]" +
        ") VALUES (" +
        "@\(SENSOR.SENSOR_ID), " +
        "@\(SENSOR.SWITCHBOARD_ITEM_ID), " +
        "@\(SENSOR.LOCONET_DEVICE_ID), " +
        "@\(SENSOR.CHANNEL_NUMBER)," +
        "@\(SENSOR.MESSAGE_TYPE)," +
        "@\(SENSOR.SENSOR_TYPE), " +
        "@\(SENSOR.POSITION), " +
        "@\(SENSOR.UNITS_POSITION)" +
        ")"
        primaryKey = Database.nextCode(tableName: TABLE.SENSOR, primaryKey: SENSOR.SENSOR_ID)!
      }
      else {
        sql = "UPDATE [\(TABLE.SENSOR)] SET " +
        "[\(SENSOR.SWITCHBOARD_ITEM_ID)] = @\(SENSOR.SWITCHBOARD_ITEM_ID), " +
        "[\(SENSOR.LOCONET_DEVICE_ID)] = @\(SENSOR.LOCONET_DEVICE_ID), " +
        "[\(SENSOR.CHANNEL_NUMBER)] = @\(SENSOR.CHANNEL_NUMBER), " +
        "[\(SENSOR.MESSAGE_TYPE)] = @\(SENSOR.MESSAGE_TYPE), " +
        "[\(SENSOR.SENSOR_TYPE)] = @\(SENSOR.SENSOR_TYPE), " +
        "[\(SENSOR.POSITION)] = @\(SENSOR.POSITION), " +
        "[\(SENSOR.UNITS_POSITION)] = @\(SENSOR.UNITS_POSITION) " +
        "WHERE [\(SENSOR.SENSOR_ID)] = @\(SENSOR.SENSOR_ID)"
      }

      let conn = Database.getConnection()
      
      let shouldClose = conn.state != .Open
       
      if shouldClose {
         _ = conn.open()
      }
       
      let cmd = conn.createCommand()
       
      cmd.commandText = sql
      
      cmd.parameters.addWithValue(key: "@\(SENSOR.SENSOR_ID)", value: primaryKey)
      cmd.parameters.addWithValue(key: "@\(SENSOR.SWITCHBOARD_ITEM_ID)", value: switchBoardItemId)
      cmd.parameters.addWithValue(key: "@\(SENSOR.LOCONET_DEVICE_ID)", value: locoNetDeviceId)
      cmd.parameters.addWithValue(key: "@\(SENSOR.CHANNEL_NUMBER)", value: channelNumber)
      cmd.parameters.addWithValue(key: "@\(SENSOR.MESSAGE_TYPE)", value: messageType)
      cmd.parameters.addWithValue(key: "@\(SENSOR.SENSOR_TYPE)", value: sensorType)
      cmd.parameters.addWithValue(key: "@\(SENSOR.POSITION)", value: position)
      cmd.parameters.addWithValue(key: "@\(SENSOR.UNITS_POSITION)", value: unitsPosition.rawValue)

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
        "[\(SENSOR.SENSOR_ID)], " +
        "[\(SENSOR.SWITCHBOARD_ITEM_ID)], " +
        "[\(SENSOR.LOCONET_DEVICE_ID)], " +
        "[\(SENSOR.CHANNEL_NUMBER)], " +
        "[\(SENSOR.MESSAGE_TYPE)], " +
        "[\(SENSOR.SENSOR_TYPE)], " +
        "[\(SENSOR.POSITION)], " +
        "[\(SENSOR.UNITS_POSITION)]"
    }
  }
  
  public static func sensors(locoNetDevice:LocoNetDevice) -> [Sensor] {
    
    let conn = Database.getConnection()
    
    let shouldClose = conn.state != .Open
     
    if shouldClose {
      _ = conn.open()
    }
     
    let cmd = conn.createCommand()
     
    cmd.commandText = "SELECT \(columnNames) FROM [\(TABLE.SENSOR)] WHERE [\(SENSOR.LOCONET_DEVICE_ID)] = \(locoNetDevice.primaryKey) ORDER BY [\(SENSOR.CHANNEL_NUMBER)]"

    var result : [Sensor] = []
    
    if let reader = cmd.executeReader() {
         
      while reader.read() {
        result.append(Sensor(reader: reader))
      }
         
      reader.close()
         
    }
    
    if shouldClose {
      conn.close()
    }

    return result

  }
  
  public static func delete(primaryKey: Int) {
    let sql = "DELETE FROM [\(TABLE.SENSOR)] WHERE [\(SENSOR.SENSOR_ID)] = \(primaryKey)"
    Database.execute(commands: [sql])
  }

}
