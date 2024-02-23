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
    //      for (_, observer) in observers {
    //        observer.openLCBCANPacketReceived(packet: newframe)
    //      }
          canFrameReceived(frame: newframe)

        }
        else {
     //     for (_, observer) in observers {
     //       observer.rawCANPacketReceived(packet: frame)
     //     }
        }

      }
      else {
        break
      }

      
    }
    
  }

  // This is running in the serail port's background thread
  
  internal func canFrameReceived(frame:LCCCANFrame) {
    
//    debugLog(message: frame.message)
    
    // The node shall restart the [alias allocation] process at the beginning if, before completion of the process, a
    // frame is received that carries a source Node ID alias value that is identical to the alias value being tested by this
    // procedure.
    
    // Items in the initNodeQueue are all in inhibited state, and only the first is attempting to get an alias.
    
    if let item = initNodeQueue.first, let alias = item.alias, alias == frame.sourceNIDAlias {
      stopAliasTimer()
      item.transitionState = .idle
      #if DEBUG
      debugLog("Restarting alias allocation due to alias already allocated: 0x\(alias.toHex(numberOfDigits: 3))")
      #endif
      item.alias = nil
      getAlias()
    }
    
    // A node shall compare the source Node ID alias in each received frame against all reserved Node ID
    // aliases it currently holds. In case of a match, the receiving node shall:

    // Items in the managed alias and nodeId lookups are all in permitted state.
    
    if let item = managedAliasLookup[frame.sourceNIDAlias] {

      // • If the frame is a Check ID (CID) frame, send a Reserve ID (RID) frame in response.

      if let controlFrameFormat = frame.controlFrameFormat, controlFrameFormat.isCheckIdFrame {
        sendReserveIdFrame(alias: frame.sourceNIDAlias)
      }
      
      // • If the frame is not a Check ID (CID) frame, the node is in Permitted state, and the received
      // source Node ID alias is the current Node ID alias of the node, the node shall immediately
      // transition to Inhibited state, send an AMR frame to release and then stop using the current Node
      // ID alias.
      
      else {
        item.state = .inhibited
        item.transitionState = .idle
        item.alias = nil
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
          }
          else {
            addNodeIdAliasMapping(nodeId: nodeId, alias: frame.sourceNIDAlias)
          }
          
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
          
        case .aliasMapResetFrame:
          
          // If a node receives an Alias Map Reset (AMR) frame referencing an alias for another node, the
          // receiving node shall stop using that alias to refer to the AMR-sending node within 100 milliseconds.
          
          removeNodeIdAliasMapping(alias: frame.sourceNIDAlias)
          
        case .errorInformationReport0, .errorInformationReport1, .errorInformationReport2, .errorInformationReport3:
          
          // The node shall restart the process at the beginning if, before completion of the process, any error is
          // encountered during frame transmission.
          
          // Items in the initNodeQueue are all in inhibited state, and only the first is attempting to get an alias.
          
          if let item = initNodeQueue.first {
            stopAliasTimer()
            item.transitionState = .idle
            #if DEBUG
            debugLog("Restarting alias allocation due to transmission error: 0x\(item.alias!.toHex(numberOfDigits: 3))")
            #endif
            item.alias = nil
            getAlias()
          }
          
        default:
          break
        }
        
      }
      
    case .openLCBMessage:
      
      guard let message = OpenLCBMessage(frame: frame), let sourceNIDAlias = message.sourceNIDAlias else {
        return
      }
      
      if let nodeId = aliasLookup[sourceNIDAlias] {
        message.sourceNodeId = nodeId
      }
      else {
        sendVerifyNodeIdNumberAddressed(destinationNodeIdAlias: sourceNIDAlias)
      }
      
      if let destinationNIDAlias = message.destinationNIDAlias {
        if let nodeId = aliasLookup[destinationNIDAlias] {
          message.destinationNodeId = nodeId
        }
        else {
          sendVerifyNodeIdNumberAddressed(destinationNodeIdAlias: destinationNIDAlias)
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
              inputQueue.append(newMessage)
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
            
            inputQueue.append(message)

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
                inputQueue.append(newMessage)
             }
            }
            else {
              #if DEBUG
              debugLog("first frame not found")
              #endif
            }
            
          }
          
        }
        
      case .datagramCompleteInFrame:
        
        inputQueue.append(message)

      case .datagramFirstFrame:
        
        if let oldMessage = datagrams[message.datagramId] {
          if let internalNode = managedAliasLookup[oldMessage.destinationNIDAlias!] {
            let errorMessage = OpenLCBMessage(messageTypeIndicator: .datagramRejected)
            errorMessage.destinationNIDAlias = message.sourceNIDAlias
            errorMessage.sourceNIDAlias = internalNode.alias!
            errorMessage.sourceNodeId = internalNode.nodeId
            errorMessage.payload = OpenLCBErrorCode.temporaryErrorOutOfOrderStartFrameBeforeFinishingPreviousMessage.bigEndianData
            outputQueue.append(errorMessage)
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
            inputQueue.append(first)
          }
        }
        else if let internalNode = managedAliasLookup[message.destinationNIDAlias!] {
          let errorMessage = OpenLCBMessage(messageTypeIndicator: .datagramRejected)
          errorMessage.destinationNIDAlias = message.sourceNIDAlias
          errorMessage.sourceNIDAlias = internalNode.alias!
          errorMessage.sourceNodeId = internalNode.nodeId
          errorMessage.payload = OpenLCBErrorCode.temporaryErrorOutOfOrderMiddleOrEndFrameWithoutStartFrame.bigEndianData
          outputQueue.append(errorMessage)
        }
        
      default:
        break
      }
      
    }
    
    self.processInputQueue()

  }

  // This is running in the serial port's background thread
  
  internal func processInputQueue() {
    
    stopWaitInputTimer()
    
    guard !inputQueue.isEmpty else {
      return
    }
    
    inputQueueLock.lock()
    
    var index = 0
    
    while index < inputQueue.count {
      
      let message = inputQueue[index]
      
      if let alias = message.sourceNIDAlias, message.sourceNodeId == nil {
        message.sourceNodeId = aliasLookup[alias]
      }
      
      if let alias = message.destinationNIDAlias, message.destinationNodeId == nil {
        message.destinationNodeId = aliasLookup[alias]
      }
      
      if !message.isMessageComplete {
        index += 1
      }
      else {
        
        var route = true

        switch message.messageTypeIndicator {
          
 //       case .initializationCompleteSimpleSetSufficient, .initializationCompleteFullProtocolRequired:
          /*
          for (key, datagram) in datagramsAwaitingReceipt {
            if datagram.destinationNodeId == message.sourceNodeId {
              datagramsAwaitingReceipt.removeValue(forKey: key)
            }
          }
          */
 //       case .datagramReceivedOK:
          
 //         datagramsAwaitingReceipt.removeValue(forKey: message.datagramIdReversed)
          
 //       case .datagramRejected:
          /*
          if let datagram = datagramsAwaitingReceipt[message.datagramIdReversed] {
            datagramsAwaitingReceipt.removeValue(forKey: message.datagramIdReversed)
            if message.errorCode.isTemporary {
              addToOutputQueue(message: datagram)
            }
          }
          */
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
            debugLog("Producer Consumer Event Report without Event Id")
            #endif
          }

        default:
          break
        }

        if route {
          DispatchQueue.main.async {
            self.sendMessage(gatewayNodeId: self.nodeId, message: message)
          }
        }
        
        inputQueue.remove(at: index)
        
      }
      
    }
    
    inputQueueLock.unlock()
    
    DispatchQueue.main.async {
      self.startWaitInputTimer(interval: 0.100)
    }
    
  }

}
