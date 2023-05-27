//
//  LCCCANTransportLayer.swift
//  MyTrains
//
//  Created by Paul Willmott on 02/04/2023.
//

import Foundation

public class OpenLCBTransportLayerCAN : OpenLCBTransportLayer, InterfaceDelegate {
  
  // MARK: Constructors & Destructors
  
  init(interface:Interface) {
    
    self.interface = interface
    
    super.init()
    
  }
  
  // MARK: Private Properties
  
  private var observerId : Int = -1
  
  private var initNodeQueue : [OpenLCBTransportLayerAlias] = []
  
  private var managedNodeIdLookup : [UInt64:OpenLCBTransportLayerAlias] = [:]
  
  private var managedAliasLookup : [UInt16:OpenLCBTransportLayerAlias] = [:]
  
  private let waitInterval : TimeInterval = 200.0 / 1000.0
  
  private let timeoutInterval : TimeInterval = 3.0
  
  private var isStopping : Bool = false

  private var waitTimer : Timer?
  
  private var aliasLock : NSLock = NSLock()
  
  private var inGetAlias : Bool = false
    
  private var aliasLookup : [UInt16:UInt64] = [:]
  
  private var nodeIdLookup : [UInt64:UInt16] = [:]
  
  private var splitFrames : [UInt64:LCCCANFrame] = [:]
  
  private var datagrams : [UInt32:OpenLCBMessage] = [:]
  
  private var datagramsAwaitingReceipt : [UInt32:OpenLCBMessage] = [:]
  
  private var inProcessQueue : Bool = false
  
  private var processQueueLock : NSLock = NSLock()
  
  // MARK: Public Properties
  
  public var interface : Interface
  
  // MARK: Private Methods
  
