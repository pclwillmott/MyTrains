//
//  LocoNetDevice.swift
//  MyTrains
//
//  Created by Paul Willmott on 05/05/2022.
//

import Foundation

public class LocoNetDevice : EditorObject {
  
  // MARK: Constructors

  init(reader:SqliteDataReader) {
    super.init(primaryKey: -1)
    decode(sqliteDataReader: reader)
  }

  override init(primaryKey:Int) {
    super.init(primaryKey: primaryKey)
  }

  // MARK: Public Properties
  
  public var optionSwitches : [OptionSwitch] {
    get {
      var result : [OptionSwitch] = []
      for opSwDef in OptionSwitch.switches(locoNetProductId: locoNetProductId) {
        let opSw = OptionSwitch(locoNetDevice: self, switchNumber: opSwDef.switchNumber, switchDefinition: opSwDef)
        result.append(opSw)
      }
      result.sort {$0.switchNumber < $1.switchNumber}
      return result
    }
  }
  
  public var networkId : Int = -1 {
    didSet {
      modified = true
    }
  }
  
  public var network : Network? {
    get {
      return networkController.networks[networkId]
    }
  }
  
  public var serialNumber : Int = 0 {
    didSet {
      modified = true
    }
  }
  
  public var softwareVersion : Double = 0.0 {
    didSet {
      modified = true
    }
  }
  
  public var hardwareVersion : Double = 0.0 {
    didSet {
      modified = true
    }
  }
  
  public var boardId : Int = -1 {
    didSet {
      modified = true
    }
  }
  
  public var locoNetProductId : LocoNetProductId = .UNKNOWN {
    didSet {
      modified = true
    }
  }
  
  public var locoNetProductInfo : LocoNetProduct? {
    get {
      return LocoNetProducts.product(id: locoNetProductId)
    }
  }
  
  public var optionSwitches0 : Int64 = 0 {
    didSet {
      modified = true
    }
  }
  
  public var optionSwitches1 : Int64 = 0 {
    didSet {
      modified = true
    }
  }
  
  public var optionSwitches2 : Int64 = 0 {
    didSet {
      modified = true
    }
  }
  
  public var optionSwitches3 : Int64 = 0 {
    didSet {
      modified = true
    }
  }
  
  public var devicePath : String = "" {
    didSet {
      modified = true
    }
  }
  
  public var baudRate : BaudRate = .br230400 {
    didSet {
      modified = true
    }
  }

  public var deviceName : String = "" {
    didSet {
      modified = true
    }
  }
  
  public var flowControl : FlowControl = .noFlowControl {
    didSet {
      modified = true
    }
  }
  
  public var isStandAloneLoconet : Bool = false {
    didSet {
      modified = true
    }
  }
  
  public var isSensorDevice : Bool {
    get {
      if let info = locoNetProductInfo {
        return !info.attributes.intersection([.PowerManager, .Transponding, .OccupancyDetector]).isEmpty
      }
      return false
    }
  }
  
  public var flags : Int64 = 0 {
    didSet {
      modified = true
    }
  }
  
  public var iplName : String {
    get {
      if let info = locoNetProductInfo {
        var name = "Digitrax \(info.productName) SN: #\(serialNumber)"
        if !info.attributes.intersection([.OccupancyDetector, .PowerManager, .Transponding]).isEmpty {
          name += " BID: \(boardId)"
        }
        return name
      }
      return ""
    }
  }
  
  // MARK: Public Methods
  
  override public func displayString() -> String {
    return deviceName == "" ? "unnamed device" : deviceName
  }
  
// MARK: Database Methods
  
