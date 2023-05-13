//
//  LCCNetworkLayer.swift
//  MyTrains
//
//  Created by Paul Willmott on 08/04/2023.
//

import Foundation

public class LCCNetworkLayer : NSObject, LCCTransportLayerDelegate {
  
  // MARK: Constructors
  
  public init(nodeId: UInt64) {
    
    self.nodeId = nodeId
    
    super.init()
    
  }
  
  // MARK: Private Properties
  
  internal var _state : LCCNetworkLayerState = .uninitialized
  
  private var nextObserverId : Int = 0
  
  private var observers : [Int:LCCNetworkLayerDelegate] = [:]
  
  // MARK: Public Properties
  
  public var state : LCCNetworkLayerState {
    get {
      return _state
    }
  }
  
  public var nodeId : UInt64
  
  public var transportLayers : [ObjectIdentifier:LCCTransportLayer] = [:]
  
  public var externalLCCNodes : [UInt64:OpenLCBNode] = [:]
  
  // MARK: Public Methods
  
  public func addTransportLayer(transportLayer: LCCTransportLayer) {
    transportLayers[ObjectIdentifier(transportLayer)] = transportLayer
    transportLayer.delegate = self
    transportLayer.transitionToPermittedState()

  }
  
  public func removeAlias(destinationNodeId:UInt64) {
    for (_, layer) in transportLayers {
      layer.removeAlias(destinationNodeId: destinationNodeId)
    }
  }

  public func removeTransportLayer(transportLayer: LCCTransportLayer) {
    transportLayer.transitionToInhibitedState()
  }
  
  public func addObserver(observer:LCCNetworkLayerDelegate) -> Int{
    let id = nextObserverId
    nextObserverId += 1
    observers[id] = observer
    return id
  }
  
  public func removeObserver(observerId:Int) {
    observers.removeValue(forKey: observerId)
  }
  
  // MARK: Messages
  
  internal func sendMessage(message:OpenLCBMessage) {
    
    guard state == .initialized else {
      return
    }
    
    for (_, transportLayer) in transportLayers {
      transportLayer.addToOutputQueue(message: message)
    }
    
  }
  
  public func sendInitializationComplete() {
    
    let message = OpenLCBMessage(messageTypeIndicator: .initializationComplete)
    
    var data : [UInt8] = []
    for index in 0...5 {
      data.append(UInt8((nodeId >> ((5 - index) * 8))  & 0xff))
    }
    
    message.payload = data
    
    sendMessage(message: message)
    
  }

  public func sendVerifyNodeIdNumber() {
    
    let message = OpenLCBMessage(messageTypeIndicator: .verifyNodeIDNumberGlobal)
    
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

    var data = [0x20, OpenLCBDatagramType.LockReserveCommand.rawValue, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]
    
    sendDatagram(sourceNodeId: sourceNodeId, destinationNodeId: destinationNodeId, data: data)
    
  }

  public func sendRebootCommand(sourceNodeId:UInt64, destinationNodeId:UInt64) {

    var data = [0x20, OpenLCBDatagramType.resetRebootCommand.rawValue]
    
    sendDatagram(sourceNodeId: sourceNodeId, destinationNodeId: destinationNodeId, data: data)
    
    removeAlias(destinationNodeId: destinationNodeId)
    
  }

  public func sendResetToDefaults(sourceNodeId:UInt64, destinationNodeId:UInt64) {

    var data = destinationNodeId.bigEndianData
    data.removeFirst(2)

    data.insert(OpenLCBDatagramType.reinitializeFactoryResetCommand.rawValue, at: 0)
    data.insert(0x20, at: 0)

    sendDatagram(sourceNodeId: sourceNodeId, destinationNodeId: destinationNodeId, data: data)
    
    removeAlias(destinationNodeId: destinationNodeId)
    
  }

  public func sendVerifyNodeIdNumber(nodeId:UInt64) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .verifyNodeIDNumberGlobal)
    
    var data : [UInt8] = []
    for index in 0...5 {
      data.append(UInt8((nodeId >> ((5 - index) * 8))  & 0xff))
    }
    
    message.payload = data
    
    sendMessage(message: message)
    
  }

  public func sendVerifiedNodeIdNumber() {
    
    let message = OpenLCBMessage(messageTypeIndicator: .verifiedNodeIDNumber)
    
    var data : [UInt8] = []
    for index in 0...5 {
      data.append(UInt8((nodeId >> ((5 - index) * 8))  & 0xff))
    }
    
    message.payload = data
    
    sendMessage(message: message)
    
  }

  public func sendProtocolSupportInquiry(nodeId:UInt64) {

    let message = OpenLCBMessage(messageTypeIndicator: .protocolSupportInquiry)
    
    message.destinationNodeId = nodeId
    
    sendMessage(message: message)

  }
  
  public func sendSimpleNodeInformationRequest(nodeId:UInt64) {

    let message = OpenLCBMessage(messageTypeIndicator: .simpleNodeIdentInfoRequest)
    
    message.destinationNodeId = nodeId
    
    sendMessage(message: message)

  }
  
  // MARK: TransportLayerDelegate Methods
  
  public func openLCBMessageReceived(message: OpenLCBMessage) {
    
    if let _ = externalLCCNodes[message.sourceNodeId!] {
    }
    else {
      externalLCCNodes[message.sourceNodeId!] = OpenLCBNode(nodeId: message.sourceNodeId!)
    }
    
    switch message.messageTypeIndicator {
    case .verifyNodeIDNumberGlobal:
      if message.payloadAsHex == nodeId.toHex(numberOfDigits: 12) {
        sendVerifiedNodeIdNumber()
      }
    default:
      break
    }

    for (_, observer) in observers {
      observer.openLCBMessageReceived(message: message)
    }
    
  }
  
  public func transportLayerStateChanged(transportLayer: LCCTransportLayer) {
    
    switch transportLayer.state {
    case .inhibited:
      transportLayer.delegate = nil
      transportLayers.removeValue(forKey: ObjectIdentifier(transportLayer))
      if transportLayers.isEmpty {
        _state = .uninitialized
        for (_, observer) in observers {
          observer.networkLayerStateChanged(networkLayer: self)
        }
      }
    case .permitted:
      let stateChanged = state != .initialized
      _state = .initialized
      sendInitializationComplete()
      if stateChanged {
        for (_, observer) in observers {
          observer.networkLayerStateChanged(networkLayer: self)
        }
      }
    case .stopped:
      break
    }
    
  }
  
}
