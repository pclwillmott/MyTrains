//
//  LocomotiveCV.swift
//  MyTrains
//
//  Created by Paul Willmott on 07/01/2022.
//

import Foundation

public enum CVNumberBase : Int {
  case binary = 2
  case octal = 8
  case decimal = 10
  case hexadecimal = 16
  case useDefault = 0xff
}

public class LocomotiveCV : EditorObject {
  
  // MARK: Constructors
  
  init(reader:SqliteDataReader) {
    super.init(primaryKey: -1)
    decode(sqliteDataReader: reader)
  }
  
  init(cvNumber: Int) {
    super.init(primaryKey: -1)
    _cvNumber = cvNumber
  }
  
  init(primaryPageIndex: Int, secondaryPageNumber: Int, cvNumber: Int) {
    super.init(primaryKey: -1)
    _cvNumber = LocomotiveCV.indexedCvNumber(primaryPageIndex: primaryPageIndex, secondaryPageIndex: secondaryPageNumber, cvNumber: cvNumber)
  }
  
  // MARK: Destructors
  
  deinit {
    
  }
  
  // MARK: Private properties
  
  private var _cvId : Int = -1
  
  private var _locomotiveId : Int = -1
  
  private var _cvNumber : Int = -1
  
  private var _cvValue : Int = 0
  
  private var _defaultValue : Int = 0
  
  private var _customDescription : String = ""
  
  private var _customNumberBase : CVNumberBase = .useDefault
  
  private var _isEnabled : Bool = true
  
  private var _modified : Bool = false
  

  // MARK: Public properties
  
  public var modified: Bool {
    get {
      return _modified
    }
    set(value) {
      _modified = value
    }
  }
  
