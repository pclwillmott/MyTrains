//
//  LocoNetExtensions.swift
//  MyTrains
//
//  Created by Paul Willmott on 02/07/2023.
//

import Foundation
import SGDCC

extension LocoNetGateway {
  
  // MARK: COMMAND STATION COMMANDS

  public func sendMessage(message:LocoNetMessage) {
    addToQueue(message: message)
  }
  
  public func powerOn() {
    addToQueue(message: LocoNetMessage(data: [LocoNetMessageOpcode.OPC_GPON.rawValue], appendCheckSum: true))
  }
  
  public func powerOff() {
    addToQueue(message: LocoNetMessage(data: [LocoNetMessageOpcode.OPC_GPOFF.rawValue], appendCheckSum: true))
  }
  
  public func getOpSwDataAP1() {
    addToQueue(message: LocoNetMessage(data: [LocoNetMessageOpcode.OPC_RQ_SL_DATA.rawValue, 0x7f, 0x00], appendCheckSum: true))
  }

  // MARK: HELPER COMMANDS
  
  public func immPacket(packet:SGDCCPacket?, repeatCount: LocoNetIMMPacketRepeat) {
    
    guard let packet else {
      return
    }
    
    var data = packet.packet
    
    data.removeLast()
    
    immPacket(packet: data, repeatCount: repeatCount)
    
  }
  
  public func immPacket(packet:[UInt8], repeatCount: LocoNetIMMPacketRepeat) {
    
    guard packet.count < 6 else {
      return
    }
    
    let param : UInt8 = ((UInt8(packet.count) << 4) | repeatCount.rawValue) & 0x7f
    
    var payload : [UInt8] = [
      LocoNetMessageOpcode.OPC_IMM_PACKET.rawValue,
      0x0b,
      0x7f,
      param,
      0b00000000,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00
    ]
    
    var mask : UInt8 = 1
    
    for index in 0...packet.count - 1 {
      
      payload[4] |= (packet[index] & 0x80 == 0x80) ? mask : 0x00
      
      payload[5 + index] = packet[index] & 0x7f
      
      mask <<= 1
      
    }
    
    addToQueue(message: LocoNetMessage(data: payload, appendCheckSum: true))

  }
  
  // MARK: LOCOMOTIVE CONTROL COMMANDS
  
  public func getLocoSlotDataP1(forAddress: UInt16) {
    addToQueue(message: LocoNetMessage(data: [LocoNetMessageOpcode.OPC_LOCO_ADR.rawValue, UInt8(forAddress >> 7), UInt8(forAddress & 0x7f)], appendCheckSum: true))
  }
  
  public func getLocoSlotDataP2(forAddress: UInt16) {
    addToQueue(message: LocoNetMessage(data: [LocoNetMessageOpcode.OPC_LOCO_ADR_P2.rawValue, UInt8(forAddress >> 7), UInt8(forAddress & 0x7f)], appendCheckSum: true))
  }
  
  public func getLocoSlotData(forAddress: UInt16) {
    if commandStationType.implementsProtocol2 {
      getLocoSlotDataP2(forAddress: forAddress)
    }
    else {
      getLocoSlotDataP1(forAddress: forAddress)
    }
  }
  
  public func setLocoSlotStat1P1(slotNumber:UInt8, stat1:UInt8) {
    addToQueue(message: LocoNetMessage(data: [LocoNetMessageOpcode.OPC_SLOT_STAT1.rawValue, UInt8(slotNumber), stat1], appendCheckSum: true))
  }
  
  public func setLocoSlotStat1P2(slotPage:UInt8, slotNumber:UInt8, stat1:UInt8) {
    addToQueue(message: LocoNetMessage(data: [LocoNetMessageOpcode.OPC_D4_GROUP.rawValue, 0b00111000 | (slotPage & 0b00000111), UInt8(slotNumber & 0x7f), 0x60, stat1], appendCheckSum: true))
  }

  public func setLocoSlotStat1(slotPage:UInt8, slotNumber:UInt8, stat1:UInt8) {
    if commandStationType.implementsProtocol2 {
      setLocoSlotStat1P2(slotPage: slotPage, slotNumber: slotNumber, stat1: stat1)
    }
    else {
      setLocoSlotStat1P1(slotNumber: slotNumber, stat1: stat1)
    }
  }
  
  public func moveSlotsP1(sourceSlotNumber: UInt8, destinationSlotNumber: UInt8) {
    addToQueue(message: LocoNetMessage(data: [LocoNetMessageOpcode.OPC_MOVE_SLOTS.rawValue, UInt8(sourceSlotNumber), UInt8(destinationSlotNumber)], appendCheckSum: true))
  }
  
