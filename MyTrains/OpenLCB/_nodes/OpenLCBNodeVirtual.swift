//
//  OpenLCBNodeVirtual.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/05/2023.
//

import Foundation

public class OpenLCBNodeVirtual : OpenLCBNode, OpenLCBNetworkLayerDelegate, OpenLCBMemorySpaceDelegate {
  
  // MARK: Constructors
  
  public override init(nodeId:UInt64) {
    
    lfsr1 = UInt32(nodeId >> 24)
    
    lfsr2 = UInt32(nodeId & 0xffffff)

    acdiManufacturerSpace = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.acdiManufacturer.rawValue, defaultMemorySize: 125, isReadOnly: true, description: "")

    acdiUserSpace = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.acdiUser.rawValue, defaultMemorySize: 128, isReadOnly: false, description: "")
    
    super.init(nodeId: nodeId)
    
    acdiManufacturerSpace.delegate = self

    memorySpaces[acdiManufacturerSpace.space] = acdiManufacturerSpace
    
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.acdiManufacturer.rawValue, address: addressACDIManufacturerSpaceVersion)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.acdiManufacturer.rawValue, address: addressACDIManufacturerName)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.acdiManufacturer.rawValue, address: addressACDIModelName)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.acdiManufacturer.rawValue, address: addressACDIHardwareVersion)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.acdiManufacturer.rawValue, address: addressACDISoftwareVersion)
    
    acdiUserSpace.delegate = self

    memorySpaces[acdiUserSpace.space] = acdiUserSpace

    registerVariable(space: OpenLCBNodeMemoryAddressSpace.acdiUser.rawValue, address: addressACDIUserSpaceVersion)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.acdiUser.rawValue, address: addressACDIUserNodeName)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.acdiUser.rawValue, address: addressACDIUserNodeDescription)

    isSimpleNodeInformationProtocolSupported = true
    
    isDatagramProtocolSupported = true
    
    isMemoryConfigurationProtocolSupported = true
    
    isAbbreviatedDefaultCDIProtocolSupported = true
    
    isEventExchangeProtocolSupported = true
    
    isSimpleProtocolSubsetSupported = true
    
  }
  
  // MARK: Private Properties
  
  private var lockedNodeId : UInt64 = 0
  
  internal var memorySpaces : [UInt8:OpenLCBMemorySpace] = [:]
  
  internal var registeredVariables : [UInt8:Set<Int>] = [:]
  
  internal let addressACDIManufacturerSpaceVersion : Int =  0
  internal let addressACDIManufacturerName         : Int =  1
  internal let addressACDIModelName                : Int =  42
  internal let addressACDIHardwareVersion          : Int =  83
  internal let addressACDISoftwareVersion          : Int =  104
  internal let addressACDIUserSpaceVersion         : Int =  0
  internal let addressACDIUserNodeName             : Int =  1
  internal let addressACDIUserNodeDescription      : Int =  64

  // MARK: Public Properties
  
  public var lfsr1 : UInt32
  
  public var lfsr2 : UInt32

  public var state : OpenLCBTransportLayerState = .inhibited
  
  public var networkLayer : OpenLCBNetworkLayer?
  
  public var memorySpacesInitialized : Bool {
    get {
      return acdiManufacturerSpace.getUInt8(address: addressACDIManufacturerSpaceVersion) != 0
    }
  }
    
  public var acdiManufacturerSpace : OpenLCBMemorySpace
  
  public var acdiUserSpace : OpenLCBMemorySpace
  
  public override var acdiManufacturerSpaceVersion : UInt8 {
    get {
      return acdiManufacturerSpace.getUInt8(address: addressACDIManufacturerSpaceVersion)!
    }
    set(value) {
      acdiManufacturerSpace.setUInt(address: addressACDIManufacturerSpaceVersion, value: value)
    }
  }
  
  public override var manufacturerName : String {
    get {
      return acdiManufacturerSpace.getString(address: addressACDIManufacturerName, count: 41)!
    }
    set(value) {
      acdiManufacturerSpace.setString(address: addressACDIManufacturerName, value: String(value.prefix(40)), fieldSize: 41)
    }
  }
  
  public override var nodeModelName : String {
    get {
      return acdiManufacturerSpace.getString(address: addressACDIModelName, count: 41)!
    }
    set(value) {
      acdiManufacturerSpace.setString(address: addressACDIModelName, value: String(value.prefix(40)), fieldSize: 41)
    }
  }
  
  public override var nodeHardwareVersion : String {
    get {
      return acdiManufacturerSpace.getString(address: addressACDIHardwareVersion, count: 21)!
    }
    set(value) {
      acdiManufacturerSpace.setString(address: addressACDIHardwareVersion, value: String(value.prefix(20)), fieldSize: 21)
    }
  }
  
  public override var nodeSoftwareVersion : String {
    get {
      return acdiManufacturerSpace.getString(address: addressACDISoftwareVersion, count: 21)!
    }
    set(value) {
      acdiManufacturerSpace.setString(address: addressACDISoftwareVersion, value: String(value.prefix(20)), fieldSize: 21)
    }

  }
  
  public override var acdiUserSpaceVersion : UInt8 {
    get {
      return acdiUserSpace.getUInt8(address: addressACDIUserSpaceVersion)!
    }
    set(value) {
      acdiUserSpace.setUInt(address: addressACDIUserSpaceVersion, value: value)
    }
  }

  public override var userNodeName : String {
    get {
      return acdiUserSpace.getString(address: addressACDIUserNodeName, count: 63)!
    }
    set(value) {
      acdiUserSpace.setString(address: addressACDIUserNodeName, value: String(value.prefix(62)), fieldSize: 63)
    }
  }
  
  public override var userNodeDescription : String {
    get {
      return acdiUserSpace.getString(address: addressACDIUserNodeDescription, count: 64)!
    }
    set(value) {
      acdiUserSpace.setString(address: addressACDIUserNodeDescription, value: String(value.prefix(63)), fieldSize: 64)
    }
  }
  
  // MARK: Private Methods
  
  internal func resetReboot() {
  }
  
  internal func resetToFactoryDefaults() {
  }
  
  internal func saveMemorySpaces() {
    for (_, memorySpace) in memorySpaces {
      if memorySpace.space != OpenLCBNodeMemoryAddressSpace.cdi.rawValue {
        memorySpace.save()
      }
    }
  }
  
  // MARK: Public Methods

  public func initCDI(filename:String) {
    initCDI(filename: filename, manufacturer: "", model: "")
  }
  
  public func initCDI(filename:String, manufacturer:String, model:String) {
    if let filepath = Bundle.main.path(forResource: filename, ofType: "xml") {
      do {
        var contents = try String(contentsOfFile: filepath)
        contents = contents.replacingOccurrences(of: "%%MANUFACTURER%%", with: manufacturer)
        contents = contents.replacingOccurrences(of: "%%MODEL%%", with: model)
        let memorySpace = OpenLCBMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.cdi.rawValue, isReadOnly: true, description: "")
        memorySpace.memory = [UInt8]()
        memorySpace.memory.append(contentsOf: contents.utf8)
        memorySpace.memory.append(contentsOf: [UInt8](repeating: 0, count: 64))
        memorySpaces[memorySpace.space] = memorySpace
        isConfigurationDescriptionInformationProtocolSupported = true
      }
      catch {
      }
    }
  }
  
  public func start() {
  
    if let network = networkLayer {
      state = .permitted
      network.sendInitializationComplete(sourceNodeId: nodeId, isSimpleSetSufficient: false)
      resetReboot()
    }
    
  }
  
  public func stop() {
    state = .inhibited
  }
  
  public func registerVariable(space:UInt8, address:Int) {
    var addresses  = Set<Int>()
    if let temp = registeredVariables[space] {
      addresses = temp
    }
    addresses.insert(address)
    registeredVariables[space] = addresses
  }
  
  public func variableChanged(space:OpenLCBMemorySpace, address:Int) {
    
  }
  
  // MARK: OpenLCBMemorySpaceDelegate Methods
  
  public func memorySpaceChanged(memorySpace: OpenLCBMemorySpace, startAddress: Int, endAddress: Int) {
    
    if let addresses = self.registeredVariables[memorySpace.space] {
      for address in addresses {
        if address >= startAddress && address <= endAddress {
          variableChanged(space: memorySpace, address: address)
        }
      }
    }
    
  }
    
  // MARK: OpenLCBNetworkLayerDelegate Methods
  
  public func networkLayerStateChanged(networkLayer: OpenLCBNetworkLayer) {
    
  }
  
  public func openLCBMessageReceived(message: OpenLCBMessage) {
    
    switch message.messageTypeIndicator {
    case .simpleNodeIdentInfoRequest:
      if message.destinationNodeId! == nodeId {
        networkLayer?.sendSimpleNodeInformationReply(sourceNodeId: self.nodeId, destinationNodeId: message.sourceNodeId!, data: encodedNodeInformation)
      }
    case .verifyNodeIDNumberGlobal:
      if message.payload.isEmpty || message.payloadAsHex == nodeId.toHex(numberOfDigits: 12) {
        networkLayer?.sendVerifiedNodeIdNumber(sourceNodeId: nodeId, isSimpleSetSufficient: false)
      }
    case .protocolSupportInquiry:
      if message.destinationNodeId! == nodeId {
        let data = supportedProtocols
        networkLayer?.sendProtocolSupportReply(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, data: data)
      }
    case .datagram:
      
      if message.destinationNodeId! == nodeId {
        
        switch message.datagramType {
        case .reinitializeFactoryResetCommand:
          networkLayer?.sendDatagramReceivedOK(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, replyPending: false, timeOut: 0.0)
          DispatchQueue.main.async {
            self.resetToFactoryDefaults()
          }
          
        case .resetRebootCommand:
          networkLayer?.sendDatagramReceivedOK(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, replyPending: false, timeOut: 0.0)
          
          DispatchQueue.main.async {
            self.stop()
            self.start()
          }
        case.LockReserveCommand:
          message.payload.removeFirst(2)
          if let id = UInt64(bigEndianData: message.payload) {
            if lockedNodeId == 0 {
              lockedNodeId = id
            }
            networkLayer?.sendLockReserveReply(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, reservedNodeId: lockedNodeId)
          }
          
        case .getAddressSpaceInformationCommand:
          
          message.payload.removeFirst(2) 
          
          let space = message.payload[0]
          
          if let memorySpace = memorySpaces[space] {
            networkLayer?.sendDatagramReceivedOK(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, replyPending: true, timeOut: 1.0)
            networkLayer?.sendGetAddressSpaceInformationReply(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, memorySpace: memorySpace)
          }
          else {
            networkLayer?.sendDatagramRejected(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, errorCode: .permanentErrorAddressSpaceUnknown)
          }
          
        case .readCommandGeneric, .readCommand0xFD, .readCommand0xFE, .readCommand0xFF:
 
          networkLayer?.sendDatagramReceivedOK(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, replyPending: true, timeOut: 1.0)

          var data = message.payload
          
          var bytesToRemove = 6
          
          var space : UInt8
          
          switch message.datagramType {
          case .readCommand0xFD:
            space = 0xfd
          case .readCommand0xFE:
            space = 0xfe
          case .readCommand0xFF:
            space = 0xff
            //          case .readCommandGeneric:
          default:
            space = data[6]
            bytesToRemove = 7
          }
          
          let startAddress = UInt32(bigEndianData: [data[2], data[3], data[4], data[5]])!
            
          if let memorySpace = memorySpaces[space] {
            
            data.removeFirst(bytesToRemove)
            let readCount = data[0] & 0x7f
            
            
            
            if readCount == 0 || readCount > 64 {
              networkLayer?.sendReadReplyFailure(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, addressSpace: space, startAddress: startAddress, errorCode: .permanentErrorInvalidArguments)
            }
            else if let data = memorySpace.getBlock(address: Int(startAddress), count: Int(readCount)) {
              networkLayer?.sendReadReply(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, addressSpace: space, startAddress: startAddress, data: data)
            }
            else {
              networkLayer?.sendReadReplyFailure(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, addressSpace: space, startAddress: startAddress, errorCode: .permanentErrorAddressOutOfBounds)
            }
            
          }
          else {
            networkLayer?.sendReadReplyFailure(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, addressSpace: space, startAddress: startAddress, errorCode: .permanentErrorAddressSpaceUnknown)
          }
          
        case .writeCommandGeneric, .writeCommand0xFD, .writeCommand0xFE, .writeCommand0xFF:

          networkLayer?.sendDatagramReceivedOK(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, replyPending: true, timeOut: 1.0)

          var data = message.payload
          
          var bytesToRemove = 6
          
          var space : UInt8
          
          switch message.datagramType {
          case .writeCommand0xFD:
            space = 0xfd
          case .writeCommand0xFE:
            space = 0xfe
          case .writeCommand0xFF:
            space = 0xff
            // case .readCommandGeneric:
          default:
            space = data[6]
            bytesToRemove = 7
          }
          
          let startAddress = UInt32(bigEndianData: [data[2], data[3], data[4], data[5]])!
            
          if let memorySpace = memorySpaces[space] {
            
            data.removeFirst(bytesToRemove)

            if memorySpace.isWithinSpace(address: Int(startAddress), count: data.count) {
              networkLayer?.sendWriteReply(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, addressSpace: space, startAddress: startAddress)
              memorySpace.setBlock(address: Int(startAddress), data: data, isInternal: false)
              memorySpace.save()
            }
            else {
              networkLayer?.sendWriteReplyFailure(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, addressSpace: space, startAddress: startAddress, errorCode: .permanentErrorAddressOutOfBounds)
            }
            
          }
          else {
            networkLayer?.sendWriteReplyFailure(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, addressSpace: space, startAddress: startAddress, errorCode: .permanentErrorAddressSpaceUnknown)
          }

        default:
          break
        }
        
      }
      
    default:
      break
    }
    
  }
    
}
