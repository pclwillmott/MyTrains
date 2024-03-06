//
//  CSVParser.swift
//  MyTrains
//
//  Created by Paul Willmott on 25/07/2019.
//  Copyright © 2019 Paul Willmott. All rights reserved.
//

import Foundation

// MARK: CSVParserDelegate

protocol CSVParserDelegate {
  func csvParserDidStartDocument()
  func csvParserDidEndDocument()
  func csvParser(didStartRow row: Int)
  func csvParser(didEndRow row: Int)
  func csvParser(foundCharacters column: Int, string:String)
}

// MARK: CSVParser

class CSVParser {
  
  // MARK: Constructors
  
  init(withURL url: URL){
    self.url = url
  }
  
  // MARK: Private Properties
  
  private var url : URL
  
  private var _numberOfRows = 0
  
  private var _numberOfColumns = 0

  // MARK: Public Properties
  
  public var delegate : CSVParserDelegate?
  
  public var encoding = String.Encoding.utf8
  
  public var columnSeparator : Character = ","
  
  public var stringDelimiter : Character = "\""
  
  public var lineTerminator  : Character = "\n"
  
  public var chunkSize = 65536
  
  public var numberOfRows : Int {
    get {
      return _numberOfRows
    }
  }
  
  public var numberOfColumns : Int {
    get {
      return _numberOfColumns
    }
  }
  
  // MARK: Public Methods
  
  public func parse() {
    
    guard let del = delegate else {
      #if DEBUG
      debugLog("no delegate")
      #endif
      return
    }
    
    guard let fp = FileHandle.openFile(path: url.path, mode: O_RDONLY) else {
      #if DEBUG
      debugLog("can't open file \"\(url.path)\"")
      #endif
      return
    }

    guard let text = String(bytes: fp.readDataToEndOfFile(), encoding: encoding) else {
      #if DEBUG
      debugLog("file read failed")
      #endif
      fp.closeFile()
      return
    }
 
    del.csvParserDidStartDocument()
    
    var row = 0
    var column = 0
    var str = ""
    var inString = false
    var delimiterCount = 0
    
    for c in text {
      
      let isDelimiter = c == stringDelimiter
      
      if inString && !isDelimiter && delimiterCount == 1 {
        inString = false
        delimiterCount = 0
      }
      
      if inString {
        
        if isDelimiter {
          delimiterCount += 1
          if delimiterCount == 2 {
            str += String(stringDelimiter)
            delimiterCount = 0
          }
        }
        else {
          str += String(c)
        }
        
      }
      else if isDelimiter {
        inString = true
        str = ""
      }
      else if c == columnSeparator || c == lineTerminator {
        if column == 0 {
          del.csvParser(didStartRow: row)
        }
        del.csvParser(foundCharacters: column, string: str)
        str = ""
        column += 1
        if column > _numberOfColumns {
          _numberOfColumns = column
        }
        if c == lineTerminator {
          del.csvParser(didEndRow: row)
          row += 1
          _numberOfRows = row
          column = 0
        }
      }
      else if c != "\n" {
        str += String(c)
      }
      
    }
    
    if str != "" {
      if column == 0 {
        del.csvParser(didStartRow: row)
      }
      del.csvParser(foundCharacters: column, string: str)
      del.csvParser(didEndRow: row)
      _numberOfRows += 1
    }
    
    fp.closeFile()
    
    del.csvParserDidEndDocument()
    
  }
  
}

