//
//  MTSerialPortManager.swift
//  MyTrains
//
//  Created by Paul Willmott on 20/05/2022.
//

import Foundation
import Cocoa

class MTSerialPortManager {
  
  public static func availablePorts() -> [String] {
    
    var result : [String] = []
    
    for i in 0...findSerialPorts()-1 {
      
      let path = String(cString: getSerialPortPath(i))
      
      result.append(path)

    }
    
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
