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
    
    var buffer : [UInt8] = []

    for frame in frames {
      
      let item = [UInt8](frame.message.utf8)
      
      if buffer.count + item.count > MTPipe.pipeBufferSize {
        sendToSerialPortPipe?.write(data: buffer)
        buffer.removeAll()
      }
      
      buffer.append(contentsOf: item)
      
      appDelegate.networkLayer?.canFrameSent(gateway: self, frame: frame, isBackgroundThread: isBackgroundThread)
      
    }
    
    sendToSerialPortPipe?.write(data: buffer)

  }

  // This is running in the main thread
  internal func processOutputQueue() {
   
    stopWaitOutputTimer()
    
    guard !outputQueue.isEmpty else {
      return
    }
    
    outputQueueLock!.lock()
    
    var frames : [LCCCANFrame] = []
    
    var index = 0
    
    while index < outputQueue.count {
      
      let message = outputQueue[index]
      
      frames.append(contentsOf: insertAlias(message: message))
      
      if !message.isMessageComplete {
        index += 1
      }
      else {
        
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
        
        outputQueue.remove(at: index)
        
      }
      
    }
    
    send(frames: frames, isBackgroundThread: false)
    
    outputQueueLock!.unlock()
    
    if !isStopping {
      startWaitTimer(interval: 1.0)
    }
    
  }

}