  public func moveSlotsP2(sourceSlotNumber: UInt8, sourceSlotPage: UInt8, destinationSlotNumber: UInt8, destinationSlotPage: UInt8) {
    addToQueue(message: LocoNetMessage(data: [LocoNetMessageOpcode.OPC_D4_GROUP.rawValue, (sourceSlotPage & 0b00000111) | 0b00111000, UInt8(sourceSlotNumber), destinationSlotPage & 0b00000111, UInt8(destinationSlotNumber)], appendCheckSum: true))
  }
  
  public func setLocomotiveState(address:UInt16, slotNumber: UInt8, slotPage: UInt8, nextState:LocoNetLocomotiveState, throttleID: UInt16) -> LocomotiveStateWithTimeStamp {
    
    var next = nextState.functions

    let timeStamp = Date.timeIntervalSinceReferenceDate
      
    if commandStationType.implementsProtocol2 {
        
      locoSpdDirP2(slotNumber: slotNumber, slotPage: slotPage, speed: nextState.speed, direction: nextState.direction, throttleID: throttleID)

      locoF0F6P2(slotNumber:   slotNumber, slotPage: slotPage, functions: next, throttleID: throttleID)
      locoF7F13P2(slotNumber:  slotNumber, slotPage: slotPage, functions: next, throttleID: throttleID)
      locoF14F20P2(slotNumber: slotNumber, slotPage: slotPage, functions: next, throttleID: throttleID)
      locoF21F28P2(slotNumber: slotNumber, slotPage: slotPage, functions: next, throttleID: throttleID)

    }
    else {
      
      locoSpdP1(slotNumber: slotNumber, speed: nextState.speed)

      locoDirF0F4P1(slotNumber: slotNumber, direction: nextState.direction, functions: next)
      
      if commandStationType.implementsProtocol1 {
        locoF5F8P1(slotNumber: slotNumber, functions: next)
      }
      else {
        dccF5F8(address: address, functions: next)
      }
      
      dccF9F12(address:  address, functions: next)
      dccF13F20(address: address, functions: next)
      dccF21F28(address: address, functions: next)
      
    }
    
    next = nextState.extendedFunctions
    
    dccF29F36(address: address, functions: next)
    dccF37F44(address: address, functions: next)
    dccF45F52(address: address, functions: next)
    dccF53F60(address: address, functions: next)
    dccF61F68(address: address, functions: next)

    return (state: nextState, timeStamp: timeStamp)

  }
  
