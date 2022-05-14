//
//  InterfaceExtensions.swift
//  MyTrains
//
//  Created by Paul Willmott on 14/05/2022.
//

import Foundation

extension Interface {
  
  // MARK: Public Methods
  
  public func powerOn() {
    
    let message = NetworkMessage(networkId: networkId, data: [NetworkMessageOpcode.OPC_GPON.rawValue], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)
    
  }
  
  public func powerOff() {
    
    let message = NetworkMessage(networkId: networkId, data: [NetworkMessageOpcode.OPC_GPOFF.rawValue], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)

  }
  
  public func getCfgSlotDataP1() {
    
    let message = NetworkMessage(networkId: networkId, data: [NetworkMessageOpcode.OPC_RQ_SL_DATA.rawValue, 0x7f, 0x00], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)

  }
  
  public func getCfgSlotDataBP1() {
    
    let message = NetworkMessage(networkId: networkId, data: [NetworkMessageOpcode.OPC_RQ_SL_DATA.rawValue, 0x7e, 0x00], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)

  }
  
  public func getCfgSlotDataP2() {
    
    let message = NetworkMessage(networkId: networkId, data: [NetworkMessageOpcode.OPC_RQ_SL_DATA.rawValue, 0x7f, 0x40], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)

  }
  
  public func getProgSlotDataP1(timeoutCode: TimeoutCode) {
    
    let message = NetworkMessage(networkId: networkId, data: [NetworkMessageOpcode.OPC_RQ_SL_DATA.rawValue, 0x7c, 0x00], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.CVOP, responses: [.progSlotDataP1], retryCount: 10, timeoutCode: timeoutCode)

  }
  
  public func getLocoSlotDataP1(slotNumber: Int) {
    
    let message = NetworkMessage(networkId: networkId, data: [NetworkMessageOpcode.OPC_RQ_SL_DATA.rawValue, UInt8(slotNumber), 0x00], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)

  }
  
  public func getLocoSlotDataP2(slotPage: Int, slotNumber: Int) {
    
    let message = NetworkMessage(networkId: networkId, data: [NetworkMessageOpcode.OPC_RQ_SL_DATA.rawValue, UInt8(slotNumber), UInt8(slotPage) | 0b01000000], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)

  }
  
  public func getQuerySlot(querySlot: Int) {
    
    guard querySlot > 0 && querySlot <= 5 else {
      return
    }
    
    let slotPage = 1
    let slotNumber = 0x78 + querySlot - 1
    
    let message = NetworkMessage(networkId: networkId, data: [NetworkMessageOpcode.OPC_RQ_SL_DATA.rawValue, UInt8(slotNumber), UInt8(slotPage) | 0b01000000], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)

  }
  
  public func getLocoSlotDataP1(forAddress: Int, timeoutCode: TimeoutCode) {
    
    let lo = UInt8(forAddress & 0x7f)
    
    let hi = UInt8(forAddress >> 7)
    
    let message = NetworkMessage(networkId: networkId, data: [NetworkMessageOpcode.OPC_LOCO_ADR.rawValue, hi, lo], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD, responses: [.locoSlotDataP1, .noFreeSlotsP1, .slotNotImplemented], retryCount: 5, timeoutCode: timeoutCode)

  }
  
  public func getLocoSlotDataP2(forAddress: Int, timeoutCode: TimeoutCode) {
    
    let lo = UInt8(forAddress & 0x7f)
    
    let hi = UInt8(forAddress >> 7)
    
    let message = NetworkMessage(networkId: networkId, data: [NetworkMessageOpcode.OPC_LOCO_ADR_P2.rawValue, hi, lo], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD, responses: [.locoSlotDataP2, .noFreeSlotsP2, .slotNotImplemented], retryCount: 5, timeoutCode: timeoutCode)

  }
  
  public func swState(switchNumber: Int, timeoutCode: TimeoutCode) {
    
    let lo = UInt8((switchNumber - 1) & 0x7f)
    
    let hi = UInt8((switchNumber - 1) >> 7)
    
    let message = NetworkMessage(networkId: networkId, data: [NetworkMessageOpcode.OPC_SW_STATE.rawValue, lo, hi], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD, responses: [.swState], retryCount: 10, timeoutCode: timeoutCode)

  }
  
