//
//  OpenOpenLCBCANGateway - Alias Mapping.swift
//  MyTrains
//
//  Created by Paul Willmott on 16/02/2024.
//

import Foundation

extension OpenLCBCANGateway {
  
  internal func addNodeIdAliasMapping(nodeId: UInt64, alias:UInt16) {
    
    aliasLookup[alias] = nodeId
    nodeIdLookup[nodeId] = alias
    /*
    for item in inputQueue {
      if let sourceAlias = item.sourceNIDAlias, sourceAlias == alias {
        item.sourceNodeId = nodeId
      }
      if let destAlias = item.destinationNIDAlias, destAlias == alias {
        item.destinationNodeId = nodeId
      }
    }
    
    for item in outputQueue {
      if let sourceId = item.sourceNodeId, sourceId == nodeId {
        item.sourceNIDAlias = alias
      }
      if let destId = item.destinationNodeId, destId == nodeId {
        item.destinationNIDAlias = alias
      }
    }
    */
  }
  
  internal func removeNodeIdAliasMapping(nodeId:UInt64) {
    if let alias = nodeIdLookup[nodeId] {
      aliasLookup.removeValue(forKey: alias)
      nodeIdLookup.removeValue(forKey: nodeId)
    }
  }
  
  internal func removeNodeIdAliasMapping(alias:UInt16) {
    if let nodeId = aliasLookup[alias] {
      aliasLookup.removeValue(forKey: alias)
      nodeIdLookup.removeValue(forKey: nodeId)
    }
  }
  
  internal func addManagedNodeIdAliasMapping(item:OpenLCBTransportLayerAlias) {
    if let alias = item.alias {
      managedAliasLookup[alias] = item
      managedNodeIdLookup[item.nodeId] = item
    }
  }
  
  internal func removeManagedNodeIdAliasMapping(nodeId:UInt64) {
    if let item = managedNodeIdLookup[nodeId] {
      managedAliasLookup.removeValue(forKey: item.alias!)
      managedNodeIdLookup.removeValue(forKey: nodeId)
    }
  }
  
  internal func removeManagedNodeIdAliasMapping(alias:UInt16) {
    if let item = managedAliasLookup[alias] {
      managedAliasLookup.removeValue(forKey: alias)
      managedNodeIdLookup.removeValue(forKey: item.nodeId)
    }
  }
  
  #if DEBUG
  internal func testPRNG() {
    
    //   let nodeId : UInt64 = 0x0000020203000540
    let nodeId : UInt64   = 0x0000000000000000
    //   let nodeId : UInt64   = 0x0000020121000012
    
    var lfsr1 : UInt32
    
    var lfsr2 : UInt32
    
    lfsr1 = UInt32(nodeId >> 24)
    
    lfsr2 = UInt32(nodeId & 0xffffff)
    
    for index in 0...15 {
      
      print("\(index):  \(((UInt64(lfsr1) << 24) | UInt64(lfsr2)).toHexDotFormat(numberOfBytes: 6))  ",terminator: "")
      
      let result = UInt16((lfsr1 ^ lfsr2 ^ (lfsr1 >> 12) ^ (lfsr2 >> 12) ) & 0xFFF)
      
      let temp1 : UInt32 = ((lfsr1 << 9) | ((lfsr2 >> 15) & 0x1FF)) & 0xFFFFFF
      let temp2 : UInt32 = (lfsr2 << 9) & 0xFFFFFF
      
      // add
      
      lfsr2 += temp2 + 0x7A4BA9
      
      lfsr1 += temp1 + 0x1B0CA3
      
      // carry
      
      lfsr1 = (lfsr1 & 0xFFFFFF) + ((lfsr2 & 0xFF000000) >> 24)
      lfsr2 &= 0xFFFFFF
      
      // Form a 12-bit alias from the PRNG state:
      
      //      let result = UInt16((lfsr1 ^ lfsr2 ^ (lfsr1 >> 12) ^ (lfsr2 >> 12) ) & 0xFFF)
      
      print(" 0x\(result.toHex(numberOfDigits: 3))   \(((UInt64(lfsr1) << 24) | UInt64(lfsr2)).toHexDotFormat(numberOfBytes: 6))")
      
    }
    
  }
  #endif
  
