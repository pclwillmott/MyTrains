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
    _name = "/tmp/\(name)"
  }
  
  // MARK: Destructors
  
  deinit {
    close()
    _delegate = nil
  }
  
  // MARK: Private Properties
  
  private var _name = ""
  
  private var _fd : Int32 = -1
  
  private weak var _delegate : MTPipeDelegate?
  
  private var quit = false
  
  // MARK: Public Properties

  public var isOpen : Bool {
    return _fd != -1
  }
  
  // MARK: Private Methods
  
  private func monitorPipe() {
    
    let kInitialBufferSize = 0x10000
    
    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: kInitialBufferSize)
    
    buffer.initialize(repeating: 0, count: kInitialBufferSize)
     
    defer {
      buffer.deinitialize(count: kInitialBufferSize)
    }

    repeat {
      
      let nbyte = readPipe(_fd, buffer, kInitialBufferSize)
      
      if nbyte == -1 {
      }
      else if nbyte > 0 {
        
        var data = [UInt8]()
        
        for index in 0...nbyte-1 {
          data.append(buffer.advanced(by: index).pointee)
        }
      
        // These are sent in the background thread
        
        self._delegate?.pipe?(self, data: data)

      }
      
    } while !quit
    
    closePipe(_fd);
    
    _fd = -1
    
  }
  
  // MARK: Public Methods
  
  public func open(delegate:MTPipeDelegate? = nil) {
    
    createPipe(_name)
    
    self._delegate = delegate
    
    if delegate != nil {
      
      _fd = openReadPipe(_name)
      
      if _fd == -1 {
        return
      }

      DispatchQueue.global(qos: .userInitiated /*.background */).async {
        self.monitorPipe()
      }
      
    }
    else {
      _fd = openWritePipe(_name)
    }

  }
  
  public func close() {
    quit = true
    if _delegate == nil && _fd != -1 {
      closePipe(_fd)
    }
  }
  
  public func sendOpenLCBMessage(message:OpenLCBMessage) {
    guard isOpen else {
      #if DEBUG
      debugLog("pipe not open")
      #endif
      return
    }
    if let fullMessage = message.fullMessage {
      write(data: fullMessage)
    }
    else {
      #if DEBUG
      debugLog("fullMessage failed")
      #endif
    }
  }
  
  public func write(data:[UInt8]) {
    
    guard !data.isEmpty else {
      return
    }
    
    if isOpen {
      
      let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
      
      defer {
        buffer.deinitialize(count: data.count)
      }
      
      for index in 0...data.count-1 {
        buffer.advanced(by: index).pointee = data[index]
      }
      
      let count = writePipe(self._fd, buffer, data.count)
      
      if count != data.count {
        close()
      }

    }
    
  }
  
  public static var pipeBufferSize : Int {
    return Int(pipebufsize())
  }
  
}
