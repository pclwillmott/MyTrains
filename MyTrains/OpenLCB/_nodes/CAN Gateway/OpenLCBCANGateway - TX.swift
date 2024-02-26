//
//  OpenLCBCANGateway - TX.swift
//  MyTrains
//
//  Created by Paul Willmott on 16/02/2024.
//

import Foundation

extension OpenLCBCANGateway {
  
  // This is may or may not be running in the main thread
  public func send(frames:[LCCCANFrame], isBackgroundThread:Bool) {
    
    guard let networkLayer else {
      return
    }
    
    var buffer = ""

    for frame in frames {
      buffer += frame.message
      networkLayer.canFrameSent(gateway: self, frame: frame, isBackgroundThread: isBackgroundThread)
    }

    sendToSerialPortPipe?.write(data: [UInt8](buffer.utf8))

  }

  // This is running in the main thread
  internal func processOutputQueue() {
   
    stopWaitTimer()
    
    guard !outputQueue.isEmpty else {
      return
    }
    
    outputQueueLock.lock()
    
    var index = 0
    
    while index < outputQueue.count {
      
      let message = outputQueue[index]
      
      if message.sourceNIDAlias == nil, let id = message.sourceNodeId {
        if let alias = nodeIdLookup[id] {
          message.sourceNIDAlias = alias
        }
        else {
          sendVerifyNodeIdGlobalCAN(destinationNodeId: id, isBackgroundThread: false)
        }
      }
      
      if let id = message.destinationNodeId, message.destinationNIDAlias == nil {
        if let alias = nodeIdLookup[id] {
          message.destinationNIDAlias = alias
        }
        else {
          sendVerifyNodeIdGlobalCAN(destinationNodeId: id, isBackgroundThread: false)
        }
      }
      
      if !message.isMessageComplete {
        index += 1
      }
      else {
        
        var frames : [LCCCANFrame] = []
        
        switch message.messageTypeIndicator {
          
        case .datagram:
          
          var payload = message.payload
          
          let numberOfFrames = payload.count == 0 ? 1 : 1 + (payload.count - 1) / 8
          
          if numberOfFrames == 1 {
            if let frame = LCCCANFrame(message: message, canFrameType: .datagramCompleteInFrame, data: payload) {
              frames.append(frame)
            }
          }
          else {
            
            for frameNumber in 1 ... numberOfFrames {
              
              var canFrameType : OpenLCBMessageCANFrameType 
              
              switch frameNumber {
              case 1:
                canFrameType = .datagramFirstFrame
              case numberOfFrames:
                canFrameType = .datagramFinalFrame
              default:
                canFrameType = .datagramMiddleFrame
              }
              
              let data = [UInt8](payload.prefix(8))
              payload.removeFirst(data.count)
              
              if let frame = LCCCANFrame(message: message, canFrameType: canFrameType, data: data) {
                frames.append(frame)
              }
              
            }
            
          }
          
        case .producerConsumerEventReport:
          
          var payload = message.eventId!.bigEndianData
          payload.append(contentsOf: message.payload)
          
          let numberOfFrames = 1 + (payload.count - 1) / 8
          
          if numberOfFrames == 1 {
            if let frame = LCCCANFrame(message: message) {
              frames.append(frame)
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
              
              let data = [UInt8](payload.prefix(8))
              payload.removeFirst(data.count)
              
              if let frame = LCCCANFrame(pcerMessage: message, payload: payload) {
                frames.append(frame)
              }
              
            }
            
          }
          
        default:
          
          if let frame = LCCCANFrame(message: message) {
            
            if message.messageTypeIndicator.isAddressPresent {

              var payload = frame.data
              payload.removeFirst(2)

              let numberOfFrames = 1 + (payload.count - 1 ) / 6
              
              if numberOfFrames == 1 {
                frames.append(frame)
              }
              else {
                
                for frameNumber in 1...numberOfFrames {
                  
                  var flags : OpenLCBCANFrameFlag
                  
                  switch frameNumber {
                  case 1:
                    flags = .firstFrame
                  case numberOfFrames:
                    flags = .lastFrame
                  default:
                    flags = .middleFrame
                  }
                  
                  let data = [UInt8](payload.prefix(6))
                  payload.removeFirst(data.count)
                  
                  if let frame = LCCCANFrame(message: message, flags: flags, payload: data) {
                    frames.append(frame)
                  }
                  
                }

              }

            }
            else {
              frames.append(frame)
            }
            
          }

        }
        
        send(frames: frames, isBackgroundThread: false)
        
        outputQueue.remove(at: index)
        
      }
      
    }
    
    outputQueueLock.unlock()
    
    startWaitTimer(interval: 1.0)
    
  }

}
