//
//  OpenLCBMemorySpace.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/05/2023.
//

import Foundation

public class OpenLCBMemorySpace {
  
  // MARK: Constructors
  
  init(nodeId:UInt64, space:UInt8, isReadOnly: Bool, description: String) {
    self.nodeId = nodeId
    self.space = space
    self._isReadOnly = isReadOnly
    self.description = description
  }
  
  init(reader: SqliteDataReader, isReadOnly:Bool, description: String) {
    self._isReadOnly = isReadOnly
    decode(sqliteDataReader: reader)
  }
  
  // MARK: Private Properties
  
  private var _isReadOnly : Bool
  
  // MARK: Public Properties
  
  public var delegate : OpenLCBMemorySpaceDelegate?
  
  public var primaryKey : Int = -1
  
  public var nodeId : UInt64 = 0
  
  public var space : UInt8 = 0
  
  public var memory : [UInt8] = []
  
  public var description : String = ""
  
  public var isReadOnly : Bool {
    get {
      return _isReadOnly
    }
  }
  
  public var addressSpaceInformation: OpenLCBNodeAddressSpaceInformation {
    get {
      var result : OpenLCBNodeAddressSpaceInformation
      result.addressSpace = space
      result.highestAddress = UInt32(memory.count - 1)
      result.lowestAddress = UInt32(0)
      result.size = UInt32(memory.count)
      result.isReadOnly = isReadOnly
      result.description = description
      return result
    }
  }
  
  // MARK: Private Methods
  
  // MARK: Public Methods
  
  public func getUInt8(address:Int) -> UInt8? {
    
    if let data = getBlock(address: address, count: 1) {
      return UInt8(bigEndianData: data)
    }
    
    return nil
    
  }
  
  public func getUInt16(address:Int) -> UInt16? {
    
    if let data = getBlock(address: address, count: 2) {
      return UInt16(bigEndianData: data)
    }
    
    return nil

  }
  
  public func getUInt32(address:Int) -> UInt32? {
    
    if let data = getBlock(address: address, count: 4) {
      return UInt32(bigEndianData: data)
    }
    
    return nil

  }
  
  public func getUInt64(address:Int) -> UInt64? {
    
    if let data = getBlock(address: address, count: 8) {
      return UInt64(bigEndianData: data)
    }
    
    return nil

  }
  
  public func getFloat16(address:Int) -> float16_t? {
      
    if let data = getBlock(address: address, count: 2) {
      return float16_t(bigEndianData: data)
    }
    
    return nil

  }

  public func getFloat(address:Int) -> Float? {
    
    if let data = getBlock(address: address, count: 4) {
      return Float(bigEndianData: data)
    }
    
    return nil

  }
  
  public func getDouble(address:Int) -> Double? {
    
    if let data = getBlock(address: address, count: 8) {
      return Double(bigEndianData: data)
    }
    
    return nil

  }

  public func getString(address:Int, count:Int) -> String? {
    
    if let data = getBlock(address: address, count: count) {
      return String(cString: data)
    }

    return nil

  }

  public func isWithinSpace(address:Int, count:Int) -> Bool {
    return (address >= addressSpaceInformation.lowestAddress) && ((address + count - 1) <= addressSpaceInformation.highestAddress)
  }
  
  public func getBlock(address:Int, count:Int) -> [UInt8]? {
    
    guard isWithinSpace(address: address, count: count) else {
      print("getBlock: address:\(address) count:\(count) \(addressSpaceInformation)" )
      return nil
    }
    
    var result : [UInt8] = []
    
    for index in address ... address + count - 1 {
      result.append(memory[index])
    }

    return result
    
  }
  
  public func setUInt(address:Int, value:UInt8) {
    setBlock(address: address, data: value.bigEndianData)
  }

  public func setUInt(address:Int, value:UInt16) {
    setBlock(address: address, data: value.bigEndianData)
  }

  public func setUInt(address:Int, value:UInt32) {
    setBlock(address: address, data: value.bigEndianData)
  }

  public func setUInt(address:Int, value:UInt64) {
    setBlock(address: address, data: value.bigEndianData)
  }
  
