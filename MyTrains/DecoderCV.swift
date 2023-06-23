//
//  DecoderCV.swift
//  MyTrains
//
//  Created by Paul Willmott on 07/01/2022.
//

import Foundation

public class DecoderCV : EditorObject {
  
  // MARK: Constructors
  
  init(reader:SqliteDataReader) {
    super.init(primaryKey: -1)
    decode(sqliteDataReader: reader)
  }
  
  init(decoderType: DCCDecoderType, cvNumber: Int) {
    super.init(primaryKey: -1)
    self.decoderType = decoderType
    self.cvNumber = cvNumber
  }
  
  init(primaryPageIndex: Int, secondaryPageNumber: Int, cvNumber: Int) {
    super.init(primaryKey: -1)
    self.cvNumber = DecoderCV.indexedCvNumber(primaryPageIndex: primaryPageIndex, secondaryPageIndex: secondaryPageNumber, cvNumber: cvNumber)
  }
  
  // MARK: Destructors
  
  deinit {
    
  }
  
  // MARK: Private properties
  
  private var _newValue : String = ""

  // MARK: Public properties
  
  public var cvId : Int = -1 {
    didSet {
      modified = true
    }
  }
  
  public var rollingStockId : Int = -1 {
    didSet {
      modified = true
    }
  }
  
  public var decoderType : DCCDecoderType = .mobile {
    didSet {
      modified = true
    }
  }
  
  public var cvNumber : Int = -1 {
    didSet {
      modified = true
    }
  }
  
  public var isIndexedCV : Bool {
    get {
      return cvNumber > 1024
    }
  }
  
  public var primaryPageIndex : Int {
    get {
      let components = DecoderCV.cvNumberComponents(cvNumber: cvNumber)
      return components.primaryPageIndex
    }
  }
  
  public var secondaryPageIndex : Int {
    get {
      let components = DecoderCV.cvNumberComponents(cvNumber: cvNumber)
      return components.secondaryPageIndex
    }
  }
  
  public var indexedIndex : Int {
    get {
      let components = DecoderCV.cvNumberComponents(cvNumber: cvNumber)
      return components.cvNumber
    }
  }
  
  public var displayCVNumber : String {
    get {
      if !isIndexedCV {
        return "\(cvNumber)"
      }
      let components = DecoderCV.cvNumberComponents(cvNumber: cvNumber)
      return "\(components.primaryPageIndex).\(components.secondaryPageIndex).\(components.cvNumber)"
    }
  }
  
  public var cvValue : Int = 0 {
    didSet {
      modified = true
    }
  }
  
  public var defaultValue : Int = 0 {
    didSet {
      modified = true
    }
  }

  public var customDescription : String = "" {
    didSet {
      modified = true
    }
  }
  
  public var nmraDescription : String {
    get {
      let nmra = NMRA.cvDescription(cv: cvNumber)
      return nmra == "" ? displayCVNumber : nmra
    }
  }
  
  public var customNumberBase : CVNumberBase = .defaultValue {
    didSet {
      modified = true
    }
  }
  
