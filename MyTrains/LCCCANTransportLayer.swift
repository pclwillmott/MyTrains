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
  case cid1
  case cid2
  case cid3
  case cid4
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
  
  private var _state : LCCCANTransportLayerState = .inhibited
  
  private var transitionState : LCCCANTransportTransitionState = .inhibited
  
  private var observerId : Int = -1
  
  // MARK: Public Properties
  
  public var interface : Interface
  
  public var nodeId : UInt64
  
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
  
  private func createCheckIdFrame(number:UInt16) -> String {
    
    var variableField : UInt16 = (8 - number) << 12
    
    variableField |= UInt16((nodeId >> ((4 - number) * 12)) & 0x0fff)
    
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
    
    transitionState = .cid1
    
    interface.send(header: createCheckIdFrame(number: 1), data: "")
    interface.send(header: createCheckIdFrame(number: 2), data: "")
    interface.send(header: createCheckIdFrame(number: 3), data: "")
    interface.send(header: createCheckIdFrame(number: 4), data: "")

  }
  
  public func transitionToInhibitedState() {
    
    guard state == .permitted else {
      return
    }
    
    if observerId != -1 {
      interface.removeObserver(id: observerId)
      observerId = -1
    }
    
  }
  
}