  public func updateLocomotiveState(address:UInt16, slotNumber: UInt8, slotPage: UInt8, previousState:LocoNetLocomotiveState, nextState:LocoNetLocomotiveState, throttleID: UInt16, forceRefresh: Bool) -> LocomotiveStateWithTimeStamp {
 
    var previous = previousState.functions
    
    var next = nextState.functions

    let speedChanged = previousState.speed != nextState.speed
    
    let directionChanged = previousState.direction != nextState.direction
    
    let timeStamp = Date.timeIntervalSinceReferenceDate
    
    if commandStationType.implementsProtocol2 {
      
      if speedChanged || directionChanged || forceRefresh {
        locoSpdDirP2(slotNumber: slotNumber, slotPage: slotPage, speed: nextState.speed, direction: nextState.direction, throttleID: throttleID)
      }

      let maskF0F6   : UInt64 = 0b00000000000000000000000001111111
      let maskF7F13  : UInt64 = 0b00000000000000000011111110000000
      let maskF14F20 : UInt64 = 0b00000000000111111100000000000000
      let maskF21F28 : UInt64 = 0b00011111111000000000000000000000
      
      if previous & maskF0F6 != next & maskF0F6 {
        locoF0F6P2(slotNumber: slotNumber, slotPage: slotPage, functions: next, throttleID: throttleID)
      }
      
      if previous & maskF7F13 != next & maskF7F13 {
        locoF7F13P2(slotNumber: slotNumber, slotPage: slotPage, functions: next, throttleID: throttleID)
      }
      
      if previous & maskF14F20 != next & maskF14F20 {
        locoF14F20P2(slotNumber: slotNumber, slotPage: slotPage, functions: next, throttleID: throttleID)
      }
      
      if previous & maskF21F28 != next & maskF21F28 {
        locoF21F28P2(slotNumber: slotNumber, slotPage: slotPage, functions: next, throttleID: throttleID)
      }

    }
    else {
      
      if speedChanged || forceRefresh {
        locoSpdP1(slotNumber: slotNumber, speed: nextState.speed)
      }

      let maskF0F4   : UInt64 = 0b00000000000000000000000000011111
      let maskF5F8   : UInt64 = 0b00000000000000000000000111100000
      let maskF9F12  : UInt64 = 0b00000000000000000001111000000000
      let maskF13F20 : UInt64 = 0b00000000000111111110000000000000
      let maskF21F28 : UInt64 = 0b00011111111000000000000000000000

      if previous & maskF0F4 != next & maskF0F4 || directionChanged {
        locoDirF0F4P1(slotNumber: slotNumber, direction: nextState.direction, functions: next)
      }
      
      if previous & maskF5F8 != next & maskF5F8 {
        
        if commandStationType.implementsProtocol1 {
          locoF5F8P1(slotNumber: slotNumber, functions: next)
        }
        else {
          dccF5F8(address: address, functions: next)
        }
        
      }

      if previous & maskF9F12 != next & maskF9F12 {
        dccF9F12(address: address, functions: next)
      }
      
      if previous & maskF13F20 != next & maskF13F20 {
        dccF13F20(address: address, functions: next)
      }

      if previous & maskF21F28 != next & maskF21F28 {
        dccF21F28(address: address, functions: next)
      }

    }
    
    previous = previousState.extendedFunctions
    
    next = nextState.extendedFunctions
    
    let maskF29F36   : UInt64 = 0b0000000000000000000000000000000011111111
    let maskF37F44   : UInt64 = 0b0000000000000000000000001111111100000000
    let maskF45F52   : UInt64 = 0b0000000000000000111111110000000000000000
    let maskF53F60   : UInt64 = 0b0000000011111111000000000000000000000000
    let maskF61F68   : UInt64 = 0b1111111100000000000000000000000000000000

    if previous & maskF29F36 != next & maskF29F36 {
      dccF29F36(address: address, functions: next)
    }
    
    if previous & maskF37F44 != next & maskF37F44 {
      dccF37F44(address: address, functions: next)
    }

    if previous & maskF45F52 != next & maskF45F52 {
      dccF45F52(address: address, functions: next)
    }

    if previous & maskF53F60 != next & maskF53F60 {
      dccF53F60(address: address, functions: next)
    }

    if previous & maskF61F68 != next & maskF61F68 {
      dccF61F68(address: address, functions: next)
    }

    return (state: nextState, timeStamp: timeStamp)

  }

  public func clearLocomotiveState(address:UInt16, slotNumber: UInt8, slotPage: UInt8, previousState:LocoNetLocomotiveState, throttleID: UInt16) {
    
    let speed : UInt8 = 0
    
    let next : UInt64 = 0
    
    if commandStationType.implementsProtocol2 {
      
      locoSpdDirP2(slotNumber: slotNumber, slotPage: slotPage, speed: speed, direction: previousState.direction, throttleID: throttleID)

      locoF0F6P2(slotNumber:   slotNumber, slotPage: slotPage, functions: next, throttleID: throttleID)
      locoF7F13P2(slotNumber:  slotNumber, slotPage: slotPage, functions: next, throttleID: throttleID)
      locoF14F20P2(slotNumber: slotNumber, slotPage: slotPage, functions: next, throttleID: throttleID)
      locoF21F28P2(slotNumber: slotNumber, slotPage: slotPage, functions: next, throttleID: throttleID)

    }
    else {
      
      locoSpdP1(slotNumber: slotNumber, speed: speed)

      locoDirF0F4P1(slotNumber: slotNumber, direction: previousState.direction, functions: next)
      
      if commandStationType.implementsProtocol1 {
        locoF5F8P1(slotNumber: slotNumber, functions: next)
      }
      else {
        dccF5F8(address: address, functions: next)
      }
      
      dccF9F12(address:  address, functions: next)
      dccF13F20(address: address, functions: next)
      dccF21F28(address: address, functions: next)
      
    }
    
    dccF29F36(address: address, functions: next)
    dccF37F44(address: address, functions: next)
    dccF45F52(address: address, functions: next)
    dccF53F60(address: address, functions: next)
    dccF61F68(address: address, functions: next)

  }
  

  public func locoSpdDirP2(slotNumber: UInt8, slotPage: UInt8, speed: UInt8, direction: LocomotiveDirection, throttleID: UInt16) {
    
    let data : [UInt8] = [
      LocoNetMessageOpcode.OPC_D5_GROUP.rawValue,
      (slotPage & 0x07) | (direction == .reverse ? 0b00001000 : 0b00000000),
      slotNumber & 0x7f,
      UInt8(throttleID & 0x7f),
      speed & 0x7f
    ]
    
    addToQueue(message: LocoNetMessage(data: data, appendCheckSum: true))

  }
  
