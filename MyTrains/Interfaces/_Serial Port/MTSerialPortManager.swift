//
//  MTSerialPortManager.swift
//  MyTrains
//
//  Created by Paul Willmott on 20/05/2022.
//

import Foundation
import Cocoa

@objc public protocol MTSerialPortManagerDelegate {
  @objc optional func serialPortWasAdded(path:String)
  @objc optional func serialPortWasRemoved(path:String)
}

class MTSerialPortManager : NSObject {
  
  // MARK: Class Private Properties
  
  private static var _lastPorts : [String] = []
  
  // MARK: Class Public Properties
  
  private static var observers : [Int:MTSerialPortManagerDelegate] = [:]
  
  private static var nextObserverId : Int = 0
  
  // MARK: Class Methods
  
  public static func addObserver(observer:MTSerialPortManagerDelegate) -> Int {
    let id = nextObserverId
    nextObserverId += 1
    observers[id] = observer
    return id
  }
  
  public static func removeObserver(observerId:Int) {
    observers.removeValue(forKey: observerId)
  }
  
  // This is called from a timer thread
  public static func checkPorts() {
    
    let result = availablePorts()
    
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
        DispatchQueue.main.async {
          for (_, observer) in observers {
            observer.serialPortWasRemoved?(path: last)
          }
        }
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
        DispatchQueue.main.async {
          for (_, observer) in observers {
            observer.serialPortWasAdded?(path: new)
          }
        }
      }
    }
    
    _lastPorts = result
    
  }
  
  public static func availablePorts() -> [String] {
    
    var result : [String] = []
    
//    autoreleasepool {
      for i in 0...findSerialPorts()-1 {
        let path = String(cString: getSerialPortPath(i))
        result.append(path)
      }
      clearSerialPorts()
//    }
    
    return result
    
  }
  
  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    let ports = MTSerialPortManager.availablePorts()
    for index in 0...ports.count-1 {
      comboBox.addItem(withObjectValue: ports[index])
    }
  }
  
  public static func insertMap(cdi:String) -> String {
    
    var map = "<map>\n"

    for port in availablePorts() {
      map += "<relation><property>\(port)</property><value>\(port)</value></relation>\n"
    }

    map += "</map>"

    return cdi.replacingOccurrences(of: CDI.PORTS, with: map)

  }
  
}
