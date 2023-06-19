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
    
    functionSpaceSize = 0x42
    
    _rollingStock = rollingStock
    
    functions = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.functions.rawValue, defaultMemorySize: functionSpaceSize, isReadOnly: false, description: "")
    
    configuration = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, defaultMemorySize: 2283, isReadOnly: false, description: "")
    
    super.init(nodeId: nodeId)
    
    configuration.delegate = self

    memorySpaces[configuration.space] = configuration

    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressDCCAddress)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedSteps)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressF0ConsistBehaviour)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressF0Directional)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressF0MUSwitch)

    for fn in 1...numberOfFunctions {
      let groupOffset = (fn - 1) * functionGroupSize
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressFNDisplayName      + groupOffset)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressFNMomentary        + groupOffset)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressFNConsistBehaviour + groupOffset)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressFNDescription      + groupOffset)
    }
    
    functions.delegate = self

    memorySpaces[functions.space] = functions

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
  
  internal let numberOfFunctions : Int = 65
  internal let functionGroupSize : Int = 35
  
  internal var activeControllerNodeId : UInt64 = 0
  
  internal var listeners : [UInt64:OpenLCBTractionListenerNode] = [:]
  
  internal var setSpeed : Float = 0.0
  internal var commandedSpeed : Float = 0.0
  internal var actualSpeed : Float = 0.0
  internal var emergencyStop : Bool = false
  
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

  // MARK: Private Methods
  
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
 
  // MARK: Public Methods
  
  public override func start() {
    
    super.start()
    
    networkLayer?.sendWellKnownEvent(sourceNodeId: nodeId, eventId: .nodeIsATrain)
    
  }
  
  // MARK: OpenLCBMemorySpaceDelegate Methods
  
  // MARK: OpenLCBNetworkLayerDelegate Methods
   
  public override func openLCBMessageReceived(message: OpenLCBMessage) {
    
    super.openLCBMessageReceived(message: message)
    
    switch message.messageTypeIndicator {
      
    case .tractionControlCommand:
      
      if message.destinationNodeId == nodeId, let instruction = OpenLCBTractionControlInstructionType(rawValue: message.payload[0] & 0b01111111) {
        
        switch instruction {
        case .setSpeedDirection:
          
          if let uint16 = UInt16(bigEndianData: [message.payload[1], message.payload[2]]) {
            var f16 = float16_t()
            f16.v = uint16
            setSpeed = Float(float16: f16)
            commandedSpeed = setSpeed
            actualSpeed = setSpeed
            emergencyStop = false
            
       //     print(setSpeed * 3600.0 / (1000.0 * 1.609344))
            
          }
          
        case .setFunction:
          
          let bed = [
            message.payload[1],
            message.payload[2],
            message.payload[3]
          ]
          
          if let space = memorySpaces[OpenLCBNodeMemoryAddressSpace.functions.rawValue], let address = UInt32(bigEndianData: bed), space.isWithinSpace(address: Int(address), count: 1) {
            
            let value = message.payload[5]
            
            space.setUInt(address: Int(address), value: value)
            
          }
          
        case .emergencyStop:
          emergencyStop = true
        case .querySpeeds:
          
          networkLayer?.sendQuerySpeedReply(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, setSpeed: setSpeed, commandedSpeed: commandedSpeed, actualSpeed: actualSpeed, emergencyStop: emergencyStop)
          
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

                let lastActiveControllerNodeId = activeControllerNodeId
                
                activeControllerNodeId = controllerNodeId
                
                networkLayer?.sendAssignControllerReply(sourceNodeId: nodeId, destinationNodeId: controllerNodeId, result: 0)
                
                if lastActiveControllerNodeId != 0 {
                  networkLayer?.sendControllerChangedNotify(sourceNodeId: nodeId, destinationNodeId: lastActiveControllerNodeId, newController: activeControllerNodeId)
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
          
            let bed = [
              message.payload[3],
              message.payload[4],
              message.payload[5],
              message.payload[6],
              message.payload[7],
              message.payload[8],
            ]

            switch configurationType {
            case .attachNode:
              
              if let listenerNodeId = UInt64(bigEndianData: bed) {
                
                if listenerNodeId == nodeId {
                  networkLayer?.sendAssignListenerReply(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, listenerNodeId: listenerNodeId, replyCode: .permanentErrorAlreadyExists)
                }
                else if let listenerNode = listeners[listenerNodeId] {
                  listenerNode.flags = message.payload[2]
                  
                  networkLayer?.sendAssignListenerReply(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, listenerNodeId: listenerNodeId, replyCode: .noError)
                  
                }
                else {
                  let listenerNode = OpenLCBTractionListenerNode(nodeId: listenerNodeId, flags: message.payload[2])
                  listeners[listenerNodeId] = listenerNode
                  networkLayer?.sendAssignListenerReply(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, listenerNodeId: listenerNodeId, replyCode: .noError)
                }
                
              }
              
            case .detachNode:
              
              if let listenerNodeId = UInt64(bigEndianData: bed) {
                
                if let listener = listeners[listenerNodeId] {
                  listeners.removeValue(forKey: listenerNodeId)
                  networkLayer?.sendAssignListenerReply(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, listenerNodeId: listenerNodeId, replyCode: .noError)
                }
                else {
                  networkLayer?.sendAssignListenerReply(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, listenerNodeId: listenerNodeId, replyCode: .permanentErrorNotFound)
                }
              }
              
            case .queryNodes:
              break
            }
            
          }
          
        case .tractionManagement:
          break
        }
        
      }
      
    case .producerConsumerEventReport:
      
      if let id = message.eventId, let eventType = OpenLCBWellKnownEvent(rawValue: id) {
        
        switch eventType {
        case .emergencyOff:
          break
        case .clearEmergencyOff:
          break
        case .emergencyStopAllOperations:
          break
        case .clearEmergencyStopAllOperations:
          break
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
            
            let forceAllocateMask      : UInt8 = 0x80
            let exactMatchOnlyMask     : UInt8 = 0x40
            let matchOnlyInAddressMask : UInt8 = 0x20
            
            let forceAllocate      = (data[7] & forceAllocateMask)      == forceAllocateMask
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
              
              nameMatch = !digitSequence.isEmpty
              
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
