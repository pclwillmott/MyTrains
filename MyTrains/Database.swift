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
            "(1, 15)",

            "CREATE TABLE [\(TABLE.LAYOUT)] (" +
              "[\(LAYOUT.LAYOUT_ID)]          INT PRIMARY KEY," +
              "[\(LAYOUT.LAYOUT_NAME)]        TEXT NOT NULL," +
              "[\(LAYOUT.LAYOUT_DESCRIPTION)] TEXT NOT NULL," +
              "[\(LAYOUT.LAYOUT_SCALE)]       REAL NOT NULL" +
            ")",

            "CREATE TABLE [\(TABLE.NETWORK)] (" +
              "[\(NETWORK.NETWORK_ID)]            INT PRIMARY KEY," +
              "[\(NETWORK.NETWORK_NAME)]          TEXT NOT NULL," +
              "[\(NETWORK.INTERFACE_ID)]          INT NOT NULL," +
              "[\(NETWORK.LAYOUT_ID)]             INT NOT NULL," +
              "[\(NETWORK.LOCONET_ID)]            INT NOT NULL," +
              "[\(NETWORK.DUPLEX_GROUP_NAME)]     TEXT NOT NULL," +
              "[\(NETWORK.DUPLEX_GROUP_PASSWORD)] TEXT NOT NULL," +
              "[\(NETWORK.DUPLEX_GROUP_CHANNEL)]  INT NOT NULL," +
              "[\(NETWORK.DUPLEX_GROUP_ID)]       INT NOT NULL," +
              "[\(NETWORK.COMMAND_STATION_ID)]    INT NOT NULL" +
            ")",
 
            "CREATE TABLE [\(TABLE.LOCONET_DEVICE)] (" +
              "[\(LOCONET_DEVICE.LOCONET_DEVICE_ID)]      INT PRIMARY KEY," +
              "[\(LOCONET_DEVICE.NETWORK_ID)]             INT NOT NULL," +
              "[\(LOCONET_DEVICE.SERIAL_NUMBER)]          INT NOT NULL," +
              "[\(LOCONET_DEVICE.SOFTWARE_VERSION)]       REAL NOT NULL," +
              "[\(LOCONET_DEVICE.HARDWARE_VERSION)]       REAL NOT NULL," +
              "[\(LOCONET_DEVICE.BOARD_ID)]               INT NOT NULL," +
              "[\(LOCONET_DEVICE.LOCONET_PRODUCT_ID)]     INT NOT NULL," +
              "[\(LOCONET_DEVICE.OPTION_SWITCHES_0)]      INT NOT NULL," +
              "[\(LOCONET_DEVICE.OPTION_SWITCHES_1)]      INT NOT NULL," +
              "[\(LOCONET_DEVICE.OPTION_SWITCHES_2)]      INT NOT NULL," +
              "[\(LOCONET_DEVICE.OPTION_SWITCHES_3)]      INT NOT NULL," +
              "[\(LOCONET_DEVICE.DEVICE_PATH)]            TEXT NOT NULL," +
              "[\(LOCONET_DEVICE.BAUD_RATE)]              INT NOT NULL," +
              "[\(LOCONET_DEVICE.DEVICE_NAME)]            TEXT NOT NULL," +
              "[\(LOCONET_DEVICE.FLOW_CONTROL)]           INT NOT NULL," +
              "[\(LOCONET_DEVICE.IS_STAND_ALONE_LOCONET)] INT NOT NULL," +
              "[\(LOCONET_DEVICE.FLAGS)]                  INT NOT NULL" +
            ")",

            "CREATE TABLE [\(TABLE.LOCONET_DEVICE_CV)] (" +
            "[\(LOCONET_DEVICE_CV.LOCONET_DEVICE_CV_ID)]  INT PRIMARY KEY," +
            "[\(LOCONET_DEVICE_CV.LOCONET_DEVICE_ID)]     INT NOT NULL," +
            "[\(LOCONET_DEVICE_CV.CV_NUMBER)]             INT NOT NULL," +
            "[\(LOCONET_DEVICE_CV.CV_VALUE)]              INT NOT NULL," +
            "[\(LOCONET_DEVICE_CV.DEFAULT_VALUE)]         INT NOT NULL," +
            "[\(LOCONET_DEVICE_CV.CUSTOM_DESCRIPTION)]    TEXT NOT NULL," +
            "[\(LOCONET_DEVICE_CV.CUSTOM_NUMBER_BASE)]    INT NOT NULL," +
            "[\(LOCONET_DEVICE_CV.ENABLED)]               INT NOT NULL" +
           ")",
            
           "CREATE TABLE [\(TABLE.ROLLING_STOCK)] (" +
              "[\(ROLLING_STOCK.ROLLING_STOCK_ID)]         INT PRIMARY KEY," +
              "[\(ROLLING_STOCK.ROLLING_STOCK_NAME)]       TEXT NOT NULL," +
              "[\(ROLLING_STOCK.NETWORK_ID)]               INT NOT NULL," +
              "[\(ROLLING_STOCK.LENGTH)]                   REAL NOT NULL," +
              "[\(ROLLING_STOCK.ROLLING_STOCK_TYPE)]       INT NOT NULL," +
              "[\(ROLLING_STOCK.MANUFACTURER_ID)]          INT NOT NULL," +
              "[\(ROLLING_STOCK.MDECODER_MANUFACTURER_ID)] INT NOT NULL," +
              "[\(ROLLING_STOCK.MDECODER_MODEL)]           INT NOT NULL," +
              "[\(ROLLING_STOCK.MDECODER_ADDRESS)]         INT NOT NULL," +
              "[\(ROLLING_STOCK.ADECODER_MANUFACTURER_ID)] INT NOT NULL," +
              "[\(ROLLING_STOCK.ADECODER_MODEL)]           INT NOT NULL," +
              "[\(ROLLING_STOCK.ADECODER_ADDRESS)]         INT NOT NULL," +
              "[\(ROLLING_STOCK.SPEED_STEPS)]              INT NOT NULL," +
              "[\(ROLLING_STOCK.FBOFF_OCC_FRONT)]          REAL NOT NULL," +
              "[\(ROLLING_STOCK.FBOFF_OCC_REAR)]           REAL NOT NULL," +
              "[\(ROLLING_STOCK.SCALE)]                    REAL NOT NULL," +
              "[\(ROLLING_STOCK.TRACK_GAUGE)]              INT NOT NULL," +
              "[\(ROLLING_STOCK.MAX_FORWARD_SPEED)]        REAL NOT NULL," +
              "[\(ROLLING_STOCK.MAX_BACKWARD_SPEED)]       REAL NOT NULL," +
              "[\(ROLLING_STOCK.UNITS_LENGTH)]             INT NOT NULL," +
              "[\(ROLLING_STOCK.UNITS_FBOFF_OCC)]          INT NOT NULL," +
              "[\(ROLLING_STOCK.UNITS_SPEED)]              INT NOT NULL," +
              "[\(ROLLING_STOCK.INVENTORY_CODE)]           TEXT NOT NULL," +
              "[\(ROLLING_STOCK.PURCHASE_DATE)]            TEXT NOT NULL," +
              "[\(ROLLING_STOCK.NOTES)]                    TEXT NOT NULL," +
              "[\(ROLLING_STOCK.LOCOMOTIVE_TYPE)]          INT NOT NULL," +
              "[\(ROLLING_STOCK.MDECODER_INSTALLED)]       INT NOT NULL," +
              "[\(ROLLING_STOCK.ADECODER_INSTALLED)]       INT NOT NULL," +
              "[\(ROLLING_STOCK.ADECODER_INSTALLED)]       INT NOT NULL," +
              "[\(ROLLING_STOCK.BEST_FIT_METHOD)]          INT NOT NULL" +
            ")",
