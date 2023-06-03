//
//  OpenLCBNodeConfigurationOptions.swift
//  MyTrains
//
//  Created by Paul Willmott on 03/06/2023.
//

import Foundation

public class OpenLCBNodeConfigurationOptions {
  
  // MARK: Constructors
  
  init(message:OpenLCBMessage) {
    encodedOptions = message.payload
  }
  
  init() {
    
    isWriteUnderMaskSupported           = false
    isUnalignedReadsSupported           = true
    isUnalignedWritesSupported          = true
    isReadFromACDIManufacturerAvailable = false
    isReadFromACDIUserAvailable         = false
    isWriteToACDIUserAvailable          = false
    
    highestAddressSpace = OpenLCBNodeMemoryAddressSpace.cdi.rawValue
    lowestAddressSpace  = OpenLCBNodeMemoryAddressSpace.configuration.rawValue
    
    is1ByteWriteSupported     = true
    is2ByteWriteSupported     = true
    is4ByteWriteSupported     = true
    is64ByteWriteSupported    = true
    isAnyLengthWriteSupported = true
    isStreamSupported         = false
    
    name = ""

  }

  // MARK: Private Properties

  // Masks for available commands
  
  private let maskWriteUnderMaskSupported           : UInt16 = 0x8000
  private let maskUnalignedReadsSupported           : UInt16 = 0x4000
  private let maskUnalignedWritesSupported          : UInt16 = 0x2000
  private let maskReadFromACDIManufacturerAvailable : UInt16 = 0x0800
  private let maskReadFromACDIUserAvailable         : UInt16 = 0x0400
  private let maskWriteToACDIUserAvailable          : UInt16 = 0x0200

  // Masks for write lengths
  
  private let mask1ByteWrite      : UInt8 = 0x80
  private let mask2ByteWrite      : UInt8 = 0x40
  private let mask4ByteWrite      : UInt8 = 0x20
  private let mask64ByteWrite     : UInt8 = 0x10
  private let maskAnyLengthWrite  : UInt8 = 0x02
  private let maskStreamSupported : UInt8 = 0x01
  

  // MARK: Public Properties
  
  public var isWriteUnderMaskSupported : Bool = false
  
  public var isUnalignedReadsSupported : Bool = false
  
  public var isUnalignedWritesSupported : Bool = false
  
  public var isReadFromACDIManufacturerAvailable : Bool = false
  
  public var isReadFromACDIUserAvailable : Bool = false
  
  public var isWriteToACDIUserAvailable : Bool = false
  
  public var highestAddressSpace : UInt8 = OpenLCBNodeMemoryAddressSpace.cdi.rawValue
  
  public var lowestAddressSpace : UInt8 = OpenLCBNodeMemoryAddressSpace.configuration.rawValue
  
  public var is1ByteWriteSupported : Bool = false
  
  public var is2ByteWriteSupported : Bool = false
  
  public var is4ByteWriteSupported : Bool = false
  
  public var is64ByteWriteSupported : Bool = false
  
  public var isAnyLengthWriteSupported : Bool = false
  
  public var isStreamSupported : Bool = false
  
  public var name : String = ""
  
  public var encodedOptions : [UInt8] {
    
    get {
      
      var availableCommands : UInt16 = 0
      
      availableCommands |= isWriteUnderMaskSupported           ? maskWriteUnderMaskSupported           : 0
      availableCommands |= isUnalignedReadsSupported           ? maskUnalignedReadsSupported           : 0
      availableCommands |= isUnalignedWritesSupported          ? maskUnalignedWritesSupported          : 0
      availableCommands |= isReadFromACDIManufacturerAvailable ? maskReadFromACDIManufacturerAvailable : 0
      availableCommands |= isReadFromACDIUserAvailable         ? maskReadFromACDIUserAvailable         : 0
      availableCommands |= isWriteToACDIUserAvailable          ? maskWriteToACDIUserAvailable          : 0
      
      var writeLengths : UInt8 = 0
      
      writeLengths |= is1ByteWriteSupported     ? mask1ByteWrite      : 0
      writeLengths |= is2ByteWriteSupported     ? mask2ByteWrite      : 0
      writeLengths |= is4ByteWriteSupported     ? mask4ByteWrite      : 0
      writeLengths |= is64ByteWriteSupported    ? mask64ByteWrite     : 0
      writeLengths |= isAnyLengthWriteSupported ? maskAnyLengthWrite  : 0
      writeLengths |= isStreamSupported         ? maskStreamSupported : 0
      
      var data : [UInt8] = [0x20, 0x82]
      
      data.append(contentsOf: availableCommands.bigEndianData)
      
      data.append(writeLengths)
      
      data.append(highestAddressSpace)
      
      data.append(lowestAddressSpace)
      
      if !name.isEmpty {
        for byte in name.utf8 {
          data.append(byte)
        }
        data.append(0)
      }
      
      return data
    }
    
    set(payload) {
      
      if let availableCommands = UInt16(bigEndianData: [payload[2], payload[3]]) {
        
        isWriteUnderMaskSupported = (availableCommands & maskWriteUnderMaskSupported) == maskWriteUnderMaskSupported
        
        isUnalignedReadsSupported = (availableCommands & maskUnalignedReadsSupported) == maskUnalignedReadsSupported
        
        isUnalignedWritesSupported = (availableCommands & maskUnalignedWritesSupported) == maskUnalignedWritesSupported
        
        isReadFromACDIManufacturerAvailable = (availableCommands & maskReadFromACDIManufacturerAvailable) == maskReadFromACDIManufacturerAvailable
        
        isReadFromACDIUserAvailable = (availableCommands & maskReadFromACDIUserAvailable) == maskReadFromACDIUserAvailable
        
        isWriteToACDIUserAvailable = (availableCommands & maskWriteToACDIUserAvailable) == maskWriteToACDIUserAvailable
        
        let writeLengths = payload[4]
        
        is1ByteWriteSupported = (writeLengths & mask1ByteWrite) == mask1ByteWrite
        
        is2ByteWriteSupported = (writeLengths & mask2ByteWrite) == mask2ByteWrite
        
        is4ByteWriteSupported = (writeLengths & mask4ByteWrite) == mask4ByteWrite
        
        is64ByteWriteSupported = (writeLengths & mask64ByteWrite) == mask64ByteWrite
        
        isAnyLengthWriteSupported = (writeLengths & maskAnyLengthWrite) == maskAnyLengthWrite
        
        isStreamSupported = (writeLengths & maskStreamSupported) == maskStreamSupported
        
        highestAddressSpace = payload[5]
        
        lowestAddressSpace = payload.count >= 7 ? payload[6] : 0
        
        if  payload.count > 7 {
          var temp = payload
          temp.removeFirst(7)
          name = String(cString: temp)
        }
        
      }

    }
    
  }
  
  // MARK: Private Methods
  
  // MARK: Public Methods
  
}
