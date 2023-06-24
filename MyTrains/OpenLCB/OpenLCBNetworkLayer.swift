//
//  LCCNetworkLayer.swift
//  MyTrains
//
//  Created by Paul Willmott on 08/04/2023.
//

import Foundation

public class OpenLCBNetworkLayer : NSObject, OpenLCBTransportLayerDelegate {
  
  // MARK: Constructors
  
  public init(nodeId: UInt64) {
    
    myTrainsNode = OpenLCBNodeMyTrains(nodeId: nodeId)
    
    configurationToolNode = OpenLCBNodeConfigurationTool(nodeId: 0x09000d000000)
    
    fastClock = OpenLCBClock(nodeId: 0x09000d000001)
    
    super.init()

    registerNode(node: myTrainsNode)
    
    registerNode(node: configurationToolNode)
    
    for (_, rollingStock) in RollingStock.rollingStock {
      if rollingStock.rollingStockType == .locomotive {
        registerNode(node: OpenLCBNodeRollingStockLocoNet(rollingStock: rollingStock))
      }
    }
    
    let numberOfThrottles : UInt8 = 8
    
    for throttleId in 1 ... numberOfThrottles {
      let throttle = OpenLCBThrottle(throttleId: throttleId)
      throttles.append(throttle)
      freeThrottles.insert(throttleId)
      registerNode(node: throttle)
    }
    
    registerNode(node: fastClock)
    
    // **** TESTING STUFF ****
    
//    OpenLCBMemorySpace.getMemorySpaces()
    

    
  }
  
  // MARK: Private Properties
  
  internal var _state : OpenLCBNetworkLayerState = .uninitialized
  
  private var nextObserverId : Int = 0
  
  private var observers : [Int:OpenLCBNetworkLayerDelegate] = [:]
  
  private var virtualNodes : [UInt64:OpenLCBNodeVirtual] = [:]
  
  private var throttles : [OpenLCBThrottle] = []
  
  private var throttlesInUse : Set<UInt8> = []
  
  private var freeThrottles : Set<UInt8> = []

  // MARK: Public Properties
  
  public var state : OpenLCBNetworkLayerState {
    get {
      return _state
    }
  }
  
  public var myTrainsNode : OpenLCBNodeMyTrains
  
  public var configurationToolNode : OpenLCBNodeVirtual
  
  public var fastClock : OpenLCBClock
  
  public var transportLayers : [ObjectIdentifier:OpenLCBTransportLayer] = [:]
  
  // MARK: Public Methods
  
  public func start() {
    
    guard state == .uninitialized else {
      return
    }
    
    for (_, interface) in myTrainsController.networkLCCInterfaces {
      addTransportLayer(transportLayer: OpenLCBTransportLayerCAN(interface: interface))
    }
    
    for (_, transportLayer) in transportLayers {
      transportLayer.start()
    }
    
  }
  
  public func stop() {
    
    guard state == .initialized else {
      return
    }
    
    for (_, transportLayer) in transportLayers {
      transportLayer.stop()
    }
    
  }
  
  public func addTransportLayer(transportLayer: OpenLCBTransportLayer) {
    transportLayers[ObjectIdentifier(transportLayer)] = transportLayer
    transportLayer.delegate = self
  }
  
  public func removeTransportLayer(transportLayer: OpenLCBTransportLayer) {
    transportLayer.delegate = nil
    transportLayers.removeValue(forKey: ObjectIdentifier(transportLayer))
  }
  
  public func removeAlias(nodeId:UInt64) {
    for (_, layer) in transportLayers {
      layer.removeAlias(nodeId: nodeId)
    }
  }

  public func addObserver(observer:OpenLCBNetworkLayerDelegate) -> Int{
    let id = nextObserverId
    nextObserverId += 1
    observers[id] = observer
    return id
  }
  
  public func removeObserver(observerId:Int) {
    observers.removeValue(forKey: observerId)
  }
  
  public func registerNode(node:OpenLCBNodeVirtual) {
    virtualNodes[node.nodeId] = node
    node.networkLayer = self
  }
  
  public func deregisterNode(node:OpenLCBNodeVirtual) {
    virtualNodes.removeValue(forKey: node.nodeId)
    node.networkLayer = nil
  }
  