  public func swReq(switchNumber: Int, state:OptionSwitchState) {
    
    let lo = UInt8((switchNumber - 1) & 0x7f)
    
    let bit : UInt8 = state == .closed ? 0x30 : 0x10
    
    let hi = UInt8((switchNumber - 1) >> 7) | bit
    
    let message = NetworkMessage(networkId: networkId, data: [NetworkMessageOpcode.OPC_SW_REQ.rawValue, lo, hi], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.SWREQ)

  }
  
  public func setLocoSlotDataP1(slotData: [UInt8], timeoutCode: TimeoutCode) {
    
    var data = [UInt8](repeating: 0, count: 13)
    
    data[0] = NetworkMessageOpcode.OPC_WR_SL_DATA.rawValue
    data[1] = 14
    
    for index in 0...slotData.count-1 {
      data[index + 2] = slotData[index]
    }
    
    let message = NetworkMessage(networkId: networkId, data: data, appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD, responses: [.setSlotDataOKP1], retryCount: 10, timeoutCode: timeoutCode)

  }

  public func setLocoSlotDataP2(slotData: [UInt8], timeoutCode: TimeoutCode) {
    
    var data = [UInt8](repeating: 0, count: 20)
    
    data[0] = NetworkMessageOpcode.OPC_WR_SL_DATA_P2.rawValue
    data[1] = 21
    
    for index in 0...slotData.count-1 {
      data[index + 2] = slotData[index]
    }
    
    let message = NetworkMessage(networkId: networkId, data: data, appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD, responses: [.setSlotDataOKP2], retryCount: 10, timeoutCode: timeoutCode)

  }
  
