//
//  LoconetSlot.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/11/2021.
//

import Foundation

public class LoconetSlot : NSObject {
  
  init(interfaceId:String, message:[UInt8]) {
    self.interfaceId = interfaceId
    super.init()
    load(message: message)
  }
  
  init(loconetMessage:LoconetMessage) {
    self.interfaceId = loconetMessage.interfaceId
    super.init()
    load(loconetMessage: loconetMessage)
  }
  
  public func load(message:[UInt8]) {
    var index : Int = LoconetSlotByte.slotNumber.rawValue
    while index <= LoconetSlotByte.expansionReservedId2.rawValue {
      slotData[index] = message[2 + index]
      index += 1
    }
  }
  
  public func load(loconetMessage:LoconetMessage) {
    load(message: loconetMessage.message)
  }
  
  public var interfaceId : String
  
  public var slotId : String {
    get {
      return "\(interfaceId)-\(String(format:"%02x",slotNumber))"
    }
  }
  
  public var slotData : [UInt8] = [UInt8](repeating: 0x00, count:11)

  public var slotNumber : UInt8 {
    get {
      return slotData[LoconetSlotByte.slotNumber.rawValue]
    }
    set(value) {
      slotData[LoconetSlotByte.slotNumber.rawValue] = value
    }
  }
  
  public var locoAddress : UInt16 {
    get {
      let highAddr = UInt16(slotData[LoconetSlotByte.slotLocoAdrHigh.rawValue])
      let lowAddr  = UInt16(slotData[LoconetSlotByte.slotLocoAdr.rawValue])
      return (highAddr << 7) | lowAddr
    }
    set(value) {
      slotData[LoconetSlotByte.slotLocoAdr.rawValue] = UInt8(value & 0x7f)
      slotData[LoconetSlotByte.slotLocoAdrHigh.rawValue] = UInt8(value >> 7)
    }
  }
  
  public var speedType : LoconetSlotSpeedType {
    get {
      return LoconetSlotSpeedType.init(rawValue: slotData[LoconetSlotByte.slotSpeed.rawValue]) ?? .speedIncreasing
    }
  }
  
  public var speed : UInt8 {
    get {
      return slotData[LoconetSlotByte.slotSpeed.rawValue]
    }
    set(value) {
      slotData[LoconetSlotByte.slotSpeed.rawValue] = value
    }
  }
  
  public var decoderType : LoconetDecoderType {
    get {
      let value = slotData[LoconetSlotByte.slotStatus1.rawValue] & loconetDecoderTypeMask
      return LoconetDecoderType.init(rawValue: value) ?? .unknown
    }
    set(value) {
      slotData[LoconetSlotByte.slotStatus1.rawValue] = (slotData[LoconetSlotByte.slotStatus1.rawValue] & ~loconetDecoderTypeMask) | value.rawValue
    }
  }
  
  public var locoUsage : LoconetLocoUsage {
    get {
      return LoconetLocoUsage.init(rawValue: slotData[LoconetSlotByte.slotStatus1.rawValue] & loconetLocoUsageMask) ?? .unknown
    }
    set(value) {
      slotData[LoconetSlotByte.slotStatus1.rawValue] = (slotData[LoconetSlotByte.slotStatus1.rawValue] & ~loconetLocoUsageMask) | value.rawValue
    }
  }
  
  public var progTrackBusy : Bool {
    get {
      return slotData[LoconetSlotByte.trk.rawValue] & loconetTrackProgBusyMask != 0x00
    }
    set(value) {
      slotData[LoconetSlotByte.trk.rawValue] = (slotData[LoconetSlotByte.trk.rawValue] & ~loconetTrackProgBusyMask) | (value ? loconetTrackProgBusyMask : 0x00)
    }
  }

  public var MLOK1 : Bool {
    get {
      return slotData[LoconetSlotByte.trk.rawValue] & loconetTrackMLOK1Mask != 0x00
    }
    set(value) {
      slotData[LoconetSlotByte.trk.rawValue] = (slotData[LoconetSlotByte.trk.rawValue] & ~loconetTrackMLOK1Mask) | (value ? loconetTrackMLOK1Mask : 0x00)
    }
  }

  public var trackPaused : Bool {
    get {
      return slotData[LoconetSlotByte.trk.rawValue] & loconetTrackIdleMask != 0x00
    }
    set(value) {
      slotData[LoconetSlotByte.trk.rawValue] = (slotData[LoconetSlotByte.trk.rawValue] & ~loconetTrackIdleMask) | (value ? loconetTrackIdleMask : 0x00)
    }
  }