  override func processQueues() {
    
    processQueueLock.lock()
    let ok = !inProcessQueue
    if ok {
      inProcessQueue = true
    }
    processQueueLock.unlock()
    
    if !ok {
      return
    }
    
    // Input Queue
    
    let referenceDate = Date.timeIntervalSinceReferenceDate
    
    if !inputQueue.isEmpty {
      
      var sendQuery = false
      
      var index = 0
      
      while index < inputQueue.count {
        
        let message = inputQueue[index]
        
        if message.sourceNodeId == nil, let alias = message.sourceNIDAlias {
          if let id = aliasLookup[alias] {
       //     print("source id found: \(id.toHexDotFormat(numberOfBytes: 6))")
            message.sourceNodeId = id
          }
          else {
       //     print("source id not found: \(alias.toHex(numberOfDigits: 3))")
            sendQuery = true
          }
        }
        
        if (message.isAddressPresent || message.messageTypeIndicator == .datagram) && message.destinationNodeId == nil, let alias = message.destinationNIDAlias {
          if let id = aliasLookup[alias] {
       //     print("dest id found: \(id.toHexDotFormat(numberOfBytes: 6))")
            message.destinationNodeId = id
          }
          else {
      //      print("dest id not found: \(alias.toHex(numberOfDigits: 3))")
            sendQuery = true
          }
        }
        
        var delete = false
        
        if message.isMessageComplete {
          
          switch message.messageTypeIndicator {
          case .initializationCompleteSimpleSetSufficient, .initializationCompleteFullProtocolRequired:
            for (key, datagram) in datagramsAwaitingReceipt {
              if datagram.destinationNodeId == message.sourceNodeId {
                datagramsAwaitingReceipt.removeValue(forKey: key)
              }
            }
          case .datagramReceivedOK:
            datagramsAwaitingReceipt.removeValue(forKey: message.datagramIdReversed)
          case .datagramRejected:
            if let datagram = datagramsAwaitingReceipt[message.datagramIdReversed] {
              datagramsAwaitingReceipt.removeValue(forKey: message.datagramIdReversed)
              if message.errorCode.isTemporary {
                addToOutputQueue(message: datagram)
              }
            }
          default:
            break
          }

          self.delegate?.openLCBMessageReceived(message: message)
 
          delete = true
          
        }
        else if (referenceDate - message.timeStamp) > timeoutInterval {
          print("timeout: \(message.messageTypeIndicator)")
          delete = true
        }
        
        if delete {
          inputQueueLock.lock()
          inputQueue.remove(at: index)
          inputQueueLock.unlock()
        }
        else {
          index += 1
        }
        
      }
      
      if sendQuery, let alias = nodeIdLookup[networkController.openLCBNodeId] {
        sendAliasMappingEnquiryFrame(alias: alias)
      }
            
    }
    
    // Output Queue
    
    if !outputQueue.isEmpty {
      
      var index = 0
      
      while index < outputQueue.count {
        
        let message = outputQueue[index]
        
        if let alias = nodeIdLookup[message.sourceNodeId!] {
          
          message.sourceNIDAlias = alias
          
          if (message.messageTypeIndicator == .datagram ) || message.isAddressPresent, let destinationNodeId = message.destinationNodeId {
            
            if let alias = nodeIdLookup[destinationNodeId] {
         //     print("dest alias found: \(destinationNodeId.toHexDotFormat(numberOfBytes: 6)) - \(alias.toHex(numberOfDigits: 3))")
              message.destinationNIDAlias = alias
            }
            else {
         //     print("dest id not found: \(destinationNodeId.toHexDotFormat(numberOfBytes: 6)))")
              sendAliasMappingEnquiryFrame(nodeId: destinationNodeId, alias: alias)
            }
            
          }
          
        }
        else {
          /*
          for (nodeId, alias) in nodeIdLookup {
            print("\(nodeId.toHexDotFormat(numberOfBytes: 6)) - 0x\(alias.toHex(numberOfDigits: 3))")
          }
          print("send source alias not found: \(message.sourceNodeId!.toHexDotFormat(numberOfBytes: 6))")
           */
        }
        
        var delete = false
        
        if message.isMessageComplete {
          
          if message.messageTypeIndicator == .datagram {

            datagramsAwaitingReceipt[message.datagramId] = message

            if message.payload.count <= 8 {
              if let frame = LCCCANFrame(networkId: interface.networkId, message: message, canFrameType: .datagramCompleteInFrame, data: message.payload) {
                interface.send(data: frame.message)
              }
            }
            else {
              
              let numberOfFrames = message.payload.count == 0 ? 1 : 1 + (message.payload.count - 1) / 8
              
              for frameNumber in 1...numberOfFrames {
                
                var canFrameType : OpenLCBMessageCANFrameType = .datagramMiddleFrame
                
                if frameNumber == 1 {
                  canFrameType = .datagramFirstFrame
                }
                else if frameNumber == numberOfFrames {
                  canFrameType = .datagramFinalFrame
                }
                
                var data : [UInt8] = []
                
                var index = (frameNumber - 1) * 8
                
                var count = 0
                
                while index < message.payload.count && count < 8 {
                  data.append(message.payload[index])
                  index += 1
                  count += 1
                }
                
                if let frame = LCCCANFrame(networkId: interface.networkId, message: message, canFrameType: canFrameType, data: data) {
                  interface.send(data: frame.message)
                }
                
              }
              
            }
            
            delete = true
            
          }
          else if message.isAddressPresent {
            
            if let frame = LCCCANFrame(networkId: interface.networkId, message: message) {
              
              if frame.data.count <= 8 {
                interface.send(data: frame.message)
              }
              else {
                
                let numberOfFrames = 1 + (frame.data.count - 3 ) / 6
                
                for frameNumber in 1...numberOfFrames {
                  
                  var flags : OpenLCBCANFrameFlag = .middleFrame
                  
                  if frameNumber == 1 {
                    flags = .firstFrame
                  }
                  else if frameNumber == numberOfFrames {
                    flags = .lastFrame
                  }
                  
                  if let frame = LCCCANFrame(networkId: interface.networkId, message: message, flags: flags, frameNumber: frameNumber) {
                    interface.send(data: frame.message)
                  }
                  
                }
                
              }
              
            }
            
            delete = true
            
          }
          else if let frame = LCCCANFrame(networkId: interface.networkId, message: message) {
            interface.send(data: frame.message)
            delete = true
          }
          
        }
        else if (referenceDate - message.timeStamp) > timeoutInterval {
          delete = true
        }
        
        if delete {
          outputQueueLock.lock()
          outputQueue.remove(at: index)
          outputQueueLock.unlock()
        }
        else {
          index += 1
        }
        
      }
      
    }

    if !inputQueue.isEmpty || !outputQueue.isEmpty {
      startWaitTimer(interval: waitInterval)
    }
    else if isStopping {
      interface.close()
    }
    
    inProcessQueue = false
    
  }
  
