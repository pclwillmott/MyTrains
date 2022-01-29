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
  
  public func protectMask() -> UInt8 {
    return 0b11111000
  }
  
  public func setMask() -> UInt8 {
    
    var mask : UInt8 = 0
    
    switch self {
    case .dcc28:
      mask = 0b000
    case .dcc28T:
      mask = 0b001
    case .dcc14:
      mask = 0b010
    case .dcc128:
      mask = 0b011
    case .dcc28A:
      mask = 0b100
    case .dcc128A:
      mask = 0b111
    default:
      break
    }
    
    return mask
    
  }
  
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

public enum LengthUnit : Int {
  case millimeters = 0
  case centimeters = 1
  case meters = 2
  case inches = 3
  case feet = 4
}

public enum SpeedUnit : Int {
  case kilometersPerHour = 0
  case milesPerHour = 1
}

public enum LocomotiveDirection {
  case forward
  case reverse
}

public protocol LocomotiveDelegate {
  func stateUpdated(locomotive: Locomotive)
}

public typealias LocomotiveSpeed = (speed: Int, direction: LocomotiveDirection)

public typealias LocomotiveState = (speed:Int, direction:LocomotiveDirection, functions:Int)

public let maskF0  = 0b00000000000000000000000000000001
public let maskF1  = 0b00000000000000000000000000000010
public let maskF2  = 0b00000000000000000000000000000100
public let maskF3  = 0b00000000000000000000000000001000
public let maskF4  = 0b00000000000000000000000000010000
public let maskF5  = 0b00000000000000000000000000100000
public let maskF6  = 0b00000000000000000000000001000000
public let maskF7  = 0b00000000000000000000000010000000
public let maskF8  = 0b00000000000000000000000100000000
public let maskF9  = 0b00000000000000000000001000000000
public let maskF10 = 0b00000000000000000000010000000000
public let maskF11 = 0b00000000000000000000100000000000
public let maskF12 = 0b00000000000000000001000000000000
public let maskF13 = 0b00000000000000000010000000000000
public let maskF14 = 0b00000000000000000100000000000000
public let maskF15 = 0b00000000000000001000000000000000
public let maskF16 = 0b00000000000000010000000000000000
public let maskF17 = 0b00000000000000100000000000000000
public let maskF18 = 0b00000000000001000000000000000000
public let maskF19 = 0b00000000000010000000000000000000
public let maskF20 = 0b00000000000100000000000000000000
public let maskF21 = 0b00000000001000000000000000000000
public let maskF22 = 0b00000000010000000000000000000000
public let maskF23 = 0b00000000100000000000000000000000
public let maskF24 = 0b00000001000000000000000000000000
public let maskF25 = 0b00000010000000000000000000000000
public let maskF26 = 0b00000100000000000000000000000000
public let maskF27 = 0b00001000000000000000000000000000
public let maskF28 = 0b00010000000000000000000000000000

public class Locomotive : EditorObject, LocomotiveFunctionDelegate, CommandStationDelegate {
  
  // MARK: Constructors
  
  init(reader:SqliteDataReader) {
    super.init(primaryKey: -1)
    decode(sqliteDataReader: reader)
    functions = LocomotiveFunction.functions(locomotive: self)
    _cvs = LocomotiveCV.cvs(locomotive: self)
  }
  
  init() {
    super.init(primaryKey: -1)
    for fn in 0...28 {
      let locoFunc = LocomotiveFunction(functionNumber: fn)
      locoFunc.delegate = self
      functions.append(locoFunc)
    }
    for cvNumber in 1...256 {
      let cv = LocomotiveCV(cvNumber: cvNumber)
      _cvs[cv.cvNumber] = cv
    }
  }
  
  // MARK: Destructors
  
  deinit {
    
  }
  
  // MARK: Private Enums
  
  private enum InitState {
    case inactive
    case waitingForSlot
    case waitingToActivate
    case waitingForOwnershipConfirmation
    case active
  }
  
  // MARK: Private Properties
  
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
  
  private var _maxForwardSpeed : Double = 0.0
  
  private var _maxBackwardSpeed : Double = 0.0
  
  private var _lengthUnits : LengthUnit = .centimeters
  
  private var _occupancyFeedbackOffsetUnits : LengthUnit = .centimeters
  
  private var _speedUnits : SpeedUnit = .kilometersPerHour
  
  private var _networkId : Int = -1
  
  private var _decoderModel : String = ""
  
  private var _inventoryCode : String = ""
  
  private var _manufacturer : String = ""
  
  private var _purchaseDate : String = ""
  
  private var _notes : String = ""
  
