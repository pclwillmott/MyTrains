//
//  LocoNetDevice.swift
//  MyTrains
//
//  Created by Paul Willmott on 05/05/2022.
//

import Foundation

public class LocoNetDevice : EditorObject {
  
  // MARK: Constructors
  
  init(reader:SqliteDataReader) {
    
    super.init(primaryKey: -1)
    
    decode(sqliteDataReader: reader)
    
    for index in 0...3 {
      _newOptionSwitchState[index] = _optionSwitchState[index]
    }
    
  }

  override init(primaryKey:Int) {
    super.init(primaryKey: primaryKey)
  }
  
  // MARK: Private Enums
  
  private enum Flag {
    static let opswRead : Int64 = 0b0000000000000000000000000000000000000000000000000000000000000001
  }
  
  // MARK: Private Properties

  private var _optionSwitches : [OptionSwitch]?
  
  private var _methodForOpSw : [OptionSwitchMethod:Set<Int>]?
  
  private var _optionSwitchDictionary : [Int:OptionSwitch]?
  
  private var _optionSwitchState = [UInt64](repeating: 0, count: 4)
  
  private var _newOptionSwitchState = [UInt64](repeating: 0, count: 4)

  // MARK: Public Properties
  
  public var optionSwitches : [OptionSwitch] {
    get {
      makeOptionSwitches()
      return _optionSwitches!
    }
  }
  
  public var optionSwitchDictionary : [Int:OptionSwitch] {
    get {
      makeOptionSwitches()
      return _optionSwitchDictionary!
    }
  }
  
  public var optionSwitchesSet : Set<Int> {
    get {
      var result : Set<Int> = []
      for opsw in optionSwitches {
        result.insert(opsw.switchNumber)
      }
      return result
    }
  }

  public var optionSwitchesChanged : [OptionSwitch] {
    
    get {
      
      var result : [OptionSwitch] = []
      
      for switchNumber in optionSwitchesChangedSet {
        if let opsw = optionSwitchDictionary[switchNumber] {
          result.append(opsw)
        }
      }
      
      return result
    }
    
  }
  
  public var optionSwitchesChangedSet : Set<Int> {
    
    get {
      
      var result : Set<Int> = []
      
      var changed = [UInt64](repeating: 0, count: 4)
      
      for index in 0...3 {
        changed[index] = _optionSwitchState[index] ^ _newOptionSwitchState[index]
      }
      
      for switchNumber in 1...256 {
        
        let sn = switchNumber - 1
        
        let byte = sn / 64
        
        let bit = sn % 64
        
        let mask : UInt64 = 1 << bit
        
        if (changed[byte] & mask) == mask {
          result.insert(switchNumber)
        }
        
      }
      
      return result
      
    }
    
  }

  public var optionSwitchSet : Set<Int> {
    get {
      
      var result : Set<Int> = []
      
      for opsw in optionSwitches {
        result.insert(opsw.switchNumber)
      }
      
      return result
    }
  }
  
  public var methodForOpSw : [OptionSwitchMethod:Set<Int>] {
    
    get {
      
      if _methodForOpSw == nil, let info = locoNetProductInfo {
        
        var series7     : Set<Int> = []
        var brdOpSw     : Set<Int> = []
        var opswDataAP1 : Set<Int> = []
        var opswDataBP1 : Set<Int> = []
        var opMode      : Set<Int> = []
        
        let hasBankA   = info.attributes.contains(.OpSwDataAP1)
        let hasBankB   = info.attributes.contains(.OpSwDataBP1)
        let hasBrdOpSw = info.attributes.contains(.BrdOpSw)
        
        for opsw in optionSwitchSet {
          
          if isSeries7 {
            series7.insert(opsw)
          }
          else if hasBrdOpSw {
            brdOpSw.insert(opsw)
          }
          else if hasBankA && (opsw % 8) != 0 && opsw > 0 && opsw <= 64 {
            opswDataAP1.insert(opsw)
          }
          else if hasBankB && (opsw % 8) != 0 && opsw > 64 && opsw <= 128 {
            opswDataBP1.insert(opsw)
          }
          else {
            opMode.insert(opsw)
          }
        }
        
        var result : [OptionSwitchMethod:Set<Int>] = [:]
        
        result[.Series7]     = series7
        result[.BrdOpSw]     = brdOpSw
        result[.OpSwDataAP1] = opswDataAP1
        result[.OpSwDataBP1] = opswDataBP1
        result[.OpMode]      = opMode
        
        _methodForOpSw = result
        
      }
      
      return _methodForOpSw!
      
    }
  }
  
