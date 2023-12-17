//
//  OpenLCBTractionListenerNode.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/06/2023.
//

import Foundation

public class OpenLCBTractionListenerNode {
  
  // MARK: Constructors
  
  init(nodeId:UInt64, flags:UInt8) {
  
    self.nodeId = nodeId
    self.flags = flags
    
  }
  
  // MARK: Private Properties
  
  private let mask_RevDirection : UInt8 = 0x02
  private let mask_LinkF0       : UInt8 = 0x04
  private let mask_LinkFN       : UInt8 = 0x08
  private let mask_Hide         : UInt8 = 0x80
  
  // MARK: Public Properties
  
  public var nodeId : UInt64
  
  public var flags : UInt8
  
  public var reverseDirection : Bool {
    get {
      return (flags & mask_RevDirection) == mask_RevDirection
    }
    set(value) {
      flags &= ~mask_RevDirection
      flags |= value ? mask_RevDirection : 0
    }
  }
  
  public var linkF0 : Bool {
    get {
      return (flags & mask_LinkF0) == mask_LinkF0
    }
    set(value) {
      flags &= ~mask_LinkF0
      flags |= value ? mask_LinkF0 : 0
    }
  }
  
  public var linkFN : Bool {
    get {
      return (flags & mask_LinkFN) == mask_LinkFN
    }
    set(value) {
      flags &= ~mask_LinkFN
      flags |= value ? mask_LinkFN : 0
    }
  }
  
  public var hide : Bool {
    get {
      return (flags & mask_Hide) == mask_Hide
    }
    set(value) {
      flags &= ~mask_Hide
      flags |= value ? mask_Hide : 0
    }
  }
  
}
