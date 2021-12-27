//
//  Locomotive.swift
//  MyTrains
//
//  Created by Paul Willmott on 07/11/2021.
//

import Foundation

public enum MobileDecoderType : Int {
  case analog = 0
  case dcc14 = 1
  case dcc28 = 2
  case dcc28A = 3
  case dcc28T = 4
  case dcc128 = 5
  case dcc128A = 6
  case unknown = 0xffff
}

public enum TrackGauge : Int {
  case em         = 0
  case ho         = 1
  case n          = 2
  case o          = 3
  case o14        = 4
  case oo         = 5
  case ooo        = 6
  case p4         = 7
  case s          = 8
  case scaleSeven = 9
  case tt         = 10
  case tt3        = 11
  case unknown    = 0xffff
}

public enum LocomotiveType : Int {
  case diesel = 0
  case electric = 1
  case electroDiesel = 2
  case steam = 3
  case unknown = 4
}

public enum TrackRestriction : Int {
  case none = 0
  case onlyElectrifiedOverhead = 1
  case onlyElectrifiedThirdRail = 2
}

public class Locomotive : EditorObject {
  
  // Constructors
  
  init(reader:SqliteDataReader) {
    super.init(primaryKey: -1)
    decode(sqliteDataReader: reader)
  }
  
  init() {
    super.init(primaryKey: -1)
  }
  
  // Destructors
  
  deinit {
    
  }
  
  // Private properties
  

  private var _locomotiveName : String = ""
  private var _locomotiveType : LocomotiveType = .unknown
  private var _length : Double = 0.0
  private var _mobileDecoderType : MobileDecoderType = .unknown
  private var _address : Int = 0
  private var _occupancyFeedbackOffsetFront = 0.0
  private var _occupancyFeedbackOffsetRear = 0.0
  private var _trackGauge : TrackGauge = .unknown
  private var _trackRestriction : TrackRestriction = .none
  private var _locomotiveScale : Double = 1.0
  private var _maxForwardSpeed : Double = -1.0
  private var _maxBackwardSpeed : Double = -1.0
  
  private var  modified : Bool = false

  // Public properties
  
  override public func displayString() -> String {
    return locomotiveName
  }
  
  public var locomotiveName : String {
    get {
      return _locomotiveName
    }
    set(value) {
      if value != _locomotiveName {
        _locomotiveName = value
        modified = true
      }
    }
  }
  

  public var locomotiveType : LocomotiveType {
    get {
      return _locomotiveType
    }
    set(value) {
      if value != _locomotiveType {
        _locomotiveType = value
        modified = true
      }
    }
  }
  
  public var length : Double {
    get {
      return _length
    }
    set(value) {
      if value != _length {
        _length = value
        modified = true
      }
    }
  }

  public var mobileDecoderType : MobileDecoderType {
    get {
      return _mobileDecoderType
    }
    set(value) {
      if value != _mobileDecoderType {
        _mobileDecoderType = value
        modified = true
      }
    }
  }
  
  public var address : Int {
    get {
      return _address
    }
    set(value) {
      if value != _address {
        _address = value
        modified = true
      }
    }
  }
  
  public var occupancyFeedbackOffsetFront : Double {
    get {
      return _occupancyFeedbackOffsetFront
    }
    set(value) {
      if value != _occupancyFeedbackOffsetFront {
        _occupancyFeedbackOffsetFront = value
        modified = true
      }
    }
  }
  
  public var occupancyFeedbackOffsetRear : Double {
    get {
      return _occupancyFeedbackOffsetRear
    }
    set(value) {
      if value != _occupancyFeedbackOffsetRear {
        _occupancyFeedbackOffsetRear = value
        modified = true
      }
    }
  }

  public var trackGauge : TrackGauge {
    get {
      return _trackGauge
    }
    set(value) {
      if value != _trackGauge {
        _trackGauge = value
        modified = true
      }
    }
  }
  
