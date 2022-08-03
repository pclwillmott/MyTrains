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
  
  public var dictionaryKey : Int {
    get {
      return TurnoutSwitch.dictionaryKey(switchBoardItemId: switchBoardItemId, turnoutIndex: turnoutIndex)
    }
  }
  
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
  
  public var switchAddress : Int {
    get {
      if let device = locoNetDevice {
        return device.baseAddress + (channelNumber - 1) * 2
      }
      return 0
    }
  }
  
  public var turnoutIndex : Int = 1 {
    didSet {
      modified = true
    }
  }
  
  public var nextTurnoutIndex : Int = 1 {
    didSet {
      modified = true
    }
  }
  
  public var switchType : Int = 0 {
    didSet {
      modified = true
    }
  }
  
  public var feedbackType : TurnoutFeedbackType = TurnoutFeedbackType.defaultValue {
    didSet {
      modified = true
    }
  }
  
  public var nextFeedbackType : TurnoutFeedbackType = TurnoutFeedbackType.defaultValue {
    didSet {
      modified = true
    }
  }
  
  public var state : TurnoutSwitchState = .unknown
    
  public var requiredState : TurnoutSwitchState = .unknown
  
  // MARK: Public Methods
  
  public func setState(state:TurnoutSwitchState) {
    requiredState = state
    if let interface = locoNetDevice?.network?.interface {
      let temp : OptionSwitchState = requiredState == .closed ? .closed : .thrown
      interface.setSwWithAck(switchNumber: switchAddress, state: temp)
      self.state = requiredState
    }
  }
  public func setClosed() {
    setState(state: .closed)
  }
  
  public func setThrown() {
    setState(state: .thrown)
  }

  public func toggle() {
    setState(state: state == .closed ? .thrown : .closed)
  }

  // MARK: Database Methods
  
  private func decode(sqliteDataReader: SqliteDataReader?) {

    if let reader = sqliteDataReader {
      
      primaryKey = reader.getInt(index: 0)!
      
      if !reader.isDBNull(index: 1) {
        locoNetDeviceId = reader.getInt(index: 1)!
      }
      
      if !reader.isDBNull(index: 2) {
        switchBoardItemId = reader.getInt(index: 2)!
      }
      
      if !reader.isDBNull(index: 3) {
        turnoutIndex = reader.getInt(index: 3)!
      }
      
      if !reader.isDBNull(index: 4) {
        channelNumber = reader.getInt(index: 4)!
      }
      
      if !reader.isDBNull(index: 5) {
        feedbackType = TurnoutFeedbackType(rawValue: reader.getInt(index: 5)!) ?? TurnoutFeedbackType.defaultValue
      }
      
      if !reader.isDBNull(index: 6) {
        switchType = reader.getInt(index: 6)!
      }
            
    }
    
    nextSwitchBoardItemId = switchBoardItemId
    nextTurnoutIndex = turnoutIndex
    nextFeedbackType = feedbackType
    
    modified = false
    
  }

  public func save() {
    
    switchBoardItemId = nextSwitchBoardItemId
    turnoutIndex = nextTurnoutIndex
    feedbackType = nextFeedbackType
    
    if modified {
      
      var sql = ""

      if primaryKey == -1 {
        sql = "INSERT INTO [\(TABLE.TURNOUT_SWITCH)] (" +
        "[\(TURNOUT_SWITCH.TURNOUT_SWITCH_ID)], " +
        "[\(TURNOUT_SWITCH.LOCONET_DEVICE_ID)], " +
        "[\(TURNOUT_SWITCH.SWITCHBOARD_ITEM_ID)], " +
        "[\(TURNOUT_SWITCH.TURNOUT_INDEX)], " +
        "[\(TURNOUT_SWITCH.CHANNEL_NUMBER)], " +
        "[\(TURNOUT_SWITCH.FEEDBACK_TYPE)], " +
        "[\(TURNOUT_SWITCH.SWITCH_TYPE)]" +
        ") VALUES (" +
        "@\(TURNOUT_SWITCH.TURNOUT_SWITCH_ID), " +
        "@\(TURNOUT_SWITCH.LOCONET_DEVICE_ID), " +
        "@\(TURNOUT_SWITCH.SWITCHBOARD_ITEM_ID), " +
        "@\(TURNOUT_SWITCH.TURNOUT_INDEX)," +
        "@\(TURNOUT_SWITCH.CHANNEL_NUMBER)," +
        "@\(TURNOUT_SWITCH.FEEDBACK_TYPE), " +
        "@\(TURNOUT_SWITCH.SWITCH_TYPE)" +
        ")"
        primaryKey = Database.nextCode(tableName: TABLE.TURNOUT_SWITCH, primaryKey: TURNOUT_SWITCH.TURNOUT_SWITCH_ID)!
      }
      else {
        sql = "UPDATE [\(TABLE.TURNOUT_SWITCH)] SET " +
        "[\(TURNOUT_SWITCH.LOCONET_DEVICE_ID)] = @\(TURNOUT_SWITCH.LOCONET_DEVICE_ID), " +
        "[\(TURNOUT_SWITCH.SWITCHBOARD_ITEM_ID)] = @\(TURNOUT_SWITCH.SWITCHBOARD_ITEM_ID), " +
        "[\(TURNOUT_SWITCH.TURNOUT_INDEX)] = @\(TURNOUT_SWITCH.TURNOUT_INDEX), " +
        "[\(TURNOUT_SWITCH.CHANNEL_NUMBER)] = @\(TURNOUT_SWITCH.CHANNEL_NUMBER), " +
        "[\(TURNOUT_SWITCH.FEEDBACK_TYPE)] = @\(TURNOUT_SWITCH.FEEDBACK_TYPE), " +
        "[\(TURNOUT_SWITCH.SWITCH_TYPE)] = @\(TURNOUT_SWITCH.SWITCH_TYPE) " +
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
      cmd.parameters.addWithValue(key: "@\(TURNOUT_SWITCH.SWITCHBOARD_ITEM_ID)", value: switchBoardItemId)
      cmd.parameters.addWithValue(key: "@\(TURNOUT_SWITCH.TURNOUT_INDEX)", value: turnoutIndex)
      cmd.parameters.addWithValue(key: "@\(TURNOUT_SWITCH.CHANNEL_NUMBER)", value: channelNumber)
      cmd.parameters.addWithValue(key: "@\(TURNOUT_SWITCH.FEEDBACK_TYPE)", value: feedbackType.rawValue)
      cmd.parameters.addWithValue(key: "@\(TURNOUT_SWITCH.SWITCH_TYPE)", value: switchType)

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
     static let SWITCHBOARD_ITEM_ID         = "SWITCHBOARD_ITEM_ID"
     static let TURNOUT_INDEX               = "TURNOUT_INDEX"
     static let CHANNEL_NUMBER              = "CHANNEL_NUMBER"
     static let FEEDBACK_TYPE               = "FEEDBACK_TYPE"
     static let SWITCH_TYPE                 = "SWITCH_TYPE"
   }
   */

public static var columnNames : String {
    get {
      return
        "[\(TURNOUT_SWITCH.TURNOUT_SWITCH_ID)], " +
        "[\(TURNOUT_SWITCH.LOCONET_DEVICE_ID)], " +
        "[\(TURNOUT_SWITCH.SWITCHBOARD_ITEM_ID)], " +
        "[\(TURNOUT_SWITCH.TURNOUT_INDEX)], " +
        "[\(TURNOUT_SWITCH.CHANNEL_NUMBER)], " +
        "[\(TURNOUT_SWITCH.FEEDBACK_TYPE)], " +
        "[\(TURNOUT_SWITCH.SWITCH_TYPE)]"
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
  
  public static func dictionaryKey(switchBoardItemId: Int, turnoutIndex: Int) -> Int {
    return (switchBoardItemId << 2) | ((turnoutIndex - 1) & 0b11)
  }

}
