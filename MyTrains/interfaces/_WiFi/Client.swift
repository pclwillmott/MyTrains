//
//  Client.swift
//  MyTrains
//
//  Created by Paul Willmott on 17/06/2023.
//

import Foundation
import Network

@available(macOS 10.14, *)
public class Client {

  // MARK: Constructors
  
  init(host: String, port: UInt16) {
    self.host = NWEndpoint.Host(host)
    self.port = NWEndpoint.Port(rawValue: port)!
//    self.interface = interface
    let nwConnection = NWConnection(host: self.host, port: self.port, using: .tcp)
//    connection = ClientConnection(nwConnection: nwConnection, interface: interface)
  }
  
  // MARK: Private Properties

  private let host : NWEndpoint.Host
  
  private let port : NWEndpoint.Port
  
//  private let interface : Interface

  // MARK: Public Properties
  
//  public let connection : ClientConnection?
  
  // MARK: Private Methods
  
  private func didStopCallback(error: Error?) {
    if error == nil {
  //    exit(EXIT_SUCCESS)
    } else {
  //    exit(EXIT_FAILURE)
    }
  }
  
  // MARK: Public Methods
  
  public func start() {
//    print("Client started \(host) \(port)")
 //   connection!.didStopCallback = didStopCallback(error:)
//    connection!.start()
  }

  public func stop() {
//    connection!.stop()
  }

  public func send(data: Data) {
//    connection!.send(data: data)
  }

}