  public var sensors : [Sensor] = []
  
  public var networkId : Int = -1 {
    didSet {
      modified = true
    }
  }
  
  public var network : Network? {
    get {
      return networkController.networks[networkId]
    }
  }
  
  public var serialNumber : Int = 0 {
    didSet {
      modified = true
    }
  }
  
  public var softwareVersion : Double = 0.0 {
    didSet {
      modified = true
    }
  }
  
  public var hardwareVersion : Double = 0.0 {
    didSet {
      modified = true
    }
  }
  
  public var boardId : Int = -1 {
    didSet {
      modified = true
    }
  }
  
  public var locoNetProductId : LocoNetProductId = .UNKNOWN {
    didSet {
      modified = true
    }
  }
  
  public var locoNetProductInfo : LocoNetProduct? {
    get {
      return LocoNetProducts.product(id: locoNetProductId)
    }
  }
  
  public var isSeries7 : Bool {
    get {
      if let info = locoNetProductInfo {
        return info.attributes.contains(.Series7)
      }
      return false
    }
  }
  
  public var optionSwitchesOK : Bool {
    get {
      return (flags & Flag.opswRead) == Flag.opswRead
    }
    set(value) {
      var temp = flags & ~Flag.opswRead
      if value {
        temp |= Flag.opswRead
      }
      flags = temp
    }
  }
  
  public var newOpSwDataAP1 : [UInt8] {
    get {
      
      var result : [UInt8] = [UInt8](repeating: 0, count: 11)
      
      result[0] = 0x7f
      
      for switchNumber in 1...64 {
        
        if (switchNumber % 8) != 0 {
        
          let sn = switchNumber - 1
          
          let byte = (sn / 8) + (switchNumber < 33 ? 1 : 2)
          
          let bit = sn % 8
          
          let mask : UInt8 = 1 << bit
          
          let safe : UInt8 = ~mask
          
          let newState = getNewState(switchNumber: switchNumber)
          
          let value = newState.isClosed ? mask : 0
          
          result[byte] = (result[byte] & safe) | value
          
        }
        
      }
      
      return result
      
    }
  }
 
  public var newOpSwDataBP1 : [UInt8] {
    get {
      
      var result : [UInt8] = [UInt8](repeating: 0, count: 11)
      
      result[0] = 0x7e
      
      for switchNumber in 65...128 {
        
        if (switchNumber % 8) != 0 {
        
          let sn = switchNumber - 1 - 64
          
          let byte = (sn / 8) + (switchNumber < 97 ? 1 : 2)
          
          let bit = sn % 8
          
          let mask : UInt8 = 1 << bit
          
          let safe = ~mask
          
          let value = getNewState(switchNumber: switchNumber).isClosed ? mask : 0
          
          result[byte] = (result[byte] & safe) | value
          
        }
        
      }
      
      return result
      
    }
  }

  public var devicePath : String = "" {
    didSet {
      modified = true
    }
  }
  
  public var baudRate : BaudRate = .br230400 {
    didSet {
      modified = true
    }
  }

  public var deviceName : String = "" {
    didSet {
      modified = true
    }
  }
  
  public var flowControl : FlowControl = .noFlowControl {
    didSet {
      modified = true
    }
  }
  
  public var isStandAloneLoconet : Bool = false {
    didSet {
      modified = true
    }
  }
  
  public var isSensorDevice : Bool {
    get {
      if let info = locoNetProductInfo {
        return !info.attributes.intersection([.PowerManager, .Transponding, .OccupancyDetector]).isEmpty
      }
      return false
    }
  }
  
  public var isStationaryDecoder : Bool {
    get {
      if let info = locoNetProductInfo {
        return !info.attributes.intersection([.StationaryDecoder]).isEmpty
      }
      return false
    }
  }
  
