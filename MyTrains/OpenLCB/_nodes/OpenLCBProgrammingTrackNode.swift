//
//  OpenLCBProgrammingTrackNode.swift
//  MyTrains
//
//  Created by Paul Willmott on 01/08/2023.
//

import Foundation

private enum IOState {
  case idle
  case readingCVWaitingForAck
  case writingCVWaitingForAck
  case readingCVWaitingForResult
  case writingCVWaitingForResult
}

public class OpenLCBProgrammingTrackNode : OpenLCBNodeVirtual, LocoNetGatewayDelegate {
  
  // MARK: Constructors
  
  public override init(nodeId:UInt64) {
    
    let cvSize = numberOfCVs
    
    cvs = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.cv.rawValue, defaultMemorySize: cvSize, isReadOnly: false, description: "")
        
    super.init(nodeId: nodeId)

    var configurationSize = 0
    
    initSpaceAddress(&addressLocoNetGateway, 8, &configurationSize)
    initSpaceAddress(&addressDeleteFromRoster, 1, &configurationSize)

    configuration = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, defaultMemorySize: configurationSize, isReadOnly: false, description: "")
    
    if let configuration {
      
      virtualNodeType = MyTrainsVirtualNodeType.programmingTrackNode
      
      eventsConsumed = []
      
      eventsProduced = [
        OpenLCBWellKnownEvent.nodeIsADCCProgrammingTrack.rawValue
      ]
      
      eventsToSendAtStartup = [
        OpenLCBWellKnownEvent.nodeIsADCCProgrammingTrack.rawValue
      ]
      
      isDatagramProtocolSupported = true
      
      isIdentificationSupported = true
      
      isSimpleNodeInformationProtocolSupported = true
      
      configuration.delegate = self
      
      memorySpaces[configuration.space] = configuration
      
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressLocoNetGateway)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressDeleteFromRoster)
      
      cvs?.delegate = self
      
      memorySpaces[cvs!.space] = cvs!
      
      for cv in 0 ... numberOfCVs - 1 {
        registerVariable(space: OpenLCBNodeMemoryAddressSpace.cv.rawValue, address: cv)
      }
      
      if !memorySpacesInitialized {
        resetToFactoryDefaults()
      }
      
      cdiFilename = "MyTrains DCC Programming Track"
      
    }
    
  }
  
  deinit {
    
    cvs = nil
    
    timeoutTimer?.invalidate()
    timeoutTimer = nil
    
  }
  
  // MARK: Private Properties
  
  internal var cvs : OpenLCBMemorySpace?
  
  internal var addressLocoNetGateway   = 0
  internal var addressDeleteFromRoster = 0
  
  internal let numberOfCVs : Int = 1024

  private var progMode : OpenLCBProgrammingMode = .defaultProgrammingMode
  
  private var ioState : IOState = .idle
  
  private var ioCount = 0
  
  private var ioAddress = 0
  
  private var ioStartAddress : UInt32 = 0
  
  private var ioSourceNodeId : UInt64 = 0
  
  private var timeoutTimer : Timer?
  
  private let ackTimeoutInterval : TimeInterval = 0.2
  
  private let resultTimeoutInterval : TimeInterval = 3.0
  
  private var _locoNetGateway : LocoNetGateway?

  // MARK: Public Properties
  
  public var locoNetGatewayNodeId : UInt64 {
    get {
      return configuration!.getUInt64(address: addressLocoNetGateway)!
    }
    set(value) {
      configuration!.setUInt(address: addressLocoNetGateway, value: value)
      _locoNetGateway = nil
    }
  }

  public var locoNetGateway : LocoNetGateway? {
    if let gateway = _locoNetGateway {
      return gateway
    }
    _locoNetGateway = appNode?.locoNetGateways[locoNetGatewayNodeId]
    return _locoNetGateway
  }

  // MARK: Private Methods
  
  internal override func resetToFactoryDefaults() {
    super.resetToFactoryDefaults()
    saveMemorySpaces()
  }
  
  @objc internal func timeoutTimerAction() {
    
    stopTimeoutTimer()

    ioState = .idle

    switch ioState {
    case .readingCVWaitingForAck, .readingCVWaitingForResult:
      sendReadReplyFailure(destinationNodeId: ioSourceNodeId, addressSpace: cvs!.space, startAddress: ioStartAddress, errorCode: .temporaryErrorTimeOut)
    case .writingCVWaitingForAck, .writingCVWaitingForResult:
      sendWriteReplyFailure(destinationNodeId: ioSourceNodeId, addressSpace: cvs!.space, startAddress: ioStartAddress, errorCode: .temporaryErrorTimeOut)
    default:
      break
    }
    
  }
  
  internal func startTimeoutTimer(interval: TimeInterval) {
    timeoutTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(timeoutTimerAction), userInfo: nil, repeats: false)
    RunLoop.current.add(timeoutTimer!, forMode: .common)
  }
  
  internal func stopTimeoutTimer() {
    timeoutTimer?.invalidate()
    timeoutTimer = nil
  }
  
  internal override func readCVs(sourceNodeId:UInt64, memorySpace:OpenLCBMemorySpace, startAddress:UInt32, count:UInt8) {
    
    guard let progMode = OpenLCBProgrammingMode(rawValue: startAddress & OpenLCBProgrammingMode.modeMask), progMode.isAllowedOnProgrammingTrack else {
      sendReadReplyFailure(destinationNodeId: sourceNodeId, addressSpace: memorySpace.space, startAddress: startAddress, errorCode: .permanentErrorInvalidArguments)
      return
    }
    
    self.progMode = progMode
    
    self.ioState = .readingCVWaitingForAck
    
    self.ioCount = Int(count)
    
    self.ioAddress = Int(startAddress & OpenLCBProgrammingMode.addressMask)
    
    self.ioStartAddress = startAddress
    
    self.ioSourceNodeId = sourceNodeId
    
    startTimeoutTimer(interval: ackTimeoutInterval)
    
    locoNetGateway?.readCV(progMode: progMode.locoNetProgrammingMode(isProgrammingTrack: true), cv: self.ioAddress, address: 0)
    
  }
  
  internal override func writeCVs(sourceNodeId:UInt64, memorySpace:OpenLCBMemorySpace, startAddress:UInt32, data: [UInt8]) {
    
    guard let progMode = OpenLCBProgrammingMode(rawValue: startAddress & OpenLCBProgrammingMode.modeMask) else {
      sendWriteReplyFailure(destinationNodeId: sourceNodeId, addressSpace: memorySpace.space, startAddress: startAddress, errorCode: .permanentErrorInvalidArguments)
      return
    }
    
    self.progMode = progMode
    
    self.ioState = .writingCVWaitingForAck
    
    self.ioCount = data.count
    
    self.ioAddress = Int(startAddress & OpenLCBProgrammingMode.addressMask)
    
    self.ioStartAddress = startAddress
    
    self.ioSourceNodeId = sourceNodeId
    
    if memorySpace.isWithinSpace(address: Int(ioAddress), count: data.count) {
      memorySpace.setBlock(address: ioAddress, data: data, isInternal: true)
      startTimeoutTimer(interval: resultTimeoutInterval)
      locoNetGateway?.writeCV(progMode: progMode.locoNetProgrammingMode(isProgrammingTrack: true), cv: ioAddress, address: 0, value: cvs!.getUInt8(address: ioAddress)!)
    }
    else {
      sendWriteReplyFailure(destinationNodeId: sourceNodeId, addressSpace: memorySpace.space, startAddress: startAddress, errorCode: .permanentErrorAddressOutOfBounds)
    }

  }

  // MARK: Private Methods
  
  internal override func resetReboot() {
    
    super.resetReboot()
    
    locoNetGateway?.addObserver(observer: self)
    
  }
  
  internal override func customizeDynamicCDI(cdi:String) -> String {
  
    var result = ""
    
    if let appNode {
      result = appNode.insertLocoNetGatewayMap(cdi: cdi)
    }
    
    return result
    
  }

  // MARK: Public Methods
  
  // MARK: LocoNetGatewayDelegate Methods
  
  @objc public func locoNetMessageReceived(message:LocoNetMessage) {
    
    let interestingMessages : Set<LocoNetMessageType> = [
      .progCmdAccepted,
      .programmerBusy,
      .progSlotDataP1,
    ]
    
    guard interestingMessages.contains(message.messageType) else {
      return
    }
    
    switch message.messageType {
      
    case .progCmdAccepted:
      stopTimeoutTimer()
      switch ioState {
      case .readingCVWaitingForAck:
        ioState = .readingCVWaitingForResult
        startTimeoutTimer(interval: resultTimeoutInterval)
      case .writingCVWaitingForAck:
        ioState = .writingCVWaitingForResult
        startTimeoutTimer(interval: resultTimeoutInterval)
      default:
        break
      }
      
    case .programmerBusy:
      stopTimeoutTimer()
      switch ioState {
      case .readingCVWaitingForAck:
        startTimeoutTimer(interval: ackTimeoutInterval)
        locoNetGateway?.readCV(progMode: progMode.locoNetProgrammingMode(isProgrammingTrack: true), cv: self.ioAddress, address: 0)
      case .writingCVWaitingForAck:
        startTimeoutTimer(interval: ackTimeoutInterval)
        locoNetGateway?.writeCV(progMode: progMode.locoNetProgrammingMode(isProgrammingTrack: true), cv: ioAddress, address: 0, value: cvs!.getUInt8(address: ioAddress)!)
      default:
        break
      }
      
    case .progSlotDataP1:
 
      if ioState != .idle {
        
        stopTimeoutTimer()
        
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
          
        case .readingCVWaitingForResult:
          if errorCode != .success {
            ioState = .idle
            sendReadReplyFailure(destinationNodeId: ioSourceNodeId, addressSpace: cvs!.space, startAddress: ioStartAddress, errorCode: errorCode)
          }
          else if let value = message.cvValue {
            cvs?.setUInt(address: ioAddress, value: value)
            ioAddress += 1
            if ioAddress < (ioStartAddress & OpenLCBProgrammingMode.addressMask) + UInt32(ioCount) {
              ioState = .readingCVWaitingForAck
              startTimeoutTimer(interval: ackTimeoutInterval)
              locoNetGateway?.readCV(progMode: progMode.locoNetProgrammingMode(isProgrammingTrack: true), cv: self.ioAddress, address: 0)
            }
            else {
              if let data = cvs!.getBlock(address: Int(ioStartAddress & OpenLCBProgrammingMode.addressMask), count: Int(ioCount)) {
                ioState = .idle
                sendReadReply(destinationNodeId: ioSourceNodeId, addressSpace: cvs!.space, startAddress: ioStartAddress, data: data)
              }
              else {
                ioState = .idle
                sendReadReplyFailure(destinationNodeId: ioSourceNodeId, addressSpace: cvs!.space, startAddress: ioStartAddress, errorCode: .permanentErrorAddressOutOfBounds)
              }
            }
          }
          
        case .writingCVWaitingForResult:
          stopTimeoutTimer()
          if errorCode != .success {
            ioState = .idle
            sendWriteReplyFailure(destinationNodeId: ioSourceNodeId, addressSpace: cvs!.space, startAddress: ioStartAddress, errorCode: errorCode)
          }
          else {
            ioAddress += 1
            if ioAddress < (ioStartAddress & OpenLCBProgrammingMode.addressMask) + UInt32(ioCount) {
              ioState = .writingCVWaitingForAck
              startTimeoutTimer(interval: ackTimeoutInterval)
              locoNetGateway?.writeCV(progMode: progMode.locoNetProgrammingMode(isProgrammingTrack: true), cv: ioAddress, address: 0, value: cvs!.getUInt8(address: ioAddress)!)
            }
            else {
              ioState = .idle
              sendWriteReply(destinationNodeId: ioSourceNodeId, addressSpace: cvs!.space, startAddress: ioStartAddress)
            }
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