  public func locoSpdP1(slotNumber: UInt8, speed: UInt8) {
    
    let data : [UInt8] = [
      LocoNetMessageOpcode.OPC_LOCO_SPD.rawValue,
      slotNumber & 0x7f,
      speed & 0x7f
    ]
    
    addToQueue(message: LocoNetMessage(data: data, appendCheckSum: true))

  }
  
  public func locoF0F6P2(slotNumber: UInt8, slotPage: UInt8, functions: UInt64, throttleID: UInt16) {
    
    var fnx : UInt8 = 0
    
    fnx |= functions & maskF0 == maskF0 ? 0b00010000 : 0b00000000
    fnx |= functions & maskF1 == maskF1 ? 0b00000001 : 0b00000000
    fnx |= functions & maskF2 == maskF2 ? 0b00000010 : 0b00000000
    fnx |= functions & maskF3 == maskF3 ? 0b00000100 : 0b00000000
    fnx |= functions & maskF4 == maskF4 ? 0b00001000 : 0b00000000
    fnx |= functions & maskF5 == maskF5 ? 0b00100000 : 0b00000000
    fnx |= functions & maskF6 == maskF6 ? 0b01000000 : 0b00000000

    let data : [UInt8] = [
      LocoNetMessageOpcode.OPC_D5_GROUP.rawValue,
      (slotPage & 0x07) | 0b00010000,
      slotNumber & 0x7f,
      UInt8(throttleID & 0x7f),
      fnx
    ]
    
    addToQueue(message: LocoNetMessage(data: data, appendCheckSum: true))

  }
  
  public func locoF7F13P2(slotNumber: UInt8, slotPage: UInt8, functions: UInt64, throttleID: UInt16) {
    
    var fnx : UInt8 = 0
    
    fnx |= functions & maskF7  == maskF7  ? 0b00000001 : 0b00000000
    fnx |= functions & maskF8  == maskF8  ? 0b00000010 : 0b00000000
    fnx |= functions & maskF9  == maskF9  ? 0b00000100 : 0b00000000
    fnx |= functions & maskF10 == maskF10 ? 0b00001000 : 0b00000000
    fnx |= functions & maskF11 == maskF11 ? 0b00010000 : 0b00000000
    fnx |= functions & maskF12 == maskF12 ? 0b00100000 : 0b00000000
    fnx |= functions & maskF13 == maskF13 ? 0b01000000 : 0b00000000
    
    let data : [UInt8] = [
      LocoNetMessageOpcode.OPC_D5_GROUP.rawValue,
      (slotPage & 0x07) | 0b00011000,
      slotNumber & 0x7f,
      UInt8(throttleID & 0x7f),
      fnx
    ]

    addToQueue(message: LocoNetMessage(data: data, appendCheckSum: true))

  }
  
  public func locoF14F20P2(slotNumber: UInt8, slotPage: UInt8, functions: UInt64, throttleID: UInt16) {
    
    var fnx : UInt8 = 0
    
    fnx |= functions & maskF14 == maskF14 ? 0b00000001 : 0b00000000
    fnx |= functions & maskF15 == maskF15 ? 0b00000010 : 0b00000000
    fnx |= functions & maskF16 == maskF16 ? 0b00000100 : 0b00000000
    fnx |= functions & maskF17 == maskF17 ? 0b00001000 : 0b00000000
    fnx |= functions & maskF18 == maskF18 ? 0b00010000 : 0b00000000
    fnx |= functions & maskF19 == maskF19 ? 0b00100000 : 0b00000000
    fnx |= functions & maskF20 == maskF20 ? 0b01000000 : 0b00000000
    
    let data : [UInt8] = [
      LocoNetMessageOpcode.OPC_D5_GROUP.rawValue,
      (slotPage & 0x07) | 0b00100000,
      slotNumber & 0x7f,
      UInt8(throttleID & 0x7f),
      fnx
    ]

    addToQueue(message: LocoNetMessage(data: data, appendCheckSum: true))

  }
  
