//
//  OpenLCBMessage.swift
//  MyTrains
//
//  Created by Paul Willmott on 08/04/2023.
//

import Foundation

public class OpenLCBMessage : NSObject {
  
  // MARK: Constructors
  
  init(messageTypeIndicator: OpenLCBMTI) {
    
    self.messageTypeIndicator = messageTypeIndicator
    
    self.canFrameType = .globalAndAddressedMTI
    
    super.init()
    
  }
  
  init?(fullMessage:[UInt8]) {
    
    var data = fullMessage
    
    guard data.count >= 29 else {
      #if DEBUG
      debugLog("decode error \(data.count)")
      #endif
      return nil
    }
    
    guard let vis = OpenLCBNodeVisibility(rawValue: data[0]) else {
      return nil
    }

    visibility = vis
    
    data.removeFirst()
    
    guard let nodeCount = UInt64(bigEndianData: [UInt8](data.prefix(6))) else {
      return nil
    }
    
    data.removeFirst(6)
    
    for _ in 1 ... nodeCount {
      let id = UInt64(bigEndianData: [UInt8](data.prefix(6)))!
      routing.insert(id)
      data.removeFirst(6)
    }
    
    guard let temp = UInt64(bigEndianData: [UInt8](data.prefix(8))) else {
      return nil
    }
    
    timeStamp = Double(bitPattern: temp)
    
    data.removeFirst(8)

    guard let temp = UInt16(bigEndianData: [UInt8](data.prefix(2))), let mti = OpenLCBMTI(rawValue: temp) else {
      return nil
    }
    
    messageTypeIndicator = mti

    data.removeFirst(2)

    canFrameType = messageTypeIndicator == .datagram ? .datagramCompleteInFrame : .globalAndAddressedMTI

    guard let sid = UInt64(bigEndianData: [UInt8](data.prefix(6))) else {
      return nil
    }
    
    sourceNodeId = sid
    
    data.removeFirst(6)
    
    if messageTypeIndicator.isAddressPresent {
      
      guard let did = UInt64(bigEndianData: [UInt8](data.prefix(6))) else {
        return nil
      }
      
      destinationNodeId = did
      
      data.removeFirst(6)
      
    }
    
    if messageTypeIndicator.isEventPresent {

      guard let eid = UInt64(bigEndianData: [UInt8](data.prefix(8))) else {
        return nil
      }
      
      eventId = eid
      
      data.removeFirst(8)

    }
    
    payload = data
    
  }
  
  init?(frame:LCCCANFrame) {
    
    guard let canFrameType = frame.openLCBMessageCANFrameType else {
      return nil
    }

    self.timeStamp = frame.timeStamp
    
    self.canFrameType = canFrameType
    
    switch canFrameType {
      
    case .globalAndAddressedMTI:
      
      messageTypeIndicator = frame.messageTypeIndicator!
      
      sourceNIDAlias = UInt16(frame.header & 0xfff)
      
      payload = frame.data
      
      if payload.count >= 2 {
        
        if messageTypeIndicator.isAddressPresent && payload.count >= 2, let alias = UInt16(bigEndianData: [payload[0] & 0x0f, payload[1]]) {
          destinationNIDAlias = alias
          flags = OpenLCBCANFrameFlag(rawValue: (payload[0] & 0x30) >> 4)!
          payload.removeFirst(2)
        }
        
        if messageTypeIndicator.isEventPresent && payload.count >= 2, let eventPrefix = UInt16(bigEndianData: [payload[0], payload[1]]) {
          switch eventPrefix {
          default:
            if let id = UInt64(bigEndianData: [UInt8](payload.prefix(8))) {
              eventId = id
              payload.removeFirst(8)
            }
          }
        }
      }
      
    case .datagramCompleteInFrame, .datagramFirstFrame, .datagramMiddleFrame, .datagramFinalFrame:
      
      messageTypeIndicator = .datagram
      sourceNIDAlias = UInt16(frame.header & 0xfff)
      destinationNIDAlias = UInt16((frame.header & 0xfff000) >> 12)
      payload = frame.data

    default:
      return nil
    }
    
    super.init()
    
  }
  
