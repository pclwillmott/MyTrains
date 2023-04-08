//
//  LCCCANTransportLayer.swift
//  MyTrains
//
//  Created by Paul Willmott on 02/04/2023.
//

import Foundation

private enum LCCCANTransportTransitionState {
  case idle
  case testingAlias
  case reservingAlias
  case mappingDeclared
}

public class LCCCANTransportLayer : LCCTransportLayer, InterfaceDelegate {
  
  // MARK: Constructors & Destructors
  
  init(interface:Interface, nodeId:UInt64) {
    
    self.interface = interface
    
    self.nodeId = nodeId
    
    self.lfsr1 = UInt32(nodeId >> 24)
    
    self.lfsr2 = UInt32(nodeId & 0xffffff)

  }
  
  // MARK: Private Properties
  
  private let waitInterval : TimeInterval = 200.0 / 1000.0

  private var lfsr1 : UInt32
  
  private var lfsr2 : UInt32
  
  private var waitTimer : Timer?
  
  private var transitionState : LCCCANTransportTransitionState = .idle
  
  private var observerId : Int = -1
  
  private var aliasLookup : [UInt16:String] = [:]
  
  private var nodeIdLookup : [String:UInt16] = [:]
  
  // MARK: Public Properties
  
  public var interface : Interface
  
  public var nodeId : UInt64
  
  public var nodeIdAsString : String {
    get {
      var id = ""
      var temp = nodeId
      for _ in 1...6 {
        id = String(format:"%02X", UInt16(temp & 0xFF)) + id
        temp >>= 8
      }
      return id
    }
  }
  
  public var alias : UInt16?
  
  // MARK: Private Methods
  
  override func send() {
    
    var index = 0
    
    while index < outputQueue.count {
      
      var deleteMessage = false
      
      let message = outputQueue[index]

      switch message.canFrameType {
        
      case 1:
        
        if message.isAddressPresent {
          if let destinationNodeId = message.destinationNodeId {
            if let destinationAlias = nodeIdLookup[destinationNodeId] {
              // TODO: send message
            }
            else {
              // TODO: send a request here
            }
          }
          else {
            deleteMessage = true
          }
        }
        
      // Delete messages we don't understand yet
        
      default:
        deleteMessage = true
      }
      
      if deleteMessage {
        outputQueueLock.lock()
        outputQueue.remove(at: index)
        outputQueueLock.unlock()
      }

    }
    
  }
  
  private func addNodeIdAliasMapping(nodeId: String, alias:UInt16) {
    aliasLookup[alias] = nodeId
    nodeIdLookup[nodeId] = alias
  }
  
  private func removeNodeIdAliasMapping(nodeId:String) {
    if let alias = nodeIdLookup[nodeId] {
      aliasLookup[alias] = nil
      nodeIdLookup[nodeId] = nil
    }
  }
  
  private func removeNodeIdAliasMapping(alias:UInt16) {
    if let nodeId = aliasLookup[alias] {
      nodeIdLookup[nodeId] = nil
      aliasLookup[alias] = nil
    }
  }
  
  private func nextAlias() -> UInt16 {
    
    // The PRNG state is stored in two 32-bit quantities:
    // uint32_t lfsr1, lfsr2; // sequence value: lfsr1 is upper 24 bits, lfsr2 lower
    
    // The 6-byte unique Node ID is stored in the nid[0:5] array.
    
    // To load the PRNG from the Node ID:
    // lfsr1 = (nid[0] << 16) | (nid[1] << 8) | nid[2]; // upper bits
    // lfsr2 = (nid[3] << 16) | (nid[4] << 8) | nid[5];
    
    // To step the PRNG:
    // First, form 2^9*val
    
    var temp1 : UInt32 = ((lfsr1 << 9) | ((lfsr2 >> 15) & 0x1FF)) & 0xFFFFFF
    var temp2 : UInt32 = (lfsr2 << 9) & 0xFFFFFF
    
    // add
    
    lfsr2 += temp2 + 0x7A4BA9
    
    lfsr1 += temp1 + 0x1B0CA3
    
    // carry
    
    lfsr1 = (lfsr1 & 0xFFFFFF) + ((lfsr2 & 0xFF000000) >> 24)
    lfsr2 &= 0xFFFFFF
    
    // Form a 12-bit alias from the PRNG state:
    
    return UInt16((lfsr1 ^ lfsr2 ^ (lfsr1 >> 12) ^ (lfsr2 >> 12) ) & 0xFFF)
    
  }
  
  @objc func waitTimerTick() {
    
    stopWaitTimer()
    
    switch transitionState {
    case .testingAlias:
      transitionState = .reservingAlias
      interface.send(header: createReserveIdFrame(), data: "")
      startWaitTimer(interval: waitInterval)
    case .reservingAlias:
      transitionState = .mappingDeclared
      _state = .permitted
      interface.send(header: createAliasMapDefinitionFrame(), data: nodeIdAsString)
    default:
      break
    }

  }
  
