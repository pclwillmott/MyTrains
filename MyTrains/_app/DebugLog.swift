//
//  DebugLog.swift
//  MyTrains
//
//  Created by Paul Willmott on 16/02/2024.
//

import Foundation

#if DEBUG
public func debugLog(functionName: String = #function, fileName: String = #file, lineNumber: Int = #line, _ message:String = "") {
    let className = (fileName as NSString).lastPathComponent
    print("<\(className)> \(functionName) [#\(lineNumber)] \(message)")
}
#endif

public var instances : [String:Int] = [:]

public func addInit(fileName: String = #file) {
  
  let className = (fileName as NSString).lastPathComponent
  
  var newTotal : Int = 1
  if let total = instances[className] {
    newTotal += total
  }
  
  instances[className] = newTotal
  
}

public func addDeinit(fileName: String = #file) {
  
  let className = (fileName as NSString).lastPathComponent
  
  var newTotal : Int = -1
  if let total = instances[className] {
    newTotal += total
  }
  
  instances[className] = newTotal
  
}

public func showInstances() {
  
  var result : [(className:String, count:Int)] = []
  
  for (className, count) in instances {
    result.append((className: className, count: count))
  }
  result.sort {$0.className < $1.className}
  
  for item in result {
    print("\(item.className): \(item.count)")
  }
  
}
