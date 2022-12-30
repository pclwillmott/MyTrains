//
//  LocoNetDeviceCV.swift
//  MyTrains
//
//  Created by Paul Willmott on 27/12/2022.
//

import Foundation

public class LocoNetDeviceCV : EditorObject {
  
  // MARK: Constructors
  
  init(reader:SqliteDataReader) {
    super.init(primaryKey: -1)
    decode(sqliteDataReader: reader)
  }
  
  init() {
    super.init(primaryKey: -1)
  }
  
  // MARK: Private Properties
  
  private var _newValue : String = ""
  
  // MARK: Public Properties
 
  
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
  
  public var cvNumber : Int = -1 {
    didSet {
      modified = true
    }
  }
  
  public var cvValue : Int = -1 {
    didSet {
      modified = true
      nextCVValue = cvValue
    }
  }

  public var nextCVValue : Int = -1
  
  public var defaultValue : Int = -1 {
    didSet {
      modified = true
      nextDefaultValue = defaultValue
    }
  }
  
  public var nextDefaultValue : Int = -1
  
  public var customDescription : String = "" {
    didSet {
      modified = true
      nextCustomDescription = customDescription
    }
  }
  
  public var nextCustomDescription : String = ""

  public var customNumberBase : CVNumberBase = .defaultValue {
    didSet {
      modified = true
      nextCustomNumberBase = customNumberBase
    }
  }
  
  public var nextCustomNumberBase : CVNumberBase = .defaultValue
  
  public var isEnabled : Bool = true {
    didSet {
      modified = true
      nextIsEnabled = isEnabled
    }
  }
  
  public var nextIsEnabled : Bool = true
  