  public func getThrottle() -> OpenLCBThrottle? {
    if let throttleId = freeThrottles.first {
      throttlesInUse.insert(throttleId)
      freeThrottles.remove(throttleId)
      return throttles[Int(throttleId) - 1]
    }
    return nil
  }
  
  public func releaseThrottle(throttle:OpenLCBThrottle) {
    freeThrottles.insert(throttle.throttleId)
    throttlesInUse.remove(throttle.throttleId)
  }

  // MARK: Messages
  
  internal func sendMessage(message:OpenLCBMessage) {
    
    guard state == .initialized else {
      return
    }
    
    for (_, transportLayer) in transportLayers {
      transportLayer.addToOutputQueue(message: message)
    }
    
    for (_, observer) in observers {
      DispatchQueue.main.async {
        observer.openLCBMessageReceived(message: message)
      }
    }
    
    for (_, virtualNode) in virtualNodes {
      if virtualNode.nodeId != message.sourceNodeId {
        DispatchQueue.main.async {
          virtualNode.openLCBMessageReceived(message: message)
        }
      }
    }
    
  }
  
  public func sendInitializationComplete(sourceNodeId:UInt64, isSimpleSetSufficient:Bool) {
    
    let mti : OpenLCBMTI = isSimpleSetSufficient ? .initializationCompleteSimpleSetSufficient : .initializationCompleteFullProtocolRequired
    
    let message = OpenLCBMessage(messageTypeIndicator: mti)
    
    message.sourceNodeId = sourceNodeId
    
    var data = sourceNodeId.bigEndianData
    data.removeFirst(2)
    
    message.payload = data
    
    sendMessage(message: message)
 
  }

