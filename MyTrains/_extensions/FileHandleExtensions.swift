//
//  FileHandleExtensions.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/05/2023.
//

import Foundation

enum FileOpenMode {
  static let O_APPEND   = 0x0008  /* set append mode              */
  static let O_CREAT    = 0x0200  /* create if nonexistant        */
  static let O_RDONLY   = 0x0000  /* open for reading only        */
  static let O_RDWR     = 0x0002  /* open for reading and writing */
  static let O_TRUNC    = 0x0400  /* truncate to zero length      */
  static let O_WRONLY   = 0x0001  /* open for writing only        */
}

extension FileHandle {
  
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
