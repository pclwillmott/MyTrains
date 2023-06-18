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
  
  let functionSpaceSize : Int
  
  private var _rollingStock : RollingStock
  
  private var functions : OpenLCBMemorySpace
  
  private var configuration : OpenLCBMemorySpace
  
  internal let addressDCCAddress         : Int = 0
  internal let addressSpeedSteps         : Int = 2
  internal let addressF0ConsistBehaviour : Int = 3
  internal let addressF0Directional      : Int = 4
  internal let addressF0MUSwitch         : Int = 5
  internal let addressFNDisplayName      : Int = 7
  internal let addressFNMomentary        : Int = 8
  internal let addressFNConsistBehaviour : Int = 9
  internal let addressFNDescription      : Int = 10
  
  private let numberOfFunctions : Int = 65
  private let functionGroupSize : Int = 35
  
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
    
    let mask = OpenLCBWellKnownEvent.trainSearchEvent.rawValue
    
    if let id = message.eventId, (id & mask) == mask {
      
      print("\(message.messageTypeIndicator) \(id.toHexDotFormat(numberOfBytes: 8))")
      
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

        var nameMatch : Bool = digitSequence.count >= 1
        
        
        for sequence in digitSequence {
        
        }
        
      }
      else {
        print("unknown track protocol found: 0x\(tp.toHex(numberOfDigits: 2))")
      }
    }
  }
  
}
