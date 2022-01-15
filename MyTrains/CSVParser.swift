//
//  CSVParser.swift
//  MyTrains
//
//  Created by Paul Willmott on 25/07/2019.
//  Copyright © 2019 Paul Willmott. All rights reserved.
//

import Foundation

class CSVParser {
  
  public var delegate : CSVParserDelegate?
  public var encoding = String.Encoding.utf8
  public var columnSeparator : Character = ","
  public var stringDelimiter : Character = "\""
  public var lineTerminator  : Character = "\r"
  public var chunkSize = 65536
  
  private var url : URL
  private var _numberOfRows = 0
  private var _numberOfColumns = 0

  init(withURL url: URL){
    self.url = url
  }
  
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
  
  public func parse() {
    
    guard let del = delegate else {
      print("CSVParser: no delegate")
      return
    }
    
    guard let fp = FileHandle.openFile(path: url.path, mode: O_RDONLY) else {
      print("CSVParser: can't open file \"\(url.path)\"")
      return
    }

    guard let text = String(bytes: fp.readDataToEndOfFile(), encoding: encoding) else {
      print("CSVParser: file read failed 2")
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

protocol CSVParserDelegate {
  func csvParserDidStartDocument()
  func csvParserDidEndDocument()
  func csvParser(didStartRow row: Int)
  func csvParser(didEndRow row: Int)
  func csvParser(foundCharacters column: Int, string:String)
}

class StreamReader {
  let encoding: String.Encoding
  let chunkSize: Int
  let fileHandle: FileHandle
  var buffer: Data
  let delimPattern : Data
  var isAtEOF: Bool = false
  
  init?(url: URL, delimeter: String = "\n", encoding: String.Encoding = .utf8, chunkSize: Int = 4096)
  {
    guard let fileHandle = try? FileHandle(forReadingFrom: url) else { return nil }
    self.fileHandle = fileHandle
    self.chunkSize = chunkSize
    self.encoding = encoding
    buffer = Data(capacity: chunkSize)
    delimPattern = delimeter.data(using: .utf8)!
  }
  
  deinit {
    fileHandle.closeFile()
  }
  
  func rewind() {
    fileHandle.seek(toFileOffset: 0)
    buffer.removeAll(keepingCapacity: true)
    isAtEOF = false
  }
  
  func nextLine() -> String? {
    if isAtEOF { return nil }
    
    repeat {
      if let range = buffer.range(of: delimPattern, options: [], in: buffer.startIndex..<buffer.endIndex) {
        let subData = buffer.subdata(in: buffer.startIndex..<range.lowerBound)
        let line = String(data: subData, encoding: encoding)
        buffer.replaceSubrange(buffer.startIndex..<range.upperBound, with: [])
        return line
      } else {
        let tempData = fileHandle.readData(ofLength: chunkSize)
        if tempData.count == 0 {
          isAtEOF = true
          return (buffer.count > 0) ? String(data: buffer, encoding: encoding) : nil
        }
        buffer.append(tempData)
      }
    } while true
  }
}

class newCSVParser {
  
  public var delegate        : CSVParserDelegate?
  public var encoding        = String.Encoding.utf8
  public var columnSeparator = ","
  public var stringDelimiter = "\""
  public var lineTerminator  = "\n"
  public var chunkSize       = 0x10000
  
  private var _numberOfRows = 0
  private var _numberOfColumns = 0
  
  private var fp : FileHandle
  
  init?(withURL url: URL){
    
    guard let handle = FileHandle.openFile(path: url.path, mode: O_RDONLY) else {
      print("CSVParser: can't open file \"\(url.path)\"")
      return nil
    }
    
    fp = handle
    
  }
  
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
  
  public func parse() {

    delegate?.csvParserDidStartDocument()
    
    var row = 0
    var column = 0

    var buffer = Data(capacity: chunkSize)
    
    var patternA =
      [ stringDelimiter.data(using: encoding)!,
        columnSeparator.data(using: encoding)!,
        lineTerminator.data(using: encoding)!]
    
    var patternB =
      [ (stringDelimiter+stringDelimiter).data(using: encoding)!,
        stringDelimiter.data(using: encoding)!]
    
    var outOfString = true
    
    var string = ""
    
    repeat {
      
      var getData = false
      
      if outOfString {
        
        var range : Range<Data.Index>?
        
        var selected = 0
        
        for index in 0..<patternA.count {
          if let tempRange = buffer.range(of: patternA[index], options: [], in: buffer.startIndex..<buffer.endIndex) {
            if range == nil || tempRange.startIndex < range!.startIndex {
              range = tempRange
              selected = index + 1
            }
          }
        }
        
        switch selected {
        case 1: // String delimiter
          outOfString = false
        case 2, 3: // Column separator or Line terminator
          let subData = buffer.subdata(in: buffer.startIndex..<range!.lowerBound)
          let contents = string == "" ? String(data: subData, encoding: encoding) ?? "" : string
          if column == 0 {
            delegate?.csvParser(didStartRow: row)
          }
          delegate?.csvParser(foundCharacters: column, string: contents)
          string = ""
          column += 1
          if column > _numberOfColumns {
            _numberOfColumns = column
          }
          if selected == 3 {
            delegate?.csvParser(didEndRow: row)
            row += 1
            _numberOfRows = row
            column = 0
          }
        default:
          getData = true
        }
        
        if let r = range {
          buffer.replaceSubrange(buffer.startIndex..<r.upperBound, with: [])
        }
        
      }
      else {
        
        var range : Range<Data.Index>?
        
        var selected = 0
        
        for index in 0..<patternB.count {
          if let tempRange = buffer.range(of: patternB[index], options: [], in: buffer.startIndex..<buffer.endIndex) {
            if range == nil || tempRange.startIndex < range!.startIndex {
              range = tempRange
              selected = index + 1
            }
          }
        }
        
        switch selected {
        case 1, 2: // String Delimiter
          let subData = buffer.subdata(in: buffer.startIndex..<range!.lowerBound)
          string += String(data: subData, encoding: encoding) ?? ""
          if selected == 1 {
            string += stringDelimiter
          }
          else {
            outOfString = true
          }
        default:
          getData = true
        }
        
        if let r = range {
          buffer.replaceSubrange(buffer.startIndex..<r.upperBound, with: [])
        }
        
      }
      
      if getData {
        let tempData = fp.readData(ofLength: chunkSize)
        if tempData.count == 0 {
          break
        }
        buffer.append(tempData)
      }
      
    } while true
    
    if buffer.count > 0 {
      let contents = string == "" ? String(data: buffer, encoding: encoding)! : string
      if column == 0 {
        delegate?.csvParser(didStartRow: row)
      }
      delegate?.csvParser(foundCharacters: column, string: contents)
      delegate?.csvParser(didEndRow: row)
      column += 1
      if column > _numberOfColumns {
        _numberOfColumns = column
      }
      _numberOfRows =  row + 1
    }
    
    fp.closeFile()
    
    delegate?.csvParserDidEndDocument()
    
  }

}