  public var flags : Int64 = 0 {
    didSet {
      modified = true
    }
  }
  
  public var iplName : String {
    get {
      if let info = locoNetProductInfo {
        var name = "Digitrax \(info.productName) SN: #\(serialNumber)"
        if !info.attributes.intersection([.OccupancyDetector, .PowerManager, .Transponding]).isEmpty {
          name += " BID: \(boardId)"
        }
        return name
      }
      return ""
    }
  }
  
  override public func sortString() -> String {
    let name = displayString()
    if name.contains("BID:") {
      let split = displayString().split(separator: ":")
      let s = String(("00000000" + split[split.count-1].trimmingCharacters(in: .whitespaces)).suffix(8))
      return s
    }
    return displayString()
  }
  
  // MARK: Private Methods
  
  private func makeOptionSwitches() {
    if _optionSwitches == nil {
      _optionSwitches = []
      _optionSwitchDictionary = [:]
      for opSwDef in OptionSwitch.switches(locoNetProductId: locoNetProductId) {
        let opSw = OptionSwitch(locoNetDevice: self, switchDefinition: opSwDef)
        _optionSwitches!.append(opSw)
        _optionSwitchDictionary![opSw.switchNumber] = opSw
      }
      _optionSwitches!.sort {$0.switchNumber < $1.switchNumber}
    }
  }
  
  private func makeSensors() {
    
    if let info = locoNetProductInfo {
      
      for index in 1...info.sensors {
        let sensor = Sensor()
        sensor.locoNetDeviceId = primaryKey
        sensor.channelNumber = index
        sensors.append(sensor)
      }
      
    }
    
  }
    
  // MARK: Public Methods
  
  override public func displayString() -> String {
    return deviceName == "" ? "unnamed device" : deviceName
  }
  
  public func newS7CV(cvNumber:Int) -> UInt8 {
    
    let baseSwitchNumber = (cvNumber - 11) * 8 + 1
    
    var result : UInt8 = 0
    
    for index in 0...7 {
      
      if getNewState(switchNumber: baseSwitchNumber + index).isClosed {
        result |= 1 << index
      }
      
    }
    
    return result
    
  }
  
  public func setState(cvNumber:Int, s7CVState:NetworkMessage) {

    let baseSwitchNumber = (cvNumber - 11 ) * 8 + 1
    
    for bit in 0...6 {
      
      let switchNumber =  baseSwitchNumber + bit
      
      let mask : UInt8 = 1 << bit
      
      let value : OptionSwitchState = ((s7CVState.message[2] & mask) == mask ? .closed : .thrown)
      
      setState(switchNumber: switchNumber, value: value)
      
    }
      
    let mask : UInt8 = 0b00000011
      
    let value : OptionSwitchState = ((s7CVState.message[1] & mask) == 0b00000010 ? .thrown : .closed)

    setState(switchNumber: baseSwitchNumber + 7, value: value)
      
  }
  
  public func getState(switchNumber: Int) -> OptionSwitchState {
    
    guard switchNumber > 0 && switchNumber < 257 else {
      return .thrown
    }
    
    let sn = switchNumber - 1
    
    let byte = sn / 64
    
    let bit = sn % 64
    
    let mask : UInt64 = 1 << bit
    
    return ((_optionSwitchState[byte] & mask) == mask) ? .closed : .thrown
    
  }

  public func setState(switchNumber: Int, value: OptionSwitchState) {

    guard switchNumber > 0 && switchNumber < 257 else {
      return
    }
    
    let sn = switchNumber - 1
    
    let byte = sn / 64
    
    let bit = sn % 64
    
    let mask : UInt64 = 1 << bit

    let safe = ~mask
    
    let temp : UInt64 = (value.isClosed) ? mask : 0

    _optionSwitchState[byte] = (_optionSwitchState[byte] & safe) | temp
    _newOptionSwitchState[byte] = (_newOptionSwitchState[byte] & safe) | temp

    modified = true
    
  }
  
  public func getNewState(switchNumber: Int) -> OptionSwitchState {
    
    guard switchNumber > 0 && switchNumber < 257 else {
      return .thrown
    }
    
    let sn = switchNumber - 1
    
    let byte = sn / 64
    
    let bit = sn % 64
    
    let mask : UInt64 = 1 << bit
    
    return ((_newOptionSwitchState[byte] & mask) == mask) ? .closed : .thrown
    
  }

