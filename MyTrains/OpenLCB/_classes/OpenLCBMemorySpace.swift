//
//  OpenLCBMemorySpace.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/05/2023.
//

import Foundation

public class OpenLCBMemorySpace : NSObject {
  
  // MARK: Constructors
  
  init(nodeId:UInt64, space:UInt8, isReadOnly: Bool, description: String) {
    self.nodeId = nodeId
    self.space = space
    self._isReadOnly = isReadOnly
    self.memorySpaceDescription = description
    super.init()
    #if DEBUG
    addInit()
    #endif
  }
  
  init(reader: SqliteDataReader, isReadOnly:Bool, description: String) {
    self._isReadOnly = isReadOnly
    super.init()
    decode(sqliteDataReader: reader)
    #if DEBUG
    addInit()
    #endif
  }
  
  deinit {
    unitConversions.removeAll()
    delegate = nil
    memory.removeAll()
    #if DEBUG
    addDeinit()
    #endif
  }
  
  // MARK: Private Properties
  
  private var _isReadOnly : Bool
  
  private var unitConversions : [Int:UnitConversionType] = [:]
  
  // MARK: Public Properties
  
  public weak var delegate : OpenLCBMemorySpaceDelegate?
  
  public var primaryKey : Int = -1
  
  public var nodeId : UInt64 = 0
  
  public var space : UInt8 = 0
  
  public var standardSpace : OpenLCBNodeMemoryAddressSpace? {
    if let standard = OpenLCBNodeMemoryAddressSpace(rawValue: space) {
      return standard
    }
    return nil
  }
  
  public var memory : [UInt8] = []
  
  public var memorySpaceDescription : String = ""
  
  public var isReadOnly : Bool {
    return _isReadOnly
  }
  
  public var addressSpaceInformation: OpenLCBNodeAddressSpaceInformation {
    
    var result : OpenLCBNodeAddressSpaceInformation
    
    result.addressSpace = space
    result.highestAddress = UInt32(memory.count - 1)
    result.realHighestAddress = result.highestAddress
    
    if let standardSpace, standardSpace == .cv {
      result.highestAddress |= OpenLCBProgrammingMode.defaultProgrammingModeBit7.rawValue
    }
  
    result.lowestAddress = UInt32(0)
    result.size = UInt32(memory.count)
    result.isReadOnly = isReadOnly
    result.description = description
    
    return result
    
  }
  
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
  
