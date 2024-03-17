//
//  OpenLCBDatagramTimeout.swift
//  MyTrains
//
//  Created by Paul Willmott on 02/07/2023.
//

import Foundation

public enum OpenLCBDatagramTimeout : UInt8 {
  
  case ok                    = 0x00
  case replyPendingNoTimeout = 0x80
  case replyPending2s        = 0x81
  case replyPending4s        = 0x82
  case replyPending8s        = 0x83
  case replyPending16s       = 0x84
  case replyPending32s       = 0x85
  case replyPending64s       = 0x86
  case replyPending128s      = 0x87
  case replyPending256s      = 0x88
  case replyPending512s      = 0x89
  case replyPending1024s     = 0x8a
  case replyPending2048s     = 0x8b
  case replyPending4096s     = 0x8c
  case replyPending8192s     = 0x8d
  case replyPending16384s    = 0x8e
  case replyPending32768s    = 0x8f
 
  // MARK: Public Properties
  
  public var replyPending : Bool {
    return self != .ok
  }
  
  public var timeout : TimeInterval? {
    
    let timeouts : [OpenLCBDatagramTimeout:TimeInterval] = [
      .replyPending2s        : 2.0,
      .replyPending4s        : 4.0,
      .replyPending8s        : 8.0,
      .replyPending16s       : 16.0,
      .replyPending32s       : 32.0,
      .replyPending64s       : 64.0,
      .replyPending128s      : 128.0,
      .replyPending256s      : 256.0,
      .replyPending512s      : 512.0,
      .replyPending1024s     : 1024.0,
      .replyPending2048s     : 2048.0,
      .replyPending4096s     : 4096.0,
      .replyPending8192s     : 8192.0,
      .replyPending16384s    : 16384.0,
      .replyPending32768s    : 32768.0,
    ]
    
    return timeouts[self]

  }
  
}
