//
//  IntExtensions.swift
//  MyTrains
//
//  Created by Paul Willmott on 15/01/2022.
//

import Foundation

extension Int {
  
  public var bigEndianData : [UInt8] {
    get {
      var intValue = UInt(bitPattern: self)
      var data : [UInt8] = []
      for _ in 1...MemoryLayout<UInt>.size {
        let byte = UInt8(intValue & 0xff)
        data.insert(byte, at: 0)
        intValue >>= 8
      }
      return data
    }
  }
  
  public static func fromMultiBaseString(stringValue: String) -> Int? {
    
    let strVal = stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
    
    if strVal.prefix(2) == "0x" {
      if let nn = Int(strVal.suffix(strVal.count-2), radix: 16) {
        return nn
      }
    }
    else if strVal.prefix(2) == "0b" {
      if let nn = Int(strVal.suffix(strVal.count-2), radix: 2) {
        return nn
      }
    }
    else if strVal.prefix(1) == "0" {
      if let nn = Int(strVal.suffix(strVal.count), radix: 8) {
        return nn
      }
    }
    else {
      if let nn = Int(strVal.suffix(strVal.count), radix: 10) {
        return nn
      }
    }
    
    return nil
    
  }
  
}

extension Int8 {
  
  public var bigEndianData : [UInt8] {
    get {
      return [UInt8(bitPattern: self)]
    }
  }
  
}

extension Int16 {
  
  public var bigEndianData : [UInt8] {
    get {
      var intValue = UInt16(bitPattern: self)
      var data : [UInt8] = []
      for _ in 1...MemoryLayout<UInt16>.size {
        let byte = UInt8(intValue & 0xff)
        data.insert(byte, at: 0)
        intValue >>= 8
      }
      return data
    }
  }
  
}

extension Int32 {
  
  public var bigEndianData : [UInt8] {
    get {
      var intValue = UInt32(bitPattern: self)
      var data : [UInt8] = []
      for _ in 1...MemoryLayout<UInt32>.size {
        let byte = UInt8(intValue & 0xff)
        data.insert(byte, at: 0)
        intValue >>= 8
      }
      return data
    }
  }
  
}

extension Int64 {
  
  public var bigEndianData : [UInt8] {
    get {
      var intValue = UInt64(bitPattern: self)
      var data : [UInt8] = []
      for _ in 1...MemoryLayout<UInt64>.size {
        let byte = UInt8(intValue & 0xff)
        data.insert(byte, at: 0)
        intValue >>= 8
      }
      return data
    }
  }
  
}

enum FileOpenMode {
  static let O_APPEND   = 0x0008  /* set append mode              */
  static let O_CREAT    = 0x0200  /* create if nonexistant        */
  static let O_RDONLY   = 0x0000  /* open for reading only        */
  static let O_RDWR     = 0x0002  /* open for reading and writing */
  static let O_TRUNC    = 0x0400  /* truncate to zero length      */
  static let O_WRONLY   = 0x0001  /* open for writing only        */
}

public extension FileHandle {
  
  class func openFile(path: String, mode: Int32) -> FileHandle? {
    
    let fm = FileManager()
    
    if !fm.fileExists(atPath: path) && mode & O_CREAT == O_CREAT {
      FileManager.default.createFile(atPath: path, contents: nil)
    }
    
    var fp : FileHandle?
    
    if mode & O_RDWR == O_RDWR {
      fp = FileHandle(forUpdatingAtPath: path)
    }
    else if mode & O_WRONLY == O_WRONLY {
      fp = FileHandle(forWritingAtPath: path)
    }
    else if mode & O_RDONLY == O_RDONLY {
      fp = FileHandle(forReadingAtPath: path)
    }
    
    if let f = fp {
      if mode & O_TRUNC == O_TRUNC {
        f.truncateFile(atOffset: 0)
      }
      if mode & O_APPEND == O_APPEND {
        f.seekToEndOfFile()
      }
    }
    
    return fp
    
  }

}

