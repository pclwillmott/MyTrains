//
//  Interface.swift
//  MyTrains
//
//  Created by Paul Willmott on 30/12/2021.
//

import Foundation
import ORSSerial
import Cocoa

public class Interface : LocoNetDevice, ORSSerialPortDelegate {
  
  // MARK: Constructors
  
  // MARK: Destructors
  
  deinit {
    close()
    serialPort = nil
  }
  
  // MARK: Private Properties
  
  private var _productCode : ProductCode = .unknown
  
  private var _serialNumber : Int = -1
  
  private var _baudRate : BaudRate = .br921600
  
  private var _devicePath : String = ""
  
  private var serialPort : ORSSerialPort?
  
  private var _delegate : ORSSerialPortDelegate?
  
  // MARK: Public Properties
  
  public var productCode : ProductCode {
    get {
      return _productCode
    }
    set(value) {
      if value != _productCode {
        _productCode = value
        modified = true
      }
    }
  }
  
  
  public var interfaceName : String {
    get {
      return "\(productCode) SN: \(serialNumber)"
    }
  }
  
  public var delegate : ORSSerialPortDelegate? {
    get {
      return _delegate
    }
    set(value) {
      _delegate = value
      serialPort?.delegate = value
    }
  }
  
  public var isConnected : Bool {
    get {
      return serialPort != nil
    }
  }
  
  public var isOpen : Bool {
    if let port = serialPort {
      return port.isOpen
    }
    return false
  }
  
  public var partialSerialNumberLow : Int = -1
  
  public var partialSerialNumberHigh : Int = -1
  
  public var messenger : NetworkMessenger?
  
  // MARK: Public Methods
  
  override public func displayString() -> String {
    return interfaceName
  }
  
  public func open() {
    
    if isOpen {
      close()
    }
    
    if serialPort == nil {
      if let port = ORSSerialPort(path: devicePath) {
        serialPort = port
      }
    }
    
    if let port = serialPort {
      port.delegate = _delegate
      port.baudRate = baudRate.baudRate
      port.numberOfDataBits = 8
      port.numberOfStopBits = 1
      port.parity = .none
      port.usesRTSCTSFlowControl = false
      port.usesDTRDSRFlowControl = false
      port.usesDCDOutputFlowControl = false
      port.open()
    }
    
  }
  
  public func close() {
    serialPort?.close()
  }
  
  public func send(data: Data) {
    serialPort?.send(data)
  }
  
  // MARK: ORSSerialPortDelegate Methods
  
  public func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
    delegate?.serialPortWasRemovedFromSystem(serialPort)
    self.serialPort = nil
  }
  
  public func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: Error) {
    delegate?.serialPort?(serialPort, didEncounterError: error)
  }
  
  public func serialPortWasOpened(_ serialPort: ORSSerialPort) {
    delegate?.serialPortWasOpened?(serialPort)

  }
  
  public func serialPortWasClosed(_ serialPort: ORSSerialPort) {
    delegate?.serialPortWasClosed?(serialPort)
  }
  
  public func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
    delegate?.serialPort?(serialPort, didReceive: data)
  }

/*
  public static var interfaces : [Int:Interface] {
    
    get {
    
      let conn = Database.getConnection()
      
      let shouldClose = conn.state != .Open
       
      if shouldClose {
        _ = conn.open()
      }
       
      let cmd = conn.createCommand()
       
      cmd.commandText = "SELECT \(columnNames) FROM [\(TABLE.INTERFACE)]"

      var result : [Int:Interface] = [:]
      
      if let reader = cmd.executeReader() {
           
        while reader.read() {
          let interface = Interface(reader: reader)
          result[interface.primaryKey] = interface
        }
           
        reader.close()
           
      }
      
      if shouldClose {
        conn.close()
      }

      return result
      
    }
    
  }
*/
}