  public func setNewState(switchNumber: Int, value: OptionSwitchState) {

    guard switchNumber > 0 && switchNumber < 257 else {
      return
    }
    
    let sn = switchNumber - 1
    
    let byte = sn / 64
    
    let bit = sn % 64
    
    let mask : UInt64 = 1 << bit

    let safe = ~mask
    
    let temp : UInt64 = (value.isClosed) ? mask : 0

    _newOptionSwitchState[byte] = (_newOptionSwitchState[byte] & safe) | temp
    
    modified = true
    
  }
  
  public func setState(opswDataAP1:NetworkMessage) {
   
    for switchNumber in 1...64 {
      
      if (switchNumber % 8) != 0 {
      
        let sn = switchNumber - 1
        
        let byte = (sn / 8) + (switchNumber < 33 ? 3 : 4)
        
        let bit = sn % 8
        
        let mask : UInt8 = 1 << bit
        
        let value : OptionSwitchState = (opswDataAP1.message[byte] & mask) == mask ? .closed : .thrown
        
        setState(switchNumber: switchNumber, value: value)
        
      }
      
    }
    
  }

  public func setState(opswDataBP1:NetworkMessage) {

    for switchNumber in 65...128 {
      
      if (switchNumber % 8) != 0 {
      
        let sn = switchNumber - 1 - 64
        
        let byte = (sn / 8) + (switchNumber < 97 ? 3 : 4)
        
        let bit = sn % 8
        
        let mask : UInt8 = 1 << bit
        
        let value : OptionSwitchState = (opswDataBP1.message[byte] & mask) == mask ? .closed : .thrown
        
        setState(switchNumber: switchNumber, value: value)
        
      }
      
    }

  }

// MARK: Database Methods
  
  private func decode(sqliteDataReader:SqliteDataReader?) {
    
    if let reader = sqliteDataReader {
      
      primaryKey = reader.getInt(index: 0)!

      if !reader.isDBNull(index: 1) {
        networkId = reader.getInt(index: 1)!
      }
      
      if !reader.isDBNull(index: 2) {
        serialNumber = reader.getInt(index: 2)!
      }

      if !reader.isDBNull(index: 3) {
        softwareVersion = reader.getDouble(index: 3)!
      }
      
      if !reader.isDBNull(index: 4) {
        hardwareVersion = reader.getDouble(index: 4)!
      }
      
      if !reader.isDBNull(index: 5) {
        boardId = reader.getInt(index: 5)!
      }

      if !reader.isDBNull(index: 6) {
        locoNetProductId = LocoNetProductId(rawValue: reader.getInt(index: 6)!) ?? .UNKNOWN
      }
      
      if !reader.isDBNull(index: 7) {
        _optionSwitchState[0] = UInt64(reader.getInt64(index: 7)!)
      }
      
      if !reader.isDBNull(index: 8) {
        _optionSwitchState[1] = UInt64(reader.getInt64(index: 8)!)
      }
      
      if !reader.isDBNull(index: 9) {
        _optionSwitchState[2] = UInt64(reader.getInt64(index: 9)!)
      }
      
      if !reader.isDBNull(index: 10) {
        _optionSwitchState[3] = UInt64(reader.getInt64(index: 10)!)
      }
      
      if !reader.isDBNull(index: 11) {
        devicePath = reader.getString(index: 11)!
      }

      if !reader.isDBNull(index: 12) {
        baudRate = BaudRate(rawValue: reader.getInt(index: 12)!) ?? .br57600
      }

      if !reader.isDBNull(index: 13) {
        deviceName = reader.getString(index: 13)!
      }

      if !reader.isDBNull(index: 14) {
        flowControl = FlowControl(rawValue: reader.getInt(index: 14)!) ?? .noFlowControl
      }

      if !reader.isDBNull(index: 15) {
        isStandAloneLoconet = reader.getBool(index: 15)!
      }

      if !reader.isDBNull(index: 16) {
        flags = reader.getInt64(index: 16)!
      }

    }
    
    modified = false
    
    if let info = locoNetProductInfo, info.sensors > 0 {
      sensors = Sensor.sensors(locoNetDevice: self)
      if sensors.count == 0 {
        makeSensors()
      }
    }
    
  }

