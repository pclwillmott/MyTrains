//
//  OpenLCBCANGateway - TX.swift
//  MyTrains
//
//  Created by Paul Willmott on 16/02/2024.
//

import Foundation

extension OpenLCBCANGateway {
  
  // This is may or may not be running in the main thread
  public func send(data: [UInt8], isBackgroundThread:Bool) {
    
    var temp = data
    temp.append(0)
    
    if let frame = LCCCANFrame(message: String(cString: temp)) {
      networkLayer?.canFrameSent(gateway: self, frame: frame, isBackgroundThread: isBackgroundThread)
    }
    
    sendToSerialPortPipe?.write(data: data)
    
  }

  public func send(data:String, isBackgroundThread:Bool) {
    send(data: [UInt8](data.utf8), isBackgroundThread: isBackgroundThread)
  }

  internal func send(header: String, data:String, isBackgroundThread:Bool) {
    if let serialPort, serialPort.isOpen {
      let packet = ":X\(header)N\(data);"
      send(data: packet, isBackgroundThread: isBackgroundThread)
    }
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
        
        switch message.messageTypeIndicator {
          
        case .datagram:
          
          if message.payload.count <= 8 {
            if let frame = LCCCANFrame(message: message, canFrameType: .datagramCompleteInFrame, data: message.payload) {
              send(data: frame.message, isBackgroundThread: false)
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
                send(data: frame.message, isBackgroundThread: false)
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
              send(data: frame.message, isBackgroundThread: false)
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
                send(data: frame.message, isBackgroundThread: false)
              }
              
            }
            
          }
          
        default:
          
          if message.messageTypeIndicator.isAddressPresent {
            
            if let frame = LCCCANFrame(message: message) {
              
              if frame.data.count <= 8 {
                send(data: frame.message, isBackgroundThread: false)
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
                    send(data: frame.message, isBackgroundThread: false)
                  }
                  
                }
                
              }
              
            }
            
          }
          else if let frame = LCCCANFrame(message: message) {
            send(data: frame.message, isBackgroundThread: false)
          }
          
        }
        
        outputQueue.remove(at: index)
        
      }
      
    }
    
    outputQueueLock.unlock()
    
    startWaitTimer(interval: 1.00)
    
  }

}