  deinit {
    payload.removeAll()
  }
  
  // MARK: Public Properties
  
  public var messageTypeIndicator : OpenLCBMTI
  
  public var canFrameType : OpenLCBMessageCANFrameType

  public var timeStamp : TimeInterval = 0
  
  public var routing : Set<UInt64> = []
  
  public var visibility : OpenLCBNodeVisibility = .visibilityPublic
  
  public var sourceNodeId : UInt64?
  
  public var sourceNIDAlias : UInt16?
  
  public var destinationNodeId : UInt64?
  
  public var destinationNIDAlias : UInt16?

  public var flags : OpenLCBCANFrameFlag = .onlyFrame
  
  public var eventId : UInt64?
  
  public var payload : [UInt8] = []
  
  public var datagramType : OpenLCBDatagramType? {
    
    guard messageTypeIndicator == .datagram && payload.count >= 2, let rawValue = UInt16(bigEndianData: [UInt8](payload.prefix(2))) else {
      return nil
    }
    
    return OpenLCBDatagramType(rawValue: rawValue)
    
  }
  
  public var datagramReplyTimeOut : OpenLCBDatagramTimeout? {

    guard messageTypeIndicator == .datagramReceivedOK else {
      return nil
    }
    
    var flags : UInt8 = 0
    
    if payload.count > 0 {
      flags = payload[0]
    }
    
    return OpenLCBDatagramTimeout(rawValue: flags & 0x8f)

  }
  
  public var isLocationServicesEvent : Bool {
    guard messageTypeIndicator == .producerConsumerEventReport, let eventId else {
      return false
    }
    return (eventId & 0xffff000000000000) == 0x0102000000000000
  }
  
  public var scannerNodeId : UInt64? {
    if isLocationServicesEvent, let eventId {
      return eventId & 0x0000ffffffffffff
    }
    return nil
  }
  
  public var locationServicesFlags : UInt16? {
    if isLocationServicesEvent {
      return UInt16(bigEndianData: [payload[0], payload[1]])
    }
    return nil
  }
  
  public var locationServicesFlagEntryExit : OpenLCBLocationServiceFlagEntryExit? {
    if isLocationServicesEvent, let locationServicesFlags {
      return OpenLCBLocationServiceFlagEntryExit(rawValue: locationServicesFlags & OpenLCBLocationServiceFlagEntryExit.mask)
    }
    return nil
  }
    
  public var locationServicesFlagDirectionRelative : OpenLCBLocationServiceFlagDirectionRelative? {
    if isLocationServicesEvent, let locationServicesFlags {
      return OpenLCBLocationServiceFlagDirectionRelative(rawValue: locationServicesFlags & OpenLCBLocationServiceFlagDirectionRelative.mask)
    }
    return nil
  }
  
  public var locationServicesFlagDirectionAbsolute : OpenLCBLocationServiceFlagDirectionAbsolute? {
    if isLocationServicesEvent, let locationServicesFlags {
      return OpenLCBLocationServiceFlagDirectionAbsolute(rawValue: locationServicesFlags & OpenLCBLocationServiceFlagDirectionAbsolute.mask)
    }
    return nil
  }
  
  public var locationServicesFlagContentFormat : OpenLCBLocationServiceFlagContentFormat? {
    if isLocationServicesEvent, let locationServicesFlags {
      return OpenLCBLocationServiceFlagContentFormat(rawValue: locationServicesFlags & OpenLCBLocationServiceFlagContentFormat.mask)
    }
    return nil
  }
  
  public var trainNodeId : UInt64? {
    if isLocationServicesEvent {
      var id : [UInt8] = []
      for index in 2 ... 7 {
        id.append(payload[index])
      }
      let idNumber = UInt64(bigEndianData: id)
      return idNumber
    }
    return nil
  }
  
