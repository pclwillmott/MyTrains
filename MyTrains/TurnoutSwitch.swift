//
//  TurnoutSwitch.swift
//  MyTrains
//
//  Created by Paul Willmott on 31/07/2022.
//

import Foundation

public class TurnoutSwitch : EditorObject {
  
  // MARK: Constructors
  
  init(reader:SqliteDataReader) {
    super.init(primaryKey: -1)
    decode(sqliteDataReader: reader)
  }
  
  init() {
    super.init(primaryKey: -1)
  }
  
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
  
  public var comboSwitchName : String {
    get {
      if let device = locoNetDevice, let info = device.locoNetProductInfo {
        return "\(info.productName) \(device.boardId).\(channelNumber) (\(switchAddress))"
      }
      return "err"
    }
  }
  
  public var comboSortOrder : String {
    get {
      if let device = locoNetDevice, let info = device.locoNetProductInfo {
        let bid = String("000000000\(device.boardId)").suffix(8)
        let cnum = String("000000000\(channelNumber)").suffix(8)
        return "\(info.productName) \(bid).\(cnum) (\(switchAddress))"
      }
      return "err"
    }
  }
  
  public var switchAddress : Int = -1 {
    didSet {
      modified = true
    }
  }

  public var nextSwitchAddress : Int = -1 

  public var calculatedSwitchAddress : Int {
    get {
      if let device = locoNetDevice {
        let multiplier = device.sensors.count > 0 ? device.sensors.count / device.turnoutSwitches.count : 1
        return device.baseAddress + (channelNumber - 1) * multiplier
      }
      return -1
    }
  }
  
  public var state : TurnoutSwitchState = .unknown
    
  public var requiredState : TurnoutSwitchState = .unknown {
    didSet {
      if let interface = locoNetDevice?.network?.interface {
        let temp : OptionSwitchState = requiredState == .closed ? .closed : .thrown
        interface.setSwWithAck(switchNumber: switchAddress, state: temp)
      }
    }
  }
  
  // MARK: Public Methods
  
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
        switchAddress = reader.getInt(index: 3)!
      }
            
    }
    
    modified = false
    
    nextSwitchAddress = switchAddress
    
  }

  public func save() {
    
    switchAddress = nextSwitchAddress
    
    if modified {
      
      var sql = ""

      if primaryKey == -1 {
        sql = "INSERT INTO [\(TABLE.TURNOUT_SWITCH)] (" +
        "[\(TURNOUT_SWITCH.TURNOUT_SWITCH_ID)], " +
        "[\(TURNOUT_SWITCH.LOCONET_DEVICE_ID)], " +
        "[\(TURNOUT_SWITCH.CHANNEL_NUMBER)], " +
        "[\(TURNOUT_SWITCH.SWITCH_ADDRESS)]" +
        ") VALUES (" +
        "@\(TURNOUT_SWITCH.TURNOUT_SWITCH_ID), " +
        "@\(TURNOUT_SWITCH.LOCONET_DEVICE_ID), " +
        "@\(TURNOUT_SWITCH.CHANNEL_NUMBER)," +
        "@\(TURNOUT_SWITCH.SWITCH_ADDRESS)" +
        ")"
        primaryKey = Database.nextCode(tableName: TABLE.TURNOUT_SWITCH, primaryKey: TURNOUT_SWITCH.TURNOUT_SWITCH_ID)!
      }
      else {
        sql = "UPDATE [\(TABLE.TURNOUT_SWITCH)] SET " +
        "[\(TURNOUT_SWITCH.LOCONET_DEVICE_ID)] = @\(TURNOUT_SWITCH.LOCONET_DEVICE_ID), " +
        "[\(TURNOUT_SWITCH.CHANNEL_NUMBER)] = @\(TURNOUT_SWITCH.CHANNEL_NUMBER), " +
        "[\(TURNOUT_SWITCH.SWITCH_ADDRESS)] = @\(TURNOUT_SWITCH.SWITCH_ADDRESS) " +
        "WHERE [\(TURNOUT_SWITCH.TURNOUT_SWITCH_ID)] = @\(TURNOUT_SWITCH.TURNOUT_SWITCH_ID)"
      }

      let conn = Database.getConnection()
      
      let shouldClose = conn.state != .Open
       
      if shouldClose {
         _ = conn.open()
      }
       
      let cmd = conn.createCommand()
       
      cmd.commandText = sql

      cmd.parameters.addWithValue(key: "@\(TURNOUT_SWITCH.TURNOUT_SWITCH_ID)", value: primaryKey)
      cmd.parameters.addWithValue(key: "@\(TURNOUT_SWITCH.LOCONET_DEVICE_ID)", value: locoNetDeviceId)
      cmd.parameters.addWithValue(key: "@\(TURNOUT_SWITCH.CHANNEL_NUMBER)", value: channelNumber)
      cmd.parameters.addWithValue(key: "@\(TURNOUT_SWITCH.SWITCH_ADDRESS)", value: switchAddress)

      _ = cmd.executeNonQuery()

      if shouldClose {
        conn.close()
      }
      
      modified = false
      
    }

  }

  // Class Properties
  
  /*
   enum TURNOUT_SWITCH {
     static let TURNOUT_SWITCH_ID           = "TURNOUT_SWITCH_ID"
     static let LOCONET_DEVICE_ID           = "LOCONET_DEVICE_ID"
     static let CHANNEL_NUMBER              = "CHANNEL_NUMBER"
     static let SWITCH_ADDRESS              = "SWITCH_ADDRESS"
   }

   */

public static var columnNames : String {
    get {
      return
        "[\(TURNOUT_SWITCH.TURNOUT_SWITCH_ID)], " +
        "[\(TURNOUT_SWITCH.LOCONET_DEVICE_ID)], " +
        "[\(TURNOUT_SWITCH.CHANNEL_NUMBER)], " +
        "[\(TURNOUT_SWITCH.SWITCH_ADDRESS)]"
    }
  }
  
  public static func turnoutSwitches(locoNetDevice:LocoNetDevice) -> [TurnoutSwitch] {
    
    let conn = Database.getConnection()
    
    let shouldClose = conn.state != .Open
     
    if shouldClose {
      _ = conn.open()
    }
     
    let cmd = conn.createCommand()
     
    cmd.commandText = "SELECT \(columnNames) FROM [\(TABLE.TURNOUT_SWITCH)] WHERE [\(TURNOUT_SWITCH.LOCONET_DEVICE_ID)] = \(locoNetDevice.primaryKey) ORDER BY [\(TURNOUT_SWITCH.CHANNEL_NUMBER)]"

    var result : [TurnoutSwitch] = []
    
    if let reader = cmd.executeReader() {
         
      while reader.read() {
        result.append(TurnoutSwitch(reader: reader))
      }
         
      reader.close()
         
    }
    
    if shouldClose {
      conn.close()
    }

    return result

  }
  
  public static func delete(primaryKey: Int) {
    let sql = "DELETE FROM [\(TABLE.TURNOUT_SWITCH)] WHERE [\(TURNOUT_SWITCH.TURNOUT_SWITCH_ID)] = \(primaryKey)"
    Database.execute(commands: [sql])
  }
  
}
