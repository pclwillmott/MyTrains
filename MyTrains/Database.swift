//
//  Database.swift
//  MyTrains
//
//  Created by Paul Willmott on 11/07/2020.
//  Copyright © 2021 Paul Willmott. All rights reserved.
//

import Foundation

class Database {
  
  public static var __number : Int = 0
  
  public static var Version : Int = 0
  
  private static var connection : SqliteConnection? = nil
  
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
          print("create directory failed")
        }
        
        /*
         * Create database connection.
         */
        
        url.appendPathComponent("MyTrains.db3")
        
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

            "CREATE TABLE [\(TABLE.LAYOUT)] (" +
              "[\(LAYOUT.LAYOUT_ID)]          INT PRIMARY KEY," +
              "[\(LAYOUT.LAYOUT_NAME)]        TEXT NOT NULL," +
              "[\(LAYOUT.LAYOUT_DESCRIPTION)] TEXT," +
              "[\(LAYOUT.LAYOUT_SCALE)]       REAL" +
            ")",

            "CREATE TABLE [\(TABLE.NETWORK)] (" +
              "[\(NETWORK.NETWORK_ID)]         INT PRIMARY KEY," +
              "[\(NETWORK.NETWORK_NAME)]       TEXT NOT NULL," +
              "[\(NETWORK.COMMAND_STATION_ID)] INT," +
              "[\(NETWORK.LAYOUT_ID)] INT" +
            ")",
 
            "CREATE TABLE [\(TABLE.INTERFACE)] (" +
              "[\(INTERFACE.INTERFACE_ID)]   INT PRIMARY KEY," +
              "[\(INTERFACE.INTERFACE_NAME)] TEXT NOT NULL," +
              "[\(INTERFACE.MANUFACTURER)]   INT NOT NULL," +
              "[\(INTERFACE.PRODUCT_CODE)]   INT NOT NULL," +
              "[\(INTERFACE.SERIAL_NUMBER)]  INT NOT NULL," +
              "[\(INTERFACE.DEVICE_PATH)]    TEXT NOT NULL," +
              "[\(INTERFACE.BAUD_RATE)]      INT NOT NULL" +
            ")",

            "CREATE TABLE [\(TABLE.COMMAND_STATION)] (" +
              "[\(COMMAND_STATION.COMMAND_STATION_ID)]   INT PRIMARY KEY," +
              "[\(COMMAND_STATION.COMMAND_STATION_NAME)] TEXT NOT NULL," +
              "[\(COMMAND_STATION.MANUFACTURER)]         INT NOT NULL," +
              "[\(COMMAND_STATION.PRODUCT_CODE)]         INT NOT NULL," +
              "[\(COMMAND_STATION.SERIAL_NUMBER)]        INT NOT NULL," +
              "[\(COMMAND_STATION.HARDWARE_VERSION)]     REAL NOT NULL," +
              "[\(COMMAND_STATION.SOFTWARE_VERSION)]     REAL NOT NULL" +
            ")",

            "CREATE TABLE [\(TABLE.LOCOMOTIVE)] (" +
              "[\(LOCOMOTIVE.LOCOMOTIVE_ID)]      INT PRIMARY KEY," +
              "[\(LOCOMOTIVE.LOCOMOTIVE_NAME)]    TEXT NOT NULL," +
              "[\(LOCOMOTIVE.LOCOMOTIVE_TYPE)]    INT NOT NULL," +
              "[\(LOCOMOTIVE.LENGTH)]             REAL NOT NULL," +
              "[\(LOCOMOTIVE.DECODER_TYPE)]       INT NOT NULL," +
              "[\(LOCOMOTIVE.ADDRESS)]            INT NOT NULL," +
              "[\(LOCOMOTIVE.FBOFF_OCC_FRONT)]    REAL NOT NULL," +
              "[\(LOCOMOTIVE.FBOFF_OCC_REAR)]     REAL NOT NULL," +
              "[\(LOCOMOTIVE.LOCOMOTIVE_SCALE)]   REAL NOT NULL," +
              "[\(LOCOMOTIVE.MAX_FORWARD_SPEED)]  REAL NOT NULL," +
              "[\(LOCOMOTIVE.MAX_BACKWARD_SPEED)] REAL NOT NULL," +
              "[\(LOCOMOTIVE.TRACK_GAUGE)]        INT NOT NULL," +
              "[\(LOCOMOTIVE.TRACK_RESTRICTION)]  INT NOT NULL," +
              "[\(LOCOMOTIVE.UNITS_LENGTH)]       INT NOT NULL," +
              "[\(LOCOMOTIVE.UNITS_FBOFF_OCC)]    INT NOT NULL," +
              "[\(LOCOMOTIVE.UNITS_SPEED)]        INT NOT NULL," +
              "[\(LOCOMOTIVE.NETWORK_ID)]         INT NOT NULL," +
              "[\(LOCOMOTIVE.DECODER_MODEL)]      INT NOT NULL," +
              "[\(LOCOMOTIVE.INVENTORY_CODE)]     TEXT NOT NULL," +
              "[\(LOCOMOTIVE.MANUFACTURER)]       TEXT NOT NULL," +
              "[\(LOCOMOTIVE.PURCHASE_DATE)]      TEXT NOT NULL," +
              "[\(LOCOMOTIVE.NOTES)]              TEXT NOT NULL," +
              "[\(LOCOMOTIVE.SOUND_FITTED)]       INT NOT NULL" +
            ")",

            "CREATE TABLE [\(TABLE.LOCOMOTIVE_FUNCTION)] (" +
              "[\(LOCOMOTIVE_FUNCTION.FUNCTION_ID)]          INT PRIMARY KEY," +
              "[\(LOCOMOTIVE_FUNCTION.LOCOMOTIVE_ID)]        INT NOT NULL," +
              "[\(LOCOMOTIVE_FUNCTION.FUNCTION_NUMBER)]      INT NOT NULL," +
              "[\(LOCOMOTIVE_FUNCTION.ENABLED)]              INT NOT NULL," +
              "[\(LOCOMOTIVE_FUNCTION.FUNCTION_DESCRIPTION)] TEXT NOT NULL," +
              "[\(LOCOMOTIVE_FUNCTION.MOMENTARY)]            INT NOT NULL," +
              "[\(LOCOMOTIVE_FUNCTION.DURATION)]             INT NOT NULL," +
              "[\(LOCOMOTIVE_FUNCTION.INVERTED)]             INT NOT NULL," +
              "[\(LOCOMOTIVE_FUNCTION.STATE)]                INT NOT NULL" +
            ")",

            "CREATE TABLE [\(TABLE.LOCOMOTIVE_CV)] (" +
              "[\(LOCOMOTIVE_CV.CV_ID)]              INT PRIMARY KEY," +
              "[\(LOCOMOTIVE_CV.LOCOMOTIVE_ID)]      INT NOT NULL," +
              "[\(LOCOMOTIVE_CV.CV_NUMBER)]          INT NOT NULL," +
              "[\(LOCOMOTIVE_CV.CV_VALUE)]           INT NOT NULL," +
              "[\(LOCOMOTIVE_CV.DEFAULT_VALUE)]      INT NOT NULL," +
              "[\(LOCOMOTIVE_CV.CUSTOM_DESCRIPTION)] TEXT NOT NULL," +
              "[\(LOCOMOTIVE_CV.CUSTOM_NUMBER_BASE)] INT NOT NULL," +
              "[\(LOCOMOTIVE_CV.ENABLED)]            INT NOT NULL" +
            ")",

            /*
            "CREATE INDEX IDX_ARTIST_UKCHART_NAME ON [\(TABLE.ARTIST)] ([\(ARTIST.UKCHART_NAME)])",
            
            "CREATE TABLE [\(TABLE.LABEL)] (" +
              "[\(LABEL.LABEL_ID)]        INT PRIMARY KEY," +
              "[\(LABEL.UKCHART_NAME)]    TEXT NOT NULL" +
            ")",
            
            "CREATE INDEX IDX_LABEL_UKCHART_NAME ON [\(TABLE.LABEL)] ([\(LABEL.UKCHART_NAME)])",
            
            "CREATE TABLE [\(TABLE.CHART)] (" +
              "[\(CHART.CHART_ID)]        INT PRIMARY KEY," +
              "[\(CHART.UKCHART_ID)]      TEXT," +
              "[\(CHART.CHART_NAME)]      TEXT" +
            ")",
            
            "INSERT INTO [\(TABLE.CHART)] ([\(CHART.CHART_ID)], [\(CHART.CHART_NAME)], [\(CHART.UKCHART_ID)]) VALUES " +
                       "(1, 'UK Singles Chart', '7501')",
            
            "INSERT INTO [\(TABLE.CHART)] ([\(CHART.CHART_ID)], [\(CHART.CHART_NAME)], [\(CHART.UKCHART_ID)]) VALUES " +
                       "(2, 'UK Albums Chart', '7502')",
            
            "CREATE TABLE [\(TABLE.CHART_LISTING)] (" +
              "[\(CHART_LISTING.CHART_LISTING_ID)] INT PRIMARY KEY," +
              "[\(CHART_LISTING.ARTIST_ID)]        INT," +
              "[\(CHART_LISTING.CHART_ID)]         INT," +
              "[\(CHART_LISTING.CATALOGUE_NUMBER)] TEXT," +
              "[\(CHART_LISTING.UKCHART_TITLE)]    TEXT," +
              "[\(CHART_LISTING.LABEL_ID)]         INT," +
              "[\(CHART_LISTING.PRODUCT_TYPE)]     TEXT" +
            ")",

            "CREATE TABLE [\(TABLE.CHART_ENTRY)] (" +
              "[\(CHART_ENTRY.CHART_ENTRY_ID)]   INT PRIMARY KEY," +
              "[\(CHART_ENTRY.CHART_DATE)]       TEXT," +
              "[\(CHART_ENTRY.CHART_LISTING_ID)] INT," +
              "[\(CHART_ENTRY.POSITION)]         TEXT," +
              "[\(CHART_ENTRY.LAST_POSITION)]    TEXT," +
              "[\(CHART_ENTRY.HIGHEST_POSITION)] TEXT," +
              "[\(CHART_ENTRY.WEEKS_ON_CHART)]   TEXT" +
            ")",
            */
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
          if let x = reader.getInt(index: 0) {
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