  public func getUInt48(address:Int) -> UInt64? {
    
    if let data = getBlock(address: address, count: 6) {
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
    return (address >= addressSpaceInformation.lowestAddress) && ((address + count - 1) <= addressSpaceInformation.realHighestAddress)
  }
  
  public func getBlock(address:Int, count:Int, isInternal:Bool = true) -> [UInt8]? {
    
    guard isWithinSpace(address: address, count: count) else {
      #if DEBUG
      debugLog("address:\(address) count:\(count) \(addressSpaceInformation)" )
      #endif
      return nil
    }
    
    var result : [UInt8] = []
    
    for index in address ... address + count - 1 {
      result.append(memory[index])
    }
    
    if !isInternal, let appNode {
      
      let startAddress = address
      let endAddress = address + count - 1
      
      for (floatAddress, unitConversionType) in unitConversions {
        
        if unitConversionType != .none, requiresReadConversion(startAddress: startAddress, endAddress: endAddress, variableAddress: floatAddress, size: unitConversionType.numberOfBytes) {
          
          var floatBytes : [UInt8] = []
          
          for index in floatAddress ... floatAddress + unitConversionType.numberOfBytes - 1 {
            floatBytes.append(memory[index])
          }
          
          var floatValue : Double = 0.0
          
          switch unitConversionType.numberOfBytes {
          case 2:
            let temp = UInt16(bigEndianData: floatBytes)!
            let float16 : float16_t = float16_t(v: temp)
            floatValue = Double(Float(float16: float16))
          case 4:
            floatValue = Double(Float32(bigEndianData: floatBytes)!)
          case 8:
            floatValue = Double(bigEndianData: floatBytes)!
          default:
            #if DEBUG
            debugLog("unexpected unitConversionType.numberOfBytes - \(unitConversionType.numberOfBytes)")
            #endif
          }
          
          var newValue : Double = 0.0
          
          switch unitConversionType.baseType {
          case .actualLength:
            newValue = UnitLength.convert(fromValue: floatValue, fromUnits: UnitLength.defaultValueActualLength, toUnits: appNode.unitsActualLength)
          case .scaleLength:
            newValue = UnitLength.convert(fromValue: floatValue, fromUnits: UnitLength.defaultValueScaleLength, toUnits: appNode.unitsScaleLength)
          case .actualDistance:
            newValue = UnitLength.convert(fromValue: floatValue, fromUnits: UnitLength.defaultValueActualDistance, toUnits: appNode.unitsActualDistance)
          case .scaleDistance:
            newValue = UnitLength.convert(fromValue: floatValue, fromUnits: UnitLength.defaultValueScaleDistance, toUnits: appNode.unitsScaleDistance)
          case .actualSpeed:
            newValue = UnitSpeed.convert(fromValue: floatValue, fromUnits: UnitSpeed.defaultValueActualSpeed, toUnits: appNode.unitsActualSpeed)
          case .scaleSpeed:
            newValue = UnitSpeed.convert(fromValue: floatValue, fromUnits: UnitSpeed.defaultValueScaleSpeed, toUnits: appNode.unitsScaleSpeed)
          case .time:
            newValue = UnitTime.convert(fromValue: floatValue, fromUnits: UnitTime.defaultValue, toUnits: appNode.unitsTime)
          default:
            break
          }
          
          floatBytes.removeAll()
          
          switch unitConversionType.numberOfBytes {
          case 2:
            floatBytes = Float32(newValue).float16.v.bigEndianData
          case 4:
            floatBytes = Float32(newValue).bigEndianData
          case 8:
            floatBytes = newValue.bigEndianData
          default:
            #if DEBUG
            debugLog("unexpected unitConversionType.numberOfBytes - \(unitConversionType.numberOfBytes)")
            #endif
          }

          let offset = floatAddress - address
          
          var indexIntoResult = max(0, offset)
          
          var indexIntoFloatBytes = max (0, -offset)
          
          while indexIntoResult < result.count && indexIntoFloatBytes < floatBytes.count {
            result[indexIntoResult] = floatBytes[indexIntoFloatBytes]
            indexIntoResult += 1
            indexIntoFloatBytes += 1
          }

        }
        
      }
      
    }

    return result
    
  }
  
  public func zeroMemory() {
    memory = [UInt8](repeating: 0, count: memory.count)
  }
  
  public func setUInt(address:Int, value:UInt8) {
    setBlock(address: address, data: value.bigEndianData, isInternal: true)
  }

  public func setUInt(address:Int, value:UInt16) {
    setBlock(address: address, data: value.bigEndianData, isInternal: true)
  }

  public func setUInt(address:Int, value:UInt32) {
    setBlock(address: address, data: value.bigEndianData, isInternal: true)
  }

  public func setUInt(address:Int, value:UInt64) {
    setBlock(address: address, data: value.bigEndianData, isInternal: true)
  }
  
  public func setUInt48(address:Int, value:UInt64) {
    var data = value.bigEndianData
    data.removeFirst(2)
    setBlock(address: address, data: data, isInternal: true)
  }
  
  public func setFloat(address:Int, value:Float) {
    setBlock(address: address, data: value.bigEndianData, isInternal: true)
  }
  
  public func setDouble(address:Int, value:Double) {
    setBlock(address: address, data: value.bigEndianData, isInternal: true)
  }

  public func setFloat(address:Int, value:float16_t) {
    setBlock(address: address, data: value.v.bigEndianData, isInternal: true)
  }

  public func setString(address:Int, value:String, fieldSize:Int) {
  
    guard isWithinSpace(address: address, count: fieldSize) else {
      #if DEBUG
      debugLog("address + fieldSize - 1 < memory.count >= memory.count \"\(value)\"" )
      #endif
      return
    }
    
    guard value.utf8.count < fieldSize else {
      #if DEBUG
      debugLog("value.utf8.count >= fieldSize \"\(value)\"" )
      #endif
      return
    }

    var data : [UInt8] = []

    data.append(contentsOf: value.utf8)

    var index = data.count

    while index < fieldSize {
      data.append(0)
      index += 1
    }

    setBlock(address: address, data: data, isInternal: true)

  }
  
  public func setBlock(address:Int, data:[UInt8], isInternal:Bool) {
    
    guard isWithinSpace(address: address, count: data.count) else {
      #if DEBUG
      debugLog("address + data.count - 1 >= memory.count" )
      #endif
      return
    }
    
    var index = 0
    for byte in data {
      memory[address + index] = byte
      index += 1
    }
    
    if !isInternal, let appNode {
      
      let endAddress = address + data.count - 1
      
      for (floatAddress, unitConversionType) in unitConversions {
        
        if unitConversionType != .none, requiresWriteConversion(startAddress: address, endAddress: endAddress, variableAddress: floatAddress, size: unitConversionType.numberOfBytes) {
          
          var floatValue : Double = 0.0
          
          switch unitConversionType.numberOfBytes {
          case 2:
            floatValue = Double(Float(float16: getFloat16(address: floatAddress)!))
          case 4:
            floatValue = Double(getFloat(address: floatAddress)!)
          case 8:
            floatValue = getDouble(address: floatAddress)!
          default:
            #if DEBUG
            debugLog("unexpected unitConversionType.numberOfBytes - \(unitConversionType.numberOfBytes)")
            #endif
          }
          
          var newValue : Double = 0.0
          
          switch unitConversionType.baseType {
          case .actualLength:
            newValue = UnitLength.convert(fromValue: floatValue, fromUnits: appNode.unitsActualLength, toUnits: UnitLength.defaultValueActualLength)
          case .scaleLength:
            newValue = UnitLength.convert(fromValue: floatValue, fromUnits: appNode.unitsScaleLength, toUnits: UnitLength.defaultValueScaleLength)
          case .actualDistance:
            newValue = UnitLength.convert(fromValue: floatValue, fromUnits: appNode.unitsActualDistance, toUnits: UnitLength.defaultValueActualDistance)
          case .scaleDistance:
            newValue = UnitLength.convert(fromValue: floatValue, fromUnits: appNode.unitsScaleDistance, toUnits: UnitLength.defaultValueScaleDistance)
          case .actualSpeed:
            newValue = UnitSpeed.convert(fromValue: floatValue, fromUnits: appNode.unitsActualSpeed, toUnits: UnitSpeed.defaultValueActualSpeed)
          case .scaleSpeed:
            newValue = UnitSpeed.convert(fromValue: floatValue, fromUnits: appNode.unitsScaleSpeed, toUnits: UnitSpeed.defaultValueScaleSpeed)
          case .time:
            newValue = UnitTime.convert(fromValue: floatValue, fromUnits: appNode.unitsTime, toUnits: UnitTime.defaultValue)
          default:
            break
          }
          
          switch unitConversionType.numberOfBytes {
          case 2:
            setFloat(address: floatAddress, value: Float32(newValue).float16)
          case 4:
            setFloat(address: floatAddress, value: Float32(newValue))
          case 8:
            setDouble(address: floatAddress, value: newValue)
          default:
            #if DEBUG
            debugLog("unexpected unitConversionType.numberOfBytes - \(unitConversionType.numberOfBytes)")
            #endif
          }

        }
        
      }

      memorySpaceChanged(startAddress: address, endAddress: endAddress)

    }
    
  }
  
  public func memorySpaceChanged(startAddress:Int, endAddress:Int) {
    delegate?.memorySpaceChanged(memorySpace: self, startAddress: startAddress, endAddress: endAddress)
  }
  
  public func requiresReadConversion(startAddress:Int, endAddress:Int, variableAddress:Int, size:Int) -> Bool {
    return ((variableAddress + size - 1) >= startAddress && variableAddress <= endAddress)
  }
  
  public func requiresWriteConversion(startAddress:Int, endAddress:Int, variableAddress:Int, size:Int) -> Bool {
    let variableEndAddress = variableAddress + size - 1
    return (variableEndAddress >= startAddress && variableEndAddress <= endAddress)
  }
  
  public func variableChanged(startAddress:Int, endAddress:Int, variableAddress:Int) -> Bool {
    return variableAddress >= startAddress && variableAddress <= endAddress
  }
  
  public func registerUnitConversion(address:Int, unitConversionType:UnitConversionType) {
    if unitConversionType == .none {
      unitConversions.removeValue(forKey: address)
    }
    else {
      unitConversions[address] = unitConversionType
    }
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
    
    let sql = "UPDATE [\(TABLE.MEMORY_SPACE)] SET " +
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

      if let result {
        
        let extra = defaultMemorySize - result.memory.count
        
        if extra > 0 {
          let data : [UInt8] = [UInt8](repeating: 0, count: extra)
          result.memory.append(contentsOf: data)
          result.save()
        }
        
      }

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

  public static func getVirtualNodes() -> [OpenLCBNodeVirtual] {
    
    var result : [OpenLCBNodeVirtual] = []
    
    for nodeId in getVirtualNodeIds() {
      
      var node : OpenLCBNodeVirtual
      
      var temp : OpenLCBNodeVirtual? = OpenLCBNodeVirtual(nodeId: nodeId)
      
      switch temp!.virtualNodeType {
      case .clockNode:
        node = OpenLCBClock(nodeId: nodeId)
      case .throttleNode:
        node = OpenLCBThrottle(nodeId: nodeId)
      case .locoNetGatewayNode:
        node = LocoNetGateway(nodeId: nodeId)
      case .trainNode:
        node = OpenLCBNodeRollingStockLocoNet(nodeId: nodeId)
      case .applicationNode:
        node =  OpenLCBNodeMyTrains(nodeId: nodeId)
      case .configurationToolNode:
        node = OpenLCBNodeConfigurationTool(nodeId: nodeId)
      case .genericVirtualNode:
        node = OpenLCBNodeVirtual(nodeId: nodeId)
      case .canGatewayNode:
        node = OpenLCBCANGateway(nodeId: nodeId)
      case .locoNetMonitorNode:
        node = OpenLCBLocoNetMonitorNode(nodeId: nodeId)
      case .programmerToolNode:
        node = OpenLCBProgrammerToolNode(nodeId: nodeId)
      case .programmingTrackNode:
        node = OpenLCBProgrammingTrackNode(nodeId: nodeId)
      case .digitraxBXP88Node:
        node = OpenLCBDigitraxBXP88Node(nodeId: nodeId)
      case .digitraxDS64Node:
        node = OpenLCBDigitraxDS64Node(nodeId: nodeId)
      case .layoutNode:
        node = LayoutNode(nodeId: nodeId)
      case .switchboardPanelNode:
        node = SwitchboardPanelNode(nodeId: nodeId)
      case .switchboardItemNode:
        node = SwitchboardItemNode(nodeId: nodeId)
      }
      
      temp = nil
      
      result.append(node)

    }
    
    return result
    
  }
  
  public static func getVirtualNodeIds() -> Set<UInt64> {
    
    var result : Set<UInt64> = []
    
    let conn = Database.getConnection()
    
    let shouldClose = conn.state != .Open
     
    if shouldClose {
      _ = conn.open()
    }
    
    let cmd = conn.createCommand()
     
    cmd.commandText = "SELECT DISTINCT [\(MEMORY_SPACE.NODE_ID)] FROM [\(TABLE.MEMORY_SPACE)]"

    if let reader = cmd.executeReader() {
      while reader.read() {
        result.insert(reader.getUInt64(index: 0)!)
      }
      reader.close()
    }
    
    if shouldClose {
      conn.close()
    }

    return result
    
  }

  public static func delete(nodeId: UInt64, space:UInt8) {
    let sql = "DELETE FROM [\(TABLE.MEMORY_SPACE)] WHERE [\(MEMORY_SPACE.NODE_ID)] = \(nodeId) AND [\(MEMORY_SPACE.SPACE)] = \(space)"
    Database.execute(commands: [sql])
  }

  public static func deleteAllMemorySpaces(forNodeId: UInt64) {
    let sql = "DELETE FROM [\(TABLE.MEMORY_SPACE)] WHERE [\(MEMORY_SPACE.NODE_ID)] = \(forNodeId)"
    Database.execute(commands: [sql])
  }

}