  public func locoF21F28P2(slotNumber: UInt8, slotPage: UInt8, functions: UInt64, throttleID: UInt16) {
    
    var fnx : UInt8 = 0
    
    fnx |= functions & maskF21 == maskF21 ? 0b00000001 : 0b00000000
    fnx |= functions & maskF22 == maskF22 ? 0b00000010 : 0b00000000
    fnx |= functions & maskF23 == maskF23 ? 0b00000100 : 0b00000000
    fnx |= functions & maskF24 == maskF24 ? 0b00001000 : 0b00000000
    fnx |= functions & maskF25 == maskF25 ? 0b00010000 : 0b00000000
    fnx |= functions & maskF26 == maskF26 ? 0b00100000 : 0b00000000
    fnx |= functions & maskF27 == maskF27 ? 0b01000000 : 0b00000000
    
    let data : [UInt8] = [
      LocoNetMessageOpcode.OPC_D5_GROUP.rawValue,
      (slotPage & 0x07) | UInt8(functions & maskF28 == maskF28 ? 0b00110000 : 0b00101000),
      slotNumber & 0x7f,
      UInt8(throttleID & 0x7f),
      fnx]

    addToQueue(message: LocoNetMessage(data: data, appendCheckSum: true))

  }
  
  public func locoDirF0F4P1(slotNumber: UInt8, direction:LocomotiveDirection, functions: UInt64) {
    
    var dirf : UInt8 = 0
    
    dirf |= direction == .reverse        ? 0b00100000 : 0b00000000
    dirf |= functions & maskF0 == maskF0 ? 0b00010000 : 0b00000000
    dirf |= functions & maskF1 == maskF1 ? 0b00000001 : 0b00000000
    dirf |= functions & maskF2 == maskF2 ? 0b00000010 : 0b00000000
    dirf |= functions & maskF3 == maskF3 ? 0b00000100 : 0b00000000
    dirf |= functions & maskF4 == maskF4 ? 0b00001000 : 0b00000000
    
    let data : [UInt8] = [
      LocoNetMessageOpcode.OPC_LOCO_DIRF.rawValue,
      slotNumber & 0x7f,
      dirf
    ]
    
    addToQueue(message: LocoNetMessage(data: data, appendCheckSum: true))

  }
  
  public func locoF5F8P1(slotNumber: UInt8, functions: UInt64) {
    
    var fnx : UInt8 = 0
    
    fnx |= functions & maskF5 == maskF5 ? 0b00000001 : 0b00000000
    fnx |= functions & maskF6 == maskF6 ? 0b00000010 : 0b00000000
    fnx |= functions & maskF7 == maskF7 ? 0b00000100 : 0b00000000
    fnx |= functions & maskF8 == maskF8 ? 0b00001000 : 0b00000000
    
    let data : [UInt8] = [
      LocoNetMessageOpcode.OPC_LOCO_SND.rawValue,
      slotNumber & 0x7f,
      fnx
    ]
    
    addToQueue(message: LocoNetMessage(data: data, appendCheckSum: true))

  }
  
  internal func dccAddress(address:UInt16) -> [UInt8] {
    
    if address < 128 {
      return [UInt8(address)]
    }
    
    let temp = Int(address) + 49152
    
    return [UInt8(temp >> 8), UInt8(temp & 0xff)]
    
  }
  
  private func sgFunctions(functionsA: UInt64, functionsB: UInt64) -> [Bool] {
    var result : [Bool] = []
    var mask : UInt64 = 1
    for _ in 0 ... 28 {
      result.append((functionsA & mask) != 0)
      mask <<= 1
    }
    mask = 1
    for _ in 29 ... 68 {
      result.append((functionsB & mask) != 0)
      mask <<= 1
    }
    return result
  }
  
  public func dccF5F8(address:UInt16, functions: UInt64) {
    
    let temp = sgFunctions(functionsA: functions, functionsB: 0)
    
    var packet : SGDCCPacket?
    
    if address < 128 {
      packet = SGDCCPacket.f5f8Control(shortAddress: UInt8(address), functions: temp)
    }
    else {
      packet = SGDCCPacket.f5f8Control(longAddress: address, functions: temp)
    }
    
    immPacket(packet: packet, repeatCount: .repeat4)
    
  }

  public func dccF9F12(address:UInt16, functions: UInt64) {
    
    let temp = sgFunctions(functionsA: functions, functionsB: 0)
    
    var packet : SGDCCPacket?
    
    if address < 128 {
      packet = SGDCCPacket.f9f12Control(shortAddress: UInt8(address), functions: temp)
    }
    else {
      packet = SGDCCPacket.f9f12Control(longAddress: address, functions: temp)
    }
    
    immPacket(packet: packet, repeatCount: .repeat4)

  }

