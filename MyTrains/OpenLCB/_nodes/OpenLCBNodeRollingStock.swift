//
//  OpenLCBNodeRollingStock.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/05/2023.
//

import Foundation

public class OpenLCBNodeRollingStock : OpenLCBNodeVirtual {
  
  // MARK: Constructors
  
  public init(rollingStock:RollingStock) {
    
    let nodeId = 0x0801000d0000 + UInt64(rollingStock.primaryKey)
    
    functionSpaceSize = 0x45
    
    _rollingStock = rollingStock
    
    functions = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.functions.rawValue, defaultMemorySize: functionSpaceSize, isReadOnly: false, description: "")
    
    configuration = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, defaultMemorySize: 2291, isReadOnly: false, description: "")
    
    super.init(nodeId: nodeId)
    
    configuration.delegate = self

    memorySpaces[configuration.space] = configuration

    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressDCCAddress)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedSteps)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressF0ConsistBehaviour)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressF0Directional)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressF0MUSwitch)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressLocoNetGateway)

    for fn in 1...numberOfFunctions {
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

    isDatagramProtocolSupported = true
    
    isIdentificationSupported = true
    
    isSimpleNodeInformationProtocolSupported = true
    
    isTractionControlProtocolSupported = true
    
    isSimpleTrainNodeInformationProtocolSupported = true
    
    if !memorySpacesInitialized {
      resetToFactoryDefaults()
    }
    
    initCDI(filename: "MyTrains Train", manufacturer: manufacturerName, model: nodeModelName)
    
  }
  
  // MARK: Private Properties
  
  internal let functionSpaceSize : Int
  
  internal var _rollingStock : RollingStock
  
  internal var functions : OpenLCBMemorySpace
  
  internal var configuration : OpenLCBMemorySpace
  
  internal let addressDCCAddress         : Int = 0
  internal let addressSpeedSteps         : Int = 2
  internal let addressF0ConsistBehaviour : Int = 3
  internal let addressF0Directional      : Int = 4
  internal let addressF0MUSwitch         : Int = 5
  internal let addressFNDisplayName      : Int = 7
  internal let addressFNMomentary        : Int = 8
  internal let addressFNConsistBehaviour : Int = 9
  internal let addressFNDescription      : Int = 10
  
  internal let addressLocoNetGateway     : Int = 2283
  
  internal let numberOfFunctions : Int = 69
  internal let functionGroupSize : Int = 35
  
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
  
  public var rollingStock : RollingStock {
    get {
      return _rollingStock
    }
  }
  
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
  
  public let heartbeatPeriod : UInt8 = 10
  
  public let heartbeatDeadline : UInt8 = 3

  // MARK: Private Methods
  
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
    
    manufacturerName     = NMRA.manufacturerName(code: _rollingStock.manufacturerId)
    nodeModelName        = _rollingStock.rollingStockName
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
 
    guard !isStopped else {
      stopTimer()
      return
    }
    
    switch heartbeatMode {
      
    case .waitingForCommand:
      
      heartbeatMode = .waitingForResponse
      
      networkLayer?.sendHeartbeatRequest(sourceNodeId: nodeId, destinationNodeId: activeControllerNodeId, timeout: heartbeatDeadline)
      
      startTimer(interval: heartbeatDeadline)
      
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
    
    let deadline : TimeInterval = Double(interval)
    
    timer = Timer.scheduledTimer(timeInterval: deadline, target: self, selector: #selector(timerAction), userInfo: nil, repeats: false)
    
    RunLoop.current.add(timer!, forMode: .common)

  }
  
  private func stopTimer() {
    timer?.invalidate()
    timer = nil
    heartbeatMode = .stopped
  }

  // MARK: Public Methods
  
  public override func start() {
    
    super.start()
    
    networkLayer?.sendWellKnownEvent(sourceNodeId: nodeId, eventId: .nodeIsATrain)
    
  }
  
  public override func variableChanged(space:OpenLCBMemorySpace, address:Int) {
    
  }
  
  public func setSpeedToZero() {
    
    setSpeed = (setSpeed.bitPattern == (-0.0).bitPattern || setSpeed < 0.0) ? -0.0 : +0.0
    
  }

  // MARK: OpenLCBMemorySpaceDelegate Methods
  
  // MARK: OpenLCBNetworkLayerDelegate Methods
   
  public override func openLCBMessageReceived(message: OpenLCBMessage) {
    
    super.openLCBMessageReceived(message: message)
    
    switch message.messageTypeIndicator {
      
    case .tractionControlCommand:
      
      if message.destinationNodeId == nodeId, let instruction = OpenLCBTractionControlInstructionType(rawValue: message.payload[0] & 0b01111111) {
        
        stopTimer()
        
        let isForwarded = ((message.payload[0]) & 0x80 == 0x80) && isListener(nodeId: message.sourceNodeId!)
        
        switch instruction {
          
        case .setSpeedDirection:
          
          if !isForwarded && message.sourceNodeId! != activeControllerNodeId {
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
                  if forwardedSpeed.bitPattern == (+0.0).bitPattern {
                    forwardedSpeed = -0.0
                  }
                  else if forwardedSpeed.bitPattern == (-0.0).bitPattern {
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
          
          if !isForwarded && message.sourceNodeId! != activeControllerNodeId {
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
          
          if !isForwarded && message.sourceNodeId! != activeControllerNodeId {
            networkLayer?.sendTerminateDueToError(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, errorCode: .permanentErrorSourceNotPermitted)
          }
          else {
            
            if abs(setSpeed) != 0.0 {
              setSpeedToZero()
            }
            
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

                nextActiveControllerNodeId = 0
                
                if activeControllerNodeId == 0 {
                  
                  activeControllerNodeId = controllerNodeId
                  
                  attachNode()
                  
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
                  
                  networkLayer?.sendAssignListenerReply(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, listenerNodeId: listenerNodeId, replyCode: .permanentErrorAlreadyExists)
                  
                }
                else {
                  
                  var found = false
                  
                  for listener in listeners {
                    
                    if listener.nodeId == listenerNodeId {
                      
                      listener.flags = message.payload[2]
                      
                      networkLayer?.sendAssignListenerReply(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, listenerNodeId: listenerNodeId, replyCode: .success)
                      
                      found = true
                      
                    }
                    
                  }
                  
                  if !found {
                    
                    let listenerNode = OpenLCBTractionListenerNode(nodeId: listenerNodeId, flags: message.payload[2])
                    
                    listeners.append(listenerNode)
                    
                    networkLayer?.sendAssignListenerReply(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, listenerNodeId: listenerNodeId, replyCode: .success)
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
                    
                    networkLayer?.sendAssignListenerReply(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, listenerNodeId: listenerNodeId, replyCode: .success)
                    
                    listeners.remove(at: index)
                    
                    found = true
                    
                    break
                    
                  }
                  
                  index += 1
                }
                
                if !found {
                  networkLayer?.sendAssignListenerReply(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, listenerNodeId: listenerNodeId, replyCode: .permanentErrorNotFound)
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
                  
                  attachNode()
                  
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
          
          if let trackProtocol = OpenLCBTrackProtocol(rawValue: tp), trackProtocol == .anyTrackProtocol || trackProtocol == .nativeOpenLCBNode {
            
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
              networkLayer?.sendProducerIdentifiedValid(sourceNodeId: nodeId, eventId: id)
            }
            
          }
          else {
            print("unknown track protocol found: 0x\(tp.toHex(numberOfDigits: 2))")
          }

        }
        
      }

    default:
      break
    }
    
  }
  
}