  public var locationServicesContent : [OpenLCBLocationServicesContentBlock]? {
    if isLocationServicesEvent, let locationServicesFlagContentFormat, locationServicesFlagContentFormat == .standardContentForm {
      var result : [OpenLCBLocationServicesContentBlock] = []
      var data = payload
      data.removeFirst(8)
      while !data.isEmpty {
        let length = Int(data.removeFirst())
        if length > 0 , let blockType = OpenLCBStandardContentBlockType(rawValue: data.removeFirst()) {
          let block : OpenLCBLocationServicesContentBlock = (blockType:blockType, content:[UInt8](data.prefix(length - 1)))
          result.append(block)
          data.removeFirst(length - 1)
        }
      }
      return result
    }
    return nil
  }
  
  public var datagramId : UInt32 {
    return (UInt32(destinationNIDAlias!) << 12) | UInt32(sourceNIDAlias!)
  }

  public var datagramIdReversed : UInt32 {
    return (UInt32(sourceNIDAlias!) << 12) | UInt32(destinationNIDAlias!)
  }

  public var errorCode : UInt16 {
    return UInt16(bigEndianData: [UInt8](payload.prefix(2))) ?? 0
  }

  public var error : OpenLCBErrorCode {
    return OpenLCBErrorCode(rawValue: errorCode)!
  }

  public var rwReplyFailureErrorCode : OpenLCBErrorCode {
    if datagramType == .readReplyFailureGeneric || datagramType == .writeReplyFailureGeneric {
      if let error = UInt16(bigEndianData: [payload[payload.count - 2], payload[payload.count - 1]]) {
        return OpenLCBErrorCode(rawValue: error)!
      }
    }
    return .success
  }

  public var isAutomaticallyRoutedEvent : Bool {
    if messageTypeIndicator == .producerConsumerEventReport {
      let auto : UInt64 = 0x0100000000000000
      let mask : UInt64 = 0xffff000000000000
      return (eventId! & mask) == auto
    }
    return false
  }
  
  public var eventRange : EventRange? {
      
    guard let eventId else {
      return nil
    }
    
    return EventRange(eventId: eventId)
    
  }
  
  public var payloadAsHex : String {
    get {
      var result = ""
      for byte in payload {
        result += byte.hex()
      }
      return result
    }
  }
  
