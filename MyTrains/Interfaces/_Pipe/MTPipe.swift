//
//  MTPipe.swift
//  MyTrains
//
//  Created by Paul Willmott on 17/02/2024.
//

import Foundation
import Cocoa

@objc public protocol MTPipeDelegate {
  @objc optional func pipe(_ pipe: MTPipe, data: [UInt8])
  @objc optional func pipe(_ pipe: MTPipe, message: OpenLCBMessage)
}
    
public class MTPipe : NSObject {
  
  // MARK: Constructors
  
  init(name:String) {
    _name = "/tmp/name"
  }
  
  // MARK: Destructors
  
  deinit {
    close()
  }
  
  // MARK: Private Properties
  
  private var _name = ""
  
  public var _fd : Int32 = -1
  
  private var _delegate : MTPipeDelegate?
  
  private var quit = false
  
  // MARK: Public Properties

  public var isOpen : Bool {
    return _fd != -1
  }
  
  // MARK: Private Methods
  
  private func monitorPipe() {
    
    let kInitialBufferSize = 0x1000
    
    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: kInitialBufferSize)
    
    buffer.initialize(repeating: 0, count: kInitialBufferSize)
     
    defer {
      buffer.deinitialize(count: kInitialBufferSize)
    }

    repeat {
      
      let nbyte = readPipe(_fd, buffer, kInitialBufferSize)
      
      if nbyte == -1 {
    //    quit = true
      }
      else if nbyte > 0 {
        
        var data = [UInt8]()
        
        for index in 0...nbyte-1 {
          data.append(buffer.advanced(by: index).pointee)
        }
      
        DispatchQueue.main.async {
          
          self._delegate?.pipe?(self, data: data)

          if let message = OpenLCBMessage(fullMessage: data) {
            self._delegate?.pipe?(self, message: message)
          }
          
        }
        
      }
      
    } while !quit
    
    closePipe(_fd);
    
    debugLog(message: "quit")
    
    _fd = -1
    
  }
  
  // MARK: Public Methods
  
  public func open(delegate:MTPipeDelegate? = nil) {
    
    self._delegate = delegate
    
    createPipe(_name)
    
    if let delegate {
      
      _fd = openReadPipe(_name)
      
      if _fd == -1 {
        return
      }

      DispatchQueue.global(qos: .background).async {
        self.monitorPipe()
      }
      
    }
    else {
      
      _fd = openWritePipe(_name)
      
      if _fd == -1 {
        return
      }
      
    }

  }
  
  public func close() {
    quit = true
    if _fd != -1 {
      closePipe(_fd)
    }
  }
  
  
  public func sendOpenLCBMessage(message:OpenLCBMessage) {
    guard _fd != -1 else {
      debugLog(message: "pipe not open")
      return
    }
    if let fullMessage = message.fullMessage {
      write(data: fullMessage)
    }
  }
  
  public func write(data:[UInt8]) {
    
    if _fd != -1 {
      
      let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
      
      defer {
        buffer.deinitialize(count: data.count)
      }
      
      for index in 0...data.count-1 {
        buffer.advanced(by: index).pointee = data[index]
      }
      
      let count = writePipe(self._fd, buffer, data.count)
      
      if count != data.count {
        self.quit = true
      }

    }
    
  }
  
}
