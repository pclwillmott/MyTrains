//
//  MTSerialPortManager.swift
//  MyTrains
//
//  Created by Paul Willmott on 20/05/2022.
//

import Foundation
import Cocoa

public protocol MTSerialPortManagerDelegate {
  func serialPortWasAdded(path:String)
  func serialPortWasRemoved(path:String)
}

class MTSerialPortManager {
  
  // MARK: Class Private Properties
  
  private static var _lastPorts : [String] = []
  
  // MARK: Class Public Properties
  
  public static var delegate : MTSerialPortManagerDelegate?
  
  // MARK: Class Methods
  
  public static func checkPorts() {
    let _ = availablePorts()
  }
  
  public static func availablePorts() -> [String] {
    
    var result : [String] = []
    
    for i in 0...findSerialPorts()-1 {
      
      let path = String(cString: getSerialPortPath(i))
      
      result.append(path)

    }
    
    // Check for removals
    
    for last in _lastPorts {
      var found = false
      for new in result {
        if new == last {
          found = true
          break
        }
      }
      if !found {
        delegate?.serialPortWasRemoved(path: last)
      }
    }
    
    // Check for additions
    
    for new in result {
      var found = false
      for last in _lastPorts {
        if new == last {
          found = true
          break
        }
      }
      if !found {
        delegate?.serialPortWasAdded(path: new)
      }
    }
    
    _lastPorts = result
    
    clearSerialPorts()
    
    return result
    
  }
  
  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    let ports = MTSerialPortManager.availablePorts()
    for index in 0...ports.count-1 {
      comboBox.addItem(withObjectValue: ports[index])
    }
  }

}