  public var isEnabled : Bool = true {
    didSet {
      modified = true
    }
  }
  
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
      return customNumberBase.toString(value: defaultValue)
    }
  }
  
  public var displayCVValue : String {
    get {
      return customNumberBase.toString(value: cvValue)
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
        rollingStockId = reader.getInt(index: 1)!
      }
      
      if !reader.isDBNull(index: 2) {
        decoderType = DCCDecoderType(rawValue: reader.getInt(index: 2)!) ?? .mobile
      }
      
      if !reader.isDBNull(index: 3) {
        cvNumber = reader.getInt(index: 3)!
      }
      
      if !reader.isDBNull(index: 4) {
        cvValue = reader.getInt(index: 4)!
      }

      if !reader.isDBNull(index: 5) {
        defaultValue = reader.getInt(index: 5)!
      }

      if !reader.isDBNull(index: 6) {
        customDescription = reader.getString(index: 6)!
      }

      if !reader.isDBNull(index: 7) {
        customNumberBase = CVNumberBase(rawValue: reader.getInt(index: 7)!) ?? .decimal
      }

      if !reader.isDBNull(index: 8) {
        isEnabled = reader.getBool(index: 8)!
      }
      
    }
    
    modified = false
    
  }

  public func save() {
    
    if modified {
      
      var sql = ""

      if primaryKey == -1 {
        sql = "INSERT INTO [\(TABLE.DECODER_CV)] (" +
        "[\(DECODER_CV.DECODER_CV_ID)], " +
        "[\(DECODER_CV.ROLLING_STOCK_ID)], " +
        "[\(DECODER_CV.DECODER_TYPE)], " +
        "[\(DECODER_CV.CV_NUMBER)], " +
        "[\(DECODER_CV.CV_VALUE)], " +
        "[\(DECODER_CV.DEFAULT_VALUE)], " +
        "[\(DECODER_CV.CUSTOM_DESCRIPTION)], " +
        "[\(DECODER_CV.CUSTOM_NUMBER_BASE)], " +
        "[\(DECODER_CV.ENABLED)]" +
        ") VALUES (" +
        "@\(DECODER_CV.DECODER_CV_ID), " +
        "@\(DECODER_CV.ROLLING_STOCK_ID), " +
        "@\(DECODER_CV.DECODER_TYPE), " +
        "@\(DECODER_CV.CV_NUMBER), " +
        "@\(DECODER_CV.CV_VALUE), " +
        "@\(DECODER_CV.DEFAULT_VALUE), " +
        "@\(DECODER_CV.CUSTOM_DESCRIPTION), " +
        "@\(DECODER_CV.CUSTOM_NUMBER_BASE), " +
        "@\(DECODER_CV.ENABLED)" +
        ")"
        primaryKey = Database.nextCode(tableName: TABLE.DECODER_CV, primaryKey: DECODER_CV.DECODER_CV_ID)!
      }
      else {
        sql = "UPDATE [\(TABLE.DECODER_CV)] SET " +
        "[\(DECODER_CV.ROLLING_STOCK_ID)] = @\(DECODER_CV.ROLLING_STOCK_ID), " +
        "[\(DECODER_CV.DECODER_TYPE)] = @\(DECODER_CV.DECODER_TYPE), " +
        "[\(DECODER_CV.CV_NUMBER)] = @\(DECODER_CV.CV_NUMBER), " +
        "[\(DECODER_CV.CV_VALUE)] = @\(DECODER_CV.CV_VALUE), " +
        "[\(DECODER_CV.DEFAULT_VALUE)] = @\(DECODER_CV.DEFAULT_VALUE), " +
        "[\(DECODER_CV.CUSTOM_DESCRIPTION)] = @\(DECODER_CV.CUSTOM_DESCRIPTION), " +
        "[\(DECODER_CV.CUSTOM_NUMBER_BASE)] = @\(DECODER_CV.CUSTOM_NUMBER_BASE), " +
        "[\(DECODER_CV.ENABLED)] = @\(DECODER_CV.ENABLED) " +
         "WHERE [\(DECODER_CV.DECODER_CV_ID)] = @\(DECODER_CV.DECODER_CV_ID)"
      }

      let conn = Database.getConnection()
      
      let shouldClose = conn.state != .Open
       
      if shouldClose {
         _ = conn.open()
      }
       
      let cmd = conn.createCommand()
       
      cmd.commandText = sql
 
      cmd.parameters.addWithValue(key: "@\(DECODER_CV.DECODER_CV_ID)", value: primaryKey)
      cmd.parameters.addWithValue(key: "@\(DECODER_CV.ROLLING_STOCK_ID)", value: rollingStockId)
      cmd.parameters.addWithValue(key: "@\(DECODER_CV.DECODER_TYPE)", value: decoderType.rawValue)
      cmd.parameters.addWithValue(key: "@\(DECODER_CV.CV_NUMBER)", value: cvNumber)
      cmd.parameters.addWithValue(key: "@\(DECODER_CV.CV_VALUE)", value: cvValue)
      cmd.parameters.addWithValue(key: "@\(DECODER_CV.DEFAULT_VALUE)", value: defaultValue)
      cmd.parameters.addWithValue(key: "@\(DECODER_CV.CUSTOM_DESCRIPTION)", value: customDescription)
      cmd.parameters.addWithValue(key: "@\(DECODER_CV.CUSTOM_NUMBER_BASE)", value: customNumberBase.rawValue)
      cmd.parameters.addWithValue(key: "@\(DECODER_CV.ENABLED)", value: isEnabled ? 1 : 0)

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
      return "[\(DECODER_CV.DECODER_CV_ID)], " +
             "[\(DECODER_CV.ROLLING_STOCK_ID)], " +
             "[\(DECODER_CV.DECODER_TYPE)], " +
             "[\(DECODER_CV.CV_NUMBER)], " +
             "[\(DECODER_CV.CV_VALUE)], " +
             "[\(DECODER_CV.DEFAULT_VALUE)], " +
             "[\(DECODER_CV.CUSTOM_DESCRIPTION)], " +
             "[\(DECODER_CV.CUSTOM_NUMBER_BASE)], " +
             "[\(DECODER_CV.ENABLED)]"
    }
  }
  
  public enum DecoderType : Int {
    case mobile = 0
    case accessory = 1
  }


  public static func cvs(rollingStock: RollingStock, decoderType: DecoderType) -> [Int:DecoderCV] {
    
    let conn = Database.getConnection()
      
    let shouldClose = conn.state != .Open
       
    if shouldClose {
      _ = conn.open()
    }
       
    let cmd = conn.createCommand()
       
    cmd.commandText = "SELECT \(columnNames) FROM [\(TABLE.DECODER_CV)] WHERE [\(DECODER_CV.ROLLING_STOCK_ID)] = \(rollingStock.primaryKey) AND [\(DECODER_CV.DECODER_TYPE)] = \(decoderType.rawValue) ORDER BY [\(DECODER_CV.CV_NUMBER)]"

    var result : [Int:DecoderCV] = [:]
      
    if let reader = cmd.executeReader() {
           
      while reader.read() {
        let cv = DecoderCV(reader: reader)
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
  
  public static func cvNumber(string: String) -> Int? {
    
    let parts = string.split(separator: ".")
    
    if parts.count == 1 {
      if let number = Int(parts[0]) {
        return number
      }
    }
    else if let primary = Int(parts[0]), let secondary = Int(parts[1]), let number = Int(parts[2]) {
      return indexedCvNumber(primaryPageIndex: primary, secondaryPageIndex: secondary, cvNumber: number)
    }
    
    return nil
    
  }

  public static func delete(primaryKey: Int) {
    let sql = "DELETE FROM [\(TABLE.DECODER_CV)] WHERE [\(DECODER_CV.DECODER_CV_ID)] = \(primaryKey)"
    Database.execute(commands: [sql])
  }

}