  public var cvId : Int {
    get {
      return _cvId
    }
    set(value) {
      if value != _cvId {
        _cvId = value
        modified = true
      }
    }
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
  
  public var cvNumber : Int {
    get {
      return _cvNumber
    }
    set(value) {
      if value != _cvNumber {
        _cvNumber = value
        modified = true
      }
    }
  }
  
  public var displayCVNumber : String {
    get {
      if _cvNumber <= 1024 {
        return "\(_cvNumber)"
      }
      let components = LocomotiveCV.cvNumberComponents(cvNumber: _cvNumber)
      return "\(components.primaryPageIndex).\(components.secondaryPageIndex).\(components.cvNumber)"
    }
  }
  
  public var cvValue : Int {
    get {
      return _cvValue
    }
    set(value) {
      if value != _cvValue {
        _cvValue = value
        modified = true
      }
    }
  }
  
  public var defaultValue : Int {
    get {
      return _defaultValue
    }
    set(value) {
      if value != _defaultValue {
        _defaultValue = value
        modified = true
      }
    }
  }

  public var customDescription : String {
    get {
      return _customDescription
    }
    set(value) {
      if value != _customDescription {
        _customDescription = value
        modified = true
      }
    }
  }
  
  public var nmraDescription : String {
    get {
      let nmra = NMRA.cvDescription(cv: cvNumber)
      return nmra == "" ? displayCVNumber : nmra
    }
  }
  
  public var customNumberBase : CVNumberBase {
    get {
      return _customNumberBase
    }
    set(value) {
      if value != _customNumberBase {
        _customNumberBase = value
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
  
  // MARK: Private Methods
  
  // MARK: Public Methods
  
  override public func displayString() -> String {
    return customDescription == "" ? nmraDescription : customDescription
  }

  // MARK: Database Methods
  
  private func decode(sqliteDataReader:SqliteDataReader?) {
    
    if let reader = sqliteDataReader {
      
      primaryKey = reader.getInt(index: 0)!

      if !reader.isDBNull(index: 1) {
        locomotiveId = reader.getInt(index: 1)!
      }
      
      if !reader.isDBNull(index: 2) {
        _cvNumber = reader.getInt(index: 2)!
      }
      
      if !reader.isDBNull(index: 3) {
        _cvValue = reader.getInt(index: 3)!
      }

      if !reader.isDBNull(index: 4) {
        _defaultValue = reader.getInt(index: 4)!
      }

      if !reader.isDBNull(index: 5) {
        _customDescription = reader.getString(index: 5)!
      }

      if !reader.isDBNull(index: 6) {
        _customNumberBase = CVNumberBase(rawValue: reader.getInt(index: 6)!) ?? .useDefault
      }

      if !reader.isDBNull(index: 7) {
        _isEnabled = reader.getInt(index: 7)! == 1
      }
      
    }
    
    modified = false
    
  }

  public func save() {
    
    if modified {
      
      var sql = ""

      if primaryKey == -1 {
        sql = "INSERT INTO [\(TABLE.LOCOMOTIVE_CV)] (" +
        "[\(LOCOMOTIVE_CV.CV_ID)], " +
        "[\(LOCOMOTIVE_CV.LOCOMOTIVE_ID)], " +
        "[\(LOCOMOTIVE_CV.CV_NUMBER)], " +
        "[\(LOCOMOTIVE_CV.CV_VALUE)], " +
        "[\(LOCOMOTIVE_CV.DEFAULT_VALUE)], " +
        "[\(LOCOMOTIVE_CV.CUSTOM_DESCRIPTION)], " +
        "[\(LOCOMOTIVE_CV.CUSTOM_NUMBER_BASE)], " +
        "[\(LOCOMOTIVE_CV.ENABLED)]" +
        ") VALUES (" +
        "@\(LOCOMOTIVE_CV.CV_ID), " +
        "@\(LOCOMOTIVE_CV.LOCOMOTIVE_ID), " +
        "@\(LOCOMOTIVE_CV.CV_NUMBER), " +
        "@\(LOCOMOTIVE_CV.CV_VALUE), " +
        "@\(LOCOMOTIVE_CV.DEFAULT_VALUE), " +
        "@\(LOCOMOTIVE_CV.CUSTOM_DESCRIPTION), " +
        "@\(LOCOMOTIVE_CV.CUSTOM_NUMBER_BASE), " +
        "@\(LOCOMOTIVE_CV.ENABLED)" +
        ")"
        primaryKey = Database.nextCode(tableName: TABLE.LOCOMOTIVE_CV, primaryKey: LOCOMOTIVE_CV.CV_ID)!
      }
      else {
        sql = "UPDATE [\(TABLE.LOCOMOTIVE_CV)] SET " +
        "[\(LOCOMOTIVE_CV.LOCOMOTIVE_ID)] = @\(LOCOMOTIVE_CV.LOCOMOTIVE_ID), " +
        "[\(LOCOMOTIVE_CV.CV_NUMBER)] = @\(LOCOMOTIVE_CV.CV_NUMBER), " +
        "[\(LOCOMOTIVE_CV.CV_VALUE)] = @\(LOCOMOTIVE_CV.CV_VALUE), " +
        "[\(LOCOMOTIVE_CV.DEFAULT_VALUE)] = @\(LOCOMOTIVE_CV.DEFAULT_VALUE), " +
        "[\(LOCOMOTIVE_CV.CUSTOM_DESCRIPTION)] = @\(LOCOMOTIVE_CV.CUSTOM_DESCRIPTION), " +
        "[\(LOCOMOTIVE_CV.CUSTOM_NUMBER_BASE)] = @\(LOCOMOTIVE_CV.CUSTOM_NUMBER_BASE), " +
        "[\(LOCOMOTIVE_CV.ENABLED)] = @\(LOCOMOTIVE_CV.ENABLED) " +
         "WHERE [\(LOCOMOTIVE_CV.CV_ID)] = @\(LOCOMOTIVE_CV.CV_ID)"
      }

      let conn = Database.getConnection()
      
      let shouldClose = conn.state != .Open
       
      if shouldClose {
         _ = conn.open()
      }
       
      let cmd = conn.createCommand()
       
      cmd.commandText = sql
 
      cmd.parameters.addWithValue(key: "@\(LOCOMOTIVE_CV.CV_ID)", value: primaryKey)
      cmd.parameters.addWithValue(key: "@\(LOCOMOTIVE_CV.LOCOMOTIVE_ID)", value: locomotiveId)
      cmd.parameters.addWithValue(key: "@\(LOCOMOTIVE_CV.CV_NUMBER)", value: cvNumber)
      cmd.parameters.addWithValue(key: "@\(LOCOMOTIVE_CV.CV_VALUE)", value: cvValue)
      cmd.parameters.addWithValue(key: "@\(LOCOMOTIVE_CV.DEFAULT_VALUE)", value: defaultValue)
      cmd.parameters.addWithValue(key: "@\(LOCOMOTIVE_CV.CUSTOM_DESCRIPTION)", value: customDescription)
      cmd.parameters.addWithValue(key: "@\(LOCOMOTIVE_CV.CUSTOM_NUMBER_BASE)", value: customNumberBase.rawValue)
      cmd.parameters.addWithValue(key: "@\(LOCOMOTIVE_CV.ENABLED)", value: isEnabled ? 1 : 0)

      _ = cmd.executeNonQuery()

      if shouldClose {
        conn.close()
      }
      
      modified = false
      
    }

  }

  // MARK: Class Properties
  
  /*
   enum LOCOMOTIVE_CV {
     static let CV_ID                 = "CV_ID"
     static let LOCOMOTIVE_ID         = "LOCOMOTIVE_ID"
     static let CV_NUMBER             = "CV_NUMBER"
     static let CV_VALUE              = "CV_VALUE"
     static let DEFAULT_VALUE         = "DEFAULT_VALUE"
     static let CUSTOM_DESCRIPTION    = "CUSTOM_DESCRIPTION"
     static let CUSTOM_NUMBER_BASE    = "CUSTOM_NUMBER_BASE"
     static let ENABLED               = "ENABLED"
   }
   */

  public static var columnNames : String {
    get {
      return "[\(LOCOMOTIVE_CV.CV_ID)], " +
             "[\(LOCOMOTIVE_CV.LOCOMOTIVE_ID)], " +
             "[\(LOCOMOTIVE_CV.CV_NUMBER)], " +
             "[\(LOCOMOTIVE_CV.CV_VALUE)], " +
             "[\(LOCOMOTIVE_CV.DEFAULT_VALUE)], " +
             "[\(LOCOMOTIVE_CV.CUSTOM_DESCRIPTION)], " +
             "[\(LOCOMOTIVE_CV.CUSTOM_NUMBER_BASE)], " +
             "[\(LOCOMOTIVE_CV.ENABLED)]"
    }
  }
  
  public static func cvs(locomotive: Locomotive) -> [Int:LocomotiveCV] {
    
    let conn = Database.getConnection()
      
    let shouldClose = conn.state != .Open
       
    if shouldClose {
      _ = conn.open()
    }
       
    let cmd = conn.createCommand()
       
    cmd.commandText = "SELECT \(columnNames) FROM [\(TABLE.LOCOMOTIVE_CV)] WHERE [\(LOCOMOTIVE_CV.LOCOMOTIVE_ID)] = \(locomotive.primaryKey) ORDER BY [\(LOCOMOTIVE_CV.CV_NUMBER)]"

    var result : [Int:LocomotiveCV] = [:]
      
    if let reader = cmd.executeReader() {
           
      while reader.read() {
        let cv = LocomotiveCV(reader: reader)
        result[cv.cvNumber] = cv
      }
           
      reader.close()
           
    }
      
    if shouldClose {
      conn.close()
    }

    return result
      
  }
  
  public static func indexedCvNumber(primaryPageIndex:Int, secondaryPageIndex: Int, cvNumber: Int) -> Int {
    return (primaryPageIndex+1) << 20 | (secondaryPageIndex+1) << 11 | cvNumber
  }
  
  public static func cvNumberComponents(cvNumber: Int) -> (primaryPageIndex:Int, secondaryPageIndex: Int, cvNumber: Int) {
    let number = cvNumber & 0b11111111111
    let secondary = ((cvNumber >> 11) - 1) & 0xff
    let primary = (cvNumber >> 20) - 1
    return (primary, secondary, number)
  }

  public static func delete(primaryKey: Int) {
    let sql = "DELETE FROM [\(TABLE.LOCOMOTIVE_CV)] WHERE [\(LOCOMOTIVE_CV.CV_ID)] = \(primaryKey)"
    Database.execute(commands: [sql])
  }

}
