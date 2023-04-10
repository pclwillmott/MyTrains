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
  
  // MARK: Public Methods
  
  public func addTransportLayer(transportLayer: LCCTransportLayer) {
    transportLayers[ObjectIdentifier(transportLayer)] = transportLayer
    transportLayer.delegate = self
    transportLayer.transitionToPermittedState()

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
    
    message.otherContent = data
    
    sendMessage(message: message)
    
    sendVerifyNodeIdNumber()
    
    sendProtocolSupportInquiry(nodeId: 0x020157000570)
    
  }

  public func sendVerifyNodeIdNumber() {
    
    let message = OpenLCBMessage(messageTypeIndicator: .verifyNodeIDNumberGlobal)
    
    sendMessage(message: message)
    
  }
  
  public func sendVerifyNodeIdNumber(nodeId:UInt64) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .verifyNodeIDNumberGlobal)
    
    var data : [UInt8] = []
    for index in 0...5 {
      data.append(UInt8((nodeId >> ((5 - index) * 8))  & 0xff))
    }
    
    message.otherContent = data
    
    sendMessage(message: message)
    
  }

  public func sendVerifiedNodeIdNumber() {
    
    let message = OpenLCBMessage(messageTypeIndicator: .verifiedNodeIDNumber)
    
    var data : [UInt8] = []
    for index in 0...5 {
      data.append(UInt8((nodeId >> ((5 - index) * 8))  & 0xff))
    }
    
    message.otherContent = data
    
    sendMessage(message: message)
    
  }

  public func sendProtocolSupportInquiry(nodeId:UInt64) {

    let message = OpenLCBMessage(messageTypeIndicator: .protocolSupportInquiry)
    
    message.destinationNodeId = nodeId
    
    sendMessage(message: message)

  }
  
  // MARK: TransportLayerDelegate Methods
  
  public func openLCBMessageReceived(message: OpenLCBMessage) {
    print("SRC: \(message.sourceNodeId!.toHex(numberOfDigits: 12))")
    print("MTI: \(message.messageTypeIndicator)")
    if message.isAddressPresent {
      print("DST: \(message.destinationNodeId!.toHex(numberOfDigits: 12))")
      print("FLG: \(message.flags)")
    }
    if message.isEventPresent {
      print("EVT: \(message.eventId!.toHex(numberOfDigits: 16))")
    }
    if !message.otherContent.isEmpty {
      print("OC: \(message.otherContentAsHex)")
    }
    print()
    
    switch message.messageTypeIndicator {
    case .verifyNodeIDNumberGlobal:
      if message.otherContentAsHex == nodeId.toHex(numberOfDigits: 12) {
        sendVerifiedNodeIdNumber()
      }
    default:
      break
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