  private func decode(sqliteDataReader:SqliteDataReader?) {
    
    if let reader = sqliteDataReader {
      
      primaryKey = reader.getInt(index: 0)!

      if !reader.isDBNull(index: 1) {
        networkId = reader.getInt(index: 1)!
      }
      
      if !reader.isDBNull(index: 2) {
        serialNumber = reader.getInt(index: 2)!
      }

      if !reader.isDBNull(index: 3) {
        softwareVersion = reader.getDouble(index: 3)!
      }
      
      if !reader.isDBNull(index: 4) {
        hardwareVersion = reader.getDouble(index: 4)!
      }
      
      if !reader.isDBNull(index: 5) {
        boardId = reader.getInt(index: 5)!
      }

      if !reader.isDBNull(index: 6) {
        locoNetProductId = LocoNetProductId(rawValue: reader.getInt(index: 6)!) ?? .UNKNOWN
      }
      
      if !reader.isDBNull(index: 7) {
        optionSwitches0 = reader.getInt64(index: 7)!
      }
      
      if !reader.isDBNull(index: 8) {
        optionSwitches1 = reader.getInt64(index: 8)!
      }
      
      if !reader.isDBNull(index: 9) {
        optionSwitches2 = reader.getInt64(index: 9)!
      }
      
      if !reader.isDBNull(index: 10) {
        optionSwitches3 = reader.getInt64(index: 10)!
      }
      
      if !reader.isDBNull(index: 11) {
        devicePath = reader.getString(index: 11)!
      }

      if !reader.isDBNull(index: 12) {
        baudRate = BaudRate(rawValue: reader.getInt(index: 12)!) ?? .br57600
      }

      if !reader.isDBNull(index: 13) {
        deviceName = reader.getString(index: 13)!
      }

      if !reader.isDBNull(index: 14) {
        flowControl = FlowControl(rawValue: reader.getInt(index: 14)!) ?? .noFlowControl
      }

      if !reader.isDBNull(index: 15) {
        isStandAloneLoconet = reader.getBool(index: 15)!
      }

      if !reader.isDBNull(index: 16) {
        flags = reader.getInt64(index: 16)!
      }

    }
    
    modified = false
    
  }

