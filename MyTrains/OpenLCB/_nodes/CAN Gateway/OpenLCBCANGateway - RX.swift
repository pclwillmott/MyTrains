//
//  OpenLCBCANGateway - RX.swift
//  MyTrains
//
//  Created by Paul Willmott on 16/02/2024.
//

import Foundation

extension OpenLCBCANGateway {
  
  internal func parseInput() {

    while !buffer.isEmpty {
      
      var found = false
      
      while !buffer.isEmpty {
        let char = String(format: "%C", buffer[0])
        if char == ":" {
          found = true
          break
        }
        buffer.removeFirst()
      }
      
      if !found {
        break
      }
      
      var frame = ""
      
      found = false
      
      var index = 0
      while index < buffer.count {
        let char = String(format: "%C", buffer[index])
        frame += char
        if char == ";" {
           found = true
          break
        }
        index += 1
      }
      
      if found {
        
        buffer.removeFirst(frame.count)

        if let newframe = LCCCANFrame(message: frame) {
          
          newframe.timeStamp = Date.timeIntervalSinceReferenceDate
          newframe.timeSinceLastMessage = newframe.timeStamp - lastTimeStamp
          lastTimeStamp = newframe.timeStamp
          for (_, observer) in observers {
            observer.openLCBCANPacketReceived(packet: newframe)
          }
          canFrameReceived(frame: newframe)

        }
        else {
          for (_, observer) in observers {
            observer.rawCANPacketReceived(packet: frame)
          }
        }

      }
      else {
        break
      }

      
    }
    
  }