  public func resetQuerySlot4(timeoutCode: TimeoutCode) {
    let slotPage = 0x19
    let slotNumber = 0x7b
    let message = NetworkMessage(networkId: networkId, data: [NetworkMessageOpcode.OPC_WR_SL_DATA_P2.rawValue, 0x15, UInt8(slotPage), UInt8(slotNumber), 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD, responses: [.setSlotDataOKP2], retryCount: 10, timeoutCode: timeoutCode)
  }

  public func clearLocoSlotDataP1(slotNumber:Int, timeoutCode: TimeoutCode) {
    
    let message = NetworkMessage(networkId: networkId, data: [NetworkMessageOpcode.OPC_WR_SL_DATA.rawValue, 0x0e, UInt8(slotNumber), 0b00000011, 0x00, 0x00, 0b00100000, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD, responses: [.setSlotDataOKP1], retryCount: 10, timeoutCode: timeoutCode)

  }
  
  public func clearLocoSlotDataP2(slotPage: Int, slotNumber:Int, timeoutCode: TimeoutCode) {
    
    let message = NetworkMessage(networkId: networkId, data: [NetworkMessageOpcode.OPC_WR_SL_DATA_P2.rawValue, 0x15, UInt8(slotPage), UInt8(slotNumber), 0b00000011, 0x00, 0x00, 0x00, 0x00, 0x00, 0b00100000, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD, responses: [.setSlotDataOKP2,.ack], retryCount: 10, timeoutCode: timeoutCode)

  }
  
  public func moveSlotsP1(sourceSlotNumber: Int, destinationSlotNumber: Int, timeoutCode: TimeoutCode) {
    
    let message = NetworkMessage(networkId: networkId, data: [NetworkMessageOpcode.OPC_MOVE_SLOTS.rawValue, UInt8(sourceSlotNumber), UInt8(destinationSlotNumber)], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD, responses: [.locoSlotDataP1, .illegalMoveP1], retryCount: 10, timeoutCode: timeoutCode)

  }
  
  public func moveSlotsP2(sourceSlotNumber: Int, sourceSlotPage: Int, destinationSlotNumber: Int, destinationSlotPage: Int, timeoutCode: TimeoutCode) {
    
    let srcPage = UInt8(sourceSlotPage & 0b00000111) | 0b00111000
    let dstPage = UInt8(destinationSlotPage & 0b00000111)
    
    let message = NetworkMessage(networkId: networkId, data: [NetworkMessageOpcode.OPC_D4_GROUP.rawValue, srcPage, UInt8(sourceSlotNumber), dstPage, UInt8(destinationSlotNumber)], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD, responses: [.locoSlotDataP2, .d4Error, .locoSlotDataP1], retryCount: 10, timeoutCode: timeoutCode)

  }
  
  public func getInterfaceData(timeoutCode: TimeoutCode) {
    
    let message = NetworkMessage(networkId: networkId, data: [NetworkMessageOpcode.OPC_BUSY.rawValue], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD, responses: [.interfaceData], retryCount: 10, timeoutCode: timeoutCode)
    
  }
  
  public func findReceiver() {
    
    let message = NetworkMessage(networkId: networkId, data:
      [NetworkMessageOpcode.OPC_DF_GROUP.rawValue,
       0x00, 0x00, 0x00, 0x00
    ], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)
    
  }
  
  public func setLocoNetID(locoNetID: Int) {
    
    let lid : UInt8 = UInt8(locoNetID & 0x7)
    
    let message = NetworkMessage(networkId: networkId, data:
      [NetworkMessageOpcode.OPC_DF_GROUP.rawValue,
       0x40, 0x1f, lid, 0x00
    ], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)
    
  }
  
  public func getDuplexData() {
    
    let message = NetworkMessage(networkId: networkId, data:
      [NetworkMessageOpcode.OPC_PEER_XFER.rawValue,
       0x14, 0x03, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    ], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)
    
  }
  
  public func setDuplexChannelNumber(channelNumber: Int) {
    
    let cn = UInt8(channelNumber)
    
    let pxct1 : UInt8 = (cn & 0b10000000) == 0b10000000 ? 0b00000001 : 0
    
    let message = NetworkMessage(networkId: networkId, data:
      [NetworkMessageOpcode.OPC_PEER_XFER.rawValue,
       0x14, 0x02, 0x00, pxct1, cn, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    ], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)
    
  }
  
  public func setDuplexGroupID(groupID: Int) {
    
    let gid = UInt8(groupID)
    
    let pxct1 : UInt8 = (gid & 0b10000000) == 0b10000000 ? 0b00000001 : 0
    
    let message = NetworkMessage(networkId: networkId, data:
      [NetworkMessageOpcode.OPC_PEER_XFER.rawValue,
       0x14, 0x04, 0x00, pxct1, gid, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    ], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)
    
  }
  
  public func getDuplexGroupID() {
    
    let message = NetworkMessage(networkId: networkId, data:
      [NetworkMessageOpcode.OPC_PEER_XFER.rawValue,
       0x14, 0x04, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    ], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)
    
  }
  
  public func getDuplexSignalStrength(duplexGroupChannel: Int) {
    
    let message = NetworkMessage(networkId: networkId, data:
      [NetworkMessageOpcode.OPC_PEER_XFER.rawValue,
       0x14, 0x10, 0x08, 0x00, UInt8(duplexGroupChannel & 0x7f), 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    ], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)
    
  }
  
  public func setDuplexSignalStrength(duplexGroupChannel: Int, signalStrength:Int) {
    
    var pxct1 : UInt8 = 0
    pxct1 |= ((duplexGroupChannel & 0b10000000) == 0b10000000) ? 0b00000001 : 0
    pxct1 |= ((signalStrength     & 0b10000000) == 0b10000000) ? 0b00000010 : 0

    let message = NetworkMessage(networkId: networkId, data:
      [NetworkMessageOpcode.OPC_PEER_XFER.rawValue,
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
    
    let message = NetworkMessage(networkId: networkId, data:
      [NetworkMessageOpcode.OPC_PEER_XFER.rawValue,
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

    let message = NetworkMessage(networkId: networkId, data:
      [NetworkMessageOpcode.OPC_PEER_XFER.rawValue,
       0x14, 0x07, 0x00, pxct1, data[0] & 0x7f, data[1] & 0x7f, data[2] & 0x7f, data[3] & 0x7f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    ], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)
    
  }
  
  public func setProgMode(mode: ProgrammerMode) {
    
    let message = NetworkMessage(networkId: networkId, data: [NetworkMessageOpcode.OPC_PR_MODE.rawValue, 0x10, UInt8(mode.rawValue), 0x00, 0x00], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.PRMODE)

//    lastProgrammerMode = mode
    
  }
  
  public func readCV(progMode:ProgrammingMode, cv:Int, address: Int, timeoutCode: TimeoutCode) {
    
    var pcmd : UInt8 = 0
    
    switch progMode {
    case .directMode:
      pcmd = 0b00101011
    case .operationsMode:
      pcmd = 0b00100111
    case .pagedMode:
      pcmd = 0b00100011
    case .physicalRegister:
      pcmd = 0b00010011
    }
    
    var hopsa : UInt8 = 0
    var lopsa : UInt8 = 0
    
    if progMode == .operationsMode {
      lopsa = UInt8(address & 0x7f)
      hopsa = UInt8(address >> 7)
    }
    
    let cvAdjusted = cv - 1
    
    let cvh : Int = (cvAdjusted & 0b0000001000000000) == 0b0000001000000000 ? 0b00100000 : 0x00 |
                    (cvAdjusted & 0b0000000100000000) == 0b0000000100000000 ? 0b00010000 : 0x00 |
                    (cvAdjusted & 0b0000000010000000) == 0b0000000010000000 ? 0b00000001 : 0x00

    let message = NetworkMessage(networkId: networkId, data:
        [
          NetworkMessageOpcode.OPC_WR_SL_DATA.rawValue,
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
    
    addToQueue(message: message, delay: MessageTiming.CVOP, responses: [.progCmdAccepted, .progCmdAcceptedBlind], retryCount: 10, timeoutCode: timeoutCode)
    
  }
  
  
  public func writeCV(progMode: ProgrammingMode, cv:Int, address: Int, value: Int, timeoutCode: TimeoutCode) {
    
    var pcmd : UInt8 = 0
    
    switch progMode {
    case .directMode:
      pcmd = 0b01101011
    case .operationsMode:
      pcmd = 0b01101111
    case .pagedMode:
      pcmd = 0b01100011
    case .physicalRegister:
      pcmd = 0b01010011
    }
    
    var hopsa : UInt8 = 0
    var lopsa : UInt8 = 0
    
    if progMode == .operationsMode {
      lopsa = UInt8(address & 0x7f)
      hopsa = UInt8(address >> 7)
    }
    
   let cvAdjusted = cv - 1
    
    let cvh : Int = (cvAdjusted & 0b0000001000000000) == 0b0000001000000000 ? 0b00100000 : 0x00 |
                    (cvAdjusted & 0b0000000100000000) == 0b0000000100000000 ? 0b00010000 : 0x00 |
                    (cvAdjusted & 0b0000000010000000) == 0b0000000010000000 ? 0b00000001 : 0x00 |
                    (value & 0b10000000) == 0b10000000 ? 0b00000010 : 0x00

    let message = NetworkMessage(networkId: networkId, data:
        [
          NetworkMessageOpcode.OPC_WR_SL_DATA.rawValue,
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
          0x00,
          0x00
        ],
        appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.CVOP, responses: [.progCmdAccepted, .progCmdAcceptedBlind], retryCount: 10, timeoutCode: timeoutCode)
    
  }
  
  public func locoDirF0F4P1(slotNumber: Int, direction:LocomotiveDirection, functions: Int) {
    
    let slot = UInt8(slotNumber & 0x7f)
    
    var dirf : UInt8 = 0
    
    dirf |= direction == .forward        ? 0b00100000 : 0b00000000
    dirf |= functions & maskF0 == maskF0 ? 0b00010000 : 0b00000000
    dirf |= functions & maskF1 == maskF1 ? 0b00000001 : 0b00000000
    dirf |= functions & maskF2 == maskF2 ? 0b00000010 : 0b00000000
    dirf |= functions & maskF3 == maskF3 ? 0b00000100 : 0b00000000
    dirf |= functions & maskF4 == maskF4 ? 0b00001000 : 0b00000000
    
    let message = NetworkMessage(networkId: networkId, data: [NetworkMessageOpcode.OPC_LOCO_DIRF.rawValue, slot, dirf], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)
    
  }
  
  public func locoDirF0F4P2(slotNumber: Int, slotPage: Int, direction:LocomotiveDirection, functions: Int) {
    
    let slot = UInt8(slotNumber & 0x7f)
    
    let page = 0b00100000 | UInt8(slotPage & 0x07)
    
    var dirf : UInt8 = 0
    
    dirf |= direction == .forward        ? 0b00100000 : 0b00000000
    dirf |= functions & maskF0 == maskF0 ? 0b00010000 : 0b00000000
    dirf |= functions & maskF1 == maskF1 ? 0b00000001 : 0b00000000
    dirf |= functions & maskF2 == maskF2 ? 0b00000010 : 0b00000000
    dirf |= functions & maskF3 == maskF3 ? 0b00000100 : 0b00000000
    dirf |= functions & maskF4 == maskF4 ? 0b00001000 : 0b00000000
    
    let message = NetworkMessage(networkId: networkId, data: [NetworkMessageOpcode.OPC_D4_GROUP.rawValue, page, slot, 0x06, dirf], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)
    
  }
  
  public func locoF5F8P1(slotNumber: Int, functions: Int) {
    
    let slot = UInt8(slotNumber & 0x7f)
    
    var fnx : UInt8 = 0
    
    fnx |= functions & maskF5 == maskF5 ? 0b00000001 : 0b00000000
    fnx |= functions & maskF6 == maskF6 ? 0b00000010 : 0b00000000
    fnx |= functions & maskF7 == maskF7 ? 0b00000100 : 0b00000000
    fnx |= functions & maskF8 == maskF8 ? 0b00001000 : 0b00000000
    
    let message = NetworkMessage(networkId: networkId, data: [NetworkMessageOpcode.OPC_LOCO_SND.rawValue, slot, fnx], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)
    
  }
  
  public func locoF0F6P2(slotNumber: Int, slotPage: Int, functions: Int, throttleID: Int) {
    
    let slot = UInt8(slotNumber & 0x7f)
    
    let page = UInt8(slotPage & 0x07) | 0b00010000
    
    let tid = UInt8(throttleID & 0x7f)
    
    var fnx : UInt8 = 0
    
    fnx |= functions & maskF0 == maskF0 ? 0b00010000 : 0b00000000
    fnx |= functions & maskF1 == maskF1 ? 0b00000001 : 0b00000000
    fnx |= functions & maskF2 == maskF2 ? 0b00000010 : 0b00000000
    fnx |= functions & maskF3 == maskF3 ? 0b00000100 : 0b00000000
    fnx |= functions & maskF4 == maskF4 ? 0b00001000 : 0b00000000
    fnx |= functions & maskF5 == maskF5 ? 0b00100000 : 0b00000000
    fnx |= functions & maskF6 == maskF6 ? 0b01000000 : 0b00000000

    let message = NetworkMessage(networkId: networkId, data: [NetworkMessageOpcode.OPC_D5_GROUP.rawValue, page, slot, tid, fnx], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)
    
  }
  
  public func locoF5F11P2(slotNumber: Int, slotPage: Int, functions: Int) {
    
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

    let message = NetworkMessage(networkId: networkId, data: [NetworkMessageOpcode.OPC_D4_GROUP.rawValue, page, slot, 0x07, dirf], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)
    
  }
  
  public func locoF7F13P2(slotNumber: Int, slotPage: Int, functions: Int, throttleID: Int) {
    
    let slot = UInt8(slotNumber & 0x7f)
    
    let page = UInt8(slotPage & 0x07) | 0b00011000
    
    let tid = UInt8(throttleID & 0x7f)

    var fnx : UInt8 = 0
    
    fnx |= functions & maskF7  == maskF7  ? 0b00000001 : 0b00000000
    fnx |= functions & maskF8  == maskF8  ? 0b00000010 : 0b00000000
    fnx |= functions & maskF9  == maskF9  ? 0b00000100 : 0b00000000
    fnx |= functions & maskF10 == maskF10 ? 0b00001000 : 0b00000000
    fnx |= functions & maskF11 == maskF11 ? 0b00010000 : 0b00000000
    fnx |= functions & maskF12 == maskF12 ? 0b00100000 : 0b00000000
    fnx |= functions & maskF13 == maskF13 ? 0b01000000 : 0b00000000

    let message = NetworkMessage(networkId: networkId, data: [NetworkMessageOpcode.OPC_D5_GROUP.rawValue, page, slot, tid, fnx], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)
    
  }
  
  public func locoF12F20F28P2(slotNumber: Int, slotPage: Int, functions: Int) {
    
    let slot = UInt8(slotNumber & 0x7f)
    
    let page = 0b00100000 | UInt8(slotPage & 0x07)
    
    var dirf : UInt8 = 0
    
    dirf |= functions & maskF12 == maskF12  ? 0b00000001 : 0b00000000
    dirf |= functions & maskF20 == maskF20  ? 0b00000010 : 0b00000000
    dirf |= functions & maskF28 == maskF28  ? 0b00000100 : 0b00000000
 
    let message = NetworkMessage(networkId: networkId, data: [NetworkMessageOpcode.OPC_D4_GROUP.rawValue, page, slot, 0x05, dirf], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)
    
  }
  
  public func locoF13F19P2(slotNumber: Int, slotPage: Int, functions: Int) {
    
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

    let message = NetworkMessage(networkId: networkId, data: [NetworkMessageOpcode.OPC_D4_GROUP.rawValue, page, slot, 0x08, dirf], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)
    
  }

  public func locoF14F20P2(slotNumber: Int, slotPage: Int, functions: Int, throttleID: Int) {
    
    let slot = UInt8(slotNumber & 0x7f)
    
    let page = UInt8(slotPage & 0x07) | 0b00100000
    
    let tid = UInt8(throttleID & 0x7f)

    var fnx : UInt8 = 0
    
    fnx |= functions & maskF14 == maskF14 ? 0b00000001 : 0b00000000
    fnx |= functions & maskF15 == maskF15 ? 0b00000010 : 0b00000000
    fnx |= functions & maskF16 == maskF16 ? 0b00000100 : 0b00000000
    fnx |= functions & maskF17 == maskF17 ? 0b00001000 : 0b00000000
    fnx |= functions & maskF18 == maskF18 ? 0b00010000 : 0b00000000
    fnx |= functions & maskF19 == maskF19 ? 0b00100000 : 0b00000000
    fnx |= functions & maskF20 == maskF20 ? 0b01000000 : 0b00000000

    let message = NetworkMessage(networkId: networkId, data: [NetworkMessageOpcode.OPC_D5_GROUP.rawValue, page, slot, tid, fnx], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)
    
  }
  
  public func locoF21F27P2(slotNumber: Int, slotPage: Int, functions: Int) {
    
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

    let message = NetworkMessage(networkId: networkId, data: [NetworkMessageOpcode.OPC_D4_GROUP.rawValue, page, slot, 0x09, dirf], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)
    
  }
  
  public func locoF21F28P2(slotNumber: Int, slotPage: Int, functions: Int, throttleID: Int) {
    
    let slot = UInt8(slotNumber & 0x7f)
    
    let page = UInt8(slotPage & 0x07) | UInt8(functions & maskF28 == maskF28 ? 0b00110000 : 0b00101000)
    
    let tid = UInt8(throttleID & 0x7f)

    var fnx : UInt8 = 0
    
    fnx |= functions & maskF21 == maskF21 ? 0b00000001 : 0b00000000
    fnx |= functions & maskF22 == maskF22 ? 0b00000010 : 0b00000000
    fnx |= functions & maskF23 == maskF23 ? 0b00000100 : 0b00000000
    fnx |= functions & maskF24 == maskF24 ? 0b00001000 : 0b00000000
    fnx |= functions & maskF25 == maskF25 ? 0b00010000 : 0b00000000
    fnx |= functions & maskF26 == maskF26 ? 0b00100000 : 0b00000000
    fnx |= functions & maskF27 == maskF27 ? 0b01000000 : 0b00000000

    let message = NetworkMessage(networkId: networkId, data: [NetworkMessageOpcode.OPC_D5_GROUP.rawValue, page, slot, tid, fnx], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)
    
  }
  
  public func locoSpdP1(slotNumber: Int, speed: Int) {
    
    let slot = UInt8(slotNumber & 0x7f)
    
    let spd = UInt8(speed & 0x7f)
    
    let message = NetworkMessage(networkId: networkId, data: [NetworkMessageOpcode.OPC_LOCO_SPD.rawValue, slot, spd], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)

  }
  
  public func locoSpdDirP2(slotNumber: Int, slotPage: Int, speed: Int, direction: LocomotiveDirection, throttleID: Int) {
    
    let slot = UInt8(slotNumber & 0x7f)
    
    let page = UInt8(slotPage & 0x07) | (direction == .forward ? 0b00001000 : 0b00000000)
    
    let spd = UInt8(speed & 0x7f)
    
    let tid = UInt8(throttleID & 0x7f)

    let message = NetworkMessage(networkId: networkId, data: [NetworkMessageOpcode.OPC_D5_GROUP.rawValue, page, slot, tid, spd], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)

  }
  
  public func locoSpdP2(slotNumber: Int, slotPage: Int, speed: Int) {
    
    let slot = UInt8(slotNumber & 0x7f)
    
    let page = UInt8(slotPage & 0x07) | 0b00100000
    
    let spd = UInt8(speed & 0x7f)
    
    let message = NetworkMessage(networkId: networkId, data: [NetworkMessageOpcode.OPC_D4_GROUP.rawValue, page, slot, 0x04, spd], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)

  }
  
  public func powerIdle() {
    
    let message = NetworkMessage(networkId: networkId, data: [NetworkMessageOpcode.OPC_IDLE.rawValue], appendCheckSum: true)
    
    addToQueue(message: message, delay: MessageTiming.STANDARD)

  }

}
