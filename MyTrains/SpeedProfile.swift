//
//  SpeedProfile.swift
//  MyTrains
//
//  Created by Paul Willmott on 01/08/2022.
//

import Foundation

public class SpeedProfile : EditorObject {
  
  // MARK: Constructors
  
  init(reader:SqliteDataReader) {
    super.init(primaryKey: -1)
    decode(sqliteDataReader: reader)
  }
  
  init(stepNumber: Int) {
    self.stepNumber = stepNumber
    super.init(primaryKey: -1)
  }
  
  // MARK: Destructors
  
  deinit {
  }
  
  // MARK: Public properties
  
  public var rollingStockId : Int = -1 {
    didSet {
      modified = true
    }
  }
  
  public var stepNumber : Int = -1 {
    didSet {
      modified = true
    }
  }
  
  public var speedForward : Double = 0.0 {
    didSet {
      modified = true
      newSpeedForward = speedForward
    }
  }
  
  public var speedReverse : Double = 0.0 {
    didSet {
      modified = true
      newSpeedReverse = speedReverse
    }
  }

  public var newSpeedForward : Double = 0.0 {
    didSet {
      modified = true
    }
  }
  
  public var newSpeedReverse : Double = 0.0 {
    didSet {
      modified = true
    }
  }

  // MARK: Database Methods
  
  private func decode(sqliteDataReader:SqliteDataReader?) {
    
    if let reader = sqliteDataReader {
      
      primaryKey = reader.getInt(index: 0)!
      
      if !reader.isDBNull(index: 1) {
        rollingStockId = reader.getInt(index: 1)!
      }
      
      if !reader.isDBNull(index: 2) {
        stepNumber = reader.getInt(index: 2)!
      }
      
      if !reader.isDBNull(index: 3) {
        speedForward = reader.getDouble(index: 3)!
      }
      
      if !reader.isDBNull(index: 4) {
        speedReverse = reader.getDouble(index: 4)!
      }
      
    }
    
    newSpeedForward = speedForward
    newSpeedReverse = speedReverse
    
    modified = false
    
  }

  public func save() {
    
    speedForward = newSpeedForward
    speedReverse = newSpeedReverse
    
    if modified {
      
      var sql = ""
      
      if primaryKey == -1 {
        sql = "INSERT INTO [\(TABLE.SPEED_PROFILE)] (" +
        "[\(SPEED_PROFILE.SPEED_PROFILE_ID)], " +
        "[\(SPEED_PROFILE.ROLLING_STOCK_ID)], " +
        "[\(SPEED_PROFILE.STEP_NUMBER)], " +
        "[\(SPEED_PROFILE.SPEED_FORWARD)]," +
        "[\(SPEED_PROFILE.SPEED_REVERSE)]" +
        ") VALUES (" +
        "@\(SPEED_PROFILE.SPEED_PROFILE_ID), " +
        "@\(SPEED_PROFILE.ROLLING_STOCK_ID), " +
        "@\(SPEED_PROFILE.STEP_NUMBER), " +
        "@\(SPEED_PROFILE.SPEED_FORWARD), " +
        "@\(SPEED_PROFILE.SPEED_REVERSE)" +
        ")"
        primaryKey = Database.nextCode(tableName: TABLE.SPEED_PROFILE, primaryKey: SPEED_PROFILE.SPEED_PROFILE_ID)!
      }
      else {
        sql = "UPDATE [\(TABLE.SPEED_PROFILE)] SET " +
        "[\(SPEED_PROFILE.ROLLING_STOCK_ID)] = @\(SPEED_PROFILE.ROLLING_STOCK_ID), " +
        "[\(SPEED_PROFILE.STEP_NUMBER)] = @\(SPEED_PROFILE.STEP_NUMBER), " +
        "[\(SPEED_PROFILE.SPEED_FORWARD)] = @\(SPEED_PROFILE.SPEED_FORWARD), " +
        "[\(SPEED_PROFILE.SPEED_REVERSE)] = @\(SPEED_PROFILE.SPEED_REVERSE) " +
        "WHERE [\(SPEED_PROFILE.SPEED_PROFILE_ID)] = @\(SPEED_PROFILE.SPEED_PROFILE_ID)"
      }

      let conn = Database.getConnection()
      
      let shouldClose = conn.state != .Open
       
      if shouldClose {
         _ = conn.open()
      }
       
      let cmd = conn.createCommand()
       
      cmd.commandText = sql
 
      cmd.parameters.addWithValue(key: "@\(SPEED_PROFILE.SPEED_PROFILE_ID)", value: primaryKey)
      cmd.parameters.addWithValue(key: "@\(SPEED_PROFILE.ROLLING_STOCK_ID)", value: rollingStockId)
      cmd.parameters.addWithValue(key: "@\(SPEED_PROFILE.STEP_NUMBER)", value: stepNumber)
      cmd.parameters.addWithValue(key: "@\(SPEED_PROFILE.SPEED_FORWARD)", value: speedForward)
      cmd.parameters.addWithValue(key: "@\(SPEED_PROFILE.SPEED_REVERSE)", value: speedReverse)

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
        "[\(SPEED_PROFILE.SPEED_PROFILE_ID)], " +
        "[\(SPEED_PROFILE.ROLLING_STOCK_ID)], " +
        "[\(SPEED_PROFILE.STEP_NUMBER)], " +
        "[\(SPEED_PROFILE.SPEED_FORWARD)], " +
        "[\(SPEED_PROFILE.SPEED_REVERSE)]"
    }
  }
  
  public static func speedProfile(rollingStock: RollingStock) -> [SpeedProfile] {
    
    let conn = Database.getConnection()
      
    let shouldClose = conn.state != .Open
       
    if shouldClose {
      _ = conn.open()
    }
       
    let cmd = conn.createCommand()
       
    cmd.commandText = "SELECT \(columnNames) FROM [\(TABLE.SPEED_PROFILE)] WHERE [\(SPEED_PROFILE.ROLLING_STOCK_ID)] = \(rollingStock.primaryKey) ORDER BY [\(SPEED_PROFILE.STEP_NUMBER)]"

    var result : [SpeedProfile] = []
      
    if let reader = cmd.executeReader() {
           
      while reader.read() {
        let sp = SpeedProfile(reader: reader)
        result.append(sp)
      }
           
      reader.close()
           
    }
      
    if shouldClose {
      conn.close()
    }

    return result
      
  }

  public static func delete(primaryKey: Int) {
    let sql = "DELETE FROM [\(TABLE.SPEED_PROFILE)] WHERE [\(SPEED_PROFILE.SPEED_PROFILE_ID)] = \(primaryKey)"
    Database.execute(commands: [sql])
  }

}
