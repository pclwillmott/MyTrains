//
//  OpenLCBNodeRollingStockLocoNet.swift
//  MyTrains
//
//  Created by Paul Willmott on 23/06/2023.
//

import Foundation

public class OpenLCBNodeRollingStockLocoNet : OpenLCBNodeRollingStock, LocoNetDelegate {
  
  // MARK: Constructors
  
  deinit {
    locoNet = nil
  }
  
  // MARK: Private Properties
  
  private enum ConfigState {
    case idle
    case initializing
    case slotFetch
    case setInUse
    case writeBack
    case active
  }
  
  private enum IOState {
    case idle
    case readingCVWaitingForAck
    case writingCVWaitingForAck
    case readingCVWaitingForResult
  }
  
  private var configState : ConfigState = .idle
  
  private var slotPage : UInt8 = 0
  
  private var slotNumber : UInt8 = 0
  
  private var stat1 : UInt8 = 0
  
  private var forceRefresh : Bool = false
  
  private var refreshTimer : Timer?
  
  private var timeoutTimer : Timer?
  
  private var cvTimeoutTimer : Timer?
  
  private var locoNet : LocoNet?
  
  private var slotState : LocoNetSlotState {
    get {
      return LocoNetSlotState(rawValue: stat1 & ~LocoNetSlotState.protectMask)!
    }
    set(value) {
      stat1 &= LocoNetSlotState.protectMask
      stat1 |= value.setMask
    }
  }
  
  private var progMode : OpenLCBProgrammingMode = .defaultProgrammingMode
  
  private var ioState : IOState = .idle
  
  private var ioCount = 0
  
  private var ioAddress = 0
  
  private var ioStartAddress : UInt32 = 0
  
  private var ioSourceNodeId : UInt64 = 0
  
  private let ackTimeoutInterval : TimeInterval = 0.2
  
  private let resultTimeoutInterval : TimeInterval = 3.0

  private var lastLocomotiveState : LocoNetLocomotiveState?
  
  private var standardFunctions : UInt64 = 0
    
  private var expandedFunctions : UInt64 = 0
  
  // MARK: Private Methods
  
  @objc internal func cvTimeoutTimerAction() {
    
    stopCVTimeoutTimer()

    ioState = .idle

    switch ioState {
    case .readingCVWaitingForAck, .readingCVWaitingForResult:
      networkLayer?.sendReadReplyFailure(sourceNodeId: nodeId, destinationNodeId: ioSourceNodeId, addressSpace: cvs.space, startAddress: ioStartAddress, errorCode: .temporaryErrorTimeOut)
    case .writingCVWaitingForAck:
      networkLayer?.sendWriteReplyFailure(sourceNodeId: nodeId, destinationNodeId: ioSourceNodeId, addressSpace: cvs.space, startAddress: ioStartAddress, errorCode: .temporaryErrorTimeOut)
    default:
      break
    }
    
  }
  
