//
//  LocoNetExtensions.swift
//  MyTrains
//
//  Created by Paul Willmott on 02/07/2023.
//

import Foundation

extension LocoNet {
  
  // MARK: COMMAND STATION COMMANDS
  
  public func powerOn() {
    
    let message = LocoNetMessage(data: [LocoNetMessageOpcode.OPC_GPON.rawValue], appendCheckSum: true)
    
    addToQueue(message: message, spacingDelay: 0)

    getOpSwDataAP1()
    
  }
  
  public func powerOff() {
    
    let message = LocoNetMessage(data: [LocoNetMessageOpcode.OPC_GPOFF.rawValue], appendCheckSum: true)
    
    addToQueue(message: message, spacingDelay: 0)

    getOpSwDataAP1()
    
  }
  
  public func emergencyStop() {
    
    if commandStationType.idleSupportedByDefault {
      
      let message = LocoNetMessage(data: [LocoNetMessageOpcode.OPC_IDLE.rawValue], appendCheckSum: true)
      
      addToQueue(message: message, spacingDelay: 0)

      getOpSwDataAP1()
      
    }
    else {
      
      immPacket(packet: [DCCAddressPartition.dccIdle.rawValue, DCCPacketType.dccIdle.rawValue], repeatCount: 0x0f)
      
      globalEmergencyStop = true
      
    }
    
  }
  
  public func clearEmergencyStop() {
    
    if commandStationType.idleSupportedByDefault {
      
      powerOn()
      
    }
    else {
      
      immPacket(packet: [DCCAddressPartition.dccIdle.rawValue, DCCPacketType.dccIdle.rawValue], repeatCount: 0x00)

      globalEmergencyStop = false
      
    }
    
  }
  
  public func getOpSwDataAP1() {
    
    let message = LocoNetMessage(data: [LocoNetMessageOpcode.OPC_RQ_SL_DATA.rawValue, 0x7f, 0x00], appendCheckSum: true)
    
    addToQueue(message: message, spacingDelay: 0)

  }

  // MARK: HELPER COMMANDS
  
