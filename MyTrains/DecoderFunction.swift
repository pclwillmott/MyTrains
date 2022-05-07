//
//  LocomotiveFunction.swift
//  MyTrains
//
//  Created by Paul Willmott on 01/01/2022.
//

import Foundation

public protocol DecoderFunctionDelegate {
  func changeState(decoderFunction: DecoderFunction)
}

public enum DecoderType : Int {
  case mobile = 0
  case accessory = 1
}

public class DecoderFunction : EditorObject {
  
  // MARK: Constructors
  
  init(reader:SqliteDataReader) {
    super.init(primaryKey: -1)
    decode(sqliteDataReader: reader)
  }
  
  init(decoderType: DecoderType, functionNumber: Int) {
    super.init(primaryKey: -1)
    self.decoderType = decoderType
    self.functionNumber = functionNumber
  }
  
  // MARK: Destructors
  
  deinit {
    stopTimer()
  }
  
  // MARK: Private properties
  
  private var timer : Timer?
  
  private var _state : Bool = false

  // MARK: Public properties
  
  override public func displayString() -> String {
    return functionDescription
  }
  
  public var newIsEnabled : Bool = true
  
  public var newFunctionDescription : String = ""
  
  public var newIsMomentary : Bool = false
  
  public var newDuration : Int = 0
  
  public var newIsInverted : Bool = false
  
  public var rollingStockId : Int  = -1 {
    didSet {
      modified = true
    }
  }
  
  public var decoderType : DecoderType = .mobile {
    didSet {
      modified = true
    }
  }
  
  public var functionNumber : Int = -1 {
    didSet {
      modified = true
    }
  }
  
  public var isEnabled : Bool = true {
    didSet {
      newIsEnabled = isEnabled
      modified = true
    }
  }
  
  public var functionDescription : String = "" {
    didSet {
      newFunctionDescription = functionDescription
      modified = true
    }
  }
  
  public var isMomentary : Bool = true {
    didSet {
      newIsMomentary = isMomentary
      modified = true
    }
  }
  
  public var duration : Int = 0 {
    didSet {
      newDuration = duration
      modified = true
    }
  }
  
  public var isInverted : Bool = false {
    didSet {
      newIsInverted = isInverted
      modified = true
    }
  }
  
  public var state : Bool {
    get {
      return _state
    }
    set(value) {
      if value != _state {
        _state = value
        modified = true
        if let del = delegate {
          del.changeState(decoderFunction: self)
          if isMomentary {
            if duration > 0 {
              startTimer(timeInterval: Double(duration) / 1000.0)
            }
            else {
              _state = false
              del.changeState(decoderFunction: self)
            }
          }
        }
      }
    }
  }
  
  public var stateToSend : Bool {
    get {
      return isInverted ? !state : state
    }
  }
  
  public var toolTip : String {
    get {
      return functionDescription == "" ? "F\(functionNumber)" : functionDescription
    }
  }
  
  public var delegate : DecoderFunctionDelegate?
  
  // MARK: Private Methods
  
  @objc func timerAction() {
    stopTimer()
    _state = false
    delegate?.changeState(decoderFunction: self)
  }
  
