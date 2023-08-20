//
//  OpenLCBProgrammerToolNode.swift
//  MyTrains
//
//  Created by Paul Willmott on 01/08/2023.
//

import Foundation

private enum IOState {
  case idle
  case readingMemorySpaceInformationWaitingForAck
  case readingMemorySpaceInformationWaitingForReply
  case readingDefaultWaitingForAck
  case readingDefaultWaitingForReply
  case writingDefaultWaitingForAck
  case writingDefaultWaitingForReply
  case readingDefaultsWaitingForAck
  case readingDefaultsWaitingForReply
  case readingCVWaitingForAck
  case readingCVWaitingForReply
  case readingCVWaitingForWriteBackAck
  case readingCVWaitingForWriteBackReply
  case writingCVWaitingForAck
  case writingCVWaitingForReply
  case writingCVWaitingForWriteBackAck
  case writingCVWaitingForWriteBackReply
}

public class OpenLCBProgrammerToolNode : OpenLCBNodeVirtual {
  
  // MARK: Constructors
  
  public override init(nodeId:UInt64) {
    
    self.programmerToolId = Int(nodeId & 0xff)

    numberBase = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.cv.rawValue, defaultMemorySize: 1024, isReadOnly: false, description: "")
    
    super.init(nodeId: nodeId)

    virtualNodeType = MyTrainsVirtualNodeType.programmerToolNode
    
    isDatagramProtocolSupported = true

    numberBase.delegate = self
    
    memorySpaces[numberBase.space] = numberBase
    
