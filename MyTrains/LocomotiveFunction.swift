//
//  LocomotiveFunction.swift
//  MyTrains
//
//  Created by Paul Willmott on 01/01/2022.
//

import Foundation

public protocol LocomotiveFunctionDelegate {
  func changeState(locomotiveFunction:LocomotiveFunction)
}

public class LocomotiveFunction : EditorObject {
  
  // MARK: Constructors
  
  init(reader:SqliteDataReader) {
    super.init(primaryKey: -1)
    decode(sqliteDataReader: reader)
  }
  
  init(functionNumber: Int) {
    super.init(primaryKey: -1)
    _functionNumber = functionNumber
  }
  
  // MARK: Destructors
  
  deinit {
    
  }
  
  // MARK: Private properties
  
  private var _locomotiveId : Int = -1
  
  private var _functionNumber : Int = -1
  
  private var _isEnabled : Bool = true
  
  private var _functionDescription : String = ""
  
  private var _isMomentary : Bool = false
  
  private var _duration : Int = 0
  
  private var _isInverted : Bool = false
  
  private var _state : Bool = false
  
  private var  modified : Bool = false
  
  private var _delegate : LocomotiveFunctionDelegate?
  
  private var timer : Timer?

  // MARK: Public properties
  
  override public func displayString() -> String {
    return _functionDescription
  }
  
  public var locomotiveId : Int {
    get {
      return _locomotiveId
    }
    set(value) {
      if value != _locomotiveId {
        _locomotiveId = value
        modified = true
      }
    }
  }
  
  public var functionNumber : Int {
    get {
      return _functionNumber
    }
    set(value) {
      if value != _functionNumber {
        _functionNumber = value
        modified = true
      }
    }
  }
  
  public var isEnabled : Bool {
    get {
      return _isEnabled
    }
    set(value) {
      if value != _isEnabled {
        _isEnabled = value
        modified = true
      }
    }
  }
  
  public var functionDescription : String {
    get {
      return _functionDescription
    }
    set(value) {
      if value != _functionDescription {
        _functionDescription = value
        modified = true
      }
    }
  }
  
  public var isMomentary : Bool {
    get {
      return _isMomentary
    }
    set(value) {
      if value != _isMomentary {
        _isMomentary = value
        modified = true
      }
    }
  }
  
  public var duration : Int {
    get {
      return _duration
    }
    set(value) {
      if value != _duration {
        _duration = value
        modified = true
      }
    }
  }
  
  public var isInverted : Bool {
    get {
      return _isInverted
    }
    set(value) {
      if value != _isInverted {
        _isInverted = value
        modified = true
      }
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
          del.changeState(locomotiveFunction: self)
          if isMomentary {
            if duration > 0 {
              startTimer(timeInterval: Double(duration) / 1000.0)
            }
            else {
              _state = false
              del.changeState(locomotiveFunction: self)
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
      return _functionDescription == "" ? "F\(functionNumber)" : _functionDescription
    }
  }
  
  public var delegate : LocomotiveFunctionDelegate? {
    get {
      return _delegate
    }
    set(value) {
      _delegate = value
    }
  }
  
  // MARK: Private Methods
  
  @objc func timerAction() {
    stopTimer()
    _state = false
    delegate?.changeState(locomotiveFunction: self)
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
        locomotiveId = reader.getInt(index: 1)!
      }
      
      if !reader.isDBNull(index: 2) {
        functionNumber = reader.getInt(index: 2)!
      }
      
      if !reader.isDBNull(index: 3) {
        isEnabled = reader.getInt(index: 3)! == 1
      }

      if !reader.isDBNull(index: 4) {
        functionDescription = reader.getString(index: 4)!
      }

      if !reader.isDBNull(index: 5) {
        isMomentary = reader.getInt(index: 5)! == 1
      }

      if !reader.isDBNull(index: 6) {
        duration = reader.getInt(index: 6)!
      }
      
      if !reader.isDBNull(index: 7) {
        isInverted = reader.getInt(index: 7)! == 1
      }

      if !reader.isDBNull(index: 8) {
        _state = reader.getInt(index: 8)! == 1
      }

    }
    
    modified = false
    
  }