  public var info : String {
    
    let padding = String(repeating: " ", count: 41)

    var text = ""
    
    if let sourceNodeId {
      text += "\(sourceNodeId.dotHex(numberOfBytes: 6)!) "
    }
    if let destinationNodeId {
      text += " → \(destinationNodeId.dotHex(numberOfBytes: 6)!) "
    }
    
 //   text += String(repeating: " ", count: 39 - text.count)
    
    text += "\(messageTypeIndicator.title) "

    if messageTypeIndicator.isEventPresent, let eventId {
      if let event = OpenLCBWellKnownEvent(rawValue: eventId) {
        text += "\"\(event.title)\" "
      }
      else {
        text += "\(eventId.dotHex(numberOfBytes: 8)!) "
      }
    }
    
    switch messageTypeIndicator {
      
    case .datagramReceivedOK:
      
      let replyCode = payload.count == 0 ? 0 : payload[0]
      
      if let timeout = OpenLCBDatagramTimeout(rawValue: replyCode) {
        switch timeout {
        case .ok:
          text += "no reply pending "
        case .replyPendingNoTimeout:
          text += "reply pending "
        default:
          text += "reply pending with timeout \(timeout.timeout!)s "
        }
      }
      
    case .datagram:
      if let datagramType {
        text += "\(datagramType.title) "
        switch datagramType {
        case .writeUnderMaskCommandGeneric:
          break
        case .writeUnderMaskCommand0xFD:
          break
        case .writeUnderMaskCommand0xFE:
          break
        case .writeUnderMaskCommand0xFF:
          break
        case .writeStreamCommandGeneric:
          break
        case .writeStreamCommand0xFD:
          break
        case .writeStreamCommand0xFE:
          break
        case .writeStreamCommand0xFF:
          break
        case .writeStreamReplyGeneric:
          break
        case .writeStreamReply0xFD:
          break
        case .writeStreamReply0xFE:
          break
        case .writeStreamReply0xFF:
          break
        case .writeStreamReplyFailureGeneric:
          break
        case .writeStreamReplyFailure0xFD:
          break
        case .writeStreamReplyFailure0xFE:
          break
        case .writeStreamReplyFailure0xFF:
          break
        case .writeReplyGeneric, .writeReply0xFD, .writeReply0xFE, .writeReply0xFF:

          var space : UInt8
          
          switch datagramType {
          case .writeReply0xFD:
            space = 0xfd
          case .writeReply0xFE:
            space = 0xfe
          case .writeReply0xFF:
            space = 0xff
          default:
            space = payload[6]
          }
          
          let startAddress = UInt32(bigEndianData: [payload[2], payload[3], payload[4], payload[5]])!
                                                    
          text += "\(space.hex()) \(startAddress.hex(numberOfBytes: 4)!)"
          
        case .readCommand0xFD, .readCommand0xFE, .readCommand0xFF, .readCommandGeneric:
          
          var space : UInt8
          
          switch datagramType {
          case .readCommand0xFD:
            space = 0xfd
          case .readCommand0xFE:
            space = 0xfe
          case .readCommand0xFF:
            space = 0xff
          default:
            space = payload[6]
          }
          
          let startAddress = UInt32(bigEndianData: [payload[2], payload[3], payload[4], payload[5]])!
                                                    
          let count = payload[datagramType == .readCommandGeneric ? 7 : 6]
          
          text += "\(space.hex()) \(startAddress.hex(numberOfBytes: 4)!) \(count)"
          
        case .readReply0xFD, .readReply0xFE, .readReply0xFF, .readReplyGeneric, .writeCommandGeneric, .writeCommand0xFD, .writeCommand0xFE, .writeCommand0xFF:

          var space : UInt8
          
          switch datagramType {
          case .readReply0xFD, .writeCommand0xFD:
            space = 0xfd
          case .readReply0xFE, .writeCommand0xFE:
            space = 0xfe
          case .readReply0xFF, .writeCommand0xFF:
            space = 0xff
          default:
            space = payload[6]
          }

          let startAddress = UInt32(bigEndianData: [payload[2], payload[3], payload[4], payload[5]])!
          
          var data : [UInt8] = []
          
          for index in Int((space < 0xfd) ? 7 : 6) ... payload.count - 1 {
            data.append(payload[index])
          }
          
          text += hexDump(space: space, startAddress: startAddress, data: data)

        case .readReplyFailure0xFD, .readReplyFailure0xFE, .readReplyFailure0xFF, .readReplyFailureGeneric, .writeReplyFailureGeneric, .writeReplyFailure0xFD, .writeReplyFailure0xFE, .writeReplyFailure0xFF:

          var space : UInt8
          
          switch datagramType {
          case .readReplyFailure0xFD, .writeReplyFailure0xFD:
            space = 0xfd
          case .readReplyFailure0xFE, .writeReplyFailure0xFE:
            space = 0xfe
          case .readReplyFailure0xFF, .writeReplyFailure0xFF:
            space = 0xff
          default:
            space = payload[6]
          }

          let startAddress = UInt32(bigEndianData: [payload[2], payload[3], payload[4], payload[5]])!
          
          let index = space < 0xfd ? 7 : 6
          
          text += "\(space.hex()) \(startAddress.hex(numberOfBytes: 4)!) "
          
          if let errorCode = UInt16(bigEndianData: [UInt8]([payload[index], payload[index + 1]])) {
            if let error = OpenLCBErrorCode(rawValue: errorCode) {
              text += "\"\(error.title)\""
            }
            else {
              text += "0x\(errorCode.hex(numberOfBytes: 2)!)"
            }
          }

        case .readStreamCommandGeneric:
          break
        case .readStreamCommand0xFD:
          break
        case .readStreamCommand0xFE:
          break
        case .readStreamCommand0xFF:
          break
        case .readStreamReplyGeneric:
          break
        case .readStreamReply0xFD:
          break
        case .readStreamReply0xFE:
          break
        case .readStreamReply0xFF:
          break
        case .readStreamReplyFailureGeneric:
          break
        case .readStreamReplyFailure0xFD:
          break
        case .readStreamReplyFailure0xFE:
          break
        case .readStreamReplyFailure0xFF:
          break
        case .getConfigurationOptionsCommand:
          break
        case .getConfigurationOptionsReply:
          break
        case .getAddressSpaceInformationCommand:
          text += "\(payload[2].hex())"
          
        case .getAddressSpaceInformationReply, .getAddressSpaceInformationReplyLowAddressPresent:
 
          let highestAddress = UInt32(bigEndianData: [payload[3], payload[4], payload[5], payload[6]])!
          
          let space = payload[2]
          
          let flags = payload.count >= 8 ? payload[7] : 0

          let mask : UInt8 = 0b00000001
          
          var lowestAddress : UInt32 = 0
          
          if flags & mask == mask {
            lowestAddress = UInt32(bigEndianData: [payload[8], payload[9], payload[10], payload[11]])!
          }
          
          text += "\(space.hex()) \(lowestAddress.hex(numberOfBytes: 4)!) \(highestAddress.hex(numberOfBytes: 4)!) \(flags.hex()) "
          
        case .lockReserveCommand, .lockReserveReply:
          
          var data = payload
          data.removeFirst(2)
          
          let nodeId = UInt64(bigEndianData: [UInt8](data.prefix(6)))!
          
          text += "\(nodeId.dotHex(numberOfBytes: 6)!) "
          
        case .getUniqueEventIDCommand:
          
          let number = payload.count > 2 ? payload[2] : 0x00
          
          text += "\(number) "
          
        case .getUniqueEventIDReply:
          
          var data = payload
          data.removeFirst(2)
          
          let number = data.count / 8
          
          if number > 0 {
            
            for _ in 1 ... number {
              let eventId = UInt64(bigEndianData: [UInt8](data.prefix(8)))!
              text += "\n\(padding) \(eventId.dotHex(numberOfBytes: 8)!)"
              data.removeFirst(8)
            }
            
          }
          
        case .unfreezeCommand, .freezeCommand:
          
          text += "\(payload[2].hex())"
          
        case .updateCompleteCommand:
          break
        case .resetRebootCommand:
          break
        case .reinitializeFactoryResetCommand:
          var data = payload
          data.removeFirst(2)
          let nodeId = UInt64(bigEndianData: [UInt8](data.prefix(6)))!
          text += "\(nodeId.dotHex(numberOfBytes: 6)!)"
        }
      }
      else {
        text += String(localized: "Datagram Type Unknown: \(UInt16(bigEndianData: [UInt8](payload.prefix(2)))!.hex(numberOfBytes: 2)!) ")
      }
    case .datagramRejected:
      var temp = payload
      temp.append(contentsOf: [0,0])
      if let errorCode = UInt16(bigEndianData: [UInt8](temp.prefix(2))) {
        if let error = OpenLCBErrorCode(rawValue: errorCode) {
          text += "\"\(error.title)\""
        }
        else {
          text += "\(errorCode.hex(numberOfBytes: 2)!)"
        }
      }
      
    case .initializationCompleteSimpleSetSufficient, .initializationCompleteFullProtocolRequired, .verifiedNodeIDSimpleSetSufficient, .verifiedNodeIDFullProtocolRequired:
      text += "\(UInt64(bigEndianData: payload)!.dotHex(numberOfBytes: 6)!)"
    
    case .verifyNodeIDGlobal, .verifyNodeIDAddressed:
      
      if !payload.isEmpty {
        let nodeId = UInt64(bigEndianData: payload)!
        text += "\(nodeId.dotHex(numberOfBytes: 6)!) "
      }
      
    case .optionalInteractionRejected, .terminateDueToError:
      
      var data = payload
      
      if let errorCode = UInt16(bigEndianData: [UInt8](data.prefix(2))) {
        if let error = OpenLCBErrorCode(rawValue: errorCode) {
          text += "\"\(error.title)\" "
        }
        else {
          text += "\(errorCode.hex(numberOfBytes: 2)!) "
        }
      }
      
      data.removeFirst(2)
      
      let mti = UInt16(bigEndianData: [UInt8](data.prefix(2)))!
      
      text += "\(mti.hex(numberOfBytes: 2)!) "
      
      data.removeFirst(2)
      
      for byte in data {
        text += "\(byte.hex()) "
      }
      
    case .simpleNodeIdentInfoReply:
      
      let node = OpenLCBNode(nodeId: 0)
      node.encodedNodeInformation = payload
      text += "\n\(padding)\"\(node.manufacturerName)\",\"\(node.nodeModelName)\",\"\(node.nodeHardwareVersion)\",\"\(node.nodeSoftwareVersion)\",\"\(node.userNodeName)\",\"\(node.userNodeDescription)\""
    
    case .protocolSupportReply:
      
      for byte in payload {
        text += "\(byte.hex()) "
      }

    case .identifyEventsAddressed:
      
      if let nodeId = UInt64(bigEndianData: payload) {
        text += "\(nodeId.dotHex(numberOfBytes: 6)!) "
      }
      else {
        text += payloadAsHex + " "
      }
      
    default:
      break
    }

    return text
    
  }
  