    if !memorySpacesInitialized {
      resetToFactoryDefaults()
    }

  }
  
  // MARK: Private Properties
  
  private var programmingTracks : [UInt64:String] = [:]
  
  private var dccTrainNodes : [UInt64:String] = [:]
  
  private var _delegate : OpenLCBProgrammerToolDelegate?
  
  private var _programmingTrackId : UInt64 = 0
  
  private var _dccTrainNodeId : UInt64 = 0
  
  private var dataSize : UInt32 = 0
  
  private var currentAddress : UInt32 = 0
  
  private var ioAddress : Int = 0
  
  private var ioCount : Int = 0
  
  private var ioStartAddress : UInt32 = 0
  
  private var ioState : IOState = .idle
  
  internal var numberBase : OpenLCBMemorySpace

  // MARK: Public Properties
  
  public var programmerToolId : Int
  
  public var cvs : [UInt8] = []
  
  public var isDefaultSupported : Bool {
    return cvs.count == 1024 * 3
  }
  
  public var programmingMode : Int = 0 {
    didSet {
      delegate?.programmingModeUpdated?(ProgrammerTool: self, programmingMode: programmingMode)
    }
  }
  
  public var delegate : OpenLCBProgrammerToolDelegate? {
    get {
      return _delegate
    }
    set(value) {
      _delegate = value
      resetReboot()
    }
  }
  
  public var programmingTrackId : UInt64 {
    get {
      return _programmingTrackId
    }
    set(value) {
      _programmingTrackId = value
      delegate?.statusUpdate?(ProgrammerTool: self, status: "")
    }
  }
  
  public var dccTrainNodeId : UInt64 {
    get {
      return _dccTrainNodeId
    }
    set(value) {
      _dccTrainNodeId = value
      ioState = .readingMemorySpaceInformationWaitingForAck
      delegate?.statusUpdate?(ProgrammerTool: self, status: "")
      networkLayer?.sendGetMemorySpaceInformationRequest(sourceNodeId: nodeId, destinationNodeId: _dccTrainNodeId, wellKnownAddressSpace: .cv)
    }
  }
  
  public let defaultOffset = 1024
  public let statusOffset  = 2048

  // MARK: Private Methods
  
  private var targetNodeId : UInt64? {
    let result = programmingTrackId == 0 ? dccTrainNodeId : programmingTrackId
    return result == 0 ? nil : result
  }
  
  private var progModeMask : UInt32? {
    
    if programmingTrackId == 0 {
      return OpenLCBProgrammingMode.defaultProgrammingMode.rawValue
    }
    
    switch programmingMode {
    case 0:
      return OpenLCBProgrammingMode.defaultProgrammingMode.rawValue
    case 1:
      return OpenLCBProgrammingMode.directModeProgramming.rawValue
    case 2:
      return OpenLCBProgrammingMode.pagedModeProgramming.rawValue
    default:
      return nil
    }
    
  }
  
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
  
  internal override func resetReboot() {
    super.resetReboot()
    programmingTracks = [0:"Programming on the Main"]
    programmingTrackId = 0
    programmingMode = 0
    delegate?.programmingTracksUpdated?(programmerTool: self, programmingTracks: programmingTracks)
    networkLayer?.sendIdentifyProducer(sourceNodeId: nodeId, event: .nodeIsADCCProgrammingTrack)
    dccTrainNodes = [:]
    networkLayer?.sendIdentifyProducer(sourceNodeId: nodeId, event: .trainSearchDCCShortAddress)
    networkLayer?.sendIdentifyProducer(sourceNodeId: nodeId, event: .trainSearchDCCLongAddress)
  }
  
  // MARK: Public Methods

  private let defaultCleanMask     : UInt8 = 0b00010000
  private let valueCleanMask       : UInt8 = 0b00000001
  private let valueWriteFailedMask : UInt8 = 0b00000010
  
  public func isDefaultClean(cvNumber:Int) -> Bool {
    let stat = cvs[statusOffset + cvNumber]
    return (stat & defaultCleanMask) == defaultCleanMask
  }
  
  public func isValueClean(cvNumber:Int) -> Bool {
    let stat = cvs[statusOffset + cvNumber]
    return (stat & valueCleanMask) == valueCleanMask
  }

  public func isValueWriteFailure(cvNumber:Int) -> Bool {
    let stat = cvs[statusOffset + cvNumber]
    return (stat & valueWriteFailedMask) == valueWriteFailedMask
  }

  public func setDefaultStatus(cvNumber:Int, isClean:Bool) {
    var stat = cvs[statusOffset + cvNumber]
    stat &= ~defaultCleanMask
    stat |= isClean ? defaultCleanMask : 0
    cvs[statusOffset + cvNumber] = stat
  }
  
  public func setValueStatus(cvNumber:Int, isClean:Bool) {
    var stat = cvs[statusOffset + cvNumber]
    stat &= ~valueCleanMask
    stat |= isClean ? valueCleanMask : 0
    cvs[statusOffset + cvNumber] = stat
  }

  public func setValueWriteStatus(cvNumber:Int, isFailure:Bool) {
    var stat = cvs[statusOffset + cvNumber]
    stat &= ~valueWriteFailedMask
    stat |= isFailure ? valueWriteFailedMask : 0
    cvs[statusOffset + cvNumber] = stat
  }

  public func getDefaultValue(cvNumber:Int) {
    
    if isDefaultSupported {
      
      ioState = .readingDefaultWaitingForAck
      
      ioAddress = defaultOffset + cvNumber
      
      ioStartAddress = UInt32(ioAddress)
      
      ioCount = 1
      
      networkLayer?.sendNodeMemoryReadRequest(sourceNodeId: nodeId, destinationNodeId: dccTrainNodeId, addressSpace: OpenLCBNodeMemoryAddressSpace.cv.rawValue, startAddress: ioAddress, numberOfBytesToRead: 1)
      
    }
    
  }
  
  public func getValue(cvNumber:Int) {
    
    guard let target = targetNodeId, let progModeMask else {
      return
    }
    
    ioState = .readingCVWaitingForAck
    
    ioAddress = cvNumber
    
    ioStartAddress = UInt32(cvNumber) | progModeMask
    
    ioCount = 1

    delegate?.statusUpdate?(ProgrammerTool: self, status: "")
    delegate?.statusUpdate?(ProgrammerTool: self, status: "Get CV\(ioAddress + 1): ")

    networkLayer?.sendNodeMemoryReadRequest(sourceNodeId: nodeId, destinationNodeId: target, addressSpace: OpenLCBNodeMemoryAddressSpace.cv.rawValue, startAddress: Int(ioStartAddress), numberOfBytesToRead: 1)

  }
  
  public func getAllValues() {
    
    guard let target = targetNodeId, let progModeMask, dccTrainNodeId != 0 else {
      return
    }
    
    delegate?.statusUpdate?(ProgrammerTool: self, status: "")

    ioState = .readingCVWaitingForAck
    
    ioAddress = 0
    
    ioStartAddress = UInt32(ioAddress) | progModeMask
    
    ioCount = 256
    
    delegate?.statusUpdate?(ProgrammerTool: self, status: "Get CV\(ioAddress + 1): ")
    
    networkLayer?.sendNodeMemoryReadRequest(sourceNodeId: nodeId, destinationNodeId: target, addressSpace: OpenLCBNodeMemoryAddressSpace.cv.rawValue, startAddress: Int(ioStartAddress), numberOfBytesToRead: 1)

  }
  
  public func getAllValuesIndexed() {
    
    guard let target = targetNodeId, let progModeMask, dccTrainNodeId != 0 else {
      return
    }
    
    delegate?.statusUpdate?(ProgrammerTool: self, status: "")

    ioState = .readingCVWaitingForAck
    
    ioAddress = 256
    
    ioStartAddress = UInt32(ioAddress) | progModeMask
    
    ioCount = 256
    
    delegate?.statusUpdate?(ProgrammerTool: self, status: "Get CV\(ioAddress + 1): ")
    
    networkLayer?.sendNodeMemoryReadRequest(sourceNodeId: nodeId, destinationNodeId: target, addressSpace: OpenLCBNodeMemoryAddressSpace.cv.rawValue, startAddress: Int(ioStartAddress), numberOfBytesToRead: 1)

  }

  public func getAllValuesExtended() {
    
    guard let target = targetNodeId, let progModeMask, dccTrainNodeId != 0 else {
      return
    }
    
    delegate?.statusUpdate?(ProgrammerTool: self, status: "")

    ioState = .readingCVWaitingForAck
    
    ioAddress = 512
    
    ioStartAddress = UInt32(ioAddress) | progModeMask
    
    ioCount = 512
    
    delegate?.statusUpdate?(ProgrammerTool: self, status: "Get CV\(ioAddress + 1): ")
    
    networkLayer?.sendNodeMemoryReadRequest(sourceNodeId: nodeId, destinationNodeId: target, addressSpace: OpenLCBNodeMemoryAddressSpace.cv.rawValue, startAddress: Int(ioStartAddress), numberOfBytesToRead: 1)

  }

  public func cancelOperation() {
    if ioState != .idle {
      delegate?.statusUpdate?(ProgrammerTool: self, status: "aborted")
    }
    ioState = .idle
  }
  
  public func setAllValues() {
    
    guard let target = targetNodeId, let progModeMask, dccTrainNodeId != 0 else {
      return
    }

    ioState = .writingCVWaitingForAck
    
    ioAddress = 0
    
    ioStartAddress = UInt32(ioAddress) | progModeMask
    
    ioCount = 256
    
    delegate?.statusUpdate?(ProgrammerTool: self, status: "")
    delegate?.statusUpdate?(ProgrammerTool: self, status: "Set CV\(ioAddress + 1): ")
    
    networkLayer?.sendNodeMemoryWriteRequest(sourceNodeId: nodeId, destinationNodeId: target, addressSpace: OpenLCBNodeMemoryAddressSpace.cv.rawValue, startAddress: Int(ioStartAddress), dataToWrite: [cvs[ioAddress]])

  }

  public func setAllValuesIndexed() {
    
    guard let target = targetNodeId, let progModeMask, dccTrainNodeId != 0 else {
      return
    }

    ioState = .writingCVWaitingForAck
    
    ioAddress = 256
    
    ioStartAddress = UInt32(ioAddress) | progModeMask
    
    ioCount = 256
    
    delegate?.statusUpdate?(ProgrammerTool: self, status: "")
    delegate?.statusUpdate?(ProgrammerTool: self, status: "Set CV\(ioAddress + 1): ")
    
    networkLayer?.sendNodeMemoryWriteRequest(sourceNodeId: nodeId, destinationNodeId: target, addressSpace: OpenLCBNodeMemoryAddressSpace.cv.rawValue, startAddress: Int(ioStartAddress), dataToWrite: [cvs[ioAddress]])

  }

  public func setAllValuesExtended() {
    
    guard let target = targetNodeId, let progModeMask, dccTrainNodeId != 0 else {
      return
    }

    ioState = .writingCVWaitingForAck
    
    ioAddress = 512
    
    ioStartAddress = UInt32(ioAddress) | progModeMask
    
    ioCount = 512
    
    delegate?.statusUpdate?(ProgrammerTool: self, status: "")
    delegate?.statusUpdate?(ProgrammerTool: self, status: "Set CV\(ioAddress + 1): ")
    
    networkLayer?.sendNodeMemoryWriteRequest(sourceNodeId: nodeId, destinationNodeId: target, addressSpace: OpenLCBNodeMemoryAddressSpace.cv.rawValue, startAddress: Int(ioStartAddress), dataToWrite: [cvs[ioAddress]])

  }

  public func setNextCV() {
    
    guard let target = targetNodeId else {
      return
    }
    
    ioAddress += 1
    
    if ioAddress == 6 {
      setValueWriteStatus(cvNumber: ioAddress, isFailure: true)
      ioAddress += 1
    }
    if ioAddress == 7  {
      setValueWriteStatus(cvNumber: ioAddress, isFailure: true)
      ioAddress += 1
    }

    if ioAddress < Int(ioStartAddress & OpenLCBProgrammingMode.addressMask) + ioCount {
      
      ioState = .writingCVWaitingForAck
      
      delegate?.statusUpdate?(ProgrammerTool: self, status: "Set CV\(ioAddress + 1): ")
      
      networkLayer?.sendNodeMemoryWriteRequest(sourceNodeId: nodeId, destinationNodeId: target, addressSpace: OpenLCBNodeMemoryAddressSpace.cv.rawValue, startAddress: ioAddress | Int(progModeMask!), dataToWrite: [cvs[ioAddress]])

    }
    else {
      ioState = .idle
    }
    
  }

  public func getNextCV() {
    
    guard let target = targetNodeId else {
      return
    }
    
    ioAddress += 1
    
    if ioAddress < Int(ioStartAddress & OpenLCBProgrammingMode.addressMask) + ioCount {
      ioState = .readingCVWaitingForAck
      
      delegate?.statusUpdate?(ProgrammerTool: self, status: "Get CV\(ioAddress + 1): ")
      
      networkLayer?.sendNodeMemoryReadRequest(sourceNodeId: nodeId, destinationNodeId: target, addressSpace: OpenLCBNodeMemoryAddressSpace.cv.rawValue, startAddress: ioAddress | Int(progModeMask!), numberOfBytesToRead: 1)

    }
    else {
      ioState = .idle
    }
    
  }
  
  public func setDefaultValue(cvNumber:Int) {
    
    if isDefaultSupported {
      
      let defaultValue = cvs[defaultOffset + cvNumber]
      
      setDefaultStatus(cvNumber: cvNumber, isClean: true)
      
      networkLayer?.sendNodeMemoryWriteRequest(sourceNodeId: nodeId, destinationNodeId: dccTrainNodeId, addressSpace: OpenLCBNodeMemoryAddressSpace.cv.rawValue, startAddress: defaultOffset + cvNumber, dataToWrite: [defaultValue])
      
      delegate?.cvDataUpdated?(programmerTool: self, cvData: cvs)
      
    }
    
  }
  
  public func setValue(cvNumber:Int) {
    
    guard let target = targetNodeId, let progModeMask else {
      return
    }
    
    ioState = .writingCVWaitingForAck
    
    ioAddress = cvNumber
    
    ioStartAddress = UInt32(ioAddress) | progModeMask
    
    ioCount = 1
    
    let value = cvs[cvNumber]

    delegate?.statusUpdate?(ProgrammerTool: self, status: "")
    delegate?.statusUpdate?(ProgrammerTool: self, status: "Set CV\(ioAddress + 1): ")

    networkLayer?.sendNodeMemoryWriteRequest(sourceNodeId: nodeId, destinationNodeId: target, addressSpace: OpenLCBNodeMemoryAddressSpace.cv.rawValue, startAddress: Int(ioStartAddress), dataToWrite: [value])
    
    if isDefaultSupported {
      
      setValueStatus(cvNumber: cvNumber, isClean: true)
      
      if !isDefaultClean(cvNumber: cvNumber) {
        cvs[defaultOffset + cvNumber] = value
        setDefaultStatus(cvNumber: cvNumber, isClean: true)
      }
      
      delegate?.cvDataUpdated?(programmerTool: self, cvData: cvs)
      
    }

  }
  
  public func setValueToDefault(cvNumber:Int) {
    
    if isDefaultSupported {
      
      cvs[cvNumber] = cvs[defaultOffset + cvNumber]
      
      setValue(cvNumber: cvNumber)
      
    }
    
  }
  
  public func getNumberBase(cvNumber:Int) -> UInt8? {
    return numberBase.getUInt8(address: cvNumber)
  }
  
  public func setNumberBase(cvNumber:Int, value:UInt8) {
    numberBase.setUInt(address: cvNumber, value: value)
    numberBase.save()
  }
  
  // MARK: OpenLCBNetworkLayerDelegate Methods

  public override func openLCBMessageReceived(message: OpenLCBMessage) {
    
    super.openLCBMessageReceived(message: message)
  
    switch message.messageTypeIndicator {
    
    case .datagramReceivedOK:
      
      if message.destinationNodeId! == nodeId {
        
        switch ioState {
        case .readingMemorySpaceInformationWaitingForAck:
          ioState = .readingMemorySpaceInformationWaitingForReply
        case .readingDefaultWaitingForAck:
          ioState = .writingDefaultWaitingForReply
        case .writingDefaultWaitingForAck:
          ioState = .writingDefaultWaitingForReply
        case .readingCVWaitingForAck:
          ioState = .readingCVWaitingForReply
        case .writingCVWaitingForAck:
          ioState = .writingCVWaitingForReply
        case .readingDefaultsWaitingForAck:
          ioState = .readingDefaultsWaitingForReply
        case .readingCVWaitingForWriteBackAck:
          ioState = .readingCVWaitingForWriteBackReply
        case .writingCVWaitingForWriteBackAck:
          ioState = .writingCVWaitingForWriteBackReply
        default:
          break
        }
        
      }
      
    case .datagramRejected:
      
      if message.destinationNodeId! == nodeId {
        
        switch ioState {
        case .readingMemorySpaceInformationWaitingForAck:
          ioState = .idle
          delegate?.statusUpdate?(ProgrammerTool: self, status: "Get Memory Space Information Failed: \(message.errorCode)")
        case .readingDefaultWaitingForAck:
          ioState = .idle
          delegate?.statusUpdate?(ProgrammerTool: self, status: "Get Default Value Failed: \(message.errorCode)")
       case .writingDefaultWaitingForAck:
          ioState = .idle
          delegate?.statusUpdate?(ProgrammerTool: self, status: "Set Default Value Failed: \(message.errorCode)")
        case .readingCVWaitingForAck:
          ioState = .idle
          delegate?.statusUpdate?(ProgrammerTool: self, status: "Get CV #\(ioAddress + 1) Failed: \(message.errorCode)")
        case .writingCVWaitingForAck:
          ioState = .idle
          delegate?.statusUpdate?(ProgrammerTool: self, status: "Set CV #\(ioAddress + 1) Failed: \(message.errorCode)")
        case .readingDefaultsWaitingForAck:
          ioState = .idle
          delegate?.statusUpdate?(ProgrammerTool: self, status: "Get Defaults Failed: \(message.errorCode)")
        case .readingCVWaitingForWriteBackAck:
          ioState = .idle
          delegate?.statusUpdate?(ProgrammerTool: self, status: "Get CV #\(ioAddress + 1) Write-Back Failed: \(message.errorCode)")
        default:
          break
        }
        
      }
      
    case .datagram:
      
      if message.destinationNodeId! == nodeId, let datagramType = message.datagramType {
        
        switch datagramType {
          
        case .getAddressSpaceInformationReply, .getAddressSpaceInformationReplyLowAddressPresent:
          
          if ioState == .readingMemorySpaceInformationWaitingForReply {
            
            let tempNode = OpenLCBNode(nodeId: dccTrainNodeId)
            
            if let info = tempNode.addAddressSpaceInformation(message: message) {
              dataSize = info.realHighestAddress + 1
              if dataSize == 1024 * 3 {
                cvs = []
                currentAddress = UInt32(0)
                ioState = .readingDefaultsWaitingForAck
                networkLayer?.sendNodeMemoryReadRequest(sourceNodeId: nodeId, destinationNodeId: dccTrainNodeId, addressSpace: OpenLCBNodeMemoryAddressSpace.cv.rawValue, startAddress: Int(currentAddress), numberOfBytesToRead: 64)
              }
              else {
                cvs = [UInt8](repeating: 0, count: 1024)
                getAllValues()
              }
            }
            
          }
          
        case .readReplyFailureGeneric:

          if ioState != .idle {
            delegate?.statusUpdate?(ProgrammerTool: self, status: "failed - \(message.rwReplyFailureErrorCode.userMessage)")
            getNextCV()
          }
          
        case .writeReplyFailureGeneric:
          
          if ioState != .idle {
            setValueWriteStatus(cvNumber: ioAddress, isFailure: true)
            delegate?.cvDataUpdated?(programmerTool: self, cvData: cvs)
            delegate?.statusUpdate?(ProgrammerTool: self, status: "failed - \(message.rwReplyFailureErrorCode.userMessage)")
            setNextCV()
          }
        
        case .writeReplyGeneric:
          
          if message.payload[6] == OpenLCBNodeMemoryAddressSpace.cv.rawValue {
            
            switch ioState {
              
            case .writingDefaultWaitingForReply:
              ioState = .idle
              delegate?.statusUpdate?(ProgrammerTool: self, status: "")
            
            case .writingCVWaitingForReply:
              setValueWriteStatus(cvNumber: ioAddress, isFailure: false)
              delegate?.cvDataUpdated?(programmerTool: self, cvData: cvs)
              delegate?.statusUpdate?(ProgrammerTool: self, status: "success")
              
              ioState = .writingCVWaitingForWriteBackAck
              
              networkLayer?.sendNodeMemoryWriteRequest(sourceNodeId: nodeId, destinationNodeId: dccTrainNodeId, addressSpace: OpenLCBNodeMemoryAddressSpace.cv.rawValue, startAddress: ioAddress, dataToWrite: [cvs[ioAddress]])
            
            case .writingCVWaitingForWriteBackReply:
              setNextCV()

            case .readingCVWaitingForWriteBackReply:
              getNextCV()
              
            default:
              break
            }
            
          }
          
        case .readReplyGeneric:
          
          if message.payload[6] == OpenLCBNodeMemoryAddressSpace.cv.rawValue {
            
            var data = message.payload
            data.removeFirst(7)

            switch ioState {
              
            case .readingDefaultWaitingForReply:
              ioState = .idle
              cvs[ioAddress] = data[0]
              delegate?.cvDataUpdated?(programmerTool: self, cvData: cvs)
              delegate?.statusUpdate?(ProgrammerTool: self, status: "success")
              
            case .readingDefaultsWaitingForReply:
              
              cvs.append(contentsOf: data)
              
              currentAddress += UInt32(data.count)
              
              let bytesToGo = min(64, dataSize - UInt32(cvs.count))
              
              if bytesToGo > 0 {
                ioState = .readingDefaultsWaitingForAck
                networkLayer?.sendNodeMemoryReadRequest(sourceNodeId: nodeId, destinationNodeId: dccTrainNodeId, addressSpace: OpenLCBNodeMemoryAddressSpace.cv.rawValue, startAddress: Int(currentAddress), numberOfBytesToRead: UInt8(bytesToGo))
              }
              else {
                ioState = .idle
                delegate?.cvDataUpdated?(programmerTool: self, cvData: cvs)
              }

            case .readingCVWaitingForReply:
              
              cvs[ioAddress] = data[0]
              
              setValueStatus(cvNumber: ioAddress, isClean: true)
              
              delegate?.cvDataUpdated?(programmerTool: self, cvData: cvs)
              delegate?.statusUpdate?(ProgrammerTool: self, status: "success")

              if message.sourceNodeId! == programmingTrackId {
                
                ioState = .readingCVWaitingForWriteBackReply
                
                networkLayer?.sendNodeMemoryWriteRequest(sourceNodeId: nodeId, destinationNodeId: dccTrainNodeId, addressSpace: OpenLCBNodeMemoryAddressSpace.cv.rawValue, startAddress: ioAddress, dataToWrite: [data[0]])
                
                if isDefaultSupported && !isDefaultClean(cvNumber: ioAddress) {
                  cvs[defaultOffset + ioAddress] = data[0]
                  setDefaultStatus(cvNumber: ioAddress, isClean: true)
                }
                
              }
              else {
                getNextCV()
              }
              
            default:
              break
            }
            
          }
          
        default:
          break
        }
        
      }
      
    case .simpleNodeIdentInfoReply:
      
      if let _ = programmingTracks[message.sourceNodeId!] {
        
        let node = OpenLCBNode(nodeId: message.sourceNodeId!)
        
        node.encodedNodeInformation = message.payload
        
        programmingTracks[node.nodeId] = node.userNodeName
        
        _delegate?.programmingTracksUpdated?(programmerTool: self, programmingTracks: programmingTracks)
        
      }

      if let _ = dccTrainNodes[message.sourceNodeId!] {
        
        let node = OpenLCBNode(nodeId: message.sourceNodeId!)
        
        node.encodedNodeInformation = message.payload
        
        dccTrainNodes[node.nodeId] = node.userNodeName
        
        _delegate?.dccTrainsUpdated?(programmerTool: self, dccTrainNodes: dccTrainNodes)
      }

    case .producerIdentifiedAsCurrentlyValid, .producerIdentifiedAsCurrentlyInvalid, .producerIdentifiedWithValidityUnknown:
      
      if let event = OpenLCBWellKnownEvent(rawValue: message.eventId!) {
        
        switch event {
          
        case .nodeIsADCCProgrammingTrack:
          
          programmingTracks[message.sourceNodeId!] = ""
          
          networkLayer?.sendSimpleNodeInformationRequest(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!)
        
        case .trainSearchDCCShortAddress, .trainSearchDCCLongAddress:
          
          dccTrainNodes[message.sourceNodeId!] = ""
          
          networkLayer?.sendSimpleNodeInformationRequest(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!)

        default:
          break
        }
        
      }
      
    default:
      break
    }
    
  }

}
