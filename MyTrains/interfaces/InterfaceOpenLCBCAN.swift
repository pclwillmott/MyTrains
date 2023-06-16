//
//  InterfaceOpenLCBCAN.swift
//  MyTrains
//
//  Created by Paul Willmott on 16/06/2023.
//

import Foundation

public class InterfaceOpenLCBCAN : Interface {
  
  // MARK: Private Properties

  internal override func parseInput() {

    let minFrameSize = 13
    
    while bufferCount >= minFrameSize {
      
      enum SearchState {
        case searchingForColon
        case searchingForSemiColon
      }
      
      var state : SearchState = .searchingForColon
      
      bufferLock.lock()
      var index = readPtr
      var tempCount = bufferCount
      bufferLock.unlock()

      var frame : String = ""
      
      while tempCount > 0 {
        
        let char = String(format: "%C", buffer[index])
        
        switch state {
          
        case .searchingForColon:
          
          if char == ":" {
            frame += char
            state = .searchingForSemiColon
          }
          else {
            bufferLock.lock()
            readPtr = (readPtr + 1) & 0xfff
            bufferCount -= 1
            bufferLock.unlock()
          }
          
        case .searchingForSemiColon:
          
          frame += char
          
          if char == ":" {
            let increment = frame.count
            bufferLock.lock()
            readPtr = (readPtr + increment) & 0xfff
            bufferCount -= increment
            bufferLock.unlock()
            frame = char
          }
          else if char == "\n" || char == "\r" {
            let increment = frame.count
            bufferLock.lock()
            readPtr = (readPtr + increment) & 0xfff
            bufferCount -= increment
            bufferLock.unlock()
            frame = ""
            state = .searchingForColon
          }
          else if char == ";" {
            
            let increment = frame.count
            bufferLock.lock()
            readPtr = (readPtr + increment) & 0xfff
            bufferCount -= increment
            bufferLock.unlock()
            
            if let newframe = LCCCANFrame(networkId: networkId, message: frame) {
              
              frame = ""
              
              newframe.timeStamp = Date.timeIntervalSinceReferenceDate
              newframe.timeSinceLastMessage = newframe.timeStamp - lastTimeStamp
              lastTimeStamp = newframe.timeStamp
              
              for (_, observer) in observers {
                observer.lccCANFrameReceived?(frame: newframe)
              }
              
            }
            
            state = .searchingForColon
            
          }
          
        }
        
        index = (index + 1) & 0xfff
        tempCount -= 1
        
      }
      
    }
    
  }

}