  public func sendClockQuery(sourceNodeId:UInt64, baseEventId:UInt64) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .producerConsumerEventReport)
    
    message.sourceNodeId = sourceNodeId
    
    message.eventId = baseEventId | 0xf000
    
    sendMessage(message: message)
    
  }

  public func sendEvent(sourceNodeId:UInt64, eventId:UInt64) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .producerConsumerEventReport)
    
    message.sourceNodeId = sourceNodeId
    
    message.eventId = eventId
    
    sendMessage(message: message)
    
  }

  public func sendWellKnownEvent(sourceNodeId:UInt64, eventId:OpenLCBWellKnownEvent) {
    sendEvent(sourceNodeId: sourceNodeId, eventId: eventId.rawValue)
  }
  
  public func sendProducerRangeIdentified(sourceNodeId:UInt64, eventId:UInt64) {

    let message = OpenLCBMessage(messageTypeIndicator: .producerRangeIdentified)

    message.sourceNodeId = sourceNodeId
    
    message.eventId = eventId
    
    sendMessage(message: message) 

  }

  public func sendConsumerRangeIdentified(sourceNodeId:UInt64, eventId:UInt64) {

    let message = OpenLCBMessage(messageTypeIndicator: .consumerRangeIdentified)

    message.sourceNodeId = sourceNodeId
    
    message.eventId = eventId
    
    sendMessage(message: message)

  }
  
  public func sendProducerIdentifiedValid(sourceNodeId:UInt64, eventId:UInt64) {

    let message = OpenLCBMessage(messageTypeIndicator: .producerIdentifiedAsCurrentlyValid)

    message.sourceNodeId = sourceNodeId
    
    message.eventId = eventId
    
    sendMessage(message: message)

  }

  public func sendProducerIdentifiedValidityUnknown(sourceNodeId:UInt64, eventId:UInt64) {

    let message = OpenLCBMessage(messageTypeIndicator: .producerIdentifiedWithValidityUnknown)

    message.sourceNodeId = sourceNodeId
    
    message.eventId = eventId
    
    sendMessage(message: message)

  }

  public func sendVerifyNodeIdNumber(sourceNodeId:UInt64) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .verifyNodeIDNumberGlobal)

    message.sourceNodeId = sourceNodeId
    
    sendMessage(message: message)
    
  }

  public func sendVerifyNodeIdNumber(sourceNodeId:UInt64, destinationNodeId:UInt64) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .verifyNodeIDNumberGlobal)

    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId

    var data = destinationNodeId.bigEndianData
    data.removeFirst(2)

    message.payload = data

    sendMessage(message: message)
    
  }

  public func sendVerifiedNodeIdNumber(sourceNodeId:UInt64, isSimpleSetSufficient:Bool) {
    
    let mti : OpenLCBMTI = isSimpleSetSufficient ? .verifiedNodeIDNumberSimpleSetSufficient : .verifiedNodeIDNumberFullProtocolRequired
    
    let message = OpenLCBMessage(messageTypeIndicator: mti)

    message.sourceNodeId = sourceNodeId
    
    var data = sourceNodeId.bigEndianData
    data.removeFirst(2)

    message.payload = data

    sendMessage(message: message)
    
  }

  public func sendGetMemorySpaceInformationRequest(sourceNodeId:UInt64, destinationNodeId:UInt64,addressSpace:UInt8) {
    
    let data : [UInt8] = [0x20, 0x84, addressSpace]
    
    sendDatagram(sourceNodeId: sourceNodeId, destinationNodeId: destinationNodeId, data: data)
    
  }
  
  public func sendDatagramReceivedOK(sourceNodeId:UInt64, destinationNodeId:UInt64, replyPending:Bool, timeOut: TimeInterval) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .datagramReceivedOK)
    
    message.destinationNodeId = destinationNodeId
    
    message.sourceNodeId = sourceNodeId
    
    var data : UInt8 = replyPending ? 0b10000000 : 0
    
    data |= timeOut != 0.0 ? (UInt8(log(timeOut) / log(2.0) + 0.9) & 0x0f) : 0x00
    
    message.payload = [data]
    
    sendMessage(message: message)
    
  }

  public func sendDatagram(sourceNodeId:UInt64, destinationNodeId:UInt64, data: [UInt8]) {

    guard data.count >= 0 && data.count <= 72 else {
      print("sendDatagram: invalid number of bytes - \(data.count)")
      return
    }
    
    let message = OpenLCBMessage(messageTypeIndicator: .datagram)
    
    message.destinationNodeId = destinationNodeId
    
    message.sourceNodeId = sourceNodeId
    
    message.payload = data
    
    sendMessage(message: message)

  }

  public func sendLockReserveReply(sourceNodeId:UInt64, destinationNodeId:UInt64, reservedNodeId:UInt64) {

    var data : [UInt8] = reservedNodeId.bigEndianData
    data.removeFirst(2)
    
    data.insert(0x8a, at: 0)
    data.insert(0x20, at: 0)
    
    sendDatagram(sourceNodeId: sourceNodeId, destinationNodeId: destinationNodeId, data: data)

  }
  
  public func sendReadReply(sourceNodeId:UInt64, destinationNodeId:UInt64, addressSpace:UInt8, startAddress:UInt32, data:[UInt8]) {

    var payload : [UInt8] = [0x20]
    
    var addAddressSpace = false
    
    switch addressSpace {
    case 0xff:
      payload.append(OpenLCBDatagramType.readReply0xFF.rawValue)
    case 0xfe:
      payload.append(OpenLCBDatagramType.readReply0xFE.rawValue)
    case 0xfd:
      payload.append(OpenLCBDatagramType.readReply0xFD.rawValue)
    default:
      payload.append(OpenLCBDatagramType.readReplyGeneric.rawValue)
      addAddressSpace = true
    }
    
    payload.append(contentsOf: startAddress.bigEndianData)
    
    if addAddressSpace {
      payload.append(addressSpace)
    }
    
    payload.append(contentsOf: data)
    
    sendDatagram(sourceNodeId: sourceNodeId, destinationNodeId: destinationNodeId, data: payload)

  }

  public func sendReadReplyFailure(sourceNodeId:UInt64, destinationNodeId:UInt64, addressSpace:UInt8, startAddress:UInt32, errorCode:OpenLCBErrorCode) {

    var payload : [UInt8] = [0x20]
    
    var addAddressSpace = false
    
    switch addressSpace {
    case 0xff:
      payload.append(OpenLCBDatagramType.readReplyFailure0xFF.rawValue)
    case 0xfe:
      payload.append(OpenLCBDatagramType.readReplyFailure0xFE.rawValue)
    case 0xfd:
      payload.append(OpenLCBDatagramType.readReplyFailure0xFD.rawValue)
    default:
      payload.append(OpenLCBDatagramType.readReplyFailureGeneric.rawValue)
      addAddressSpace = true
    }
    
    payload.append(contentsOf: startAddress.bigEndianData)
    
    if addAddressSpace {
      payload.append(addressSpace)
    }
    
    payload.append(contentsOf: errorCode.bigEndianData)
    
    sendDatagram(sourceNodeId: sourceNodeId, destinationNodeId: destinationNodeId, data: payload)

  }

  public func sendWriteReply(sourceNodeId:UInt64, destinationNodeId:UInt64, addressSpace:UInt8, startAddress:UInt32) {

    var payload : [UInt8] = [0x20]
    
    var addAddressSpace = false
    
    switch addressSpace {
    case 0xff:
      payload.append(OpenLCBDatagramType.writeReply0xFF.rawValue)
    case 0xfe:
      payload.append(OpenLCBDatagramType.writeReply0xFE.rawValue)
    case 0xfd:
      payload.append(OpenLCBDatagramType.writeReply0xFD.rawValue)
    default:
      payload.append(OpenLCBDatagramType.writeReplyGeneric.rawValue)
      addAddressSpace = true
    }
    
    payload.append(contentsOf: startAddress.bigEndianData)
    
    if addAddressSpace {
      payload.append(addressSpace)
    }
    
    sendDatagram(sourceNodeId: sourceNodeId, destinationNodeId: destinationNodeId, data: payload)

  }

  public func sendWriteReplyFailure(sourceNodeId:UInt64, destinationNodeId:UInt64, addressSpace:UInt8, startAddress:UInt32, errorCode:OpenLCBErrorCode) {

    var payload : [UInt8] = [0x20]
    
    var addAddressSpace = false
    
    switch addressSpace {
    case 0xff:
      payload.append(OpenLCBDatagramType.writeReplyFailure0xFF.rawValue)
    case 0xfe:
      payload.append(OpenLCBDatagramType.writeReplyFailure0xFE.rawValue)
    case 0xfd:
      payload.append(OpenLCBDatagramType.writeReplyFailure0xFD.rawValue)
    default:
      payload.append(OpenLCBDatagramType.writeReplyFailureGeneric.rawValue)
      addAddressSpace = true
    }
    
    payload.append(contentsOf: startAddress.bigEndianData)
    
    if addAddressSpace {
      payload.append(addressSpace)
    }
    
    payload.append(contentsOf: errorCode.bigEndianData)
    
    sendDatagram(sourceNodeId: sourceNodeId, destinationNodeId: destinationNodeId, data: payload)

  }

  public func sendGetAddressSpaceInformationReply(sourceNodeId:UInt64, destinationNodeId:UInt64, memorySpace:OpenLCBMemorySpace) {

    var data : [UInt8] = [0x20, 0x87]
    
    let info = memorySpace.addressSpaceInformation
    
    data.append(info.addressSpace)
    
    data.append(contentsOf: info.highestAddress.bigEndianData)
    
    var flags : UInt8 = 0b10
    flags |= info.isReadOnly ? 0b01 : 0b00
    
    data.append(flags)
    
    data.append(contentsOf: info.lowestAddress.bigEndianData)
    
    if !info.description.isEmpty {
      for byte in info.description.utf8 {
        data.append(byte)
      }
      data.append(0)
    }
    
    sendDatagram(sourceNodeId: sourceNodeId, destinationNodeId: destinationNodeId, data: data)

  }
  
  public func sendDatagramRejected(sourceNodeId:UInt64, destinationNodeId:UInt64, errorCode:OpenLCBErrorCode) {

    let message = OpenLCBMessage(messageTypeIndicator: .datagramRejected)
    
    message.destinationNodeId = destinationNodeId
    
    message.sourceNodeId = sourceNodeId
    
    var data = errorCode.rawValue.bigEndianData
    
    if data[1] == 0 {
      data.removeLast()
    }
    message.payload = data
    
    sendMessage(message: message)

  }
  
  public func sendNodeMemoryReadRequest(sourceNodeId:UInt64, destinationNodeId:UInt64, addressSpace:UInt8, startAddress:Int, numberOfBytesToRead: UInt8) {
    
    guard numberOfBytesToRead > 0 && numberOfBytesToRead <= 64 else {
      print("sendNodeMemoryReadRequest: invalid number of bytes to read - \(numberOfBytesToRead)")
      return
    }
    
    var data : [UInt8] = [0x20]
    
    var addByte6 = false
    
    switch addressSpace {
    case 0xff:
      data.append(0x43)
    case 0xfe:
      data.append(0x42)
    case 0xfd:
      data.append(0x41)
    default:
      data.append(0x40)
      addByte6 = true
    }
    
    var mask : UInt32 = 0xff000000
    for index in (0...3).reversed() {
      data.append(UInt8((UInt32(startAddress) & mask) >> (index * 8)))
      mask >>= 8
    }
    
    if addByte6 {
      data.append(addressSpace)
    }
    
    data.append(numberOfBytesToRead)
    
    sendDatagram(sourceNodeId: sourceNodeId, destinationNodeId: destinationNodeId, data: data)
    
  }
  
  public func sendNodeMemoryWriteRequest(sourceNodeId:UInt64, destinationNodeId:UInt64, addressSpace:UInt8, startAddress:Int, dataToWrite: [UInt8]) {
    
    guard dataToWrite.count > 0 && dataToWrite.count <= 64 else {
      print("sendNodeMemoryWriteRequest: invalid number of bytes to write - \(dataToWrite.count)")
      return
    }
    
    var data : [UInt8] = [0x20]
    
    var addByte6 = false
    
    switch addressSpace {
    case 0xff:
      data.append(0x03)
    case 0xfe:
      data.append(0x02)
    case 0xfd:
      data.append(0x01)
    default:
      data.append(0x00)
      addByte6 = true
    }
    
    var mask : UInt32 = 0xff000000
    for index in (0...3).reversed() {
      data.append(UInt8((UInt32(startAddress) & mask) >> (index * 8)))
      mask >>= 8
    }
    
    if addByte6 {
      data.append(addressSpace)
    }
    
    data.append(contentsOf: dataToWrite)
    
    sendDatagram(sourceNodeId: sourceNodeId, destinationNodeId: destinationNodeId, data: data)
    
  }
  
  public func sendLockCommand(sourceNodeId:UInt64, destinationNodeId:UInt64) {

    var data = sourceNodeId.bigEndianData
    data.removeFirst(2)

    data.insert(OpenLCBDatagramType.LockReserveCommand.rawValue, at: 0)
    data.insert(0x20, at: 0)
    
    sendDatagram(sourceNodeId: sourceNodeId, destinationNodeId: destinationNodeId, data: data)
    
  }

  public func sendUnLockCommand(sourceNodeId:UInt64, destinationNodeId:UInt64) {

    let data = [0x20, OpenLCBDatagramType.LockReserveCommand.rawValue, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
    
    sendDatagram(sourceNodeId: sourceNodeId, destinationNodeId: destinationNodeId, data: data)
    
  }

  public func sendRebootCommand(sourceNodeId:UInt64, destinationNodeId:UInt64) {

    let data = [0x20, OpenLCBDatagramType.resetRebootCommand.rawValue]
    
    sendDatagram(sourceNodeId: sourceNodeId, destinationNodeId: destinationNodeId, data: data)
    
    removeAlias(nodeId: destinationNodeId)
    
  }

  public func sendGetConfigurationOptionsCommand(sourceNodeId:UInt64, destinationNodeId:UInt64) {

    let data = [0x20, OpenLCBDatagramType.getConfigurationOptionsCommand.rawValue]
    
    sendDatagram(sourceNodeId: sourceNodeId, destinationNodeId: destinationNodeId, data: data)
    
  }

  public func sendResetToDefaults(sourceNodeId:UInt64, destinationNodeId:UInt64) {

    var data = destinationNodeId.bigEndianData
    data.removeFirst(2)

    data.insert(OpenLCBDatagramType.reinitializeFactoryResetCommand.rawValue, at: 0)
    data.insert(0x20, at: 0)

    sendDatagram(sourceNodeId: sourceNodeId, destinationNodeId: destinationNodeId, data: data)
    
    removeAlias(nodeId: destinationNodeId)
    
  }

  public func sendSimpleNodeInformationRequest(sourceNodeId:UInt64, destinationNodeId:UInt64) {

    let message = OpenLCBMessage(messageTypeIndicator: .simpleNodeIdentInfoRequest)
    
    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    sendMessage(message: message)

  }
  
  public func sendSimpleNodeInformationReply(sourceNodeId:UInt64, destinationNodeId:UInt64, data:[UInt8]) {

    let message = OpenLCBMessage(messageTypeIndicator: .simpleNodeIdentInfoReply)
    
    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    message.payload = data
    
    sendMessage(message: message)

  }

  public func sendProtocolSupportInquiry(sourceNodeId:UInt64, destinationNodeId:UInt64) {

    let message = OpenLCBMessage(messageTypeIndicator: .protocolSupportInquiry)
    
    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    sendMessage(message: message)

  }

  public func sendProtocolSupportReply(sourceNodeId:UInt64, destinationNodeId:UInt64, data:[UInt8]) {

    let message = OpenLCBMessage(messageTypeIndicator: .protocolSupportReply)
    
    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    message.payload = data
    
    sendMessage(message: message)

  }
  
  public func sendQueryControllerReply(sourceNodeId:UInt64, destinationNodeId:UInt64, activeController:UInt64) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlReply)

    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.controllerConfiguration.rawValue,
      OpenLCBTractionControllerConfigurationType.queryController.rawValue,
      0x00
    ]
    
    var ac = activeController.bigEndianData
    ac.removeFirst(2)
    
    message.payload.append(contentsOf: ac)
    
