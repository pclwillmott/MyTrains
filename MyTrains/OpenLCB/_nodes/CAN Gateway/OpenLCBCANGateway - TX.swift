//
//  OpenLCBCANGateway - TX.swift
//  MyTrains
//
//  Created by Paul Willmott on 16/02/2024.
//

import Foundation

extension OpenLCBCANGateway {
  
  public func send(data: [UInt8]) {
    self.serialPort?.write(data:data)
  }

  public func send(data:String) {
    for (_, observer) in observers {
      observer.rawCANPacketSent(packet: data)
    }
    self.serialPort?.write(data:[UInt8](data.utf8))
  }

  internal func send(header: String, data:String) {
    if let serialPort, serialPort.isOpen {
      let packet = ":X\(header)N\(data);"
      send(data: packet)
    }
  }

  public func addToOutputQueue(message: OpenLCBMessage) {
    outputQueue.append(message)
    processOutputQueue()
  }

  internal func processOutputQueue() {
    
    guard !outputQueue.isEmpty else {
      return
    }
    
//    processOutputQueueLock.lock()
    
    for message in outputQueue {
      
      outputQueue.removeFirst()
      
      if message.sourceNIDAlias == nil, let id = message.sourceNodeId {
        message.sourceNIDAlias = nodeIdLookup[id]
      }
      
      if message.destinationNIDAlias == nil, let id = message.destinationNodeId {
        message.destinationNIDAlias = nodeIdLookup[id]
      }
      
      if !message.isMessageComplete {
        outputQueue.append(message)
      }
      else {
        
        switch message.messageTypeIndicator {
          
        case .datagram:
          
     //     datagramsAwaitingReceipt[message.datagramId] = message
          
          if message.payload.count <= 8 {
            if let frame = LCCCANFrame(message: message, canFrameType: .datagramCompleteInFrame, data: message.payload) {
              send(data: frame.message)
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
              
              if let frame = LCCCANFrame(message: message, canFrameType: canFrameType, data: data) {
                send(data: frame.message)
              }
              
            }
            
          }
          
        case .producerConsumerEventReport:
          
          var data : [UInt8] = []
          
          data.append(contentsOf: message.eventId!.bigEndianData)
          data.append(contentsOf: message.payload)
          
          let numberOfFrames = 1 + (data.count - 1) / 8
          
          if numberOfFrames == 1 {
            if let frame = LCCCANFrame(message: message) {
              send(data: frame.message)
            }
          }
          else {
            
            for frameNumber in 1 ... numberOfFrames {
              
              switch frameNumber {
              case 1:
                message.messageTypeIndicator = .producerConsumerEventReportWithPayloadFirstFrame
              case numberOfFrames:
                message.messageTypeIndicator = .producerConsumerEventReportWithPayloadLastFrame
              default:
                message.messageTypeIndicator = .producerConsumerEventReportWithPayloadMiddleFrame
              }
              
              let payload : [UInt8] = [UInt8](data.prefix(8))
              
              data.removeFirst(payload.count)
              
              if let frame = LCCCANFrame(pcerMessage: message, payload: payload) {
                send(data: frame.message)
              }
              
            }
            
          }
          
        default:
          
          if message.messageTypeIndicator.isAddressPresent {
            
            if let frame = LCCCANFrame(message: message) {
              
              if frame.data.count <= 8 {
                send(data: frame.message)
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
                  
                  if let frame = LCCCANFrame(message: message, flags: flags, frameNumber: frameNumber) {
                    send(data: frame.message)
                  }
                  
                }
                
              }
              
            }
            
          }
          else if let frame = LCCCANFrame(message: message) {
            send(data: frame.message)
          }
          
        }
        
      }
      
    }
    
//    processOutputQueueLock.unlock()
    
  }

}
