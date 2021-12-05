//
//  NetworkController.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/11/2021.
//

import Foundation

public class NetworkController {
  
  init() {
  
    let connections = [ //"/dev/cu.usbmodemDxP431751"
                    //  "/dev/cu.usbmodemDxP470881"
                       "/dev/cu.usbmodemDtrxA0BA1"
    ]
    
    var index : Int = 1
    
    for connection in connections {
      let networkMessenger = NetworkMessenger(id: "id\(index)", path: connection)
      networkMessengers[networkMessenger.id] = networkMessenger
      index += 1
    }
    
    if let interface1 = networkMessengers["id1"] {
      add(locomotive: Locomotive(locomotiveId: "Class 25",  address: 10, interface: interface1))
      add(locomotive: Locomotive(locomotiveId: "Class 121", address: 11, interface: interface1))
      add(locomotive: Locomotive(locomotiveId: "Class 128", address: 12, interface: interface1))
     }
    
    
    
  }
  
  public var networkMessengers : [String:NetworkMessenger] = [:]
  
  private var locomotivesByName    : [String:Locomotive] = [:]
  private var locomotivesByAddress : [UInt16:Locomotive] = [:]

  public func add(locomotive:Locomotive) {
    locomotivesByName[locomotive.locomotiveId] = locomotive
    locomotivesByAddress[locomotive.address] = locomotive
  }
  
}
