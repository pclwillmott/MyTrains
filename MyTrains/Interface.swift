//
//  Interface.swift
//  MyTrains
//
//  Created by Paul Willmott on 30/12/2021.
//

import Foundation
import ORSSerial

public enum BaudRate : NSNumber {
  case br19200  =  19200
  case br28800  =  28800
  case br38400  =  38400
  case br57600  =  57600
  case br76800  =  76800
  case br115200 = 115200
  case br230400 = 230400
  case br460800 = 460800
  case br576000 = 576000
  case br921600 = 921600
}

public class Interface : EditorObject, ORSSerialPortDelegate {
  
  // MARK: Constructors
  
  init(reader:SqliteDataReader) {
    super.init(primaryKey: -1)
    decode(sqliteDataReader: reader)
  }
  
  override init(primaryKey: Int) {
    super.init(primaryKey: primaryKey)
  }
  
  // MARK: Destructors
  
  deinit {
    close()
  }
  
  // MARK: Private Properties
  
  private var _manufacturer : Manufacturer = .Digitrax
  
  private var _productCode : ProductCode = .unknown
  
  private var _serialNumber : Int = -1
  
  private var _baudRate : BaudRate = .br57600
  
  private var _devicePath : String = ""
  
  private var modified : Bool = false
  
  private var serialPort : ORSSerialPort?
  
  private var _delegate : ORSSerialPortDelegate?
  
  // MARK: Public Properties
  
  public var isConnected : Bool {
    get {
      return serialPort != nil
    }
  }
  
  public var manufacturer : Manufacturer {
    get {
      return _manufacturer
    }
    set(value) {
      if value != _manufacturer {
        _manufacturer = value
        modified = true
      }
    }
  }
  
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
  
  public var serialNumber : Int {
    get {
      return _serialNumber
    }
    set(value) {
      if value != _serialNumber {
        _serialNumber = value
        modified = true
      }
    }
  }
  
  public var baudRate : BaudRate {
    get {
      return _baudRate
    }
    set(value) {
      if value != _baudRate {
        _baudRate = value
        modified = true
      }
    }
  }
  
  public var devicePath : String {
    get {
      return _devicePath
    }
    set(value) {
      if value != _devicePath {
        _devicePath = value
        modified = true
      }
    }
  }
  
