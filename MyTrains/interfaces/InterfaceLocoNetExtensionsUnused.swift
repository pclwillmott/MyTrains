//
//  InterfaceLocoNetExtensionsUnused.swift
//  MyTrains
//
//  Created by Paul Willmott on 22/06/2023.
//

import Foundation

extension InterfaceLocoNet {
  
  // MARK: Public Methods
  
  public func getBrdOpSwState(device:LocoNetDevice, switchNumber:Int) {
    
    let boardType : [DeviceId:UInt8] = [
      .PM4 : 0,
      .PM42 : 0,
      .BDL16 : 1,
      .BDL162 : 1,
      .BDL168 : 1,
      .SE8C : 2,
      .DS64 : 3,
    ]
    
    if let bType = boardType[device.locoNetProductId] {

      let id : UInt8 = UInt8((device.boardId - 1) & 0xff)
    
      let high = 0b01100010 | (id >> 7)
      
      let low = id & 0x7f
      
      let bt = 0b01110000 | bType
      
      let opsw = UInt8(((switchNumber-1) << 1) & 0x7f)
      
      let message = LocoNetMessage(networkId: networkId, data: [LocoNetMessageOpcode.OPC_D0_GROUP.rawValue, high, low, bt, opsw], appendCheckSum: true)
      
      addToQueue(message: message, delay: MessageTiming.STANDARD)

    }

  }

  public func setBrdOpSwState(device:LocoNetDevice, switchNumber:Int, state:OptionSwitchState) {
    
    let boardType : [DeviceId:UInt8] = [
      .PM4 : 0,
      .PM42 : 0,
      .BDL16 : 1,
      .BDL162 : 1,
      .BDL168 : 1,
      .SE8C : 2,
      .DS64 : 3,
    ]
    
    if let bType = boardType[device.locoNetProductId] {

      let id : UInt8 = UInt8((device.boardId - 1) & 0xff)
    
      let high = 0b01110010 | (id >> 7)
      
      let low = id & 0x7f
      
      let bt = 0b01110000 | bType
      
      let opsw = UInt8((switchNumber-1) << 1) | (state == .closed ? 1 : 0)
      
      let message = LocoNetMessage(networkId: networkId, data: [LocoNetMessageOpcode.OPC_D0_GROUP.rawValue, high, low, bt, opsw], appendCheckSum: true)
      
      addToQueue(message: message, delay: MessageTiming.STANDARD)

    }

  }

  public func s7CVRW(boardId: Int, cvNumber:Int, isRead:Bool, value:UInt8) {
    
    let cv = UInt8((cvNumber - 1) & 0xff)
    
    let val = isRead ? 0 : value
    
    let high = (0b00000111) | ((cv & 0x80) >> 4) | ((val & 0x80) >> 3)
    
    let b = boardId - 1
    
    let c = b % 4
    
    let d = b / 4
    
    let e = d % 64
    
    let addA = UInt8(e)
    
    let g = d / 64
    
    let h = 7 - g
    
    let i = h * 16 + c * 2 + 8
    
    let addB = UInt8(i)
    
    let mode : UInt8 = 0b01100100 | (isRead ? 0 : 0b1000)
    
    let message = LocoNetMessage(networkId: networkId, data: [LocoNetMessageOpcode.OPC_IMM_PACKET.rawValue, 0x0b, 0x7f, 0x54, high, addA, addB, mode, cv & 0x7f, val & 0x7f], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)

  }

  private func s7CVRW(device:LocoNetDevice, cvNumber:Int, isRead:Bool, value:UInt8) {
    
    let cv = UInt8((cvNumber - 1) & 0xff)
    
    let val = isRead ? 0 : value
    
    let high = (0b00000111) | ((cv & 0x80) >> 4) | ((val & 0x80) >> 3)
    
    let b = device.boardId - 1
    
    let c = b % 4
    
    let d = b / 4
    
    let e = d % 64
    
    let addA = UInt8(e)
    
    let g = d / 64
    
    let h = 7 - g
    
    let i = h * 16 + c * 2 + 8
    
    let addB = UInt8(i)
    
    let mode : UInt8 = 0b01100100 | (isRead ? 0 : 0b1000)
    
    let message = LocoNetMessage(networkId: networkId, data: [LocoNetMessageOpcode.OPC_IMM_PACKET.rawValue, 0x0b, 0x7f, 0x54, high, addA, addB, mode, cv & 0x7f, val & 0x7f], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)

  }

