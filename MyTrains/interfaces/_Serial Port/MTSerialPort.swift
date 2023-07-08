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
    
    let _fd = openSerialPort(path)
    
    guard _fd != -1 else {
      return nil
    }

    var speed : speed_t = 0
    
    var dataBits : Int32 = 0
    
    var stopBits : Int32 = 0
    
    var ctsrts : Int32 = 0
    
    var par_value : Int32 = 0
    
    guard getSerialPortOptions(_fd, &speed, &dataBits, &stopBits, &par_value, &ctsrts) == 0 else {
      closeSerialPort(_fd)
      return nil
    }
    
    self._baudRate = BaudRate.baudRate(speed: speed)
    self._numberOfDataBits = dataBits
    self._numberOfStopBits = stopBits
    self._parity = Parity(rawValue: par_value) ?? .none
    self._usesRTSCTSFlowControl = ctsrts == 1
    
    self.path = path
    self.baudRate = _baudRate
    self.numberOfDataBits = _numberOfDataBits
    self.numberOfStopBits = _numberOfStopBits
    self.parity = _parity
    self.usesRTSCTSFlowControl = _usesRTSCTSFlowControl
    
    closeSerialPort(_fd)
    
  }
  
  // MARK: Destructors
  
  deinit {
    
    close()
    
  }
  
  // MARK: Private Properties
  
  private var fd : Int32 = -1
  
  private var quit : Bool = false
  
  private var _baudRate : BaudRate
  
  private var _numberOfDataBits : Int32
  
  private var _numberOfStopBits : Int32
  
  private var _parity : Parity
  
  private var _usesRTSCTSFlowControl : Bool
  
  // MARK: Public Properties

  public var path : String
  
  public var baudRate : BaudRate = .br115200
  
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
    
    let kInitialBufferSize = 0x1000
    
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
    
    // try and restore previous options
    
    setSerialPortOptions(fd, _baudRate.baudRate, _numberOfDataBits, _numberOfStopBits, _parity.rawValue, _usesRTSCTSFlowControl ? 1 : 0)
    
    closeSerialPort(fd);
    
    fd = -1
    
    DispatchQueue.main.async {
      self.delegate?.serialPortWasClosed(self)
    }
    
  }
  
  // MARK: Public Methods
  
  public func open() {
    
    quit = false
    
    fd = openSerialPort(path)
    
    if fd != -1 {
      
      if setSerialPortOptions(fd, baudRate.baudRate, numberOfDataBits, numberOfStopBits, parity.rawValue, usesRTSCTSFlowControl ? 1 : 0) == 0 {
      
        DispatchQueue.global(qos: .background /* .utility*/).async {
          self.monitorPort()
        }
        
      }
      else {
        closeSerialPort(fd)
        fd = -1
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
      
      let count = writeSerialPort(self.fd, buffer, data.count)
      
      if count != data.count {
        self.delegate?.serialPortWasRemovedFromSystem(self)
        self.quit = true
      }

    }
    
  }
  
}