  internal func nextAlias() -> UInt16 {
    
    // The PRNG state is stored in two 32-bit quantities:
    // uint32_t lfsr1, lfsr2; // sequence value: lfsr1 is upper 24 bits, lfsr2 lower
    
    // The 6-byte unique Node ID is stored in the nid[0:5] array.
    
    // To load the PRNG from the Node ID:
    // lfsr1 = (nid[0] << 16) | (nid[1] << 8) | nid[2]; // upper bits
    // lfsr2 = (nid[3] << 16) | (nid[4] << 8) | nid[5];
    
    // Form a 12-bit alias from the PRNG state:
    
    let result = UInt16((self.lfsr1 ^ self.lfsr2 ^ (self.lfsr1 >> 12) ^ (self.lfsr2 >> 12) ) & 0xFFF)
    
    // To step the PRNG:
    // First, form 2^9*val
    
    let temp1 : UInt32 = ((self.lfsr1 << 9) | ((self.lfsr2 >> 15) & 0x1FF)) & 0xFFFFFF
    let temp2 : UInt32 = (self.lfsr2 << 9) & 0xFFFFFF
    
    // add
    
    self.lfsr2 += temp2 + 0x7A4BA9
    
    self.lfsr1 += temp1 + 0x1B0CA3
    
    // carry
    
    self.lfsr1 = (self.lfsr1 & 0xFFFFFF) + ((self.lfsr2 & 0xFF000000) >> 24)
    self.lfsr2 &= 0xFFFFFF
    
    return result
    
  }
  
  internal func getAlias() {
   
    guard let item = initNodeQueue.first, item.transitionState == .idle else {
      return
    }
      
    item.transitionState = .testingAlias
    item.state = .inhibited
    let alias = nextAlias()
    item.alias = alias
    
    sendCheckIdFrame(format: .checkId7Frame, nodeId: item.nodeId, alias: alias)
    sendCheckIdFrame(format: .checkId6Frame, nodeId: item.nodeId, alias: alias)
    sendCheckIdFrame(format: .checkId5Frame, nodeId: item.nodeId, alias: alias)
    sendCheckIdFrame(format: .checkId4Frame, nodeId: item.nodeId, alias: alias)
    
    startAliasTimer(interval: aliasWaitInterval)

  }
  
  // MARK: Alias Timer Methods
  
  internal func startAliasTimer(interval: TimeInterval) {
    aliasTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(aliasTimerAction), userInfo: nil, repeats: false)
    RunLoop.current.add(aliasTimer!, forMode: .common)
  }
  
  internal func stopAliasTimer() {
    aliasTimer?.invalidate()
    aliasTimer = nil
  }
  
  @objc internal func aliasTimerAction() {
    
    aliasTimer = nil
    
    guard let item = initNodeQueue.first, let alias = item.alias else {
      return
    }
    
    switch item.transitionState {
      
    case .testingAlias:
      
      //  Wait at least 200 milliseconds
      //  Transmit a Reserve ID frame (RID) with the tentative source Node ID alias value in the Source
      //  NID Alias field.
      
      item.transitionState = .reservingAlias
      sendReserveIdFrame(alias: alias)
      
      // The standard does not say how long to wait after sending the Reserve ID frame (RID), so just
      // use the same 200 milliseconds as the previous wait.
      
      startAliasTimer(interval: aliasWaitInterval)
      
    case .reservingAlias:
      
      // The alias is reserved when that sequence completes without error.
      // To transition from the Inhibited state to the Permitted state, a node shall, in order:
      // • Have or obtain a validly reserved Node ID alias
      // • Transmit an Alias Map Definition (AMD) frame with the node's Node ID alias and Node ID
      
      initNodeQueue.removeFirst()

      item.transitionState = .mappingDeclared
      item.state = .permitted
      addNodeIdAliasMapping(nodeId: item.nodeId, alias: alias)
      addManagedNodeIdAliasMapping(item: item)

      sendAliasMapDefinitionFrame(nodeId: item.nodeId, alias: alias)
      
      getAlias()
      
    default:
      break
    }
    
  }
  
}