//    message.payload.append(contentsOf: [0x00, 0x00])
    
    sendMessage(message: message)
    
  }

  public func sendControllerChangedNotify(sourceNodeId:UInt64, destinationNodeId:UInt64, newController:UInt64) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlCommand)

    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.controllerConfiguration.rawValue,
      OpenLCBTractionControllerConfigurationType.controllerChangingNotify.rawValue,
      0x00
    ]
    
    var ac = newController.bigEndianData
    ac.removeFirst(2)
    
    message.payload.append(contentsOf: ac)
    
    sendMessage(message: message)
    
  }

  public func sendAssignControllerReply(sourceNodeId:UInt64, destinationNodeId:UInt64, result:UInt8) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlReply)

    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.controllerConfiguration.rawValue,
      OpenLCBTractionControllerConfigurationType.assignController.rawValue,
      result,
/*    0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00, */
    ]
    
    sendMessage(message: message)
    
  }

  public func sendQueryFunctionReply(sourceNodeId:UInt64, destinationNodeId:UInt64, address:UInt32, value:UInt16) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlReply)

    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.queryFunction.rawValue
    ]
    
    var bed = address.bigEndianData
    bed.removeFirst()
    
    message.payload.append(contentsOf: bed)
    
    message.payload.append(contentsOf: value.bigEndianData)
    
    sendMessage(message: message)
    
  }

  public func sendTerminateDueToError(sourceNodeId:UInt64, destinationNodeId:UInt64, errorCode:OpenLCBErrorCode) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .terminateDueToError)

    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    message.payload = errorCode.bigEndianData
    
    sendMessage(message: message)
    
  }

  public func sendQuerySpeedReply(sourceNodeId:UInt64, destinationNodeId:UInt64, setSpeed:Float, commandedSpeed:Float, emergencyStop:Bool) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlReply)

    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.querySpeeds.rawValue
    ]
    
    message.payload.append(contentsOf: setSpeed.float16.v.bigEndianData)
    message.payload.append(emergencyStop ? 0x01 : 0x00)
    message.payload.append(contentsOf: commandedSpeed.float16.v.bigEndianData)
    message.payload.append(contentsOf: [0xff, 0xff])