  func startTimer(timeInterval:TimeInterval) {
    timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(timerAction), userInfo: nil, repeats: false)
  }
  
  func stopTimer() {
    timer?.invalidate()
    timer = nil
  }
  
  // MARK: Database Methods
  
  private func decode(sqliteDataReader:SqliteDataReader?) {
    
    if let reader = sqliteDataReader {
      
      primaryKey = reader.getInt(index: 0)!
      
      if !reader.isDBNull(index: 1) {
        rollingStockId = reader.getInt(index: 1)!
      }
      
      if !reader.isDBNull(index: 2) {
        decoderType = DecoderType(rawValue: reader.getInt(index: 2)!) ?? .mobile
      }
      
      if !reader.isDBNull(index: 3) {
        functionNumber = reader.getInt(index: 3)!
      }
      
      if !reader.isDBNull(index: 4) {
        isEnabled = reader.getInt(index: 4)! == 1
      }

      if !reader.isDBNull(index: 5) {
        functionDescription = reader.getString(index: 5)!
      }

      if !reader.isDBNull(index: 6) {
        isMomentary = reader.getInt(index: 6)! == 1
      }

      if !reader.isDBNull(index: 7) {
        duration = reader.getInt(index: 7)!
      }
      
      if !reader.isDBNull(index: 8) {
        isInverted = reader.getInt(index: 8)! == 1
      }

      if !reader.isDBNull(index: 9) {
        _state = reader.getInt(index: 9)! == 1
      }

      newIsEnabled = isEnabled
      
      newFunctionDescription = functionDescription
      
      newIsMomentary = isMomentary
      
      newDuration = duration
      
      newIsInverted = isInverted
      
    }
    
    modified = false
    
  }

  public func save() {
    
    isEnabled = newIsEnabled
    functionDescription = newFunctionDescription
    isMomentary = newIsMomentary
    duration = newDuration
    isInverted = newIsInverted
    
    if modified {
      
      var sql = ""
      
      if primaryKey == -1 {
        sql = "INSERT INTO [\(TABLE.DECODER_FUNCTION)] (" +
        "[\(DECODER_FUNCTION.DECODER_FUNCTION_ID)], " +
        "[\(DECODER_FUNCTION.ROLLING_STOCK_ID)], " +
        "[\(DECODER_FUNCTION.DECODER_TYPE)], " +
        "[\(DECODER_FUNCTION.FUNCTION_NUMBER)]," +
        "[\(DECODER_FUNCTION.ENABLED)]," +
        "[\(DECODER_FUNCTION.FUNCTION_DESCRIPTION)]," +
        "[\(DECODER_FUNCTION.MOMENTARY)]," +
        "[\(DECODER_FUNCTION.DURATION)]," +
        "[\(DECODER_FUNCTION.INVERTED)]," +
        "[\(DECODER_FUNCTION.STATE)]" +
        ") VALUES (" +
        "@\(DECODER_FUNCTION.DECODER_FUNCTION_ID), " +
        "@\(DECODER_FUNCTION.ROLLING_STOCK_ID), " +
        "@\(DECODER_FUNCTION.DECODER_TYPE), " +
        "@\(DECODER_FUNCTION.FUNCTION_NUMBER), " +
        "@\(DECODER_FUNCTION.ENABLED), " +
        "@\(DECODER_FUNCTION.FUNCTION_DESCRIPTION), " +
        "@\(DECODER_FUNCTION.MOMENTARY), " +
        "@\(DECODER_FUNCTION.DURATION), " +
        "@\(DECODER_FUNCTION.INVERTED), " +
        "@\(DECODER_FUNCTION.STATE)" +
        ")"
        primaryKey = Database.nextCode(tableName: TABLE.DECODER_FUNCTION, primaryKey: DECODER_FUNCTION.DECODER_FUNCTION_ID)!
      }
      else {
        sql = "UPDATE [\(TABLE.DECODER_FUNCTION)] SET " +
        "[\(DECODER_FUNCTION.ROLLING_STOCK_ID)] = @\(DECODER_FUNCTION.ROLLING_STOCK_ID), " +
        "[\(DECODER_FUNCTION.DECODER_TYPE)] = @\(DECODER_FUNCTION.DECODER_TYPE), " +
        "[\(DECODER_FUNCTION.FUNCTION_NUMBER)] = @\(DECODER_FUNCTION.FUNCTION_NUMBER), " +
        "[\(DECODER_FUNCTION.ENABLED)] = @\(DECODER_FUNCTION.ENABLED), " +
        "[\(DECODER_FUNCTION.FUNCTION_DESCRIPTION)] = @\(DECODER_FUNCTION.FUNCTION_DESCRIPTION), " +
        "[\(DECODER_FUNCTION.MOMENTARY)] = @\(DECODER_FUNCTION.MOMENTARY), " +
        "[\(DECODER_FUNCTION.DURATION)] = @\(DECODER_FUNCTION.DURATION), " +
        "[\(DECODER_FUNCTION.INVERTED)] = @\(DECODER_FUNCTION.INVERTED), " +
        "[\(DECODER_FUNCTION.STATE)] = @\(DECODER_FUNCTION.STATE) " +
        "WHERE [\(DECODER_FUNCTION.DECODER_FUNCTION_ID)] = @\(DECODER_FUNCTION.DECODER_FUNCTION_ID)"
      }

      let conn = Database.getConnection()
      
      let shouldClose = conn.state != .Open
       
      if shouldClose {
         _ = conn.open()
      }
       
      let cmd = conn.createCommand()
       
      cmd.commandText = sql
 
      cmd.parameters.addWithValue(key: "@\(DECODER_FUNCTION.DECODER_FUNCTION_ID)", value: primaryKey)
      cmd.parameters.addWithValue(key: "@\(DECODER_FUNCTION.ROLLING_STOCK_ID)", value: rollingStockId)
      cmd.parameters.addWithValue(key: "@\(DECODER_FUNCTION.DECODER_TYPE)", value: decoderType.rawValue)
      cmd.parameters.addWithValue(key: "@\(DECODER_FUNCTION.FUNCTION_NUMBER)", value: functionNumber)
      cmd.parameters.addWithValue(key: "@\(DECODER_FUNCTION.ENABLED)", value: isEnabled ? 1 : 0)
      cmd.parameters.addWithValue(key: "@\(DECODER_FUNCTION.FUNCTION_DESCRIPTION)", value: functionDescription)
      cmd.parameters.addWithValue(key: "@\(DECODER_FUNCTION.MOMENTARY)", value: isMomentary ? 1 : 0)
      cmd.parameters.addWithValue(key: "@\(DECODER_FUNCTION.DURATION)", value: duration)
      cmd.parameters.addWithValue(key: "@\(DECODER_FUNCTION.INVERTED)", value: isInverted ? 1 : 0)
      cmd.parameters.addWithValue(key: "@\(DECODER_FUNCTION.STATE)", value: state ? 1 : 0)

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
        "[\(DECODER_FUNCTION.DECODER_FUNCTION_ID)], " +
        "[\(DECODER_FUNCTION.ROLLING_STOCK_ID)], " +
        "[\(DECODER_FUNCTION.DECODER_TYPE)], " +
        "[\(DECODER_FUNCTION.FUNCTION_NUMBER)], " +
        "[\(DECODER_FUNCTION.ENABLED)], " +
        "[\(DECODER_FUNCTION.FUNCTION_DESCRIPTION)], " +
        "[\(DECODER_FUNCTION.MOMENTARY)], " +
        "[\(DECODER_FUNCTION.DURATION)], " +
        "[\(DECODER_FUNCTION.INVERTED)], " +
        "[\(DECODER_FUNCTION.STATE)]"
    }
  }
  
  public static func functions(rollingStock: RollingStock, decoderType: DecoderType) -> [DecoderFunction] {
    
    let conn = Database.getConnection()
      
    let shouldClose = conn.state != .Open
       
    if shouldClose {
      _ = conn.open()
    }
       
    let cmd = conn.createCommand()
       
    cmd.commandText = "SELECT \(columnNames) FROM [\(TABLE.DECODER_FUNCTION)] WHERE [\(DECODER_FUNCTION.ROLLING_STOCK_ID)] = \(rollingStock.primaryKey) AND [\(DECODER_FUNCTION.DECODER_TYPE)] = \(decoderType.rawValue) ORDER BY [\(DECODER_FUNCTION.FUNCTION_NUMBER)]"

    var result : [DecoderFunction] = []
      
    if let reader = cmd.executeReader() {
           
      while reader.read() {
        let fn = DecoderFunction(reader: reader)
        fn.delegate = rollingStock
        result.append(fn)
      }
           
      reader.close()
           
    }
      
    if shouldClose {
      conn.close()
    }

    return result
      
  }

  public static func delete(primaryKey: Int) {
    let sql = "DELETE FROM [\(TABLE.DECODER_FUNCTION)] WHERE [\(DECODER_FUNCTION.DECODER_FUNCTION_ID)] = \(primaryKey)"
    Database.execute(commands: [sql])
  }

}