  public func setS7BaseAddr(device:LocoNetDevice) {
    
    if let info = device.locoNetProductInfo {
      
      let pc : UInt8 = UInt8(info.productCode.rawValue)
      
      let lowSN = UInt8(device.serialNumber & 0x7f)
      
      let highSN = UInt8(device.serialNumber >> 7)
      
      let lowAddr = UInt8(device.baseAddress & 0x7f)
      
      let highAddr = UInt8(device.baseAddress >> 7)
      
     let message = LocoNetMessage(networkId: networkId, data: [LocoNetMessageOpcode.OPC_WR_SL_DATA_P2.rawValue, 0x10, 0x02, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, pc, 0x00, lowSN, highSN, lowAddr, highAddr], appendCheckSum: true)
    
     addToQueue(message: message, delay: MessageTiming.STANDARD)
      
    }
    
  }
  public func getS7CV(device:LocoNetDevice, cvNumber:Int) {
    s7CVRW(device: device, cvNumber: cvNumber, isRead: true, value: 0)
  }

  public func setS7CV(device:LocoNetDevice, cvNumber:Int, value:UInt8) {
    s7CVRW(device: device, cvNumber: cvNumber, isRead: false, value: value)
  }

  public func getOpSwDataBP1() {
    
    let message = LocoNetMessage(networkId: networkId, data: [LocoNetMessageOpcode.OPC_RQ_SL_DATA.rawValue, 0x7e, 0x00], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)

  }
  
  public func getOpSwDataP2() {
    
    let message = LocoNetMessage(networkId: networkId, data: [LocoNetMessageOpcode.OPC_RQ_SL_DATA.rawValue, 0x7f, 0x40], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)

  }
  
  public func getProgSlotDataP1(timeoutCode: TimeoutCode) {
    
    let message = LocoNetMessage(networkId: networkId, data: [LocoNetMessageOpcode.OPC_RQ_SL_DATA.rawValue, 0x7c, 0x00], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.CVOP, responses: [.progSlotDataP1], retryCount: 10, timeoutCode: timeoutCode)

  }
  
  public func getLocoSlotDataP1(slotNumber: UInt8) {
    
    let message = LocoNetMessage(networkId: networkId, data: [LocoNetMessageOpcode.OPC_RQ_SL_DATA.rawValue, slotNumber, 0x00], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)

  }
  
  public func getLocoSlotDataP2(slotPage: UInt8, slotNumber: UInt8) {
    
    let message = LocoNetMessage(networkId: networkId, data: [LocoNetMessageOpcode.OPC_RQ_SL_DATA.rawValue, slotNumber, slotPage | 0b01000000], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)

  }
  
  public func testIMM(address: Int) {
    
    let add = address - 1
    
    var adr1 = ((add & 0b11) << 1) | 0b10001000
    
    adr1 |= ((~(add >> 8) & 0x07) << 4)
    
    let payload : [UInt8] = [
      UInt8(((add >> 2) & 0b00111111) | 0b10000000),
      UInt8(adr1),
    ]
    
    immPacket(packet: payload, repeatCount: 2)
    
  }

  public func setSwIMM(address: Int, state:TurnoutSwitchState, isOutputOn:Bool) {
    
    let add = address - 1
    
    var adr1 = ((add & 0b11) << 1) | 0b10000000
    
    adr1 |= ((state == .closed) ? 1 : 0)
    
    adr1 |= (isOutputOn ? 0b1000 : 0)
    
    adr1 |= ((~(add >> 8) & 0x07) << 4)
    
    let payload : [UInt8] = [
      UInt8((((add >> 2) + 1) & 0b00111111) | 0b10000000),
      UInt8(adr1),
    ]
    
    immPacket(packet: payload, repeatCount: 2)
    
  }
  
  public func getQuerySlot(querySlot: Int) {
    
    guard querySlot > 0 && querySlot <= 5 else {
      return
    }
    
    let slotPage = 1
    let slotNumber = 0x78 + querySlot - 1
    
    let message = LocoNetMessage(networkId: networkId, data: [LocoNetMessageOpcode.OPC_RQ_SL_DATA.rawValue, UInt8(slotNumber), UInt8(slotPage) | 0b01000000], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)

  }
  