  public func save() {
    
    if modified {
      
      for index in 0...3 {
        _optionSwitchState[index] = _newOptionSwitchState[index]
      }
      
      for opsw in optionSwitches {
        let def = opsw.switchDefinition.defaultState
        if def.isAuto {
          setState(switchNumber: opsw.switchNumber, value: def.value)
        }
      }

      var sql = ""
      
      if !Database.codeExists(tableName: TABLE.LOCONET_DEVICE, primaryKey: LOCONET_DEVICE.LOCONET_DEVICE_ID, code: primaryKey)! {
        sql = "INSERT INTO [\(TABLE.LOCONET_DEVICE)] (" +
        "[\(LOCONET_DEVICE.LOCONET_DEVICE_ID)], " +
        "[\(LOCONET_DEVICE.NETWORK_ID)], " +
        "[\(LOCONET_DEVICE.SERIAL_NUMBER)], " +
        "[\(LOCONET_DEVICE.SOFTWARE_VERSION)], " +
        "[\(LOCONET_DEVICE.HARDWARE_VERSION)], " +
        "[\(LOCONET_DEVICE.BOARD_ID)], " +
        "[\(LOCONET_DEVICE.LOCONET_PRODUCT_ID)], " +
        "[\(LOCONET_DEVICE.OPTION_SWITCHES_0)], " +
        "[\(LOCONET_DEVICE.OPTION_SWITCHES_1)], " +
        "[\(LOCONET_DEVICE.OPTION_SWITCHES_2)], " +
        "[\(LOCONET_DEVICE.OPTION_SWITCHES_3)], " +
        "[\(LOCONET_DEVICE.DEVICE_PATH)], " +
        "[\(LOCONET_DEVICE.BAUD_RATE)], " +
        "[\(LOCONET_DEVICE.DEVICE_NAME)], " +
        "[\(LOCONET_DEVICE.FLOW_CONTROL)], " +
        "[\(LOCONET_DEVICE.IS_STAND_ALONE_LOCONET)], " +
        "[\(LOCONET_DEVICE.FLAGS)]" +
        ") VALUES (" +
        "@\(LOCONET_DEVICE.LOCONET_DEVICE_ID), " +
        "@\(LOCONET_DEVICE.NETWORK_ID), " +
        "@\(LOCONET_DEVICE.SERIAL_NUMBER), " +
        "@\(LOCONET_DEVICE.SOFTWARE_VERSION), " +
        "@\(LOCONET_DEVICE.HARDWARE_VERSION), " +
        "@\(LOCONET_DEVICE.BOARD_ID), " +
        "@\(LOCONET_DEVICE.LOCONET_PRODUCT_ID), " +
        "@\(LOCONET_DEVICE.OPTION_SWITCHES_0), " +
        "@\(LOCONET_DEVICE.OPTION_SWITCHES_1), " +
        "@\(LOCONET_DEVICE.OPTION_SWITCHES_2), " +
        "@\(LOCONET_DEVICE.OPTION_SWITCHES_3), " +
        "@\(LOCONET_DEVICE.DEVICE_PATH), " +
        "@\(LOCONET_DEVICE.BAUD_RATE), " +
        "@\(LOCONET_DEVICE.DEVICE_NAME), " +
        "@\(LOCONET_DEVICE.FLOW_CONTROL), " +
        "@\(LOCONET_DEVICE.IS_STAND_ALONE_LOCONET), " +
        "@\(LOCONET_DEVICE.FLAGS)" +
        ")"
        primaryKey = Database.nextCode(tableName: TABLE.LOCONET_DEVICE, primaryKey: LOCONET_DEVICE.LOCONET_DEVICE_ID)!
      }
      else {
        sql = "UPDATE [\(TABLE.LOCONET_DEVICE)] SET " +
        "[\(LOCONET_DEVICE.NETWORK_ID)] = @\(LOCONET_DEVICE.NETWORK_ID), " +
        "[\(LOCONET_DEVICE.SERIAL_NUMBER)] = @\(LOCONET_DEVICE.SERIAL_NUMBER), " +
        "[\(LOCONET_DEVICE.SOFTWARE_VERSION)] = @\(LOCONET_DEVICE.SOFTWARE_VERSION), " +
        "[\(LOCONET_DEVICE.HARDWARE_VERSION)] = @\(LOCONET_DEVICE.HARDWARE_VERSION), " +
        "[\(LOCONET_DEVICE.BOARD_ID)] = @\(LOCONET_DEVICE.BOARD_ID), " +
        "[\(LOCONET_DEVICE.LOCONET_PRODUCT_ID)] = @\(LOCONET_DEVICE.LOCONET_PRODUCT_ID), " +
        "[\(LOCONET_DEVICE.OPTION_SWITCHES_0)] = @\(LOCONET_DEVICE.OPTION_SWITCHES_0), " +
        "[\(LOCONET_DEVICE.OPTION_SWITCHES_1)] = @\(LOCONET_DEVICE.OPTION_SWITCHES_1), " +
        "[\(LOCONET_DEVICE.OPTION_SWITCHES_2)] = @\(LOCONET_DEVICE.OPTION_SWITCHES_2), " +
        "[\(LOCONET_DEVICE.OPTION_SWITCHES_3)] = @\(LOCONET_DEVICE.OPTION_SWITCHES_3), " +
        "[\(LOCONET_DEVICE.DEVICE_PATH)] = @\(LOCONET_DEVICE.DEVICE_PATH), " +
        "[\(LOCONET_DEVICE.BAUD_RATE)] = @\(LOCONET_DEVICE.BAUD_RATE), " +
        "[\(LOCONET_DEVICE.DEVICE_NAME)] = @\(LOCONET_DEVICE.DEVICE_NAME), " +
        "[\(LOCONET_DEVICE.FLOW_CONTROL)] = @\(LOCONET_DEVICE.FLOW_CONTROL), " +
        "[\(LOCONET_DEVICE.IS_STAND_ALONE_LOCONET)] = @\(LOCONET_DEVICE.IS_STAND_ALONE_LOCONET), " +
        "[\(LOCONET_DEVICE.FLAGS)] = @\(LOCONET_DEVICE.FLAGS) " +
        "WHERE [\(LOCONET_DEVICE.LOCONET_DEVICE_ID)] = @\(LOCONET_DEVICE.LOCONET_DEVICE_ID)"
      }

      let conn = Database.getConnection()
      
      let shouldClose = conn.state != .Open
       
      if shouldClose {
         _ = conn.open()
      }
       
      let cmd = conn.createCommand()
       
      cmd.commandText = sql
      
      cmd.parameters.addWithValue(key: "@\(LOCONET_DEVICE.LOCONET_DEVICE_ID)", value: primaryKey)
      cmd.parameters.addWithValue(key: "@\(LOCONET_DEVICE.NETWORK_ID)", value: networkId)
      cmd.parameters.addWithValue(key: "@\(LOCONET_DEVICE.SERIAL_NUMBER)", value: serialNumber)
      cmd.parameters.addWithValue(key: "@\(LOCONET_DEVICE.SOFTWARE_VERSION)", value: softwareVersion)
      cmd.parameters.addWithValue(key: "@\(LOCONET_DEVICE.HARDWARE_VERSION)", value: hardwareVersion)
      cmd.parameters.addWithValue(key: "@\(LOCONET_DEVICE.BOARD_ID)", value: boardId)
      cmd.parameters.addWithValue(key: "@\(LOCONET_DEVICE.LOCONET_PRODUCT_ID)", value: locoNetProductId.rawValue)
      cmd.parameters.addWithValue(key: "@\(LOCONET_DEVICE.OPTION_SWITCHES_0)", value: Int64(_optionSwitchState[0]))
      cmd.parameters.addWithValue(key: "@\(LOCONET_DEVICE.OPTION_SWITCHES_1)", value: Int64(_optionSwitchState[1]))
      cmd.parameters.addWithValue(key: "@\(LOCONET_DEVICE.OPTION_SWITCHES_2)", value: Int64(_optionSwitchState[2]))
      cmd.parameters.addWithValue(key: "@\(LOCONET_DEVICE.OPTION_SWITCHES_3)", value: Int64(_optionSwitchState[3]))
      cmd.parameters.addWithValue(key: "@\(LOCONET_DEVICE.DEVICE_PATH)", value: devicePath)
      cmd.parameters.addWithValue(key: "@\(LOCONET_DEVICE.BAUD_RATE)", value: baudRate.rawValue)
      cmd.parameters.addWithValue(key: "@\(LOCONET_DEVICE.DEVICE_NAME)", value: deviceName)
      cmd.parameters.addWithValue(key: "@\(LOCONET_DEVICE.FLOW_CONTROL)", value: flowControl.rawValue)
      cmd.parameters.addWithValue(key: "@\(LOCONET_DEVICE.IS_STAND_ALONE_LOCONET)", value: isStandAloneLoconet)
      cmd.parameters.addWithValue(key: "@\(LOCONET_DEVICE.FLAGS)", value: flags)

      _ = cmd.executeNonQuery()

      if shouldClose {
        conn.close()
      }
      
      modified = false
      
    }
    
    if let info = locoNetProductInfo, info.sensors > 0 {
      if sensors.count == 0 {
        makeSensors()
      }
    }
    
    for sensor in sensors {
      sensor.save()
    }

  }

