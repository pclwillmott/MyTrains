//
//  OpenLCBProgrammerToolNode.swift
//  MyTrains
//
//  Created by Paul Willmott on 01/08/2023.
//

import Foundation

private enum State {
  case idle
  case gettingMemorySpaceInformation
  case gettingDefaults
  case gettingCV
  case gettingCVs
  case gettingCachedCVs
  case gettingDefault
}

public class OpenLCBProgrammerToolNode : OpenLCBNodeVirtual {
  
  // MARK: Constructors
  
  public override init(nodeId:UInt64) {
    
    self.programmerToolId = Int(nodeId & 0xff)

    super.init(nodeId: nodeId)

    virtualNodeType = MyTrainsVirtualNodeType.programmerToolNode
    
    isDatagramProtocolSupported = true

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
  
  private var currentCV : Int = 0
  
  private var operationState : State = .idle
  
  // MARK: Public Properties
  
  public var programmerToolId : Int
  
  public var cvs : [UInt8] = []
  
  public var numberBase = [UInt8](repeating: 0, count: 1024)
  
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
    }
  }
  
  public var dccTrainNodeId : UInt64 {
    get {
      return _dccTrainNodeId
    }
    set(value) {
      _dccTrainNodeId = value
      operationState = .gettingMemorySpaceInformation
      delegate?.statusUpdate?(ProgrammerTool: self, status: "Getting Memory Space Information")
      networkLayer?.sendGetMemorySpaceInformationRequest(sourceNodeId: nodeId, destinationNodeId: _dccTrainNodeId, wellKnownAddressSpace: .cv)
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
  
  internal override func resetReboot() {
    super.resetReboot()
    programmingTracks = [0:"Programming on the Mainline"]
    programmingTrackId = 0
    programmingMode = 0
    delegate?.programmingTracksUpdated?(programmerTool: self, programmingTracks: programmingTracks)
    networkLayer?.sendIdentifyProducer(sourceNodeId: nodeId, event: .nodeIsADCCProgrammingTrack)
    dccTrainNodes = [:]
    networkLayer?.sendIdentifyProducer(sourceNodeId: nodeId, event: .trainSearchDCCShortAddress)
    networkLayer?.sendIdentifyProducer(sourceNodeId: nodeId, event: .trainSearchDCCLongAddress)
  }
  
  private func nextCachedCV() -> Int? {
    while currentCV < 1024 {
      if cvs[2048 + currentCV] & 0x0f != 0 {
        return currentCV
      }
      currentCV += 1
    }
    return nil
  }

  // MARK: Public Methods

  private let defaultCleanMask : UInt8 = 0b00010000
  private let valueCleanMask   : UInt8 = 0b00000001
  
  private let defaultOffset = 1024
  private let statusOffset  = 2048

  public func isDefaultClean(cvNumber:Int) -> Bool {
    let stat = cvs[statusOffset + cvNumber]
    return (stat & defaultCleanMask) == defaultCleanMask
  }
  
  public func isValueClean(cvNumber:Int) -> Bool {
    let stat = cvs[statusOffset + cvNumber]
    return (stat & valueCleanMask) == valueCleanMask
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
  
  public func getDefaultValue(cvNumber:Int) {
    
    if isDefaultSupported {
      
      operationState = .gettingDefault
      
      currentCV = defaultOffset + cvNumber
      
      networkLayer?.sendNodeMemoryReadRequest(sourceNodeId: nodeId, destinationNodeId: dccTrainNodeId, addressSpace: OpenLCBNodeMemoryAddressSpace.cv.rawValue, startAddress: currentCV, numberOfBytesToRead: 1)
      
    }
    
  }
  
  public var targetNodeId : UInt64? {
    var result = programmingTrackId == 0 ? dccTrainNodeId : programmingTrackId
    return result == 0 ? nil : result
  }
  
  public func getValue(cvNumber:Int) {
    
    guard let target = targetNodeId else {
      return
    }
    
    operationState = .gettingCV
    
    currentCV = cvNumber
    
    networkLayer?.sendNodeMemoryReadRequest(sourceNodeId: nodeId, destinationNodeId: target, addressSpace: OpenLCBNodeMemoryAddressSpace.cv.rawValue, startAddress: currentCV, numberOfBytesToRead: 1)
    
  }
  
  public func getAllValues() {
    
    guard let target = targetNodeId else {
      return
    }
    
    operationState = .gettingCVs
    
    currentCV = 0

    delegate?.statusUpdate?(ProgrammerTool: self, status: "Getting CV#\(currentCV + 1)")
    
    networkLayer?.sendNodeMemoryReadRequest(sourceNodeId: nodeId, destinationNodeId: target, addressSpace: OpenLCBNodeMemoryAddressSpace.cv.rawValue, startAddress: currentCV, numberOfBytesToRead: 1)

  }
  
  public func setDefaultValue(cvNumber:Int) {
    
    if isDefaultSupported {
      
      let defaultValue = cvs[defaultOffset + cvNumber]
      
      setDefaultStatus(cvNumber: cvNumber, isClean: true)
      
      networkLayer?.sendNodeMemoryWriteRequest(sourceNodeId: nodeId, destinationNodeId: dccTrainNodeId, addressSpace: OpenLCBNodeMemoryAddressSpace.cv.rawValue, startAddress: defaultOffset + cvNumber, dataToWrite: [defaultValue])
      
      networkLayer?.sendNodeMemoryWriteRequest(sourceNodeId: nodeId, destinationNodeId: dccTrainNodeId, addressSpace: OpenLCBNodeMemoryAddressSpace.cv.rawValue, startAddress: statusOffset + cvNumber, dataToWrite: [cvs[statusOffset + cvNumber]])
      
      delegate?.cvDataUpdated?(programmerTool: self, cvData: cvs)
      
    }
    
  }
  
  public func setValue(cvNumber:Int) {
    
    guard let target = targetNodeId else {
      return
    }
    
    let value = cvs[cvNumber]
      
    networkLayer?.sendNodeMemoryWriteRequest(sourceNodeId: nodeId, destinationNodeId: target, addressSpace: OpenLCBNodeMemoryAddressSpace.cv.rawValue, startAddress: cvNumber, dataToWrite: [value])
    
    if isDefaultSupported {
      
      setValueStatus(cvNumber: cvNumber, isClean: true)
      
      if !isDefaultClean(cvNumber: cvNumber) {
        cvs[defaultOffset + cvNumber] = value
        setDefaultValue(cvNumber: cvNumber)
      }
      else {
        networkLayer?.sendNodeMemoryWriteRequest(sourceNodeId: nodeId, destinationNodeId: dccTrainNodeId, addressSpace: OpenLCBNodeMemoryAddressSpace.cv.rawValue, startAddress: statusOffset + cvNumber, dataToWrite: [cvs[statusOffset + cvNumber]])
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
  
  // MARK: OpenLCBNetworkLayerDelegate Methods

  public override func openLCBMessageReceived(message: OpenLCBMessage) {
    
    super.openLCBMessageReceived(message: message)
  
    switch message.messageTypeIndicator {
    
    case .datagramRejected:
      
      if message.destinationNodeId! == nodeId {
        
        switch operationState {
          
        case .idle:
          break
          
        case .gettingMemorySpaceInformation:
          operationState = .idle
          delegate?.statusUpdate?(ProgrammerTool: self, status: "Get Memory Space Information Failed: \(message.errorCode)")
          
        case .gettingDefaults:
          operationState = .idle
          delegate?.statusUpdate?(ProgrammerTool: self, status: "Get Default & Status Values Failed: \(message.errorCode)")

        case .gettingDefault:
          operationState = .idle
          delegate?.statusUpdate?(ProgrammerTool: self, status: "Get Default Value Failed: \(message.errorCode)")

        case .gettingCV, .gettingCVs, .gettingCachedCVs:
          operationState = .idle
          delegate?.statusUpdate?(ProgrammerTool: self, status: "Get CV Failed: \(message.errorCode)")

        }
        
      }
      
    case .datagram:
      
      if message.destinationNodeId! == nodeId, let datagramType = message.datagramType {
        
        switch datagramType {
          
        case .getAddressSpaceInformationReply, .getAddressSpaceInformationReplyLowAddressPresent:
          
          if operationState == .gettingMemorySpaceInformation {
            
            let tempNode = OpenLCBNode(nodeId: dccTrainNodeId)
            
            if let info = tempNode.addAddressSpaceInformation(message: message) {
              cvs = []
              dataSize = info.highestAddress + 1
              if dataSize == 1024 * 3 {
                cvs = []
                currentAddress = UInt32(0)
                operationState = .gettingDefaults
                networkLayer?.sendNodeMemoryReadRequest(sourceNodeId: nodeId, destinationNodeId: dccTrainNodeId, addressSpace: OpenLCBNodeMemoryAddressSpace.cv.rawValue, startAddress: Int(currentAddress), numberOfBytesToRead: 64)
              }
              else {
                currentCV = 0
                operationState = .gettingCVs
                delegate?.statusUpdate?(ProgrammerTool: self, status: "Getting CV #\(currentCV + 1)")
                networkLayer?.sendNodeMemoryReadRequest(sourceNodeId: nodeId, destinationNodeId: dccTrainNodeId, addressSpace: OpenLCBNodeMemoryAddressSpace.cv.rawValue, startAddress: currentCV, numberOfBytesToRead: 1)
              }
            }
            
          }
          
        case .readReplyGeneric:
          
          if message.payload[6] == OpenLCBNodeMemoryAddressSpace.cv.rawValue {
            
            var data = message.payload
            data.removeFirst(7)

            switch operationState {
            
            case .gettingCVs:
              
              cvs[currentCV] = data[0]
              
              setValueStatus(cvNumber: currentCV, isClean: true)
              
              networkLayer?.sendNodeMemoryWriteRequest(sourceNodeId: nodeId, destinationNodeId: dccTrainNodeId, addressSpace: OpenLCBNodeMemoryAddressSpace.cv.rawValue, startAddress: currentCV, dataToWrite: [data[0]])
              
              if isDefaultSupported {
                
                if !isDefaultClean(cvNumber: currentCV) {
                  
                  cvs[defaultOffset + currentCV] = data[0]
                  
                  setDefaultStatus(cvNumber: currentCV, isClean: true)
                  
                  networkLayer?.sendNodeMemoryWriteRequest(sourceNodeId: nodeId, destinationNodeId: dccTrainNodeId, addressSpace: OpenLCBNodeMemoryAddressSpace.cv.rawValue, startAddress: defaultOffset + currentCV, dataToWrite: [data[0]])
                  
                }
                
                networkLayer?.sendNodeMemoryWriteRequest(sourceNodeId: nodeId, destinationNodeId: dccTrainNodeId, addressSpace: OpenLCBNodeMemoryAddressSpace.cv.rawValue, startAddress: statusOffset + currentCV, dataToWrite: [cvs[statusOffset + currentCV]])
                
              }
              
              delegate?.cvDataUpdated?(programmerTool: self, cvData: cvs)

              if currentCV == 255 {
                operationState = .idle
                delegate?.statusUpdate?(ProgrammerTool: self, status: "")
              }
              else {
                operationState = .gettingCVs
                currentCV += 1
                delegate?.statusUpdate?(ProgrammerTool: self, status: "Getting CV #\(currentCV + 1)")
                networkLayer?.sendNodeMemoryReadRequest(sourceNodeId: nodeId, destinationNodeId: targetNodeId!, addressSpace: OpenLCBNodeMemoryAddressSpace.cv.rawValue, startAddress: currentCV, numberOfBytesToRead: 1)
              }
              
            case .gettingCachedCVs:
              
              cvs[currentCV] = data[0]
              
              currentCV += 1
              
              if let _ = nextCachedCV() {
                operationState = .gettingCachedCVs
                delegate?.statusUpdate?(ProgrammerTool: self, status: "Getting CV #\(currentCV + 1)")
                networkLayer?.sendNodeMemoryReadRequest(sourceNodeId: nodeId, destinationNodeId: dccTrainNodeId, addressSpace: OpenLCBNodeMemoryAddressSpace.cv.rawValue, startAddress: currentCV, numberOfBytesToRead: 1)
              }
              else {
                operationState = .idle
                delegate?.cvDataUpdated?(programmerTool: self, cvData: cvs)
                delegate?.statusUpdate?(ProgrammerTool: self, status: "")
              }

            case .gettingDefaults:
              
              cvs.append(contentsOf: data)
              
              delegate?.statusUpdate?(ProgrammerTool: self, status: "\(cvs.count) bytes read")
              
              currentAddress += UInt32(data.count)
              
              let bytesToGo = min(64, dataSize - UInt32(cvs.count))
              
              if bytesToGo > 0 {
                networkLayer?.sendNodeMemoryReadRequest(sourceNodeId: nodeId, destinationNodeId: dccTrainNodeId, addressSpace: OpenLCBNodeMemoryAddressSpace.cv.rawValue, startAddress: Int(currentAddress), numberOfBytesToRead: UInt8(bytesToGo))
              }
              else {
                operationState = .idle
                delegate?.cvDataUpdated?(programmerTool: self, cvData: cvs)
                delegate?.statusUpdate?(ProgrammerTool: self, status: "")
                currentCV = 0
                if let _ = nextCachedCV() {
                  operationState = .gettingCachedCVs
                  delegate?.statusUpdate?(ProgrammerTool: self, status: "Getting CV #\(currentCV + 1)")
                  networkLayer?.sendNodeMemoryReadRequest(sourceNodeId: nodeId, destinationNodeId: dccTrainNodeId, addressSpace: OpenLCBNodeMemoryAddressSpace.cv.rawValue, startAddress: currentCV, numberOfBytesToRead: 1)
                }
              }
              
            case .gettingDefault:
              operationState = .idle
              cvs[currentCV] = data[0]
              delegate?.cvDataUpdated?(programmerTool: self, cvData: cvs)
              delegate?.statusUpdate?(ProgrammerTool: self, status: "")
              
            case .gettingCV:
              
              operationState = .idle
              
              cvs[currentCV] = data[0]
              
              setValueStatus(cvNumber: currentCV, isClean: true)
              
              networkLayer?.sendNodeMemoryWriteRequest(sourceNodeId: nodeId, destinationNodeId: dccTrainNodeId, addressSpace: OpenLCBNodeMemoryAddressSpace.cv.rawValue, startAddress: currentCV, dataToWrite: [data[0]])
              
              if isDefaultSupported {
                
                if !isDefaultClean(cvNumber: currentCV) {
                  
                  cvs[defaultOffset + currentCV] = data[0]
                  
                  setDefaultStatus(cvNumber: currentCV, isClean: true)
                  
                  networkLayer?.sendNodeMemoryWriteRequest(sourceNodeId: nodeId, destinationNodeId: dccTrainNodeId, addressSpace: OpenLCBNodeMemoryAddressSpace.cv.rawValue, startAddress: defaultOffset + currentCV, dataToWrite: [data[0]])
                  
                }
                
                networkLayer?.sendNodeMemoryWriteRequest(sourceNodeId: nodeId, destinationNodeId: dccTrainNodeId, addressSpace: OpenLCBNodeMemoryAddressSpace.cv.rawValue, startAddress: statusOffset + currentCV, dataToWrite: [cvs[statusOffset + currentCV]])
                
              }
              
              delegate?.cvDataUpdated?(programmerTool: self, cvData: cvs)
              delegate?.statusUpdate?(ProgrammerTool: self, status: "")

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
