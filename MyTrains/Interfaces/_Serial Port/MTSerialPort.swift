//
//  MTSerialPort.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/05/2022.
//

import Foundation
import Cocoa

@objc public protocol MTSerialPortDelegate {
  @objc optional func serialPort(_ serialPort: MTSerialPort, didReceive data: [UInt8])
}
   
public enum SerialPortState {
  
  case closed
  case open
  case removed
  
}

public class MTSerialPort : NSObject, MTSerialPortManagerDelegate, MTPipeDelegate {
  
  // MARK: Constructors
  
  init?(path: String) {
    
    _path = path
    
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
    self._parity = Parity(rawValue: UInt8(par_value)) ?? .none
    self._usesRTSCTSFlowControl = ctsrts == 1
    
    self.path = path
    self.baudRate = _baudRate
    self.numberOfDataBits = _numberOfDataBits
    self.numberOfStopBits = _numberOfStopBits
    self.parity = _parity
    self.usesRTSCTSFlowControl = _usesRTSCTSFlowControl
    
    closeSerialPort(_fd)
    
    txPipe = MTPipe(name: MTSerialPort.pipeName(path: path))
    
    super.init()
    
    txPipe.open(delegate: self)
    
    observerId = MTSerialPortManager.addObserver(observer: self)
    
  }
  
  // MARK: Destructors
  
  deinit {
    
    txPipe.close()
    
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
  
  private var _path : String
  
  private var observerId : Int = -1
  
  private var txPipe : MTPipe
  
  // MARK: Public Properties
  
  public var path : String
  
  public var baudRate : BaudRate = .br115200
  
  public var numberOfDataBits : Int32 = 8
  
  public var numberOfStopBits : Int32 = 1
  
  public var parity : Parity = .none
  
  public var usesRTSCTSFlowControl : Bool = false
  
  public var delegate : MTSerialPortDelegate?
  
  public var isOpen : Bool {
    return state == .open
  }
  
  public var state : SerialPortState = .closed
  
  // MARK: Private Methods
  
  // This is called from inside a background thread
  private func monitorPort() {
    
    let kInitialBufferSize = 0x10000
    
    let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: kInitialBufferSize)
    
    buffer.initialize(repeating: 0, count: kInitialBufferSize)
    
    defer {
      buffer.deinitialize(count: kInitialBufferSize)
    }
    
    repeat {
      
      let nbyte = readSerialPort(fd, buffer, kInitialBufferSize)
      
      if nbyte == -1 {
        state = .removed
        quit = true
      }
      else if nbyte > 0 {
        
        var data = [UInt8]()
        
        for index in 0...nbyte-1 {
          data.append(buffer.advanced(by: index).pointee)
        }
        
        // This is sent on the background thread
        self.delegate?.serialPort?(self, didReceive: data)
        
      }
      
    } while !quit;
    
    // try and restore previous options
    
    setSerialPortOptions(fd, _baudRate.baudRate, _numberOfDataBits, _numberOfStopBits, Int32(_parity.rawValue), _usesRTSCTSFlowControl ? 1 : 0)
    
    closeSerialPort(fd);
    
    fd = -1
    
    if state == .open {
      state = .closed
    }
    
  }
  
  private func write(data:[UInt8]) {
    
    if state == .open {
      
      let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
      
      defer {
        buffer.deinitialize(count: data.count)
      }
      
      for index in 0...data.count-1 {
        buffer.advanced(by: index).pointee = data[index]
      }
      
      let count = writeSerialPort(self.fd, buffer, data.count)
      
      if count != data.count {
        state = .removed
        self.quit = true
      }
      
    }
    
  }

  
  // MARK: Public Methods
  
  public func open() {
    
    quit = false
    
    fd = openSerialPort(path)
    
    if fd != -1 {
      
      if setSerialPortOptions(fd, baudRate.baudRate, numberOfDataBits, numberOfStopBits, Int32(parity.rawValue), usesRTSCTSFlowControl ? 1 : 0) == 0 {
        
        state = .open
        
        DispatchQueue.global(qos: .userInteractive /* .background */ /* .utility*/).async {
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
    
  // MARK: MTSerialPortManagerDelegate Methods
  
  @objc public func serialPortWasAdded(path:String) {
    
    guard path == self.path && state == .removed else {
      return
    }
    
    open()
    
  }
  
  // MARK: MTPipeDelegate Methods
  
  // This is run in the pipe's background thread and is atomic
  @objc public func pipe(_ pipe: MTPipe, data: [UInt8]) {
    write(data: data)
  }

  // MARK: Public Class Methods
  
  public static func pipeName(path:String) -> String {
    return "MyTrains_SerialPort_\((path as NSString).lastPathComponent)"
  }
  
}
