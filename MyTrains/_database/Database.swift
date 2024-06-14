//
//  Database.swift
//  MyTrains
//
//  Created by Paul Willmott on 11/07/2020.
//  Copyright © 2021 Paul Willmott. All rights reserved.
//

import Foundation

class Database {
  
  // MARK: Public Class Properties
  
  private static var connection : SqliteConnection? = nil
  
  public static var __number : Int = 0
  
  public static var Version : Int = 0
  
  public static var databaseFilename : String {
    return "MyTrains.db3"
  }
  
  public static var databaseFullPath : String {
    return "\(databasePath!)/\(databaseFilename)"
  }
  
  // MARK: Public Class Methods
  
  public static func getConnection() -> SqliteConnection {
    
    if (connection == nil) {

      /*
       * Create MyChartBox directory.
       */
      
      if let databasePath = UserDefaults.standard.string(forKey: DEFAULT.DATABASE_PATH) {
      
        var url = URL(fileURLWithPath: databasePath)
        
        let fm = FileManager()
        
        do{
          try fm.createDirectory(at: url, withIntermediateDirectories:true, attributes:nil)
        }
        catch{
          #if DEBUG
          debugLog("create directory failed")
          #endif
        }
        
        /*
         * Create database connection.
         */
        
        url.appendPathComponent(databaseFilename)
        
        let newfile = !fm.fileExists(atPath: url.path)
        
        connection = SqliteConnection(connectionString: url.absoluteString)
        
        if newfile {
          
          let commands = [
            
            "CREATE TABLE [\(TABLE.VERSION)] (" +
              "[\(VERSION.VERSION_ID)]     INTEGER PRIMARY KEY," +
              "[\(VERSION.VERSION_NUMBER)] INT" +
            ")",
            
            "INSERT INTO [\(TABLE.VERSION)] ([\(VERSION.VERSION_ID)], [\(VERSION.VERSION_NUMBER)]) VALUES " +
            "(1, 1)",

            "CREATE TABLE [\(TABLE.MEMORY_SPACE)] (" +
              "[\(MEMORY_SPACE.MEMORY_SPACE_ID)] INT PRIMARY KEY," +
              "[\(MEMORY_SPACE.NODE_ID)]         INT NOT NULL," +
              "[\(MEMORY_SPACE.SPACE)]           INT NOT NULL," +
              "[\(MEMORY_SPACE.MEMORY)]          TEXT NOT NULL" +
            ")",

          ]
          
          execute(commands: commands)
          
        }
        
        /*
         * Get version information.
         */

        if connection!.open() == .Open {
          
          let cmd = connection!.createCommand()
          
          cmd.commandText =
          "SELECT [\(VERSION.VERSION_NUMBER)] FROM [\(TABLE.VERSION)] WHERE [\(VERSION.VERSION_ID)] = 1"
          
          if let reader = cmd.executeReader() {
            
            if reader.read() {
              Version = reader.getInt(index: 0)!
            }
            
            reader.close()
            
            // MARK: Updates
            
            if Version == 34 {
  
              let commands = [

                "UPDATE [\(TABLE.VERSION)] SET [\(VERSION.VERSION_NUMBER)] = 35 WHERE [\(VERSION.VERSION_ID)] = 1",
 
             ]
              
              execute(commands: commands)
              
              Version = 35
 
            }
            
            connection!.close()
            
          }
          
        }
        
      }
      
    }
    
    return connection!
    
  }
  
  public static func nextCode(tableName:String, primaryKey:String) -> Int? {
    
    let conn = Database.getConnection()
    var shouldClose = false
    
    if conn.state != .Open {
      if conn.open() != .Open {
        return nil
      }
      shouldClose = true
    }
    
    var code : Int = 0
    
    var _cmd : SqliteCommand? = conn.createCommand()
    
    if let cmd = _cmd {
      
      cmd.commandText = "SELECT MAX([\(primaryKey)]) AS MAX_KEY FROM [\(tableName)] "
      
      if let reader = cmd.executeReader() {
        
        if reader.read() {
          if let maxKey = reader.getInt(index: 0) {
            code = maxKey
          }
        }
        
        code += 1
        
        reader.close()
        
      }
      
      if code == 0 {
        code = 1
      }

    }
    
    _cmd = nil
    
    if shouldClose {
      conn.close()
    }
    
    return code

  }
  
  public static func codeExists(tableName:String, primaryKey:String, code:Int) -> Bool? {
    
    let conn = Database.getConnection()
    var shouldClose = false
    
    if conn.state != .Open {
      if conn.open() != .Open {
        return nil
      }
      shouldClose = true
    }
    
    var result = false
    
    var _cmd : SqliteCommand? = conn.createCommand()
    
    if let cmd = _cmd {
      
      cmd.commandText = "SELECT [\(primaryKey)] FROM [\(tableName)] WHERE [\(primaryKey)] = \(code)"
      
      if let reader = cmd.executeReader() {
        
        if reader.read() {
          if let _ = reader.getInt(index: 0) {
            result = true
          }
        }
        
        reader.close()
        
      }
      
    }
    
    _cmd = nil
    
    if shouldClose {
      conn.close()
    }
    
    return result

  }

  public static func codeExists(tableName:String, primaryKey:String, code:UInt64) -> Bool {
    
    let conn = Database.getConnection()
    var shouldClose = false
    
    if conn.state != .Open {
      if conn.open() != .Open {
        return true
      }
      shouldClose = true
    }
    
    var result = false
    
    var _cmd : SqliteCommand? = conn.createCommand()
    
    if let cmd = _cmd {
      
      cmd.commandText = "SELECT [\(primaryKey)] FROM [\(tableName)] WHERE [\(primaryKey)] = \(code)"
      
      if let reader = cmd.executeReader() {
        
        if reader.read() {
          if let _ = reader.getInt(index: 0) {
            result = true
          }
        }
        
        reader.close()
        
      }
      
    }
    
    _cmd = nil
    
    if shouldClose {
      conn.close()
    }
    
    return result

  }
  
  public static func isEmpty() -> Bool {
    return numberOfRows(tableName: TABLE.MEMORY_SPACE) == 0
  }
  
  public static func numberOfRows(tableName:String) -> Int {
    
    let conn = Database.getConnection()
    var shouldClose = false
    
    if conn.state != .Open {
      if conn.open() != .Open {
        return 0
      }
      shouldClose = true
    }
    
    var result : Int = 0
    
    var _cmd : SqliteCommand? = conn.createCommand()
    
    if let cmd = _cmd {
      
      cmd.commandText = "SELECT COUNT(*) FROM [\(tableName)]"
      
      if let reader = cmd.executeReader() {
        
        if reader.read() {
          if let count = reader.getInt(index: 0) {
            result = count
          }
        }
        
        reader.close()
        
      }
      
    }
    
    _cmd = nil
    
    if shouldClose {
      conn.close()
    }
    
    return result

  }

  
  public static func deleteAllRows() {
    
    let commands = [
      "DELETE FROM \(TABLE.VERSION)",
      "DELETE FROM \(TABLE.MEMORY_SPACE)",
    ]
    
    execute(commands: commands)
    
  }

  public static func execute(commands:[String]) {
    
    let conn = getConnection()
        
    let shouldClose = conn.state != .Open
         
    if shouldClose {
      _ = conn.open()
    }

    let cmd = conn.createCommand()
                    
    for sql in commands {
      cmd.commandText = sql
      let _ = cmd.executeNonQuery()
    }
                    
    if shouldClose {
      conn.close()
    }

  }
  
}

