//
//  InterfaceLocoNet.swift
//  MyTrains
//
//  Created by Paul Willmott on 16/06/2023.
//

import Foundation
import Cocoa
import AVFoundation

enum InterfaceState {
  case idle
  case spacing
  case waitingForResponse
}

public class InterfaceLocoNet : Interface {
  
  // MARK: Private Properties
  
  private var outputQueue : [LocoNetOutputQueueItem] = []
  
  private var outputQueueLock : NSLock = NSLock()
  
  private var outputTimer : Timer?
  
  private var interfaceState : InterfaceState = .idle
  
  internal var commandStationType : LocoNetCommandStationType = .DT200
  
  // MARK: Public Properties
  
  public var commandStation : InterfaceLocoNet? {
    get {
      return network?.commandStation
    }
  }
  
  public var trackPowerOn : Bool = false
  
  public var globalEmergencyStop : Bool = false
  
  public var implementsProtocol0 : Bool {
    get {
      return commandStationType.protocolsSupported.contains(.protocol0)
    }
  }
  
  public var implementsProtocol1 : Bool {
    get {
      return commandStationType.protocolsSupported.contains(.protocol1)
    }
  }

  public var implementsProtocol2 : Bool {
    get {
      return commandStationType.protocolsSupported.contains(.protocol2)
    }
  }

  // MARK: Private Methods
  
  private func networkMessageReceived(message: LocoNetMessage) {
    
    switch message.messageType {
      
    case .opSwDataAP1:
      
      let trackByte = message.message[7]
      
      let mask_TrackPower    : UInt8 = 0b00000001
      let mask_EmergencyStop : UInt8 = 0b00000010
      let mask_Protocol1     : UInt8 = 0b00000100

      if (trackByte & mask_Protocol1) == mask_Protocol1, let csType = LocoNetCommandStationType(rawValue: message.message[11]) {
          commandStationType = csType
      }
      
      trackPowerOn = (trackByte & mask_TrackPower) == mask_TrackPower
      
      if commandStationType.idleSupportedByDefault {
        globalEmergencyStop = (trackByte & mask_EmergencyStop) != mask_EmergencyStop
      }
      
    default:
      break
    }
    
  }
  
  private func sendMessage() {
    
    var startTimer = false
    
    var delay : TimeInterval = 0.0
    
    var timeout : LocoNetMessage?
    
    outputQueueLock.lock()
    
    if outputQueue.count > 0 && interfaceState == .idle {
        
      let item = outputQueue[0]
      
      if item.retryCount > 0 {
      
        send(data: item.message.message)
        
        if item.responseExpected {
          interfaceState = .waitingForResponse
        }
        else {
          interfaceState = .spacing
          outputQueue.remove(at: 0)
        }
        
        item.retryCount -= 1
          
        delay = item.delay
        
        startTimer = true
        
      }
      else {
        
        if item.timeoutCode != .none {
          timeout = LocoNetMessage(networkId: networkId, timeoutCode: item.timeoutCode)
        }
        
        outputQueue.remove(at: 0)

      }

    }
    
    outputQueueLock.unlock()
    
    if let timeoutMessage = timeout {
      for observer in observers {
        observer.value.networkMessageReceived?(message: timeoutMessage)
        observer.value.progMessageReceived?(message: timeoutMessage)
      }
    }
    
    if startTimer {
      startSpacingTimer(timeInterval: delay)
    }
    
  }
 
  @objc func spacingTimer() {
    stopSpacingTimer()
    outputQueueLock.lock()
    interfaceState = .idle
    outputQueueLock.unlock()
    sendMessage()
  }
  
