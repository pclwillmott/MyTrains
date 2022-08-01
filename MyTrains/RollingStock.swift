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

public class RollingStock : EditorObject, DecoderFunctionDelegate {
  
  // MARK: Constructors

  init(reader:SqliteDataReader) {
    super.init(primaryKey: -1)
    decode(sqliteDataReader: reader)
    functions = DecoderFunction.functions(rollingStock: self, decoderType: .mobile)
    _cvs = DecoderCV.cvs(rollingStock: self, decoderType: .mobile)
    speedProfile = SpeedProfile.speedProfile(rollingStock: self)
  }
  
  override init(primaryKey:Int) {
    super.init(primaryKey: primaryKey)
    for fn in 0...28 {
      let decoderFunc = DecoderFunction(decoderType: .mobile, functionNumber: fn)
      decoderFunc.delegate = self
      functions.append(decoderFunc)
    }
    for cvNumber in 1...256 {
      let cv = DecoderCV(decoderType: .mobile, cvNumber: cvNumber)
      _cvs[cv.cvNumber] = cv
    }
    for stepNumber in 1...127 {
      let sp = SpeedProfile(stepNumber: stepNumber)
      speedProfile.append(sp)
    }
  }
  
  // MARK: Private Properties
  
  private var _cvs : [Int:DecoderCV] = [:]
  
  // MARK: Public Properties
  
  public var functions : [DecoderFunction] = []
  
  public var speedProfile : [SpeedProfile] = []
  
  public var cvs : [Int:DecoderCV] {
    get {
      return _cvs
    }
  }
  
  public var cvsSorted : [DecoderCV] {
    get {
      
      var result : [DecoderCV] = []
      
      for cv in _cvs {
        result.append(cv.value)
      }
      
      return result.sorted {
        $0.cvNumber < $1.cvNumber
      }
      
    }
  }
  
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
  
