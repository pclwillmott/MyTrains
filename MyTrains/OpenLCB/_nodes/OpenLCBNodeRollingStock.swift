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
    
    //    let nodeId = 0x0801000d0000 + UInt64(rollingStock.primaryKey)
    
    functionSpaceSize = 0x45
    
    functions = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.functions.rawValue, defaultMemorySize: functionSpaceSize, isReadOnly: false, description: "")
    
    let configSize = addressLocoNetGateway + 8
    
    configuration = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, defaultMemorySize: configSize, isReadOnly: false, description: "")
    
    let cvSize = numberOfCVs * 3
    
    cvs = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.cv.rawValue, defaultMemorySize: cvSize, isReadOnly: false, description: "")
        
    super.init(nodeId: nodeId)
    
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

    for fn in 1...numberOfFunctions - 1 {
      let groupOffset = (fn - 1) * functionGroupSize
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressFNDisplayName      + groupOffset)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressFNMomentary        + groupOffset)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressFNConsistBehaviour + groupOffset)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressFNDescription      + groupOffset)
    }
    
    functions.delegate = self
    
    memorySpaces[functions.space] = functions
    
    for fn in 0 ... numberOfFunctions - 1 {
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.functions.rawValue, address: fn)
    }
    
    cvs.delegate = self
    
    memorySpaces[cvs.space] = cvs
    
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
    
    initCDI(filename: "MyTrains Train", manufacturer: manufacturerName, model: nodeModelName)
    
    initFDI(filename: "FDI Generic")
    
  }
  
  // MARK: Private Properties
  
  internal let functionSpaceSize : Int
  
  internal var functions : OpenLCBMemorySpace
  
  internal var configuration : OpenLCBMemorySpace
  
  internal var cvs : OpenLCBMemorySpace
  
  internal let addressDCCAddress         : Int = 0
  internal let addressSpeedSteps         : Int = 2
  internal let addressF0ConsistBehaviour : Int = 3
  internal let addressF0Directional      : Int = 4
  internal let addressF0MUSwitch         : Int = 5
  internal let addressFNDisplayName      : Int = 7
  internal let addressFNMomentary        : Int = 8
  internal let addressFNConsistBehaviour : Int = 9
  internal let addressFNDescription      : Int = 10
  internal let addressDeleteFromRoster   : Int = 2387
  internal let addressLocoNetGateway     : Int = 2388
  
  internal let numberOfFunctions : Int = 69
  internal let functionGroupSize : Int = 35
  internal let numberOfCVs : Int = 1024
  
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
    get {
      return abs(setSpeed) == 0.0 || emergencyStop
    }
  }
  
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
      return configuration.getUInt16(address: addressDCCAddress)!
    }
    set(value) {
      configuration.setUInt(address: addressDCCAddress, value: value)
    }
  }
  
  public var speedSteps : SpeedSteps {
    get {
      return SpeedSteps(rawValue: configuration.getUInt8(address: addressSpeedSteps)!)!
    }
    set(value) {
      configuration.setUInt(address: addressDCCAddress, value: value.rawValue)
    }
  }
  
  public var locoNetGatewayNodeId : UInt64 {
    get {
      return configuration.getUInt64(address: addressLocoNetGateway)!
    }
    set(value) {
      configuration.setUInt(address: addressLocoNetGateway, value: value)
    }
  }
  
  public let heartbeatPeriod : UInt8 = 10
  
  public let heartbeatDeadline : UInt8 = 3
  
  // MARK: Private Methods
  
  internal func isMomentary(number:Int) -> Bool {
    
    if number == 0 {
      return false
    }
    
    let baseAddress = (number - 1) * functionGroupSize
    
    if let value = configuration.getUInt8(address: baseAddress + addressFNMomentary) {
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
          if let displayNameId = configuration.getUInt8(address: baseAddress + addressFNDisplayName), let function = OpenLCBFunction(rawValue: displayNameId), let momentary = configuration.getUInt8(address: baseAddress + addressFNMomentary) {
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
    
    acdiManufacturerSpaceVersion = 4
    
    manufacturerName     = virtualNodeType.manufacturerName
    nodeModelName        = virtualNodeType.name
    nodeHardwareVersion  = ""
    nodeSoftwareVersion  = ""
    
    acdiUserSpaceVersion = 2
    
    userNodeName         = ""
    userNodeDescription  = ""
    
    functions.memory = [UInt8](repeating: 0, count: functionSpaceSize)
    
    saveMemorySpaces()
    
  }
  
  internal func attachNode() {
  }
  
  internal func attachCompleted() {
    networkLayer?.sendAssignControllerReply(sourceNodeId: nodeId, destinationNodeId: activeControllerNodeId, result: 0)
  }
  
  internal func attachFailed() {
    
    networkLayer?.sendAssignControllerReply(sourceNodeId: nodeId, destinationNodeId: activeControllerNodeId, result: 0x02)
    
    activeControllerNodeId = 0
    
    nextActiveControllerNodeId = 0
    
  }
  
  internal func releaseNode() {
    
  }
  
  internal func speedChanged() {
    
  }
  
  internal func functionChanged() {
    
  }
  
  @objc func timerAction() {
    
    timer?.invalidate()
    
    switch heartbeatMode {
      
    case .waitingForCommand:
      
      heartbeatMode = .waitingForResponse
      
      startTimer(interval: heartbeatDeadline)
      
      networkLayer?.sendHeartbeatRequest(sourceNodeId: nodeId, destinationNodeId: activeControllerNodeId, timeout: heartbeatDeadline)
      
    case .waitingForResponse:
      
      heartbeatMode = .stopped
      
      setSpeedToZero()
      
      speedChanged()
      
      for listener in listeners {
        networkLayer?.sendSetSpeedDirection(sourceNodeId: nodeId, destinationNodeId: listener.nodeId, setSpeed: setSpeed, isForwarded: true)
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
  
  public func reloadCDI() {
    memorySpaces.removeValue(forKey: OpenLCBNodeMemoryAddressSpace.cdi.rawValue)
    initCDI(filename: "MyTrains Train", manufacturer: manufacturerName, model: nodeModelName)
  }
  
  public func reloadFDI() {
    memorySpaces.removeValue(forKey: OpenLCBNodeMemoryAddressSpace.fdi.rawValue)
    initCDI(filename: "FDI Generic", manufacturer: manufacturerName, model: nodeModelName)
  }
  
  public override func start() {
    
    super.start()
    
    networkLayer?.sendWellKnownEvent(sourceNodeId: nodeId, eventId: .nodeIsATrain)
    
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
      
      if message.destinationNodeId! == nodeId, let instruction = OpenLCBTractionControlInstructionType(rawValue: message.payload[0] & 0b01111111) {
        
        timer?.invalidate()
        
        let isForwarded = ((message.payload[0]) & 0x80 == 0x80) && isListener(nodeId: message.sourceNodeId!)
        
        switch instruction {
          
        case .setSpeedDirection:
          
          if !isForwarded && false && message.sourceNodeId! != activeControllerNodeId {
            networkLayer?.sendTerminateDueToError(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, errorCode: .permanentErrorSourceNotPermitted)
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
                  let plusZero : Float = -0.0

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
                networkLayer?.sendSetSpeedDirection(sourceNodeId: nodeId, destinationNodeId: listener.nodeId, setSpeed: forwardedSpeed, isForwarded: true)
              }
            }
            
          }
          
        case .setFunction:
          
          if !isForwarded && false && message.sourceNodeId! != activeControllerNodeId {
            networkLayer?.sendTerminateDueToError(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, errorCode: .permanentErrorSourceNotPermitted)
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
                  networkLayer?.sendSetFunction(sourceNodeId: nodeId, destinationNodeId: listener.nodeId, address: address, value: value, isForwarded: true)
                }
              }
              
            }
            
          }
          
        case .emergencyStop:
          
          if !isForwarded && false && message.sourceNodeId! != activeControllerNodeId {
            networkLayer?.sendTerminateDueToError(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, errorCode: .permanentErrorSourceNotPermitted)
          }
          else {
            
            emergencyStop = true
            
            for listener in listeners {
              if listener.nodeId != message.sourceNodeId! {
                networkLayer?.sendEmergencyStop(sourceNodeId: nodeId, destinationNodeId: listener.nodeId, isForwarded: true)
              }
            }
            
          }
          
        case .querySpeeds:
          
          networkLayer?.sendQuerySpeedReply(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, setSpeed: setSpeed, commandedSpeed: commandedSpeed, emergencyStop: emergencyStop)
          
        case .queryFunction:
          
          let bed = [
            message.payload[1],
            message.payload[2],
            message.payload[3]
          ]
          
          if let space = memorySpaces[OpenLCBNodeMemoryAddressSpace.functions.rawValue], let address = UInt32(bigEndianData: bed) {
              
            if space.isWithinSpace(address: Int(address), count: 1), let value = space.getUInt8(address: Int(address)) {
              
              networkLayer?.sendQueryFunctionReply(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, address: address, value: UInt16(value))
              
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
                
 //               print("controllerNodeId: \(controllerNodeId.toHexDotFormat(numberOfBytes: 6))")

                nextActiveControllerNodeId = 0
                
                if activeControllerNodeId == 0 || activeControllerNodeId == controllerNodeId {
                  
                  if activeControllerNodeId != 0 {
                    networkLayer?.sendAssignControllerReply(sourceNodeId: nodeId, destinationNodeId: controllerNodeId, result: 0)
                  }
                  else {
                    activeControllerNodeId = controllerNodeId
                  }
                  
                }
                else {

                  nextActiveControllerNodeId = controllerNodeId
                  
                  networkLayer?.sendControllerChangedNotify(sourceNodeId: nodeId, destinationNodeId: activeControllerNodeId, newController: nextActiveControllerNodeId)
                  
                }
                
              }
              
            case .releaseController:
              
              if let controllerNodeId = UInt64(bigEndianData: bed) {
                
                if controllerNodeId == activeControllerNodeId {
                  activeControllerNodeId = 0
                }
                
              }
              
            case .queryController:
              
              networkLayer?.sendQueryControllerReply(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, activeController: activeControllerNodeId)
              
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
                  
                  networkLayer?.sendAttachListenerReply(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, listenerNodeId: listenerNodeId, replyCode: .permanentErrorAlreadyExists)
                  
                }
                else {
                  
                  var found = false
                  
                  for listener in listeners {
                    
                    if listener.nodeId == listenerNodeId {
                      
                      listener.flags = message.payload[2]
                      
                      networkLayer?.sendAttachListenerReply(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, listenerNodeId: listenerNodeId, replyCode: .success)
                      
                      found = true
                      
                    }
                    
                  }
                  
                  if !found {
                    
                    let listenerNode = OpenLCBTractionListenerNode(nodeId: listenerNodeId, flags: message.payload[2])
                    
                    listeners.append(listenerNode)
                    
                    networkLayer?.sendAttachListenerReply(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, listenerNodeId: listenerNodeId, replyCode: .success)
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
                    
                    networkLayer?.sendAttachListenerReply(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, listenerNodeId: listenerNodeId, replyCode: .success)
                    
                    listeners.remove(at: index)
                    
                    found = true
                    
                    break
                    
                  }
                  
                  index += 1
                }
                
                if !found {
                  networkLayer?.sendAttachListenerReply(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, listenerNodeId: listenerNodeId, replyCode: .permanentErrorNotFound)
                }
                
              }
              
            case .queryNodes:
              
              var found = false
              
              if message.payload.count >= 3 {
                
                let index = Int(message.payload[2])
                
                if index < listeners.count {
                  
                  networkLayer?.sendListenerQueryNodeReply(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, nodeCount: listeners.count, nodeIndex: index, flags: listeners[index].flags, listenerNodeId: listeners[index].nodeId)
                  
                  found = true
                  
                }
                
              }
 
              if !found {
                networkLayer?.sendListenerQueryNodeReplyShort(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, nodeCount: listeners.count)
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
      
      if message.destinationNodeId == nodeId, let instruction = OpenLCBTractionControlInstructionType(rawValue: message.payload[0] & 0b01111111) {

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
                  networkLayer?.sendAssignControllerReply(sourceNodeId: nodeId, destinationNodeId: nextActiveControllerNodeId, result: 0x01)
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
              networkLayer?.sendProducerIdentified(sourceNodeId: nodeId, eventId: id, validity: .valid)
            }
            
          }
          else {
       //     print("train search did not match track protocol \(userNodeName): 0x\(tp.toHex(numberOfDigits: 2))")
          }

        }
        else if let event = OpenLCBWellKnownEvent(rawValue: id) {
          
          if event == .nodeIsATrain {
            networkLayer?.sendProducerIdentified(sourceNodeId: nodeId, eventId: id, validity: .valid)
          }
          
        }
        
      }

    default:
      break
    }
    
  }
  
}
