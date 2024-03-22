//
//  OpenLCBNodeRollingStock.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/05/2023.
//

import Foundation

public class OpenLCBNodeRollingStock : OpenLCBNodeVirtual {
  
  // MARK: Constructors
  
  public override init(nodeId:UInt64) {
    
    functionSpaceSize = 0x45
    
    functions = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.functions.rawValue, defaultMemorySize: functionSpaceSize, isReadOnly: false, description: "")
    
    let cvSize = numberOfCVs * 3
    
    cvs = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.cv.rawValue, defaultMemorySize: cvSize, isReadOnly: false, description: "")
        
    super.init(nodeId: nodeId)
    
    var configurationSize = 0

    initSpaceAddress(&addressLocoNetGateway, 8, &configurationSize)

    initSpaceAddress(&addressDCCAddress, 2, &configurationSize)
    initSpaceAddress(&addressSpeedSteps, 1, &configurationSize)
    initSpaceAddress(&addressF0ConsistBehaviour, 1, &configurationSize)
    initSpaceAddress(&addressF0Directional, 1, &configurationSize)
    initSpaceAddress(&addressF0MUSwitch, 2, &configurationSize)
    
    initSpaceAddress(&addressFNDisplayName, 1, &configurationSize) // F1
    initSpaceAddress(&addressFNMomentary, 1, &configurationSize)
    initSpaceAddress(&addressFNConsistBehaviour, 1, &configurationSize)
    initSpaceAddress(&addressFNDescription, 32, &configurationSize)

    var temp = 0
    for _ in 2 ... numberOfFunctions - 1 { // F2 to F68
      initSpaceAddress(&temp, functionGroupSize, &configurationSize)
    }
    
    initSpaceAddress(&addressDeleteFromRoster, 1, &configurationSize)
    initSpaceAddress(&addressLocoNetGateway, 8, &configurationSize)

    configuration = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, defaultMemorySize: configurationSize, isReadOnly: false, description: "")
    
    if let configuration {
      
      virtualNodeType = MyTrainsVirtualNodeType.trainNode
      
      configuration.delegate = self
      
      memorySpaces[configuration.space] = configuration
      
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressDCCAddress)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedSteps)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressF0ConsistBehaviour)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressF0Directional)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressF0MUSwitch)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressLocoNetGateway)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressDeleteFromRoster)
      
      for fn in 1 ... numberOfFunctions - 1 {
        let groupOffset = (fn - 1) * functionGroupSize
        registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressFNDisplayName      + groupOffset)
        registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressFNMomentary        + groupOffset)
        registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressFNConsistBehaviour + groupOffset)
        registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressFNDescription      + groupOffset)
      }
      
      functions?.delegate = self
      
      memorySpaces[functions!.space] = functions
      
      for fn in 0 ... numberOfFunctions - 1 {
        registerVariable(space: OpenLCBNodeMemoryAddressSpace.functions.rawValue, address: fn)
      }
      
      cvs?.delegate = self
      
      memorySpaces[cvs!.space] = cvs
      
      for cv in 0 ... numberOfCVs - 1 {
        registerVariable(space: OpenLCBNodeMemoryAddressSpace.cv.rawValue, address: cv)
      }
      
      isDatagramProtocolSupported = true
      
      isIdentificationSupported = true
      
      isSimpleNodeInformationProtocolSupported = true
      
      isTractionControlProtocolSupported = true
      
      isSimpleTrainNodeInformationProtocolSupported = true
      
      if !memorySpacesInitialized {
        resetToFactoryDefaults()
      }
      
      eventsConsumed = [
      ]
      
      eventsProduced = [
        OpenLCBWellKnownEvent.nodeIsATrain.rawValue,
      ]
      
      eventRangesConsumed = [
        EventRange(startId: OpenLCBWellKnownEvent.locationServicesReport.rawValue, mask: 0x0000ffffffffffff)!,
      ]

      eventRangesProduced = [
        EventRange(startId: OpenLCBWellKnownEvent.locationServicesReport.rawValue, mask: 0x0000ffffffffffff)!,
      ]
      
      eventsToSendAtStartup = [
        OpenLCBWellKnownEvent.nodeIsATrain.rawValue,
      ]

      cdiFilename = "MyTrains Train"
      
      initFDI(filename: "FDI Generic")
      
    }
    
    addInit()
    
  }
  
  deinit {
    
    functions = nil
    
    cvs = nil
    
    listeners.removeAll()
    
    moveTimer?.invalidate()
    moveTimer = nil
    
    timer?.invalidate()
    timer = nil
    
    addDeinit()
  }
  
  // MARK: Private Properties
  
  internal let functionSpaceSize : Int
  
  internal var functions : OpenLCBMemorySpace?
  
  internal var cvs : OpenLCBMemorySpace?
  
  internal var addressDCCAddress         = 0
  internal var addressSpeedSteps         = 0
  internal var addressF0ConsistBehaviour = 0
  internal var addressF0Directional      = 0
  internal var addressF0MUSwitch         = 0
  internal var addressFNDisplayName      = 0
  internal var addressFNMomentary        = 0
  internal var addressFNConsistBehaviour = 0
  internal var addressFNDescription      = 0
  internal var addressDeleteFromRoster   = 0
  internal var addressLocoNetGateway     = 0
  
  internal let numberOfFunctions : Int = 69
  internal let functionGroupSize : Int = 35
  internal let numberOfCVs : Int = 1024

  private let defaultCleanMask : UInt8 = 0b00010000
  private let valueCleanMask   : UInt8 = 0b00000001
  
  internal let defaultOffset = 1024
  internal let statusOffset  = 2048

  internal var activeControllerNodeId : UInt64 = 0 {
    didSet {
      if activeControllerNodeId == 0 {
        releaseNode()
      }
      else {
        attachNode()
      }
    }
  }
  
  internal var nextActiveControllerNodeId : UInt64 = 0
  
  internal var listeners : [OpenLCBTractionListenerNode] = []
  
  internal var setSpeed : Float = 0.0
  
  internal var commandedSpeed : Float = 0.0
  
  internal var emergencyStop : Bool = false {
    didSet {
      speedChanged()
    }
  }
  
  internal var globalEmergencyStop : Bool = false {
    didSet {
      speedChanged()
    }
  }
  
  internal var globalEmergencyOff : Bool = false {
    didSet {
      speedChanged()
    }
  }
  
  internal var isStopped : Bool {
    return abs(setSpeed) == 0.0 || emergencyStop
  }
  
  // Train Movement Variables
  
  internal enum TrainMoveMode {
    case manualControl
    case stopped
    case settingInitialSpeed
    case atCruiseSpeed
    case settingFinalSpeed
    case moveComplete
    
    var isMoving : Bool {
      let movingModes : Set<TrainMoveMode> = [.settingInitialSpeed, .atCruiseSpeed, .settingFinalSpeed]
      return movingModes.contains(self)
    }
    
  }
  
  internal var trainMoveMode : TrainMoveMode = .manualControl {
    didSet {
      switch trainMoveMode {
      case .manualControl, .moveComplete:
        moveTimer?.invalidate()
        moveTimer = nil
      default:
        break
      }
    }
  }
  
  // The acceleration rate is defined as the time from 0 to maximumSpeed in seconds.
  internal var accelerationRate : Float = 10.0
  
  // The decleration rate is defined as the time from maximumSpeed to 0 in seconds.
  internal var decelerationRate : Float = 10.0

  // The maximum speed is the maximum speed of the locomotive in scale metres
  // per second.
  internal var maximumSpeed : Float = 126.0
  
  // The current speed is the current speed of the train in scale metres per second.
  internal var currentSpeed : Float = 0.0
  
  // The cruise speed is the cruising speed of the train in the middle portion
  // of a move in scale metres per second.
  internal var cruiseSpeed : Float = 126.0
  
  // The final speed is the final speed of the train at the end of the move in
  // scale metres per second.
  internal var finalSpeed : Float = 0.0

  // The move direction is the direction of movement of the train in the move.
  internal var moveDirection : LocomotiveDirection = .forward
  
  // This is the number of speed changes allowed per second.
  internal var stepsPerSecond : Float = 4.0
  
  internal var isStealAllowedInMove : Bool = false
  
  internal var isPositionUpdateRequiredInMove : Bool = false
  
  internal var moveTimer : Timer?
  
  private enum HeartbeatMode {
    case stopped
    case waitingForCommand
    case waitingForResponse
  }
  
  private var heartbeatMode : HeartbeatMode = .stopped
  
  private var timer : Timer?
  
  // MARK: Public Properties
  
  public var dccAddress : UInt16 {
    get {
      return configuration!.getUInt16(address: addressDCCAddress)!
    }
    set(value) {
      configuration!.setUInt(address: addressDCCAddress, value: value)
    }
  }
  
  public var dccAddressUniqueId : UInt64? {
    return OpenLCBNodeRollingStock.mapDCCAddressToID(address: dccAddress)
  }
  
  public var speedSteps : SpeedSteps {
    get {
      return SpeedSteps(rawValue: configuration!.getUInt8(address: addressSpeedSteps)!)!
    }
    set(value) {
      configuration!.setUInt(address: addressDCCAddress, value: value.rawValue)
    }
  }
  
  public var locoNetGatewayNodeId : UInt64 {
    get {
      return configuration!.getUInt64(address: addressLocoNetGateway)!
    }
    set(value) {
      configuration!.setUInt(address: addressLocoNetGateway, value: value)
    }
  }
  
  public let heartbeatPeriod : UInt8 = 10
  
  public let heartbeatDeadline : UInt8 = 3
  
  // MARK: Private Methods
  
  internal func isDefaultClean(cvNumber:Int) -> Bool {
    guard let stat = cvs?.getUInt8(address: statusOffset + cvNumber) else {
      return false
    }
    return (stat & defaultCleanMask) == defaultCleanMask
  }
  
  internal func isValueClean(cvNumber:Int) -> Bool {
    guard let stat = cvs?.getUInt8(address: statusOffset + cvNumber) else {
      return false
    }
    return (stat & valueCleanMask) == valueCleanMask
  }
  
  internal func setDefaultStatus(cvNumber:Int, isClean:Bool) {
    guard let stat = cvs?.getUInt8(address: statusOffset + cvNumber) else {
      return
    }
    var status = stat
    status &= ~defaultCleanMask
    status |= isClean ? defaultCleanMask : 0
    cvs?.setUInt(address: statusOffset + cvNumber, value: status)
  }
  
  internal func setValueStatus(cvNumber:Int, isClean:Bool) {
    guard let stat = cvs?.getUInt8(address: statusOffset + cvNumber) else {
      return
    }
    var status = stat
    status &= ~valueCleanMask
    status |= isClean ? valueCleanMask : 0
    cvs?.setUInt(address: statusOffset + cvNumber, value: status)
  }
  
  internal func isMomentary(number:Int) -> Bool {
    
    if number == 0 {
      return false
    }
    
    let baseAddress = (number - 1) * functionGroupSize
    
    if let value = configuration!.getUInt8(address: baseAddress + addressFNMomentary) {
      return value != 0
    }
    
    return false
    
  }
  
  internal func initFDI(filename:String) {
    
    if let filepath = Bundle.main.path(forResource: filename, ofType: "xml") {
      do {
        
        var contents = try String(contentsOfFile: filepath)
        
        var fnx = ""
        
        fnx += "<function size='1' kind='binary'>\n"
        fnx += "<name>\(OpenLCBFunction.light.title)</name>\n"
        fnx += "<number>0</number>\n"
        fnx += "</function>"

        for number in 1 ... numberOfFunctions - 1 {
          let baseAddress = (number - 1) * functionGroupSize
          if let displayNameId = configuration!.getUInt8(address: baseAddress + addressFNDisplayName), let function = OpenLCBFunction(rawValue: displayNameId), let momentary = configuration!.getUInt8(address: baseAddress + addressFNMomentary) {
            if function != .unassigned {
              let kind = momentary == 0 ? "binary" : "momentary"
              fnx += "<function size='1' kind='\(kind)'>\n"
              fnx += "<name>\(function.title)</name>\n"
              fnx += "<number>\(number)</number>\n"
              fnx += "</function>"
            }
          }
        }
        
        contents = contents.replacingOccurrences(of: "%%FUNCTIONS%%", with: fnx)
        
        let memorySpace = OpenLCBMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.fdi.rawValue, isReadOnly: true, description: "")
        memorySpace.memory = [UInt8]()
        memorySpace.memory.append(contentsOf: contents.utf8)
        memorySpace.memory.append(contentsOf: [UInt8](repeating: 0, count: 64))
        memorySpaces[memorySpace.space] = memorySpace
        isFunctionDescriptionInformationProtocolSupported = true
        
      }
      catch {
      }
    }
    
  }
  
  
  private func isListener(nodeId:UInt64) -> Bool {
    for listener in listeners {
      if listener.nodeId == nodeId {
        return true
      }
    }
    return false
  }
  
  internal override func resetToFactoryDefaults() {
    
    super.resetToFactoryDefaults()
    
    functions?.zeroMemory()
    
    saveMemorySpaces()
    
  }
  
  internal func attachNode() {
  }
  
  internal func attachCompleted() {
    sendAssignControllerReply(destinationNodeId: activeControllerNodeId, result: 0)
  }
  
  internal func attachFailed() {
    
    sendAssignControllerReply(destinationNodeId: activeControllerNodeId, result: 0x02)
    
    activeControllerNodeId = 0
    
    nextActiveControllerNodeId = 0
    
  }
  
  internal func releaseNode() {
    
  }
  
  internal func speedChanged() {
    
  }
  
  internal func functionChanged() {
    
  }
  
  // Self-Driving Routines
  
  internal typealias MoveStep = (velocity:Float, duration:Float)
  
  internal typealias MovePart = (distance:Float, steps:[MoveStep])
  
  internal func getCruiseMovePart(distance:Float, initial:MovePart, final:MovePart) -> MovePart {
    
    let D = distance - initial.distance - final.distance
    
    let δT = D / abs(cruiseSpeed)

    let N = Int(ceil(δT * stepsPerSecond))
    
    let stepDuration = 1.0 / stepsPerSecond

    let d = Float(N - 1) * stepDuration * cruiseSpeed
    
    let δdT = (D - d) / abs(cruiseSpeed)
    
    var steps : [MoveStep] = []
 
    var index = 0
    while index < N {
      index += 1
      let duration = (index == N) ? δdT : stepDuration
      steps.append((velocity: cruiseSpeed, duration: duration))
    }

    return (distance: distance, steps: steps)

  }
  
  internal func getSpeedChangeMovePart(v1:Float, v2:Float) -> MovePart {
    
    let δV = v1 - v2
    
    let velocityChangeRate = (v1 == v2) ? 0.0 : (v1 < v2) ? accelerationRate : decelerationRate
    
    let δT = abs(δV) / maximumSpeed * velocityChangeRate
    
    let N = Int(ceil(δT * stepsPerSecond))
    
    var distance : Float = 0
    
    var steps : [MoveStep] = []
    
    if N > 0 {
      
      let δVPerStep = δV / Float(N)
      
      let stepDuration = 1.0 / stepsPerSecond
      
      var velocity = v1
      
      var index = 0
      while index < N {
        index += 1
        velocity = (index == N) ? v2 : velocity + δVPerStep
        steps.append((velocity: velocity, duration: stepDuration))
      }
      
      steps = adjustMovePartSpeedSteps(steps: steps)
      
      for step in steps {
        distance += step.duration * step.velocity
      }
      
    }
    
    return (distance: distance, steps: steps)
    
  }

  internal func getSpeedChangeMovePartForDistance(targetDistance:Float, v1:Float, v2:Float) -> MovePart {
    
    let δV = v1 - v2
    
    var velocityChangeRate = (v1 == v2) ? 0.0 : (v1 < v2) ? accelerationRate : decelerationRate
    
    var distance : Float = 0
    
    var steps : [MoveStep] = []

    repeat {
      
      velocityChangeRate *= 0.99
      
      let δT = abs(δV) / maximumSpeed * velocityChangeRate
      
      let N = Int(ceil(δT * stepsPerSecond))
      
      steps = []
      
      if N > 0 {
        
        let δVPerStep = δV / Float(N)
        
        let stepDuration = 1.0 / stepsPerSecond
        
        var velocity = v1
        
        var index = 0
        while index < N {
          index += 1
          velocity = (index == N) ? v2 : velocity + δVPerStep
          steps.append((velocity: velocity, duration: stepDuration))
        }
        
        steps = adjustMovePartSpeedSteps(steps: steps)
        
        distance = 0.0
        for step in steps {
          distance += step.duration * step.velocity
        }
        
      }
      
    } while distance > targetDistance
    
    return (distance: distance, steps: steps)
    
  }

  internal func normalizeVelocity(velocity:Float) -> Float {
    return velocity
  }
  
  internal func adjustMovePartSpeedSteps(steps:[MoveStep]) -> [MoveStep] {
    
    var normalized : [MoveStep] = []
    
    for step in steps {
      normalized.append((velocity:normalizeVelocity(velocity: step.velocity), duration:step.duration))
    }
    
    return normalized
    
  }
  
  @objc func timerAction() {
    
    timer?.invalidate()
    
    switch heartbeatMode {
      
    case .waitingForCommand:
      
      heartbeatMode = .waitingForResponse
      
      startTimer(interval: heartbeatDeadline)
      
      sendHeartbeatRequest(destinationNodeId: activeControllerNodeId, timeout: heartbeatDeadline)
      
    case .waitingForResponse:
      
      heartbeatMode = .stopped
      
      setSpeedToZero()
      
      speedChanged()
      
      for listener in listeners {
        sendSetSpeedDirection(destinationNodeId: listener.nodeId, setSpeed: setSpeed, isForwarded: true)
      }
      
    default:
      break
    }
    
  }
  
  private func startTimer(interval:UInt8) {
    
    timer?.invalidate()
    
    let deadline : TimeInterval = Double(interval)
    
    timer = Timer.scheduledTimer(timeInterval: deadline, target: self, selector: #selector(timerAction), userInfo: nil, repeats: false)
    
    RunLoop.current.add(timer!, forMode: .common)
    
  }
  
  // MARK: Public Methods
  
  public func reloadFDI() {
    memorySpaces.removeValue(forKey: OpenLCBNodeMemoryAddressSpace.fdi.rawValue)
    initFDI(filename: "FDI Generic")
  }
  
  public override func start() {
    
    super.start()
    
  }
  
  public override func variableChanged(space:OpenLCBMemorySpace, address:Int) {
    
  }
  
  public func setSpeedToZero() {
    
    let minusZero : Float = -0.0
    
    setSpeed = (setSpeed.bitPattern == minusZero.bitPattern || setSpeed < 0.0) ? -0.0 : +0.0
    
  }
  
  // MARK: OpenLCBMemorySpaceDelegate Methods
  
  public override func memorySpaceChanged(memorySpace:OpenLCBMemorySpace, startAddress:Int, endAddress:Int) {
    
    super.memorySpaceChanged(memorySpace: memorySpace, startAddress: startAddress, endAddress: endAddress)
    
    if memorySpace.space == OpenLCBNodeMemoryAddressSpace.configuration.rawValue {
      reloadFDI()
    }
    
  }

  // MARK: OpenLCBNetworkLayerDelegate Methods
   
  public override func openLCBMessageReceived(message: OpenLCBMessage) {
    
    super.openLCBMessageReceived(message: message)
        
    switch message.messageTypeIndicator {
      
    case .tractionControlCommand:
      
      if let instruction = OpenLCBTractionControlInstructionType(rawValue: message.payload[0] & 0b01111111) {
        
        timer?.invalidate()
        
        let isForwarded = ((message.payload[0]) & 0x80 == 0x80) && isListener(nodeId: message.sourceNodeId!)
        
        switch instruction {
         
        case .setMove:
          
          // Add zeros to the payload to allow for optional arguments.
          
          message.payload.append(contentsOf: [UInt8](repeating: 0, count: 8))

          if let tempDistanceToGo = Float(bigEndianData: [message.payload[1], message.payload[2], message.payload[3], message.payload[4]]), let uint16CruiseSpeed = UInt16(bigEndianData: [message.payload[5], message.payload[6]]), let uint16FinalSpeed = UInt16(bigEndianData: [message.payload[7], message.payload[8]]) {
            
            // The distance sign bit controls the direction of travel and will
            // override the direction bits of the two speeds.
            
            let trainDirection = tempDistanceToGo.direction
            
            var f16 = float16_t()
            
            f16.v = uint16CruiseSpeed
            var tempCruiseSpeed = abs(Float(float16: f16))
            
            // If the cruise speed is zero then set it to the train's maximum speed.
            
            if tempCruiseSpeed == 0.0 {
              tempCruiseSpeed = abs(maximumSpeed)
            }
            
            f16.v = uint16FinalSpeed
            var tempFinalSpeed = abs(Float(float16: f16))
            
            // If the train is currently moving in the opposite direction to the
            // requested distance, then stop it immediately before starting the move.
            
            var tempCurrentSpeed = currentSpeed.direction == trainDirection ? abs(currentSpeed) : 0.0

            if trainDirection == .reverse {
              if tempCruiseSpeed == 0.0 {
                tempCruiseSpeed = -0.0
              }
              else {
                tempCruiseSpeed *= -1.0
              }
              if tempFinalSpeed == 0.0 {
                tempFinalSpeed = -0.0
              }
              else {
                tempFinalSpeed *= -1.0
              }
              if tempCurrentSpeed == 0.0 {
                tempCurrentSpeed = -0.0
              }
              else {
                tempCurrentSpeed *= -1.0
              }
            }
            
            tempCurrentSpeed = normalizeVelocity(velocity: tempCurrentSpeed)
            tempCruiseSpeed = normalizeVelocity(velocity: tempCruiseSpeed)
            tempFinalSpeed = normalizeVelocity(velocity: tempFinalSpeed)
            
            var initial = getSpeedChangeMovePart(v1: tempCurrentSpeed, v2: tempCruiseSpeed)
            
            var final = getSpeedChangeMovePart(v1: tempCruiseSpeed, v2: tempFinalSpeed)
            
            var move : [MovePart] = []
            
            if (initial.distance + final.distance) < abs(tempDistanceToGo) {
              let cruise = getCruiseMovePart(distance: abs(tempDistanceToGo), initial: initial, final: final)
              move.append(initial)
              move.append(cruise)
              move.append(final)
            }
            else if abs(tempCurrentSpeed ) == 0.0 && abs(tempFinalSpeed) == 0.0 {
              var distance : Float
              repeat {
                tempCruiseSpeed *= 0.99
                initial = getSpeedChangeMovePart(v1: tempCurrentSpeed, v2: tempCruiseSpeed)
                final = getSpeedChangeMovePart(v1: tempCruiseSpeed, v2: tempFinalSpeed)
                distance = initial.distance + final.distance
              } while distance > abs(tempDistanceToGo)
              move.append(initial)
              move.append(final)
            }
            else {
              final = getSpeedChangeMovePartForDistance(targetDistance: abs(tempDistanceToGo), v1: tempCurrentSpeed, v2: tempFinalSpeed)
              move.append(final)
            }

          }
 
        case .startMove:
          break
          
        case .stopMove:
          break
          
        case .setSpeedDirection:
          
          if !isForwarded && false && message.sourceNodeId! != activeControllerNodeId {
            sendTerminateDueToError(destinationNodeId: message.sourceNodeId!, errorCode: .permanentErrorSourceNotPermitted)
          }
          
          else if let uint16 = UInt16(bigEndianData: [message.payload[1], message.payload[2]]) {
            
            var f16 = float16_t()
            f16.v = uint16
            setSpeed = Float(float16: f16)
 
            emergencyStop = false
            
            for listener in listeners {
              if listener.nodeId != message.sourceNodeId! {
                var forwardedSpeed = setSpeed
                if listener.reverseDirection {
                  let minusZero : Float = -0.0
                  let plusZero : Float = +0.0

                  if forwardedSpeed.bitPattern == plusZero.bitPattern {
                    forwardedSpeed = -0.0
                  }
                  else if forwardedSpeed.bitPattern == minusZero.bitPattern {
                    forwardedSpeed = +0.0
                  }
                  else {
                    forwardedSpeed *= -1.0
                  }
                }
                sendSetSpeedDirection(destinationNodeId: listener.nodeId, setSpeed: forwardedSpeed, isForwarded: true)
              }
            }
            
          }
          
        case .setFunction:
          
          if !isForwarded && false && message.sourceNodeId! != activeControllerNodeId {
            sendTerminateDueToError(destinationNodeId: message.sourceNodeId!, errorCode: .permanentErrorSourceNotPermitted)
          }
          else {
            
            let bed = [
              message.payload[1],
              message.payload[2],
              message.payload[3]
            ]
            
            if let space = memorySpaces[OpenLCBNodeMemoryAddressSpace.functions.rawValue], let address = UInt32(bigEndianData: bed) {
              
              let value = UInt16(bigEndianData: [message.payload[4], message.payload[5]])!
              
              if space.isWithinSpace(address: Int(address), count: 1) {
                if address >= 0 && address <= 0x41 {
                  space.setUInt(address: Int(address), value: UInt8(value & 0xff))
                  functionChanged()
                  space.save()
                }
              }
              
              for listener in listeners {
                if listener.nodeId != message.sourceNodeId!, (address == 0 && listener.linkF0) || (address != 0 && listener.linkFN) {
                  sendSetFunction(destinationNodeId: listener.nodeId, address: address, value: value, isForwarded: true)
                }
              }
              
            }
            
          }
          
        case .emergencyStop:
          
          if !isForwarded && false && message.sourceNodeId! != activeControllerNodeId {
            sendTerminateDueToError(destinationNodeId: message.sourceNodeId!, errorCode: .permanentErrorSourceNotPermitted)
          }
          else {
            
            emergencyStop = true
            
            for listener in listeners {
              if listener.nodeId != message.sourceNodeId! {
                sendEmergencyStop(destinationNodeId: listener.nodeId, isForwarded: true)
              }
            }
            
          }
          
        case .querySpeeds:
          
          sendQuerySpeedsReply(destinationNodeId: message.sourceNodeId!, setSpeed: setSpeed, commandedSpeed: commandedSpeed, emergencyStop: emergencyStop)
          
        case .queryFunction:
          
          let bed = [
            message.payload[1],
            message.payload[2],
            message.payload[3]
          ]
          
          if let space = memorySpaces[OpenLCBNodeMemoryAddressSpace.functions.rawValue], let address = UInt32(bigEndianData: bed) {
              
            if space.isWithinSpace(address: Int(address), count: 1), let value = space.getUInt8(address: Int(address)) {
              
              sendQueryFunctionReply(destinationNodeId: message.sourceNodeId!, address: address, value: UInt16(value))
              
            }

          }
          
        case .controllerConfiguration:
          
          if let configurationType = OpenLCBTractionControllerConfigurationType(rawValue: message.payload[1]) {
            
            let bed = [
              message.payload[3],
              message.payload[4],
              message.payload[5],
              message.payload[6],
              message.payload[7],
              message.payload[8],
            ]
            
            switch configurationType {
              
            case .assignController:
              
              if let controllerNodeId = UInt64(bigEndianData: bed) {
                
                nextActiveControllerNodeId = 0
                
                if activeControllerNodeId == 0 || activeControllerNodeId == controllerNodeId {
                  
                  if activeControllerNodeId != 0 {
                    sendAssignControllerReply(destinationNodeId: controllerNodeId, result: 0)
                  }
                  else {
                    activeControllerNodeId = controllerNodeId
                  }
                  
                }
                else {

                  nextActiveControllerNodeId = controllerNodeId
                  
                  sendControllerChangedNotify(destinationNodeId: activeControllerNodeId, newController: nextActiveControllerNodeId)
                  
                }
                
              }
              
            case .releaseController:
              
              if let controllerNodeId = UInt64(bigEndianData: bed) {
                
                if controllerNodeId == activeControllerNodeId {
                  activeControllerNodeId = 0
                }
                
              }
              
            case .queryController:
              
              sendQueryControllerReply(destinationNodeId: message.sourceNodeId!, activeController: activeControllerNodeId)
              
            case .controllerChangingNotify:
              break
            }
            
          }
        case .listenerConfiguration:
          
          if let configurationType = OpenLCBTractionListenerConfigurationType(rawValue: message.payload[1]) {
          
            switch configurationType {
              
            case .attachNode:
              
              let bed = [
                message.payload[3],
                message.payload[4],
                message.payload[5],
                message.payload[6],
                message.payload[7],
                message.payload[8],
              ]

              if let listenerNodeId = UInt64(bigEndianData: bed) {
                
                if listenerNodeId == nodeId {
                  
                  sendAttachListenerReply(destinationNodeId: message.sourceNodeId!, listenerNodeId: listenerNodeId, replyCode: .permanentErrorAlreadyExists)
                  
                }
                else {
                  
                  var found = false
                  
                  for listener in listeners {
                    
                    if listener.nodeId == listenerNodeId {
                      
                      listener.flags = message.payload[2]
                      
                      sendAttachListenerReply(destinationNodeId: message.sourceNodeId!, listenerNodeId: listenerNodeId, replyCode: .success)
                      
                      found = true
                      
                    }
                    
                  }
                  
                  if !found {
                    
                    let listenerNode = OpenLCBTractionListenerNode(nodeId: listenerNodeId, flags: message.payload[2])
                    
                    listeners.append(listenerNode)
                    
                    sendAttachListenerReply(destinationNodeId: message.sourceNodeId!, listenerNodeId: listenerNodeId, replyCode: .success)
                  }
                  
                }
                
              }
              
            case .detachNode:
              
              let bed = [
                message.payload[3],
                message.payload[4],
                message.payload[5],
                message.payload[6],
                message.payload[7],
                message.payload[8],
              ]

              if let listenerNodeId = UInt64(bigEndianData: bed) {
                
                var index = 0
                
                var found = false
                
                for listener in listeners {
                  
                  if listener.nodeId == listenerNodeId {
                    
                    sendAttachListenerReply(destinationNodeId: message.sourceNodeId!, listenerNodeId: listenerNodeId, replyCode: .success)
                    
                    listeners.remove(at: index)
                    
                    found = true
                    
                    break
                    
                  }
                  
                  index += 1
                }
                
                if !found {
                  sendAttachListenerReply(destinationNodeId: message.sourceNodeId!, listenerNodeId: listenerNodeId, replyCode: .permanentErrorNotFound)
                }
                
              }
              
            case .queryNodes:
              
              var found = false
              
              if message.payload.count >= 3 {
                
                let index = Int(message.payload[2])
                
                if index < listeners.count {
                  
                  sendListenerQueryNodeReply(destinationNodeId: message.sourceNodeId!, nodeCount: listeners.count, nodeIndex: index, flags: listeners[index].flags, listenerNodeId: listeners[index].nodeId)
                  
                  found = true
                  
                }
                
              }
 
              if !found {
                sendListenerQueryNodeReplyShort(destinationNodeId: message.sourceNodeId!, nodeCount: listeners.count)
              }
              
            }
            
          }
          
        case .tractionManagement:
          break
        }
      
        if activeControllerNodeId != 0 && !isStopped {
          heartbeatMode = .waitingForCommand
          startTimer(interval: heartbeatPeriod)
        }
        
      }
      
    case .tractionControlReply:
      
      if let instruction = OpenLCBTractionControlInstructionType(rawValue: message.payload[0] & 0b01111111) {

        switch instruction {
          
        case .controllerConfiguration:
          
          if let configurationType = OpenLCBTractionControllerConfigurationType(rawValue: message.payload[1]) {
            
            switch configurationType {
              
            case .controllerChangingNotify:
              
              if nextActiveControllerNodeId != 0 {
                
                if message.payload[2] == 0 {
                  
                  activeControllerNodeId = nextActiveControllerNodeId
                  
                }
                else {
                  sendAssignControllerReply(destinationNodeId: nextActiveControllerNodeId, result: 0x01)
                }
                
                nextActiveControllerNodeId = 0
                
              }
              
            default:
              break
            }
          }
          
        default:
          break
        }
        
      }
      
    case .producerConsumerEventReport:
      
      if let id = message.eventId, let eventType = OpenLCBWellKnownEvent(rawValue: id) {
        
        switch eventType {
        case .emergencyOffAll:
          globalEmergencyOff = true
        case .clearEmergencyOffAll:
          globalEmergencyOff = false
        case .emergencyStopAll:
          globalEmergencyStop = true
        case .clearEmergencyStopAll:
          globalEmergencyStop = false
        default:
          break
        }
        
      }
      else if message.isLocationServicesEvent, let trainNodeId = message.trainNodeId, let uniqueId = dccAddressUniqueId, trainNodeId == uniqueId {
        
        var motionRelative : OpenLCBLocationServiceFlagDirectionRelative
        
        if setSpeed < 0.0 {
          motionRelative = .reverse
        }
        else if setSpeed > 0.0 {
          motionRelative = .forward
        }
        else {
          motionRelative = .stopped
        }
        
        sendLocationServiceEvent(eventId: message.eventId!, trainNodeId: nodeId, entryExit: message.locationServicesFlagEntryExit!, motionRelative: motionRelative, motionAbsolute: message.locationServicesFlagDirectionAbsolute!, contentFormat: message.locationServicesFlagContentFormat!, content: message.locationServicesContent)
        
      }

    case .identifyProducer:
      
      if let id = message.eventId {
        
        // Train Search Protocol
        
        let mask = OpenLCBWellKnownEvent.trainSearchEvent.rawValue
        
        if (id & mask) == mask {
 
          let data = id.bigEndianData
          
          let tp = data[7] & OpenLCBTrackProtocol.trackProtocolMask
          
          if let trackProtocol = OpenLCBTrackProtocol(rawValue: tp), trackProtocol.isMatch(address: dccAddress, speedSteps: speedSteps) {
            
      //    let forceAllocateMask      : UInt8 = 0x80
            let exactMatchOnlyMask     : UInt8 = 0x40
            let matchOnlyInAddressMask : UInt8 = 0x20
            
      //    let forceAllocate      = (data[7] & forceAllocateMask)      == forceAllocateMask
            let exactMatchOnly     = (data[7] & exactMatchOnlyMask)     == exactMatchOnlyMask
            let matchOnlyInAddress = (data[7] & matchOnlyInAddressMask) == matchOnlyInAddressMask
            
            var nibbles : [UInt8] = []
            
            for index in 4...6 {
              nibbles.append(data[index] >> 4)
              nibbles.append(data[index] & 0x0f)
            }
            
            var digitSequence : [String] = []
            
            var temp : String = ""
            
            for nibble in nibbles {
              switch nibble {
              case 0x0...0x9:
                temp += "\(nibble)"
              case 0xf:
                if !temp.isEmpty {
                  digitSequence.append(temp)
                  temp = ""
                }
              default:
                return
              }
              
            }
            
            if !temp.isEmpty {
              digitSequence.append(temp)
            }
            
            let address = "\(dccAddress)"
            
            var addressMatch : Bool = digitSequence.count == 1 && (
              speedSteps == .trinary ||
              trackProtocol == .anyTrackProtocol ||
              !trackProtocol.forceLongAddress ||
              dccAddress >= 128
              // long dccAddress < 128 is not supported by LocoNet, so it is not tested for
            )
            
            addressMatch = addressMatch && ((exactMatchOnly && digitSequence[0] == address) || (!exactMatchOnly && address.prefix(digitSequence[0].count) == digitSequence[0]))
            
            var nameMatch : Bool = false
            
            if !matchOnlyInAddress {
              
              nameMatch = digitSequence.isEmpty
              
              if !nameMatch {
                
                nameMatch = true
                
                var nameDigitSequence : [String] = []
                
                temp = ""
                
                for char in userNodeName {
                  switch char {
                  case "0"..."9":
                    temp += String(char)
                    break
                  default:
                    if !temp.isEmpty {
                      nameDigitSequence.append(temp)
                      temp = ""
                    }
                  }
                }
                
                if !temp.isEmpty {
                  nameDigitSequence.append(temp)
                }
                
                for sequence in digitSequence {
                  var found = false
                  for nameSequence in nameDigitSequence {
                    if (exactMatchOnly && sequence == nameSequence) || (!exactMatchOnly && sequence == nameSequence.prefix(sequence.count)) {
                      found = true
                      break
                    }
                  }
                  nameMatch = nameMatch && found
                }
                
              }
              
            }
            
            if addressMatch || (!matchOnlyInAddress && nameMatch) {
              sendProducerIdentified(eventId: id, validity: .valid)
            }
            
          }

        }
        else if let event = OpenLCBWellKnownEvent(rawValue: id) {
          
          if event == .nodeIsATrain {
            sendProducerIdentified(eventId: id, validity: .valid)
          }
          
        }
        
      }

    default:
      break
    }
    
  }
  
  // MARK: Class Methods
  
  public static func mapDCCAddressToID(address:UInt16) -> UInt64? {
    
    guard address > 0 && address < 10240 else {
      return nil
    }
    
    var result : UInt64 = 0x060100000000 | UInt64(address)
    
    if address > 127 {
      result += 0xc000
    }
    
    return result
    
  }
  
}