//  message.payload.append(contentsOf: [0x00, 0x00, 0x00])
    
    sendMessage(message: message)
    
  }

  public func sendSetSpeedDirection(sourceNodeId:UInt64, destinationNodeId:UInt64, setSpeed:Float, isForwarded: Bool) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlCommand)

    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.setSpeedDirection.rawValue | (isForwarded ? 0x80 : 0x00)
    ]
    
    message.payload.append(contentsOf: setSpeed.float16.v.bigEndianData)

//  message.payload.append(contentsOf: [0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
    
    sendMessage(message: message)
    
  }

  public func sendSetFunction(sourceNodeId:UInt64, destinationNodeId:UInt64, address:UInt32, value:UInt16, isForwarded: Bool) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlCommand)

    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.setFunction.rawValue | (isForwarded ? 0x80 : 0x00)
    ]
    
    var adr = address.bigEndianData
    adr.removeFirst()
    
    message.payload.append(contentsOf: adr)
    
    message.payload.append(contentsOf: value.bigEndianData)

//  message.payload.append(contentsOf: [0x00, 0x00, 0x00])
    
    sendMessage(message: message)
    
  }

  public func sendEmergencyStop(sourceNodeId:UInt64, destinationNodeId:UInt64, isForwarded: Bool) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlCommand)

    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.emergencyStop.rawValue | (isForwarded ? 0x80 : 0x00)
    ]
    
    sendMessage(message: message)
    
  }

  public func sendAssignListenerReply(sourceNodeId:UInt64, destinationNodeId:UInt64, listenerNodeId:UInt64, replyCode:OpenLCBErrorCode) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlReply)

    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.listenerConfiguration.rawValue,
      OpenLCBTractionListenerConfigurationType.attachNode.rawValue,
    ]
    
    var ln = listenerNodeId.bigEndianData
    ln.removeFirst(2)
    
    message.payload.append(contentsOf: ln)
    
    message.payload.append(contentsOf: replyCode.rawValue.bigEndianData)
    
