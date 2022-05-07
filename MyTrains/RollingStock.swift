//
//  RollingStock.swift
//  MyTrains
//
//  Created by Paul Willmott on 07/05/2022.
//

import Foundation

public enum RollingStockType : Int {
  case unknown = -1
  case locomotive = 0
  case wagon = 1
}

public enum TrackElectrificationType : Int {
  case notElectrified = 0
  case thirdRail = 1
  case overhead = 2
}

public class RollingStock : EditorObject, DecoderFunctionDelegate {
  
  // MARK: Constructors

  init(reader:SqliteDataReader) {
    super.init(primaryKey: -1)
    decode(sqliteDataReader: reader)
  }
  
  // MARK: Public Properties
  
  public var rollingStockName : String = "" {
    didSet {
      modified = true
    }
  }
  
  public var networkId : Int = -1 {
    didSet {
      modified = true
    }
  }
  
  public var length : Double = 0.0 {
    didSet {
      modified = true
    }
  }
  
  public var rollingStockType : RollingStockType = .unknown {
    didSet {
      modified = true
    }
  }
  
  public var manufacturerId : Int = -1 {
    didSet {
      modified = true
    }
  }
  
  public var mDecoderManufacturerId : Int = -1 {
    didSet {
      modified = true
    }
  }
  
  public var mDecoderModel : String = "" {
    didSet {
      modified = true
    }
  }
  
  public var mDecoderAddress : Int = 0 {
    didSet {
      modified = true
    }
  }
  
  public var aDecoderManufacturerId : Int = -1 {
    didSet {
      modified = true
    }
  }
  
  public var aDecoderModel : String = "" {
    didSet {
      modified = true
    }
  }
  
  public var aDecoderAddress : Int = 0 {
    didSet {
      modified = true
    }
  }
  
  public var speedSteps : SpeedSteps = .dcc128 {
    didSet {
      modified = true
    }
  }
  
  public var feedbackOccupancyOffsetFront : Double = 0.0 {
    didSet {
      modified = true
    }
  }
  
  public var feedbackOccupancyOffsetRear : Double = 0.0 {
    didSet {
      modified = true
    }
  }
  
  public var scale : Double = 0.0 {
    didSet {
      modified = true
    }
  }
  
  public var trackGauge : TrackGauge = .unknown {
    didSet {
      modified = true
    }
  }
  
  public var maxForwardSpeed : Double = 0.0 {
    didSet {
      modified = true
    }
  }
  
  public var maxBackwardSpeed : Double = 0.0 {
    didSet {
      modified = true
    }
  }
  
  public var unitsLength : LengthUnit = .centimeters {
    didSet {
      modified = true
    }
  }
  
  public var unitsFeedbackOccupancyOffset : LengthUnit = .centimeters {
    didSet {
      modified = true
    }
  }
  
  public var unitsSpeed : SpeedUnit = .milesPerHour {
    didSet {
      modified = true
    }
  }
  
  public var inventoryCode : String = "" {
    didSet {
      modified = true
    }
  }
  
  public var purchaseDate : String = "" {
    didSet {
      modified = true
    }
  }
  
  public var notes : String = "" {
    didSet {
      modified = true
    }
  }
  
  public var locomotiveType : LocomotiveType = .unknown {
    didSet {
      modified = true
    }
  }
  
  // MARK: Decoder Delegate Methods
  
  public func changeState(decoderFunction: DecoderFunction) {
    
  }
  
  // MARK: Database Methods
  
