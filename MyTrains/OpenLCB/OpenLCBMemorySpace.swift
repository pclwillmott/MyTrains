//
//  OpenLCBMemorySpace.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/05/2023.
//

import Foundation

public class OpenLCBMemorySpace {
  
  // MARK: Constructors
  
  init(nodeId:UInt64, space:Int) {
    self.nodeId = nodeId
    self.space = space
  }
  
  init(reader: SqliteDataReader) {
    decode(sqliteDataReader: reader)
  }
  
  // MARK: Private Properties
  
  // MARK: Public Properties
  
  public var nodeId : UInt64 = 0
  
  public var space : Int = 0
  
  public var memory : [UInt8] = []
  
  // MARK: Private Methods
  
  // MARK: Public Methods
  
  public func getUInt8(address:Int) -> UInt8? {
    
    guard address < memory.count else {
      return nil
    }
    
    return memory[address]
    
  }
  
  public func setUInt8(address:Int, value:UInt8) {
    
    guard address < memory.count else {
      return
    }
    
    memory[address] = value
    
  }

  public func getUInt16(address:Int) -> UInt16? {
    
    guard address + 1 < memory.count else {
      return nil
    }
    
    var temp : [UInt8] = []
    
    for index in 0...1 {
      temp.append(memory[index])
    }
    return UInt16(bigEndianData: temp)

  }
  
  public func setUInt16(address:Int, value:UInt16) {
    
    guard address + 1 < memory.count else {
      return
    }
    
    memory[address + 0] = UInt8((value >> 8) & 0xff)
    memory[address + 1] = UInt8((value >> 0) & 0xff)
    
  }

  public func getUInt32(address:Int) -> UInt32? {
    
    guard address + 3 < memory.count else {
      return nil
    }
    
    var temp : [UInt8] = []
    
    for index in 0...3 {
      temp.append(memory[index])
    }
    return UInt32(bigEndianData: temp)

  }
  
  public func setUInt32(address:Int, value:UInt32) {
    
    guard address + 3 < memory.count else {
      return
    }
    
    memory[address + 0] = UInt8((value >> 24) & 0xff)
    memory[address + 1] = UInt8((value >> 16) & 0xff)
    memory[address + 2] = UInt8((value >>  8) & 0xff)
    memory[address + 3] = UInt8((value >>  0) & 0xff)

  }

  public func getUInt64(address:Int) -> UInt64? {
    
    guard address + 7 < memory.count else {
      return nil
    }
    
    var temp : [UInt8] = []
    
    for index in 0...7 {
      temp.append(memory[index])
    }
    return UInt64(bigEndianData: temp)
    
  }
  
  public func setUInt64(address:Int, value:UInt64) {
    
    guard address + 7 < memory.count else {
      return
    }
    
    memory[address + 0] = UInt8((value >> 56) & 0xff)
    memory[address + 1] = UInt8((value >> 48) & 0xff)
    memory[address + 2] = UInt8((value >> 40) & 0xff)
    memory[address + 3] = UInt8((value >> 32) & 0xff)
    memory[address + 4] = UInt8((value >> 24) & 0xff)
    memory[address + 5] = UInt8((value >> 16) & 0xff)
    memory[address + 6] = UInt8((value >>  8) & 0xff)
    memory[address + 7] = UInt8((value >>  0) & 0xff)

  }

  // MARK: Database Methods
  
  private func decode(sqliteDataReader: SqliteDataReader?) {
  
    if let reader = sqliteDataReader {
      
      nodeId = reader.getUInt64(index: 0)!
      
      if !reader.isDBNull(index: 1) {
        space = reader.getInt(index: 1)!
      }
      
      if !reader.isDBNull(index: 2) {
        memory = reader.getBlob(index: 2)!
      }
      
    }
    
  }

  public func save() {
    
    let sql = "UPDATE [\(TABLE.MEMORY_SPACE)] SET " +
       "[\(MEMORY_SPACE.NODE_ID)] = @\(MEMORY_SPACE.NODE_ID), " +
       "[\(MEMORY_SPACE.SPACE)] = @\(MEMORY_SPACE.SPACE), " +
       "[\(MEMORY_SPACE.MEMORY)] = @\(MEMORY_SPACE.MEMORY) " +
       "WHERE [\(MEMORY_SPACE.NODE_ID)] = @\(MEMORY_SPACE.NODE_ID) AND [\(MEMORY_SPACE.SPACE)] = @\(MEMORY_SPACE.SPACE)"

     let conn = Database.getConnection()
     
     let shouldClose = conn.state != .Open
      
     if shouldClose {
        _ = conn.open()
     }
      
     let cmd = conn.createCommand()
      
     cmd.commandText = sql
     
     cmd.parameters.addWithValue(key: "@\(MEMORY_SPACE.NODE_ID)", value: self.nodeId)
     cmd.parameters.addWithValue(key: "@\(MEMORY_SPACE.SPACE)", value: self.space)
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
        "[\(MEMORY_SPACE.NODE_ID)], " +
        "[\(MEMORY_SPACE.SPACE)], " +
        "[\(MEMORY_SPACE.MEMORY)]"
    }
  }
  
  public static func getMemorySpace(nodeId:UInt64, space:Int, defaultMemorySize:Int) -> OpenLCBMemorySpace {
    
    let conn = Database.getConnection()
    
    let shouldClose = conn.state != .Open
     
    if shouldClose {
      _ = conn.open()
    }
    
    let cmd = conn.createCommand()
     
    cmd.commandText = "SELECT \(columnNames) FROM [\(TABLE.MEMORY_SPACE)] WHERE [\(MEMORY_SPACE.NODE_ID)] = \(nodeId) AND [\(MEMORY_SPACE.SPACE)] = \(space)"

    var result : OpenLCBMemorySpace?
    
    if let reader = cmd.executeReader(), reader.read() {
      
      result = OpenLCBMemorySpace(reader: reader)
      
      reader.close()
      
    }
    else {

      result = OpenLCBMemorySpace(nodeId: nodeId, space: space)
      
      if let memorySpace = result {
        
        memorySpace.memory = [UInt8](repeating: 0, count: defaultMemorySize)
        memorySpace.memory[0] = 0x34
        memorySpace.memory[1] = 0x35
        memorySpace.memory[2] = 0x36

        var sql = "INSERT INTO [\(TABLE.MEMORY_SPACE)] (" +
        "[\(MEMORY_SPACE.NODE_ID)], " +
        "[\(MEMORY_SPACE.SPACE)], " +
        "[\(MEMORY_SPACE.MEMORY)]" +
        ") VALUES (" +
        "@\(MEMORY_SPACE.NODE_ID), " +
        "@\(MEMORY_SPACE.SPACE), " +
        "@\(MEMORY_SPACE.MEMORY)" +
        ")"
        
        let cmd = conn.createCommand()
         
        cmd.commandText = sql
        
        cmd.parameters.addWithValue(key: "@\(MEMORY_SPACE.NODE_ID)", value: memorySpace.nodeId)
        cmd.parameters.addWithValue(key: "@\(MEMORY_SPACE.SPACE)", value: memorySpace.space)
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
  
  public static func delete(nodeId: UInt64, space:UInt8) {
    let sql = "DELETE FROM [\(TABLE.MEMORY_SPACE)] WHERE [\(MEMORY_SPACE.NODE_ID)] = \(nodeId) AND [\(MEMORY_SPACE.SPACE)] = \(space)"
    Database.execute(commands: [sql])
  }

}
