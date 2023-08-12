//
//  OpenLCBProgrammingTrackNode.swift
//  MyTrains
//
//  Created by Paul Willmott on 01/08/2023.
//

import Foundation

private enum IOState {
  case idle
  case reading
  case writing
}

public class OpenLCBProgrammingTrackNode : OpenLCBNodeVirtual, LocoNetDelegate {
  
  // MARK: Constructors
  
  public override init(nodeId:UInt64) {
    
    let configSize = addressDeleteFromRoster + 1
    
    configuration = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, defaultMemorySize: configSize, isReadOnly: false, description: "")
    
    let cvSize = numberOfCVs
    
    cvs = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.cv.rawValue, defaultMemorySize: cvSize, isReadOnly: false, description: "")
        
    super.init(nodeId: nodeId)

    virtualNodeType = MyTrainsVirtualNodeType.programmingTrackNode
    
    isDatagramProtocolSupported = true

    isIdentificationSupported = true
    
    isSimpleNodeInformationProtocolSupported = true
    
    configuration.delegate = self
    
    memorySpaces[configuration.space] = configuration
    
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressLocoNetGateway)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressDeleteFromRoster)

    cvs.delegate = self
    
    memorySpaces[cvs.space] = cvs
    
    for cv in 0 ... numberOfCVs - 1 {
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.cv.rawValue, address: cv)
    }
    
    if !memorySpacesInitialized {
      resetToFactoryDefaults()
    }
    
    initCDI(filename: "MyTrains DCC Programming Track", manufacturer: manufacturerName, model: nodeModelName)

  }
  
  deinit {
    locoNet = nil
  }
  
  // MARK: Private Properties
  
  internal var configuration : OpenLCBMemorySpace

  internal var cvs : OpenLCBMemorySpace
  
  internal let addressLocoNetGateway   : Int = 0
  internal let addressDeleteFromRoster : Int = 8
  
  internal let numberOfCVs : Int = 1024

  private var locoNet : LocoNet?
  
  private var locoNetGateways : [UInt64:String] = [:]
  
  private var progMode : OpenLCBProgrammingMode = .defaultProgrammingMode
  
  private var ioState : IOState = .idle
  
  private var ioCount = 0
  
  private var ioAddress = 0
  
  private var ioStartAddress : UInt32 = 0
  
  private var ioSourceNodeId : UInt64 = 0

  // MARK: Public Properties
  
  public var locoNetGatewayNodeId : UInt64 {
    get {
      return configuration.getUInt64(address: addressLocoNetGateway)!
    }
    set(value) {
      configuration.setUInt(address: addressLocoNetGateway, value: value)
    }
  }

  // MARK: Private Methods
  
  internal override func resetToFactoryDefaults() {

    acdiManufacturerSpaceVersion = 4
    
    manufacturerName    = virtualNodeType.manufacturerName
    nodeModelName       = virtualNodeType.name
    nodeHardwareVersion = "\(Bundle.main.releaseVersionNumberPretty)"
    nodeSoftwareVersion = "\(Bundle.main.releaseVersionNumberPretty)"

    acdiUserSpaceVersion = 2
    
    userNodeName        = ""
    userNodeDescription = ""
    
    saveMemorySpaces()
    
  }
  
  internal override func readCVs(sourceNodeId:UInt64, memorySpace:OpenLCBMemorySpace, startAddress:UInt32, count:UInt8) {
    
    guard let progMode = OpenLCBProgrammingMode(rawValue: startAddress & OpenLCBProgrammingMode.modeMask) else {
      networkLayer?.sendReadReplyFailure(sourceNodeId: nodeId, destinationNodeId: sourceNodeId, addressSpace: memorySpace.space, startAddress: startAddress, errorCode: .permanentErrorInvalidArguments)
      return
    }
    
    self.progMode = progMode
    
    self.ioState = .reading
    
    self.ioCount = Int(count)
    
    self.ioAddress = Int(startAddress & OpenLCBProgrammingMode.addressMark)
    
    self.ioStartAddress = startAddress
    
    self.ioSourceNodeId = sourceNodeId
    
    locoNet?.readCV(progMode: progMode.locoNetProgrammingMode(isProgrammingTrack: true), cv: self.ioAddress, address: 0)
    
  }
  
  internal override func writeCVs(sourceNodeId:UInt64, memorySpace:OpenLCBMemorySpace, startAddress:UInt32, data: [UInt8]) {
    
    guard let progMode = OpenLCBProgrammingMode(rawValue: startAddress & OpenLCBProgrammingMode.modeMask) else {
      networkLayer?.sendReadReplyFailure(sourceNodeId: nodeId, destinationNodeId: sourceNodeId, addressSpace: memorySpace.space, startAddress: startAddress, errorCode: .permanentErrorInvalidArguments)
      return
    }
    
    self.progMode = progMode
    
    self.ioState = .writing
    
    self.ioCount = data.count
    
    self.ioAddress = Int(startAddress & OpenLCBProgrammingMode.addressMark)
    
    self.ioStartAddress = startAddress
    
    self.ioSourceNodeId = sourceNodeId
    
    if memorySpace.isWithinSpace(address: Int(ioAddress), count: data.count) {
      memorySpace.setBlock(address: ioAddress, data: data, isInternal: true)
      locoNet?.writeCV(progMode: progMode.locoNetProgrammingMode(isProgrammingTrack: true), cv: ioAddress, address: 0, value: cvs.getUInt8(address: ioAddress)!)
    }
    else {
      networkLayer?.sendWriteReplyFailure(sourceNodeId: nodeId, destinationNodeId: sourceNodeId, addressSpace: memorySpace.space, startAddress: startAddress, errorCode: .permanentErrorAddressOutOfBounds)
    }

  }


  // MARK: Private Methods
  
  internal override func resetReboot() {
    
    super.resetReboot()
    
    networkLayer?.sendConsumerIdentified(sourceNodeId: nodeId, wellKnownEvent: .nodeIsALocoNetGateway, validity: .unknown)
    
    networkLayer?.sendIdentifyProducer(sourceNodeId: nodeId, event: .nodeIsALocoNetGateway)
    
    guard locoNetGatewayNodeId != 0 else {
      return
    }
    
    locoNet = LocoNet(gatewayNodeId: locoNetGatewayNodeId, virtualNode: self)
    
    locoNet?.delegate = self
    
  }
  
  // MARK: Public Methods
  
  public func reloadCDI() {
    memorySpaces.removeValue(forKey: OpenLCBNodeMemoryAddressSpace.cdi.rawValue)
    initCDI(filename: "MyTrains DCC Programming Track", manufacturer: manufacturerName, model: nodeModelName)
  }

  public override func initCDI(filename:String, manufacturer:String, model:String) {
    
    if let filepath = Bundle.main.path(forResource: filename, ofType: "xml") {
      do {
        
        var contents = try String(contentsOfFile: filepath)
        
        contents = contents.replacingOccurrences(of: "%%MANUFACTURER%%", with: manufacturer)
        contents = contents.replacingOccurrences(of: "%%MODEL%%", with: model)
        
        var sorted : [(nodeId:UInt64, name:String)] = []
        
        for (key, name) in locoNetGateways {
          sorted.append((nodeId:key, name:name))
        }
        
        sorted.sort {$0.name < $1.name}
        
        var gateways = "<relation><property>00.00.00.00.00.00.00.00</property><value>No Gateway Selected</value></relation>\n"
        
        for gateway in sorted {
          gateways += "<relation><property>\(gateway.nodeId.toHexDotFormat(numberOfBytes: 8))</property><value>\(gateway.name)</value></relation>\n"
        }

        contents = contents.replacingOccurrences(of: "%%LOCONET_GATEWAYS%%", with: gateways)

        let memorySpace = OpenLCBMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.cdi.rawValue, isReadOnly: true, description: "")
        memorySpace.memory = [UInt8]()
        memorySpace.memory.append(contentsOf: contents.utf8)
        memorySpace.memory.append(contentsOf: [UInt8](repeating: 0, count: 64))
        memorySpaces[memorySpace.space] = memorySpace
        
        isConfigurationDescriptionInformationProtocolSupported = true
        
        setupConfigurationOptions()
        
      }
      catch {
      }
    }
    
  }

  // MARK: OpenLCBNetworkLayerDelegate Methods
  
  public override func openLCBMessageReceived(message: OpenLCBMessage) {
    
    super.openLCBMessageReceived(message: message)
    
    locoNet?.openLCBMessageReceived(message: message)
    
    switch message.messageTypeIndicator {
    
    case .producerIdentifiedAsCurrentlyValid, .producerIdentifiedAsCurrentlyInvalid, .producerIdentifiedWithValidityUnknown, .producerConsumerEventReport:
      
      if let event = OpenLCBWellKnownEvent(rawValue: message.eventId!) {
        
        switch event {
        case .nodeIsALocoNetGateway:
          
          locoNetGateways[message.sourceNodeId!] = ""
          networkLayer?.sendSimpleNodeInformationRequest(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!)
          
        default:
          break
        }
        
      }

    case .simpleNodeIdentInfoReply:
      
      if let _ = locoNetGateways[message.sourceNodeId!] {
        let node = OpenLCBNode(nodeId: message.sourceNodeId!)
        node.encodedNodeInformation = message.payload
        locoNetGateways[node.nodeId] = node.userNodeName
        reloadCDI()
      }

    case .identifyProducer:
      
      if let event = OpenLCBWellKnownEvent(rawValue: message.eventId!) {
        
        switch event {
        case .nodeIsADCCProgrammingTrack:
          if locoNet!.commandStationType.programmingTrackExists {
            networkLayer?.sendProducerIdentified(sourceNodeId: nodeId, wellKnownEvent: .nodeIsADCCProgrammingTrack, validity: .unknown)
          }
        default:
          break
        }
        
      }
      
    default:
      break
    }
    
  }
  
  // MARK: LocoNetDelegate Methods
  
  @objc public func locoNetInitializationComplete() {
    
    guard let locoNet else {
      return
    }
    
    if locoNet.commandStationType.programmingTrackExists {
      networkLayer?.sendWellKnownEvent(sourceNodeId: nodeId, eventId: .nodeIsADCCProgrammingTrack)
    }
    
  }
  
  @objc public func locoNetMessageReceived(message:LocoNetMessage) {
    
    switch message.messageType {
      
    case .progCmdAccepted:
      break
      
    case .progCmdAcceptedBlind:
      break
      
    case .programmerBusy:
      switch ioState {
      case .idle:
        break
      case .reading:
        locoNet?.readCV(progMode: progMode.locoNetProgrammingMode(isProgrammingTrack: true), cv: self.ioAddress, address: 0)
      case .writing:
        locoNet?.writeCV(progMode: progMode.locoNetProgrammingMode(isProgrammingTrack: true), cv: ioAddress, address: 0, value: cvs.getUInt8(address: ioAddress)!)
      }

    case .progSlotDataP1:
      
      if ioState != .idle {
        
        var errorCode : OpenLCBErrorCode
        
        let pstat = message.message[4]
        
        if (pstat & 0b00000001) == 0b00000001 {
          errorCode = .permanentErrorNoDecoderDetected
        }
        else if (pstat & 0b00000010) == 0b00000010 {
          errorCode = .permanentErrorWriteCVFailed
        }
        else if (pstat & 0b00000100) == 0b00000100 {
          errorCode = .permanentErrorReadCVFailed
        }
        else {
          errorCode = .success
        }
        
      
        switch ioState {
        case .idle:
          break
          
        case .reading:
          if errorCode != .success {
            networkLayer?.sendReadReplyFailure(sourceNodeId: nodeId, destinationNodeId: ioSourceNodeId, addressSpace: cvs.space, startAddress: ioStartAddress, errorCode: errorCode)
            ioState = .idle
          }
          else if let address = message.cvNumber, let value = message.cvValue {
            cvs.setUInt(address: ioAddress, value: value)
            ioAddress += 1
            if ioAddress < ioStartAddress + UInt32(ioCount) {
              locoNet?.readCV(progMode: progMode.locoNetProgrammingMode(isProgrammingTrack: true), cv: self.ioAddress, address: 0)
            }
            else {
              if let data = cvs.getBlock(address: Int(ioStartAddress & OpenLCBProgrammingMode.addressMark), count: Int(ioCount)) {
                networkLayer?.sendReadReply(sourceNodeId: nodeId, destinationNodeId: ioSourceNodeId, addressSpace: cvs.space, startAddress: ioStartAddress, data: data)
              }
              else {
                networkLayer?.sendReadReplyFailure(sourceNodeId: nodeId, destinationNodeId: ioSourceNodeId, addressSpace: cvs.space, startAddress: ioStartAddress, errorCode: .permanentErrorAddressOutOfBounds)
                ioState = .idle
              }
            }
            
          }
        case .writing:
          if errorCode != .success {
            networkLayer?.sendWriteReplyFailure(sourceNodeId: nodeId, destinationNodeId: ioSourceNodeId, addressSpace: cvs.space, startAddress: ioStartAddress, errorCode: errorCode)
            ioState = .idle
          }
          else if let address = message.cvNumber, Int(address) == ioAddress {
            ioAddress += 1
            if ioAddress < ioStartAddress + UInt32(ioCount) {
              locoNet?.writeCV(progMode: progMode.locoNetProgrammingMode(isProgrammingTrack: true), cv: ioAddress, address: 0, value: cvs.getUInt8(address: ioAddress)!)
            }
            else {
              networkLayer?.sendWriteReply(sourceNodeId: nodeId, destinationNodeId: ioSourceNodeId, addressSpace: cvs.space, startAddress: ioStartAddress)
              ioState = .idle
            }
          }
        }
        
      }

    default:
      break
    }
  }

}
