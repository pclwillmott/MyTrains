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
  
  // MARK: Private Properties
  
  private var _sensorAddress : Int = -1
  
  // MARK: Public Properties
  
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
  
  public var displayChannelNumber : String {
    get {
      if let device = locoNetDevice {
        return "\(device.boardId).\(channelNumber)"
      }
      return "err"
    }
  }
  
  public var sensorType : SensorType = SensorType.defaultValue {
    didSet {
      modified = true
    }
  }
  
  public var nextSensorType : SensorType = SensorType.defaultValue
  
  public var sensorAddress : Int {
    get {
      return _sensorAddress
    }
    set(value) {
      _sensorAddress = value
      modified = true
    }
  }

  public var nextSensorAddress : Int = -1

  public var calculatedSensorAddress : Int {
    get {
      if let device = locoNetDevice {
        return device.baseAddress + channelNumber - 1
      }
      return -1
    }
  }
  
  public var comboSensorName : String {
    get {
      if let device = locoNetDevice, let info = device.locoNetProductInfo {
        return "\(info.productName) \(device.boardId).\(channelNumber) (\(sensorAddress))"
      }
      return "err"
    }
  }
  
  public var comboSortOrder : String {
    get {
      if let device = locoNetDevice, let info = device.locoNetProductInfo {
        let bid = String("000000000\(device.boardId)").suffix(8)
        let cnum = String("000000000\(channelNumber)").suffix(8)
        return "\(info.productName) \(bid).\(cnum) (\(sensorAddress))"
      }
      return "err"
    }
  }

  public var delayOn : Int = 0 {
    didSet {
      modified = true
    }
  }

  public var nextDelayOn : Int = 0

  public var delayOff : Int = 0 {
    didSet {
      modified = true
    }
  }

  public var nextDelayOff : Int = 0

  public var inverted : Bool = false {
    didSet {
      modified = true
    }
  }
  
  public var nextInverted : Bool = false

  // MARK: Database Methods
  
  private func decode(sqliteDataReader: SqliteDataReader?) {
  
    if let reader = sqliteDataReader {
      
      primaryKey = reader.getInt(index: 0)!

      if !reader.isDBNull(index: 1) {
        locoNetDeviceId = reader.getInt(index: 1)!
      }
      
      if !reader.isDBNull(index: 2) {
        channelNumber = reader.getInt(index: 2)!
      }
      
      if !reader.isDBNull(index: 3) {
        sensorType = SensorType(rawValue: reader.getInt(index: 3)!) ?? SensorType.defaultValue
      }
      
      if !reader.isDBNull(index: 4) {
        sensorAddress = reader.getInt(index: 4)!
      }
      
      if !reader.isDBNull(index: 5) {
        delayOn = reader.getInt(index: 5)!
      }
      
      if !reader.isDBNull(index: 6) {
        delayOff = reader.getInt(index: 6)!
      }
      
      if !reader.isDBNull(index: 7) {
        inverted = reader.getBool(index: 7)!
      }
      
    }
        
    modified = false
    
    nextSensorType = sensorType
    nextSensorAddress = sensorAddress
    nextInverted = inverted
    nextDelayOn = delayOn
    nextDelayOff = delayOff
    
  }

  public func save() {
    
    sensorType = nextSensorType
    sensorAddress = nextSensorAddress
    inverted = nextInverted
    delayOn = nextDelayOn
    delayOff = nextDelayOff
    
    if modified {
      
      var sql = ""

      /*
       enum SENSOR {
         static let SENSOR_ID                   = "SENSOR_ID"
         static let LOCONET_DEVICE_ID           = "LOCONET_DEVICE_ID"
         static let CHANNEL_NUMBER              = "CHANNEL_NUMBER"
         static let SENSOR_TYPE                 = "SENSOR_TYPE"
         static let SENSOR_ADDRESS              = "SENSOR_ADDRESS"
         static let DELAY_ON                    = "DELAY_ON"
         static let DELAY_OFF                   = "DELAY_OFF"
         static let INVERTED                    = "INVERTED"
       }
       */

      if primaryKey == -1 {
        sql = "INSERT INTO [\(TABLE.SENSOR)] (" +
        "[\(SENSOR.SENSOR_ID)], " +
        "[\(SENSOR.LOCONET_DEVICE_ID)], " +
        "[\(SENSOR.CHANNEL_NUMBER)], " +
        "[\(SENSOR.SENSOR_TYPE)], " +
        "[\(SENSOR.SENSOR_ADDRESS)], " +
        "[\(SENSOR.DELAY_ON)], " +
        "[\(SENSOR.DELAY_OFF)], " +
        "[\(SENSOR.INVERTED)]" +
        ") VALUES (" +
        "@\(SENSOR.SENSOR_ID), " +
        "@\(SENSOR.LOCONET_DEVICE_ID), " +
        "@\(SENSOR.CHANNEL_NUMBER)," +
        "@\(SENSOR.SENSOR_TYPE), " +
        "@\(SENSOR.SENSOR_ADDRESS), " +
        "@\(SENSOR.DELAY_ON), " +
        "@\(SENSOR.DELAY_OFF), " +
        "@\(SENSOR.INVERTED)" +
        ")"
        primaryKey = Database.nextCode(tableName: TABLE.SENSOR, primaryKey: SENSOR.SENSOR_ID)!
      }
      else {
        sql = "UPDATE [\(TABLE.SENSOR)] SET " +
        "[\(SENSOR.LOCONET_DEVICE_ID)] = @\(SENSOR.LOCONET_DEVICE_ID), " +
        "[\(SENSOR.CHANNEL_NUMBER)] = @\(SENSOR.CHANNEL_NUMBER), " +
        "[\(SENSOR.SENSOR_TYPE)] = @\(SENSOR.SENSOR_TYPE), " +
        "[\(SENSOR.SENSOR_ADDRESS)] = @\(SENSOR.SENSOR_ADDRESS), " +
        "[\(SENSOR.DELAY_ON)] = @\(SENSOR.DELAY_ON), " +
        "[\(SENSOR.DELAY_OFF)] = @\(SENSOR.DELAY_OFF), " +
        "[\(SENSOR.INVERTED)] = @\(SENSOR.INVERTED) " +
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
      cmd.parameters.addWithValue(key: "@\(SENSOR.LOCONET_DEVICE_ID)", value: locoNetDeviceId)
      cmd.parameters.addWithValue(key: "@\(SENSOR.CHANNEL_NUMBER)", value: channelNumber)
      cmd.parameters.addWithValue(key: "@\(SENSOR.SENSOR_TYPE)", value: sensorType.rawValue)
      cmd.parameters.addWithValue(key: "@\(SENSOR.SENSOR_ADDRESS)", value: sensorAddress)
      cmd.parameters.addWithValue(key: "@\(SENSOR.DELAY_ON)", value: delayOn)
      cmd.parameters.addWithValue(key: "@\(SENSOR.DELAY_OFF)", value: delayOff)
      cmd.parameters.addWithValue(key: "@\(SENSOR.INVERTED)", value: inverted)

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
        "[\(SENSOR.SENSOR_ID)], " +
        "[\(SENSOR.LOCONET_DEVICE_ID)], " +
        "[\(SENSOR.CHANNEL_NUMBER)], " +
        "[\(SENSOR.SENSOR_TYPE)], " +
        "[\(SENSOR.SENSOR_ADDRESS)], " +
        "[\(SENSOR.DELAY_ON)], " +
        "[\(SENSOR.DELAY_OFF)], " +
        "[\(SENSOR.INVERTED)]"
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