  public var trackGauge : TrackGauge = TrackGauge.defaultValue {
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
  
  public var unitsLength : UnitLength = UnitLength.defaultValue {
    didSet {
      modified = true
    }
  }
  
  public var unitsFeedbackOccupancyOffset : UnitLength = UnitLength.defaultValue {
    didSet {
      modified = true
    }
  }
  
  public var unitsSpeed : UnitSpeed = UnitSpeed.defaultValue {
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
  
  public var mDecoderInstalled : Bool = false {
    didSet {
      modified = true
    }
  }
  
  public var aDecoderInstalled : Bool = false {
    didSet {
      modified = true
    }
  }
  
  public var flags : Int64 = 0 {
    didSet {
      modified = true
    }
  }

  // MARK: Public Methods
  
  override public func displayString() -> String {
    return rollingStockName
  }
  
  public func getCV(cvNumber: Int) -> DecoderCV? {
    if cvNumber < 1 {
      return nil
    }
    return _cvs[cvNumber]
  }
  
  public func getCV(primaryPageIndex: Int, secondaryPageIndex: Int, cvNumber: Int) -> DecoderCV? {
    let cv = DecoderCV.indexedCvNumber(primaryPageIndex: primaryPageIndex, secondaryPageIndex: secondaryPageIndex, cvNumber: cvNumber)
    return _cvs[cv]
  }
  
  public func updateCVS(cv: DecoderCV) {
    cv.rollingStockId = self.primaryKey
    _cvs[cv.cvNumber] = cv
    cv.save()
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
        trackGauge = TrackGauge(rawValue: reader.getInt(index: 16)!) ?? TrackGauge.defaultValue
      }
      
      if !reader.isDBNull(index: 17) {
        maxForwardSpeed = reader.getDouble(index: 17)!
      }

      if !reader.isDBNull(index: 18) {
        maxBackwardSpeed = reader.getDouble(index: 18)!
      }

      if !reader.isDBNull(index: 19) {
        unitsLength = UnitLength(rawValue: reader.getInt(index: 19)!) ?? UnitLength.defaultValue
      }
      
      if !reader.isDBNull(index: 20) {
        unitsFeedbackOccupancyOffset = UnitLength(rawValue: reader.getInt(index: 20)!) ?? UnitLength.defaultValue
      }
      
      if !reader.isDBNull(index: 21) {
        unitsSpeed = UnitSpeed(rawValue: reader.getInt(index: 21)!) ?? UnitSpeed.defaultValue
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

      if !reader.isDBNull(index: 26) {
        mDecoderInstalled = reader.getBool(index: 26)!
      }

      if !reader.isDBNull(index: 27) {
        aDecoderInstalled = reader.getBool(index: 27)!
      }

      if !reader.isDBNull(index: 28) {
        flags = reader.getInt64(index: 28)!
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
        "[\(ROLLING_STOCK.LOCOMOTIVE_TYPE)], " +
        "[\(ROLLING_STOCK.MDECODER_INSTALLED)], " +
        "[\(ROLLING_STOCK.ADECODER_INSTALLED)], " +
        "[\(ROLLING_STOCK.FLAGS)]" +
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
        "@\(ROLLING_STOCK.LOCOMOTIVE_TYPE), " +
        "@\(ROLLING_STOCK.MDECODER_INSTALLED), " +
        "@\(ROLLING_STOCK.ADECODER_INSTALLED), " +
        "@\(ROLLING_STOCK.FLAGS)" +
        ")"
        primaryKey = Database.nextCode(tableName: TABLE.ROLLING_STOCK, primaryKey: ROLLING_STOCK.ROLLING_STOCK_ID)!
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
        "[\(ROLLING_STOCK.LOCOMOTIVE_TYPE)] = @\(ROLLING_STOCK.LOCOMOTIVE_TYPE), " +
        "[\(ROLLING_STOCK.MDECODER_INSTALLED)] = @\(ROLLING_STOCK.MDECODER_INSTALLED), " +
        "[\(ROLLING_STOCK.ADECODER_INSTALLED)] = @\(ROLLING_STOCK.ADECODER_INSTALLED), " +
        "[\(ROLLING_STOCK.FLAGS)] = @\(ROLLING_STOCK.FLAGS) " +
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
      cmd.parameters.addWithValue(key: "@\(ROLLING_STOCK.MDECODER_INSTALLED)", value: mDecoderInstalled)
      cmd.parameters.addWithValue(key: "@\(ROLLING_STOCK.ADECODER_INSTALLED)", value: aDecoderInstalled)
      cmd.parameters.addWithValue(key: "@\(ROLLING_STOCK.FLAGS)", value: flags)

      _ = cmd.executeNonQuery()
      
      for fn in functions {
        fn.rollingStockId = primaryKey
        fn.save()
      }
      
      for (_, cv) in _cvs {
        cv.rollingStockId = primaryKey
        cv.save()
      }
      
      for sp in speedProfile {
        sp.rollingStockId = primaryKey
        sp.save()
      }
      
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
        "[\(ROLLING_STOCK.LOCOMOTIVE_TYPE)], " +
        "[\(ROLLING_STOCK.MDECODER_INSTALLED)], " +
        "[\(ROLLING_STOCK.ADECODER_INSTALLED)], " +
        "[\(ROLLING_STOCK.FLAGS)]"
    }
  }

  public static func delete(primaryKey: Int) {
    let sql = [
      "DELETE FROM [\(TABLE.DECODER_CV)] WHERE [\(DECODER_CV.ROLLING_STOCK_ID)] = \(primaryKey)",
      "DELETE FROM [\(TABLE.DECODER_FUNCTION)] WHERE [\(DECODER_FUNCTION.ROLLING_STOCK_ID)] = \(primaryKey)",
      "DELETE FROM [\(TABLE.SPEED_PROFILE)] WHERE [\(SPEED_PROFILE.ROLLING_STOCK_ID)] = \(primaryKey)",
      "DELETE FROM [\(TABLE.ROLLING_STOCK)] WHERE [\(ROLLING_STOCK.ROLLING_STOCK_ID)] = \(primaryKey)",
    ]
    
    Database.execute(commands: sql)
  }

  public static var rollingStock : [Int:RollingStock] {
    
    get {
    
      let conn = Database.getConnection()
      
      let shouldClose = conn.state != .Open
       
      if shouldClose {
        _ = conn.open()
      }
       
      let cmd = conn.createCommand()
       
      cmd.commandText = "SELECT \(columnNames) FROM [\(TABLE.ROLLING_STOCK)]"

      var result : [Int:RollingStock] = [:]
      
      if let reader = cmd.executeReader() {
           
        while reader.read() {
          let rs = RollingStock(reader: reader)
          if rs.rollingStockType == .locomotive {
            let loco = Locomotive(reader: reader)
            result[loco.primaryKey] = loco
          }
          else {
            result[rs.primaryKey] = rs
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

}