  public func save() {
    
    if modified {
      
      var sql = ""
      
      if primaryKey == -1 {
        sql = "INSERT INTO [\(TABLE.LOCOMOTIVE_FUNCTION)] (" +
        "[\(LOCOMOTIVE_FUNCTION.FUNCTION_ID)], " +
        "[\(LOCOMOTIVE_FUNCTION.LOCOMOTIVE_ID)], " +
        "[\(LOCOMOTIVE_FUNCTION.FUNCTION_NUMBER)]," +
        "[\(LOCOMOTIVE_FUNCTION.ENABLED)]," +
        "[\(LOCOMOTIVE_FUNCTION.FUNCTION_DESCRIPTION)]," +
        "[\(LOCOMOTIVE_FUNCTION.MOMENTARY)]," +
        "[\(LOCOMOTIVE_FUNCTION.DURATION)]," +
        "[\(LOCOMOTIVE_FUNCTION.INVERTED)]," +
        "[\(LOCOMOTIVE_FUNCTION.STATE)]" +
        ") VALUES (" +
        "@\(LOCOMOTIVE_FUNCTION.FUNCTION_ID), " +
        "@\(LOCOMOTIVE_FUNCTION.LOCOMOTIVE_ID), " +
        "@\(LOCOMOTIVE_FUNCTION.FUNCTION_NUMBER), " +
        "@\(LOCOMOTIVE_FUNCTION.ENABLED), " +
        "@\(LOCOMOTIVE_FUNCTION.FUNCTION_DESCRIPTION), " +
        "@\(LOCOMOTIVE_FUNCTION.MOMENTARY), " +
        "@\(LOCOMOTIVE_FUNCTION.DURATION), " +
        "@\(LOCOMOTIVE_FUNCTION.INVERTED), " +
        "@\(LOCOMOTIVE_FUNCTION.STATE)" +
        ")"
        primaryKey = Database.nextCode(tableName: TABLE.LOCOMOTIVE_FUNCTION, primaryKey: LOCOMOTIVE_FUNCTION.FUNCTION_ID)!
      }
      else {
        sql = "UPDATE [\(TABLE.LOCOMOTIVE_FUNCTION)] SET " +
        "[\(LOCOMOTIVE_FUNCTION.FUNCTION_ID)] = @\(LOCOMOTIVE_FUNCTION.FUNCTION_ID), " +
        "[\(LOCOMOTIVE_FUNCTION.LOCOMOTIVE_ID)] = @\(LOCOMOTIVE_FUNCTION.LOCOMOTIVE_ID), " +
        "[\(LOCOMOTIVE_FUNCTION.FUNCTION_NUMBER)] = @\(LOCOMOTIVE_FUNCTION.FUNCTION_NUMBER), " +
        "[\(LOCOMOTIVE_FUNCTION.ENABLED)] = @\(LOCOMOTIVE_FUNCTION.ENABLED), " +
        "[\(LOCOMOTIVE_FUNCTION.FUNCTION_DESCRIPTION)] = @\(LOCOMOTIVE_FUNCTION.FUNCTION_DESCRIPTION), " +
        "[\(LOCOMOTIVE_FUNCTION.MOMENTARY)] = @\(LOCOMOTIVE_FUNCTION.MOMENTARY), " +
        "[\(LOCOMOTIVE_FUNCTION.DURATION)] = @\(LOCOMOTIVE_FUNCTION.DURATION), " +
        "[\(LOCOMOTIVE_FUNCTION.INVERTED)] = @\(LOCOMOTIVE_FUNCTION.INVERTED), " +
        "[\(LOCOMOTIVE_FUNCTION.STATE)] = @\(LOCOMOTIVE_FUNCTION.STATE) " +
        "WHERE [\(LOCOMOTIVE_FUNCTION.FUNCTION_ID)] = @\(LOCOMOTIVE_FUNCTION.FUNCTION_ID)"
      }

      let conn = Database.getConnection()
      
      let shouldClose = conn.state != .Open
       
      if shouldClose {
         _ = conn.open()
      }
       
      let cmd = conn.createCommand()
       
      cmd.commandText = sql
 
      cmd.parameters.addWithValue(key: "@\(LOCOMOTIVE_FUNCTION.FUNCTION_ID)", value: primaryKey)
      cmd.parameters.addWithValue(key: "@\(LOCOMOTIVE_FUNCTION.LOCOMOTIVE_ID)", value: locomotiveId)
      cmd.parameters.addWithValue(key: "@\(LOCOMOTIVE_FUNCTION.FUNCTION_NUMBER)", value: functionNumber)
      cmd.parameters.addWithValue(key: "@\(LOCOMOTIVE_FUNCTION.ENABLED)", value: isEnabled ? 1 : 0)
      cmd.parameters.addWithValue(key: "@\(LOCOMOTIVE_FUNCTION.FUNCTION_DESCRIPTION)", value: functionDescription)
      cmd.parameters.addWithValue(key: "@\(LOCOMOTIVE_FUNCTION.MOMENTARY)", value: isMomentary ? 1 : 0)
      cmd.parameters.addWithValue(key: "@\(LOCOMOTIVE_FUNCTION.DURATION)", value: duration)
      cmd.parameters.addWithValue(key: "@\(LOCOMOTIVE_FUNCTION.INVERTED)", value: isInverted ? 1 : 0)
      cmd.parameters.addWithValue(key: "@\(LOCOMOTIVE_FUNCTION.STATE)", value: state ? 1 : 0)

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
        "[\(LOCOMOTIVE_FUNCTION.FUNCTION_ID)], " +
        "[\(LOCOMOTIVE_FUNCTION.LOCOMOTIVE_ID)], " +
        "[\(LOCOMOTIVE_FUNCTION.FUNCTION_NUMBER)], " +
        "[\(LOCOMOTIVE_FUNCTION.ENABLED)], " +
        "[\(LOCOMOTIVE_FUNCTION.FUNCTION_DESCRIPTION)], " +
        "[\(LOCOMOTIVE_FUNCTION.MOMENTARY)], " +
        "[\(LOCOMOTIVE_FUNCTION.DURATION)], " +
        "[\(LOCOMOTIVE_FUNCTION.INVERTED)], " +
        "[\(LOCOMOTIVE_FUNCTION.STATE)]"
    }
  }
  
  public static func functions(locomotive: Locomotive) -> [LocomotiveFunction] {
    
    let conn = Database.getConnection()
      
    let shouldClose = conn.state != .Open
       
    if shouldClose {
      _ = conn.open()
    }
       
    let cmd = conn.createCommand()
       
    cmd.commandText = "SELECT \(columnNames) FROM [\(TABLE.LOCOMOTIVE_FUNCTION)] WHERE [\(LOCOMOTIVE_FUNCTION.LOCOMOTIVE_ID)] = \(locomotive.primaryKey) ORDER BY [\(LOCOMOTIVE_FUNCTION.FUNCTION_NUMBER)]"

    var result : [LocomotiveFunction] = []
      
    if let reader = cmd.executeReader() {
           
      while reader.read() {
        let fn = LocomotiveFunction(reader: reader)
        fn.delegate = locomotive
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
    let sql = "DELETE FROM [\(TABLE.LOCOMOTIVE_FUNCTION)] WHERE [\(LOCOMOTIVE_FUNCTION.FUNCTION_ID)] = \(primaryKey)"
    Database.execute(commands: [sql])
  }

}
