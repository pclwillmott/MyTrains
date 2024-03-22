//
//  OpenOpenLCBCANGateway - Alias Mapping.swift
//  MyTrains
//
//  Created by Paul Willmott on 16/02/2024.
//

import Foundation

extension OpenLCBCANGateway {

  internal func insertNodeId(message:OpenLCBMessage) -> [LCCCANFrame] {
    
    var frames : [LCCCANFrame] = []
    
    if let sourceAlias = message.sourceNIDAlias, message.sourceNodeId == nil {
      if let sourceNodeId = aliasLookup[sourceAlias] {
        message.sourceNodeId = sourceNodeId
      }
      else if !waitingForNodeId.contains(sourceAlias) {
        waitingForNodeId.insert(sourceAlias)
        frames.append(contentsOf: createVerifyNodeIdAddressedCANFrame(destinationNodeIdAlias: sourceAlias))
      }
    }

    if let destinationAlias = message.destinationNIDAlias, message.destinationNodeId == nil {
      if let nodeId = aliasLookup[destinationAlias] {
        message.destinationNodeId = nodeId
      }
      else if !waitingForNodeId.contains(destinationAlias) {
        waitingForNodeId.insert(destinationAlias)
        frames.append(contentsOf: createVerifyNodeIdAddressedCANFrame(destinationNodeIdAlias: destinationAlias))
      }
    }

    return frames
    
  }

  internal func insertAlias(message:OpenLCBMessage) -> [LCCCANFrame] {
    
    var frames : [LCCCANFrame] = []
    
    if let sourceNodeId = message.sourceNodeId, message.sourceNIDAlias == nil {
      if let alias = nodeIdLookup[sourceNodeId] {
        message.sourceNIDAlias = alias
      }
      else if !waitingForAlias.contains(sourceNodeId) {
        #if DEBUG
        debugLog("message without a source id alias")
        #endif
      }
    }

    if let destinationNodeId = message.destinationNodeId, message.destinationNIDAlias == nil {
      if let alias = nodeIdLookup[destinationNodeId] {
        message.destinationNIDAlias = alias
      }
      else if !waitingForAlias.contains(destinationNodeId) {
        waitingForAlias.insert(destinationNodeId)
        frames.append(contentsOf: createVerifyNodeIdGlobalCANFrame(destinationNodeId: destinationNodeId))
      }
    }

    return frames
    
  }
  
  internal func addNodeIdAliasMapping(nodeId: UInt64, alias:UInt16) {
    
    aliasLookup[alias] = nodeId
    nodeIdLookup[nodeId] = alias
    
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
    
    waitingForNodeId.remove(alias)
    waitingForAlias.remove(nodeId)
    
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
    managedAliasLookup[item.alias] = item
    managedNodeIdLookup[item.nodeId] = item
  }
  
  internal func removeManagedNodeIdAliasMapping(nodeId:UInt64) {
    if let item = managedNodeIdLookup[nodeId] {
      managedAliasLookup.removeValue(forKey: item.alias)
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
      
      debugLog("\(index):  \(((UInt64(lfsr1) << 24) | UInt64(lfsr2)).toHexDotFormat(numberOfBytes: 6)) ,terminator: ")
      
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
      
      debugLog(" 0x\(result.toHex(numberOfDigits: 3))   \(((UInt64(lfsr1) << 24) | UInt64(lfsr2)).toHexDotFormat(numberOfBytes: 6))")
      
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
    
  // MARK: Alias Timer Methods
  
  internal func startAliasTimer() {
    aliasTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(aliasTimerAction), userInfo: nil, repeats: true)
    RunLoop.current.add(aliasTimer!, forMode: .common)
  }
  
  internal func stopAliasTimer() {
    aliasTimer?.invalidate()
    aliasTimer = nil
  }
  
  // This is running in the main thread
  @objc internal func aliasTimerAction() {
    
    aliasLock!.lock()
    
    let now = Date.timeIntervalSinceReferenceDate
    
    var frames : [LCCCANFrame] = []
    
    for (alias, item) in managedAliases {

      // Wait at least 200 milliseconds
      // Transmit a Reserve ID frame (RID) with the tentative source Node ID
      // alias value in the Source NID Alias field.

      if item.state == .testingAlias && now - item.timeStamp > 0.2 {
        item.state = .aliasReserved
        frames.append(contentsOf: createReserveIdFrame(alias: alias))
      }
      
    }
    
    var startGateway = false
    
    for nodeId in waitingForAlias {
 
      // The alias is reserved when that sequence completes without error.
      // To transition from the Inhibited state to the Permitted state, a node shall, in order:
      // • Have or obtain a validly reserved Node ID alias
      // • Transmit an Alias Map Definition (AMD) frame with the node's Node ID alias and Node ID

      var found = false
      
      for (alias, item) in managedAliases {
        
        if item.state == .aliasReserved {

          item.nodeId = nodeId
          item.state = .mappingDeclared
          addNodeIdAliasMapping(nodeId: item.nodeId, alias: alias)
          addManagedNodeIdAliasMapping(item: item)
          frames.append(contentsOf: createAliasMapDefinitionFrame(nodeId: nodeId, alias: alias))
          
          if nodeId == self.nodeId {
            let message = OpenLCBMessage(messageTypeIndicator: .initializationCompleteFullProtocolRequired)
            message.payload = nodeId.nodeIdBigEndianData
            message.sourceNIDAlias = alias
            if let frame = LCCCANFrame(message: message) {
              frames.append(frame)
            }
            startGateway = true
          }
          else {
            for message in outputQueue {
              if message.sourceNodeId! == nodeId {
                message.sourceNIDAlias = item.alias
              }
            }
          }
          
          found = true
          
          break
          
        }
        
      }
      
      if !found {
        break
      }
      
    }
    
    var numberOfAliasesBeingTested = 0
    
    var numberOfUnusedAliases = 0
    
    for (_, item) in managedAliases {
      if item.state != .mappingDeclared {
        numberOfUnusedAliases += 1
        if item.state == .testingAlias {
          numberOfAliasesBeingTested += 1
        }
      }
    }
    
    if numberOfUnusedAliases < Int(minAliasesToCache) {
      
      for _ in 1 ... Int(maxAliasesToCache) - numberOfUnusedAliases {
        
        let alias = nextAlias()
        
        let item = OpenLCBTransportLayerAlias(alias: alias, nodeId: nodeId)
        
        managedAliases[alias] = item
        
        frames.append(contentsOf: [
          createCheckIdFrame(format: .checkId7Frame, nodeId: nodeId, alias: alias),
          createCheckIdFrame(format: .checkId6Frame, nodeId: nodeId, alias: alias),
          createCheckIdFrame(format: .checkId5Frame, nodeId: nodeId, alias: alias),
          createCheckIdFrame(format: .checkId4Frame, nodeId: nodeId, alias: alias),
        ])
        
        numberOfAliasesBeingTested += 1
        
      }
      
    }
    
    aliasLock!.unlock()
    
    send(frames: frames, isBackgroundThread: false)
    
    if numberOfAliasesBeingTested == 0 && waitingForAlias.count == 0 {
      stopAliasTimer()
    }
    else if aliasTimer == nil {
      startAliasTimer()
    }
    
    if startGateway {
      startComplete()
    }
    
  }
  
}