  private func decode(sqliteDataReader:SqliteDataReader?) {
    
    if let reader = sqliteDataReader {
      
      primaryKey = reader.getInt(index: 0)!

      if !reader.isDBNull(index: 1) {
        rollingStockName = reader.getString(index: 1)!
      }
      
      if !reader.isDBNull(index: 2) {
        networkId = reader.getInt(index: 2)!
      }

      if !reader.isDBNull(index: 3) {
        length = reader.getDouble(index: 3)!
      }
      
      if !reader.isDBNull(index: 4) {
        rollingStockType = RollingStockType(rawValue: reader.getInt(index: 4)!) ?? .unknown
      }
      
      if !reader.isDBNull(index: 5) {
        manufacturerId = reader.getInt(index: 5)!
      }

      if !reader.isDBNull(index: 6) {
        mDecoderManufacturerId = reader.getInt(index: 6)!
      }
      
      if !reader.isDBNull(index: 7) {
        mDecoderModel = reader.getString(index: 7)!
      }
      
      if !reader.isDBNull(index: 8) {
        mDecoderAddress = reader.getInt(index: 8)!
      }
      
      if !reader.isDBNull(index: 9) {
        aDecoderManufacturerId = reader.getInt(index: 9)!
      }
      
      if !reader.isDBNull(index: 10) {
        aDecoderModel = reader.getString(index: 10)!
      }
      
      if !reader.isDBNull(index: 11) {
        aDecoderAddress = reader.getInt(index: 11)!
      }
      
      if !reader.isDBNull(index: 12) {
        speedSteps = SpeedSteps(rawValue: reader.getInt(index: 12)!) ?? .dcc128
      }
      
      if !reader.isDBNull(index: 13) {
        feedbackOccupancyOffsetFront = reader.getDouble(index: 13)!
      }
      
      if !reader.isDBNull(index: 14) {
        feedbackOccupancyOffsetRear = reader.getDouble(index: 14)!
      }

      if !reader.isDBNull(index: 15) {
        scale = reader.getDouble(index: 15)!
      }

      if !reader.isDBNull(index: 16) {
        trackGauge = TrackGauge(rawValue: reader.getInt(index: 16)!) ?? .unknown
      }
      
      if !reader.isDBNull(index: 17) {
        maxForwardSpeed = reader.getDouble(index: 17)!
      }

      if !reader.isDBNull(index: 18) {
        maxBackwardSpeed = reader.getDouble(index: 18)!
      }

      if !reader.isDBNull(index: 19) {
        unitsLength = LengthUnit(rawValue: reader.getInt(index: 19)!) ?? .centimeters
      }
      
      if !reader.isDBNull(index: 20) {
        unitsFeedbackOccupancyOffset = LengthUnit(rawValue: reader.getInt(index: 20)!) ?? .centimeters
      }
      
      if !reader.isDBNull(index: 21) {
        unitsSpeed = SpeedUnit(rawValue: reader.getInt(index: 21)!) ?? .milesPerHour
      }
      
      if !reader.isDBNull(index: 22) {
        inventoryCode = reader.getString(index: 22)!
      }

      if !reader.isDBNull(index: 23) {
        purchaseDate = reader.getString(index: 23)!
      }

      if !reader.isDBNull(index: 24) {
        notes = reader.getString(index: 24)!
      }

      if !reader.isDBNull(index: 25) {
        locomotiveType = LocomotiveType(rawValue: reader.getInt(index: 25)!) ?? .unknown
      }

    }
    
    modified = false
    
  }