  public func immPacket(packet:[UInt8], repeatCount: Int) {
    
    guard packet.count < 6 && repeatCount < 0x10 else {
      print("invalid IMMPacket")
      return
    }
    
    let param : Int = ((packet.count << 4) | repeatCount) & 0x7f
    
    var payload : [UInt8] = [
      LocoNetMessageOpcode.OPC_IMM_PACKET.rawValue,
      0x0b,
      0x7f,
      UInt8(param),
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
    
    let message = LocoNetMessage(data: payload, appendCheckSum: true)
    
    addToQueue(message: message, spacingDelay: 0)

  }
  
  // MARK: LOCOMOTIVE CONTROL COMMANDS
  
  public func getLocoSlot(forAddress: UInt16) {

    if implementsProtocol2 {
      getLocoSlotDataP2(forAddress: forAddress)
    }
    else {
      getLocoSlotDataP1(forAddress: forAddress)
    }
    
  }

  public func getLocoSlotDataP1(forAddress: UInt16) {
    
    let lo = UInt8(forAddress & 0x7f)
    
    let hi = UInt8(forAddress >> 7)
    
    let message = LocoNetMessage(data: [LocoNetMessageOpcode.OPC_LOCO_ADR.rawValue, hi, lo], appendCheckSum: true)
    
    addToQueue(message: message, spacingDelay: 0)

  }
  
  public func getLocoSlotDataP2(forAddress: UInt16) {
    
    let lo = UInt8(forAddress & 0x7f)
    
    let hi = UInt8(forAddress >> 7)
    
    let message = LocoNetMessage(data: [LocoNetMessageOpcode.OPC_LOCO_ADR_P2.rawValue, hi, lo], appendCheckSum: true)
    
    addToQueue(message: message, spacingDelay: 0)

  }
  
  public func setLocoSlotStat1(slotPage:UInt8, slotNumber:UInt8, stat1:UInt8) {
    
    if implementsProtocol2 {
      setLocoSlotStat1P2(slotPage: slotPage, slotNumber: slotNumber, stat1: stat1)
    }
    else {
      setLocoSlotStat1P1(slotNumber: slotNumber, stat1: stat1)
    }
    
  }
  
  public func setLocoSlotStat1P1(slotNumber:UInt8, stat1:UInt8) {

    guard slotNumber > 0 && slotNumber < 120 else {
      return
    }
    
    let message = LocoNetMessage(data: [LocoNetMessageOpcode.OPC_SLOT_STAT1.rawValue, UInt8(slotNumber), stat1], appendCheckSum: true)

    addToQueue(message: message, spacingDelay: 0)

  }
  
  public func setLocoSlotStat1P2(slotPage:UInt8, slotNumber:UInt8, stat1:UInt8) {

    let page : UInt8 = 0b00111000 | UInt8(slotPage & 0b00000111)
    
    let message = LocoNetMessage(data: [LocoNetMessageOpcode.OPC_D4_GROUP.rawValue, page, UInt8(slotNumber & 0x7f), 0x60, stat1], appendCheckSum: true)

    addToQueue(message: message, spacingDelay: 0)

  }
   
  public func moveSlotsP1(sourceSlotNumber: UInt8, destinationSlotNumber: UInt8) {
    
    let message = LocoNetMessage(data: [LocoNetMessageOpcode.OPC_MOVE_SLOTS.rawValue, UInt8(sourceSlotNumber), UInt8(destinationSlotNumber)], appendCheckSum: true)
    
    addToQueue(message: message, spacingDelay: 0)

  }
  
  public func moveSlotsP2(sourceSlotNumber: UInt8, sourceSlotPage: UInt8, destinationSlotNumber: UInt8, destinationSlotPage: UInt8) {
    
    let srcPage = UInt8(sourceSlotPage & 0b00000111) | 0b00111000
    let dstPage = UInt8(destinationSlotPage & 0b00000111)
    
    let message = LocoNetMessage(data: [LocoNetMessageOpcode.OPC_D4_GROUP.rawValue, srcPage, UInt8(sourceSlotNumber), dstPage, UInt8(destinationSlotNumber)], appendCheckSum: true)
    
    addToQueue(message: message, spacingDelay: 0)

  }
  
  public func setLocomotiveState(address:UInt16, slotNumber: UInt8, slotPage: UInt8, nextState:LocoNetLocomotiveState, throttleID: UInt16) -> LocomotiveStateWithTimeStamp {
    
    var next = nextState.functions

    let timeStamp = Date.timeIntervalSinceReferenceDate
      
    if implementsProtocol2 {
        
      locoSpdDirP2(slotNumber: slotNumber, slotPage: slotPage, speed: nextState.speed, direction: nextState.direction, throttleID: throttleID)

      locoF0F6P2(slotNumber:   slotNumber, slotPage: slotPage, functions: next, throttleID: throttleID)
      locoF7F13P2(slotNumber:  slotNumber, slotPage: slotPage, functions: next, throttleID: throttleID)
      locoF14F20P2(slotNumber: slotNumber, slotPage: slotPage, functions: next, throttleID: throttleID)
      locoF21F28P2(slotNumber: slotNumber, slotPage: slotPage, functions: next, throttleID: throttleID)

    }
    else {
      
      locoSpdP1(slotNumber: slotNumber, speed: nextState.speed)

      locoDirF0F4P1(slotNumber: slotNumber, direction: nextState.direction, functions: next)
      
      if implementsProtocol1 {
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
    
    if implementsProtocol2 {
      
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
        
        if implementsProtocol1 {
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

  public func locoSpdDirP2(slotNumber: UInt8, slotPage: UInt8, speed: UInt8, direction: LocomotiveDirection, throttleID: UInt16) {
    
    let data : [UInt8] = [
      LocoNetMessageOpcode.OPC_D5_GROUP.rawValue,
      (slotPage & 0x07) | (direction == .reverse ? 0b00001000 : 0b00000000),
      slotNumber & 0x7f,
      UInt8(throttleID & 0x7f),
      speed & 0x7f
    ]
    
    let message = LocoNetMessage(data: data, appendCheckSum: true)
    
    addToQueue(message: message, spacingDelay: 0)

  }
  
  public func locoSpdP1(slotNumber: UInt8, speed: UInt8) {
    
    let data : [UInt8] = [
      LocoNetMessageOpcode.OPC_LOCO_SPD.rawValue,
      slotNumber & 0x7f,
      speed & 0x7f
    ]
    
    let message = LocoNetMessage(data: data, appendCheckSum: true)
    
    addToQueue(message: message, spacingDelay: 0)

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
    
    let message = LocoNetMessage(data: data, appendCheckSum: true)
    
    addToQueue(message: message, spacingDelay: 0)

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

    let message = LocoNetMessage(data: data, appendCheckSum: true)
    
    addToQueue(message: message, spacingDelay: 0)

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

    let message = LocoNetMessage(data: data, appendCheckSum: true)
    
    addToQueue(message: message, spacingDelay: 0)

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

    let message = LocoNetMessage(data: data, appendCheckSum: true)
    
    addToQueue(message: message, spacingDelay: 0)

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
    
    let message = LocoNetMessage(data: data, appendCheckSum: true)
    
    addToQueue(message: message, spacingDelay: 0)

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
    
    let message = LocoNetMessage(data: data, appendCheckSum: true)
    
    addToQueue(message: message, spacingDelay: 0)

  }
  
  internal func dccAddress(address:UInt16) -> [UInt8] {
    
    if address < 128 {
      return [UInt8(address)]
    }
    
    let temp = Int(address) + 49152
    
    return [UInt8(temp >> 8), UInt8(temp & 0xff)]
    
  }
  
  public func dccF5F8(address:UInt16, functions: UInt64) {
    
    var fx : UInt8 = DCCPacketType.dccF5F8.rawValue
    
    fx |= functions & maskF5 == maskF5 ? 0b00000001 : 0b00000000
    fx |= functions & maskF6 == maskF6 ? 0b00000010 : 0b00000000
    fx |= functions & maskF7 == maskF7 ? 0b00000100 : 0b00000000
    fx |= functions & maskF8 == maskF8 ? 0b00001000 : 0b00000000
    
    var data : [UInt8] = dccAddress(address: address)
    
    data.append(fx)
    
    immPacket(packet: data, repeatCount: 4)
    
  }

  public func dccF9F12(address:UInt16, functions: UInt64) {
    
    var fx : UInt8 = DCCPacketType.dccF9F12.rawValue
    
    fx |= functions & maskF9  == maskF9  ? 0b00000001 : 0b00000000
    fx |= functions & maskF10 == maskF10 ? 0b00000010 : 0b00000000
    fx |= functions & maskF11 == maskF11 ? 0b00000100 : 0b00000000
    fx |= functions & maskF12 == maskF12 ? 0b00001000 : 0b00000000
    
    var data : [UInt8] = dccAddress(address: address)
    
    data.append(fx)
    
    immPacket(packet: data, repeatCount: 4)
    
  }

  public func dccF13F20(address:UInt16, functions: UInt64) {
    
    var fx : UInt8 = 0
    
    fx |= functions & maskF13 == maskF13 ? 0b00000001 : 0b00000000
    fx |= functions & maskF14 == maskF14 ? 0b00000010 : 0b00000000
    fx |= functions & maskF15 == maskF15 ? 0b00000100 : 0b00000000
    fx |= functions & maskF16 == maskF16 ? 0b00001000 : 0b00000000
    fx |= functions & maskF17 == maskF17 ? 0b00010000 : 0b00000000
    fx |= functions & maskF18 == maskF18 ? 0b00100000 : 0b00000000
    fx |= functions & maskF19 == maskF19 ? 0b01000000 : 0b00000000
    fx |= functions & maskF20 == maskF20 ? 0b10000000 : 0b00000000

    var data : [UInt8] = dccAddress(address: address)
    
    data.append(DCCPacketType.dccF13F20.rawValue)
    data.append(fx)
    
    immPacket(packet: data, repeatCount: 4)
    
  }

  public func dccF21F28(address:UInt16, functions: UInt64) {
    
    var fx : UInt8 = 0
    
    fx |= functions & maskF21 == maskF21 ? 0b00000001 : 0b00000000
    fx |= functions & maskF22 == maskF22 ? 0b00000010 : 0b00000000
    fx |= functions & maskF23 == maskF23 ? 0b00000100 : 0b00000000
    fx |= functions & maskF24 == maskF24 ? 0b00001000 : 0b00000000
    fx |= functions & maskF25 == maskF25 ? 0b00010000 : 0b00000000
    fx |= functions & maskF26 == maskF26 ? 0b00100000 : 0b00000000
    fx |= functions & maskF27 == maskF27 ? 0b01000000 : 0b00000000
    fx |= functions & maskF28 == maskF28 ? 0b10000000 : 0b00000000

    var data : [UInt8] = dccAddress(address: address)
    
    data.append(DCCPacketType.dccF21F28.rawValue)
    data.append(fx)
    
    immPacket(packet: data, repeatCount: 4)
    
  }

  public func dccF29F36(address:UInt16, functions: UInt64) {
    
    var fx : UInt8 = 0
    
    fx |= functions & maskF29 == maskF29 ? 0b00000001 : 0b00000000
    fx |= functions & maskF30 == maskF30 ? 0b00000010 : 0b00000000
    fx |= functions & maskF31 == maskF31 ? 0b00000100 : 0b00000000
    fx |= functions & maskF32 == maskF32 ? 0b00001000 : 0b00000000
    fx |= functions & maskF33 == maskF33 ? 0b00010000 : 0b00000000
    fx |= functions & maskF34 == maskF34 ? 0b00100000 : 0b00000000
    fx |= functions & maskF35 == maskF35 ? 0b01000000 : 0b00000000
    fx |= functions & maskF36 == maskF36 ? 0b10000000 : 0b00000000

    var data : [UInt8] = dccAddress(address: address)
    
    data.append(DCCPacketType.dccF29F36.rawValue)
    data.append(fx)
    
    immPacket(packet: data, repeatCount: 4)
    
  }

  public func dccF37F44(address:UInt16, functions: UInt64) {
    
    var fx : UInt8 = 0
    
    fx |= functions & maskF37 == maskF37 ? 0b00000001 : 0b00000000
    fx |= functions & maskF38 == maskF38 ? 0b00000010 : 0b00000000
    fx |= functions & maskF39 == maskF39 ? 0b00000100 : 0b00000000
    fx |= functions & maskF40 == maskF40 ? 0b00001000 : 0b00000000
    fx |= functions & maskF41 == maskF41 ? 0b00010000 : 0b00000000
    fx |= functions & maskF42 == maskF42 ? 0b00100000 : 0b00000000
    fx |= functions & maskF43 == maskF43 ? 0b01000000 : 0b00000000
    fx |= functions & maskF44 == maskF44 ? 0b10000000 : 0b00000000

    var data : [UInt8] = dccAddress(address: address)
    
    data.append(DCCPacketType.dccF37F44.rawValue)
    data.append(fx)
    
    immPacket(packet: data, repeatCount: 4)
    
  }

  public func dccF45F52(address:UInt16, functions: UInt64) {
    
    var fx : UInt8 = 0
    
    fx |= functions & maskF45 == maskF45 ? 0b00000001 : 0b00000000
    fx |= functions & maskF46 == maskF46 ? 0b00000010 : 0b00000000
    fx |= functions & maskF47 == maskF47 ? 0b00000100 : 0b00000000
    fx |= functions & maskF48 == maskF48 ? 0b00001000 : 0b00000000
    fx |= functions & maskF49 == maskF49 ? 0b00010000 : 0b00000000
    fx |= functions & maskF50 == maskF50 ? 0b00100000 : 0b00000000
    fx |= functions & maskF51 == maskF51 ? 0b01000000 : 0b00000000
    fx |= functions & maskF52 == maskF52 ? 0b10000000 : 0b00000000

    var data : [UInt8] = dccAddress(address: address)
    
    data.append(DCCPacketType.dccF45F52.rawValue)
    data.append(fx)
    
    immPacket(packet: data, repeatCount: 4)
    
  }

  public func dccF53F60(address:UInt16, functions: UInt64) {
    
    var fx : UInt8 = 0
    
    fx |= functions & maskF53 == maskF53 ? 0b00000001 : 0b00000000
    fx |= functions & maskF54 == maskF54 ? 0b00000010 : 0b00000000
    fx |= functions & maskF55 == maskF55 ? 0b00000100 : 0b00000000
    fx |= functions & maskF56 == maskF56 ? 0b00001000 : 0b00000000
    fx |= functions & maskF57 == maskF57 ? 0b00010000 : 0b00000000
    fx |= functions & maskF58 == maskF58 ? 0b00100000 : 0b00000000
    fx |= functions & maskF59 == maskF59 ? 0b01000000 : 0b00000000
    fx |= functions & maskF60 == maskF60 ? 0b10000000 : 0b00000000

    var data : [UInt8] = dccAddress(address: address)
    
    data.append(DCCPacketType.dccF53F60.rawValue)
    data.append(fx)
    
    immPacket(packet: data, repeatCount: 4)
    
  }

  public func dccF61F68(address:UInt16, functions: UInt64) {
    
    var fx : UInt8 = 0
    
    fx |= functions & maskF61 == maskF61 ? 0b00000001 : 0b00000000
    fx |= functions & maskF62 == maskF62 ? 0b00000010 : 0b00000000
    fx |= functions & maskF63 == maskF63 ? 0b00000100 : 0b00000000
    fx |= functions & maskF64 == maskF64 ? 0b00001000 : 0b00000000
    fx |= functions & maskF65 == maskF65 ? 0b00010000 : 0b00000000
    fx |= functions & maskF66 == maskF66 ? 0b00100000 : 0b00000000
    fx |= functions & maskF67 == maskF67 ? 0b01000000 : 0b00000000
    fx |= functions & maskF68 == maskF68 ? 0b10000000 : 0b00000000

    var data : [UInt8] = dccAddress(address: address)
    
    data.append(DCCPacketType.dccF61F68.rawValue)
    data.append(fx)
    
    immPacket(packet: data, repeatCount: 4)
    
  }

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
    
    immPacket(packet: data, repeatCount: 4)
    
  }

  public func dccAnalogFunction(address:UInt16, analogOutput:UInt8, value:UInt8) {
    
    var data : [UInt8] = dccAddress(address: address)

    data.append(contentsOf: [
      DCCPacketType.dccAnalogFunction.rawValue,
      analogOutput,
      value
    ])
    
    immPacket(packet: data, repeatCount: 4)
    
  }

}
