//
//  OpenLCBNodeVirtual - Messages - Event Transport.swift
//  MyTrains
//
//  Created by Paul Willmott on 23/02/2024.
//

import Foundation
import AppKit

extension OpenLCBNodeVirtual {
  
  public func sendEvent(eventId:UInt64, payload:[UInt8] = []) {
    
    #if DEBUG
    
    if !OpenLCBWellKnownEvent.isAutomaticallyRouted(eventId: eventId) && !eventsProduced.union(userConfigEventsProduced).contains(eventId) {
      
      var found = false
      
      for eventRange in eventRangesProduced {
        if eventId >= eventRange.startId && eventId <= eventRange.endId {
          found = true
          break
        }
      }
      
      if !found {
        
        let alert = NSAlert()
        
        alert.messageText = String(localized: "Sending unadvertised event")
        alert.informativeText = String(localized: "The node \"\(userNodeName)\" (\(nodeId.toHexDotFormat(numberOfBytes: 6))) is attempting to send the unadvertised event: \(eventId.toHexDotFormat(numberOfBytes: 8))")
        alert.addButton(withTitle: "OK")
        alert.alertStyle = .informational
        
        alert.runModal()
        
      }
      
    }
    
    #endif
    
    let message = OpenLCBMessage(messageTypeIndicator: .producerConsumerEventReport)
    message.eventId = eventId
    message.payload = payload
    sendMessage(message: message)
    
  }

  public func sendWellKnownEvent(eventId:OpenLCBWellKnownEvent, payload:[UInt8] = []) {
    sendEvent(eventId: eventId.rawValue, payload: payload)
  }
    
  public func sendIdentifyConsumer(eventId:UInt64) {
    let message = OpenLCBMessage(messageTypeIndicator: .identifyConsumer)
    message.eventId = eventId
    sendMessage(message: message)
  }

  public func sendIdentifyConsumer(event:OpenLCBWellKnownEvent) {
    sendIdentifyConsumer(eventId: event.rawValue)
  }
  
  public func sendConsumerIdentified(eventId:UInt64, validity:OpenLCBValidity) {
    let message = OpenLCBMessage(messageTypeIndicator: validity.consumerMTI)
    message.eventId = eventId
    sendMessage(message: message)
  }

  public func sendConsumerIdentified(wellKnownEvent: OpenLCBWellKnownEvent, validity:OpenLCBValidity) {
    sendConsumerIdentified(eventId: wellKnownEvent.rawValue, validity: validity)
  }

  public func sendConsumerRangeIdentified(eventId:UInt64) {
    let message = OpenLCBMessage(messageTypeIndicator: .consumerRangeIdentified)
    message.eventId = eventId
    sendMessage(message: message)
  }
  
  public func sendIdentifyProducer(eventId:UInt64) {
    let message = OpenLCBMessage(messageTypeIndicator: .identifyProducer)
    message.eventId = eventId
    sendMessage(message: message)
  }

  public func sendIdentifyProducer(event:OpenLCBWellKnownEvent) {
    sendIdentifyProducer(eventId: event.rawValue)
  }
  
  public func sendProducerIdentified(eventId:UInt64, validity:OpenLCBValidity) {
    let message = OpenLCBMessage(messageTypeIndicator: validity.producerMTI)
    message.eventId = eventId
    sendMessage(message: message)
  }

  public func sendProducerIdentified(wellKnownEvent: OpenLCBWellKnownEvent, validity:OpenLCBValidity) {
    sendProducerIdentified(eventId: wellKnownEvent.rawValue, validity: validity)
  }

  public func sendProducerRangeIdentified(eventId:UInt64) {
    let message = OpenLCBMessage(messageTypeIndicator: .producerRangeIdentified)
    message.eventId = eventId
    sendMessage(message: message)
  }
  
  public func sendIdentifyEventsGlobal() {
    let message = OpenLCBMessage(messageTypeIndicator: .identifyEventsGlobal)
    sendMessage(message: message)
  }

  public func sendIdentifyEventsAddressed(destinationNodeId:UInt64) {
    let message = OpenLCBMessage(messageTypeIndicator: .identifyEventsAddressed)
    message.destinationNodeId = destinationNodeId
    message.payload = destinationNodeId.nodeIdBigEndianData
    sendMessage(message: message)
  }

  // MARK: PLACEHOLDER FOR sendLearnEvent

}