  private var _isInUse : Bool = false
  
  private var _direction : LocomotiveDirection = .forward
  
  private var _targetSpeed : LocomotiveSpeed = (speed: 0, direction: .forward)
  
  private var _isInertial : Bool = true
  
  private var commandStationDelegateId : Int = -1
  
  private var initState : InitState = .inactive {
    willSet {
      stopTimer()
    }
    didSet {
      if initState == .active {
        startTimer(timeInterval: 200.0 / 1000.0)
      }
    }
  }
  
  private var _speed  : LocomotiveSpeed = (speed: 0, direction: .forward)
  
  private var modified : Bool = false
  
  private var lastLocomotiveState : LocomotiveState = (speed: 0, direction: .forward, functions: 0)
  
  private var timer : Timer? = nil
  
  private var delegates : [Int:LocomotiveDelegate] = [:]
  
  private var nextDelegateId : Int = 0
  
  private var _cvs : [Int:LocomotiveCV] = [:]
  
  private var _throttleID : Int?
  
  // MARK: Public properties
  
  public var functions : [LocomotiveFunction] = []
  
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
  
  public var lengthUnits : LengthUnit {
    get {
      return _lengthUnits
    }
    set(value) {
      if value != _lengthUnits {
        _lengthUnits = value
        modified = true
      }
    }
  }
  
  public var occupancyFeedbackOffsetUnits : LengthUnit {
    get {
      return _occupancyFeedbackOffsetUnits
    }
    set(value) {
      if value != _occupancyFeedbackOffsetUnits {
        _occupancyFeedbackOffsetUnits = value
        modified = true
      }
    }
  }
  
  public var speedUnits : SpeedUnit {
    get {
      return _speedUnits
    }
    set(value) {
      if value != _speedUnits {
        _speedUnits = value
        modified = true
      }
    }
  }
  
  public var networkId : Int {
    get {
      return _networkId
    }
    set(value) {
      if value != _networkId {
        _networkId = value
        modified = true
      }
    }
  }
  
  public var decoderModel : String {
    get {
      return _decoderModel
    }
    set(value) {
      if value != _decoderModel {
        _decoderModel = value
        modified = true
      }
    }
  }
  
  public var inventoryCode : String {
    get {
      return _inventoryCode
    }
    set(value) {
      if value != _inventoryCode {
        _inventoryCode = value
        modified = true
      }
    }
  }
  
  public var manufacturer : String {
    get {
      return _manufacturer
    }
    set(value) {
      if value != _manufacturer {
        _manufacturer = value
        modified = true
      }
    }
  }
  
  public var purchaseDate : String {
    get {
      return _purchaseDate
    }
    set(value) {
      if value != _purchaseDate {
        _purchaseDate = value
        modified = true
      }
    }
  }
  
  public var notes : String {
    get {
      return _notes
    }
    set(value) {
      if value != _notes {
        _notes = value
        modified = true
      }
    }
  }
  
  public var network : Network? {
    get {
      return networkController.networks[networkId]
    }
  }
  
  public var cvs : [Int:LocomotiveCV] {
    get {
      return _cvs
    }
  }
  
  public var cvsSorted : [LocomotiveCV] {
    get {
      
      var result : [LocomotiveCV] = []
      
      for cv in _cvs {
        result.append(cv.value)
      }
      
      return result.sorted {
        $0.cvNumber < $1.cvNumber
      }
      
    }
  }
  
  public var isInUse : Bool {
    get {
      return _isInUse
    }
    set(value) {
      if value != _isInUse {
        _isInUse = value
        if let net = network, let cs = net.commandStation {
          if _isInUse {
            commandStationDelegateId = cs.addDelegate(delegate: self)
            initState = .waitingForSlot
            cs.getLocoSlot(forAddress: address)
          }
          else {
            stopTimer()
            cs.removeDelegate(id: commandStationDelegateId)
            initState = .inactive
          }
        }
      }
    }
  }
  
  // NOTE: targetSpeed is in the range 0 to 126.
  
  public var targetSpeed : LocomotiveSpeed {
    get {
      return _targetSpeed
    }
    set(value) {
      _targetSpeed = value
    }
  }
  
  // NOTE: speed is in the range 0 to 126.
  
  public var speed : LocomotiveSpeed {
    get {
      return _speed
    }
    set(value) {
      _speed = value
    }
  }
  
  public var isInertial : Bool {
    get {
      return _isInertial
    }
    set(value) {
      if value != _isInertial {
        _isInertial = value
      }
    }
  }
  
  public var slotNumber : Int = -1
  
  public var slotPage : Int = -1
  
