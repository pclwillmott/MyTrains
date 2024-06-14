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