  public var newValue : String {
    get {
      return _newValue
    }
    set(value) {
      _newValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
  }
  
  public var newValueNumber : Int? {
    get {
      return Int.fromMultiBaseString(stringValue: newValue)
    }
  }
  
  public var displayDefaultValue : String {
    get {
      return nextCustomNumberBase.toString(value: nextDefaultValue)
    }
  }
  
  public var displayCVValue : String {
    get {
      return nextCustomNumberBase.toString(value: nextCVValue)
    }
  }
  
  public var cvDescription : String {
    get {
      if let description = TC64.cvDescriptions[cvNumber] {
        return description
      }
      return ""
    }
  }
  
  // MARK: Private Methods
    
  // MARK: Public Methods
  
  override public func displayString() -> String {
    return customDescription == "" ? cvDescription : nextCustomDescription
  }

  // MARK: Public Methods
  
  // MARK: Database Methods
  
  private func decode(sqliteDataReader: SqliteDataReader?) {

    if let reader = sqliteDataReader {
      
      primaryKey = reader.getInt(index: 0)!
      
      if !reader.isDBNull(index: 1) {
        locoNetDeviceId = reader.getInt(index: 1)!
      }
      
      if !reader.isDBNull(index: 2) {
        cvNumber = reader.getInt(index: 2)!
      }
      
      if !reader.isDBNull(index: 3) {
        cvValue = reader.getInt(index: 3)!
      }
            
      if !reader.isDBNull(index: 4) {
        defaultValue = reader.getInt(index: 4)!
      }
            
      if !reader.isDBNull(index: 5) {
        customDescription = reader.getString(index: 5)!
      }
            
      if !reader.isDBNull(index: 6) {
        customNumberBase = CVNumberBase(rawValue: reader.getInt(index: 6)!) ?? CVNumberBase.defaultValue
      }
            
      if !reader.isDBNull(index: 7) {
        isEnabled = reader.getBool(index: 7)!
      }
            
    }
    
    modified = false
    
  }

  public func save() {
    
    cvValue = nextCVValue
    defaultValue = nextDefaultValue
    customDescription = nextCustomDescription
    customNumberBase = nextCustomNumberBase
    isEnabled = nextIsEnabled
    
    if modified {
      
      var sql = ""

      if primaryKey == -1 {
        sql = "INSERT INTO [\(TABLE.LOCONET_DEVICE_CV)] (" +
        "[\(LOCONET_DEVICE_CV.LOCONET_DEVICE_CV_ID)], " +
        "[\(LOCONET_DEVICE_CV.LOCONET_DEVICE_ID)], " +
        "[\(LOCONET_DEVICE_CV.CV_NUMBER)], " +
        "[\(LOCONET_DEVICE_CV.CV_VALUE)]," +
        "[\(LOCONET_DEVICE_CV.DEFAULT_VALUE)]," +
        "[\(LOCONET_DEVICE_CV.CUSTOM_DESCRIPTION)]," +
        "[\(LOCONET_DEVICE_CV.CUSTOM_NUMBER_BASE)]," +
        "[\(LOCONET_DEVICE_CV.ENABLED)]" +
        ") VALUES (" +
        "@\(LOCONET_DEVICE_CV.LOCONET_DEVICE_CV_ID), " +
        "@\(LOCONET_DEVICE_CV.LOCONET_DEVICE_ID), " +
        "@\(LOCONET_DEVICE_CV.CV_NUMBER)," +
        "@\(LOCONET_DEVICE_CV.CV_VALUE)," +
        "@\(LOCONET_DEVICE_CV.DEFAULT_VALUE)," +
        "@\(LOCONET_DEVICE_CV.CUSTOM_DESCRIPTION)," +
        "@\(LOCONET_DEVICE_CV.CUSTOM_NUMBER_BASE)," +
        "@\(LOCONET_DEVICE_CV.ENABLED)" +
        ")"
        primaryKey = Database.nextCode(tableName: TABLE.LOCONET_DEVICE_CV, primaryKey: LOCONET_DEVICE_CV.LOCONET_DEVICE_CV_ID)!
      }
      else {
        sql = "UPDATE [\(TABLE.LOCONET_DEVICE_CV)] SET " +
        "[\(LOCONET_DEVICE_CV.LOCONET_DEVICE_ID)] = @\(LOCONET_DEVICE_CV.LOCONET_DEVICE_ID), " +
        "[\(LOCONET_DEVICE_CV.CV_NUMBER)] = @\(LOCONET_DEVICE_CV.CV_NUMBER), " +
        "[\(LOCONET_DEVICE_CV.CV_VALUE)] = @\(LOCONET_DEVICE_CV.CV_VALUE), " +
        "[\(LOCONET_DEVICE_CV.DEFAULT_VALUE)] = @\(LOCONET_DEVICE_CV.DEFAULT_VALUE), " +
        "[\(LOCONET_DEVICE_CV.CUSTOM_DESCRIPTION)] = @\(LOCONET_DEVICE_CV.CUSTOM_DESCRIPTION), " +
        "[\(LOCONET_DEVICE_CV.CUSTOM_NUMBER_BASE)] = @\(LOCONET_DEVICE_CV.CUSTOM_NUMBER_BASE), " +
        "[\(LOCONET_DEVICE_CV.ENABLED)] = @\(LOCONET_DEVICE_CV.ENABLED) " +
        "WHERE [\(LOCONET_DEVICE_CV.LOCONET_DEVICE_CV_ID)] = @\(LOCONET_DEVICE_CV.LOCONET_DEVICE_CV_ID)"
      }

      let conn = Database.getConnection()
      
      let shouldClose = conn.state != .Open
       
      if shouldClose {
         _ = conn.open()
      }
       
      let cmd = conn.createCommand()
       
      cmd.commandText = sql

      cmd.parameters.addWithValue(key: "@\(LOCONET_DEVICE_CV.LOCONET_DEVICE_CV_ID)", value: primaryKey)
      cmd.parameters.addWithValue(key: "@\(LOCONET_DEVICE_CV.LOCONET_DEVICE_ID)", value: locoNetDeviceId)
      cmd.parameters.addWithValue(key: "@\(LOCONET_DEVICE_CV.CV_NUMBER)", value: cvNumber)
      cmd.parameters.addWithValue(key: "@\(LOCONET_DEVICE_CV.CV_VALUE)", value: Int(cvValue))
      cmd.parameters.addWithValue(key: "@\(LOCONET_DEVICE_CV.DEFAULT_VALUE)", value: Int(defaultValue))
      cmd.parameters.addWithValue(key: "@\(LOCONET_DEVICE_CV.CUSTOM_DESCRIPTION)", value: customDescription)
      cmd.parameters.addWithValue(key: "@\(LOCONET_DEVICE_CV.CUSTOM_NUMBER_BASE)", value: customNumberBase.rawValue)
      cmd.parameters.addWithValue(key: "@\(LOCONET_DEVICE_CV.ENABLED)", value: isEnabled)

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
      return "[\(LOCONET_DEVICE_CV.LOCONET_DEVICE_CV_ID)], " +
      "[\(LOCONET_DEVICE_CV.LOCONET_DEVICE_ID)], " +
      "[\(LOCONET_DEVICE_CV.CV_NUMBER)], " +
      "[\(LOCONET_DEVICE_CV.CV_VALUE)], " +
      "[\(LOCONET_DEVICE_CV.DEFAULT_VALUE)], " +
      "[\(LOCONET_DEVICE_CV.CUSTOM_DESCRIPTION)], " +
      "[\(LOCONET_DEVICE_CV.CUSTOM_NUMBER_BASE)], " +
      "[\(LOCONET_DEVICE_CV.ENABLED)]"
    }
  }
  
  public static func cvs(locoNetDevice:LocoNetDevice) -> [LocoNetDeviceCV] {
    
    let conn = Database.getConnection()
    
    let shouldClose = conn.state != .Open
     
    if shouldClose {
      _ = conn.open()
    }
     
    let cmd = conn.createCommand()
     
    cmd.commandText = "SELECT \(columnNames) FROM [\(TABLE.LOCONET_DEVICE_CV)] WHERE [\(LOCONET_DEVICE_CV.LOCONET_DEVICE_ID)] = \(locoNetDevice.primaryKey) ORDER BY [\(LOCONET_DEVICE_CV.CV_NUMBER)]"

    var result : [LocoNetDeviceCV] = []
    
    if let reader = cmd.executeReader() {
         
      while reader.read() {
        result.append(LocoNetDeviceCV(reader: reader))
      }
         
      reader.close()
         
    }
    
    if shouldClose {
      conn.close()
    }

    return result

  }
  
  public static func delete(primaryKey: Int) {
    let sql = "DELETE FROM [\(TABLE.LOCONET_DEVICE_CV)] WHERE [\(LOCONET_DEVICE_CV.LOCONET_DEVICE_CV_ID)] = \(primaryKey)"
    Database.execute(commands: [sql])
  }
  
}