  // MARK: Class Properties
  
  public static var columnNames : String {
    get {
      let names =
      "[\(LOCONET_DEVICE.LOCONET_DEVICE_ID)], " +
      "[\(LOCONET_DEVICE.NETWORK_ID)], " +
      "[\(LOCONET_DEVICE.SERIAL_NUMBER)], " +
      "[\(LOCONET_DEVICE.SOFTWARE_VERSION)], " +
      "[\(LOCONET_DEVICE.HARDWARE_VERSION)], " +
      "[\(LOCONET_DEVICE.BOARD_ID)], " +
      "[\(LOCONET_DEVICE.LOCONET_PRODUCT_ID)], " +
      "[\(LOCONET_DEVICE.OPTION_SWITCHES_0)], " +
      "[\(LOCONET_DEVICE.OPTION_SWITCHES_1)], " +
      "[\(LOCONET_DEVICE.OPTION_SWITCHES_2)], " +
      "[\(LOCONET_DEVICE.OPTION_SWITCHES_3)], " +
      "[\(LOCONET_DEVICE.DEVICE_PATH)], " +
      "[\(LOCONET_DEVICE.BAUD_RATE)], " +
      "[\(LOCONET_DEVICE.DEVICE_NAME)], " +
      "[\(LOCONET_DEVICE.FLOW_CONTROL)], " +
      "[\(LOCONET_DEVICE.IS_STAND_ALONE_LOCONET)], " +
      "[\(LOCONET_DEVICE.FLAGS)]"
      return names
    }
  }