  public func dccF13F20(address:UInt16, functions: UInt64) {
    
    let temp = sgFunctions(functionsA: functions, functionsB: 0)
    
    var packet : SGDCCPacket?
    
    if address < 128 {
      packet = SGDCCPacket.f13f20Control(shortAddress: UInt8(address), functions: temp)
    }
    else {
      packet = SGDCCPacket.f13f20Control(longAddress: address, functions: temp)
    }
    
    immPacket(packet: packet, repeatCount: .repeat4)

  }

  public func dccF21F28(address:UInt16, functions: UInt64) {
    
    let temp = sgFunctions(functionsA: functions, functionsB: 0)
    
    var packet : SGDCCPacket?
    
    if address < 128 {
      packet = SGDCCPacket.f21f28Control(shortAddress: UInt8(address), functions: temp)
    }
    else {
      packet = SGDCCPacket.f21f28Control(longAddress: address, functions: temp)
    }
    
    immPacket(packet: packet, repeatCount: .repeat4)

  }

  public func dccF29F36(address:UInt16, functions: UInt64) {
    
    let temp = sgFunctions(functionsA: 0, functionsB: functions)
    
    var packet : SGDCCPacket?
    
    if address < 128 {
      packet = SGDCCPacket.f29f36Control(shortAddress: UInt8(address), functions: temp)
    }
    else {
      packet = SGDCCPacket.f29f36Control(longAddress: address, functions: temp)
    }
    
    immPacket(packet: packet, repeatCount: .repeat4)

  }

  public func dccF37F44(address:UInt16, functions: UInt64) {
    
    let temp = sgFunctions(functionsA: 0, functionsB: functions)
    
    var packet : SGDCCPacket?
    
    if address < 128 {
      packet = SGDCCPacket.f29f36Control(shortAddress: UInt8(address), functions: temp)
    }
    else {
      packet = SGDCCPacket.f29f36Control(longAddress: address, functions: temp)
    }
    
    immPacket(packet: packet, repeatCount: .repeat4)

  }

  public func dccF45F52(address:UInt16, functions: UInt64) {
    
    let temp = sgFunctions(functionsA: 0, functionsB: functions)
    
    var packet : SGDCCPacket?
    
    if address < 128 {
      packet = SGDCCPacket.f45f52Control(shortAddress: UInt8(address), functions: temp)
    }
    else {
      packet = SGDCCPacket.f45f52Control(longAddress: address, functions: temp)
    }
    
    immPacket(packet: packet, repeatCount: .repeat4)

  }

  public func dccF53F60(address:UInt16, functions: UInt64) {
    
    let temp = sgFunctions(functionsA: 0, functionsB: functions)
    
    var packet : SGDCCPacket?
    
    if address < 128 {
      packet = SGDCCPacket.f53f60Control(shortAddress: UInt8(address), functions: temp)
    }
    else {
      packet = SGDCCPacket.f53f60Control(longAddress: address, functions: temp)
    }
    
    immPacket(packet: packet, repeatCount: .repeat4)

  }

  public func dccF61F68(address:UInt16, functions: UInt64) {
    
    let temp = sgFunctions(functionsA: 0, functionsB: functions)
    
    var packet : SGDCCPacket?
    
    if address < 128 {
      packet = SGDCCPacket.f61f68Control(shortAddress: UInt8(address), functions: temp)
    }
    else {
      packet = SGDCCPacket.f61f68Control(longAddress: address, functions: temp)
    }
    
    immPacket(packet: packet, repeatCount: .repeat4)

  }
/*
  public func dccBinaryState(address:UInt16, binaryStateAddress:UInt16, state:DCCBinaryState) {
    
    var data : [UInt8] = dccAddress(address: address)
    
    if binaryStateAddress < 128 {
      data.append(DCCPacketType.dccBinaryStateShort.rawValue)
      data.append(state.rawValue | UInt8(binaryStateAddress & 0x7f))
    }
    else {
      data.append(DCCPacketType.dccBinaryStateLong.rawValue)
      data.append(state.rawValue | UInt8(binaryStateAddress & 0x7f))
      data.append(UInt8(binaryStateAddress >> 7))
    }
    
    immPacket(packet: data, repeatCount: .repeat4)
    
  }

  public func dccAnalogFunction(address:UInt16, analogOutput:UInt8, value:UInt8) {
    
    var data : [UInt8] = dccAddress(address: address)

    data.append(contentsOf: [
      DCCPacketType.dccAnalogFunction.rawValue,
      analogOutput,
      value
    ])
    
    immPacket(packet: data, repeatCount: .repeat4)
    
  }
  */
  // MARK: CV PROGRAMMING
  