  public func hexDump(space:UInt8, startAddress:UInt32, data:[UInt8]) -> String {
    
    var dump = "\n"
    
    let bytesPerRow : UInt32 = 16
    
    var address = startAddress
    var bytesSoFar : UInt32 = 0
    var bytes : String = ""
    var chars : String = ""
    
    let padding = String(repeating: " ", count: 41)
    
    for byte in data {
      
      if bytesSoFar == bytesPerRow {
        dump += "\(padding)\(space.hex()) \(address.hex(numberOfBytes: 4)!): \(bytes) \(chars)\n"
        address += bytesPerRow
        bytesSoFar = 0
        bytes = ""
        chars = ""
      }

      bytes += "\(byte.hex()) "

      let char = Character(UnicodeScalar(byte))
      let isPrintable = char.isLetter || char.isNumber || char.isSymbol || char.isPunctuation || char == " "
      
      chars += "\(isPrintable ? char : ".")"
      
      bytesSoFar += 1
      
    }
    
    if bytesSoFar > 0 {
      while bytesSoFar < bytesPerRow {
        bytes += "   "
        bytesSoFar += 1
      }
      dump += "\(padding)\(space.hex()) \(address.hex(numberOfBytes: 4)!): \(bytes) \(chars)"
    }
    
    return dump
    
  }

  
  public var isMessageComplete : Bool {
    
    var result = sourceNodeId != nil && sourceNIDAlias != nil
    let isDatagram = messageTypeIndicator == .datagram
    if messageTypeIndicator.isAddressPresent || isDatagram {
      result = result && destinationNodeId != nil && destinationNIDAlias != nil
    }
    if messageTypeIndicator.isEventPresent && !isDatagram {
      result = result && eventId != nil
    }
    return result

  }
  
