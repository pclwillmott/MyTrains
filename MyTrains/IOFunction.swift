//
//  IOFunction.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/01/2023.
//

import Foundation

public class IOFunction : EditorObject {

  // MARK: Constructors & Destructors
  
  init(ioChannel:IOChannel, ioFunctionNumber:Int) {
    self.ioChannel = ioChannel
    self.ioFunctionNumber = ioFunctionNumber
    super.init(primaryKey: -1)
  }
  
  init(ioChannel:IOChannel, reader: SqliteDataReader) {
    self.ioChannel = ioChannel
    super.init(primaryKey: -1)
    decode(sqliteDataReader: reader)
  }
  
  // MARK: Private Properties
  
  public var _address : Int = -1
  
  // MARK: Public Properties
  
  public var ioDevice : IODevice {
    get {
      return ioChannel.ioDevice
    }
  }
  
  public var ioChannel : IOChannel
  
  public var ioFunctionNumber : Int = -1
  
  public var ioFunctionType : IOFunctionType = .generalSensorReport
  
  public var sensorType : SensorType = SensorType.defaultValue {
    didSet {
      modified = true
    }
  }
  
  public var address : Int {
    get {
      return _address
    }
    set(value) {
      _address = value
      modified = true
    }
  }

  public var delayOn : Int = 0 {
    didSet {
      modified = true
    }
  }

  public var delayOff : Int = 0 {
    didSet {
      modified = true
    }
  }

  public var inverted : Bool = false {
    didSet {
      modified = true
    }
  }
  
  // MARK: Public Methods
  
  override public func displayString() -> String {
    return "\(ioDevice.boardId).\(ioChannel.ioChannelNumber).\(ioFunctionNumber)"
  }
  
  override public func sortString() -> String {
    if let info = ioDevice.locoNetProductInfo {
      let bid  = String("000000000\(ioDevice.boardId)").suffix(8)
      let cnum = String("000000000\(ioChannel.ioChannelNumber)").suffix(8)
      let fnum = String("000000000\(ioFunctionNumber)").suffix(8)
      return "\(info.productName) \(bid).\(cnum).\(fnum) (\(address))"
    }
    return "err"
  }

  public func comboSensorName() -> String {
    if let info = ioDevice.locoNetProductInfo {
      return "\(info.productName) \(ioDevice.boardId).\(ioChannel.ioChannelNumber).\(ioFunctionNumber) (\(address))"
    }
    return "err"
  }
  
  public func propertySheet() {
    
  }

  // MARK: Database Methods
  