  public var trackPower : Bool {
    get {
      return slotData[LoconetSlotByte.trk.rawValue] & loconetTrackPowerMask != 0x00
    }
    set(value) {
      slotData[LoconetSlotByte.trk.rawValue] = (slotData[LoconetSlotByte.trk.rawValue] & ~loconetTrackPowerMask) | (value ? loconetTrackPowerMask : 0x00)
    }
  }
  
  public var stateXCNT : Bool {
    get {
      return slotData[LoconetSlotByte.slotDirF.rawValue] & loconetDirFXCNTMask != 0x00
    }
    set(value) {
      slotData[LoconetSlotByte.slotDirF.rawValue] = (slotData[LoconetSlotByte.slotDirF.rawValue] & ~loconetDirFXCNTMask) | (value ? loconetDirFXCNTMask : 0x00)
    }
  }

  public var locoDirection : LoconetLocoDirection {
    get {
      return slotData[LoconetSlotByte.slotDirF.rawValue] & loconetDirFDirMask != 0x00 ? .forwards : .backwards
    }
    set(value) {
      slotData[LoconetSlotByte.slotDirF.rawValue] = (slotData[LoconetSlotByte.slotDirF.rawValue] & ~loconetDirFDirMask) | (value == .forwards ? loconetDirFDirMask : 0x00)
    }
  }
  
  public var stateF0 : Bool {
    get {
      return slotData[LoconetSlotByte.slotDirF.rawValue] & loconetDirFF0 != 0x00
    }
    set(value) {
      slotData[LoconetSlotByte.slotDirF.rawValue] = (slotData[LoconetSlotByte.slotDirF.rawValue] & ~loconetDirFF0) | (value ? loconetDirFF0 : 0x00)
    }
  }
  
  public var stateF4 : Bool {
    get {
      return slotData[LoconetSlotByte.slotDirF.rawValue] & loconetDirFF4 != 0x00
    }
    set(value) {
      slotData[LoconetSlotByte.slotDirF.rawValue] = (slotData[LoconetSlotByte.slotDirF.rawValue] & ~loconetDirFF4) | (value ? loconetDirFF4 : 0x00)
    }
  }
  
  public var stateF3 : Bool {
    get {
      return slotData[LoconetSlotByte.slotDirF.rawValue] & loconetDirFF3 != 0x00
    }
    set(value) {
      slotData[LoconetSlotByte.slotDirF.rawValue] = (slotData[LoconetSlotByte.slotDirF.rawValue] & ~loconetDirFF3) | (value ? loconetDirFF3 : 0x00)
    }
  }
  
  public var stateF2 : Bool {
    get {
      return slotData[LoconetSlotByte.slotDirF.rawValue] & loconetDirFF2 != 0x00
    }
    set(value) {
      slotData[LoconetSlotByte.slotDirF.rawValue] = (slotData[LoconetSlotByte.slotDirF.rawValue] & ~loconetDirFF2) | (value ? loconetDirFF2 : 0x00)
    }
  }
  
  public var stateF1 : Bool {
    get {
      return slotData[LoconetSlotByte.slotDirF.rawValue] & loconetDirFF1 != 0x00
    }
    set(value) {
      slotData[LoconetSlotByte.slotDirF.rawValue] = (slotData[LoconetSlotByte.slotDirF.rawValue] & ~loconetDirFF1) | (value ? loconetDirFF1 : 0x00)
    }
  }

  public var sound1 : Bool {
    get {
      return slotData[LoconetSlotByte.slotSound.rawValue] & loconetSnd1 != 0x00
    }
    set(value) {
      slotData[LoconetSlotByte.slotSound.rawValue] = (slotData[LoconetSlotByte.slotSound.rawValue] & ~loconetSnd1) | (value ? loconetSnd1 : 0x00)
    }
  }

  public var sound2 : Bool {
    get {
      return slotData[LoconetSlotByte.slotSound.rawValue] & loconetSnd2 != 0x00
    }
    set(value) {
      slotData[LoconetSlotByte.slotSound.rawValue] = (slotData[LoconetSlotByte.slotSound.rawValue] & ~loconetSnd2) | (value ? loconetSnd2 : 0x00)
    }
  }

  public var sound3 : Bool {
    get {
      return slotData[LoconetSlotByte.slotSound.rawValue] & loconetSnd3 != 0x00
    }
    set(value) {
      slotData[LoconetSlotByte.slotSound.rawValue] = (slotData[LoconetSlotByte.slotSound.rawValue] & ~loconetSnd3) | (value ? loconetSnd3 : 0x00)
    }
  }

  public var sound4 : Bool {
    get {
      return slotData[LoconetSlotByte.slotSound.rawValue] & loconetSnd4 != 0x00
    }
    set(value) {
      slotData[LoconetSlotByte.slotSound.rawValue] = (slotData[LoconetSlotByte.slotSound.rawValue] & ~loconetSnd4) | (value ? loconetSnd4 : 0x00)
    }
  }

}