  public func getRouteTableInfoA() {
    
    let message = LocoNetMessage(networkId: networkId, data: [LocoNetMessageOpcode.OPC_WR_SL_DATA_P2.rawValue,
    0x10, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD, responses: [], retryCount: 0, timeoutCode: .none)
    
  }

  public func getRouteTablePage(routeNumber: Int, pageNumber: Int, pagesPerRoute: Int ) {
    
    let shift = pagesPerRoute / 2
    
    let combined : Int = pageNumber | (routeNumber - 1) << shift
    
    let pageL = UInt8(combined & 0x7f)
    let pageH = UInt8(combined >> 7)
    
    let message = LocoNetMessage(networkId: networkId, data: [LocoNetMessageOpcode.OPC_WR_SL_DATA_P2.rawValue,
    0x10, 0x01, 0x02, pageL, pageH, 0x0f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD, responses: [], retryCount: 0, timeoutCode: .none)
    
  }

  public func setRouteTablePages(routeNumber: Int, route: [SwitchRoute], pagesPerRoute: Int ) {
    
    let shift = pagesPerRoute / 2
    
    for pageNumber in 0...pagesPerRoute - 1 {
      
      let combined : Int = pageNumber | (routeNumber - 1) << shift
      
      let pageL = UInt8(combined & 0x7f)
      let pageH = UInt8(combined >> 7)
      
      var data : [UInt8] = [LocoNetMessageOpcode.OPC_WR_SL_DATA_P2.rawValue,
                            0x10, 0x01, 0x03, pageL, pageH, 0x0f]
      
      for entryNumber in (pageNumber * 4)...(pageNumber * 4 + 3) {
        let switchNumber = route[entryNumber].switchNumber - 1
        var part1 = switchNumber & 0x7f
        let mask = route[entryNumber].switchState == .closed ? 0b100000 : 0
        var part2 = (switchNumber >> 7) | 0b10000 | mask
        if route[entryNumber].switchNumber == 0x7f && route[entryNumber].switchState == .unknown {
          part1 = 0x7f
          part2 = 0x7f
        }
        data.append(UInt8(part1))
        data.append(UInt8(part2))
      }
      
      let message = LocoNetMessage(networkId: networkId, data: data, appendCheckSum: true)
      
      addToQueue(message: message, delay: MessageTiming.STANDARD, responses: [], retryCount: 0, timeoutCode: .none)
      
    }
    
  }

  public func getRosterEntry(recordNumber: Int) {
    
    let recNum : UInt8 = UInt8(recordNumber & 0x1f)
    
    let message = LocoNetMessage(networkId: networkId, data: [LocoNetMessageOpcode.OPC_WR_SL_DATA_P2.rawValue,
    0x10, 0x00, 0x02, recNum, 0x00, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD, responses: [], retryCount: 0, timeoutCode: .none)
    
  }
  
  public func setRosterEntry(entryNumber:Int, extendedAddress1:Int, primaryAddress1:Int,extendedAddress2:Int, primaryAddress2:Int) {
    
    let low1 = UInt8(extendedAddress1 & 0x7f)
    let high1 = UInt8(extendedAddress1 >> 7)
    let primary1 = UInt8(primaryAddress1)

    let low2 = UInt8(extendedAddress2 & 0x7f)
    let high2 = UInt8(extendedAddress2 >> 7)
    let primary2 = UInt8(primaryAddress2)
    
    let flag : UInt8 = (entryNumber & 0x01) == 0x01 ? 0x04 : 0x00

    let message = LocoNetMessage(networkId: networkId, data: [LocoNetMessageOpcode.OPC_WR_SL_DATA_P2.rawValue,
    0x10, 0x00, 0x43, UInt8(entryNumber >> 1), 0x00, flag, low1, high1, primary1, 0x00, low2, high2, primary2, 0x00], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD, responses: [], retryCount: 0, timeoutCode: .none)
    
  }
  
  public func getSwState(switchNumber: Int) {
    
    let lo = UInt8((switchNumber - 1) & 0x7f)
    
    let hi = UInt8((switchNumber - 1) >> 7)
    
    let message = LocoNetMessage(networkId: networkId, data: [LocoNetMessageOpcode.OPC_SW_STATE.rawValue, lo, hi], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD, responses: [], retryCount: 0, timeoutCode: .none)

  }
  
  public func setSw(switchNumber: Int, state:OptionSwitchState) {
    
    let sn = switchNumber - 1
    
    let lo = UInt8(sn & 0x7f)
    
    let bit : UInt8 = state == .closed ? 0x30 : 0x10
    
    let hi = UInt8(sn >> 7) | bit
    
    let message = LocoNetMessage(networkId: networkId, data: [LocoNetMessageOpcode.OPC_SW_REQ.rawValue, lo, hi], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.SWREQ)

  }
  
  public func setSwWithAck(switchNumber: Int, state:OptionSwitchState) {
    
    let sn = switchNumber - 1
    
    let lo = UInt8(sn & 0x7f)
    
    let bit : UInt8 = state == .closed ? 0x30 : 0x10
    
    let hi = UInt8(sn >> 7) | bit
    
    let message = LocoNetMessage(networkId: networkId, data: [LocoNetMessageOpcode.OPC_SW_ACK.rawValue, lo, hi], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.SWREQ)

  }

  public func setOpSwDataAP1(state:Bool) {
    
    var data = [UInt8](repeating: 0, count: 13)
    
    data[0] = LocoNetMessageOpcode.OPC_WR_SL_DATA.rawValue
    data[1] = 14
    data[2] = 0x7f
    
    for byte in 3...13 {
      data[byte] = state ? 0x7f : 0x00
    }
    
    let message = LocoNetMessage(networkId: networkId, data: data, appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD, responses: [], retryCount: 0, timeoutCode: .none)

  }

  public func setOpSwDataBP1(state:Bool) {
    
    var data = [UInt8](repeating: 0, count: 13)
    
    data[0] = LocoNetMessageOpcode.OPC_WR_SL_DATA.rawValue
    data[1] = 14
    data[2] = 0x7e
    
    for byte in 3...13 {
      data[byte] = state ? 0x7f : 0x00
    }
    
    let message = LocoNetMessage(networkId: networkId, data: data, appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD, responses: [], retryCount: 0, timeoutCode: .none)

  }

  public func setLocoSlotDataP1(slotData: [UInt8]) {
    
    var data = [UInt8](repeating: 0, count: 13)
    
    data[0] = LocoNetMessageOpcode.OPC_WR_SL_DATA.rawValue
    data[1] = 14
    
    for index in 0...slotData.count-1 {
      data[index + 2] = slotData[index]
    }
    
    let message = LocoNetMessage(networkId: networkId, data: data, appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD, responses: [], retryCount: 0, timeoutCode: .none)

  }
  
  public func setLocoSlotDataP2(slotData: [UInt8], timeoutCode: TimeoutCode) {
    
    var data = [UInt8](repeating: 0, count: 20)
    
    data[0] = LocoNetMessageOpcode.OPC_WR_SL_DATA_P2.rawValue
    data[1] = 21
    
    for index in 0...slotData.count-1 {
      data[index + 2] = slotData[index]
    }
    
    let message = LocoNetMessage(networkId: networkId, data: data, appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD, responses: [], retryCount: 0, timeoutCode: timeoutCode)

  }
  
  public func resetQuerySlot4(timeoutCode: TimeoutCode) {
    let slotPage = 0x19
    let slotNumber = 0x7b
    let message = LocoNetMessage(networkId: networkId, data: [LocoNetMessageOpcode.OPC_WR_SL_DATA_P2.rawValue, 0x15, UInt8(slotPage), UInt8(slotNumber), 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD, responses: [.setSlotDataOKP2], retryCount: 10, timeoutCode: timeoutCode)
  }

  public func clearLocoSlotDataP1(slotNumber:Int, timeoutCode: TimeoutCode) {
    
    let message = LocoNetMessage(networkId: networkId, data: [LocoNetMessageOpcode.OPC_WR_SL_DATA.rawValue, 0x0e, UInt8(slotNumber), 0b00000011, 0x00, 0x00, 0b00100000, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD, responses: [.setSlotDataOKP1], retryCount: 10, timeoutCode: timeoutCode)

  }
  
  public func clearLocoSlotDataP2(slotPage: Int, slotNumber:Int, timeoutCode: TimeoutCode) {
    
    let message = LocoNetMessage(networkId: networkId, data: [LocoNetMessageOpcode.OPC_WR_SL_DATA_P2.rawValue, 0x15, UInt8(slotPage), UInt8(slotNumber), 0b00000011, 0x00, 0x00, 0x00, 0x00, 0x00, 0b00100000, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD, responses: [.setSlotDataOKP2], retryCount: 10, timeoutCode: timeoutCode)

  }
  
  public func getInterfaceData(timeoutCode: TimeoutCode) {
    
    let message = LocoNetMessage(networkId: networkId, data: [LocoNetMessageOpcode.OPC_BUSY.rawValue], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD, responses: [.interfaceData], retryCount: 10, timeoutCode: timeoutCode)
    
  }
  
  public func findReceiver() {
    
    let message = LocoNetMessage(networkId: networkId, data:
      [LocoNetMessageOpcode.OPC_DF_GROUP.rawValue,
       0x00, 0x00, 0x00, 0x00
    ], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)
    
  }
  
  public func setLocoNetID(locoNetID: Int) {
    
    let lid : UInt8 = UInt8(locoNetID & 0x7)
    
    let message = LocoNetMessage(networkId: networkId, data:
      [LocoNetMessageOpcode.OPC_DF_GROUP.rawValue,
       0x40, 0x1f, lid, 0x00
    ], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)
    
  }
  
  public func getDuplexData() {
    
    let message = LocoNetMessage(networkId: networkId, data:
      [LocoNetMessageOpcode.OPC_PEER_XFER.rawValue,
       0x14, 0x03, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    ], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)
    
  }
  
  public func setDuplexChannelNumber(channelNumber: Int) {
    
    let cn = UInt8(channelNumber)
    
    let pxct1 : UInt8 = (cn & 0b10000000) == 0b10000000 ? 0b00000001 : 0
    
    let message = LocoNetMessage(networkId: networkId, data:
      [LocoNetMessageOpcode.OPC_PEER_XFER.rawValue,
       0x14, 0x02, 0x00, pxct1, cn, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    ], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)
    
  }
  
  public func setDuplexGroupID(groupID: Int) {
    
    let gid = UInt8(groupID)
    
    let pxct1 : UInt8 = (gid & 0b10000000) == 0b10000000 ? 0b00000001 : 0
    
    let message = LocoNetMessage(networkId: networkId, data:
      [LocoNetMessageOpcode.OPC_PEER_XFER.rawValue,
       0x14, 0x04, 0x00, pxct1, gid, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    ], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)
    
  }
  
  public func getDuplexGroupID() {
    
    let message = LocoNetMessage(networkId: networkId, data:
      [LocoNetMessageOpcode.OPC_PEER_XFER.rawValue,
       0x14, 0x04, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    ], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)
    
  }
  
  public func getDuplexSignalStrength(duplexGroupChannel: Int) {
    
    let message = LocoNetMessage(networkId: networkId, data:
      [LocoNetMessageOpcode.OPC_PEER_XFER.rawValue,
       0x14, 0x10, 0x08, 0x00, UInt8(duplexGroupChannel & 0x7f), 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    ], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)
    
  }
  
  public func setDuplexSignalStrength(duplexGroupChannel: Int, signalStrength:Int) {
    
    var pxct1 : UInt8 = 0
    pxct1 |= ((duplexGroupChannel & 0b10000000) == 0b10000000) ? 0b00000001 : 0
    pxct1 |= ((signalStrength     & 0b10000000) == 0b10000000) ? 0b00000010 : 0

    let message = LocoNetMessage(networkId: networkId, data:
      [LocoNetMessageOpcode.OPC_PEER_XFER.rawValue,
       0x14, 0x10, 0x10, pxct1, UInt8(duplexGroupChannel & 0x7f), UInt8(signalStrength & 0x7f), 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    ], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)
    
  }
  public func setDuplexGroupName(groupName: String) {
    
    let data = String((groupName + "        ").prefix(8)).data(using: .ascii)!
    
    var pxct1 : UInt8 = 0
    
    pxct1 |= (data[0] & 0b10000000) == 0b10000000 ? 0b00000001 : 0
    pxct1 |= (data[1] & 0b10000000) == 0b10000000 ? 0b00000010 : 0
    pxct1 |= (data[2] & 0b10000000) == 0b10000000 ? 0b00000100 : 0
    pxct1 |= (data[3] & 0b10000000) == 0b10000000 ? 0b00001000 : 0

    var pxct2 : UInt8 = 0
    
    pxct2 |= (data[4] & 0b10000000) == 0b10000000 ? 0b00000001 : 0
    pxct2 |= (data[5] & 0b10000000) == 0b10000000 ? 0b00000010 : 0
    pxct2 |= (data[6] & 0b10000000) == 0b10000000 ? 0b00000100 : 0
    pxct2 |= (data[7] & 0b10000000) == 0b10000000 ? 0b00001000 : 0
    
    let message = LocoNetMessage(networkId: networkId, data:
      [LocoNetMessageOpcode.OPC_PEER_XFER.rawValue,
       0x14, 0x03, 0x00, pxct1, data[0], data[1], data[2], data[3], pxct2, data[4], data[5], data[6], data[7], 0x00, 0x00, 0x00, 0x00, 0x00
    ], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)
    
  }
  
  public func setDuplexPassword(password: String) {
    
    let data = String((password + "0000").prefix(4)).data(using: .ascii)!
    
    var pxct1 : UInt8 = 0
    
    pxct1 |= (data[0] & 0b10000000) == 0b10000000 ? 0b00000001 : 0
    pxct1 |= (data[1] & 0b10000000) == 0b10000000 ? 0b00000010 : 0
    pxct1 |= (data[2] & 0b10000000) == 0b10000000 ? 0b00000100 : 0
    pxct1 |= (data[3] & 0b10000000) == 0b10000000 ? 0b00001000 : 0

    let message = LocoNetMessage(networkId: networkId, data:
      [LocoNetMessageOpcode.OPC_PEER_XFER.rawValue,
       0x14, 0x07, 0x00, pxct1, data[0] & 0x7f, data[1] & 0x7f, data[2] & 0x7f, data[3] & 0x7f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    ], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)
    
  }
  
  public func setProgMode(mode: ProgrammerMode) {
    
    var prMode = UInt8(mode.rawValue)
    
    if mode == .MS100 && (locoNetProductId == .PR3 || locoNetProductId == .PR3XTRA) && isStandAloneLoconet {
      prMode |= 0b10
    }
    
    let message = LocoNetMessage(networkId: networkId, data: [LocoNetMessageOpcode.OPC_PR_MODE.rawValue, 0x10, prMode, 0x00, 0x00], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.PRMODE)

  }
  
  public func readCV(progMode:LocoNetProgrammingMode, cv:Int, address: UInt16) {
    
    var pcmd : UInt8 = progMode.readCommand
    
    var hopsa : UInt8 = 0
    var lopsa : UInt8 = 0
    
    if progMode.isOperationsMode {
      lopsa = UInt8(address & 0x7f)
      hopsa = UInt8(address >> 7)
    }
    
    let cvAdjusted = cv - 1
    
    let cvh : Int = ((cvAdjusted & 0b0000001000000000) == 0b0000001000000000 ? 0b00100000 : 0x00) |
                    ((cvAdjusted & 0b0000000100000000) == 0b0000000100000000 ? 0b00010000 : 0x00) |
                    ((cvAdjusted & 0b0000000010000000) == 0b0000000010000000 ? 0b00000001 : 0x00)

    let message = LocoNetMessage(networkId: networkId, data:
        [
          LocoNetMessageOpcode.OPC_WR_SL_DATA.rawValue,
          0x0e,
          0x7c,
          pcmd,
          0x00,
          hopsa, // HOPSA
          lopsa, // LOPSA
          0x00,
          UInt8(cvh & 0x7f),
          UInt8(cvAdjusted & 0x7f),
          0x00,
          0x00,
          0x00
        ],
        appendCheckSum: true)
    
    let timing = MessageTiming.STANDARD
    
    addToQueue(message: message, delay: timing, responses: [], retryCount: 0, timeoutCode: .none)
    
  }
  
  
  public func writeCV(progMode: LocoNetProgrammingMode, cv:Int, address: Int, value: UInt16) {
    
    var pcmd : UInt8 = progMode.writeCommand
    
    var hopsa : UInt8 = 0
    var lopsa : UInt8 = 0
    
    if progMode.isOperationsMode {
      lopsa = UInt8(address & 0x7f)
      hopsa = UInt8(address >> 7)
    }
    
    let cvAdjusted = cv - 1
    
    let cvh : Int = ((cvAdjusted & 0b0000001000000000) == 0b0000001000000000 ? 0b00100000 : 0x00) |
                    ((cvAdjusted & 0b0000000100000000) == 0b0000000100000000 ? 0b00010000 : 0x00) |
                    ((cvAdjusted & 0b0000000010000000) == 0b0000000010000000 ? 0b00000001 : 0x00) |
                    ((value & 0b10000000) == 0b10000000 ? 0b00000010 : 0x00)

    let message = LocoNetMessage(networkId: networkId, data:
        [
          LocoNetMessageOpcode.OPC_WR_SL_DATA.rawValue,
          0x0e,
          0x7c,
          pcmd,
          0x00,
          hopsa,
          lopsa,
          0x00,
          UInt8(cvh & 0x7f),
          UInt8(cvAdjusted & 0x7f),
          UInt8(value & 0x7f),
          0x7f,
          0x7f
        ],
        appendCheckSum: true)

    let timing = MessageTiming.STANDARD

    addToQueue(message: message, delay: timing, responses: [], retryCount: 0, timeoutCode: .none)
    
  }
  
  public func locoDirF0F4P2(slotNumber: Int, slotPage: Int, direction:LocomotiveDirection, functions: UInt64) {
    
    let slot = UInt8(slotNumber & 0x7f)
    
    let page = 0b00100000 | UInt8(slotPage & 0x07)
    
    var dirf : UInt8 = 0
    
    dirf |= direction == .reverse        ? 0b00100000 : 0b00000000
    dirf |= functions & maskF0 == maskF0 ? 0b00010000 : 0b00000000
    dirf |= functions & maskF1 == maskF1 ? 0b00000001 : 0b00000000
    dirf |= functions & maskF2 == maskF2 ? 0b00000010 : 0b00000000
    dirf |= functions & maskF3 == maskF3 ? 0b00000100 : 0b00000000
    dirf |= functions & maskF4 == maskF4 ? 0b00001000 : 0b00000000
    
    let message = LocoNetMessage(networkId: networkId, data: [LocoNetMessageOpcode.OPC_D4_GROUP.rawValue, page, slot, 0x06, dirf], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)
    
  }
  
  public func locoF5F11P2(slotNumber: Int, slotPage: Int, functions: UInt64) {
    
    let slot = UInt8(slotNumber & 0x7f)
    
    let page = 0b00100000 | UInt8(slotPage & 0x07)
    
    var dirf : UInt8 = 0
    
    dirf |= functions & maskF5  == maskF5  ? 0b00000001 : 0b00000000
    dirf |= functions & maskF6  == maskF6  ? 0b00000010 : 0b00000000
    dirf |= functions & maskF7  == maskF7  ? 0b00000100 : 0b00000000
    dirf |= functions & maskF8  == maskF8  ? 0b00001000 : 0b00000000
    dirf |= functions & maskF9  == maskF9  ? 0b00010000 : 0b00000000
    dirf |= functions & maskF10 == maskF10 ? 0b00100000 : 0b00000000
    dirf |= functions & maskF11 == maskF11 ? 0b01000000 : 0b00000000

    let message = LocoNetMessage(networkId: networkId, data: [LocoNetMessageOpcode.OPC_D4_GROUP.rawValue, page, slot, 0x07, dirf], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)
    
  }
  
  public func locoF12F20F28P2(slotNumber: Int, slotPage: Int, functions: UInt64) {
    
    let slot = UInt8(slotNumber & 0x7f)
    
    let page = 0b00100000 | UInt8(slotPage & 0x07)
    
    var dirf : UInt8 = 0
    
    dirf |= functions & maskF12 == maskF12  ? 0b00000001 : 0b00000000
    dirf |= functions & maskF20 == maskF20  ? 0b00000010 : 0b00000000
    dirf |= functions & maskF28 == maskF28  ? 0b00000100 : 0b00000000
 
    let message = LocoNetMessage(networkId: networkId, data: [LocoNetMessageOpcode.OPC_D4_GROUP.rawValue, page, slot, 0x05, dirf], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)
    
  }
  
  public func locoF13F19P2(slotNumber: Int, slotPage: Int, functions: UInt64) {
    
    let slot = UInt8(slotNumber & 0x7f)
    
    let page = 0b00100000 | UInt8(slotPage & 0x07)
    
    var dirf : UInt8 = 0
    
    dirf |= functions & maskF13 == maskF13 ? 0b00000001 : 0b00000000
    dirf |= functions & maskF14 == maskF14 ? 0b00000010 : 0b00000000
    dirf |= functions & maskF15 == maskF15 ? 0b00000100 : 0b00000000
    dirf |= functions & maskF16 == maskF16 ? 0b00001000 : 0b00000000
    dirf |= functions & maskF17 == maskF17 ? 0b00010000 : 0b00000000
    dirf |= functions & maskF18 == maskF18 ? 0b00100000 : 0b00000000
    dirf |= functions & maskF19 == maskF19 ? 0b01000000 : 0b00000000

    let message = LocoNetMessage(networkId: networkId, data: [LocoNetMessageOpcode.OPC_D4_GROUP.rawValue, page, slot, 0x08, dirf], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)
    
  }

  public func locoF21F27P2(slotNumber: Int, slotPage: Int, functions: UInt64) {
    
    let slot = UInt8(slotNumber & 0x7f)
    
    let page = 0b00100000 | UInt8(slotPage & 0x07)
    
    var dirf : UInt8 = 0
    
    dirf |= functions & maskF21 == maskF21 ? 0b00000001 : 0b00000000
    dirf |= functions & maskF22 == maskF22 ? 0b00000010 : 0b00000000
    dirf |= functions & maskF23 == maskF23 ? 0b00000100 : 0b00000000
    dirf |= functions & maskF24 == maskF24 ? 0b00001000 : 0b00000000
    dirf |= functions & maskF25 == maskF25 ? 0b00010000 : 0b00000000
    dirf |= functions & maskF26 == maskF26 ? 0b00100000 : 0b00000000
    dirf |= functions & maskF27 == maskF27 ? 0b01000000 : 0b00000000

    let message = LocoNetMessage(networkId: networkId, data: [LocoNetMessageOpcode.OPC_D4_GROUP.rawValue, page, slot, 0x09, dirf], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)
    
  }
  
  public func locoSpdP2(slotNumber: Int, slotPage: Int, speed: UInt8) {
    
    let slot = UInt8(slotNumber & 0x7f)
    
    let page = UInt8(slotPage & 0x07) | 0b00100000
    
    let spd = speed & 0x7f
    
    let message = LocoNetMessage(networkId: networkId, data: [LocoNetMessageOpcode.OPC_D4_GROUP.rawValue, page, slot, 0x04, spd], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)

  }
  
  public func iplDiscover() {
    
    let message = LocoNetMessage(networkId: networkId, data: [LocoNetMessageOpcode.OPC_PEER_XFER.rawValue,
       0x14, 0x0f, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.DISCOVER)

  }
  
  /*
  public func readCV(progMode: ProgrammingMode, cv:Int, address: Int) {
    DispatchQueue.main.async {
      self._programmer?.readCV(progMode: progMode, cv: cv, address: address, timeoutCode: .readCV)
    }
  }
    
  public func writeCV(progMode: ProgrammingMode, cv:Int, address: Int, value:Int) {
    DispatchQueue.main.async {
      self._programmer?.writeCV(progMode: progMode, cv: cv, address: address, value: value, timeoutCode: .writeCV)
    }
  }
  */
  public func enterProgMode(needToSetPRMode: Bool) {
    if needToSetPRMode {
      setProgMode(mode: .ProgrammerMode)
    }
  }
  
  public func exitProgMode(needToSetPRMode: Bool) {
    if needToSetPRMode {
      setProgMode(mode: .MS100)
    }
  }
  
  public func getProgSlotDataP1() {
    DispatchQueue.main.async {
 //     self._programmer?.getProgSlotDataP1()
    }
  }

  public func getFastClock() {
    
    let data : [UInt8] =
    [
      LocoNetMessageOpcode.OPC_RQ_SL_DATA.rawValue,
      0x7b,
      0x00,
    ]
    
    let message = LocoNetMessage(networkId: networkId, data: data, appendCheckSum: true)

    addToQueue(message: message, delay: MessageTiming.FAST)

  }
  
  public func setFastClock(date:Date, scaleFactor:FastClockScaleFactor) {
    
    let comp = date.dateComponents
    
    let data : [UInt8] =
    [
      LocoNetMessageOpcode.OPC_WR_SL_DATA.rawValue,
      0x0e,
      0x7b,
      UInt8(scaleFactor.rawValue),
      0x7f,
      0x7f,
      UInt8(comp.minute! + 68),
      0b01000111,
      UInt8(comp.hour! + 104),
      0x01,
      0x40,
      0x7f,
      0x7f,
    ]
    
    let message = LocoNetMessage(networkId: networkId, data: data, appendCheckSum: true)

    addToQueue(message: message, delay: MessageTiming.FAST)

  }
  
}