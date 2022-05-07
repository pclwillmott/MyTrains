//
//  SwitchBoardItem.swift
//  MyTrains
//
//  Created by Paul Willmott on 30/04/2022.
//

import Foundation

public enum SwitchBoardItemAction {
  case delete
  case save
  case noAction
}

public enum TurnoutMotorType : Int {
  case slowMotion = 0
  case solenoid = 1
}

class SwitchBoardItem : EditorObject {

  // MARK: Constructors
  
  init(reader:SqliteDataReader) {
    super.init(primaryKey: -1)
    decode(sqliteDataReader: reader)
  }
  
  init(location: SwitchBoardLocation, itemPartType: SwitchBoardItemPartType, orientation: Int, groupId: Int, panelId: Int, layoutId: Int) {
    super.init(primaryKey: -1)
    self.location = location
    self.itemPartType = itemPartType
    self.orientation = orientation
    self.groupId = groupId
    self.panelId = panelId
    self.layoutId = layoutId
  }
  
  // MARK: Private Properties
  
  // MARK: Public Properties
  
  public var layoutId : Int = -1 {
    didSet {
      modified = true
    }
  }
  
  public var panelId : Int = -1 {
    didSet {
      modified = true
    }
  }
  
  public var groupId : Int = -1 {
    didSet {
      modified = true
    }
  }
  
  public var itemPartType : SwitchBoardItemPartType = .none {
    didSet {
      modified = true
    }
  }
  
  public var orientation : Int = 0 {
    didSet {
      modified = true
    }
  }
  
  public var location : SwitchBoardLocation = (x: 0, y: 0) {
    didSet {
      modified = true
    }
  }
  
  public var blockName : String = "" {
    didSet {
      modified = true
    }
  }
  
  public var blockDirection : BlockDirection = .bidirectional {
    didSet {
      modified = true
    }
  }
  
  public var trackPartId : Int = -1 {
    didSet {
      modified = true
    }
  }
  
  public var dimensionA : Double = 0.0 {
    didSet {
      modified = true
    }
  }
  
  public var dimensionB : Double = 0.0 {
    didSet {
      modified = true
    }
  }
  
  public var dimensionC : Double = 0.0 {
    didSet {
      modified = true
    }
  }
  
  public var dimensionD : Double = 0.0 {
    didSet {
      modified = true
    }
  }
  
  public var dimensionE : Double = 0.0 {
    didSet {
      modified = true
    }
  }
  
  public var dimensionF : Double = 0.0 {
    didSet {
      modified = true
    }
  }
  
  public var dimensionG : Double = 0.0 {
    didSet {
      modified = true
    }
  }
  
  public var dimensionH : Double = 0.0 {
    didSet {
      modified = true
    }
  }
  
  public var unitsDimension : LengthUnit = .centimeters {
    didSet {
      modified = true
    }
  }
  
  public var allowShunt : Bool = true {
    didSet {
      modified = true
    }
  }
  
  public var trackGauge : TrackGauge = .oo {
    didSet {
      modified = true
    }
  }
  
  public var trackElectrificationType : TrackElectrificationType = .notElectrified {
    didSet {
      modified = true
    }
  }
  
  public var gradient : Double = 1.0 {
    didSet {
      modified = true
    }
  }
  
  public var isCritical : Bool = false {
    didSet {
      modified = true
    }
  }
  
  public var unitsSpeed : SpeedUnit = .milesPerHour {
    didSet {
      modified = true
    }
  }
  
  public var unitsPosition : LengthUnit = .centimeters {
    didSet {
      modified = true
    }
  }
  
  public var dirNextBrakePosition : Double = 0.0 {
    didSet {
      modified = true
    }
  }
  
  public var dirNextStopPosition : Double = 0.0 {
    didSet {
      modified = true
    }
  }
  
  public var dirNextSpeedMax : Double = 0.0 {
    didSet {
      modified = true
    }
  }
  
  public var dirNextSpeedStopExpected : Double = 0.0 {
    didSet {
      modified = true
    }
  }
  
  public var dirNextSpeedRestricted : Double = 0.0 {
    didSet {
      modified = true
    }
  }
  
  public var dirNextSpeedBrake : Double = 0.0 {
    didSet {
      modified = true
    }
  }
  
  public var dirNextSpeedShunt : Double = 0.0 {
    didSet {
      modified = true
    }
  }
  
  public var dirNextSpeedMaxUseDefault : Bool = true {
    didSet {
      modified = true
    }
  }
  
  public var dirNextSpeedStopExpectedUseDefault : Bool = true {
    didSet {
      modified = true
    }
  }
  
  public var dirNextSpeedRestrictedUseDefault : Bool = true {
    didSet {
      modified = true
    }
  }
  
  public var dirNextSpeedBrakeUseDefault : Bool = true {
    didSet {
      modified = true
    }
  }
  
  public var dirNextSpeedShuntUseDefault : Bool = true {
    didSet {
      modified = true
    }
  }
  
  public var dirPreviousBrakePosition : Double = 0.0 {
    didSet {
      modified = true
    }
  }
  
  public var dirPreviousStopPosition : Double = 0.0 {
    didSet {
      modified = true
    }
  }
  
  public var dirPreviousSpeedMax : Double = 0.0 {
    didSet {
      modified = true
    }
  }
  
  public var dirPreviousSpeedStopExpected : Double = 0.0 {
    didSet {
      modified = true
    }
  }
  
  public var dirPreviousSpeedRestricted : Double = 0.0 {
    didSet {
      modified = true
    }
  }
  
  public var dirPreviousSpeedBrake : Double = 0.0 {
    didSet {
      modified = true
    }
  }
  
  public var dirPreviousSpeedShunt : Double = 0.0 {
    didSet {
      modified = true
    }
  }
  
  public var dirPreviousSpeedMaxUseDefault : Bool = true {
    didSet {
      modified = true
    }
  }
  
  public var dirPreviousSpeedStopExpectedUseDefault : Bool = true {
    didSet {
      modified = true
    }
  }
  