  public func save() {
    
    if modified {
      
      var sql = ""
      
      if !Database.codeExists(tableName: TABLE.ROLLING_STOCK, primaryKey: ROLLING_STOCK.ROLLING_STOCK_ID, code: primaryKey)! {
        sql = "INSERT INTO [\(TABLE.ROLLING_STOCK)] (" +
        "[\(ROLLING_STOCK.ROLLING_STOCK_ID)], " +
        "[\(ROLLING_STOCK.ROLLING_STOCK_NAME)], " +
        "[\(ROLLING_STOCK.NETWORK_ID)], " +
        "[\(ROLLING_STOCK.LENGTH)], " +
        "[\(ROLLING_STOCK.ROLLING_STOCK_TYPE)], " +
        "[\(ROLLING_STOCK.MANUFACTURER_ID)], " +
        "[\(ROLLING_STOCK.MDECODER_MANUFACTURER_ID)], " +
        "[\(ROLLING_STOCK.MDECODER_MODEL)], " +
        "[\(ROLLING_STOCK.MDECODER_ADDRESS)], " +
        "[\(ROLLING_STOCK.ADECODER_MANUFACTURER_ID)], " +
        "[\(ROLLING_STOCK.ADECODER_MODEL)], " +
        "[\(ROLLING_STOCK.ADECODER_ADDRESS)], " +
        "[\(ROLLING_STOCK.SPEED_STEPS)], " +
        "[\(ROLLING_STOCK.FBOFF_OCC_FRONT)], " +
        "[\(ROLLING_STOCK.FBOFF_OCC_REAR)], " +
        "[\(ROLLING_STOCK.SCALE)], " +
        "[\(ROLLING_STOCK.TRACK_GAUGE)], " +
        "[\(ROLLING_STOCK.MAX_FORWARD_SPEED)], " +
        "[\(ROLLING_STOCK.MAX_BACKWARD_SPEED)], " +
        "[\(ROLLING_STOCK.UNITS_LENGTH)], " +
        "[\(ROLLING_STOCK.UNITS_FBOFF_OCC)], " +
        "[\(ROLLING_STOCK.UNITS_SPEED)], " +
        "[\(ROLLING_STOCK.INVENTORY_CODE)], " +
        "[\(ROLLING_STOCK.PURCHASE_DATE)], " +
        "[\(ROLLING_STOCK.NOTES)], " +
        "[\(ROLLING_STOCK.LOCOMOTIVE_TYPE)]" +
        ") VALUES (" +
        "@\(ROLLING_STOCK.ROLLING_STOCK_ID), " +
        "@\(ROLLING_STOCK.ROLLING_STOCK_NAME), " +
        "@\(ROLLING_STOCK.NETWORK_ID), " +
        "@\(ROLLING_STOCK.LENGTH), " +
        "@\(ROLLING_STOCK.ROLLING_STOCK_TYPE), " +
        "@\(ROLLING_STOCK.MANUFACTURER_ID), " +
        "@\(ROLLING_STOCK.MDECODER_MANUFACTURER_ID), " +
        "@\(ROLLING_STOCK.MDECODER_MODEL), " +
        "@\(ROLLING_STOCK.MDECODER_ADDRESS), " +
        "@\(ROLLING_STOCK.ADECODER_MANUFACTURER_ID), " +
        "@\(ROLLING_STOCK.ADECODER_MODEL), " +
        "@\(ROLLING_STOCK.ADECODER_ADDRESS), " +
        "@\(ROLLING_STOCK.SPEED_STEPS), " +
        "@\(ROLLING_STOCK.FBOFF_OCC_FRONT), " +
        "@\(ROLLING_STOCK.FBOFF_OCC_REAR), " +
        "@\(ROLLING_STOCK.SCALE), " +
        "@\(ROLLING_STOCK.TRACK_GAUGE), " +
        "@\(ROLLING_STOCK.MAX_FORWARD_SPEED), " +
        "@\(ROLLING_STOCK.MAX_BACKWARD_SPEED), " +
        "@\(ROLLING_STOCK.UNITS_LENGTH), " +
        "@\(ROLLING_STOCK.UNITS_FBOFF_OCC), " +
        "@\(ROLLING_STOCK.UNITS_SPEED), " +
        "@\(ROLLING_STOCK.INVENTORY_CODE), " +
        "@\(ROLLING_STOCK.PURCHASE_DATE), " +
        "@\(ROLLING_STOCK.NOTES), " +
        "@\(ROLLING_STOCK.LOCOMOTIVE_TYPE)" +
        ")"
        primaryKey = Database.nextCode(tableName: TABLE.LOCONET_DEVICE, primaryKey: LOCONET_DEVICE.LOCONET_DEVICE_ID)!
      }
      else {
        sql = "UPDATE [\(TABLE.ROLLING_STOCK)] SET " +
        "[\(ROLLING_STOCK.ROLLING_STOCK_NAME)] = @\(ROLLING_STOCK.ROLLING_STOCK_NAME), " +
        "[\(ROLLING_STOCK.NETWORK_ID)] = @\(ROLLING_STOCK.NETWORK_ID), " +
        "[\(ROLLING_STOCK.LENGTH)] = @\(ROLLING_STOCK.LENGTH), " +
        "[\(ROLLING_STOCK.ROLLING_STOCK_TYPE)] = @\(ROLLING_STOCK.ROLLING_STOCK_TYPE), " +
        "[\(ROLLING_STOCK.MANUFACTURER_ID)] = @\(ROLLING_STOCK.MANUFACTURER_ID), " +
        "[\(ROLLING_STOCK.MDECODER_MANUFACTURER_ID)] = @\(ROLLING_STOCK.MDECODER_MANUFACTURER_ID), " +
        "[\(ROLLING_STOCK.MDECODER_MODEL)] = @\(ROLLING_STOCK.MDECODER_MODEL), " +
        "[\(ROLLING_STOCK.MDECODER_ADDRESS)] = @\(ROLLING_STOCK.MDECODER_ADDRESS), " +
        "[\(ROLLING_STOCK.ADECODER_MANUFACTURER_ID)] = @\(ROLLING_STOCK.ADECODER_MANUFACTURER_ID), " +
        "[\(ROLLING_STOCK.ADECODER_MODEL)] = @\(ROLLING_STOCK.ADECODER_MODEL), " +
        "[\(ROLLING_STOCK.ADECODER_ADDRESS)] = @\(ROLLING_STOCK.ADECODER_ADDRESS), " +
        "[\(ROLLING_STOCK.SPEED_STEPS)] = @\(ROLLING_STOCK.SPEED_STEPS), " +
        "[\(ROLLING_STOCK.FBOFF_OCC_FRONT)] = @\(ROLLING_STOCK.FBOFF_OCC_FRONT), " +
        "[\(ROLLING_STOCK.FBOFF_OCC_REAR)] = @\(ROLLING_STOCK.FBOFF_OCC_REAR), " +
        "[\(ROLLING_STOCK.SCALE)] = @\(ROLLING_STOCK.SCALE), " +
        "[\(ROLLING_STOCK.TRACK_GAUGE)] = @\(ROLLING_STOCK.TRACK_GAUGE), " +
        "[\(ROLLING_STOCK.MAX_FORWARD_SPEED)] = @\(ROLLING_STOCK.MAX_FORWARD_SPEED), " +
        "[\(ROLLING_STOCK.MAX_BACKWARD_SPEED)] = @\(ROLLING_STOCK.MAX_BACKWARD_SPEED), " +
        "[\(ROLLING_STOCK.UNITS_LENGTH)] = @\(ROLLING_STOCK.UNITS_LENGTH), " +
        "[\(ROLLING_STOCK.UNITS_FBOFF_OCC)] = @\(ROLLING_STOCK.UNITS_FBOFF_OCC), " +
        "[\(ROLLING_STOCK.UNITS_SPEED)] = @\(ROLLING_STOCK.UNITS_SPEED), " +
        "[\(ROLLING_STOCK.INVENTORY_CODE)] = @\(ROLLING_STOCK.INVENTORY_CODE), " +
        "[\(ROLLING_STOCK.PURCHASE_DATE)] = @\(ROLLING_STOCK.PURCHASE_DATE), " +
        "[\(ROLLING_STOCK.NOTES)] = @\(ROLLING_STOCK.NOTES), " +
        "[\(ROLLING_STOCK.LOCOMOTIVE_TYPE)] = @\(ROLLING_STOCK.LOCOMOTIVE_TYPE) " +
        "WHERE [\(ROLLING_STOCK.ROLLING_STOCK_ID)] = @\(ROLLING_STOCK.ROLLING_STOCK_ID)"
      }

      let conn = Database.getConnection()
      
      let shouldClose = conn.state != .Open
       
      if shouldClose {
         _ = conn.open()
      }
       
      let cmd = conn.createCommand()
       
      cmd.commandText = sql
      
      cmd.parameters.addWithValue(key: "@\(ROLLING_STOCK.ROLLING_STOCK_ID)", value: primaryKey)
      cmd.parameters.addWithValue(key: "@\(ROLLING_STOCK.ROLLING_STOCK_NAME)", value: rollingStockName)
      cmd.parameters.addWithValue(key: "@\(ROLLING_STOCK.NETWORK_ID)", value: networkId)
      cmd.parameters.addWithValue(key: "@\(ROLLING_STOCK.LENGTH)", value: length)
      cmd.parameters.addWithValue(key: "@\(ROLLING_STOCK.ROLLING_STOCK_TYPE)", value: rollingStockType.rawValue)
      cmd.parameters.addWithValue(key: "@\(ROLLING_STOCK.MANUFACTURER_ID)", value: manufacturerId)
      cmd.parameters.addWithValue(key: "@\(ROLLING_STOCK.MDECODER_MANUFACTURER_ID)", value: mDecoderManufacturerId)
      cmd.parameters.addWithValue(key: "@\(ROLLING_STOCK.MDECODER_MODEL)", value: mDecoderModel)
      cmd.parameters.addWithValue(key: "@\(ROLLING_STOCK.MDECODER_ADDRESS)", value: mDecoderAddress)
      cmd.parameters.addWithValue(key: "@\(ROLLING_STOCK.ADECODER_MANUFACTURER_ID)", value: aDecoderManufacturerId)
      cmd.parameters.addWithValue(key: "@\(ROLLING_STOCK.ADECODER_MODEL)", value: aDecoderModel)
      cmd.parameters.addWithValue(key: "@\(ROLLING_STOCK.ADECODER_ADDRESS)", value: aDecoderAddress)
      cmd.parameters.addWithValue(key: "@\(ROLLING_STOCK.SPEED_STEPS)", value: speedSteps.rawValue)
      cmd.parameters.addWithValue(key: "@\(ROLLING_STOCK.FBOFF_OCC_FRONT)", value: feedbackOccupancyOffsetFront)
      cmd.parameters.addWithValue(key: "@\(ROLLING_STOCK.FBOFF_OCC_REAR)", value: feedbackOccupancyOffsetRear)
      cmd.parameters.addWithValue(key: "@\(ROLLING_STOCK.SCALE)", value: scale)
      cmd.parameters.addWithValue(key: "@\(ROLLING_STOCK.TRACK_GAUGE)", value: trackGauge.rawValue)
      cmd.parameters.addWithValue(key: "@\(ROLLING_STOCK.MAX_FORWARD_SPEED)", value: maxForwardSpeed)
      cmd.parameters.addWithValue(key: "@\(ROLLING_STOCK.MAX_BACKWARD_SPEED)", value: maxBackwardSpeed)
      cmd.parameters.addWithValue(key: "@\(ROLLING_STOCK.UNITS_LENGTH)", value: unitsLength.rawValue)
      cmd.parameters.addWithValue(key: "@\(ROLLING_STOCK.UNITS_FBOFF_OCC)", value: unitsFeedbackOccupancyOffset.rawValue)
      cmd.parameters.addWithValue(key: "@\(ROLLING_STOCK.UNITS_SPEED)", value: unitsSpeed.rawValue)
      cmd.parameters.addWithValue(key: "@\(ROLLING_STOCK.INVENTORY_CODE)", value: inventoryCode)
      cmd.parameters.addWithValue(key: "@\(ROLLING_STOCK.PURCHASE_DATE)", value: purchaseDate)
      cmd.parameters.addWithValue(key: "@\(ROLLING_STOCK.NOTES)", value: notes)
      cmd.parameters.addWithValue(key: "@\(ROLLING_STOCK.LOCOMOTIVE_TYPE)", value: locomotiveType.rawValue)

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
        "[\(ROLLING_STOCK.ROLLING_STOCK_ID)], " +
        "[\(ROLLING_STOCK.ROLLING_STOCK_NAME)], " +
        "[\(ROLLING_STOCK.NETWORK_ID)], " +
        "[\(ROLLING_STOCK.LENGTH)], " +
        "[\(ROLLING_STOCK.ROLLING_STOCK_TYPE)], " +
        "[\(ROLLING_STOCK.MANUFACTURER_ID)], " +
        "[\(ROLLING_STOCK.MDECODER_MANUFACTURER_ID)], " +
        "[\(ROLLING_STOCK.MDECODER_MODEL)], " +
        "[\(ROLLING_STOCK.MDECODER_ADDRESS)], " +
        "[\(ROLLING_STOCK.ADECODER_MANUFACTURER_ID)], " +
        "[\(ROLLING_STOCK.ADECODER_MODEL)], " +
        "[\(ROLLING_STOCK.ADECODER_ADDRESS)], " +
        "[\(ROLLING_STOCK.SPEED_STEPS)], " +
        "[\(ROLLING_STOCK.FBOFF_OCC_FRONT)], " +
        "[\(ROLLING_STOCK.FBOFF_OCC_REAR)], " +
        "[\(ROLLING_STOCK.SCALE)], " +
        "[\(ROLLING_STOCK.TRACK_GAUGE)], " +
        "[\(ROLLING_STOCK.MAX_FORWARD_SPEED)], " +
        "[\(ROLLING_STOCK.MAX_BACKWARD_SPEED)], " +
        "[\(ROLLING_STOCK.UNITS_LENGTH)], " +
        "[\(ROLLING_STOCK.UNITS_FBOFF_OCC)], " +
        "[\(ROLLING_STOCK.UNITS_SPEED)], " +
        "[\(ROLLING_STOCK.INVENTORY_CODE)], " +
        "[\(ROLLING_STOCK.PURCHASE_DATE)], " +
        "[\(ROLLING_STOCK.NOTES)], " +
        "[\(ROLLING_STOCK.LOCOMOTIVE_TYPE)]"
    }
  }

}