  public var functionSettings : Int {
    get {
      var result = 0
      var mask = 1
      for locoFunc in functions {
        result |= locoFunc.stateToSend ? mask : 0
        mask <<= 1
      }
      return result
    }
  }
  
  public var locomotiveState : LocomotiveState {
    get {
      var result : LocomotiveState
      
      result.speed = speed.speed == 0 ? 0 : speed.speed + 1
      result.direction = speed.direction
      result.functions = functionSettings
      return result
    }
  }
  
  public var decoderManufacturerName : String {
    get {
      return NMRA.manufacturerName(code: getCV(cvNumber: 8)!.cvValue)
    }
  }
  
  // MARK: Private Methods
  
  @objc func timerAction() {
    
    if let net = network, let cs = net.commandStation, let throttle = _throttleID {
      
      if !isInertial {
        speed = targetSpeed
      }
      
      lastLocomotiveState = cs.updateLocomotiveState(slotNumber: slotNumber, slotPage: slotPage, previousState: lastLocomotiveState, nextState: locomotiveState, throttleID: throttle)
      
      for delegate in delegates {
        delegate.value.stateUpdated(locomotive: self)
      }
      
      if isInertial {
        let tsign = targetSpeed.direction == .forward ? 1 : -1
        let ts = targetSpeed.speed * tsign
        let csign = speed.direction == .forward ? 1 : -1
        var cs = speed.speed * csign
        if ts != cs {
          let increment = ts <= cs ? -1 : 1
          cs += increment
          cs = increment < 0 ? max(ts,cs) : min(ts,cs)
          let newDirection : LocomotiveDirection = cs >= 0 ? .forward : .reverse
          let newSpeed = abs(cs)
          speed = (speed: newSpeed, direction: newDirection)
        }
      }
      
    }
    
  }
  
  func startTimer(timeInterval:TimeInterval) {
    timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
  }
  
  func stopTimer() {
    timer?.invalidate()
    timer = nil
  }
  
  private func writeBack(message:NetworkMessage) -> [UInt8] {

    var slotData = message.slotData

    if _throttleID == nil {
      _throttleID = networkController.softwareThrottleID
    }
    
    if let throttleID = _throttleID {
      var index = slotData.count - 2
      slotData[index+0] = UInt8(throttleID & 0x7f)
      slotData[index+1] = UInt8(throttleID >> 8)
      index = message.messageType == .locoSlotDataP1 ? 1 : 2
      slotData[index] = (slotData[index] & mobileDecoderType.protectMask()) | mobileDecoderType.setMask()
    }
    
    return slotData
    
  }
  
  // MARK: Public Methods
  
  override public func displayString() -> String {
    return locomotiveName
  }
  
  public func getCV(cvNumber: Int) -> LocomotiveCV? {
    if cvNumber < 1 {
      return nil
    }
    return _cvs[cvNumber]
  }
  
  public func getCV(primaryPageIndex: Int, secondaryPageIndex: Int, cvNumber: Int) -> LocomotiveCV? {
    let cv = LocomotiveCV.indexedCvNumber(primaryPageIndex: primaryPageIndex, secondaryPageIndex: secondaryPageIndex, cvNumber: cvNumber)
    return _cvs[cv]
  }
  
  public func updateCVS(cv: LocomotiveCV) {
    cv.locomotiveId = self.primaryKey
    _cvs[cv.cvNumber] = cv
    cv.save()
  }
  
  public func addDelegate(delegate:LocomotiveDelegate) -> Int {
    let id = nextDelegateId
    nextDelegateId += 1
    delegates[id] = delegate
    return id
  }
  
  public func removeDelegate(withKey: Int) {
    delegates.removeValue(forKey: withKey)
  }
  
  // MARK: CommandStationDelegate Methods
  