  public var trackRestriction : TrackRestriction {
    get {
      return _trackRestriction
    }
    set(value) {
      if value != _trackRestriction {
        _trackRestriction = value
        modified = true
      }
    }
  }
  
  public var locomotiveScale : Double {
    get {
      return _locomotiveScale
    }
    set(value) {
      if value != _locomotiveScale {
        _locomotiveScale = value
        modified = true
      }
    }
  }
  
  public var maxForwardSpeed : Double {
    get {
      return _maxForwardSpeed
    }
    set(value) {
      if value != _maxForwardSpeed {
        _maxForwardSpeed = value
        modified = true
      }
    }
  }
  
  public var maxBackwardSpeed : Double {
    get {
      return _maxBackwardSpeed
    }
    set(value) {
      if value != _maxBackwardSpeed {
        _maxBackwardSpeed = value
        modified = true
      }
    }
  }
  
  // Database Methods
  
  private func decode(sqliteDataReader:SqliteDataReader?) {
    
    if let reader = sqliteDataReader {
      
      primaryKey = reader.getInt(index: 0)!
      
      if !reader.isDBNull(index: 1) {
        locomotiveName = reader.getString(index: 1)!
      }
      
      if !reader.isDBNull(index: 2) {
        locomotiveType = LocomotiveType(rawValue: reader.getInt(index: 2)!) ?? .unknown
      }

      if !reader.isDBNull(index: 3) {
        length = reader.getDouble(index: 3)!
      }
      
      if !reader.isDBNull(index: 4) {
        mobileDecoderType = MobileDecoderType(rawValue: reader.getInt(index: 4)!) ?? .unknown
      }

      if !reader.isDBNull(index: 5) {
        address = reader.getInt(index: 5)!
      }
      
      if !reader.isDBNull(index: 6) {
        occupancyFeedbackOffsetFront = reader.getDouble(index: 6)!
      }
      
      if !reader.isDBNull(index: 7) {
        occupancyFeedbackOffsetRear = reader.getDouble(index: 7)!
      }
 
      if !reader.isDBNull(index: 8) {
        trackGauge = TrackGauge(rawValue: reader.getInt(index: 8)!) ?? .unknown
      }

      if !reader.isDBNull(index: 9) {
        trackRestriction = TrackRestriction(rawValue: reader.getInt(index: 9)!) ?? .none
      }

      if !reader.isDBNull(index: 10) {
        locomotiveScale = reader.getDouble(index: 10)!
      }
      
      if !reader.isDBNull(index: 11) {
        maxForwardSpeed = reader.getDouble(index: 11)!
      }
      
      if !reader.isDBNull(index: 12) {
        maxBackwardSpeed = reader.getDouble(index: 12)!
      }
      
    }
    
    modified = false
    
  }

