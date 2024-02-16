//
//  OpenLCBCANGateway - TX.swift
//  MyTrains
//
//  Created by Paul Willmott on 16/02/2024.
//

import Foundation

extension OpenLCBCANGateway {
  
  public func send(data: [UInt8]) {
    self.serialPort?.write(data:data)
  }

  public func send(data:String) {
    for (_, observer) in observers {
      observer.rawCANPacketSent(packet: data)
    }
    self.serialPort?.write(data:[UInt8](data.utf8))
  }

  internal func send(header: String, data:String) {
    if let serialPort, serialPort.isOpen {
      let packet = ":X\(header)N\(data);"
      print("\(packet) \((aliasLookup[0x534] ?? 0).toHexDotFormat(numberOfBytes: 6))")
      send(data: packet)
    }
  }

  public func addToOutputQueue(message: OpenLCBMessage) {
    message.timeStamp = Date.timeIntervalSinceReferenceDate
    outputQueueLock.lock()
    outputQueue.append(message)
    outputQueueLock.unlock()
    processQueues()
  }

}