  private func addNodeIdAliasMapping(nodeId: UInt64, alias:UInt16) {
    aliasLookup[alias] = nodeId
    nodeIdLookup[nodeId] = alias
  }
  
  private func removeNodeIdAliasMapping(nodeId:UInt64) {
    if let alias = nodeIdLookup[nodeId] {
      sendAliasMapResetFrame(nodeId: nodeId, alias: alias)
      aliasLookup.removeValue(forKey: alias)
      nodeIdLookup.removeValue(forKey: nodeId)
    }
  }
  
  private func removeNodeIdAliasMapping(alias:UInt16) {
    if let nodeId = aliasLookup[alias] {
      sendAliasMapResetFrame(nodeId: nodeId, alias: alias)
      aliasLookup.removeValue(forKey: alias)
      nodeIdLookup.removeValue(forKey: nodeId)
    }
  }
  
  private func nextAlias(node: OpenLCBNodeVirtual) -> UInt16 {
    
    // The PRNG state is stored in two 32-bit quantities:
    // uint32_t lfsr1, lfsr2; // sequence value: lfsr1 is upper 24 bits, lfsr2 lower
    
    // The 6-byte unique Node ID is stored in the nid[0:5] array.
    
    // To load the PRNG from the Node ID:
    // lfsr1 = (nid[0] << 16) | (nid[1] << 8) | nid[2]; // upper bits
    // lfsr2 = (nid[3] << 16) | (nid[4] << 8) | nid[5];
    
    // To step the PRNG:
    // First, form 2^9*val
    
    let temp1 : UInt32 = ((node.lfsr1 << 9) | ((node.lfsr2 >> 15) & 0x1FF)) & 0xFFFFFF
    let temp2 : UInt32 = (node.lfsr2 << 9) & 0xFFFFFF
    
    // add
    
    node.lfsr2 += temp2 + 0x7A4BA9
    
    node.lfsr1 += temp1 + 0x1B0CA3
    
    // carry
    
    node.lfsr1 = (node.lfsr1 & 0xFFFFFF) + ((node.lfsr2 & 0xFF000000) >> 24)
    node.lfsr2 &= 0xFFFFFF
    
    // Form a 12-bit alias from the PRNG state:
    
    return UInt16((node.lfsr1 ^ node.lfsr2 ^ (node.lfsr1 >> 12) ^ (node.lfsr2 >> 12) ) & 0xFFF)
    
  }
  
  @objc func waitTimerTick() {
    
    stopWaitTimer()
    
    if let internalNode = initNodeQueue.first {
      
      switch internalNode.transitionState {
      case .testingAlias:
        internalNode.transitionState = .reservingAlias
        sendReserveIdFrame(alias: internalNode.alias!)
        startWaitTimer(interval: waitInterval)
      case .reservingAlias:
        internalNode.transitionState = .mappingDeclared
        internalNode.state = .permitted
        sendAliasMapDefinitionFrame(nodeId: internalNode.node.nodeId, alias: internalNode.alias!)
        addNodeIdAliasMapping(nodeId: internalNode.node.nodeId, alias: internalNode.alias!)
        managedAliasLookup[internalNode.alias!] = internalNode
        managedNodeIdLookup[internalNode.node.nodeId] = internalNode
        initNodeQueue.removeFirst()
        internalNode.node.start()
        if !initNodeQueue.isEmpty {
          getAlias()
        }
      default:
        break
      }
    }
    
    processQueues()

  }
  