  public var fullMessage : [UInt8]? {
    
    guard let sourceNodeId else {
      return nil
    }
    
    var data : [UInt8] = []
    
    data.append(contentsOf: visibility.bigEndianData)

    data.append(contentsOf: UInt64(routing.count).nodeIdBigEndianData)
    
    for id in routing {
      data.append(contentsOf: id.nodeIdBigEndianData)
    }
    
    data.append(contentsOf: timeStamp.bitPattern.bigEndianData)
    
    data.append(contentsOf: messageTypeIndicator.rawValue.bigEndianData)
    
    data.append(contentsOf: sourceNodeId.nodeIdBigEndianData)
    
    if messageTypeIndicator.isAddressPresent {
      
      guard let destinationNodeId else {
        return nil
      }
      
      data.append(contentsOf: destinationNodeId.nodeIdBigEndianData)
      
    }
    
    if messageTypeIndicator.isEventPresent {
      
      guard let eventId else {
        return nil
      }
      
      data.append(contentsOf: eventId.bigEndianData)
      
    }
    
    data.append(contentsOf: payload)
    
    return data
    
  }
  
  // MARK: Class Methods
  
  public static func canFrameType(message:OpenLCBMessage) -> OpenLCBMessageCANFrameType {
    
    if !message.messageTypeIndicator.isStreamOrDatagram && !message.messageTypeIndicator.isSpecial {
      return .globalAndAddressedMTI
    }
    else if message.messageTypeIndicator == .datagram {
      return .datagramFirstFrame
    }
    
    return .reserved1
    
  }
  
}