  public func save() {
    
    if modified {
      
      var sql = ""
      
      if primaryKey == -1 {
        sql = "INSERT INTO [\(TABLE.LOCOMOTIVE)] (" +
        "[\(LOCOMOTIVE.LOCOMOTIVE_ID)], " +
        "[\(LOCOMOTIVE.LOCOMOTIVE_NAME)], " +
        "[\(LOCOMOTIVE.LOCOMOTIVE_TYPE)]," +
        "[\(LOCOMOTIVE.LENGTH)]," +
        "[\(LOCOMOTIVE.DECODER_TYPE)]," +
        "[\(LOCOMOTIVE.ADDRESS)]," +
        "[\(LOCOMOTIVE.FBOFF_OCC_FRONT)]," +
        "[\(LOCOMOTIVE.FBOFF_OCC_REAR)]," +
        "[\(LOCOMOTIVE.TRACK_GAUGE)]," +
        "[\(LOCOMOTIVE.TRACK_RESTRICTION)]," +
        "[\(LOCOMOTIVE.LOCOMOTIVE_SCALE)]," +
        "[\(LOCOMOTIVE.MAX_FORWARD_SPEED)]," +
        "[\(LOCOMOTIVE.MAX_BACKWARD_SPEED)]" +
        ") VALUES (" +
        "@\(LOCOMOTIVE.LOCOMOTIVE_ID), " +
        "@\(LOCOMOTIVE.LOCOMOTIVE_NAME), " +
        "@\(LOCOMOTIVE.LOCOMOTIVE_TYPE), " +
        "@\(LOCOMOTIVE.LENGTH), " +
        "@\(LOCOMOTIVE.DECODER_TYPE), " +
        "@\(LOCOMOTIVE.ADDRESS), " +
        "@\(LOCOMOTIVE.FBOFF_OCC_FRONT), " +
        "@\(LOCOMOTIVE.FBOFF_OCC_REAR), " +
        "@\(LOCOMOTIVE.TRACK_GAUGE), " +
        "@\(LOCOMOTIVE.TRACK_RESTRICTION), " +
        "@\(LOCOMOTIVE.LOCOMOTIVE_SCALE), " +
        "@\(LOCOMOTIVE.MAX_FORWARD_SPEED), " +
        "@\(LOCOMOTIVE.MAX_BACKWARD_SPEED)" +
        ")"
        primaryKey = Database.nextCode(tableName: TABLE.LOCOMOTIVE, primaryKey: LOCOMOTIVE.LOCOMOTIVE_ID)!
      }
      else {
        sql = "UPDATE [\(TABLE.LOCOMOTIVE)] SET " +
        "[\(LOCOMOTIVE.LOCOMOTIVE_NAME)] = @\(LOCOMOTIVE.LOCOMOTIVE_NAME), " +
        "[\(LOCOMOTIVE.LOCOMOTIVE_TYPE)] = @\(LOCOMOTIVE.LOCOMOTIVE_TYPE), " +
        "[\(LOCOMOTIVE.LENGTH)] = @\(LOCOMOTIVE.LENGTH), " +
        "[\(LOCOMOTIVE.DECODER_TYPE)] = @\(LOCOMOTIVE.DECODER_TYPE), " +
        "[\(LOCOMOTIVE.ADDRESS)] = @\(LOCOMOTIVE.ADDRESS), " +
        "[\(LOCOMOTIVE.FBOFF_OCC_FRONT)] = @\(LOCOMOTIVE.FBOFF_OCC_FRONT), " +
        "[\(LOCOMOTIVE.FBOFF_OCC_REAR)] = @\(LOCOMOTIVE.FBOFF_OCC_REAR), " +
        "[\(LOCOMOTIVE.TRACK_GAUGE)] = @\(LOCOMOTIVE.TRACK_GAUGE), " +
        "[\(LOCOMOTIVE.TRACK_RESTRICTION)] = @\(LOCOMOTIVE.TRACK_RESTRICTION), " +
        "[\(LOCOMOTIVE.LOCOMOTIVE_SCALE)] = @\(LOCOMOTIVE.LOCOMOTIVE_SCALE), " +
        "[\(LOCOMOTIVE.MAX_FORWARD_SPEED)] = @\(LOCOMOTIVE.MAX_FORWARD_SPEED), " +
        "[\(LOCOMOTIVE.MAX_BACKWARD_SPEED)] = @\(LOCOMOTIVE.MAX_BACKWARD_SPEED) " +
        "WHERE [\(LOCOMOTIVE.LOCOMOTIVE_ID)] = @\(LOCOMOTIVE.LOCOMOTIVE_ID)"
      }

      let conn = Database.getConnection()
      
      let shouldClose = conn.state != .Open
       
      if shouldClose {
         _ = conn.open()
      }
       
      let cmd = conn.createCommand()
       
      cmd.commandText = sql
      
      cmd.parameters.addWithValue(key: "@\(LOCOMOTIVE.LOCOMOTIVE_ID)", value: primaryKey)
      cmd.parameters.addWithValue(key: "@\(LOCOMOTIVE.LOCOMOTIVE_NAME)", value: locomotiveName)
      cmd.parameters.addWithValue(key: "@\(LOCOMOTIVE.LOCOMOTIVE_TYPE)", value: locomotiveType.rawValue)
      cmd.parameters.addWithValue(key: "@\(LOCOMOTIVE.LENGTH)", value: length)
      cmd.parameters.addWithValue(key: "@\(LOCOMOTIVE.DECODER_TYPE)", value: mobileDecoderType.rawValue)
      cmd.parameters.addWithValue(key: "@\(LOCOMOTIVE.ADDRESS)", value: address)
      cmd.parameters.addWithValue(key: "@\(LOCOMOTIVE.FBOFF_OCC_FRONT)", value: occupancyFeedbackOffsetFront)
      cmd.parameters.addWithValue(key: "@\(LOCOMOTIVE.FBOFF_OCC_REAR)", value: occupancyFeedbackOffsetRear)
      cmd.parameters.addWithValue(key: "@\(LOCOMOTIVE.TRACK_GAUGE)", value: trackGauge.rawValue)
      cmd.parameters.addWithValue(key: "@\(LOCOMOTIVE.TRACK_RESTRICTION)", value: trackRestriction.rawValue)
      cmd.parameters.addWithValue(key: "@\(LOCOMOTIVE.LOCOMOTIVE_SCALE)", value: locomotiveScale)
      cmd.parameters.addWithValue(key: "@\(LOCOMOTIVE.MAX_FORWARD_SPEED)", value: maxForwardSpeed)
      cmd.parameters.addWithValue(key: "@\(LOCOMOTIVE.MAX_BACKWARD_SPEED)", value: maxBackwardSpeed)

      _ = cmd.executeNonQuery()

      if shouldClose {
        conn.close()
      }
      
      modified = false
      
    }

  }

