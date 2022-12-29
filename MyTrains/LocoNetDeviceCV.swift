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
  
  private var _cvDescriptions : [Int:String]?
  
  // MARK: Public Properties
 
  public var cvDescriptions : [Int:String] {
    
    get {
      if let descriptions = _cvDescriptions {
        return descriptions
      }
      var temp : [(cvNumber:Int, cvDescription:String)] = [
        (1, "Primary Address"),
        (2, "Vstart"),
        (3, "Acceleration Rate"),
        (4, "Decleration Rate"),
        (5, "Vhigh"),
        (6, "Vmid"),
        (7, "Manufacturer Version Number"),
        (8, "Manufacturer ID"),
        (9, "Total PWM Period"),
        (10, "EMF Feedback Cutout"),
        (11, "Packet time-out Value"),
        (12, "Power Source Conversion"),
        (13, "Alternate Mode Function Status"),
        (14, "Alternate Mode Function 2 Status"),
        (15, "Decoder Lock"),
        (16, "Decoder Lock"),
        (17, "Extended Address MSBits"),
        (18, "Extended Address LSBits"),
        (19, "Consist Address"),
        (21, "Consist Address Active for F1-F8"),
        (22, "Consist Address Active for FL and F9-F12"),
        (23, "Acceleration Adjustment"),
        (24, "Decleration Adjustment"),
        (25, "Speed Table/Mid Range Cab Speed Step"),
        (27, "Decoder Automatic Stopping Configuration"),
        (28, "Bi-Directional Communication Configuration"),
        (29, "Configurations Supported"),
        (30, "ERROR Information"),
        (31, "Index High Byte"),
        (32, "Index Low Byte"),
        (33, "Manufacturer Unique"),
        (34, "Manufacturer Unique"),
        (35, "Manufacturer Unique"),
        (36, "Manufacturer Unique"),
        (37, "Manufacturer Unique"),
        (38, "Manufacturer Unique"),
        (39, "Manufacturer Unique"),
        (40, "Manufacturer Unique"),
        (41, "Manufacturer Unique"),
        (42, "Manufacturer Unique"),
        (43, "Manufacturer Unique"),
        (44, "Manufacturer Unique"),
        (45, "Manufacturer Unique"),
        (46, "Manufacturer Unique"),
        (47, "Manufacturer Unique"),
        (48, "Manufacturer Unique"),
        (49, "Manufacturer Unique"),
        (50, "Manufacturer Unique"),
        (51, "Manufacturer Unique"),
        (52, "Manufacturer Unique"),
        (53, "Manufacturer Unique"),
        (54, "Manufacturer Unique"),
        (55, "Manufacturer Unique"),
        (56, "Manufacturer Unique"),
        (57, "Manufacturer Unique"),
        (58, "Manufacturer Unique"),
        (59, "Manufacturer Unique"),
        (60, "Manufacturer Unique"),
        (61, "Manufacturer Unique"),
        (62, "Manufacturer Unique"),
        (63, "Manufacturer Unique"),
        (64, "Manufacturer Unique"),
        (65, "Kick Start"),
        (66, "Forward Trim"),
        (67, "Speed Table #1"),
        (68, "Speed Table #2"),
        (69, "Speed Table #3"),
        (70, "Speed Table #4"),
        (71, "Speed Table #5"),
        (72, "Speed Table #6"),
        (73, "Speed Table #7"),
        (74, "Speed Table #8"),
        (75, "Speed Table #9"),
        (76, "Speed Table #10"),
        (77, "Speed Table #11"),
        (78, "Speed Table #12"),
        (79, "Speed Table #13"),
        (80, "Speed Table #14"),
        (81, "Speed Table #15"),
        (82, "Speed Table #16"),
        (83, "Speed Table #17"),
        (84, "Speed Table #18"),
        (85, "Speed Table #19"),
        (86, "Speed Table #20"),
        (87, "Speed Table #21"),
        (88, "Speed Table #22"),
        (89, "Speed Table #23"),
        (90, "Speed Table #24"),
        (91, "Speed Table #25"),
        (92, "Speed Table #26"),
        (93, "Speed Table #27"),
        (94, "Speed Table #28"),
        (95, "Reverse Trim"),
        (96, "NMRA Reserved"),
        (97, "NMRA Reserved"),
        (98, "NMRA Reserved"),
        (99, "NMRA Reserved"),
        (100, "NMRA Reserved"),
        (101, "NMRA Reserved"),
        (102, "NMRA Reserved"),
        (103, "NMRA Reserved"),
        (104, "NMRA Reserved"),
        (105, "User Identification #1"),
        (106, "User Identification #2"),
        (107, "NMRA Reserved"),
        (108, "NMRA Reserved"),
        (109, "NMRA Reserved"),
        (110, "NMRA Reserved"),
        (111, "NMRA Reserved"),
        (892, "Decoder Load"),
        (893, "Flags"),
        (894, "Fuel/Coal"),
        (895, "Water"),
      ]
      
      for cv in 112...256 {
        temp.append((cv, "Manufacturer Unique"))
      }
      
      _cvDescriptions = [:]
      
      for x in temp {
        _cvDescriptions![x.cvNumber] = x.cvDescription
      }
      
      return _cvDescriptions!
      
    }
  }
  
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
      if let description = cvDescriptions[cvNumber] {
        return description
      }
      return "unknown - \(cvNumber)"
    }
  }
  
  // MARK: Private Methods
    
  // MARK: Public Methods
  
  override public func displayString() -> String {
    return customDescription == "" ? cvDescription : customDescription
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