  internal func canFrameReceived(frame:LCCCANFrame) {
    
    // The node shall restart the process at the beginning if, before completion of the process, a frame is
    // received that carries a source Node ID alias value that is identical to the alias value being tested by this
    // procedure.
    
    // Items in the initNodeQueue are all in inhibited state, and only the first is attempting to get an alias.
    
    if let item = initNodeQueue.first, let alias = item.alias, alias == frame.sourceNIDAlias {
      stopAliasTimer()
      item.transitionState = .idle
      getAlias()
    }
    
    // A node shall compare the source Node ID alias in each received frame against all reserved Node ID
    // aliases it currently holds. In case of a match, the receiving node shall:

    // Items in the managed alias and nodeId lookups are all in permitted state.
    
    if let item = managedAliasLookup[frame.sourceNIDAlias] {

      // • If the frame is a Check ID (CID) frame, send a Reserve ID (RID) frame in response.

      if let controlFrameFormat = frame.controlFrameFormat, controlFrameFormat.isCheckIdFrame {
        sendReserveIdFrame(alias: frame.sourceNIDAlias)
        return
      }
      
      // • If the frame is not a Check ID (CID) frame, the node is in Permitted state, and the received
      // source Node ID alias is the current Node ID alias of the node, the node shall immediately
      // transition to Inhibited state, send an AMR frame to release and then stop using the current Node
      // ID alias.
      
      else {
        item.alias = nil
        item.state = .inhibited
        item.transitionState = .idle
        removeNodeIdAliasMapping(nodeId: item.nodeId)
        removeManagedNodeIdAliasMapping(nodeId: item.nodeId)
        sendAliasMapResetFrame(nodeId: nodeId, alias: frame.sourceNIDAlias)
        initNodeQueue.append(item)
        getAlias()
      }

    }

    switch frame.frameType {
      
    case .canControlFrame:
      
      if let controlFrameFormat = frame.controlFrameFormat {
        
        switch controlFrameFormat {
          
        case .aliasMapDefinitionFrame:
          
          // Each node shall compare the node ID in each received Alias Map Definition frame with its own Node
          // ID. Should they match, in addition to any other actions that may be required by the incoming message,
          // the node
          // • if in Permitted state, may, but is not required to, notify other nodes of the condition by
          // transmitting the CAN frame [195B4sss] 01.01.00.00.00.00.02.01
          // where 'sss' is the current alias of the transmitting node. If that frame is emitted, the node is then
          // required to not send any more CAN frames on the OpenLCB-CAN link until reset by the user.
          
          // Items in the managed alias and nodeId lookups are all in permitted state.
          
          if let nodeId = UInt64(bigEndianData: frame.data), let item = managedNodeIdLookup[nodeId], let alias = item.alias {
            sendDuplicateNodeIdErrorFrame(alias: alias)
            removeNodeIdAliasMapping(nodeId: nodeId)
            removeManagedNodeIdAliasMapping(nodeId: nodeId)
            item.state = .stopped
            item.transitionState = .idle
            item.alias = nil
            stoppedNodesLookup[item.nodeId] = item
            return
          }
          
          addNodeIdAliasMapping(nodeId: nodeId, alias: frame.sourceNIDAlias)
          processInputQueue()
          return
          
        case .aliasMappingEnquiryFrame:
          
          // A node in Permitted state receiving a Alias Mapping Enquiry frame shall compare the full Node ID in
          // the CAN data segment to the node's own Node ID. If and only if they match in length and content and
          // the receiving node is in Permitted state, the node shall reply with a Alias Map Definition frame
          // carrying the node's full Node ID in the data segment of the frame.
          // A node in Permitted state receiving an Alias Mapping Enquiry frame with no data content shall reply
          // with an Alias Map Definition frame carrying the node's full Node ID in the data segment of the frame.
          // A node in Inhibited state shall not reply to a Alias Mapping Enquiry frame.
          
          // Items in the managed alias and nodeId lookups are all in permitted state.
          
          if frame.data.isEmpty {
            for (alias, item) in managedAliasLookup {
              sendAliasMapDefinitionFrame(nodeId: item.nodeId, alias: alias)
            }
          }
          else {
            if let nodeId = UInt64(bigEndianData: frame.data), let item = managedNodeIdLookup[nodeId], let alias = item.alias {
              sendAliasMapDefinitionFrame(nodeId: nodeId, alias: alias)
            }
          }
          
          return
          
        case .aliasMapResetFrame:
          
          // If a node receives an Alias Map Reset (AMR) frame referencing an alias for another node, the
          // receiving node shall stop using that alias to refer to the AMR-sending node within 100 milliseconds.
          
          removeNodeIdAliasMapping(alias: frame.sourceNIDAlias)
          
          return
          
        case .errorInformationReport0:
          #if DEBUG
          debugLog(message: "\(controlFrameFormat)")
          #endif
        case .errorInformationReport1:
          #if DEBUG
          debugLog(message: "\(controlFrameFormat)")
          #endif
        case .errorInformationReport2:
          #if DEBUG
          debugLog(message: "\(controlFrameFormat)")
          #endif
        case .errorInformationReport3:
          #if DEBUG
          debugLog(message: "\(controlFrameFormat)")
          #endif
        default:
          break
        }
        
        return
        
      }
      
    case .openLCBMessage:
      
      guard let message = OpenLCBMessage(frame: frame), let sourceNIDAlias = message.sourceNIDAlias else {
        return
      }
      
      if let nodeId = aliasLookup[sourceNIDAlias] {
        message.sourceNodeId = nodeId
      }
      else {
        sendVerifyNodeIdNumberAddressed(sourceNodeId: nodeId, destinationNodeIdAlias: sourceNIDAlias)
      }
      
      if let destinationNIDAlias = message.destinationNIDAlias {
        if let nodeId = aliasLookup[destinationNIDAlias] {
          message.destinationNodeId = nodeId
        }
        else {
          sendVerifyNodeIdNumberAddressed(sourceNodeId: nodeId, destinationNodeIdAlias: destinationNIDAlias)
        }
      }
      
      switch message.canFrameType {
        
      case .globalAndAddressedMTI:
        
        switch message.messageTypeIndicator {

        case .producerConsumerEventReportWithPayloadFirstFrame:
          
          splitFrames[frame.splitFrameId] = frame
          
        case .producerConsumerEventReportWithPayloadMiddleFrame, .producerConsumerEventReportWithPayloadLastFrame:
          
          if let first = splitFrames[frame.splitFrameId] {
            
            first.data += frame.data
            
            if message.messageTypeIndicator == .producerConsumerEventReportWithPayloadLastFrame, let newMessage = OpenLCBMessage(frame: first) {
              splitFrames.removeValue(forKey: first.splitFrameId)
              newMessage.timeStamp = first.timeStamp
              newMessage.flags = .onlyFrame
              newMessage.messageTypeIndicator = .producerConsumerEventReport
              newMessage.sourceNodeId = message.sourceNodeId
              newMessage.destinationNodeId = message.destinationNodeId
              addToInputQueue(message: newMessage)
            }
            
          }

        case .verifiedNodeIDSimpleSetSufficient, .verifiedNodeIDFullProtocolRequired, .initializationCompleteSimpleSetSufficient, .initializationCompleteFullProtocolRequired:
          
          if let alias = message.sourceNIDAlias, let newNodeId = UInt64(bigEndianData: message.payload) {
            addNodeIdAliasMapping(nodeId: newNodeId, alias: alias)
            message.sourceNodeId = newNodeId
          }
          
          fallthrough

        default:
          
          switch message.flags {
            
          case .onlyFrame:
            
            addToInputQueue(message: message)
            
          case .firstFrame:
            
            splitFrames[frame.splitFrameId] = frame
            
          case .middleFrame, .lastFrame:
            
            if let first = splitFrames[frame.splitFrameId] {
              frame.data.removeFirst(2)
              first.data += frame.data
              if message.flags == .lastFrame, let newMessage = OpenLCBMessage(frame: first) {
                splitFrames.removeValue(forKey: first.splitFrameId)
                newMessage.timeStamp = first.timeStamp
                newMessage.flags = .onlyFrame
                newMessage.sourceNodeId = message.sourceNodeId
                newMessage.destinationNodeId = message.destinationNodeId
                addToInputQueue(message: message)
              }
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
            errorMessage.sourceNodeId = internalNode.nodeId
            errorMessage.payload = OpenLCBErrorCode.temporaryErrorOutOfOrderStartFrameBeforeFinishingPreviousMessage.bigEndianData
            addToOutputQueue(message: errorMessage)
          }
          datagrams.removeValue(forKey: oldMessage.datagramId)
        }
        else {
          datagrams[message.datagramId] = message
        }
        
      case .datagramMiddleFrame, .datagramFinalFrame:
        
        if let first = datagrams[message.datagramId] {
          first.payload += message.payload
          if message.canFrameType == .datagramFinalFrame {
            datagrams.removeValue(forKey: first.datagramId)
            addToInputQueue(message: first)
          }
        }
        else if let internalNode = managedAliasLookup[message.destinationNIDAlias!] {
          let errorMessage = OpenLCBMessage(messageTypeIndicator: .datagramRejected)
          errorMessage.destinationNIDAlias = message.sourceNIDAlias
          errorMessage.sourceNIDAlias = internalNode.alias!
          errorMessage.sourceNodeId = internalNode.nodeId
          errorMessage.payload = OpenLCBErrorCode.temporaryErrorOutOfOrderMiddleOrEndFrameWithoutStartFrame.bigEndianData
          addToOutputQueue(message: errorMessage)
        }
        
      default:
        break
      }
      
    }
    
  }

  public func addToInputQueue(message: OpenLCBMessage) {
    inputQueue.append(message)
    processInputQueue()
  }
  
  internal func processInputQueue() {
    
    guard !inputQueue.isEmpty else {
      return
    }
    
    processInputQueueLock.lock()
    
    let ok = !isProcessingInputQueue
    
    if ok {
      isProcessingInputQueue = true
    }
    
    processInputQueueLock.unlock()

    guard ok else {
      return
    }
    
    for message in inputQueue {
      
      inputQueue.removeFirst()
      
      if message.sourceNodeId == nil, let alias = message.sourceNIDAlias {
        message.sourceNodeId = aliasLookup[alias]
      }
      
      if message.destinationNodeId == nil, let alias = message.destinationNIDAlias {
        message.destinationNodeId = aliasLookup[alias]
      }
      
      if !message.isMessageComplete {
        inputQueue.append(message)
      }
      else {
        
        var route = true

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
          
        case .consumerIdentifiedAsCurrentlyValid, .consumerIdentifiedAsCurrentlyInvalid, .consumerIdentifiedWithValidityUnknown:
          
          externalConsumedEvents.insert(message.eventId!)

        case .consumerRangeIdentified:
          
          if let range = message.eventRange {
            
            var found = false
            
            for r in externalConsumedEventRanges {
              if r.eventId == range.eventId {
                found = true
                break
              }
            }
            
            if !found {
              externalConsumedEventRanges.append(range)
            }
            
          }

        case .producerConsumerEventReport:
          
          if let eventId = message.eventId {
            
            if !(message.isAutomaticallyRoutedEvent || internalConsumedEvents.contains(eventId)) {
              
              var found = false
              
              for range in internalConsumedEventRanges {
                if eventId >= range.startId && eventId <= range.endId {
                  found = true
                  break
                }
              }
              
              if !found {
                route = false
              }
              
            }
            
          }
          else {
            #if DEBUG
            debugLog(message: "Producer Consumer Event Report without Event Id")
            #endif
          }

        default:
          break
        }

        if route {
          networkLayer?.sendMessage(gatewayNodeId: nodeId, message: message)
        }
        
      }
      
    }
    
    isProcessingInputQueue = false
    
  }

}