  // Class Properties
  
  public static var columnNames : String {
    get {
      return
        "[\(LOCOMOTIVE.LOCOMOTIVE_ID)], " +
        "[\(LOCOMOTIVE.LOCOMOTIVE_NAME)], " +
        "[\(LOCOMOTIVE.LOCOMOTIVE_TYPE)], " +
        "[\(LOCOMOTIVE.LENGTH)], " +
        "[\(LOCOMOTIVE.DECODER_TYPE)], " +
        "[\(LOCOMOTIVE.ADDRESS)], " +
        "[\(LOCOMOTIVE.FBOFF_OCC_FRONT)], " +
        "[\(LOCOMOTIVE.FBOFF_OCC_REAR)], " +
        "[\(LOCOMOTIVE.TRACK_GAUGE)], " +
        "[\(LOCOMOTIVE.TRACK_RESTRICTION)], " +
        "[\(LOCOMOTIVE.LOCOMOTIVE_SCALE)], " +
        "[\(LOCOMOTIVE.MAX_FORWARD_SPEED)], " +
        "[\(LOCOMOTIVE.MAX_BACKWARD_SPEED)]"
    }
  }
  
  public static var locomotives : [Int:Locomotive] {
    
    get {
    
      let conn = Database.getConnection()
      
      let shouldClose = conn.state != .Open
       
      if shouldClose {
        _ = conn.open()
      }
       
      let cmd = conn.createCommand()
       
      cmd.commandText = "SELECT \(columnNames) FROM [\(TABLE.LOCOMOTIVE)] ORDER BY [\(LOCOMOTIVE.LOCOMOTIVE_NAME)]"

      var result : [Int:Locomotive] = [:]
      
      if let reader = cmd.executeReader() {
           
        while reader.read() {
          let locomotive = Locomotive(reader: reader)
          result[locomotive.primaryKey] = locomotive
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
    let sql = "DELETE FROM [\(TABLE.LOCOMOTIVE)] WHERE [\(LOCOMOTIVE.LOCOMOTIVE_ID)] = \(primaryKey)"
    Database.execute(commands: [sql])
  }
  
}
