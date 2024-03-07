//
//  MonitorItem.swift
//  MyTrains
//
//  Created by Paul Willmott on 25/02/2024.
//

import Foundation

public enum MonitorItemDirection {
  case sent
  case received
  case notApplicable
}
public class MonitorItem : NSObject {
  
  // MARK: Constructors
  
  public override init() {
    super.init()
  }
  
  // MARK: Private Properties
  
  private var _info : String?
  
  // MARK: Public Properties
  
  public var frame : LCCCANFrame?
  
  public var direction : MonitorItemDirection = .notApplicable
  
  public var message : OpenLCBMessage?
  
  public var info : String {
    if _info == nil {
      if let frame {
        _info = "\(direction == .received ? "→" : "←") \(frame.info)"
        return _info!
     }
      if let message {
        _info = "\(message.info)"
        return _info!
      }
    }
    if let _info {
      return _info
    }
    return "????????"
  }
  
}
