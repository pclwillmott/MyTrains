//
//  ClientConnection.swift
//  MyTrains
//
//  Created by Paul Willmott on 17/06/2023.
//

import Foundation
import Network

@available(macOS 10.14, *)
public class ClientConnection {

  // MARK: Constructors
  
  init(nwConnection: NWConnection, interface: Interface) {
    self.nwConnection = nwConnection
    self.interface = interface
  }

  // MARK: Private Properties
  
  private let nwConnection : NWConnection
  
  private let interface : Interface
  
  private let queue = DispatchQueue(label: "Client connection Q")

  // MARK: Public Properties
  
  public var didStopCallback : ((Error?) -> Void)? = nil

  // MARK: Private Methods
  
  private func stateDidChange(to state: NWConnection.State) {
    switch state {
    case .waiting(let error):
      connectionDidFail(error: error)
    case .ready:
//      print("Client connection ready")
      break
    case .failed(let error):
      connectionDidFail(error: error)
    default:
        break
    }
  }

  private func setupReceive() {
    nwConnection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { (data, _, isComplete, error) in
      if let data = data, !data.isEmpty {
        let bytes = [UInt8](data)
   //     let message = String(data: data, encoding: .utf8)
      //  print("connection did receive, data: \(data as NSData) string: \(message ?? "-" )")
        DispatchQueue.main.async {
          self.interface.addToInputBuffer(data: bytes)
        }
      }
      if isComplete {
        self.connectionDidEnd()
      } else if let error = error {
        self.connectionDidFail(error: error)
      } else {
        self.setupReceive()
      }
    }
  }

  private func connectionDidFail(error: Error) {
    print("connection did fail, error: \(error)")
    self.stop(error: error)
  }

  private func connectionDidEnd() {
    print("connection did end")
    self.stop(error: nil)
  }

  private func stop(error: Error?) {
    self.nwConnection.stateUpdateHandler = nil
    self.nwConnection.cancel()
    if let didStopCallback = self.didStopCallback {
      self.didStopCallback = nil
      didStopCallback(error)
    }
  }

  // MARK: Public Methods
  
  public func start() {
//    print("connection will start")
    nwConnection.stateUpdateHandler = stateDidChange(to:)
    setupReceive()
    nwConnection.start(queue: queue)
  }

  public func stop() {
    print("connection will stop")
    stop(error: nil)
  }

  func send(data: Data) {
    nwConnection.send(content: data, completion: .contentProcessed( { error in
      if let error = error {
        self.connectionDidFail(error: error)
        return
      }
//      print("connection did send, data: \(data as NSData)")
    }))
  }

}