  public var dirPreviousSpeedRestrictedUseDefault : Bool = true {
    didSet {
      modified = true
    }
  }
  
  public var dirPreviousSpeedBrakeUseDefault : Bool = true {
    didSet {
      modified = true
    }
  }
  
  public var dirPreviousSpeedShuntUseDefault : Bool = true {
    didSet {
      modified = true
    }
  }
  
  public var sw1LocoNetDeviceId : Int = -1 {
    didSet {
      modified = true
    }
  }
  
  public var sw1Port : Int = -1 {
    didSet {
      modified = true
    }
  }
  
  public var sw1TurnoutMotorType : TurnoutMotorType = .solenoid {
    didSet {
      modified = true
    }
  }
  
  public var sw1SensorId : Int = -1 {
    didSet {
      modified = true
    }
  }
  
  public var sw2LocoNetDeviceId : Int = -1 {
    didSet {
      modified = true
    }
  }
  
  public var sw2Port : Int = -1 {
    didSet {
      modified = true
    }
  }
  
  public var sw2TurnoutMotorType : TurnoutMotorType = .solenoid {
    didSet {
      modified = true
    }
  }
  
  public var sw2SensorId : Int = -1 {
    didSet {
      modified = true
    }
  }
  
  public var nextAction : SwitchBoardItemAction = .noAction
  
  public var key : Int {
    get {
      return SwitchBoardItem.createKey(panelId: panelId, location: location, nextAction: nextAction)
    }
  }
  
  public var isDatabaseItem : Bool {
    get {
      return primaryKey != -1
    }
  }
  
  // MARK: Private Methods
  
  // MARK: Public Methods
  
  public func rotateRight() {
    var orientation = self.orientation
    orientation += 1
    if orientation > 7 {
      orientation = 0
    }
    self.orientation = orientation
  }
  
  public func rotateLeft() {
    var orientation = self.orientation
    orientation -= 1
    if orientation < 0 {
      orientation = 7
    }
    self.orientation = orientation
  }
  
  // MARK: Database Methods
  
  private func decode(sqliteDataReader:SqliteDataReader?) {
    
    if let reader = sqliteDataReader {
      
      primaryKey = reader.getInt(index: 0)!

      if !reader.isDBNull(index: 1) {
        layoutId = reader.getInt(index: 1)!
      }
      
      if !reader.isDBNull(index: 2) {
        panelId = reader.getInt(index: 2)!
      }

      if !reader.isDBNull(index: 3) {
        groupId = reader.getInt(index: 3)!
      }
      
      if !reader.isDBNull(index: 4) {
        itemPartType = SwitchBoardItemPartType(rawValue: reader.getInt(index: 4)!) ?? .none
      }
      
      if !reader.isDBNull(index: 5) {
        orientation = reader.getInt(index: 5)!
      }

      if !reader.isDBNull(index: 6) {
        location.x = reader.getInt(index: 6)!
      }
      
      if !reader.isDBNull(index: 7) {
        location.y = reader.getInt(index: 7)!
      }
      
      if !reader.isDBNull(index: 8) {
        blockName = reader.getString(index: 8)!
      }
      
      if !reader.isDBNull(index: 9) {
        blockDirection = BlockDirection(rawValue: reader.getInt(index: 9)!) ?? .bidirectional
      }
      
      if !reader.isDBNull(index: 10) {
        trackPartId = reader.getInt(index: 10)!
      }
      
      if !reader.isDBNull(index: 11) {
        dimensionA = reader.getDouble(index: 11)!
      }

      if !reader.isDBNull(index: 12) {
        dimensionB = reader.getDouble(index: 12)!
      }

      if !reader.isDBNull(index: 13) {
        dimensionC = reader.getDouble(index: 13)!
      }

      if !reader.isDBNull(index: 14) {
        dimensionD = reader.getDouble(index: 14)!
      }

      if !reader.isDBNull(index: 15) {
        dimensionE = reader.getDouble(index: 15)!
      }

      if !reader.isDBNull(index: 16) {
        dimensionF = reader.getDouble(index: 16)!
      }

      if !reader.isDBNull(index: 17) {
        dimensionG = reader.getDouble(index: 17)!
      }

      if !reader.isDBNull(index: 18) {
        dimensionH = reader.getDouble(index: 18)!
      }

      if !reader.isDBNull(index: 19) {
        unitsDimension = LengthUnit(rawValue: reader.getInt(index: 19)!) ?? .centimeters
      }

      if !reader.isDBNull(index: 20) {
        allowShunt = reader.getBool(index: 20)!
      }

      if !reader.isDBNull(index: 21) {
        trackGauge = TrackGauge(rawValue: reader.getInt(index: 21)!) ?? .oo
      }

      if !reader.isDBNull(index: 22) {
        trackElectrificationType = TrackElectrificationType(rawValue: reader.getInt(index: 22)!) ?? .notElectrified
      }

      if !reader.isDBNull(index: 23) {
        gradient = reader.getDouble(index: 23)!
      }

      if !reader.isDBNull(index: 24) {
        isCritical = reader.getBool(index: 24)!
      }

      if !reader.isDBNull(index: 25) {
        unitsSpeed = SpeedUnit(rawValue: reader.getInt(index: 25)!) ?? .milesPerHour
      }

      if !reader.isDBNull(index: 26) {
        unitsPosition = LengthUnit(rawValue: reader.getInt(index: 26)!) ?? .centimeters
      }

      if !reader.isDBNull(index: 27) {
        dirNextBrakePosition = reader.getDouble(index: 27)!
      }

      if !reader.isDBNull(index: 28) {
        dirNextStopPosition = reader.getDouble(index: 28)!
      }

      if !reader.isDBNull(index: 29) {
        dirNextSpeedMax = reader.getDouble(index: 29)!
      }

      if !reader.isDBNull(index: 30) {
        dirNextSpeedStopExpected = reader.getDouble(index: 30)!
      }

      if !reader.isDBNull(index: 31) {
        dirNextSpeedRestricted = reader.getDouble(index: 31)!
      }

      if !reader.isDBNull(index: 32) {
        dirNextSpeedBrake = reader.getDouble(index: 32)!
      }

      if !reader.isDBNull(index: 33) {
        dirNextSpeedShunt = reader.getDouble(index: 33)!
      }

      if !reader.isDBNull(index: 34) {
        dirNextSpeedMaxUseDefault = reader.getBool(index: 34)!
      }

      if !reader.isDBNull(index: 35) {
        dirNextSpeedStopExpectedUseDefault = reader.getBool(index: 35)!
      }

      if !reader.isDBNull(index: 36) {
        dirNextSpeedRestrictedUseDefault = reader.getBool(index: 36)!
      }

      if !reader.isDBNull(index: 37) {
        dirNextSpeedBrakeUseDefault = reader.getBool(index: 37)!
      }

      if !reader.isDBNull(index: 38) {
        dirNextSpeedShuntUseDefault = reader.getBool(index: 38)!
      }

      if !reader.isDBNull(index: 39) {
        dirPreviousBrakePosition = reader.getDouble(index: 39)!
      }

      if !reader.isDBNull(index: 40) {
        dirPreviousStopPosition = reader.getDouble(index: 40)!
      }

      if !reader.isDBNull(index: 41) {
        dirPreviousSpeedMax = reader.getDouble(index: 41)!
      }

      if !reader.isDBNull(index: 42) {
        dirPreviousSpeedStopExpected = reader.getDouble(index: 42)!
      }

      if !reader.isDBNull(index: 43) {
        dirPreviousSpeedRestricted = reader.getDouble(index: 43)!
      }

      if !reader.isDBNull(index: 44) {
        dirPreviousSpeedBrake = reader.getDouble(index: 44)!
      }

      if !reader.isDBNull(index: 45) {
        dirPreviousSpeedShunt = reader.getDouble(index: 45)!
      }

      if !reader.isDBNull(index: 46) {
        dirPreviousSpeedMaxUseDefault = reader.getBool(index: 46)!
      }

      if !reader.isDBNull(index: 47) {
        dirPreviousSpeedStopExpectedUseDefault = reader.getBool(index: 47)!
      }

      if !reader.isDBNull(index: 48) {
        dirPreviousSpeedRestrictedUseDefault = reader.getBool(index: 48)!
      }

      if !reader.isDBNull(index: 49) {
        dirPreviousSpeedBrakeUseDefault = reader.getBool(index: 49)!
      }

      if !reader.isDBNull(index: 50) {
        dirPreviousSpeedShuntUseDefault = reader.getBool(index: 50)!
      }

      if !reader.isDBNull(index: 51) {
        sw1LocoNetDeviceId = reader.getInt(index: 51)!
      }

      if !reader.isDBNull(index: 52) {
        sw1Port = reader.getInt(index: 52)!
      }

      if !reader.isDBNull(index: 53) {
        sw1TurnoutMotorType = TurnoutMotorType(rawValue: reader.getInt(index: 53)!) ?? .solenoid
      }

      if !reader.isDBNull(index: 54) {
        sw1SensorId = reader.getInt(index: 54)!
      }

      if !reader.isDBNull(index: 55) {
        sw2LocoNetDeviceId = reader.getInt(index: 55)!
      }

      if !reader.isDBNull(index: 56) {
        sw2Port = reader.getInt(index: 56)!
      }

      if !reader.isDBNull(index: 57) {
        sw2TurnoutMotorType = TurnoutMotorType(rawValue: reader.getInt(index: 57)!) ?? .solenoid
      }

      if !reader.isDBNull(index: 58) {
        sw2SensorId = reader.getInt(index: 58)!
      }

    }
    
    modified = false
    
  }