  @objc public func locomotiveMessageReceived(message: NetworkMessage) {
    
    if let net = network, let cs = net.commandStation {
      
      switch message.messageType {
      case .ack:
        let ack = Ack(interfaceId: message.interfaceId, data: message.message)
        break
      case .locoSlotDataP1:
        let locoSlotDataP1 = LocoSlotDataP1(interfaceId: message.interfaceId, data: message.message)
        if locoSlotDataP1.address == address {
          slotPage = locoSlotDataP1.slotPage
          slotNumber = locoSlotDataP1.slotNumber
          if initState == .waitingForSlot {
            initState = .waitingToActivate
            cs.moveSlots(sourceSlotNumber: slotNumber, sourceSlotPage: slotPage, destinationSlotNumber: slotNumber, destinationSlotPage: slotPage)
          }
          else if initState == .waitingToActivate {
            initState = .waitingForOwnershipConfirmation
            let wb = writeBack(message: message)
            cs.setLocoSlotDataP1(slotData: wb)
          }
        }
        break
      case .locoSlotDataP2:
        let locoSlotDataP2 = LocoSlotDataP2(interfaceId: message.interfaceId, data: message.message)
        if locoSlotDataP2.address == address {
          slotPage = locoSlotDataP2.slotPage
          slotNumber = locoSlotDataP2.slotNumber
          if initState == .waitingForSlot {
            initState = .waitingToActivate
            cs.moveSlots(sourceSlotNumber: slotNumber, sourceSlotPage: slotPage, destinationSlotNumber: slotNumber, destinationSlotPage: slotPage)
          }
          else if initState == .waitingToActivate {
            initState = .waitingForOwnershipConfirmation
            let wb = writeBack(message: message)
            cs.setLocoSlotDataP2(slotData: wb)
          }
        }
        break
      case .setSlotDataOKP1, .setSlotDataOKP2:
        initState = .active
      case .noFreeSlotsP1, .noFreeSlotsP2:
        initState = .inactive
      default:
        break
      }
        
    }
    
  }
    
  // MARK: LocomotiveFunctionDelegate Methods
  
  public func changeState(locomotiveFunction: LocomotiveFunction) {
  }
  
  // MARK: Database Methods
  
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
      
      if !reader.isDBNull(index: 13) {
        lengthUnits = LengthUnit(rawValue: reader.getInt(index: 13)!) ?? .centimeters
      }

      if !reader.isDBNull(index: 14) {
        occupancyFeedbackOffsetUnits = LengthUnit(rawValue: reader.getInt(index: 14)!) ?? .centimeters
      }

      if !reader.isDBNull(index: 15) {
        speedUnits = SpeedUnit(rawValue: reader.getInt(index: 15)!) ?? .kilometersPerHour
      }

      if !reader.isDBNull(index: 16) {
        networkId = reader.getInt(index: 16)!
      }

      if !reader.isDBNull(index: 17) {
        decoderModel = reader.getString(index: 17)!
      }

      if !reader.isDBNull(index: 18) {
        inventoryCode = reader.getString(index: 18)!
      }

      if !reader.isDBNull(index: 19) {
        manufacturer = reader.getString(index: 19)!
      }

      if !reader.isDBNull(index: 20) {
        purchaseDate = reader.getString(index: 20)!
      }

