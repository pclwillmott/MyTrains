//
//  OpenLCBCANGatewayWiFi.swift
//  MyTrains
//
//  Created by Paul Willmott on 16/12/2023.
//

import Foundation
public class OpenLCBCANGatewayWiFi : OpenLCBCANGateway {
  
  // MARK: Private Properties
    
  internal var client : Client?
  
  // MARK: Public Properties
/*
  public override var isConnected : Bool {
    get {
      return client != nil
    }
  }
  
  public override var isOpen : Bool {
    return isPortOpen
  }

  public var isPortOpen = false

  // MARK: Private Methods
  
  // MARK: Public Methods
      
  public override func open() {
    
    let server = "10.0.0.1"
    let port : UInt16 = 12021
    
    client = Client(host: server, port: port, interface: self)
    client?.start()
    
    isPortOpen = true

    for (_, observer) in observers {
      DispatchQueue.main.async {
        observer.interfaceWasOpened?(interface: self)
      }
    }

  }
  
  public override func close() {
    
    client?.stop()
    
    isPortOpen = false
    
    for (_, observer) in observers {
      DispatchQueue.main.async {
        observer.interfaceWasClosed?(interface: self)
      }
    }
    
  }
  
  public override func send(data: [UInt8]) {
    DispatchQueue.main.async {
      self.client?.connection.send(data: Data(data))
    }
  }

  public override func send(data:String) {
    DispatchQueue.main.async {
      self.client?.connection.send(data: data.data(using: .utf8)!)
    }
  }
*/
}