  public var interfaceName : String {
    get {
      return "\(manufacturer) \(productCode) SN: \(serialNumber)"
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
  
  public var isOpen : Bool {
    if let port = serialPort {
      return port.isOpen
    }
    return false
  }
  
  public var partialSerialNumberLow : Int = -1
  
  public var partialSerialNumberHigh : Int = -1
  
  // MARK: Public Methods
  
  override public func displayString() -> String {
    return interfaceName
  }
  
  public func open() {
    if isOpen {
      close()
    }
    if let sp = ORSSerialPort(path: devicePath) {
      serialPort = sp
      sp.delegate = _delegate
      sp.baudRate = baudRate.rawValue
      sp.numberOfDataBits = 8
      sp.numberOfStopBits = 1
      sp.parity = .none
      sp.usesRTSCTSFlowControl = false
      sp.usesDTRDSRFlowControl = false
      sp.usesDCDOutputFlowControl = false
      sp.open()
    }
  }
  
  public func close() {
    serialPort?.close()
    serialPort = nil
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
  
  public func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
    delegate?.serialPort?(serialPort, didReceive: data)
  }

  // MARK: Database Methods
  
  private func decode(sqliteDataReader:SqliteDataReader?) {
    
    if let reader = sqliteDataReader {
      
      primaryKey = reader.getInt(index: 0)!

      if !reader.isDBNull(index: 1) {
        manufacturer = Manufacturer(rawValue: reader.getInt(index: 1)!) ?? .Unknown
      }

      if !reader.isDBNull(index: 2) {
        productCode = ProductCode(rawValue: reader.getInt(index: 2)!) ?? .unknown
      }
      
      if !reader.isDBNull(index: 3) {
        serialNumber = reader.getInt(index: 3)!
      }

      if !reader.isDBNull(index: 4) {
        baudRate = BaudRate(rawValue: NSNumber(nonretainedObject: reader.getInt(index: 4)!)) ?? .br57600
      }

      if !reader.isDBNull(index: 5) {
        devicePath = reader.getString(index: 5)!
      }

    }
    
    modified = false
    
  }

  public func save() {
    
    if modified {
      
      var sql = ""
      
      if !Database.codeExists(tableName: TABLE.INTERFACE, primaryKey: INTERFACE.INTERFACE_ID, code: primaryKey)! {
        sql = "INSERT INTO [\(TABLE.INTERFACE)] (" +
        "[\(INTERFACE.INTERFACE_ID)], " +
        "[\(INTERFACE.INTERFACE_NAME)], " +
        "[\(INTERFACE.MANUFACTURER)], " +
        "[\(INTERFACE.PRODUCT_CODE)], " +
        "[\(INTERFACE.SERIAL_NUMBER)], " +
        "[\(INTERFACE.BAUD_RATE)], " +
        "[\(INTERFACE.DEVICE_PATH)]" +
        ") VALUES (" +
        "@\(INTERFACE.INTERFACE_ID), " +
        "@\(INTERFACE.INTERFACE_NAME), " +
        "@\(INTERFACE.MANUFACTURER), " +
        "@\(INTERFACE.PRODUCT_CODE), " +
        "@\(INTERFACE.SERIAL_NUMBER), " +
        "@\(INTERFACE.BAUD_RATE), " +
        "@\(INTERFACE.DEVICE_PATH)" +
        ")"
        primaryKey = Database.nextCode(tableName: TABLE.INTERFACE, primaryKey: INTERFACE.INTERFACE_ID)!
      }
      else {
        sql = "UPDATE [\(TABLE.INTERFACE)] SET " +
        "[\(INTERFACE.INTERFACE_NAME)] = @\(INTERFACE.INTERFACE_NAME), " +
        "[\(INTERFACE.MANUFACTURER)] = @\(INTERFACE.MANUFACTURER), " +
        "[\(INTERFACE.PRODUCT_CODE)] = @\(INTERFACE.PRODUCT_CODE), " +
        "[\(INTERFACE.SERIAL_NUMBER)] = @\(INTERFACE.SERIAL_NUMBER), " +
        "[\(INTERFACE.BAUD_RATE)] = @\(INTERFACE.BAUD_RATE), " +
        "[\(INTERFACE.DEVICE_PATH)] = @\(INTERFACE.DEVICE_PATH) " +
        "WHERE [\(INTERFACE.INTERFACE_ID)] = @\(INTERFACE.INTERFACE_ID)"
      }

      let conn = Database.getConnection()
      
      let shouldClose = conn.state != .Open
       
      if shouldClose {
         _ = conn.open()
      }
       
      let cmd = conn.createCommand()
       
      cmd.commandText = sql
      
      cmd.parameters.addWithValue(key: "@\(INTERFACE.INTERFACE_ID)", value: primaryKey)
      cmd.parameters.addWithValue(key: "@\(INTERFACE.INTERFACE_NAME)", value: interfaceName)
      cmd.parameters.addWithValue(key: "@\(INTERFACE.MANUFACTURER)", value: manufacturer.rawValue)
      cmd.parameters.addWithValue(key: "@\(INTERFACE.PRODUCT_CODE)", value: productCode.rawValue)
      cmd.parameters.addWithValue(key: "@\(INTERFACE.SERIAL_NUMBER)", value: serialNumber)
      cmd.parameters.addWithValue(key: "@\(INTERFACE.BAUD_RATE)", value: Int(truncating: baudRate.rawValue))
      cmd.parameters.addWithValue(key: "@\(INTERFACE.DEVICE_PATH)", value: devicePath)

      _ = cmd.executeNonQuery()

      if shouldClose {
        conn.close()
      }
      
      modified = false
      
    }

  }

  // Class Properties
  
  public static var columnNames : String {
    get {
      return
        "[\(INTERFACE.INTERFACE_ID)], " +
        "[\(INTERFACE.INTERFACE_NAME)], " +
        "[\(INTERFACE.MANUFACTURER)], " +
        "[\(INTERFACE.PRODUCT_CODE)], " +
        "[\(INTERFACE.SERIAL_NUMBER)], " +
        "[\(INTERFACE.BAUD_RATE)], " +
        "[\(INTERFACE.DEVICE_PATH)]"
    }
  }
  
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

}