  func startWaitTimer(interval: TimeInterval) {
    waitTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(waitTimerTick), userInfo: nil, repeats: false)
    RunLoop.current.add(waitTimer!, forMode: .common)
  }
  
  func stopWaitTimer() {
    waitTimer?.invalidate()
    waitTimer = nil
  }

  private func createCheckIdFrame(number:UInt16) -> String {
    
    var variableField : UInt16 = (8 - number) << 12
    
    variableField |= UInt16((nodeId >> ((4 - number) * 12)) & 0x0fff)
    
    let header = LCCCANFrame.createFrameHeader(frameType: .canControlFrame, variableField: variableField, sourceNIDAlias: alias!)
    
    return "\(String(format: "%08X", header))"
    
  }

  private func createReserveIdFrame() -> String {
    
    var variableField : UInt16 = 0x0700
    
    let header = LCCCANFrame.createFrameHeader(frameType: .canControlFrame, variableField: variableField, sourceNIDAlias: alias!)
    
    return "\(String(format: "%08X", header))"
    
  }

  private func createAliasMapDefinitionFrame() -> String {
    
    var variableField : UInt16 = 0x0701
    
    let header = LCCCANFrame.createFrameHeader(frameType: .canControlFrame, variableField: variableField, sourceNIDAlias: alias!)
    
    return "\(String(format: "%08X", header))"
    
  }

  private func createAliasMapResetFrame() -> String {
    
    var variableField : UInt16 = 0x0703
    
    let header = LCCCANFrame.createFrameHeader(frameType: .canControlFrame, variableField: variableField, sourceNIDAlias: alias!)
    
    return "\(String(format: "%08X", header))"
    
  }

  private func createDuplicateNodeIdErrorFrame(alias:UInt16) -> String {
    
    var header : UInt32 = 0x195B4000
    
    header |= UInt32(alias & 0x0fff)

    return "\(String(format: "%08X", header))"
    
  }

  // MARK: Public Methods
  
  public func transitionToPermittedState() {
    
    guard state == .inhibited else {
      return
    }
    
    if observerId != -1 {
      interface.removeObserver(id: observerId)
    }
    
    observerId = interface.addObserver(observer: self)

    transitionState = .testingAlias
    
    alias = nextAlias()
    
    interface.send(header: createCheckIdFrame(number: 1), data: "")
    interface.send(header: createCheckIdFrame(number: 2), data: "")
    interface.send(header: createCheckIdFrame(number: 3), data: "")
    interface.send(header: createCheckIdFrame(number: 4), data: "")

    startWaitTimer(interval: waitInterval)
    
  }
  
  public func transitionToInhibitedState() {
    
    guard state == .permitted else {
      return
    }
    
    transitionState = .idle
    
    _state = .inhibited
    
    interface.send(header: createAliasMapResetFrame(), data: nodeIdAsString)
    
    alias = nil
    
    if observerId != -1 {
      interface.removeObserver(id: observerId)
      observerId = -1
    }
    
  }
  
  // MARK: InterfaceDelegate Methods
  
  @objc public func lccCANFrameReceived(frame:LCCCANFrame) {
    
    guard state != .stopped else {
      return
    }
    
    switch frame.frameType {
      
    case .canControlFrame:
      
      if let alias = self.alias {
        
        // Testing an alias
        
        if (transitionState == .testingAlias || transitionState == .reservingAlias) {
          
          if frame.sourceNIDAlias == alias {
            
            stopWaitTimer()
            
            _state = .inhibited
            
            self.alias = nil
            
            transitionState = .idle
            
            transitionToPermittedState()
            
            return
            
          }
          
        }
        else if state == .permitted {
          
          // Node Id Alias Validation
          
          if frame.canFrameFormat == .aliasMappingEnquiryFrame {
            
            let nidas = nodeIdAsString
            
            if frame.dataAsString.isEmpty || frame.dataAsString == nidas {
              interface.send(header: createAliasMapDefinitionFrame(), data: nidas)
            }
            
            return
            
          }
          
        }
        
        // Node Id Collision Handling
        
        let cidSet : Set<LCCCANFrameFormat> = [.checkId4Frame, .checkId5Frame, .checkId6Frame, .checkId7Frame]
        
        if frame.sourceNIDAlias == alias {
          
          // Is a CID Frame
          
          if cidSet.contains(frame.canFrameFormat) {
            interface.send(header: createReserveIdFrame(), data: "")
            return
          }
          
          // Is not a CID Frame
          
          else if state == .permitted {
            transitionToInhibitedState()
            transitionToPermittedState()
          }
          
        }
        
        // Remove lookups for reset mappings
        
        if frame.canFrameFormat == .aliasMapResetFrame {
          removeNodeIdAliasMapping(alias: frame.sourceNIDAlias)
          return
        }
        
        // Check for Duplicate NodeId
        
        if frame.canFrameFormat == .aliasMapDefinitionFrame {
          
          if nodeIdAsString == frame.dataAsString {
            _state = .stopped
            interface.send(header: createDuplicateNodeIdErrorFrame(alias: alias), data: "0101000000000201")
            interface.removeObserver(id: observerId)
            observerId = -1
            transitionState = .idle
            self.alias = nil
            delegate?.transportLayerStateChanged(transportLayer: self)
            return
          }
          
          addNodeIdAliasMapping(nodeId: frame.dataAsString, alias: frame.sourceNIDAlias)
          
        }
        
      }

    case .openLCBMessage:
      break
    }
    
  }

}