  func startSpacingTimer(timeInterval:TimeInterval) {
    outputTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(spacingTimer), userInfo: nil, repeats: false)
    RunLoop.current.add(outputTimer!, forMode: .common)
  }
  
  func stopSpacingTimer() {
    outputTimer?.invalidate()
    outputTimer = nil
    outputQueueLock.lock()
    interfaceState = .idle
    outputQueueLock.unlock()
  }

  // MARK: Public Methods
        
  public func addToQueue(message:LocoNetMessage, delay:TimeInterval, responses: Set<LocoNetMessageType>, retryCount: Int, timeoutCode: TimeoutCode) {
    
    let item = LocoNetOutputQueueItem(message: message, delay: delay, responses: responses, retryCount: retryCount, timeoutCode: timeoutCode)
    
    outputQueueLock.lock()
    outputQueue.append(item)
    outputQueueLock.unlock()
    
    sendMessage()
    
  }
  
  public func addToQueue(message:LocoNetMessage, delay:TimeInterval) {
    addToQueue(message: message, delay: delay, responses: [], retryCount: 0, timeoutCode: .none)
  }
  
  public override func parseInput() {

    var doAgain = true
    
    while doAgain {
      
      doAgain = false
      
      // find the start of a message
      
      var opCodeFound : Bool
      
      opCodeFound = false
      
      bufferLock.lock()
      while bufferCount > 0 {
        let cc = buffer[readPtr]
        if ((cc & 0x80) != 0) {
          opCodeFound = true
          break
        }
        readPtr = (readPtr + 1) & 0xfff
        bufferCount -= 1
      }
      bufferLock.unlock()
      
      if opCodeFound {
        
       var length = (buffer[readPtr] & 0b01100000) >> 5
        
        switch length {
        case 0b00 :
          length = 2
          break
        case 0b01 :
          length = 4
          break
        case 0b10 :
          length = 6
          break
        default :
          length = bufferCount > 1 ? buffer[(readPtr+1) & 0xfff] : 0xff
          break
        }
        
        if length < 0xff && bufferCount >= length {
          
         var message : [UInt8] = [UInt8](repeating: 0x00, count:Int(length))
          
          var restart : Bool = false
          
          bufferLock.lock()
          
          var index : Int = 0
          
          while index < length {
            
            let cc = buffer[readPtr]
            
            // check that there are no high bits set in the data bytes
            
            if index > 0 && ((cc & 0x80) != 0x00) {
              restart = true
              break
            }
            
            message[index] = cc
            
            readPtr = (readPtr + 1) & 0xfff
            index += 1
            bufferCount -= 1
            
          }
          
          // Do another loop if there are at least 2 bytes in the buffer
          
          doAgain = bufferCount > 1
          
          bufferLock.unlock()
          
          // Process message if no high bits set in data
          
          if !restart {
          
            let networkMessage = LocoNetMessage(networkId: networkId, data: message)
            
            networkMessage.timeStamp = Date.timeIntervalSinceReferenceDate
            networkMessage.timeSinceLastMessage = networkMessage.timeStamp - lastTimeStamp
            lastTimeStamp = networkMessage.timeStamp
            
            if networkMessage.checkSumOK && networkMessage.messageType != .busy {
              
              var stopTimer = false
              
              outputQueueLock.lock()
              
              if interfaceState == .waitingForResponse &&
                outputQueue[0].isValidResponse(messageType: networkMessage.messageType) {
                
          //      if networkMessage.messageType != .programmerBusy {
                  
                  outputQueue.remove(at: 0)
                  
                  interfaceState = .spacing
                  
                  stopTimer = true
                  
            //    }
              
              }
              
              outputQueueLock.unlock()
              
              if stopTimer {
                stopSpacingTimer()
              }

              networkMessageReceived(message: networkMessage)
              
              let _ = networkMessage.messageType // Force slot update
              
              for observer in observers {
                
                observer.value.networkMessageReceived?(message: networkMessage)
                
                let progMessages : Set<LocoNetMessageType> = [.progCmdAccepted, .progSlotDataP1, .progCmdAcceptedBlind]
                
                if progMessages.contains(networkMessage.messageType) {
                  observer.value.progMessageReceived?(message: networkMessage)
                }
                
              }
              
              if stopTimer {
                sendMessage()
              }
              
            }

          }
          
        }

      }

    }
  }
  
  public override func serialPortWasOpened(_ serialPort: MTSerialPort) {
    
    super.serialPortWasOpened(serialPort)
    
    getOpSwDataAP1()
    
  }
  
}
