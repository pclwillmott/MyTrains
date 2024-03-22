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
  
  // MARK: Constructors & Destructors
  
  public override init() {
    super.init()
    addInit()
  }
  
  deinit {
    frame = nil
    message = nil
    _info = nil
    addDeinit()
  }
  
  // MARK: Private Properties
  
  private var _info : String?
  
  // MARK: Public Properties
  
  public var frame : LCCCANFrame?
  
  public var direction : MonitorItemDirection = .notApplicable
  
  public var gatewayNumber : Int = 0
  
  public var message : OpenLCBMessage?
  
  public var info : String {
    if _info == nil {
      if let frame {
        _info = "\(gatewayNumber) \(direction == .received ? "→" : "←") \(frame.info)"
        return _info!
     }
      if let message {
        _info = "0 \(message.info)"
        return _info!
      }
    }
    if let _info {
      return _info
    }
    return "????????"
  }
  
}
