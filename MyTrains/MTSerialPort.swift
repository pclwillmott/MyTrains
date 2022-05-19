//
//  MTSerialPort.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/05/2022.
//

import Foundation
import Cocoa

public protocol MTSerialPortDelegate {
  func serialPort(_ serialPort: MTSerialPort, didReceive data: [UInt8])
  func serialPortWasRemovedFromSystem(_ serialPort: MTSerialPort)
  func serialPortWasOpened(_ serialPort: MTSerialPort)
  func serialPortWasClosed(_ serialPort: MTSerialPort)
}
    
public class MTSerialPort {
  
  // MARK: Constructors
  
  init?(path: String) {
    self.path = path
  }
  
  // MARK: Destructors
  
  deinit {
    
    close()
    
  }
  
  // MARK: Private Properties
  
  private var fd : Int32 = -1
  
  private var quit : Bool = false
  
  // MARK: Public Properties

  public var path : String
  
  public var baudRate : BaudRate = .br19200
  
  public var numberOfDataBits : Int32 = 8
  
  public var numberOfStopBits : Int32 = 1
  
  public var parity : Parity = .none
  
  public var usesRTSCTSFlowControl : Bool = false
  
  public var delegate : MTSerialPortDelegate?
  
  public var isOpen : Bool {
    get {
      return fd != -1
    }
  }
  
  // MARK: Private Methods
  
  private func monitorPort() {
    
    let kInitialBufferSize = 256
    
    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: kInitialBufferSize)
    
    buffer.initialize(repeating: 0, count: kInitialBufferSize)
     
    defer {
      buffer.deinitialize(count: kInitialBufferSize)
    }

    DispatchQueue.main.async {
      self.delegate?.serialPortWasOpened(self)
    }

    repeat {
      
      let nbyte = readSerialPort(fd, buffer, kInitialBufferSize)
      
      if nbyte == -1 {
        DispatchQueue.main.async {
          self.delegate?.serialPortWasRemovedFromSystem(self)
        }
        quit = true
      }
      else if nbyte > 0 {
        
        var data = [UInt8]()
        
        for index in 0...nbyte-1 {
          data.append(buffer.advanced(by: index).pointee)
        }
      
        DispatchQueue.main.async {
          self.delegate?.serialPort(self, didReceive: data)
        }
        
      }
      
    } while !quit;
    
    closeSerialPort(fd);
    
    fd = -1
    
    DispatchQueue.main.async {
      self.delegate?.serialPortWasClosed(self)
    }
    
  }
  
  // MARK: Public Methods
  
  public func open() {
    
    quit = false
    
    fd = openSerialPort(path, baudRate.baudRate, numberOfDataBits, numberOfStopBits, parity.rawValue, usesRTSCTSFlowControl ? 1 : 0)
    
    if fd != -1 {
      
      DispatchQueue.global(qos: .utility).async {
        self.monitorPort()
      }
      
    }
    
  }
  
  public func close() {
    quit = true
  }
  
  public func write(data:[UInt8]) {
    
    if fd != -1 {
      
      let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
      
      buffer.initialize(repeating: 0, count: data.count)
       
      defer {
        buffer.deinitialize(count: data.count)
      }
      
      for index in 0...data.count-1 {
        buffer.advanced(by: index).pointee = data[index]
      }
      
      writeSerialPort(fd, buffer, data.count)
      
    }
    
  }
  
}

public enum Parity : Int32 {
  case none = 0
  case even = 1
  case odd = 2
}