  public func save() {
    
    if modified {
      
      var sql = ""
      
      if !Database.codeExists(tableName: TABLE.LOCONET_DEVICE, primaryKey: LOCONET_DEVICE.LOCONET_DEVICE_ID, code: primaryKey)! {
        sql = "INSERT INTO [\(TABLE.LOCONET_DEVICE)] (" +
        "[\(LOCONET_DEVICE.LOCONET_DEVICE_ID)], " +
        "[\(LOCONET_DEVICE.NETWORK_ID)], " +
        "[\(LOCONET_DEVICE.SERIAL_NUMBER)], " +
        "[\(LOCONET_DEVICE.SOFTWARE_VERSION)], " +
        "[\(LOCONET_DEVICE.HARDWARE_VERSION)], " +
        "[\(LOCONET_DEVICE.BOARD_ID)], " +
        "[\(LOCONET_DEVICE.LOCONET_PRODUCT_ID)], " +
        "[\(LOCONET_DEVICE.OPTION_SWITCHES_0)], " +
        "[\(LOCONET_DEVICE.OPTION_SWITCHES_1)], " +
        "[\(LOCONET_DEVICE.OPTION_SWITCHES_2)], " +
        "[\(LOCONET_DEVICE.OPTION_SWITCHES_3)], " +
        "[\(LOCONET_DEVICE.DEVICE_PATH)], " +
        "[\(LOCONET_DEVICE.BAUD_RATE)], " +
        "[\(LOCONET_DEVICE.DEVICE_NAME)], " +
        "[\(LOCONET_DEVICE.FLOW_CONTROL)], " +
        "[\(LOCONET_DEVICE.IS_STAND_ALONE_LOCONET)], " +
        "[\(LOCONET_DEVICE.FLAGS)]" +
        ") VALUES (" +
        "@\(LOCONET_DEVICE.LOCONET_DEVICE_ID), " +
        "@\(LOCONET_DEVICE.NETWORK_ID), " +
        "@\(LOCONET_DEVICE.SERIAL_NUMBER), " +
        "@\(LOCONET_DEVICE.SOFTWARE_VERSION), " +
        "@\(LOCONET_DEVICE.HARDWARE_VERSION), " +
        "@\(LOCONET_DEVICE.BOARD_ID), " +
        "@\(LOCONET_DEVICE.LOCONET_PRODUCT_ID), " +
        "@\(LOCONET_DEVICE.OPTION_SWITCHES_0), " +
        "@\(LOCONET_DEVICE.OPTION_SWITCHES_1), " +
        "@\(LOCONET_DEVICE.OPTION_SWITCHES_2), " +
        "@\(LOCONET_DEVICE.OPTION_SWITCHES_3), " +
        "@\(LOCONET_DEVICE.DEVICE_PATH), " +
        "@\(LOCONET_DEVICE.BAUD_RATE), " +
        "@\(LOCONET_DEVICE.DEVICE_NAME), " +
        "@\(LOCONET_DEVICE.FLOW_CONTROL), " +
        "@\(LOCONET_DEVICE.IS_STAND_ALONE_LOCONET), " +
        "@\(LOCONET_DEVICE.FLAGS)" +
        ")"
        primaryKey = Database.nextCode(tableName: TABLE.LOCONET_DEVICE, primaryKey: LOCONET_DEVICE.LOCONET_DEVICE_ID)!
      }
      else {
        sql = "UPDATE [\(TABLE.LOCONET_DEVICE)] SET " +
        "[\(LOCONET_DEVICE.NETWORK_ID)] = @\(LOCONET_DEVICE.NETWORK_ID), " +
        "[\(LOCONET_DEVICE.SERIAL_NUMBER)] = @\(LOCONET_DEVICE.SERIAL_NUMBER), " +
        "[\(LOCONET_DEVICE.SOFTWARE_VERSION)] = @\(LOCONET_DEVICE.SOFTWARE_VERSION), " +
        "[\(LOCONET_DEVICE.HARDWARE_VERSION)] = @\(LOCONET_DEVICE.HARDWARE_VERSION), " +
        "[\(LOCONET_DEVICE.BOARD_ID)] = @\(LOCONET_DEVICE.BOARD_ID), " +
        "[\(LOCONET_DEVICE.LOCONET_PRODUCT_ID)] = @\(LOCONET_DEVICE.LOCONET_PRODUCT_ID), " +
        "[\(LOCONET_DEVICE.OPTION_SWITCHES_0)] = @\(LOCONET_DEVICE.OPTION_SWITCHES_0), " +
        "[\(LOCONET_DEVICE.OPTION_SWITCHES_1)] = @\(LOCONET_DEVICE.OPTION_SWITCHES_1), " +
        "[\(LOCONET_DEVICE.OPTION_SWITCHES_2)] = @\(LOCONET_DEVICE.OPTION_SWITCHES_2), " +
        "[\(LOCONET_DEVICE.OPTION_SWITCHES_3)] = @\(LOCONET_DEVICE.OPTION_SWITCHES_3), " +
        "[\(LOCONET_DEVICE.DEVICE_PATH)] = @\(LOCONET_DEVICE.DEVICE_PATH), " +
        "[\(LOCONET_DEVICE.BAUD_RATE)] = @\(LOCONET_DEVICE.BAUD_RATE), " +
        "[\(LOCONET_DEVICE.DEVICE_NAME)] = @\(LOCONET_DEVICE.DEVICE_NAME), " +
        "[\(LOCONET_DEVICE.FLOW_CONTROL)] = @\(LOCONET_DEVICE.FLOW_CONTROL), " +
        "[\(LOCONET_DEVICE.IS_STAND_ALONE_LOCONET)] = @\(LOCONET_DEVICE.IS_STAND_ALONE_LOCONET), " +
        "[\(LOCONET_DEVICE.FLAGS)] = @\(LOCONET_DEVICE.FLAGS) " +
        "WHERE [\(LOCONET_DEVICE.LOCONET_DEVICE_ID)] = @\(LOCONET_DEVICE.LOCONET_DEVICE_ID)"
      }

      let conn = Database.getConnection()
      
      let shouldClose = conn.state != .Open
       
      if shouldClose {
         _ = conn.open()
      }
       
      let cmd = conn.createCommand()
       
      cmd.commandText = sql
      
      cmd.parameters.addWithValue(key: "@\(LOCONET_DEVICE.LOCONET_DEVICE_ID)", value: primaryKey)
      cmd.parameters.addWithValue(key: "@\(LOCONET_DEVICE.NETWORK_ID)", value: networkId)
      cmd.parameters.addWithValue(key: "@\(LOCONET_DEVICE.SERIAL_NUMBER)", value: serialNumber)
      cmd.parameters.addWithValue(key: "@\(LOCONET_DEVICE.SOFTWARE_VERSION)", value: softwareVersion)
      cmd.parameters.addWithValue(key: "@\(LOCONET_DEVICE.HARDWARE_VERSION)", value: hardwareVersion)
      cmd.parameters.addWithValue(key: "@\(LOCONET_DEVICE.BOARD_ID)", value: boardId)
      cmd.parameters.addWithValue(key: "@\(LOCONET_DEVICE.LOCONET_PRODUCT_ID)", value: locoNetProductId.rawValue)
      cmd.parameters.addWithValue(key: "@\(LOCONET_DEVICE.OPTION_SWITCHES_0)", value: optionSwitches0)
      cmd.parameters.addWithValue(key: "@\(LOCONET_DEVICE.OPTION_SWITCHES_1)", value: optionSwitches1)
      cmd.parameters.addWithValue(key: "@\(LOCONET_DEVICE.OPTION_SWITCHES_2)", value: optionSwitches2)
      cmd.parameters.addWithValue(key: "@\(LOCONET_DEVICE.OPTION_SWITCHES_3)", value: optionSwitches3)
      cmd.parameters.addWithValue(key: "@\(LOCONET_DEVICE.DEVICE_PATH)", value: devicePath)
      cmd.parameters.addWithValue(key: "@\(LOCONET_DEVICE.BAUD_RATE)", value: baudRate.rawValue)
      cmd.parameters.addWithValue(key: "@\(LOCONET_DEVICE.DEVICE_NAME)", value: deviceName)
      cmd.parameters.addWithValue(key: "@\(LOCONET_DEVICE.FLOW_CONTROL)", value: flowControl.rawValue)
      cmd.parameters.addWithValue(key: "@\(LOCONET_DEVICE.IS_STAND_ALONE_LOCONET)", value: isStandAloneLoconet)
      cmd.parameters.addWithValue(key: "@\(LOCONET_DEVICE.FLAGS)", value: flags)

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
      let names =
      "[\(LOCONET_DEVICE.LOCONET_DEVICE_ID)], " +
      "[\(LOCONET_DEVICE.NETWORK_ID)], " +
      "[\(LOCONET_DEVICE.SERIAL_NUMBER)], " +
      "[\(LOCONET_DEVICE.SOFTWARE_VERSION)], " +
      "[\(LOCONET_DEVICE.HARDWARE_VERSION)], " +
      "[\(LOCONET_DEVICE.BOARD_ID)], " +
      "[\(LOCONET_DEVICE.LOCONET_PRODUCT_ID)], " +
      "[\(LOCONET_DEVICE.OPTION_SWITCHES_0)], " +
      "[\(LOCONET_DEVICE.OPTION_SWITCHES_1)], " +
      "[\(LOCONET_DEVICE.OPTION_SWITCHES_2)], " +
      "[\(LOCONET_DEVICE.OPTION_SWITCHES_3)], " +
      "[\(LOCONET_DEVICE.DEVICE_PATH)], " +
      "[\(LOCONET_DEVICE.BAUD_RATE)], " +
      "[\(LOCONET_DEVICE.DEVICE_NAME)], " +
      "[\(LOCONET_DEVICE.FLOW_CONTROL)], " +
      "[\(LOCONET_DEVICE.IS_STAND_ALONE_LOCONET)], " +
      "[\(LOCONET_DEVICE.FLAGS)]"
      return names
    }
  }

  public static var locoNetDevices : [Int:LocoNetDevice] {
    
    get {
    
      let conn = Database.getConnection()
      
      let shouldClose = conn.state != .Open
       
      if shouldClose {
        _ = conn.open()
      }
       
      let cmd = conn.createCommand()
       
      cmd.commandText = "SELECT \(columnNames) FROM [\(TABLE.LOCONET_DEVICE)] ORDER BY [\(LOCONET_DEVICE.LOCONET_DEVICE_ID)]"

      var result : [Int:LocoNetDevice] = [:]
      
      if let reader = cmd.executeReader() {
           
        while reader.read() {
          let device = LocoNetDevice(reader: reader)
          if let info = device.locoNetProductInfo {
            if info.attributes.intersection([.CommandStation, .ComputerInterface]).isEmpty {
              result[device.primaryKey] = device
            }
            else {
              result[device.primaryKey] = Interface(reader: reader)
            }
          }
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
    let sql = "DELETE FROM [\(TABLE.LOCONET_DEVICE)] WHERE [\(LOCONET_DEVICE.LOCONET_DEVICE_ID)] = \(primaryKey)"
    Database.execute(commands: [sql])
  }
  
}