  private func s7CVRWPacket(address:UInt16, cvNumber:UInt16, mode:DCCCVAccessMode) -> [UInt8] {

    var packet : [UInt8] = [
      0b10000000,
      0b10001000,
      0b11100000,
      0b00000000,
      0b00000000,
    ]
    
    let addr = address - 1
    
    let cv = cvNumber - 1
    
    packet[0] |= UInt8((addr >> 2) & 0b00111111)
    
    packet[1] |= UInt8((addr & 0b00000011) << 1)
    
    packet[1] |= UInt8(~(addr >> 4) & 0b01110000)
    
    packet[2] |= UInt8(cv >> 8)
    
    packet[2] |= mode.rawValue

    packet[3] |= UInt8(cv & 0xff)
    
    return packet
    
  }
  
  public func s7CVReadByte(address:UInt16, cvNumber:UInt16) {
    let packet = s7CVRWPacket(address: address, cvNumber: cvNumber, mode: .readByte)
    immPacket(packet: packet, repeatCount: .repeat4)
  }

  public func s7CVWriteByte(address:UInt16, cvNumber:UInt16, cvValue:UInt8) {
    var packet = s7CVRWPacket(address: address, cvNumber: cvNumber, mode: .writeByte)
    packet[4] = cvValue
    immPacket(packet: packet, repeatCount: .repeat4)
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
    
    let message = LocoNetMessage(data: [LocoNetMessageOpcode.OPC_IMM_PACKET.rawValue, 0x0b, 0x7f, 0x54, high, addA, addB, mode, cv & 0x7f, val & 0x7f], appendCheckSum: true)
    
    addToQueue(message: message)

  }

  public func readCVOpsMode(cv:Int, cvValue: UInt8, address:UInt16) {
    
    var cmd : UInt8 = 0b11100000
    
    let maskcvBit9 = 0b001000000000
    let maskcvBit8 = 0b000100000000
    
    cmd |= (cv & maskcvBit9) == maskcvBit9 ? 0b10 : 0
    cmd |= (cv & maskcvBit8) == maskcvBit8 ? 0b01 : 0
    
    cmd |= 0b00000100 // read

    let packet : [UInt8] = [
      cv17(address: address),
      cv18(address: address),
      cmd,
      UInt8(cv & 0xff),
      cvValue,
    ]
    
    immPacket(packet: packet, repeatCount: .repeat4)
    
  }
  
  public func cv17(address: UInt16) -> UInt8 {
    let temp = address + 49152
    return UInt8(temp >> 8)
  }
  
  public func cv18(address: UInt16) -> UInt8 {
    let temp = address + 49152
    return UInt8(temp & 0xff)
  }

  public func readCV(progMode:LocoNetProgrammingMode, cv:Int, address: UInt16) {
    
    guard let pcmd = progMode.command(isByte: true, isWrite: false) else {
      return
    }
    
    var hopsa : UInt8 = 0
    var lopsa : UInt8 = 0
    
    if progMode == .operations {
      lopsa = UInt8(address & 0x7f)
      hopsa = UInt8((address >> 7) & 0x7f)
    }
    
    let cvh : Int = ((cv & 0b0000001000000000) == 0b0000001000000000 ? 0b00100000 : 0x00) |
                    ((cv & 0b0000000100000000) == 0b0000000100000000 ? 0b00010000 : 0x00) |
                    ((cv & 0b0000000010000000) == 0b0000000010000000 ? 0b00000001 : 0x00)

    let message = LocoNetMessage(data:
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
          UInt8(cv & 0x7f),
          0x00,
          0x00,
          0x00
        ],
        appendCheckSum: true)
    