  public func setFloat(address:Int, value:Float) {
    setBlock(address: address, data: value.bigEndianData)
  }
  
  public func setDouble(address:Int, value:Double) {
    setBlock(address: address, data: value.bigEndianData)
  }

  public func setFloat(address:Int, value:float16_t) {
    setBlock(address: address, data: value.v.bigEndianData)
  }

  public func setString(address:Int, value:String, fieldSize:Int) {
  
    guard isWithinSpace(address: address, count: fieldSize) else {
      print("setString: address + fieldSize - 1 < memory.count >= memory.count" )
      return
    }
    
    guard value.utf8.count < fieldSize else {
      print("setString: value.utf8.count >= fieldSize" )
      return
    }

    var data : [UInt8] = []

    for byte in value.utf8 {
      data.append(UInt8(byte))
    }

    var index = data.count

    while index < fieldSize {
      data.append(0)
      index += 1
    }

    setBlock(address: address, data: data)

  }
  
  public func setBlock(address:Int, data:[UInt8]) {
    
    guard isWithinSpace(address: address, count: data.count) else {
      print("setBlock: address + data.count - 1 >= memory.count" )
      return
    }
    
    let oldData = getBlock(address: address, count: data.count)!
    
    var isChanged = false
    
    var index = 0
    while index < data.count {
      if oldData[index] != data[index] {
        isChanged = true
        break
      }
      index += 1
    }
    
    if !isChanged {
      return
    }
    
    index = 0
    for byte in data {
      memory[address + index] = byte
      index += 1
    }
    
    memorySpaceChanged(startAddress: address, endAddress: address + data.count - 1)
    
  }
  
  public func memorySpaceChanged(startAddress:Int, endAddress:Int) {
    delegate?.memorySpaceChanged(memorySpace: self, startAddress: startAddress, endAddress: endAddress)
  }

  // MARK: Database Methods
  
  private func decode(sqliteDataReader: SqliteDataReader?) {
  
    if let reader = sqliteDataReader {
      
      primaryKey = reader.getInt(index: 0)!

      nodeId = reader.getUInt64(index: 1)!

      if !reader.isDBNull(index: 2) {
        space = UInt8(reader.getInt(index: 2)! & 0xff)
      }
      
      if !reader.isDBNull(index: 3) {
        memory = reader.getBlob(index: 3)!
      }
      
    }
    
  }

  public func save() {
    
    var sql = "UPDATE [\(TABLE.MEMORY_SPACE)] SET " +
      "[\(MEMORY_SPACE.NODE_ID)] = @\(MEMORY_SPACE.NODE_ID), " +
      "[\(MEMORY_SPACE.SPACE)] = @\(MEMORY_SPACE.SPACE), " +
      "[\(MEMORY_SPACE.MEMORY)] = @\(MEMORY_SPACE.MEMORY) " +
      "WHERE [\(MEMORY_SPACE.MEMORY_SPACE_ID)] = @\(MEMORY_SPACE.MEMORY_SPACE_ID)"

    let conn = Database.getConnection()
    
    let shouldClose = conn.state != .Open
     
    if shouldClose {
      _ = conn.open()
    }
     
    let cmd = conn.createCommand()
     
    cmd.commandText = sql
    
    cmd.parameters.addWithValue(key: "@\(MEMORY_SPACE.MEMORY_SPACE_ID)", value: self.primaryKey)
    cmd.parameters.addWithValue(key: "@\(MEMORY_SPACE.NODE_ID)", value: self.nodeId)
    cmd.parameters.addWithValue(key: "@\(MEMORY_SPACE.SPACE)", value: Int(self.space))
    cmd.parameters.addWithValue(key: "@\(MEMORY_SPACE.MEMORY)", value: self.memory)

   _ = cmd.executeNonQuery()

   if shouldClose {
     conn.close()
   }

  }

  // MARK: Class Properties
  
  public static var columnNames : String {
    get {
      return
        "[\(MEMORY_SPACE.MEMORY_SPACE_ID)], " +
        "[\(MEMORY_SPACE.NODE_ID)], " +
        "[\(MEMORY_SPACE.SPACE)], " +
        "[\(MEMORY_SPACE.MEMORY)]"
    }
  }
  