  private func decode(sqliteDataReader: SqliteDataReader?) {
  
    if let reader = sqliteDataReader {
      
      primaryKey = reader.getInt(index: 0)!

      if !reader.isDBNull(index: 3) {
        sensorType = SensorType(rawValue: reader.getInt(index: 3)!) ?? SensorType.defaultValue
      }
      
      if !reader.isDBNull(index: 4) {
        address = reader.getInt(index: 4)!
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
      
      if !reader.isDBNull(index: 8) {
        ioFunctionNumber = reader.getInt(index: 8)!
      }
      
      if !reader.isDBNull(index: 9) {
        ioFunctionType = IOFunctionType(rawValue: reader.getInt(index: 9)!) ?? IOFunctionType.defaultValue
      }
      
    }
    
    modified = false
        
  }

  public func save() {
    
    if modified {
      
      var sql = ""

      if primaryKey == -1 {
        sql = "INSERT INTO [\(TABLE.SENSOR)] (" +
        "[\(SENSOR.SENSOR_ID)], " +
        "[\(SENSOR.LOCONET_DEVICE_ID)], " +
        "[\(SENSOR.CHANNEL_NUMBER)], " +
        "[\(SENSOR.SENSOR_TYPE)], " +
        "[\(SENSOR.SENSOR_ADDRESS)], " +
        "[\(SENSOR.DELAY_ON)], " +
        "[\(SENSOR.DELAY_OFF)], " +
        "[\(SENSOR.INVERTED)], " +
        "[\(SENSOR.FUNCTION_NUMBER)], " +
        "[\(SENSOR.FUNCTION_TYPE)]" +
        ") VALUES (" +
        "@\(SENSOR.SENSOR_ID), " +
        "@\(SENSOR.LOCONET_DEVICE_ID), " +
        "@\(SENSOR.CHANNEL_NUMBER)," +
        "@\(SENSOR.SENSOR_TYPE), " +
        "@\(SENSOR.SENSOR_ADDRESS), " +
        "@\(SENSOR.DELAY_ON), " +
        "@\(SENSOR.DELAY_OFF), " +
        "@\(SENSOR.INVERTED)," +
        "@\(SENSOR.FUNCTION_NUMBER)," +
        "@\(SENSOR.FUNCTION_TYPE)" +
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
        "[\(SENSOR.INVERTED)] = @\(SENSOR.INVERTED), " +
        "[\(SENSOR.FUNCTION_NUMBER)] = @\(SENSOR.FUNCTION_NUMBER), " +
        "[\(SENSOR.FUNCTION_TYPE)] = @\(SENSOR.FUNCTION_TYPE) " +
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
      cmd.parameters.addWithValue(key: "@\(SENSOR.LOCONET_DEVICE_ID)", value: ioDevice.primaryKey)
      cmd.parameters.addWithValue(key: "@\(SENSOR.CHANNEL_NUMBER)", value: ioChannel.ioChannelNumber)
      cmd.parameters.addWithValue(key: "@\(SENSOR.SENSOR_TYPE)", value: sensorType.rawValue)
      cmd.parameters.addWithValue(key: "@\(SENSOR.SENSOR_ADDRESS)", value: address)
      cmd.parameters.addWithValue(key: "@\(SENSOR.DELAY_ON)", value: delayOn)
      cmd.parameters.addWithValue(key: "@\(SENSOR.DELAY_OFF)", value: delayOff)
      cmd.parameters.addWithValue(key: "@\(SENSOR.INVERTED)", value: inverted)
      cmd.parameters.addWithValue(key: "@\(SENSOR.FUNCTION_NUMBER)", value: ioFunctionNumber)
      cmd.parameters.addWithValue(key: "@\(SENSOR.FUNCTION_TYPE)", value: ioFunctionType.rawValue)

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
        "[\(SENSOR.INVERTED)], " +
        "[\(SENSOR.FUNCTION_NUMBER)], " +
        "[\(SENSOR.FUNCTION_TYPE)]"
    }
  }
  
  public static func functions(ioChannel:IOChannel) -> [IOFunction] {
    
    let conn = Database.getConnection()
    
    let shouldClose = conn.state != .Open
     
    if shouldClose {
      _ = conn.open()
    }
     
    let cmd = conn.createCommand()
     
    cmd.commandText = "SELECT \(columnNames) FROM [\(TABLE.SENSOR)] WHERE [\(SENSOR.LOCONET_DEVICE_ID)] = \(ioChannel.ioDevice.primaryKey) AND [\(SENSOR.CHANNEL_NUMBER)] = \(ioChannel.ioChannelNumber) ORDER BY [\(SENSOR.CHANNEL_NUMBER)], [\(SENSOR.FUNCTION_NUMBER)]"

    var result : [IOFunction] = []
    
    if let reader = cmd.executeReader() {
         
      while reader.read() {
        
        var ioFunction = IOFunction(ioChannel: ioChannel, reader: reader)
        
        switch ioChannel.ioDevice.locoNetProductId {
          
        case .DS64:
          
          ioFunction = ioFunction.ioChannel.ioChannelNumber < 9 ? IOFunctionDS64Input(ioChannel: ioChannel, reader: reader) : IOFunctionDS64Output(ioChannel: ioChannel, reader: reader)
         
        case .BXP88:
          
          ioFunction = IOFunctionBXP88Input(ioChannel: ioChannel, reader: reader) 
 
        case .TowerControllerMarkII:
          
          ioFunction = IOFunctionTC54MkII(ioChannel: ioChannel, reader: reader)
          
        default:
          break
        }
        
        result.append(ioFunction)

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