  internal func startCVTimeoutTimer(interval: TimeInterval) {
    cvTimeoutTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(cvTimeoutTimerAction), userInfo: nil, repeats: false)
    RunLoop.current.add(cvTimeoutTimer!, forMode: .common)
  }
  
  internal func stopCVTimeoutTimer() {
    cvTimeoutTimer?.invalidate()
    cvTimeoutTimer = nil
  }
  
  internal override func readCVs(sourceNodeId:UInt64, memorySpace:OpenLCBMemorySpace, startAddress:UInt32, count:UInt8) {
    
    guard let progMode = OpenLCBProgrammingMode(rawValue: startAddress & OpenLCBProgrammingMode.modeMask), progMode.isAllowedOnMainTrack else {
      networkLayer?.sendReadReplyFailure(sourceNodeId: nodeId, destinationNodeId: sourceNodeId, addressSpace: memorySpace.space, startAddress: startAddress, errorCode: .permanentErrorInvalidArguments)
      return
    }

    let address = startAddress & OpenLCBProgrammingMode.addressMask
    
    if let data = memorySpace.getBlock(address: Int(address), count: Int(count)) {
      networkLayer?.sendReadReply(sourceNodeId: nodeId, destinationNodeId: sourceNodeId, addressSpace: memorySpace.space, startAddress: startAddress, data: data)
    }
    else {
      networkLayer?.sendReadReplyFailure(sourceNodeId: nodeId, destinationNodeId: sourceNodeId, addressSpace: memorySpace.space, startAddress: startAddress, errorCode: .permanentErrorAddressOutOfBounds)
    }

  }
  
  internal override func writeCVs(sourceNodeId:UInt64, memorySpace:OpenLCBMemorySpace, startAddress:UInt32, data: [UInt8]) {

    guard let progMode = OpenLCBProgrammingMode(rawValue: startAddress & OpenLCBProgrammingMode.modeMask), progMode.isAllowedOnMainTrack else {
      networkLayer?.sendWriteReplyFailure(sourceNodeId: nodeId, destinationNodeId: sourceNodeId, addressSpace: memorySpace.space, startAddress: startAddress, errorCode: .permanentErrorInvalidArguments)
      return
    }
    
    let address = startAddress & OpenLCBProgrammingMode.addressMask

    if memorySpace.isWithinSpace(address: Int(address), count: data.count) {
      
      memorySpace.setBlock(address: Int(address), data: data, isInternal: false)
      memorySpace.save()

      if address < defaultOffset {

        ioAddress = Int(address)
        
        ioStartAddress = startAddress
        
        ioSourceNodeId = sourceNodeId
        
        ioCount = data.count
        
        ioState = .writingCVWaitingForAck
        
        startCVTimeoutTimer(interval: ackTimeoutInterval)
        
        locoNet?.writeCV(progMode: progMode.locoNetProgrammingMode(isProgrammingTrack: false), cv: Int(ioAddress), address: Int(dccAddress), value: cvs.getUInt8(address: ioAddress)!)
        
      }
      else {
        if address < statusOffset { // Setting Default Values
          for addr in Int(address) ... Int(address) + data.count - 1 {
            setDefaultStatus(cvNumber: addr, isClean: true)
          }
          cvs.save()
        }
        networkLayer?.sendWriteReply(sourceNodeId: nodeId, destinationNodeId: sourceNodeId, addressSpace: memorySpace.space, startAddress: startAddress)
      }
      
    }
    else {
      networkLayer?.sendWriteReplyFailure(sourceNodeId: nodeId, destinationNodeId: sourceNodeId, addressSpace: memorySpace.space, startAddress: startAddress, errorCode: .permanentErrorAddressOutOfBounds)
    }

  }

  private func readStandardFunctions() {
    
    standardFunctions = 0
    
    var mask : UInt64 = 1
    
    for fn in 0 ... 28 {
      if let fx = functions.getUInt8(address: fn), fx != 0 {
        standardFunctions |= mask
      }
      mask <<= 1
    }
    
  }
  
  private func readExpandedFunctions() {
    
    expandedFunctions = 0
    
    var mask : UInt64 = 1
    
    for fn in 29 ... 68 {
      if let fx = functions.getUInt8(address: fn), fx != 0 {
        expandedFunctions |= mask
      }
      mask <<= 1
    }
    
  }
  
  @objc func refreshTimerAction() {
    guard configState == .active else {
      stopRefreshTimer()
      return
    }
    forceRefresh = true
    updateLocoState()
  }
  
  func startRefreshTimer(timeInterval:TimeInterval) {
    refreshTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(refreshTimerAction), userInfo: nil, repeats: true)
    RunLoop.current.add(refreshTimer!, forMode: .common)
  }
  
  func stopRefreshTimer() {
    refreshTimer?.invalidate()
    refreshTimer = nil
  }

  @objc func timeoutTimerAction() {
    
    switch configState {
    case .slotFetch, .setInUse:
      attachFailed()
    case .writeBack:
      slotState = .common
      locoNet?.setLocoSlotStat1(slotPage: slotPage, slotNumber: slotNumber, stat1: stat1)
      attachFailed()
    default:
      break
    }
    
    configState = .idle
    
  }
  
  func startTimeoutTimer() {
    
    let timeInterval : TimeInterval = 2.0
    
    timeoutTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(timeoutTimerAction), userInfo: nil, repeats: false)
    
    RunLoop.current.add(timeoutTimer!, forMode: .common)
    
  }
  
  func stopTimeoutTimer() {
    timeoutTimer?.invalidate()
    timeoutTimer = nil
  }
  
  private func setSpeed(speedStep:UInt8, direction:LocomotiveDirection) {
    var newSpeed : Float
    if speedStep < 2 {
      newSpeed = (direction == .forward) ? +0.0 : -0.0
    }
    else {
      newSpeed = Float(speedStep - 1) / 3600.0 * (1000.0 * 1.609344)
      newSpeed *= (direction == .forward) ? +1.0 : -1.0
    }
    setSpeed = newSpeed
    speedChanged()
  }

  private func updateLocoState() {
    
    guard let locoNet else {
      return
    }
    
    var step = UInt8(min(126, Int(abs(setSpeed) * 3600.0 / (1000.0 * 1.609344))))
    
    // THIS SHOULD BE DONE WITH A SPEED TABLE
    
    step = step == 0 ? 0 : step + 1
    
    if emergencyStop {
      step = 1
      if abs(setSpeed) != 0.0 {
        setSpeedToZero()
      }
    }
    
    let minusZero : Float = -0.0
    
    let direction : LocomotiveDirection = (setSpeed.bitPattern == minusZero.bitPattern || setSpeed < 0.0) ? .reverse : .forward

    let nextState = (
      speed: step,
      direction: direction,
      functions: standardFunctions,
      extendedFunctions: expandedFunctions
    )
    
    if let last = lastLocomotiveState {
      let temp = locoNet.updateLocomotiveState(address: dccAddress, slotNumber: slotNumber, slotPage: slotPage, previousState: last, nextState: nextState, throttleID: 0, forceRefresh: forceRefresh)
      lastLocomotiveState = temp.state
    }
    else {
      let temp = locoNet.setLocomotiveState(address: dccAddress, slotNumber: slotNumber, slotPage: slotPage, nextState: nextState, throttleID: 0)
      lastLocomotiveState = temp.state
    }
    
    forceRefresh = false

  }
  
  internal override func attachNode() {
  
    if configState == .active {
      attachCompleted()
      return
    }
    
    guard locoNetGatewayNodeId != 0 else {
      return
    }
    
    configState = .initializing
    
    slotPage = 0
    
    slotNumber = 0
    
    stat1 = 0
    
    setSpeedToZero()
    
    commandedSpeed = 0.0
    
    readStandardFunctions()
    
    readExpandedFunctions()
    
    lastLocomotiveState = nil
    
    configState = .slotFetch

    startTimeoutTimer()
    
    locoNet?.getLocoSlot(forAddress: dccAddress)
    
  }
  
  internal override func releaseNode() {
    
    stopRefreshTimer()
    
    guard let locoNet else {
      return
    }
    
    emergencyStop = true
    
    setSpeedToZero()
    
    emergencyStop = false
    
    locoNet.clearLocomotiveState(address: dccAddress, slotNumber: slotNumber, slotPage: slotPage, previousState: lastLocomotiveState!, throttleID: 0)

    slotState = .common

    locoNet.setLocoSlotStat1(slotPage: slotPage, slotNumber: slotNumber, stat1: stat1)

    configState = .idle
    
  }
 
  internal override func speedChanged() {
    updateLocoState()
  }
  
  internal override func functionChanged() {
    
    readStandardFunctions()
    
    readExpandedFunctions()
    
    updateLocoState()
    
  }
  
  internal override func customizeDynamicCDI(cdi:String) -> String {
   
    var result = cdi
    
    if let appNode {
      result = appNode.insertLocoNetGatewayMap(cdi: result)
    }

    return OpenLCBFunction.insertMap(cdi: result)
    
  }

  internal override func resetReboot() {
    
    super.resetReboot()
    
    guard locoNetGatewayNodeId != 0 else {
      return
    }
    
    locoNet = LocoNet(gatewayNodeId: locoNetGatewayNodeId, virtualNode: self)
    
    locoNet?.delegate = self

  }


  // MARK: Public Methods
  
  // MARK: OpenLCBNetworkLayerDelegate Methods
   
  public override func openLCBMessageReceived(message: OpenLCBMessage) {
    super.openLCBMessageReceived(message: message)
    locoNet?.openLCBMessageReceived(message: message)
  }
  
  // MARK: LocoNetDelegate Methods
  
  @objc public func locoNetInitializationComplete() {
  }
  
  @objc public func locoNetMessageReceived(message:LocoNetMessage) {
    
    switch message.messageType {
      
    case .programmerBusy:
      stopTimeoutTimer()
      switch ioState {
      case .readingCVWaitingForAck:
        startCVTimeoutTimer(interval: ackTimeoutInterval)
        locoNet?.readCV(progMode: progMode.locoNetProgrammingMode(isProgrammingTrack: true), cv: self.ioAddress, address: 0)
      case .writingCVWaitingForAck:
        startCVTimeoutTimer(interval: ackTimeoutInterval)
        locoNet?.writeCV(progMode: progMode.locoNetProgrammingMode(isProgrammingTrack: true), cv: ioAddress, address: 0, value: cvs.getUInt8(address: ioAddress)!)
      default:
        break
      }
      
    case .progCmdAcceptedBlind:
      
      stopCVTimeoutTimer()
      
      switch ioState {
        
      case .readingCVWaitingForAck:
        ioState = .readingCVWaitingForResult
        startCVTimeoutTimer(interval: resultTimeoutInterval)
        
      case .writingCVWaitingForAck:
        
        setValueStatus(cvNumber: ioAddress, isClean: true)
        
        if !isDefaultClean(cvNumber: ioAddress), let value = cvs.getUInt8(address: ioAddress) {
          cvs.setUInt(address: defaultOffset + ioAddress, value: value)
          setDefaultStatus(cvNumber: ioAddress, isClean: true)
        }
        
        cvs.save()
        
        ioAddress += 1
        
        if ioAddress < Int(ioStartAddress & OpenLCBProgrammingMode.addressMask) + ioCount {
          ioState = .writingCVWaitingForAck
          startCVTimeoutTimer(interval: ackTimeoutInterval)
          locoNet?.writeCV(progMode: progMode.locoNetProgrammingMode(isProgrammingTrack: false), cv: Int(ioAddress), address: Int(dccAddress), value: cvs.getUInt8(address: ioAddress)!)
        }
        else {
          networkLayer?.sendWriteReply(sourceNodeId: nodeId, destinationNodeId: ioSourceNodeId, addressSpace: cvs.space, startAddress: ioStartAddress)
        }

      default:
        break
      }

    case .locoSlotDataP1:
      let address : UInt16 = UInt16(message.message[4])
      if address == dccAddress {
        stopTimeoutTimer()
        slotPage = 0
        slotNumber = message.message[2]
        stat1 = message.message[3]
        switch configState {
        case .slotFetch:
          if slotState == .inUse {
            var writeBackMessage = message.message
            writeBackMessage.removeLast()
            writeBackMessage[0] = LocoNetMessageOpcode.OPC_WR_SL_DATA.rawValue
            writeBackMessage[3] &= SpeedSteps.protectMask
            writeBackMessage[3] |= speedSteps.setMask
            let wbm = LocoNetMessage(data: writeBackMessage, appendCheckSum: true)
            configState = .writeBack
            startTimeoutTimer()
            networkLayer?.sendLocoNetMessage(sourceNodeId: nodeId, destinationNodeId: locoNetGatewayNodeId, locoNetMessage: wbm)
            let directionMask : UInt8 = 0b00100000
            let direction : LocomotiveDirection = ((message.message[6] & directionMask) == directionMask) ? .reverse : .forward
            setSpeed(speedStep: message.message[5], direction: direction)
          }
          else {
            configState = .setInUse
            startTimeoutTimer()
            locoNet?.moveSlotsP1(sourceSlotNumber: slotNumber, destinationSlotNumber: slotNumber)
          }
        case .setInUse:
          if slotState != .inUse {
            configState = .idle
            attachFailed()
          }
          else {
            var writeBackMessage = message.message
            writeBackMessage.removeLast()
            writeBackMessage[0] = LocoNetMessageOpcode.OPC_WR_SL_DATA.rawValue
            writeBackMessage[3] &= SpeedSteps.protectMask
            writeBackMessage[3] |= speedSteps.setMask
            let wbm = LocoNetMessage(data: writeBackMessage, appendCheckSum: true)
            configState = .writeBack
            startTimeoutTimer()
            locoNet?.addToQueue(message: wbm)
          }
        default:
          break
        }
      }
    case .locoSlotDataP2:
      let address : UInt16 = (UInt16(message.message[6]) << 7) | UInt16(message.message[5])
      if address == dccAddress {
        stopTimeoutTimer()
        slotPage = message.message[2]
        slotNumber = message.message[3]
        stat1 = message.message[4]
        switch configState {
        case .slotFetch:
          if slotState == .inUse {
            var writeBackMessage = message.message
            writeBackMessage.removeLast()
            writeBackMessage[0] = LocoNetMessageOpcode.OPC_WR_SL_DATA_P2.rawValue
            writeBackMessage[4] &= SpeedSteps.protectMask
            writeBackMessage[4] |= speedSteps.setMask
            writeBackMessage[18] = 0 // Throttle Id low
            writeBackMessage[19] = 0 // Throttle Id high
            let wbm = LocoNetMessage(data: writeBackMessage, appendCheckSum: true)
            configState = .writeBack
            startTimeoutTimer()
            locoNet?.addToQueue(message: wbm)
          }
          else {
            configState = .setInUse
            startTimeoutTimer()
            locoNet?.moveSlotsP2(sourceSlotNumber: slotNumber, sourceSlotPage: slotPage, destinationSlotNumber: slotNumber, destinationSlotPage: slotPage)
          }
        case .setInUse:
          if slotState != .inUse {
            configState = .idle
            attachFailed()
          }
          else {
            var writeBackMessage = message.message
            writeBackMessage.removeLast()
            writeBackMessage[0] = LocoNetMessageOpcode.OPC_WR_SL_DATA_P2.rawValue
            writeBackMessage[4] &= SpeedSteps.protectMask
            writeBackMessage[4] |= speedSteps.setMask
            writeBackMessage[18] = 0 // Throttle Id low
            writeBackMessage[19] = 0 // Throttle Id high
            let wbm = LocoNetMessage(data: writeBackMessage, appendCheckSum: true)
            configState = .writeBack
            startTimeoutTimer()
            locoNet?.addToQueue(message: wbm)
          }
        default:
          break
        }
      }
    case .noFreeSlotsP1, .noFreeSlotsP2:
      if configState == .slotFetch {
        stopTimeoutTimer()
        configState = .idle
        attachFailed()
      }
    case .illegalMoveP1, .d4Error:
      if configState == .setInUse {
        stopTimeoutTimer()
        configState = .idle
        attachFailed()
      }
    case .setSlotDataOKP1, .setSlotDataOKP2:
      if configState == .writeBack {
        stopTimeoutTimer()
        configState = .active
        attachCompleted()
        updateLocoState()
        startRefreshTimer(timeInterval: 90.0)
      }
    default:
      break
    }
    
  }

}