  public static var locoNetDevices : [Int:LocoNetDevice] {
    
    get {
    
      let conn = Database.getConnection()
      
      let shouldClose = conn.state != .Open
       
      if shouldClose {
        _ = conn.open()
      }
       
      let cmd = conn.createCommand()
       
      cmd.commandText = "SELECT \(columnNames) FROM [\(TABLE.LOCONET_DEVICE)] ORDER BY [\(LOCONET_DEVICE.LOCONET_DEVICE_ID)]"

      var result : [Int:LocoNetDevice] = [:]
      
      if let reader = cmd.executeReader() {
           
        while reader.read() {
          let device = LocoNetDevice(reader: reader)
          if let info = device.locoNetProductInfo {
            if info.attributes.intersection([.CommandStation, .ComputerInterface]).isEmpty {
              result[device.primaryKey] = device
            }
            else {
              result[device.primaryKey] = Interface(reader: reader)
            }
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
  
  public static func delete(primaryKey: Int) {
    
    let sql = [
      "DELETE FROM [\(TABLE.SENSOR)] WHERE [\(SENSOR.LOCONET_DEVICE_ID)] = \(primaryKey)",
      "DELETE FROM [\(TABLE.LOCONET_DEVICE)] WHERE [\(LOCONET_DEVICE.LOCONET_DEVICE_ID)] = \(primaryKey)"
    ]
    Database.execute(commands: sql)
  }
  
}
