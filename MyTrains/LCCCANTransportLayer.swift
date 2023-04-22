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
  
  private let timeoutInterval : TimeInterval = 3.0

  private var lfsr1 : UInt32
  
  private var lfsr2 : UInt32
  
  private var waitTimer : Timer?
  
  private var transitionState : LCCCANTransportTransitionState = .idle
  
  private var observerId : Int = -1
  
  private var aliasLookup : [UInt16:String] = [:]
  
  private var nodeIdLookup : [String:UInt16] = [:]
  
  private var splitFrames : [UInt64:LCCCANFrame] = [:]
  
  private var datagrams : [UInt32:OpenLCBMessage] = [:]
  
  private var datagramsAwaitingReceipt : [UInt32:OpenLCBMessage] = [:]
  
  // MARK: Public Properties
  
  public var interface : Interface
  
  public var nodeId : UInt64
  
  public var alias : UInt16?
  
  // MARK: Private Methods
  
  override func processQueues() {
    
    // Input Queue
    
    let referenceDate = Date.timeIntervalSinceReferenceDate
    
    if !inputQueue.isEmpty {
      
      var sendQuery = false
      
      var index = 0
      
      while index < inputQueue.count {
        
        let message = inputQueue[index]
        
        if message.sourceNodeId == nil, let alias = message.sourceNIDAlias {
          if let id = aliasLookup[alias] {
            message.sourceNodeId = UInt64(hex: id)
          }
          else {
            sendQuery = true
          }
        }
        
        if (message.isAddressPresent || message.messageTypeIndicator == .datagram) && message.destinationNodeId == nil, let alias = message.destinationNIDAlias {
          if let id = aliasLookup[alias] {
            message.destinationNodeId = UInt64(hex: id)
          }
          else {
            sendQuery = true
          }
        }
        
        var delete = false
        
        if message.isMessageComplete {
          
          switch message.messageTypeIndicator {
          case .datagramReceivedOK:
            if let datagram = datagramsAwaitingReceipt[message.datagramIdReversed] {
              datagramsAwaitingReceipt.removeValue(forKey: message.datagramIdReversed)
            }
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

          delegate?.openLCBMessageReceived(message: message)

          delete = true
          
        }
        else if (referenceDate - message.timeStamp) > timeoutInterval {
          delete = true
        }
        
        if delete {
          if index < inputQueue.count {
            inputQueueLock.lock()
            inputQueue.remove(at: index)
            inputQueueLock.unlock()
          }
        }
        else {
          index += 1
        }
        
      }
      
      if sendQuery {
        sendAliasMappingEnquiryFrame()
      }
            
    }
    
    // Output Queue
    
    if !outputQueue.isEmpty {
      
      var index = 0
      
      while index < outputQueue.count {
        
        let message = outputQueue[index]
        
        if message.sourceNodeId == nil {
          message.sourceNodeId = nodeId
        }
        
        message.sourceNIDAlias = nodeIdLookup[message.sourceNodeId!.toHex(numberOfDigits: 12)]
        
        if (message.messageTypeIndicator == .datagram ) || message.isAddressPresent, let destinationNodeId = message.destinationNodeId {
          
          if let alias = nodeIdLookup[destinationNodeId.toHex(numberOfDigits: 12)] {
            message.destinationNIDAlias = alias
          }
          else {
            sendAliasMappingEnquiryFrame(nodeId: destinationNodeId)
          }
          
        }
        
        var delete = false
        
        if message.isMessageComplete {
          
          if message.messageTypeIndicator == .datagram {

            datagramsAwaitingReceipt[message.datagramId] = message

            if message.otherContent.count <= 8 {
              if let frame = LCCCANFrame(networkId: interface.networkId, message: message, canFrameType: .datagramCompleteInFrame, data: message.otherContent) {
                interface.send(data: frame.message)
              }
            }
            else {
              
              let numberOfFrames = message.otherContent.count == 0 ? 1 : 1 + (message.otherContent.count - 1) / 8
              
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
                
                while index < message.otherContent.count && count < 8 {
                  data.append(message.otherContent[index])
                  index += 1
                  count += 1
                }
                
                if let frame = LCCCANFrame(networkId: interface.networkId, message: message, canFrameType: canFrameType, data: data) {
                  interface.send(data: frame.message)
                }
                
              }
              
            }
          }
          else if message.isAddressPresent {
            
            if let frame = LCCCANFrame(networkId: interface.networkId, message: message) {
              
              if frame.data.count <= 8 {
                interface.send(data: frame.message)
              }
              else {
                
                let numberOfFrames = 1 + (frame.data.count - 3 ) / 6
                
                for frameNumber in 1...numberOfFrames {
                  
                  var flags : LCCCANFrameFlag = .middleFrame
                  
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
    
    let temp1 : UInt32 = ((lfsr1 << 9) | ((lfsr2 >> 15) & 0x1FF)) & 0xFFFFFF
    let temp2 : UInt32 = (lfsr2 << 9) & 0xFFFFFF
    
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
      sendReserveIdFrame()
      startWaitTimer(interval: waitInterval)
    case .reservingAlias:
      transitionState = .mappingDeclared
      _state = .permitted
      sendAliasMapDefinitionFrame()
      addNodeIdAliasMapping(nodeId: nodeId.toHex(numberOfDigits: 12), alias: alias!)
      delegate?.transportLayerStateChanged(transportLayer: self)
    default:
      break
    }
    
    processQueues()

  }
  
  func startWaitTimer(interval: TimeInterval) {
    waitTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(waitTimerTick), userInfo: nil, repeats: false)
    RunLoop.current.add(waitTimer!, forMode: .common)
  }
  
  func stopWaitTimer() {
    waitTimer?.invalidate()
    waitTimer = nil
  }

  private func send(header: String, data:String) {
    interface.send(data: ":X\(header)N\(data);")
  }

  private func sendCheckIdFrame(format:OpenLCBCANControlFrameFormat, alias: UInt16) {
    
    var variableField : UInt16 = format.rawValue
    
    variableField |= UInt16((nodeId >> (((format.rawValue >> 12) - 4) * 12)) & 0x0fff)
    
    let header = LCCCANFrame.createFrameHeader(frameType: .canControlFrame, variableField: variableField, sourceNIDAlias: alias)
    
    send(header: header, data: "")

  }

  private func sendReserveIdFrame() {
    
    let variableField : UInt16 = OpenLCBCANControlFrameFormat.reserveIdFrame.rawValue
    
    let header = LCCCANFrame.createFrameHeader(frameType: .canControlFrame, variableField: variableField, sourceNIDAlias: alias!)
    
    send(header: header, data: "")

  }

  private func sendAliasMapDefinitionFrame() {
    
    let variableField : UInt16 = OpenLCBCANControlFrameFormat.aliasMapDefinitionFrame.rawValue
    
    let header = LCCCANFrame.createFrameHeader(frameType: .canControlFrame, variableField: variableField, sourceNIDAlias: alias!)
    
    send(header: header, data: nodeId.toHex(numberOfDigits: 12))

  }

  private func sendAliasMapResetFrame() {
    
    let variableField : UInt16 = OpenLCBCANControlFrameFormat.aliasMapResetFrame.rawValue
    
    let header = LCCCANFrame.createFrameHeader(frameType: .canControlFrame, variableField: variableField, sourceNIDAlias: alias!)
    
    send(header: header, data: nodeId.toHex(numberOfDigits: 12))

  }

  private func sendAliasMappingEnquiryFrame(nodeId:UInt64) {
    
    let variableField : UInt16 = OpenLCBCANControlFrameFormat.aliasMappingEnquiryFrame.rawValue
    
    let header = LCCCANFrame.createFrameHeader(frameType: .canControlFrame, variableField: variableField, sourceNIDAlias: alias!)
    
    send(header: header, data: nodeId.toHex(numberOfDigits: 12))

  }

  private func sendAliasMappingEnquiryFrame() {
    
    let variableField : UInt16 = OpenLCBCANControlFrameFormat.aliasMappingEnquiryFrame.rawValue
    
    let header = LCCCANFrame.createFrameHeader(frameType: .canControlFrame, variableField: variableField, sourceNIDAlias: alias!)
    
    send(header: header, data: "")

  }

  private func sendDuplicateNodeIdErrorFrame() {
    
    var header : UInt32 = 0x195B4000
    
    header |= UInt32(alias! & 0x0fff)

    send(header: header.toHex(numberOfDigits: 8), data: "0101000000000201")

  }

  // MARK: Public Methods
  
  override public func transitionToPermittedState() {
    
    guard state == .inhibited else {
      return
    }
    
    if observerId != -1 {
      interface.removeObserver(id: observerId)
    }
    
    observerId = interface.addObserver(observer: self)

    transitionState = .testingAlias
    
    alias = nextAlias()
    
    sendCheckIdFrame(format: .checkId7Frame, alias: alias!)
    sendCheckIdFrame(format: .checkId6Frame, alias: alias!)
    sendCheckIdFrame(format: .checkId5Frame, alias: alias!)
    sendCheckIdFrame(format: .checkId4Frame, alias: alias!)

    startWaitTimer(interval: waitInterval)
    
  }
  
  override public func transitionToInhibitedState() {
    
    guard state == .permitted else {
      return
    }
    
    sendAliasMapResetFrame()
    
    removeNodeIdAliasMapping(nodeId: nodeId.toHex(numberOfDigits: 12))

    transitionState = .idle
    
    _state = .inhibited
    
    alias = nil
    
    if observerId != -1 {
      interface.removeObserver(id: observerId)
      observerId = -1
    }
    
    delegate?.transportLayerStateChanged(transportLayer: self)
    
  }
  
  // MARK: InterfaceDelegate Methods
  
  private var count = 0
  
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
          
          if frame.canControlFrameFormat == .aliasMappingEnquiryFrame {
            
            if frame.dataAsHex.isEmpty || frame.dataAsHex == nodeId.toHex(numberOfDigits: 12) {
              sendAliasMapDefinitionFrame()
            }
            
            return
            
          }
          
        }
        
        // Node Id Collision Handling
        
        if frame.sourceNIDAlias == alias {
          
          // Is a CID Frame
          
          if frame.canControlFrameFormat.isCheckIdFrame {
            sendReserveIdFrame()
            return
          }
          
          // Is not a CID Frame
          
          else if state == .permitted {
            transitionToInhibitedState()
            transitionToPermittedState()
          }
          
        }
        
        // Remove lookups for reset mappings
        
        if frame.canControlFrameFormat == .aliasMapResetFrame {
          removeNodeIdAliasMapping(alias: frame.sourceNIDAlias)
          return
        }
        
        // Check for Duplicate NodeId
        
        if frame.canControlFrameFormat == .aliasMapDefinitionFrame {
          
          if nodeId.toHex(numberOfDigits: 12) == frame.dataAsHex {
            sendDuplicateNodeIdErrorFrame()
            removeNodeIdAliasMapping(nodeId: nodeId.toHex(numberOfDigits: 12))
            _state = .stopped
            interface.removeObserver(id: observerId)
            observerId = -1
            transitionState = .idle
            self.alias = nil
            delegate?.transportLayerStateChanged(transportLayer: self)
            return
          }
          
          addNodeIdAliasMapping(nodeId: frame.dataAsHex, alias: frame.sourceNIDAlias)
          
        }
        
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
          splitFrames.removeValue(forKey: deleteList[0].splitFrameId)
        }
        
        var timeOutList : [OpenLCBMessage] = []
        
        for (_, message) in datagrams {
          if (now - message.timeStamp) > 3.0 {
            timeOutList.append(message)
          }
        }
        
        while timeOutList.count > 0 {
          let message = timeOutList[0]
          if message.destinationNIDAlias == alias {
            let errorMessage = OpenLCBMessage(messageTypeIndicator: .datagramRejected)
            errorMessage.destinationNIDAlias = message.sourceNIDAlias
            errorMessage.sourceNIDAlias = alias
            errorMessage.sourceNodeId = nodeId
            errorMessage.otherContent = OpenLCBErrorCode.temporaryErrorTimeOutWaitingForEndFrame.asData
            addToOutputQueue(message: errorMessage)
          }
          datagrams.removeValue(forKey: timeOutList[0].datagramId)
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
            if oldMessage.destinationNIDAlias == alias {
              let errorMessage = OpenLCBMessage(messageTypeIndicator: .datagramRejected)
              errorMessage.destinationNIDAlias = message.sourceNIDAlias
              errorMessage.sourceNIDAlias = alias
              errorMessage.sourceNodeId = nodeId
              errorMessage.otherContent = OpenLCBErrorCode.temporaryErrorOutOfOrderStartFrameBeforeFinishingPreviousMessage.asData
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
            first.otherContent += message.otherContent
            if message.canFrameType == .datagramFinalFrame {
              addToInputQueue(message: first)
              datagrams.removeValue(forKey: first.datagramId)
            }
          }
          else if message.destinationNIDAlias == alias {
            let errorMessage = OpenLCBMessage(messageTypeIndicator: .datagramRejected)
            errorMessage.destinationNIDAlias = message.sourceNIDAlias
            errorMessage.sourceNIDAlias = alias
            errorMessage.sourceNodeId = nodeId
            errorMessage.otherContent = OpenLCBErrorCode.temporaryErrorOutOfOrderMiddleOrEndFrameWithoutStartFrame.asData
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
    
    /*
    for (key, value) in nodeIdLookup {
      print("0x\(key) : 0x\(value.toHex(numberOfDigits: 3))")
    }
    print()
     */
  }
  
}