    addToQueue(message: message)
    
  }
  
  public func writeCV(progMode: LocoNetProgrammingMode, cv:Int, address: Int, value: UInt8) {
    
    guard let pcmd = progMode.command(isByte: true, isWrite: true) else {
      return
    }
    
    var hopsa : UInt8 = 0
    var lopsa : UInt8 = 0
    
    if progMode == .operations {
      lopsa = UInt8(address & 0x7f)
      hopsa = UInt8(address >> 7)
    }
    
    let cvh : Int = ((cv & 0b0000001000000000) == 0b0000001000000000 ? 0b00100000 : 0x00) |
                    ((cv & 0b0000000100000000) == 0b0000000100000000 ? 0b00010000 : 0x00) |
                    ((cv & 0b0000000010000000) == 0b0000000010000000 ? 0b00000001 : 0x00) |
                    ((value & 0b10000000) == 0b10000000 ? 0b00000010 : 0x00)

    let message = LocoNetMessage(data:
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
          UInt8(cv & 0x7f),
          UInt8(value & 0x7f),
          0x7f,
          0x7f
        ],
        appendCheckSum: true)

    addToQueue(message: message)
    
  }
  
  // MARK: IPL
  
  public func iplDiscover() {
    
    let message = LocoNetMessage(data: [LocoNetMessageOpcode.OPC_PEER_XFER.rawValue,
       0x14, 0x0f, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], appendCheckSum: true)
    
    addToQueue(message: message)

  }

  public func iplDiscover(productCode:DigitraxProductCode) {
    
    let message = LocoNetMessage(data: [LocoNetMessageOpcode.OPC_PEER_XFER.rawValue,
                                        0x14,
                                        0x0f,
                                        0x08,
                                        0x00,
                                        productCode.rawValue,
                                        0x00,
                                        0x00,
                                        0x00,
                                        0x00,
                                        0x00,
                                        0x01,
                                        0x00,
                                        0x00,
                                        0x00,
                                        0x00,
                                        0x00,
                                        0x00,
                                        0x00],
                                 appendCheckSum: true)
    
    addToQueue(message: message)

  }
/*
  public func getSwState(switchNumber: Int) {
    
    let lo = UInt8((switchNumber - 1) & 0x7f)
    
    let hi = UInt8((switchNumber - 1) >> 7)
    
    let message = LocoNetMessage(data: [LocoNetMessageOpcode.OPC_SW_STATE.rawValue, lo, hi], appendCheckSum: true)
    
    addToQueue(message: message)

  }
  
  public func setSw(switchNumber: Int, state:OptionSwitchState) {
    
    let sn = switchNumber - 1
    
    let lo = UInt8(sn & 0x7f)
    
    let bit : UInt8 = state == .closed ? 0x30 : 0x10
    
    let hi = UInt8(sn >> 7) | bit
    
    let message = LocoNetMessage(data: [LocoNetMessageOpcode.OPC_SW_REQ.rawValue, lo, hi], appendCheckSum: true)
    
    addToQueue(message: message)

  }
  
  public func setSwWithAck(switchNumber: Int, state:OptionSwitchState) {
    
    let sn = switchNumber - 1
    
    let lo = UInt8(sn & 0x7f)
    
    let bit : UInt8 = state == .closed ? 0x30 : 0x10
    
    let hi = UInt8(sn >> 7) | bit
    
    let message = LocoNetMessage(data: [LocoNetMessageOpcode.OPC_SW_ACK.rawValue, lo, hi], appendCheckSum: true)
    
    addToQueue(message: message)

  }
  */
  public func getLocoSlotDataP1(slotNumber: UInt8) {
    addToQueue(message: LocoNetMessage(data: [LocoNetMessageOpcode.OPC_RQ_SL_DATA.rawValue, slotNumber, 0x00], appendCheckSum: true))
  }
  
  public func getLocoSlotDataP2(bankNumber: UInt8, slotNumber: UInt8) {
    addToQueue(message: LocoNetMessage(data: [LocoNetMessageOpcode.OPC_RQ_SL_DATA.rawValue, slotNumber, bankNumber | 0b01000000], appendCheckSum: true))
  }

  public func getSwState(switchNumber: UInt16) {
    addToQueue(message: LocoNetMessage(data: [LocoNetMessageOpcode.OPC_SW_STATE.rawValue, UInt8((switchNumber - 1) & 0x7f), UInt8((switchNumber - 1) >> 7)], appendCheckSum: true))
  }
  
  public func setSw(switchNumber: UInt16, state:DCCSwitchState) {
    
    let lo = UInt8((switchNumber - 1) & 0x7f)
    
    let hi = UInt8((switchNumber - 1) >> 7) | (state == .closed ? 0x30 : 0x10)
    
    addToQueue(message: LocoNetMessage(data: [LocoNetMessageOpcode.OPC_SW_REQ.rawValue, lo, hi], appendCheckSum: true))

  }
  
  public func setSwWithAck(switchNumber: UInt16, state:DCCSwitchState) {
    
    let lo = UInt8((switchNumber - 1) & 0x7f)
    
    let hi = UInt8((switchNumber - 1) >> 7) | (state == .closed ? 0x30 : 0x10)
    
    addToQueue(message: LocoNetMessage(data: [LocoNetMessageOpcode.OPC_SW_ACK.rawValue, lo, hi], appendCheckSum: true))

  }

}