  public static func getMemorySpace(nodeId: UInt64, space: UInt8, defaultMemorySize: Int, isReadOnly: Bool, description: String) -> OpenLCBMemorySpace {
    
    let conn = Database.getConnection()
    
    let shouldClose = conn.state != .Open
     
    if shouldClose {
      _ = conn.open()
    }
    
    let cmd = conn.createCommand()
     
    cmd.commandText = "SELECT \(columnNames) FROM [\(TABLE.MEMORY_SPACE)] WHERE [\(MEMORY_SPACE.NODE_ID)] = \(nodeId) AND [\(MEMORY_SPACE.SPACE)] = \(space)"

    var result : OpenLCBMemorySpace?
    
    if let reader = cmd.executeReader(), reader.read() {

        result = OpenLCBMemorySpace(reader: reader, isReadOnly: isReadOnly, description: description)

        reader.close()
  
    }
    else {

      result = OpenLCBMemorySpace(nodeId: nodeId, space: space, isReadOnly: isReadOnly, description: description)
      
      if let memorySpace = result {
        
        memorySpace.memory = [UInt8](repeating: 0, count: defaultMemorySize)

        let sql = "INSERT INTO [\(TABLE.MEMORY_SPACE)] (" +
        "[\(MEMORY_SPACE.MEMORY_SPACE_ID)], " +
        "[\(MEMORY_SPACE.NODE_ID)], " +
        "[\(MEMORY_SPACE.SPACE)], " +
        "[\(MEMORY_SPACE.MEMORY)]" +
        ") VALUES (" +
        "@\(MEMORY_SPACE.MEMORY_SPACE_ID), " +
        "@\(MEMORY_SPACE.NODE_ID), " +
        "@\(MEMORY_SPACE.SPACE), " +
        "@\(MEMORY_SPACE.MEMORY)" +
        ")"
        
        let cmd = conn.createCommand()
         
        cmd.commandText = sql
        
        memorySpace.primaryKey = Database.nextCode(tableName: TABLE.MEMORY_SPACE, primaryKey: MEMORY_SPACE.MEMORY_SPACE_ID) ?? 1
        
        cmd.parameters.addWithValue(key: "@\(MEMORY_SPACE.MEMORY_SPACE_ID)", value: memorySpace.primaryKey)
        cmd.parameters.addWithValue(key: "@\(MEMORY_SPACE.NODE_ID)", value: memorySpace.nodeId)
        cmd.parameters.addWithValue(key: "@\(MEMORY_SPACE.SPACE)", value: Int(memorySpace.space))
        cmd.parameters.addWithValue(key: "@\(MEMORY_SPACE.MEMORY)", value: memorySpace.memory)

        _ = cmd.executeNonQuery()

        if shouldClose {
          conn.close()
        }

      }
      
    }
    
    if shouldClose {
      conn.close()
    }

    return result!

  }

  public static func getMemorySpaces() {
    
    let conn = Database.getConnection()
    
    let shouldClose = conn.state != .Open
     
    if shouldClose {
      _ = conn.open()
    }
    
    let cmd = conn.createCommand()
     
    cmd.commandText = "SELECT \(columnNames) FROM [\(TABLE.MEMORY_SPACE)] ORDER BY [\(MEMORY_SPACE.NODE_ID)], [\(MEMORY_SPACE.SPACE)]"

    if let reader = cmd.executeReader() {
      
      while reader.read() {
        let result = OpenLCBMemorySpace(reader: reader, isReadOnly: true, description: "")
        print("*** \(result.nodeId.toHexDotFormat(numberOfBytes: 6)) - 0x\(result.space.toHex(numberOfDigits: 2)) PK: \(result.primaryKey) \(result.memory)")
      }
      
      reader.close()
  
    }
    
    if shouldClose {
      conn.close()
    }

  }

  public static func delete(nodeId: UInt64, space:UInt8) {
    let sql = "DELETE FROM [\(TABLE.MEMORY_SPACE)] WHERE [\(MEMORY_SPACE.NODE_ID)] = \(nodeId) AND [\(MEMORY_SPACE.SPACE)] = \(space)"
    Database.execute(commands: [sql])
  }

}