//  message.payload.append(0)

    sendMessage(message: message)
    
  }

  public func sendListenerQueryNodeReply(sourceNodeId:UInt64, destinationNodeId:UInt64, nodeCount:Int, nodeIndex:Int, flags:UInt8, listenerNodeId:UInt64) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlReply)

    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    let nc = UInt8(min(0xff, nodeCount) & 0xff)
    
    message.payload = [
      OpenLCBTractionControlInstructionType.listenerConfiguration.rawValue,
      OpenLCBTractionListenerConfigurationType.queryNodes.rawValue,
      nc,
      UInt8(nodeIndex),
      flags
    ]
    
    var ln = listenerNodeId.bigEndianData
    ln.removeFirst(2)
    
    message.payload.append(contentsOf: ln)
    
    sendMessage(message: message)
    
  }

  public func sendListenerQueryNodeReplyShort(sourceNodeId:UInt64, destinationNodeId:UInt64, nodeCount:Int) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlReply)

    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    let nc = UInt8(min(0xff, nodeCount) & 0xff)
    
    message.payload = [
      OpenLCBTractionControlInstructionType.listenerConfiguration.rawValue,
      OpenLCBTractionListenerConfigurationType.queryNodes.rawValue,
      nc,
    ]
    
    sendMessage(message: message)
    
  }
  
  public func sendHeartbeatRequest(sourceNodeId:UInt64, destinationNodeId:UInt64, timeout:UInt8) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlReply)

    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.tractionManagement.rawValue,
      OpenLCBTractionManagementType.noopOrHeartbeatRequest.rawValue,
      timeout
    ]
    
    sendMessage(message: message)
    
  }

  // MARK: TransportLayerDelegate Methods
  
  public func openLCBMessageReceived(message: OpenLCBMessage) {
    
    for (_, virtualNode) in virtualNodes {
      virtualNode.openLCBMessageReceived(message: message)
    }

    for (_, observer) in observers {
      observer.openLCBMessageReceived(message: message)
    }
    
  }
  
  public func transportLayerStateChanged(transportLayer: OpenLCBTransportLayer) {
    
    let lastState = state
    
    switch transportLayer.isActive {
      case true:
      
        if state == .uninitialized {
          // Wait for all transport layers to go active
          for (_, transportLayer) in transportLayers {
            if !transportLayer.isActive {
              return
            }
          }
          _state = .initialized
          for (_, transportLayer) in transportLayers {
            for (_, virtualNode) in virtualNodes {
              transportLayer.registerNode(node: virtualNode)
            }
          }
          
        }
      case false:
      
        removeTransportLayer(transportLayer: transportLayer)
        if state == .initialized {
          // Wait for all transport layers are inactive
          if !transportLayers.isEmpty {
            return
          }
          _state = .uninitialized
        }
      
    }
    
    if state != lastState {
      for (_, observer) in observers {
        observer.networkLayerStateChanged(networkLayer: self)
      }
    }

  }
  
}
