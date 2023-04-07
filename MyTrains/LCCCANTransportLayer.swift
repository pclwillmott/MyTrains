//
//  LCCCANTransportLayer.swift
//  MyTrains
//
//  Created by Paul Willmott on 02/04/2023.
//

import Foundation

public enum LCCCANTransportLayerState {
  case inhibited
  case permitted
}

public enum LCCCANTransportTransitionState {
  case inhibited
  case cid
  case rid
  case amd
  case permitted
}

public class LCCCANTransportLayer : NSObject, InterfaceDelegate {
  
  // MARK: Constructors & Destructors
  
  init(interface:Interface, nodeId:UInt64) {
    
    self.interface = interface
    
    self.nodeId = nodeId
    
    self.lfsr1 = UInt32(nodeId >> 24)
    
    self.lfsr2 = UInt32(nodeId & 0xffffff)

  }
  
  // MARK: Private Properties
  
  private var lfsr1 : UInt32
  
  private var lfsr2 : UInt32
  
  private var waitTimer : Timer?
  
  private var _state : LCCCANTransportLayerState = .inhibited
  
  private var transitionState : LCCCANTransportTransitionState = .inhibited
  
  private var observerId : Int = -1
  
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
  
  public var state : LCCCANTransportLayerState {
    get {
      return _state
    }
  }
  
  // MARK: Private Methods
  
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
    transitionState = .rid
    interface.send(header: createReserveIdFrame(), data: "")
    interface.send(header: createAliasMapDefinitionFrame(), data: nodeIdAsString)
    transitionState = .permitted
  }
  
  func startWaitTimer() {
    let waitInterval : TimeInterval = 250.0 / 1000.0
    waitTimer = Timer.scheduledTimer(timeInterval: waitInterval, target: self, selector: #selector(waitTimerTick), userInfo: nil, repeats: false)
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

  // MARK: Public Methods
  
  public func transitionToPermittedState() {
    
    guard state == .inhibited else {
      return
    }
    
    transitionState = .inhibited
    
    if observerId != -1 {
      interface.removeObserver(id: observerId)
    }
    
    observerId = interface.addObserver(observer: self)

    alias = nextAlias()
    
    transitionState = .cid
    
    interface.send(header: createCheckIdFrame(number: 1), data: "")
    interface.send(header: createCheckIdFrame(number: 2), data: "")
    interface.send(header: createCheckIdFrame(number: 3), data: "")
    interface.send(header: createCheckIdFrame(number: 4), data: "")

    startWaitTimer()
    
  }
  
  public func transitionToInhibitedState() {
    
    guard state == .permitted else {
      return
    }
    
    interface.send(header: createAliasMapResetFrame(), data: nodeIdAsString)
    
    if observerId != -1 {
      interface.removeObserver(id: observerId)
      observerId = -1
    }
    
    transitionState = .inhibited
    
  }
  
  // MARK: InterfaceDelegate Methods
  
  @objc public func lccCANFrameReceived(frame:LCCCANFrame) {
    
    if transitionState == .cid && frame.sourceNIDAlias == alias {
      startWaitTimer()
      transitionState = .inhibited
      transitionToPermittedState()
    }
    else if transitionState == .permitted {
      
      let cidSet : Set<LCCCANFrameFormat> = [.checkId4Frame, .checkId5Frame, .checkId6Frame, .checkId7Frame]
      
      if frame.canFrameFormat == .aliasMappingEnquiryFrame {
        
        if frame.dataAsString.isEmpty || frame.dataAsString == nodeIdAsString {
          interface.send(header: createAliasMapDefinitionFrame(), data: nodeIdAsString)
        }
        
      }
      else if cidSet.contains(frame.canFrameFormat) {
        if frame.sourceNIDAlias == self.alias! {
          interface.send(header: createReserveIdFrame(), data: "")
        }
      }
      else 
    }
    
  }

}