  private func getAlias() {
    
    aliasLock.lock()
    let ok = !inGetAlias
    if ok {
      inGetAlias = true
    }
    aliasLock.unlock()
    
    if !ok {
      return
    }

    if let node = initNodeQueue.first {

      if node.transitionState == .tryAgain {
        managedAliasLookup.removeValue(forKey: node.alias!)
        managedNodeIdLookup.removeValue(forKey: node.node.nodeId)
        node.transitionState = .idle
      }
      
      if node.transitionState == .idle {
        
        node.state = .inhibited
        
        node.transitionState = .testingAlias
        
        node.alias = nextAlias(node: node.node)
        
        sendCheckIdFrame(format: .checkId7Frame, nodeId: node.node.nodeId, alias: node.alias!)
        sendCheckIdFrame(format: .checkId6Frame, nodeId: node.node.nodeId, alias: node.alias!)
        sendCheckIdFrame(format: .checkId5Frame, nodeId: node.node.nodeId, alias: node.alias!)
        sendCheckIdFrame(format: .checkId4Frame, nodeId: node.node.nodeId, alias: node.alias!)
        
        startWaitTimer(interval: waitInterval)
        
      }
      
    }
    
    inGetAlias = false
    
  }
  
  private func startWaitTimer(interval: TimeInterval) {
    waitTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(waitTimerTick), userInfo: nil, repeats: false)
    RunLoop.current.add(waitTimer!, forMode: .common)
  }
  
  private func stopWaitTimer() {
    waitTimer?.invalidate()
    waitTimer = nil
  }

  private func send(header: String, data:String) {
    interface.send(data: ":X\(header)N\(data);")
  }

  private func sendCheckIdFrame(format:OpenLCBCANControlFrameFormat, nodeId:UInt64, alias: UInt16) {
    
    var variableField : UInt16 = format.rawValue
    
    variableField |= UInt16((nodeId >> (((format.rawValue >> 12) - 4) * 12)) & 0x0fff)
    
    let header = LCCCANFrame.createFrameHeader(frameType: .canControlFrame, variableField: variableField, sourceNIDAlias: alias)
    
    send(header: header, data: "")

  }

  private func sendReserveIdFrame(alias:UInt16) {
    
    let variableField : UInt16 = OpenLCBCANControlFrameFormat.reserveIdFrame.rawValue
    
    let header = LCCCANFrame.createFrameHeader(frameType: .canControlFrame, variableField: variableField, sourceNIDAlias: alias)
    
    send(header: header, data: "")

  }

  private func sendAliasMapDefinitionFrame(nodeId:UInt64, alias:UInt16) {
    
    let variableField : UInt16 = OpenLCBCANControlFrameFormat.aliasMapDefinitionFrame.rawValue
    
    let header = LCCCANFrame.createFrameHeader(frameType: .canControlFrame, variableField: variableField, sourceNIDAlias: alias)
    
    send(header: header, data: nodeId.toHex(numberOfDigits: 12))

  }

  private func sendAliasMapResetFrame(nodeId:UInt64, alias:UInt16) {
    
    let variableField : UInt16 = OpenLCBCANControlFrameFormat.aliasMapResetFrame.rawValue
    
    let header = LCCCANFrame.createFrameHeader(frameType: .canControlFrame, variableField: variableField, sourceNIDAlias: alias)
    
    send(header: header, data: nodeId.toHex(numberOfDigits: 12))

  }

  private func sendAliasMappingEnquiryFrame(nodeId:UInt64, alias:UInt16) {
    
    let variableField : UInt16 = OpenLCBCANControlFrameFormat.aliasMappingEnquiryFrame.rawValue
    
    let header = LCCCANFrame.createFrameHeader(frameType: .canControlFrame, variableField: variableField, sourceNIDAlias: alias)
    
    send(header: header, data: nodeId.toHex(numberOfDigits: 12))

  }

  private func sendAliasMappingEnquiryFrame(alias:UInt16) {
    
    let variableField : UInt16 = OpenLCBCANControlFrameFormat.aliasMappingEnquiryFrame.rawValue
    
    let header = LCCCANFrame.createFrameHeader(frameType: .canControlFrame, variableField: variableField, sourceNIDAlias: alias)
    
    send(header: header, data: "")

  }

  private func sendDuplicateNodeIdErrorFrame(alias:UInt16) {
    
    var header : UInt32 = 0x195B4000
    
    header |= UInt32(alias & 0x0fff)

    send(header: header.toHex(numberOfDigits: 8), data: "0101000000000201")

  }

  // MARK: Public Methods
  
  override public func start() {
    
    guard !isActive else {
      return
    }
    
    observerId = interface.addObserver(observer: self)
    
    isStopping = false
    
    interface.open()
    
  }
  
  override public func stop() {
    
    guard isActive else {
      return
    }

    while let (_, node) = virtualNodes.first {
      deregisterNode(node: node)
    }

    isStopping = true
    
    processQueues()
    
  }
  
  override public func registerNode(node:OpenLCBNodeVirtual) {
    super.registerNode(node: node)
    let alias = OpenLCBTransportLayerAlias(node: node)
    initNodeQueue.append(alias)
    getAlias()
  }
  
  override public func deregisterNode(node:OpenLCBNodeVirtual) {
    removeNodeIdAliasMapping(nodeId: node.nodeId)
    super.deregisterNode(node: node)
  }

  override public func removeAlias(nodeId:UInt64) {
    removeNodeIdAliasMapping(nodeId: nodeId)
  }

  // MARK: InterfaceDelegate Methods
  
  private var count = 0
  
  @objc public func lccCANFrameReceived(frame:LCCCANFrame) {
    
    switch frame.frameType {
      
    case .canControlFrame:
      
      // Testing an alias
      
      if let node = initNodeQueue.first, let alias = node.alias, (node.transitionState == .testingAlias || node.transitionState == .reservingAlias) && frame.sourceNIDAlias == alias {
        stopWaitTimer()
        node.transitionState = .idle
        getAlias()
        return
      }
      
      // Node Id Alias Validation
      
      if frame.canControlFrameFormat == .aliasMappingEnquiryFrame {
          
        if frame.data.isEmpty {
          for (_, internalNode) in managedNodeIdLookup {
            if internalNode.state == .permitted {
              sendAliasMapDefinitionFrame(nodeId: internalNode.node.nodeId, alias: internalNode.alias!)
            }
          }
        }
        else {
          if let nodeId = UInt64(bigEndianData: frame.data), let internalNode = managedNodeIdLookup[nodeId], internalNode.state == .permitted {
            sendAliasMapDefinitionFrame(nodeId: nodeId, alias: internalNode.alias!)
          }
        }
        
        return

      }

      for (_, internalNode) in managedNodeIdLookup {
        
        // Node Id Collision Handling
        
        if let alias = internalNode.alias, frame.sourceNIDAlias == alias {
          
          // Is a CID Frame
          
          if frame.canControlFrameFormat.isCheckIdFrame {
            sendReserveIdFrame(alias: alias)
            return
          }
          
          // Is not a CID Frame
          
          if internalNode.state == .permitted {
            
            removeNodeIdAliasMapping(nodeId: internalNode.node.nodeId)
            internalNode.alias = nil
            internalNode.state = .inhibited
            internalNode.transitionState = .tryAgain
            initNodeQueue.append(internalNode)
            getAlias()
            return
            
          }
          
        }
        
        
      }
      
      // Remove lookups for reset mappings
        
      if frame.canControlFrameFormat == .aliasMapResetFrame {
        removeNodeIdAliasMapping(alias: frame.sourceNIDAlias)
        return
      }
        
        // Check for Duplicate NodeId
        
      if frame.canControlFrameFormat == .aliasMapDefinitionFrame, let nodeId = UInt64(bigEndianData: frame.data) {

        if let internalNode = managedNodeIdLookup[nodeId] {
          sendDuplicateNodeIdErrorFrame(alias: internalNode.alias!)
          removeNodeIdAliasMapping(nodeId: nodeId)
          internalNode.state = .stopped
          internalNode.transitionState = .idle
          managedAliasLookup.removeValue(forKey: internalNode.alias!)
          managedNodeIdLookup.removeValue(forKey: nodeId)
          internalNode.alias = nil
          internalNode.node.stop()
          return
        }
        
        addNodeIdAliasMapping(nodeId: nodeId, alias: frame.sourceNIDAlias)

      }

    case .openLCBMessage:
      
      if let message = OpenLCBMessage(frame: frame) {
        
        var deleteList : [LCCCANFrame] = []
        
        let now = frame.timeStamp
        
        for (_, frame) in splitFrames {
          if (now - frame.timeStamp) > 3.0 {
            deleteList.append(frame)
          }
        }
        
        while deleteList.count > 0 {
          splitFrames.removeValue(forKey: deleteList.first!.splitFrameId)
          deleteList.removeFirst()
        }
        
        var timeOutList : [OpenLCBMessage] = []
        
        for (_, message) in datagrams {
          if (now - message.timeStamp) > 3.0 {
            timeOutList.append(message)
          }
        }
        
        while !timeOutList.isEmpty {
          let message = timeOutList.first!
          datagrams.removeValue(forKey: message.datagramId)
          timeOutList.removeFirst()
          if let internalNode = managedAliasLookup[message.destinationNIDAlias!] {
            let errorMessage = OpenLCBMessage(messageTypeIndicator: .datagramRejected)
            errorMessage.destinationNIDAlias = message.sourceNIDAlias
            errorMessage.sourceNIDAlias = internalNode.alias!
            errorMessage.sourceNodeId = internalNode.node.nodeId
            errorMessage.payload = OpenLCBErrorCode.temporaryErrorTimeOutWaitingForEndFrame.asData
            addToOutputQueue(message: errorMessage)
          }
        }

        switch message.canFrameType {
        case .globalAndAddressedMTI:
          switch message.flags {
          case .onlyFrame:
            addToInputQueue(message: message)
          case .firstFrame:
            splitFrames[frame.splitFrameId] = frame
          case .middleFrame, .lastFrame:
            if let first = splitFrames[frame.splitFrameId] {
              frame.data.removeFirst(2)
              first.data += frame.data
              if message.flags == .lastFrame, let message = OpenLCBMessage(frame: first) {
                message.flags = .onlyFrame
                addToInputQueue(message: message)
                splitFrames.removeValue(forKey: first.splitFrameId)
              }
            }
          }
        case .datagramCompleteInFrame:
          addToInputQueue(message: message)
        case .datagramFirstFrame:
          if let oldMessage = datagrams[message.datagramId] {
            if let internalNode = managedAliasLookup[oldMessage.destinationNIDAlias!] {
              let errorMessage = OpenLCBMessage(messageTypeIndicator: .datagramRejected)
              errorMessage.destinationNIDAlias = message.sourceNIDAlias
              errorMessage.sourceNIDAlias = internalNode.alias!
              errorMessage.sourceNodeId = internalNode.node.nodeId
              errorMessage.payload = OpenLCBErrorCode.temporaryErrorOutOfOrderStartFrameBeforeFinishingPreviousMessage.asData
              addToOutputQueue(message: errorMessage)
            }
            datagrams.removeValue(forKey: oldMessage.datagramId)
          }
          else {
            datagrams[message.datagramId] = message
          }
        case .datagramMiddleFrame, .datagramFinalFrame:
          if let first = datagrams[message.datagramId] {
            first.timeStamp = message.timeStamp
            first.payload += message.payload
            if message.canFrameType == .datagramFinalFrame {
              addToInputQueue(message: first)
              datagrams.removeValue(forKey: first.datagramId)
            }
          }
          else if let internalNode = managedAliasLookup[message.destinationNIDAlias!] {
            let errorMessage = OpenLCBMessage(messageTypeIndicator: .datagramRejected)
            errorMessage.destinationNIDAlias = message.sourceNIDAlias
            errorMessage.sourceNIDAlias = internalNode.alias!
            errorMessage.sourceNodeId = internalNode.node.nodeId
            errorMessage.payload = OpenLCBErrorCode.temporaryErrorOutOfOrderMiddleOrEndFrameWithoutStartFrame.asData
            addToOutputQueue(message: errorMessage)
          }
        default:
          break
        }
        
      }
      else {
        print("*\(frame.header.toHex(numberOfDigits: 4))")
      }
      
    }
    
  }
  
  @objc public func interfaceWasDisconnected(interface:Interface) {
    
  }
  
  @objc public func interfaceWasOpened(interface:Interface) {
    isActive = true
    delegate?.transportLayerStateChanged(transportLayer: self)
  }
  
  @objc public func interfaceWasClosed(interface:Interface) {
    interface.removeObserver(id: observerId)
    observerId = -1
    isActive = false
    delegate?.transportLayerStateChanged(transportLayer: self)
  }

}