/*
            "CREATE TABLE [\(TABLE.DECODER_FUNCTION)] (" +
              "[\(DECODER_FUNCTION.DECODER_FUNCTION_ID)]  INT PRIMARY KEY," +
              "[\(DECODER_FUNCTION.ROLLING_STOCK_ID)]     INT NOT NULL," +
              "[\(DECODER_FUNCTION.DECODER_TYPE)]         INT NOT NULL," +
              "[\(DECODER_FUNCTION.FUNCTION_NUMBER)]      INT NOT NULL," +
              "[\(DECODER_FUNCTION.ENABLED)]              INT NOT NULL," +
              "[\(DECODER_FUNCTION.FUNCTION_DESCRIPTION)] TEXT NOT NULL," +
              "[\(DECODER_FUNCTION.MOMENTARY)]            INT NOT NULL," +
              "[\(DECODER_FUNCTION.DURATION)]             INT NOT NULL," +
              "[\(DECODER_FUNCTION.INVERTED)]             INT NOT NULL," +
              "[\(DECODER_FUNCTION.STATE)]                INT NOT NULL" +
            ")",
*/
            "CREATE TABLE [\(TABLE.DECODER_CV)] (" +
              "[\(DECODER_CV.DECODER_CV_ID)]      INT PRIMARY KEY," +
              "[\(DECODER_CV.ROLLING_STOCK_ID)]   INT NOT NULL," +
              "[\(DECODER_CV.DECODER_TYPE)]       INT NOT NULL," +
              "[\(DECODER_CV.CV_NUMBER)]          INT NOT NULL," +
              "[\(DECODER_CV.CV_VALUE)]           INT NOT NULL," +
              "[\(DECODER_CV.DEFAULT_VALUE)]      INT NOT NULL," +
              "[\(DECODER_CV.CUSTOM_DESCRIPTION)] TEXT NOT NULL," +
              "[\(DECODER_CV.CUSTOM_NUMBER_BASE)] INT NOT NULL," +
              "[\(DECODER_CV.ENABLED)]            INT NOT NULL" +
            ")",

            "CREATE TABLE [\(TABLE.SPEED_PROFILE)] (" +
              "[\(SPEED_PROFILE.SPEED_PROFILE_ID)]  INT PRIMARY KEY," +
              "[\(SPEED_PROFILE.ROLLING_STOCK_ID)]  INT NOT NULL," +
              "[\(SPEED_PROFILE.STEP_NUMBER)]       INT NOT NULL," +
              "[\(SPEED_PROFILE.SPEED_FORWARD)]     REAL NOT NULL," +
              "[\(SPEED_PROFILE.SPEED_REVERSE)]     REAL NOT NULL" +
            ")",

            "CREATE TABLE [\(TABLE.SWITCHBOARD_PANEL)] (" +
              "[\(SWITCHBOARD_PANEL.SWITCHBOARD_PANEL_ID)] INT PRIMARY KEY," +
              "[\(SWITCHBOARD_PANEL.LAYOUT_ID)]            INT NOT NULL," +
              "[\(SWITCHBOARD_PANEL.PANEL_ID)]             INT NOT NULL," +
              "[\(SWITCHBOARD_PANEL.PANEL_NAME)]           TEXT NOT NULL," +
              "[\(SWITCHBOARD_PANEL.NUMBER_OF_COLUMNS)]    INT NOT NULL," +
              "[\(SWITCHBOARD_PANEL.NUMBER_OF_ROWS)]       INT NOT NULL" +
            ")",

            "CREATE TABLE [\(TABLE.SWITCHBOARD_ITEM)] (" +
              "[\(SWITCHBOARD_ITEM.SWITCHBOARD_ITEM_ID)]          INT PRIMARY KEY," +
              "[\(SWITCHBOARD_ITEM.LAYOUT_ID)]                    INT NOT NULL," +
              "[\(SWITCHBOARD_ITEM.PANEL_ID)]                     INT NOT NULL," +
              "[\(SWITCHBOARD_ITEM.GROUP_ID)]                     INT NOT NULL," +
              "[\(SWITCHBOARD_ITEM.ITEM_PART_TYPE)]               INT NOT NULL," +
              "[\(SWITCHBOARD_ITEM.ORIENTATION)]                  INT NOT NULL," +
              "[\(SWITCHBOARD_ITEM.XPOS)]                         INT NOT NULL," +
              "[\(SWITCHBOARD_ITEM.YPOS)]                         INT NOT NULL," +
              "[\(SWITCHBOARD_ITEM.BLOCK_NAME)]                   TEXT NOT NULL," +
              "[\(SWITCHBOARD_ITEM.BLOCK_DIRECTION)]              INT NOT NULL," +
              "[\(SWITCHBOARD_ITEM.TRACK_PART_ID)]                INT NOT NULL," +
              "[\(SWITCHBOARD_ITEM.DIMENSIONA)]                   REAL NOT NULL," +
              "[\(SWITCHBOARD_ITEM.DIMENSIONB)]                   REAL NOT NULL," +
              "[\(SWITCHBOARD_ITEM.DIMENSIONC)]                   REAL NOT NULL," +
              "[\(SWITCHBOARD_ITEM.DIMENSIOND)]                   REAL NOT NULL," +
              "[\(SWITCHBOARD_ITEM.DIMENSIONE)]                   REAL NOT NULL," +
              "[\(SWITCHBOARD_ITEM.DIMENSIONF)]                   REAL NOT NULL," +
              "[\(SWITCHBOARD_ITEM.DIMENSIONG)]                   REAL NOT NULL," +
              "[\(SWITCHBOARD_ITEM.DIMENSIONH)]                   REAL NOT NULL," +
              "[\(SWITCHBOARD_ITEM.UNITS_DIMENSION)]              INT NOT NULL," +
              "[\(SWITCHBOARD_ITEM.ALLOW_SHUNT)]                  INT NOT NULL," +
              "[\(SWITCHBOARD_ITEM.TRACK_GAUGE)]                  INT NOT NULL," +
              "[\(SWITCHBOARD_ITEM.TRACK_ELECTRIFICATION_TYPE)]   INT NOT NULL," +
              "[\(SWITCHBOARD_ITEM.GRADIENT)]                     REAL NOT NULL," +
              "[\(SWITCHBOARD_ITEM.IS_CRITICAL)]                  INT NOT NULL," +
              "[\(SWITCHBOARD_ITEM.UNITS_SPEED)]                  INT NOT NULL," +
              "[\(SWITCHBOARD_ITEM.DN_UNITS_POSITION)]            INT NOT NULL," +
              "[\(SWITCHBOARD_ITEM.DP_UNITS_POSITION)]            INT NOT NULL," +
              "[\(SWITCHBOARD_ITEM.DN_BRAKE_POSITION)]            REAL NOT NULL," +
              "[\(SWITCHBOARD_ITEM.DN_STOP_POSITION)]             REAL NOT NULL," +
              "[\(SWITCHBOARD_ITEM.DN_SPEED_MAX)]                 REAL NOT NULL," +
              "[\(SWITCHBOARD_ITEM.DN_SPEED_STOP_EXPECTED)]       REAL NOT NULL," +
              "[\(SWITCHBOARD_ITEM.DN_SPEED_RESTRICTED)]          REAL NOT NULL," +
              "[\(SWITCHBOARD_ITEM.DN_SPEED_BRAKE)]               REAL NOT NULL," +
              "[\(SWITCHBOARD_ITEM.DN_SPEED_SHUNT)]               REAL NOT NULL," +
              "[\(SWITCHBOARD_ITEM.DN_SPEED_MAX_UD)]              INT NOT NULL," +
              "[\(SWITCHBOARD_ITEM.DN_SPEED_STOP_EXPECTED_UD)]    INT NOT NULL," +
              "[\(SWITCHBOARD_ITEM.DN_SPEED_RESTRICTED_UD)]       INT NOT NULL," +
              "[\(SWITCHBOARD_ITEM.DN_SPEED_BRAKE_UD)]            INT NOT NULL," +
              "[\(SWITCHBOARD_ITEM.DN_SPEED_SHUNT_UD)]            INT NOT NULL," +
              "[\(SWITCHBOARD_ITEM.DP_BRAKE_POSITION)]            REAL NOT NULL," +
              "[\(SWITCHBOARD_ITEM.DP_STOP_POSITION)]             REAL NOT NULL," +
              "[\(SWITCHBOARD_ITEM.DP_SPEED_MAX)]                 REAL NOT NULL," +
              "[\(SWITCHBOARD_ITEM.DP_SPEED_STOP_EXPECTED)]       REAL NOT NULL," +
              "[\(SWITCHBOARD_ITEM.DP_SPEED_RESTRICTED)]          REAL NOT NULL," +
              "[\(SWITCHBOARD_ITEM.DP_SPEED_BRAKE)]               REAL NOT NULL," +
              "[\(SWITCHBOARD_ITEM.DP_SPEED_SHUNT)]               REAL NOT NULL," +
              "[\(SWITCHBOARD_ITEM.DP_SPEED_MAX_UD)]              INT NOT NULL," +
              "[\(SWITCHBOARD_ITEM.DP_SPEED_STOP_EXPECTED_UD)]    INT NOT NULL," +
              "[\(SWITCHBOARD_ITEM.DP_SPEED_RESTRICTED_UD)]       INT NOT NULL," +
              "[\(SWITCHBOARD_ITEM.DP_SPEED_BRAKE_UD)]            INT NOT NULL," +
              "[\(SWITCHBOARD_ITEM.DP_SPEED_SHUNT_UD)]            INT NOT NULL," +
              "[\(SWITCHBOARD_ITEM.SW1_TURNOUT_MOTOR_TYPE)]       INT NOT NULL," +
              "[\(SWITCHBOARD_ITEM.SW2_TURNOUT_MOTOR_TYPE)]       INT NOT NULL," +
              "[\(SWITCHBOARD_ITEM.IS_SCENIC_SECTION)]            INT NOT NULL," +
              "[\(SWITCHBOARD_ITEM.BLOCK_TYPE)]                   INT NOT NULL," +
              "[\(SWITCHBOARD_ITEM.LINK_ITEM)]                    INT NOT NULL," +
              "[\(SWITCHBOARD_ITEM.TURNOUT_CONNECTION)]           INT NOT NULL," +
              "[\(SWITCHBOARD_ITEM.SENSOR_POSITION)]              REAL NOT NULL," +
              "[\(SWITCHBOARD_ITEM.UNITS_SENSOR_POSITION)]        INT NOT NULL," +
              "[\(SWITCHBOARD_ITEM.ENTER_OCCUPANCY_EVENT_ID)]     INT," +
              "[\(SWITCHBOARD_ITEM.EXIT_OCCUPANCY_EVENT_ID)]      INT," +
              "[\(SWITCHBOARD_ITEM.TRANSPONDER_EVENT_ID)]         INT," +
              "[\(SWITCHBOARD_ITEM.TRACK_FAULT_EVENT_ID)]         INT," +
              "[\(SWITCHBOARD_ITEM.TRACK_FAULT_CLEARED_EVENT_ID)] INT," +
              "[\(SWITCHBOARD_ITEM.SW1_THROWN_EVENT_ID)]          INT," +
              "[\(SWITCHBOARD_ITEM.SW1_CLOSED_EVENT_ID)]          INT," +
              "[\(SWITCHBOARD_ITEM.SW1_THROW_EVENT_ID)]           INT," +
              "[\(SWITCHBOARD_ITEM.SW1_CLOSE_EVENT_ID)]           INT," +
              "[\(SWITCHBOARD_ITEM.SW2_THROWN_EVENT_ID)]          INT," +
              "[\(SWITCHBOARD_ITEM.SW2_CLOSED_EVENT_ID)]          INT," +
              "[\(SWITCHBOARD_ITEM.SW2_THROW_EVENT_ID)]           INT," +
              "[\(SWITCHBOARD_ITEM.SW2_CLOSE_EVENT_ID)]           INT" +
            ")",
            
            "CREATE TABLE [\(TABLE.SENSOR)] (" +
              "[\(SENSOR.SENSOR_ID)]           INT PRIMARY KEY," +
              "[\(SENSOR.LOCONET_DEVICE_ID)]   INT NOT NULL," +
              "[\(SENSOR.CHANNEL_NUMBER)]      INT NOT NULL," +
              "[\(SENSOR.SENSOR_TYPE)]         INT NOT NULL," +
              "[\(SENSOR.SENSOR_ADDRESS)]      INT NOT NULL," +
              "[\(SENSOR.DELAY_ON)]            INT NOT NULL," +
              "[\(SENSOR.DELAY_OFF)]           INT NOT NULL," +
              "[\(SENSOR.INVERTED)]            INT NOT NULL," +
              "[\(SENSOR.FUNCTION_NUMBER)]     INT NOT NULL," +
              "[\(SENSOR.FUNCTION_TYPE)]       INT NOT NULL" +
            ")",
            
            "CREATE TABLE [\(TABLE.TURNOUT_SWITCH)] (" +
              "[\(TURNOUT_SWITCH.TURNOUT_SWITCH_ID)]   INT PRIMARY KEY," +
              "[\(TURNOUT_SWITCH.LOCONET_DEVICE_ID)]   INT NOT NULL," +
              "[\(TURNOUT_SWITCH.CHANNEL_NUMBER)]      INT NOT NULL," +
              "[\(TURNOUT_SWITCH.SWITCH_ADDRESS)]      INT NOT NULL" +
            ")",

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
            
   //         print("Version: \(Version)")
            
            if Version == 30 {
  
              let commands = [
        

           /*
                "CREATE TABLE [\(TABLE.LOCONET_DEVICE_CV)] (" +
                "[\(LOCONET_DEVICE_CV.LOCONET_DEVICE_CV_ID)]  INT PRIMARY KEY," +
                "[\(LOCONET_DEVICE_CV.LOCONET_DEVICE_ID)]     INT NOT NULL," +
                "[\(LOCONET_DEVICE_CV.CV_NUMBER)]             INT NOT NULL," +
                "[\(LOCONET_DEVICE_CV.CV_VALUE)]              INT NOT NULL" +
                ")",
              */
                
          //      "DELETE FROM [\(TABLE.SPEED_PROFILE)] WHERE [\(SPEED_PROFILE.STEP_NUMBER)] = 127",
                
          //      "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] ADD [\(SWITCHBOARD_ITEM.TURNOUT_CONNECTION)] INT",
                
          //      "UPDATE [\(TABLE.SWITCHBOARD_ITEM)] SET [\(SWITCHBOARD_ITEM.TURNOUT_CONNECTION)] = 0",
                /*
                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] RENAME COLUMN [\(SWITCHBOARD_ITEM.SW1_SENSOR_ID)] TO [\(SWITCHBOARD_ITEM.SW1_SENSOR1_ID)]",
                
                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] RENAME COLUMN [\(SWITCHBOARD_ITEM.SW2_SENSOR_ID)] TO [\(SWITCHBOARD_ITEM.SW2_SENSOR1_ID)]",

                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] RENAME COLUMN [\(SWITCHBOARD_ITEM.SW1_PORT)] TO [\(SWITCHBOARD_ITEM.SW1_CHANNEL_NUMBER)]",

                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] RENAME COLUMN [\(SWITCHBOARD_ITEM.SW2_PORT)] TO [\(SWITCHBOARD_ITEM.SW2_CHANNEL_NUMBER)]",

                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] ADD [\(SWITCHBOARD_ITEM.SW1_SENSOR1_CHANNEL_NUMBER)] INT",

                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] ADD [\(SWITCHBOARD_ITEM.SW1_SENSOR2_ID)] INT",

                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] ADD [\(SWITCHBOARD_ITEM.SW1_SENSOR2_CHANNEL_NUMBER)] INT",

                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] ADD [\(SWITCHBOARD_ITEM.SW2_SENSOR1_CHANNEL_NUMBER)] INT",

                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] ADD [\(SWITCHBOARD_ITEM.SW2_SENSOR2_ID)] INT",

                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] ADD [\(SWITCHBOARD_ITEM.SW2_SENSOR2_CHANNEL_NUMBER)] INT",

                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] ADD [\(SWITCHBOARD_ITEM.SENSOR_POSITION)] REAL",

                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] ADD [\(SWITCHBOARD_ITEM.UNITS_SENSOR_POSITION)] INT",

                "ALTER TABLE [\(TABLE.SENSOR)] DROP COLUMN [\(SENSOR.SWITCHBOARD_ITEM_ID)]",
                
                "ALTER TABLE [\(TABLE.SENSOR)] DROP COLUMN [\(SENSOR.MESSAGE_TYPE)]",
 
                "ALTER TABLE [\(TABLE.SENSOR)] DROP COLUMN [\(SENSOR.POSITION)]",
                
                "ALTER TABLE [\(TABLE.SENSOR)] DROP COLUMN [\(SENSOR.UNITS_POSITION)]",
                
                "ALTER TABLE [\(TABLE.SENSOR)] ADD [\(SENSOR.SENSOR_ADDRESS)] INT",

                "ALTER TABLE [\(TABLE.SENSOR)] ADD [\(SENSOR.DELAY_ON)] INT",

                "ALTER TABLE [\(TABLE.SENSOR)] ADD [\(SENSOR.DELAY_OFF)] INT",

                "ALTER TABLE [\(TABLE.SENSOR)] ADD [\(SENSOR.INVERTED)] INT",

                "ALTER TABLE [\(TABLE.TURNOUT_SWITCH)] DROP COLUMN [\(TURNOUT_SWITCH.SWITCHBOARD_ITEM_ID)]",
                
                "ALTER TABLE [\(TABLE.TURNOUT_SWITCH)] DROP COLUMN [\(TURNOUT_SWITCH.TURNOUT_INDEX)]",
                
                "ALTER TABLE [\(TABLE.TURNOUT_SWITCH)] DROP COLUMN [\(TURNOUT_SWITCH.FEEDBACK_TYPE)]",
                
                "ALTER TABLE [\(TABLE.TURNOUT_SWITCH)] DROP COLUMN [\(TURNOUT_SWITCH.SWITCH_TYPE)]",
                */

          //      "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] ADD [\(SWITCHBOARD_ITEM.GEN_SENSOR_ID)] INT",

          //      "ALTER TABLE [\(TABLE.SENSOR)] ADD [\(SENSOR.FUNCTION_NUMBER)] INT",

          //      "UPDATE [\(TABLE.SENSOR)] SET [\(SENSOR.FUNCTION_NUMBER)] = 1",

          //      "ALTER TABLE [\(TABLE.SENSOR)] ADD [\(SENSOR.FUNCTION_TYPE)] INT",

          //      "UPDATE [\(TABLE.SENSOR)] SET [\(SENSOR.FUNCTION_TYPE)] = 0",

          //      "ALTER TABLE [\(TABLE.LOCONET_DEVICE_CV)] ADD [\(LOCONET_DEVICE_CV.CUSTOM_DESCRIPTION)] TEXT",

          //      "ALTER TABLE [\(TABLE.LOCONET_DEVICE_CV)] ADD [\(LOCONET_DEVICE_CV.CUSTOM_NUMBER_BASE)] INT",

          //      "ALTER TABLE [\(TABLE.LOCONET_DEVICE_CV)] ADD [\(LOCONET_DEVICE_CV.ENABLED)] INT",
/*
                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] DROP COLUMN [\(SWITCHBOARD_ITEM.GEN_SENSOR_CHANNEL_NUMBER)]",
                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] DROP COLUMN [\(SWITCHBOARD_ITEM.SW1_LOCONET_DEVICE_ID)]",
                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] DROP COLUMN [\(SWITCHBOARD_ITEM.SW2_LOCONET_DEVICE_ID)]",
                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] DROP COLUMN [\(SWITCHBOARD_ITEM.SW1_CHANNEL_NUMBER)]",
                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] DROP COLUMN [\(SWITCHBOARD_ITEM.SW2_CHANNEL_NUMBER)]",
                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] DROP COLUMN [\(SWITCHBOARD_ITEM.SW1_SENSOR1_ID)]",
                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] DROP COLUMN [\(SWITCHBOARD_ITEM.SW2_SENSOR1_ID)]",
                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] DROP COLUMN [\(SWITCHBOARD_ITEM.SW1_SENSOR2_ID)]",
                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] DROP COLUMN [\(SWITCHBOARD_ITEM.SW2_SENSOR2_ID)]",
                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] DROP COLUMN [\(SWITCHBOARD_ITEM.SW1_SENSOR1_CHANNEL_NUMBER)]",
                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] DROP COLUMN [\(SWITCHBOARD_ITEM.SW2_SENSOR1_CHANNEL_NUMBER)]",
                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] DROP COLUMN [\(SWITCHBOARD_ITEM.SW1_SENSOR2_CHANNEL_NUMBER)]",
                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] DROP COLUMN [\(SWITCHBOARD_ITEM.SW2_SENSOR2_CHANNEL_NUMBER)]",

                
                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] ADD [\(SWITCHBOARD_ITEM.TRANSPONDER_SENSOR_ID)] INT",
                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] ADD [\(SWITCHBOARD_ITEM.TRACK_FAULT_SENSOR_ID)] INT",
                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] ADD [\(SWITCHBOARD_ITEM.SW1_ID)] INT",
                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] ADD [\(SWITCHBOARD_ITEM.SW1_SENSOR1_ID)] INT",
                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] ADD [\(SWITCHBOARD_ITEM.SW1_SENSOR2_ID)] INT",
 
                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] DROP COLUMN [\(SWITCHBOARD_ITEM.SW2_SENSOR1_ID)]",
                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] DROP COLUMN [\(SWITCHBOARD_ITEM.SW2_SENSOR2_ID)]",

                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] ADD [\(SWITCHBOARD_ITEM.SW2_ID)] INT",
                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] ADD [\(SWITCHBOARD_ITEM.SW2_SENSOR1_ID)] INT",
                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] ADD [\(SWITCHBOARD_ITEM.SW2_SENSOR2_ID)] INT",
 
                

                "DROP TABLE IF EXISTS [\(TABLE.DECODER_FUNCTION)]",

 "DROP TABLE IF EXISTS [\(TABLE.MEMORY_SPACE)]",

 "CREATE TABLE [\(TABLE.MEMORY_SPACE)] (" +
   "[\(MEMORY_SPACE.MEMORY_SPACE_ID)] INT PRIMARY KEY," +
   "[\(MEMORY_SPACE.NODE_ID)]         INT NOT NULL," +
   "[\(MEMORY_SPACE.SPACE)]           INT NOT NULL," +
   "[\(MEMORY_SPACE.MEMORY)]          TEXT NOT NULL" +
 ")",
*/
             /*
                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] DROP COLUMN [\(SWITCHBOARD_ITEM.SW1_ID)]",
                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] DROP COLUMN [\(SWITCHBOARD_ITEM.SW1_SENSOR1_ID)]",
                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] DROP COLUMN [\(SWITCHBOARD_ITEM.SW1_SENSOR2_ID)]",
                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] DROP COLUMN [\(SWITCHBOARD_ITEM.SW2_ID)]",
                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] DROP COLUMN [\(SWITCHBOARD_ITEM.SW2_SENSOR1_ID)]",
                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] DROP COLUMN [\(SWITCHBOARD_ITEM.SW2_SENSOR2_ID)]",

                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] ADD [\(SWITCHBOARD_ITEM.SW1_THROWN_EVENT_ID)] INT",
                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] ADD [\(SWITCHBOARD_ITEM.SW1_CLOSED_EVENT_ID)] INT",
                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] ADD [\(SWITCHBOARD_ITEM.SW1_THROW_EVENT_ID)] INT",
                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] ADD [\(SWITCHBOARD_ITEM.SW1_CLOSE_EVENT_ID)] INT",
                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] ADD [\(SWITCHBOARD_ITEM.SW2_THROWN_EVENT_ID)] INT",
                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] ADD [\(SWITCHBOARD_ITEM.SW2_CLOSED_EVENT_ID)] INT",
                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] ADD [\(SWITCHBOARD_ITEM.SW2_THROW_EVENT_ID)] INT",
                "ALTER TABLE [\(TABLE.SWITCHBOARD_ITEM)] ADD [\(SWITCHBOARD_ITEM.SW2_CLOSE_EVENT_ID)] INT",
*/
                "UPDATE [\(TABLE.VERSION)] SET [\(VERSION.VERSION_NUMBER)] = 31 WHERE [\(VERSION.VERSION_ID)] = 1",
 
             ]
              
              execute(commands: commands)
              
              Version = 29

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