  public func save() {
    
    if modified {
      
      var sql = ""
      
      if !Database.codeExists(tableName: TABLE.SWITCHBOARD_ITEM, primaryKey: SWITCHBOARD_ITEM.SWITCHBOARD_ITEM_ID, code: primaryKey)! {
        sql = "INSERT INTO [\(TABLE.SWITCHBOARD_ITEM)] (" +
        "[\(SWITCHBOARD_ITEM.SWITCHBOARD_ITEM_ID)], " +
        "[\(SWITCHBOARD_ITEM.LAYOUT_ID)], " +
        "[\(SWITCHBOARD_ITEM.PANEL_ID)], " +
        "[\(SWITCHBOARD_ITEM.GROUP_ID)], " +
        "[\(SWITCHBOARD_ITEM.ITEM_PART_TYPE)], " +
        "[\(SWITCHBOARD_ITEM.ORIENTATION)], " +
        "[\(SWITCHBOARD_ITEM.XPOS)], " +
        "[\(SWITCHBOARD_ITEM.YPOS)], " +
        "[\(SWITCHBOARD_ITEM.BLOCK_NAME)], " +
        "[\(SWITCHBOARD_ITEM.BLOCK_DIRECTION)], " +
        "[\(SWITCHBOARD_ITEM.TRACK_PART_ID)], " +
        "[\(SWITCHBOARD_ITEM.DIMENSIONA)], " +
        "[\(SWITCHBOARD_ITEM.DIMENSIONB)], " +
        "[\(SWITCHBOARD_ITEM.DIMENSIONC)], " +
        "[\(SWITCHBOARD_ITEM.DIMENSIOND)], " +
        "[\(SWITCHBOARD_ITEM.DIMENSIONE)], " +
        "[\(SWITCHBOARD_ITEM.DIMENSIONF)], " +
        "[\(SWITCHBOARD_ITEM.DIMENSIONG)], " +
        "[\(SWITCHBOARD_ITEM.DIMENSIONH)], " +
        "[\(SWITCHBOARD_ITEM.UNITS_DIMENSION)], " +
        "[\(SWITCHBOARD_ITEM.ALLOW_SHUNT)], " +
        "[\(SWITCHBOARD_ITEM.TRACK_GAUGE)], " +
        "[\(SWITCHBOARD_ITEM.TRACK_ELECTRIFICATION_TYPE)], " +
        "[\(SWITCHBOARD_ITEM.GRADIENT)], " +
        "[\(SWITCHBOARD_ITEM.IS_CRITICAL)], " +
        "[\(SWITCHBOARD_ITEM.UNITS_SPEED)], " +
        "[\(SWITCHBOARD_ITEM.UNITS_POSITION)], " +
        "[\(SWITCHBOARD_ITEM.DN_BRAKE_POSITION)], " +
        "[\(SWITCHBOARD_ITEM.DN_STOP_POSITION)], " +
        "[\(SWITCHBOARD_ITEM.DN_SPEED_MAX)], " +
        "[\(SWITCHBOARD_ITEM.DN_SPEED_STOP_EXPECTED)], " +
        "[\(SWITCHBOARD_ITEM.DN_SPEED_RESTRICTED)], " +
        "[\(SWITCHBOARD_ITEM.DN_SPEED_BRAKE)], " +
        "[\(SWITCHBOARD_ITEM.DN_SPEED_SHUNT)], " +
        "[\(SWITCHBOARD_ITEM.DN_SPEED_MAX_UD)], " +
        "[\(SWITCHBOARD_ITEM.DN_SPEED_STOP_EXPECTED_UD)], " +
        "[\(SWITCHBOARD_ITEM.DN_SPEED_RESTRICTED_UD)], " +
        "[\(SWITCHBOARD_ITEM.DN_SPEED_BRAKE_UD)], " +
        "[\(SWITCHBOARD_ITEM.DN_SPEED_BRAKE_UD)], " +
        "[\(SWITCHBOARD_ITEM.DP_BRAKE_POSITION)], " +
        "[\(SWITCHBOARD_ITEM.DP_STOP_POSITION)], " +
        "[\(SWITCHBOARD_ITEM.DP_SPEED_MAX)], " +
        "[\(SWITCHBOARD_ITEM.DP_SPEED_STOP_EXPECTED)], " +
        "[\(SWITCHBOARD_ITEM.DP_SPEED_RESTRICTED)], " +
        "[\(SWITCHBOARD_ITEM.DP_SPEED_BRAKE)], " +
        "[\(SWITCHBOARD_ITEM.DP_SPEED_SHUNT)], " +
        "[\(SWITCHBOARD_ITEM.DP_SPEED_MAX_UD)], " +
        "[\(SWITCHBOARD_ITEM.DP_SPEED_STOP_EXPECTED_UD)], " +
        "[\(SWITCHBOARD_ITEM.DP_SPEED_RESTRICTED_UD)], " +
        "[\(SWITCHBOARD_ITEM.DP_SPEED_BRAKE_UD)], " +
        "[\(SWITCHBOARD_ITEM.DP_SPEED_BRAKE_UD)], " +
        "[\(SWITCHBOARD_ITEM.SW1_LOCONET_DEVICE_ID)], " +
        "[\(SWITCHBOARD_ITEM.SW1_PORT)], " +
        "[\(SWITCHBOARD_ITEM.SW1_TURNOUT_MOTOR_TYPE)], " +
        "[\(SWITCHBOARD_ITEM.SW1_SENSOR_ID)], " +
        "[\(SWITCHBOARD_ITEM.SW2_LOCONET_DEVICE_ID)], " +
        "[\(SWITCHBOARD_ITEM.SW2_PORT)], " +
        "[\(SWITCHBOARD_ITEM.SW2_TURNOUT_MOTOR_TYPE)], " +
        "[\(SWITCHBOARD_ITEM.SW2_SENSOR_ID)]" +
        ") VALUES (" +
        "@\(SWITCHBOARD_ITEM.SWITCHBOARD_ITEM_ID), " +
        "@\(SWITCHBOARD_ITEM.LAYOUT_ID), " +
        "@\(SWITCHBOARD_ITEM.PANEL_ID), " +
        "@\(SWITCHBOARD_ITEM.GROUP_ID), " +
        "@\(SWITCHBOARD_ITEM.ITEM_PART_TYPE), " +
        "@\(SWITCHBOARD_ITEM.ORIENTATION), " +
        "@\(SWITCHBOARD_ITEM.XPOS), " +
        "@\(SWITCHBOARD_ITEM.YPOS), " +
        "@\(SWITCHBOARD_ITEM.BLOCK_NAME), " +
        "@\(SWITCHBOARD_ITEM.BLOCK_DIRECTION), " +
        "@\(SWITCHBOARD_ITEM.TRACK_PART_ID), " +
        "@\(SWITCHBOARD_ITEM.DIMENSIONA), " +
        "@\(SWITCHBOARD_ITEM.DIMENSIONB), " +
        "@\(SWITCHBOARD_ITEM.DIMENSIONC), " +
        "@\(SWITCHBOARD_ITEM.DIMENSIOND), " +
        "@\(SWITCHBOARD_ITEM.DIMENSIONE), " +
        "@\(SWITCHBOARD_ITEM.DIMENSIONF), " +
        "@\(SWITCHBOARD_ITEM.DIMENSIONG), " +
        "@\(SWITCHBOARD_ITEM.DIMENSIONH), " +
        "@\(SWITCHBOARD_ITEM.UNITS_DIMENSION), " +
        "@\(SWITCHBOARD_ITEM.ALLOW_SHUNT), " +
        "@\(SWITCHBOARD_ITEM.TRACK_GAUGE), " +
        "@\(SWITCHBOARD_ITEM.TRACK_ELECTRIFICATION_TYPE), " +
        "@\(SWITCHBOARD_ITEM.GRADIENT), " +
        "@\(SWITCHBOARD_ITEM.IS_CRITICAL), " +
        "@\(SWITCHBOARD_ITEM.UNITS_SPEED), " +
        "@\(SWITCHBOARD_ITEM.UNITS_POSITION), " +
        "@\(SWITCHBOARD_ITEM.DN_BRAKE_POSITION), " +
        "@\(SWITCHBOARD_ITEM.DN_STOP_POSITION), " +
        "@\(SWITCHBOARD_ITEM.DN_SPEED_MAX), " +
        "@\(SWITCHBOARD_ITEM.DN_SPEED_STOP_EXPECTED), " +
        "@\(SWITCHBOARD_ITEM.DN_SPEED_RESTRICTED), " +
        "@\(SWITCHBOARD_ITEM.DN_SPEED_BRAKE), " +
        "@\(SWITCHBOARD_ITEM.DN_SPEED_SHUNT), " +
        "@\(SWITCHBOARD_ITEM.DN_SPEED_MAX_UD), " +
        "@\(SWITCHBOARD_ITEM.DN_SPEED_STOP_EXPECTED_UD), " +
        "@\(SWITCHBOARD_ITEM.DN_SPEED_RESTRICTED_UD), " +
        "@\(SWITCHBOARD_ITEM.DN_SPEED_BRAKE_UD), " +
        "@\(SWITCHBOARD_ITEM.DN_SPEED_SHUNT_UD), " +
        "@\(SWITCHBOARD_ITEM.DP_BRAKE_POSITION), " +
        "@\(SWITCHBOARD_ITEM.DP_STOP_POSITION), " +
        "@\(SWITCHBOARD_ITEM.DP_SPEED_MAX), " +
        "@\(SWITCHBOARD_ITEM.DP_SPEED_STOP_EXPECTED), " +
        "@\(SWITCHBOARD_ITEM.DP_SPEED_RESTRICTED), " +
        "@\(SWITCHBOARD_ITEM.DP_SPEED_BRAKE), " +
        "@\(SWITCHBOARD_ITEM.DP_SPEED_SHUNT), " +
        "@\(SWITCHBOARD_ITEM.DP_SPEED_MAX_UD), " +
        "@\(SWITCHBOARD_ITEM.DP_SPEED_STOP_EXPECTED_UD), " +
        "@\(SWITCHBOARD_ITEM.DP_SPEED_RESTRICTED_UD), " +
        "@\(SWITCHBOARD_ITEM.DP_SPEED_BRAKE_UD), " +
        "@\(SWITCHBOARD_ITEM.DP_SPEED_SHUNT_UD), " +
        "@\(SWITCHBOARD_ITEM.SW1_LOCONET_DEVICE_ID), " +
        "@\(SWITCHBOARD_ITEM.SW1_PORT), " +
        "@\(SWITCHBOARD_ITEM.SW1_TURNOUT_MOTOR_TYPE), " +
        "@\(SWITCHBOARD_ITEM.SW1_SENSOR_ID), " +
        "@\(SWITCHBOARD_ITEM.SW2_LOCONET_DEVICE_ID), " +
        "@\(SWITCHBOARD_ITEM.SW2_PORT), " +
        "@\(SWITCHBOARD_ITEM.SW2_TURNOUT_MOTOR_TYPE), " +
        "@\(SWITCHBOARD_ITEM.SW2_SENSOR_ID)" +
        ")"
        primaryKey = Database.nextCode(tableName: TABLE.SWITCHBOARD_ITEM, primaryKey: SWITCHBOARD_ITEM.SWITCHBOARD_ITEM_ID)!
      }
      else {
        sql = "UPDATE [\(TABLE.SWITCHBOARD_ITEM)] SET " +
        "[\(SWITCHBOARD_ITEM.LAYOUT_ID)] = @\(SWITCHBOARD_ITEM.LAYOUT_ID), " +
        "[\(SWITCHBOARD_ITEM.PANEL_ID)] = @\(SWITCHBOARD_ITEM.PANEL_ID), " +
        "[\(SWITCHBOARD_ITEM.GROUP_ID)] = @\(SWITCHBOARD_ITEM.GROUP_ID), " +
        "[\(SWITCHBOARD_ITEM.ITEM_PART_TYPE)] = @\(SWITCHBOARD_ITEM.ITEM_PART_TYPE), " +
        "[\(SWITCHBOARD_ITEM.ORIENTATION)] = @\(SWITCHBOARD_ITEM.ORIENTATION), " +
        "[\(SWITCHBOARD_ITEM.XPOS)] = @\(SWITCHBOARD_ITEM.XPOS), " +
        "[\(SWITCHBOARD_ITEM.YPOS)] = @\(SWITCHBOARD_ITEM.YPOS), " +
        "[\(SWITCHBOARD_ITEM.BLOCK_NAME)] = @\(SWITCHBOARD_ITEM.BLOCK_NAME), " +
        "[\(SWITCHBOARD_ITEM.BLOCK_DIRECTION)] = @\(SWITCHBOARD_ITEM.BLOCK_DIRECTION), " +
        "[\(SWITCHBOARD_ITEM.TRACK_PART_ID)] = @\(SWITCHBOARD_ITEM.TRACK_PART_ID), " +
        "[\(SWITCHBOARD_ITEM.DIMENSIONA)] = @\(SWITCHBOARD_ITEM.DIMENSIONA), " +
        "[\(SWITCHBOARD_ITEM.DIMENSIONB)] = @\(SWITCHBOARD_ITEM.DIMENSIONB), " +
        "[\(SWITCHBOARD_ITEM.DIMENSIONC)] = @\(SWITCHBOARD_ITEM.DIMENSIONC), " +
        "[\(SWITCHBOARD_ITEM.DIMENSIOND)] = @\(SWITCHBOARD_ITEM.DIMENSIOND), " +
        "[\(SWITCHBOARD_ITEM.DIMENSIONE)] = @\(SWITCHBOARD_ITEM.DIMENSIONE), " +
        "[\(SWITCHBOARD_ITEM.DIMENSIONF)] = @\(SWITCHBOARD_ITEM.DIMENSIONF), " +
        "[\(SWITCHBOARD_ITEM.DIMENSIONG)] = @\(SWITCHBOARD_ITEM.DIMENSIONG), " +
        "[\(SWITCHBOARD_ITEM.DIMENSIONH)] = @\(SWITCHBOARD_ITEM.DIMENSIONH), " +
        "[\(SWITCHBOARD_ITEM.UNITS_DIMENSION)] = @\(SWITCHBOARD_ITEM.UNITS_DIMENSION), " +
        "[\(SWITCHBOARD_ITEM.ALLOW_SHUNT)] = @\(SWITCHBOARD_ITEM.ALLOW_SHUNT), " +
        "[\(SWITCHBOARD_ITEM.TRACK_GAUGE)] = @\(SWITCHBOARD_ITEM.TRACK_GAUGE), " +
        "[\(SWITCHBOARD_ITEM.TRACK_ELECTRIFICATION_TYPE)] = @\(SWITCHBOARD_ITEM.TRACK_ELECTRIFICATION_TYPE), " +
        "[\(SWITCHBOARD_ITEM.GRADIENT)] = @\(SWITCHBOARD_ITEM.GRADIENT), " +
        "[\(SWITCHBOARD_ITEM.IS_CRITICAL)] = @\(SWITCHBOARD_ITEM.IS_CRITICAL), " +
        "[\(SWITCHBOARD_ITEM.UNITS_SPEED)] = @\(SWITCHBOARD_ITEM.UNITS_SPEED), " +
        "[\(SWITCHBOARD_ITEM.UNITS_POSITION)] = @\(SWITCHBOARD_ITEM.UNITS_POSITION), " +
        "[\(SWITCHBOARD_ITEM.DN_BRAKE_POSITION)] = @\(SWITCHBOARD_ITEM.DN_BRAKE_POSITION), " +
        "[\(SWITCHBOARD_ITEM.DN_STOP_POSITION)] = @\(SWITCHBOARD_ITEM.DN_STOP_POSITION), " +
        "[\(SWITCHBOARD_ITEM.DN_SPEED_MAX)] = @\(SWITCHBOARD_ITEM.DN_SPEED_MAX), " +
        "[\(SWITCHBOARD_ITEM.DN_SPEED_STOP_EXPECTED)] = @\(SWITCHBOARD_ITEM.DN_SPEED_STOP_EXPECTED), " +
        "[\(SWITCHBOARD_ITEM.DN_SPEED_RESTRICTED)] = @\(SWITCHBOARD_ITEM.DN_SPEED_RESTRICTED), " +
        "[\(SWITCHBOARD_ITEM.DN_SPEED_BRAKE)] = @\(SWITCHBOARD_ITEM.DN_SPEED_BRAKE), " +
        "[\(SWITCHBOARD_ITEM.DN_SPEED_SHUNT)] = @\(SWITCHBOARD_ITEM.DN_SPEED_SHUNT), " +
        "[\(SWITCHBOARD_ITEM.DN_SPEED_MAX_UD)] = @\(SWITCHBOARD_ITEM.DN_SPEED_MAX_UD), " +
        "[\(SWITCHBOARD_ITEM.DN_SPEED_STOP_EXPECTED_UD)] = @\(SWITCHBOARD_ITEM.DN_SPEED_STOP_EXPECTED_UD), " +
        "[\(SWITCHBOARD_ITEM.DN_SPEED_RESTRICTED_UD)] = @\(SWITCHBOARD_ITEM.DN_SPEED_RESTRICTED_UD), " +
        "[\(SWITCHBOARD_ITEM.DN_SPEED_BRAKE_UD)] = @\(SWITCHBOARD_ITEM.DN_SPEED_BRAKE_UD), " +
        "[\(SWITCHBOARD_ITEM.DN_SPEED_SHUNT_UD)] = @\(SWITCHBOARD_ITEM.DN_SPEED_SHUNT_UD), " +
        "[\(SWITCHBOARD_ITEM.DP_BRAKE_POSITION)] = @\(SWITCHBOARD_ITEM.DP_BRAKE_POSITION), " +
        "[\(SWITCHBOARD_ITEM.DP_STOP_POSITION)] = @\(SWITCHBOARD_ITEM.DP_STOP_POSITION), " +
        "[\(SWITCHBOARD_ITEM.DP_SPEED_MAX)] = @\(SWITCHBOARD_ITEM.DP_SPEED_MAX), " +
        "[\(SWITCHBOARD_ITEM.DP_SPEED_STOP_EXPECTED)] = @\(SWITCHBOARD_ITEM.DP_SPEED_STOP_EXPECTED), " +
        "[\(SWITCHBOARD_ITEM.DP_SPEED_RESTRICTED)] = @\(SWITCHBOARD_ITEM.DP_SPEED_RESTRICTED), " +
        "[\(SWITCHBOARD_ITEM.DP_SPEED_BRAKE)] = @\(SWITCHBOARD_ITEM.DP_SPEED_BRAKE), " +
        "[\(SWITCHBOARD_ITEM.DP_SPEED_SHUNT)] = @\(SWITCHBOARD_ITEM.DP_SPEED_SHUNT), " +
        "[\(SWITCHBOARD_ITEM.DP_SPEED_MAX_UD)] = @\(SWITCHBOARD_ITEM.DP_SPEED_MAX_UD), " +
        "[\(SWITCHBOARD_ITEM.DP_SPEED_STOP_EXPECTED_UD)] = @\(SWITCHBOARD_ITEM.DP_SPEED_STOP_EXPECTED_UD), " +
        "[\(SWITCHBOARD_ITEM.DP_SPEED_RESTRICTED_UD)] = @\(SWITCHBOARD_ITEM.DP_SPEED_RESTRICTED_UD), " +
        "[\(SWITCHBOARD_ITEM.DP_SPEED_BRAKE_UD)] = @\(SWITCHBOARD_ITEM.DP_SPEED_BRAKE_UD), " +
        "[\(SWITCHBOARD_ITEM.DP_SPEED_SHUNT_UD)] = @\(SWITCHBOARD_ITEM.DP_SPEED_SHUNT_UD), " +
        "[\(SWITCHBOARD_ITEM.SW1_LOCONET_DEVICE_ID)] = @\(SWITCHBOARD_ITEM.SW1_LOCONET_DEVICE_ID), " +
        "[\(SWITCHBOARD_ITEM.SW1_PORT)] = @\(SWITCHBOARD_ITEM.SW1_PORT), " +
        "[\(SWITCHBOARD_ITEM.SW1_TURNOUT_MOTOR_TYPE)] = @\(SWITCHBOARD_ITEM.SW1_TURNOUT_MOTOR_TYPE), " +
        "[\(SWITCHBOARD_ITEM.SW1_SENSOR_ID)] = @\(SWITCHBOARD_ITEM.SW1_SENSOR_ID), " +
        "[\(SWITCHBOARD_ITEM.SW2_LOCONET_DEVICE_ID)] = @\(SWITCHBOARD_ITEM.SW2_LOCONET_DEVICE_ID), " +
        "[\(SWITCHBOARD_ITEM.SW2_PORT)] = @\(SWITCHBOARD_ITEM.SW2_PORT), " +
        "[\(SWITCHBOARD_ITEM.SW2_TURNOUT_MOTOR_TYPE)] = @\(SWITCHBOARD_ITEM.SW2_TURNOUT_MOTOR_TYPE), " +
        "[\(SWITCHBOARD_ITEM.SW2_SENSOR_ID)] = @\(SWITCHBOARD_ITEM.SW2_SENSOR_ID) " +
        "WHERE [\(SWITCHBOARD_ITEM.SWITCHBOARD_ITEM_ID)] = @\(SWITCHBOARD_ITEM.SWITCHBOARD_ITEM_ID)"
      }

      let conn = Database.getConnection()
      
      let shouldClose = conn.state != .Open
       
      if shouldClose {
         _ = conn.open()
      }
       
      let cmd = conn.createCommand()
       
      cmd.commandText = sql
      
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.SWITCHBOARD_ITEM_ID)", value: primaryKey)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.LAYOUT_ID)", value: layoutId)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.PANEL_ID)", value: panelId)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.GROUP_ID)", value: groupId)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.ITEM_PART_TYPE)", value: itemPartType.rawValue)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.ORIENTATION)", value: orientation)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.XPOS)", value: location.x)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.YPOS)", value: location.y)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.BLOCK_NAME)", value: blockName)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.BLOCK_DIRECTION)", value: blockDirection.rawValue)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.TRACK_PART_ID)", value: trackPartId)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.DIMENSIONA)", value: dimensionA)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.DIMENSIONB)", value: dimensionB)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.DIMENSIONC)", value: dimensionC)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.DIMENSIOND)", value: dimensionD)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.DIMENSIONE)", value: dimensionE)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.DIMENSIONF)", value: dimensionF)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.DIMENSIONG)", value: dimensionG)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.DIMENSIONH)", value: dimensionH)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.UNITS_DIMENSION)", value: unitsDimension.rawValue)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.ALLOW_SHUNT)", value: allowShunt)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.TRACK_GAUGE)", value: trackGauge.rawValue)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.TRACK_ELECTRIFICATION_TYPE)", value: trackElectrificationType.rawValue)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.GRADIENT)", value: gradient)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.IS_CRITICAL)", value: isCritical)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.UNITS_SPEED)", value: unitsSpeed.rawValue)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.UNITS_POSITION)", value: unitsPosition.rawValue)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.DN_BRAKE_POSITION)", value: dirNextBrakePosition)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.DN_STOP_POSITION)", value: dirNextStopPosition)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.DN_SPEED_MAX)", value: dirNextSpeedMax)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.DN_SPEED_STOP_EXPECTED)", value: dirNextSpeedStopExpected)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.DN_SPEED_RESTRICTED)", value: dirNextSpeedRestricted)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.DN_SPEED_BRAKE)", value: dirNextSpeedBrake)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.DN_SPEED_SHUNT)", value: dirNextSpeedShunt)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.DN_SPEED_MAX_UD)", value: dirNextSpeedMaxUseDefault)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.DN_SPEED_STOP_EXPECTED_UD)", value: dirNextSpeedStopExpectedUseDefault)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.DN_SPEED_RESTRICTED_UD)", value: dirNextSpeedRestrictedUseDefault)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.DN_SPEED_BRAKE_UD)", value: dirNextSpeedBrakeUseDefault)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.DN_SPEED_SHUNT_UD)", value: dirNextSpeedShuntUseDefault)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.DP_BRAKE_POSITION)", value: dirPreviousBrakePosition)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.DP_STOP_POSITION)", value: dirPreviousStopPosition)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.DP_SPEED_MAX)", value: dirPreviousSpeedMax)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.DP_SPEED_STOP_EXPECTED)", value: dirPreviousSpeedStopExpected)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.DP_SPEED_RESTRICTED)", value: dirPreviousSpeedRestricted)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.DP_SPEED_BRAKE)", value: dirPreviousSpeedBrake)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.DP_SPEED_SHUNT)", value: dirPreviousSpeedShunt)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.DP_SPEED_MAX_UD)", value: dirPreviousSpeedMaxUseDefault)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.DP_SPEED_STOP_EXPECTED_UD)", value: dirPreviousSpeedStopExpectedUseDefault)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.DP_SPEED_RESTRICTED_UD)", value: dirPreviousSpeedRestrictedUseDefault)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.DP_SPEED_BRAKE_UD)", value: dirPreviousSpeedBrakeUseDefault)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.DP_SPEED_SHUNT_UD)", value: dirPreviousSpeedShuntUseDefault)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.SW1_LOCONET_DEVICE_ID)", value: sw1LocoNetDeviceId)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.SW1_PORT)", value: sw1Port)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.SW1_TURNOUT_MOTOR_TYPE)", value: sw1TurnoutMotorType.rawValue)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.SW1_SENSOR_ID)", value: sw1SensorId)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.SW2_LOCONET_DEVICE_ID)", value: sw2LocoNetDeviceId)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.SW2_PORT)", value: sw2Port)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.SW2_TURNOUT_MOTOR_TYPE)", value: sw2TurnoutMotorType.rawValue)
      cmd.parameters.addWithValue(key: "@\(SWITCHBOARD_ITEM.SW2_SENSOR_ID)", value: sw2SensorId)

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
        "[\(SWITCHBOARD_ITEM.SWITCHBOARD_ITEM_ID)], " +
        "[\(SWITCHBOARD_ITEM.LAYOUT_ID)], " +
        "[\(SWITCHBOARD_ITEM.PANEL_ID)], " +
        "[\(SWITCHBOARD_ITEM.GROUP_ID)], " +
        "[\(SWITCHBOARD_ITEM.ITEM_PART_TYPE)], " +
        "[\(SWITCHBOARD_ITEM.ORIENTATION)], " +
        "[\(SWITCHBOARD_ITEM.XPOS)], " +
        "[\(SWITCHBOARD_ITEM.YPOS)], " +
        "[\(SWITCHBOARD_ITEM.BLOCK_NAME)], " +
        "[\(SWITCHBOARD_ITEM.BLOCK_DIRECTION)], " +
        "[\(SWITCHBOARD_ITEM.TRACK_PART_ID)], " +
        "[\(SWITCHBOARD_ITEM.DIMENSIONA)], " +
        "[\(SWITCHBOARD_ITEM.DIMENSIONB)], " +
        "[\(SWITCHBOARD_ITEM.DIMENSIONC)], " +
        "[\(SWITCHBOARD_ITEM.DIMENSIOND)], " +
        "[\(SWITCHBOARD_ITEM.DIMENSIONE)], " +
        "[\(SWITCHBOARD_ITEM.DIMENSIONF)], " +
        "[\(SWITCHBOARD_ITEM.DIMENSIONG)], " +
        "[\(SWITCHBOARD_ITEM.DIMENSIONH)], " +
        "[\(SWITCHBOARD_ITEM.UNITS_DIMENSION)], " +
        "[\(SWITCHBOARD_ITEM.ALLOW_SHUNT)], " +
        "[\(SWITCHBOARD_ITEM.TRACK_GAUGE)], " +
        "[\(SWITCHBOARD_ITEM.TRACK_ELECTRIFICATION_TYPE)], " +
        "[\(SWITCHBOARD_ITEM.GRADIENT)], " +
        "[\(SWITCHBOARD_ITEM.IS_CRITICAL)], " +
        "[\(SWITCHBOARD_ITEM.UNITS_SPEED)], " +
        "[\(SWITCHBOARD_ITEM.UNITS_POSITION)], " +
        "[\(SWITCHBOARD_ITEM.DN_BRAKE_POSITION)], " +
        "[\(SWITCHBOARD_ITEM.DN_STOP_POSITION)], " +
        "[\(SWITCHBOARD_ITEM.DN_SPEED_MAX)], " +
        "[\(SWITCHBOARD_ITEM.DN_SPEED_STOP_EXPECTED)], " +
        "[\(SWITCHBOARD_ITEM.DN_SPEED_RESTRICTED)], " +
        "[\(SWITCHBOARD_ITEM.DN_SPEED_BRAKE)], " +
        "[\(SWITCHBOARD_ITEM.DN_SPEED_SHUNT)], " +
        "[\(SWITCHBOARD_ITEM.DN_SPEED_MAX_UD)], " +
        "[\(SWITCHBOARD_ITEM.DN_SPEED_STOP_EXPECTED_UD)], " +
        "[\(SWITCHBOARD_ITEM.DN_SPEED_RESTRICTED_UD)], " +
        "[\(SWITCHBOARD_ITEM.DN_SPEED_BRAKE_UD)], " +
        "[\(SWITCHBOARD_ITEM.DN_SPEED_SHUNT_UD)], " +
        "[\(SWITCHBOARD_ITEM.DP_BRAKE_POSITION)], " +
        "[\(SWITCHBOARD_ITEM.DP_STOP_POSITION)], " +
        "[\(SWITCHBOARD_ITEM.DP_SPEED_MAX)], " +
        "[\(SWITCHBOARD_ITEM.DP_SPEED_STOP_EXPECTED)], " +
        "[\(SWITCHBOARD_ITEM.DP_SPEED_RESTRICTED)], " +
        "[\(SWITCHBOARD_ITEM.DP_SPEED_BRAKE)], " +
        "[\(SWITCHBOARD_ITEM.DP_SPEED_SHUNT)], " +
        "[\(SWITCHBOARD_ITEM.DP_SPEED_MAX_UD)], " +
        "[\(SWITCHBOARD_ITEM.DP_SPEED_STOP_EXPECTED_UD)], " +
        "[\(SWITCHBOARD_ITEM.DP_SPEED_RESTRICTED_UD)], " +
        "[\(SWITCHBOARD_ITEM.DP_SPEED_BRAKE_UD)], " +
        "[\(SWITCHBOARD_ITEM.DP_SPEED_SHUNT_UD)], " +
        "[\(SWITCHBOARD_ITEM.SW1_LOCONET_DEVICE_ID)], " +
        "[\(SWITCHBOARD_ITEM.SW1_PORT)], " +
        "[\(SWITCHBOARD_ITEM.SW1_TURNOUT_MOTOR_TYPE)], " +
        "[\(SWITCHBOARD_ITEM.SW1_SENSOR_ID)], " +
        "[\(SWITCHBOARD_ITEM.SW2_LOCONET_DEVICE_ID)], " +
        "[\(SWITCHBOARD_ITEM.SW2_PORT)], " +
        "[\(SWITCHBOARD_ITEM.SW2_TURNOUT_MOTOR_TYPE)], " +
        "[\(SWITCHBOARD_ITEM.SW2_SENSOR_ID)]"
    }
  }

  // MARK: Class Methods
  
  public static func createKey(panelId: Int, location: SwitchBoardLocation, nextAction: SwitchBoardItemAction) -> Int {
    return (location.x & 0xffff) | ((location.y & 0xffff) << 16) | ((panelId & 0xff) << 32) | ((nextAction == .delete) ? (1 << 40) : 0)
  }
  
}