      if !reader.isDBNull(index: 21) {
        notes = reader.getString(index: 21)!
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
        "[\(LOCOMOTIVE.MAX_BACKWARD_SPEED)]," +
        "[\(LOCOMOTIVE.UNITS_LENGTH)]," +
        "[\(LOCOMOTIVE.UNITS_FBOFF_OCC)]," +
        "[\(LOCOMOTIVE.UNITS_SPEED)]," +
        "[\(LOCOMOTIVE.NETWORK_ID)]," +
        "[\(LOCOMOTIVE.DECODER_MODEL)]," +
        "[\(LOCOMOTIVE.INVENTORY_CODE)]," +
        "[\(LOCOMOTIVE.MANUFACTURER)]," +
        "[\(LOCOMOTIVE.PURCHASE_DATE)]," +
        "[\(LOCOMOTIVE.NOTES)]" +
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
        "@\(LOCOMOTIVE.MAX_BACKWARD_SPEED), " +
        "@\(LOCOMOTIVE.UNITS_LENGTH), " +
        "@\(LOCOMOTIVE.UNITS_FBOFF_OCC), " +
        "@\(LOCOMOTIVE.UNITS_SPEED), " +
        "@\(LOCOMOTIVE.NETWORK_ID), " +
        "@\(LOCOMOTIVE.DECODER_MODEL), " +
        "@\(LOCOMOTIVE.INVENTORY_CODE), " +
        "@\(LOCOMOTIVE.MANUFACTURER), " +
        "@\(LOCOMOTIVE.PURCHASE_DATE), " +
        "@\(LOCOMOTIVE.NOTES)" +
        ")"
        primaryKey = Database.nextCode(tableName: TABLE.LOCOMOTIVE, primaryKey: LOCOMOTIVE.LOCOMOTIVE_ID)!
        
        for locoFunc in functions {
          locoFunc.locomotiveId = primaryKey
        }
        
        for cv in _cvs {
          cv.value.locomotiveId = primaryKey
        }
        
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
        "[\(LOCOMOTIVE.MAX_BACKWARD_SPEED)] = @\(LOCOMOTIVE.MAX_BACKWARD_SPEED), " +
        "[\(LOCOMOTIVE.UNITS_LENGTH)] = @\(LOCOMOTIVE.UNITS_LENGTH), " +
        "[\(LOCOMOTIVE.UNITS_FBOFF_OCC)] = @\(LOCOMOTIVE.UNITS_FBOFF_OCC), " +
        "[\(LOCOMOTIVE.UNITS_SPEED)] = @\(LOCOMOTIVE.UNITS_SPEED), " +
        "[\(LOCOMOTIVE.NETWORK_ID)] = @\(LOCOMOTIVE.NETWORK_ID), " +
        "[\(LOCOMOTIVE.DECODER_MODEL)] = @\(LOCOMOTIVE.DECODER_MODEL), " +
        "[\(LOCOMOTIVE.INVENTORY_CODE)] = @\(LOCOMOTIVE.INVENTORY_CODE), " +
        "[\(LOCOMOTIVE.MANUFACTURER)] = @\(LOCOMOTIVE.MANUFACTURER), " +
        "[\(LOCOMOTIVE.PURCHASE_DATE)] = @\(LOCOMOTIVE.PURCHASE_DATE), " +
        "[\(LOCOMOTIVE.NOTES)] = @\(LOCOMOTIVE.NOTES) " +
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
      cmd.parameters.addWithValue(key: "@\(LOCOMOTIVE.UNITS_LENGTH)", value: lengthUnits.rawValue)
      cmd.parameters.addWithValue(key: "@\(LOCOMOTIVE.UNITS_FBOFF_OCC)", value: occupancyFeedbackOffsetUnits.rawValue)
      cmd.parameters.addWithValue(key: "@\(LOCOMOTIVE.UNITS_SPEED)", value: speedUnits.rawValue)
      cmd.parameters.addWithValue(key: "@\(LOCOMOTIVE.NETWORK_ID)", value: networkId)
      cmd.parameters.addWithValue(key: "@\(LOCOMOTIVE.DECODER_MODEL)", value: decoderModel)
      cmd.parameters.addWithValue(key: "@\(LOCOMOTIVE.INVENTORY_CODE)", value: inventoryCode)
      cmd.parameters.addWithValue(key: "@\(LOCOMOTIVE.MANUFACTURER)", value: manufacturer)
      cmd.parameters.addWithValue(key: "@\(LOCOMOTIVE.PURCHASE_DATE)", value: purchaseDate)
      cmd.parameters.addWithValue(key: "@\(LOCOMOTIVE.NOTES)", value: notes)

      _ = cmd.executeNonQuery()

      if shouldClose {
        conn.close()
      }
      
      modified = false
      
    }
    
    for locoFunc in functions {
      locoFunc.save()
    }
    
    for cv in _cvs {
      cv.value.save()
    }

  }

  // MARK: Class Properties
  
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
        "[\(LOCOMOTIVE.MAX_BACKWARD_SPEED)], " +
        "[\(LOCOMOTIVE.UNITS_LENGTH)], " +
        "[\(LOCOMOTIVE.UNITS_FBOFF_OCC)], " +
        "[\(LOCOMOTIVE.UNITS_SPEED)], " +
        "[\(LOCOMOTIVE.NETWORK_ID)], " +
        "[\(LOCOMOTIVE.DECODER_MODEL)], " +
        "[\(LOCOMOTIVE.INVENTORY_CODE)], " +
        "[\(LOCOMOTIVE.MANUFACTURER)], " +
        "[\(LOCOMOTIVE.PURCHASE_DATE)], " +
        "[\(LOCOMOTIVE.NOTES)]"
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
    let sql = [
      "DELETE FROM [\(TABLE.LOCOMOTIVE_FUNCTION)] WHERE [\(LOCOMOTIVE_FUNCTION.LOCOMOTIVE_ID)] = \(primaryKey)",
      "DELETE FROM [\(TABLE.LOCOMOTIVE_CV)] WHERE [\(LOCOMOTIVE_CV.LOCOMOTIVE_ID)] = \(primaryKey)",
      "DELETE FROM [\(TABLE.LOCOMOTIVE)] WHERE [\(LOCOMOTIVE.LOCOMOTIVE_ID)] = \(primaryKey)"
    ]
    Database.execute(commands: sql)
  }
  
  public static func decoderAddress(cv17: Int, cv18: Int) -> Int {
    return (cv17 << 8 | cv18) - 49152
  }
  
  public static func cv17(address: Int) -> Int {
    let temp = address + 49152
    return temp >> 8
  }
  
  public static func cv18(address: Int) -> Int {
    let temp = address + 49152
    return temp & 0xff
  }
  
}
