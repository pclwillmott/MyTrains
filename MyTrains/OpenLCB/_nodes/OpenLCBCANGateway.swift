//
//  OpenLCBCANGateway.swift
//  MyTrains
//
//  Created by Paul Willmott on 09/07/2023.
//

import Foundation

public class OpenLCBCANGateway : OpenLCBNodeVirtual, MTSerialPortDelegate {
 
  // MARK: Constructors & Destructors
  
  public override init(nodeId:UInt64) {
    
    configuration = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, defaultMemorySize: 259, isReadOnly: false, description: "")
    
    super.init(nodeId: nodeId)
    
    virtualNodeType = MyTrainsVirtualNodeType.canGatewayNode
    
    configuration.delegate = self

    memorySpaces[configuration.space] = configuration

    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressDevicePath)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressBaudRate)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressParity)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressFlowControl)

    initCDI(filename: "MyTrains CAN Gateway")
    
    if !memorySpacesInitialized {
      resetToFactoryDefaults()
    }
    
  }
  
  deinit {
    if isOpen {
      close()
    }
  }

  // MARK: Private Properties
  
  // Serial Port Control
  
  internal var serialPort : MTSerialPort?
  
  internal var buffer : [UInt8] = []
  
  internal var isOpen : Bool {
    if let port = serialPort {
      return port.isOpen
    }
    return false
  }

  // Configuration varaible addresses
  
  internal let addressDevicePath       : Int =  0
  internal let addressBaudRate         : Int =  256
  internal let addressParity           : Int =  257
  internal let addressFlowControl      : Int =  258
  
  internal var observers : [Int:OpenLCBCANDelegate] = [:]
  internal var nextObserverId : Int = 1

  private var devicePath : String {
    get {
      return configuration.getString(address: addressDevicePath, count: 256)!
    }
    set(value) {
      configuration.setString(address: addressDevicePath, value: value, fieldSize: 256)
    }
  }
  
  private var baudRate : BaudRate {
    get {
      return BaudRate(rawValue: Int(configuration.getUInt8(address: addressBaudRate)!))!
    }
    set(value) {
      let uInt : UInt8 = UInt8(value.rawValue & 0xff)
      configuration.setUInt(address: addressBaudRate, value: uInt)
    }
  }
  
  private var parity : Parity {
    get {
      return Parity(rawValue: Int32(configuration.getUInt8(address: addressParity)!))!
    }
    set(value) {
      let uInt : UInt8 = UInt8(value.rawValue & 0xff)
      configuration.setUInt(address: addressBaudRate, value: uInt)
    }
  }
  
  private var flowControl : FlowControl {
    get {
      return FlowControl(rawValue: Int(configuration.getUInt8(address: addressFlowControl)!))!
    }
    set(value) {
      let uInt : UInt8 = UInt8(value.rawValue & 0xff)
      configuration.setUInt(address: addressBaudRate, value: uInt)
    }
  }
  
  internal var outputQueue : [OpenLCBMessage] = []
  
  internal var outputQueueLock : NSLock = NSLock()
  
  internal var inputQueue : [OpenLCBMessage] = []
  
  internal var inputQueueLock : NSLock = NSLock()
  
  internal var internalNodes : Set<UInt64> = []
  
  internal var externalConsumedEvents : Set<UInt64> = []
  
  internal var externalConsumedEventRanges : [(startEventId:UInt64, endEventId:UInt64)] = []
  
  internal var internalConsumedEvents : Set<UInt64> = []
  
  internal var internalConsumedEventRanges : [(startEventId:UInt64, endEventId:UInt64)] = []
  
  private var initNodeQueue : [OpenLCBTransportLayerAlias] = []
  
  private var managedNodeIdLookup : [UInt64:OpenLCBTransportLayerAlias] = [:]
  
  private var managedAliasLookup : [UInt16:OpenLCBTransportLayerAlias] = [:]
  
  private let waitInterval : TimeInterval = 200.0 / 1000.0
  
  private let timeoutInterval : TimeInterval = 3.0
  
  private var isStopping : Bool = false

  private var waitTimer : Timer?
  
  private var aliasTimer : Timer?
  
  private var aliasLock : NSLock = NSLock()
  
  private var inGetAlias : Bool = false
    
  private var aliasLookup : [UInt16:UInt64] = [:]
  
  private var nodeIdLookup : [UInt64:UInt16] = [:]
  
  private var splitFrames : [UInt64:LCCCANFrame] = [:]
  
  private var datagrams : [UInt32:OpenLCBMessage] = [:]
  
  private var datagramsAwaitingReceipt : [UInt32:OpenLCBMessage] = [:]
  
  private var inProcessQueue : Bool = false
  
  private var processQueueLock : NSLock = NSLock()
  
  private var lastTimeStamp : TimeInterval = 0.0
  
  // MARK: Public Properties
  
  public var configuration : OpenLCBMemorySpace

  // MARK: Private Methods
  
  internal override func resetToFactoryDefaults() {
    
    super.resetToFactoryDefaults()
    
    acdiManufacturerSpaceVersion = 4
    
    manufacturerName    = virtualNodeType.manufacturerName
    nodeModelName       = virtualNodeType.name
    nodeHardwareVersion = "\(Bundle.main.releaseVersionNumberPretty)"
    nodeSoftwareVersion = "\(Bundle.main.releaseVersionNumberPretty)"

    acdiUserSpaceVersion = 2
    
    userNodeName        = ""
    userNodeDescription = ""
    
    devicePath = ""
    
    baudRate = .br9600
    
    flowControl = .noFlowControl
    
    parity = .none
    
    saveMemorySpaces()
    
  }
  
  internal override func resetReboot() {

    super.resetReboot()
    
    close()
    
    buffer.removeAll()
    
    if let port = MTSerialPort(path: devicePath) {
      serialPort = port
      port.baudRate = baudRate
      port.numberOfDataBits = 8
      port.numberOfStopBits = 1
      port.parity = parity
      port.usesRTSCTSFlowControl = flowControl == .rtsCts
      port.delegate = self
      port.open()
    }

  }
  
  private func close() {
    serialPort?.close()
    serialPort = nil
  }
  
  public func send(data: [UInt8]) {
//    DispatchQueue.main.async {
      self.serialPort?.write(data:data)
//    }
  }

  public func send(data:String) {
//    DispatchQueue.main.async {
    for (_, observer) in observers {
      observer.rawCANPacketSent(packet: data)
    }
      self.serialPort?.write(data:[UInt8](data.utf8))
 //   }
  }

  internal func parseInput() {

    while !buffer.isEmpty {
      
      var found = false
      
      while !buffer.isEmpty {
        let char = String(format: "%C", buffer[0])
        if char == ":" {
          found = true
          break
        }
        buffer.removeFirst()
      }
      
      if !found {
        break
      }
      
      var frame = ""
      
      found = false
      
      var index = 0
      while index < buffer.count {
        let char = String(format: "%C", buffer[index])
        frame += char
        if char == ";" {
           found = true
          break
        }
        index += 1
      }
      
      if found {
        
        buffer.removeFirst(frame.count)

        if let newframe = LCCCANFrame(message: frame) {
          
          newframe.timeStamp = Date.timeIntervalSinceReferenceDate
          newframe.timeSinceLastMessage = newframe.timeStamp - lastTimeStamp
          lastTimeStamp = newframe.timeStamp
          for (_, observer) in observers {
            observer.openLCBCANPacketReceived(packet: newframe)
          }
          canFrameReceived(frame: newframe)

        }
        else {
          for (_, observer) in observers {
            observer.rawCANPacketReceived(packet: frame)
          }
        }

      }
      else {
        break
      }

      
    }
    
  }

  private func canFrameReceived(frame:LCCCANFrame) {
    
    switch frame.frameType {
      
    case .canControlFrame:
      
      // Testing an alias
      
      if let node = initNodeQueue.first, let alias = node.alias, (node.transitionState == .testingAlias || node.transitionState == .reservingAlias) && frame.sourceNIDAlias == alias {
        stopAliasTimer()
        node.transitionState = .idle
        getAlias()
        return
      }
      
      // Node Id Alias Validation
      
      if frame.canControlFrameFormat == .aliasMappingEnquiryFrame {
          
        if frame.data.isEmpty {
          for (_, internalNode) in managedNodeIdLookup {
            if internalNode.state == .permitted {
              sendAliasMapDefinitionFrame(nodeId: internalNode.nodeId, alias: internalNode.alias!)
            }
          }
        }
        else {
          if let nodeId = UInt64(bigEndianData: frame.data), let internalNode = managedNodeIdLookup[nodeId], internalNode.state == .permitted {
            sendAliasMapDefinitionFrame(nodeId: nodeId, alias: internalNode.alias!)
          }
        }
        
        return

      }
      
      // *** HUB TESTING ***
      if (frame.sourceNIDAlias == 0xe46 ||  frame.sourceNIDAlias == 0x11e) && frame.canControlFrameFormat.isCheckIdFrame {
    //    sendReserveIdFrame(alias: frame.sourceNIDAlias)
        return
      }


      for (_, internalNode) in managedNodeIdLookup {
        
        // Node Id Collision Handling
        
        if let alias = internalNode.alias, frame.sourceNIDAlias == alias {
          
          // Is a CID Frame
          
          if frame.canControlFrameFormat.isCheckIdFrame {
            sendReserveIdFrame(alias: alias)
            return
          }
          
          // Is not a CID Frame
          
          if internalNode.state == .permitted {
            
            removeNodeIdAliasMapping(nodeId: internalNode.nodeId)
            internalNode.alias = nil
            internalNode.state = .inhibited
            internalNode.transitionState = .tryAgain
            initNodeQueue.append(internalNode)
            getAlias()
            return
            
          }
          
        }
        
        
      }
      
      // Remove lookups for reset mappings
        
      if frame.canControlFrameFormat == .aliasMapResetFrame {
        removeNodeIdAliasMapping(alias: frame.sourceNIDAlias)
        return
      }
        
        // Check for Duplicate NodeId
        
      if frame.canControlFrameFormat == .aliasMapDefinitionFrame, let nodeId = UInt64(bigEndianData: frame.data) {

        if let internalNode = managedNodeIdLookup[nodeId] {
          sendDuplicateNodeIdErrorFrame(alias: internalNode.alias!)
          removeNodeIdAliasMapping(nodeId: nodeId)
          internalNode.state = .stopped
          internalNode.transitionState = .idle
          managedAliasLookup.removeValue(forKey: internalNode.alias!)
          managedNodeIdLookup.removeValue(forKey: nodeId)
          internalNode.alias = nil
          return
        }
        
        addNodeIdAliasMapping(nodeId: nodeId, alias: frame.sourceNIDAlias)

      }

    case .openLCBMessage:
      
      if let message = OpenLCBMessage(frame: frame) {
        
        if let _ = aliasLookup[message.sourceNIDAlias!] {
        }
        else if let alias = message.sourceNIDAlias {
          sendVerifyNodeIdNumberAddressed(sourceNodeId: nodeId, destinationNodeIdAlias: alias)
        }
        
        var deleteList : [LCCCANFrame] = []
        
        let now = frame.timeStamp
        
        for (_, frame) in splitFrames {
          if (now - frame.timeStamp) > 3.0 {
            deleteList.append(frame)
          }
        }
        
        while deleteList.count > 0 {
          splitFrames.removeValue(forKey: deleteList.first!.splitFrameId)
          deleteList.removeFirst()
        }
        
        var timeOutList : [OpenLCBMessage] = []
        
        for (_, message) in datagrams {
          if (now - message.timeStamp) > 3.0 {
            timeOutList.append(message)
          }
        }
        
        while !timeOutList.isEmpty {
          let message = timeOutList.first!
          datagrams.removeValue(forKey: message.datagramId)
          timeOutList.removeFirst()
          if let internalNode = managedAliasLookup[message.destinationNIDAlias!] {
            let errorMessage = OpenLCBMessage(messageTypeIndicator: .datagramRejected)
            errorMessage.destinationNIDAlias = message.sourceNIDAlias
            errorMessage.sourceNIDAlias = internalNode.alias!
            errorMessage.sourceNodeId = internalNode.nodeId
            errorMessage.payload = OpenLCBErrorCode.temporaryErrorTimeOutWaitingForEndFrame.bigEndianData
            addToOutputQueue(message: errorMessage)
          }
        }

        switch message.canFrameType {
        case .globalAndAddressedMTI:
          switch message.messageTypeIndicator {
          case .producerConsumerEventReportWithPayloadFirstFrame:
            splitFrames[frame.splitFrameId] = frame
          case .producerConsumerEventReportWithPayloadMiddleFrame, .producerConsumerEventReportWithPayloadLastFrame:
            if let first = splitFrames[frame.splitFrameId] {
              first.data += frame.data
              if message.messageTypeIndicator == .producerConsumerEventReportWithPayloadLastFrame, let message = OpenLCBMessage(frame: first) {
                message.flags = .onlyFrame
                message.messageTypeIndicator = .producerConsumerEventReport
                stealAlias(message: message)
                addToInputQueue(message: message)
                splitFrames.removeValue(forKey: first.splitFrameId)
              }
            }
          default:
            switch message.flags {
            case .onlyFrame:
              stealAlias(message: message)
              addToInputQueue(message: message)
            case .firstFrame:
              splitFrames[frame.splitFrameId] = frame
            case .middleFrame, .lastFrame:
              if let first = splitFrames[frame.splitFrameId] {
                frame.data.removeFirst(2)
                first.data += frame.data
                if message.flags == .lastFrame, let message = OpenLCBMessage(frame: first) {
                  message.flags = .onlyFrame
                  stealAlias(message: message)
                  addToInputQueue(message: message)
                  splitFrames.removeValue(forKey: first.splitFrameId)
                }
              }
            }
          }
        case .datagramCompleteInFrame:
          addToInputQueue(message: message)
        case .datagramFirstFrame:
          if let oldMessage = datagrams[message.datagramId] {
            if let internalNode = managedAliasLookup[oldMessage.destinationNIDAlias!] {
              let errorMessage = OpenLCBMessage(messageTypeIndicator: .datagramRejected)
              errorMessage.destinationNIDAlias = message.sourceNIDAlias
              errorMessage.sourceNIDAlias = internalNode.alias!
              errorMessage.sourceNodeId = internalNode.nodeId
              errorMessage.payload = OpenLCBErrorCode.temporaryErrorOutOfOrderStartFrameBeforeFinishingPreviousMessage.bigEndianData
              addToOutputQueue(message: errorMessage)
            }
            datagrams.removeValue(forKey: oldMessage.datagramId)
          }
          else {
            datagrams[message.datagramId] = message
          }
        case .datagramMiddleFrame, .datagramFinalFrame:
          if let first = datagrams[message.datagramId] {
            first.timeStamp = message.timeStamp
            first.payload += message.payload
            if message.canFrameType == .datagramFinalFrame {
              addToInputQueue(message: first)
              datagrams.removeValue(forKey: first.datagramId)
            }
          }
          else if let internalNode = managedAliasLookup[message.destinationNIDAlias!] {
            let errorMessage = OpenLCBMessage(messageTypeIndicator: .datagramRejected)
            errorMessage.destinationNIDAlias = message.sourceNIDAlias
            errorMessage.sourceNIDAlias = internalNode.alias!
            errorMessage.sourceNodeId = internalNode.nodeId
            errorMessage.payload = OpenLCBErrorCode.temporaryErrorOutOfOrderMiddleOrEndFrameWithoutStartFrame.bigEndianData
            addToOutputQueue(message: errorMessage)
          }
        default:
          break
        }
        
      }
      else {
        print("*\(frame.header.toHex(numberOfDigits: 4))")
      }
      
    }
    
  }

  private func processQueues() {
    
    if !initNodeQueue.isEmpty {
      return
    }
    
    processQueueLock.lock()
    let ok = !inProcessQueue
    if ok {
      inProcessQueue = true
    }
    processQueueLock.unlock()
    
    if !ok {
      return
    }
    
    // Input Queue
    
    let referenceDate = Date.timeIntervalSinceReferenceDate
    
    if !inputQueue.isEmpty {
      
      var sendQuery = false
      
      var index = 0
      
      while index < inputQueue.count {
        
        let message = inputQueue[index]
        
        if message.sourceNodeId == nil, let alias = message.sourceNIDAlias {
          if let id = aliasLookup[alias] {
       //     print("source id found: \(id.toHexDotFormat(numberOfBytes: 6))")
            message.sourceNodeId = id
          }
          else {
       //     print("source id not found: \(alias.toHex(numberOfDigits: 3))")
            sendQuery = true
          }
        }
        
        if (message.isAddressPresent || message.messageTypeIndicator == .datagram) && message.destinationNodeId == nil, let alias = message.destinationNIDAlias {
          if let id = aliasLookup[alias] {
       //     print("dest id found: \(id.toHexDotFormat(numberOfBytes: 6))")
            message.destinationNodeId = id
          }
          else {
      //      print("dest id not found: \(alias.toHex(numberOfDigits: 3))")
            sendQuery = true
          }
        }
        
        var delete = false
        
        if message.isMessageComplete {
          
          var route = true
          
          switch message.messageTypeIndicator {
            
          case .initializationCompleteSimpleSetSufficient, .initializationCompleteFullProtocolRequired:
            
            for (key, datagram) in datagramsAwaitingReceipt {
              if datagram.destinationNodeId == message.sourceNodeId {
                datagramsAwaitingReceipt.removeValue(forKey: key)
              }
            }
            
          case .datagramReceivedOK:
            
            datagramsAwaitingReceipt.removeValue(forKey: message.datagramIdReversed)
            
          case .datagramRejected:
            
            if let datagram = datagramsAwaitingReceipt[message.datagramIdReversed] {
              datagramsAwaitingReceipt.removeValue(forKey: message.datagramIdReversed)
              if message.errorCode.isTemporary {
                addToOutputQueue(message: datagram)
              }
            }
            
          case .consumerIdentifiedAsCurrentlyValid, .consumerIdentifiedAsCurrentlyInvalid, .consumerIdentifiedWithValidityUnknown:
            
            externalConsumedEvents.insert(message.eventId!)

          case .consumerRangeIdentified:
            
            if let range = message.eventRange {
              
              var found = false
              
              for r in externalConsumedEventRanges {
                if r.startEventId == range.startEventId && r.endEventId == range.endEventId {
                  found = true
                  break
                }
              }
              
              if !found {
                externalConsumedEventRanges.append(range)
              }
              
            }

          case .producerConsumerEventReport:
            
            if let eventId = message.eventId {
              
              if !(message.isAutomaticallyRoutedEvent || internalConsumedEvents.contains(eventId)) {
                
                var found = false
                
                for range in internalConsumedEventRanges {
                  if eventId >= range.startEventId && eventId <= range.endEventId {
                    found = true
                    break
                  }
                }
                
                if !found {
                  route = false
                }
                
              }
              
            }
            else {
              print("producerConsumerEventReport without eventId")
            }

          default:
            break
          }

          if route {
            networkLayer?.sendMessage(gatewayNodeId: nodeId, message: message)
          }
          
          delete = true
          
        }
        else if (referenceDate - message.timeStamp) > timeoutInterval {
          
          var source = "0x\(message.sourceNIDAlias!.toHex(numberOfDigits: 4)) "
          if let sourceNodeId = message.sourceNodeId {
            source += "(\(sourceNodeId.toHex(numberOfDigits: 6)))"
          }
          var dest = ""
          if let alias = message.destinationNIDAlias  {
            dest += "0x\(alias.toHex(numberOfDigits: 4)) "
            if let destinationNodeId = message.destinationNodeId {
              dest += "(\(destinationNodeId.toHex(numberOfDigits: 6)))"
            }
          }
          print("input timeout: \(message.messageTypeIndicator) \(source) -> \(dest)")
          
          delete = true
        }
        
        if delete {
          inputQueueLock.lock()
          inputQueue.remove(at: index)
          inputQueueLock.unlock()
        }
        else {
          index += 1
        }
        
      }
      
      if sendQuery, let alias = nodeIdLookup[nodeId] {
        sendAliasMappingEnquiryFrame(alias: alias)
      }
            
    }
    
    // Output Queue
    
    if !outputQueue.isEmpty {
      
      var index = 0
      
      while index < outputQueue.count {
        
        let message = outputQueue[index]
        
        if let alias = nodeIdLookup[message.sourceNodeId!] {
          
          message.sourceNIDAlias = alias
          
          if (message.messageTypeIndicator == .datagram ) || message.isAddressPresent, let destinationNodeId = message.destinationNodeId {
            
            if let alias = nodeIdLookup[destinationNodeId] {
         //     print("dest alias found: \(destinationNodeId.toHexDotFormat(numberOfBytes: 6)) - \(alias.toHex(numberOfDigits: 3))")
              message.destinationNIDAlias = alias
            }
            else {
         //     print("dest id not found: \(destinationNodeId.toHexDotFormat(numberOfBytes: 6)))")
              sendAliasMappingEnquiryFrame(nodeId: destinationNodeId, alias: alias)
            }
            
          }
          
        }
        else {
          /*
          for (nodeId, alias) in nodeIdLookup {
            print("\(nodeId.toHexDotFormat(numberOfBytes: 6)) - 0x\(alias.toHex(numberOfDigits: 3))")
          }
           */
          print("send source alias not found: \(message.sourceNodeId!.toHexDotFormat(numberOfBytes: 6))")
          
        }
        
        var delete = false
        
        if message.isMessageComplete {
          
          if message.messageTypeIndicator == .datagram {

            datagramsAwaitingReceipt[message.datagramId] = message

            if message.payload.count <= 8 {
              if let frame = LCCCANFrame(message: message, canFrameType: .datagramCompleteInFrame, data: message.payload) {
                send(data: frame.message)
              }
            }
            else {
              
              let numberOfFrames = message.payload.count == 0 ? 1 : 1 + (message.payload.count - 1) / 8
              
              for frameNumber in 1...numberOfFrames {
                
                var canFrameType : OpenLCBMessageCANFrameType = .datagramMiddleFrame
                
                if frameNumber == 1 {
                  canFrameType = .datagramFirstFrame
                }
                else if frameNumber == numberOfFrames {
                  canFrameType = .datagramFinalFrame
                }
                
                var data : [UInt8] = []
                
                var index = (frameNumber - 1) * 8
                
                var count = 0
                
                while index < message.payload.count && count < 8 {
                  data.append(message.payload[index])
                  index += 1
                  count += 1
                }
                
                if let frame = LCCCANFrame(message: message, canFrameType: canFrameType, data: data) {
                  send(data: frame.message)
                }
                
              }
              
            }
            
            delete = true
            
          }
          else if message.messageTypeIndicator == .producerConsumerEventReport {
            
            var data : [UInt8] = []
            
            data.append(contentsOf: message.eventId!.bigEndianData)
            data.append(contentsOf: message.payload)
            
            let numberOfFrames = 1 + (data.count - 1) / 8
            
 //           print("data.count: \(data.count) numberOfFrames: \(numberOfFrames)")
            
            if numberOfFrames == 1 {
              if let frame = LCCCANFrame(message: message) {
                send(data: frame.message)
              }
            }
            else {
              
              for frameNumber in 1 ... numberOfFrames {
                
                switch frameNumber {
                case 1:
                  message.messageTypeIndicator = .producerConsumerEventReportWithPayloadFirstFrame
                case numberOfFrames:
                  message.messageTypeIndicator = .producerConsumerEventReportWithPayloadLastFrame
                default:
                  message.messageTypeIndicator = .producerConsumerEventReportWithPayloadMiddleFrame
                }
                
                var payload : [UInt8] = [UInt8](data.prefix(8))
                
                data.removeFirst(8)
                
                if let frame = LCCCANFrame(pcerMessage: message, payload: payload) {
                  send(data: frame.message)
                }
              
              }
              
            }
            
          }
          else if message.isAddressPresent {
            
            if let frame = LCCCANFrame(message: message) {
              
              if frame.data.count <= 8 {
                send(data: frame.message)
              }
              else {
                
                let numberOfFrames = 1 + (frame.data.count - 3 ) / 6
                
                for frameNumber in 1...numberOfFrames {
                  
                  var flags : OpenLCBCANFrameFlag = .middleFrame
                  
                  if frameNumber == 1 {
                    flags = .firstFrame
                  }
                  else if frameNumber == numberOfFrames {
                    flags = .lastFrame
                  }
                  
                  if let frame = LCCCANFrame(message: message, flags: flags, frameNumber: frameNumber) {
                    send(data: frame.message)
                  }
                  
                }
                
              }
              
            }
            
            delete = true
            
          }
          else if let frame = LCCCANFrame(message: message) {
            send(data: frame.message)
            delete = true
          }
          
        }
        else if (referenceDate - message.timeStamp) > timeoutInterval {

          var source = message.sourceNodeId!.toHexDotFormat(numberOfBytes: 6)
          if let alias = message.sourceNIDAlias {
            source += " (0x\(alias.toHex(numberOfDigits: 4))"
          }
          var dest = ""
          if let nodeId = message.destinationNodeId {
            dest += nodeId.toHexDotFormat(numberOfBytes: 6)
            if let alias = message.destinationNIDAlias {
              dest += " (0x\(alias.toHex(numberOfDigits: 4))"
            }
          }
          
          print("output timeout: \(message.messageTypeIndicator) \(source) -> \(dest)")
          
          delete = true
        }
        
        if delete {
          outputQueueLock.lock()
          outputQueue.remove(at: index)
          outputQueueLock.unlock()
        }
        else {
          index += 1
        }
        
      }
      
    }

    if !inputQueue.isEmpty || !outputQueue.isEmpty {
      startWaitTimer(interval: waitInterval)
    }
    else if isStopping {
      close()
    }
    
    inProcessQueue = false
    
  }
  
  private func sendVerifyNodeIdNumberAddressed(sourceNodeId:UInt64, destinationNodeIdAlias:UInt16) {
    
    if let sourceNIDAlias = nodeIdLookup[sourceNodeId] {
      
      let message = OpenLCBMessage(messageTypeIndicator: .verifyNodeIDNumberAddressed)

      message.sourceNIDAlias = sourceNIDAlias
      
      message.destinationNIDAlias = destinationNodeIdAlias
      
      if let frame = LCCCANFrame(message: message) {
        send(data: frame.message)
      }
      
    }
      
  }

  private func addNodeIdAliasMapping(nodeId: UInt64, alias:UInt16) {
    aliasLookup[alias] = nodeId
    nodeIdLookup[nodeId] = alias
  }
  
  private func removeNodeIdAliasMapping(nodeId:UInt64) {
    if let alias = nodeIdLookup[nodeId] {
      sendAliasMapResetFrame(nodeId: nodeId, alias: alias)
      aliasLookup.removeValue(forKey: alias)
      nodeIdLookup.removeValue(forKey: nodeId)
    }
  }
  
  private func removeNodeIdAliasMapping(alias:UInt16) {
    if let nodeId = aliasLookup[alias] {
      sendAliasMapResetFrame(nodeId: nodeId, alias: alias)
      aliasLookup.removeValue(forKey: alias)
      nodeIdLookup.removeValue(forKey: nodeId)
    }
  }
  
  private func testPRNG() {
    
 //   let nodeId : UInt64 = 0x0000020203000540
    let nodeId : UInt64   = 0x0000000000000000
 //   let nodeId : UInt64   = 0x0000020121000012

    var lfsr1 : UInt32
    
    var lfsr2 : UInt32

    lfsr1 = UInt32(nodeId >> 24)
    
    lfsr2 = UInt32(nodeId & 0xffffff)
    
    for index in 0...15 {

      print("\(index):  \(((UInt64(lfsr1) << 24) | UInt64(lfsr2)).toHexDotFormat(numberOfBytes: 6))  ",terminator: "")

      let result = UInt16((lfsr1 ^ lfsr2 ^ (lfsr1 >> 12) ^ (lfsr2 >> 12) ) & 0xFFF)

      let temp1 : UInt32 = ((lfsr1 << 9) | ((lfsr2 >> 15) & 0x1FF)) & 0xFFFFFF
      let temp2 : UInt32 = (lfsr2 << 9) & 0xFFFFFF
      
      // add
      
      lfsr2 += temp2 + 0x7A4BA9
      
      lfsr1 += temp1 + 0x1B0CA3
      
      // carry
      
      lfsr1 = (lfsr1 & 0xFFFFFF) + ((lfsr2 & 0xFF000000) >> 24)
      lfsr2 &= 0xFFFFFF
      
      // Form a 12-bit alias from the PRNG state:
      
//      let result = UInt16((lfsr1 ^ lfsr2 ^ (lfsr1 >> 12) ^ (lfsr2 >> 12) ) & 0xFFF)
      
      print(" 0x\(result.toHex(numberOfDigits: 3))   \(((UInt64(lfsr1) << 24) | UInt64(lfsr2)).toHexDotFormat(numberOfBytes: 6))")

    }

  }
  
  private func nextAlias() -> UInt16 {
        
  //      print(testPRNG())
    
    // The PRNG state is stored in two 32-bit quantities:
    // uint32_t lfsr1, lfsr2; // sequence value: lfsr1 is upper 24 bits, lfsr2 lower
    
    // The 6-byte unique Node ID is stored in the nid[0:5] array.
    
    // To load the PRNG from the Node ID:
    // lfsr1 = (nid[0] << 16) | (nid[1] << 8) | nid[2]; // upper bits
    // lfsr2 = (nid[3] << 16) | (nid[4] << 8) | nid[5];

    // Form a 12-bit alias from the PRNG state:
    
    let result = UInt16((self.lfsr1 ^ self.lfsr2 ^ (self.lfsr1 >> 12) ^ (self.lfsr2 >> 12) ) & 0xFFF)

    // To step the PRNG:
    // First, form 2^9*val
    
    let temp1 : UInt32 = ((self.lfsr1 << 9) | ((self.lfsr2 >> 15) & 0x1FF)) & 0xFFFFFF
    let temp2 : UInt32 = (self.lfsr2 << 9) & 0xFFFFFF
    
    // add
    
    self.lfsr2 += temp2 + 0x7A4BA9
    
    self.lfsr1 += temp1 + 0x1B0CA3
    
    // carry
    
    self.lfsr1 = (self.lfsr1 & 0xFFFFFF) + ((self.lfsr2 & 0xFF000000) >> 24)
    self.lfsr2 &= 0xFFFFFF
    
    return result
    
  }
  
  private func getAlias() {
    
    aliasLock.lock()
    let ok = !inGetAlias
    if ok {
      inGetAlias = true
    }
    aliasLock.unlock()
    
    if !ok {
      return
    }

    if let node = initNodeQueue.first {

      if node.transitionState == .tryAgain {
        managedAliasLookup.removeValue(forKey: node.alias!)
        managedNodeIdLookup.removeValue(forKey: node.nodeId)
        node.transitionState = .idle
      }
      
      if node.transitionState == .idle {
        
        node.state = .inhibited
        
        node.transitionState = .testingAlias
        
        node.alias = nextAlias()
        
        sendCheckIdFrame(format: .checkId7Frame, nodeId: node.nodeId, alias: node.alias!)
        sendCheckIdFrame(format: .checkId6Frame, nodeId: node.nodeId, alias: node.alias!)
        sendCheckIdFrame(format: .checkId5Frame, nodeId: node.nodeId, alias: node.alias!)
        sendCheckIdFrame(format: .checkId4Frame, nodeId: node.nodeId, alias: node.alias!)
        
        startAliasTimer(interval: waitInterval)
        
      }
      
    }
    
    inGetAlias = false
    
  }
  
  @objc func waitTimerTick() {
    stopWaitTimer()
    processQueues()
  }
  
  private func startWaitTimer(interval: TimeInterval) {
    waitTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(waitTimerTick), userInfo: nil, repeats: false)
    RunLoop.current.add(waitTimer!, forMode: .common)
  }
  
  private func stopWaitTimer() {
    waitTimer?.invalidate()
    waitTimer = nil
  }

  @objc func aliasTimerAction() {
    
    stopAliasTimer()
    
    if let internalNode = initNodeQueue.first {
      
      switch internalNode.transitionState {
      case .testingAlias:
        internalNode.transitionState = .reservingAlias
        sendReserveIdFrame(alias: internalNode.alias!)
        startAliasTimer(interval: waitInterval)
      case .reservingAlias:
        internalNode.transitionState = .mappingDeclared
        internalNode.state = .permitted
        sendAliasMapDefinitionFrame(nodeId: internalNode.nodeId, alias: internalNode.alias!)
        addNodeIdAliasMapping(nodeId: internalNode.nodeId, alias: internalNode.alias!)
        managedAliasLookup[internalNode.alias!] = internalNode
        managedNodeIdLookup[internalNode.nodeId] = internalNode
        initNodeQueue.removeFirst()
        /*
        for (alias, nodeId) in aliasLookup {
          print("0x\(alias.toHex(numberOfDigits: 3)) -> \(nodeId.toHexDotFormat(numberOfBytes: 6))")
        }
        print()
         */
        if !initNodeQueue.isEmpty {
          getAlias()
        }
        else {
          processQueues()
        }
      default:
        break
      }
    }
    
  }
  
  private func startAliasTimer(interval: TimeInterval) {
    aliasTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(aliasTimerAction), userInfo: nil, repeats: false)
    RunLoop.current.add(aliasTimer!, forMode: .common)
  }
  
  private func stopAliasTimer() {
    aliasTimer?.invalidate()
    aliasTimer = nil
  }
  
  private func send(header: String, data:String) {
    let packet = ":X\(header)N\(data);"
    send(data: packet)
  }

  private func sendCheckIdFrame(format:OpenLCBCANControlFrameFormat, nodeId:UInt64, alias: UInt16) {
    
    var variableField : UInt16 = format.rawValue
    
    variableField |= UInt16((nodeId >> (((format.rawValue >> 12) - 4) * 12)) & 0x0fff)
    
    let header = LCCCANFrame.createFrameHeader(frameType: .canControlFrame, variableField: variableField, sourceNIDAlias: alias)
    
    send(header: header, data: "")

  }

  private func sendReserveIdFrame(alias:UInt16) {
    
    let variableField : UInt16 = OpenLCBCANControlFrameFormat.reserveIdFrame.rawValue
    
    let header = LCCCANFrame.createFrameHeader(frameType: .canControlFrame, variableField: variableField, sourceNIDAlias: alias)
    
    send(header: header, data: "")

  }

  private func sendAliasMapDefinitionFrame(nodeId:UInt64, alias:UInt16) {
    
    let variableField : UInt16 = OpenLCBCANControlFrameFormat.aliasMapDefinitionFrame.rawValue
    
    let header = LCCCANFrame.createFrameHeader(frameType: .canControlFrame, variableField: variableField, sourceNIDAlias: alias)
    
    send(header: header, data: nodeId.toHex(numberOfDigits: 12))

  }

  private func sendAliasMapResetFrame(nodeId:UInt64, alias:UInt16) {
    
    let variableField : UInt16 = OpenLCBCANControlFrameFormat.aliasMapResetFrame.rawValue
    
    let header = LCCCANFrame.createFrameHeader(frameType: .canControlFrame, variableField: variableField, sourceNIDAlias: alias)
    
    send(header: header, data: nodeId.toHex(numberOfDigits: 12))

  }

  private func sendAliasMappingEnquiryFrame(nodeId:UInt64, alias:UInt16) {
    
    let variableField : UInt16 = OpenLCBCANControlFrameFormat.aliasMappingEnquiryFrame.rawValue
    
    let header = LCCCANFrame.createFrameHeader(frameType: .canControlFrame, variableField: variableField, sourceNIDAlias: alias)
    
    send(header: header, data: nodeId.toHex(numberOfDigits: 12))

  }

  private func sendAliasMappingEnquiryFrame(alias:UInt16) {
    
    let variableField : UInt16 = OpenLCBCANControlFrameFormat.aliasMappingEnquiryFrame.rawValue
    
    let header = LCCCANFrame.createFrameHeader(frameType: .canControlFrame, variableField: variableField, sourceNIDAlias: alias)
    
    send(header: header, data: "")

  }

  private func sendDuplicateNodeIdErrorFrame(alias:UInt16) {
    
    var header : UInt32 = 0x195B4000
    
    header |= UInt32(alias & 0x0fff)

    send(header: header.toHex(numberOfDigits: 8), data: "0101000000000201")

  }
  
  private func stealAlias(message:OpenLCBMessage) {
    
    switch message.messageTypeIndicator {
    case .verifiedNodeIDNumberSimpleSetSufficient, .verifiedNodeIDNumberFullProtocolRequired, .initializationCompleteSimpleSetSufficient, .initializationCompleteFullProtocolRequired:
      if let alias = message.sourceNIDAlias, let newNodeId = UInt64(bigEndianData: message.payload) {
        addNodeIdAliasMapping(nodeId: newNodeId, alias: alias)
      }
    default:
      break
    }

  }

  // MARK: Public Methods
  
  public override func start() {
    super.start()
  }
  
  public override func stop() {
    close()
    super.stop()
  }
  
  public func addObserver(observer:OpenLCBCANDelegate) -> Int {
    let id = nextObserverId
    nextObserverId += 1
    observers[id] = observer
    return id
  }
  
  public func removeObserver(id:Int) {
    observers.removeValue(forKey: id)
  }
  
  public func addToOutputQueue(message: OpenLCBMessage) {
    message.timeStamp = Date.timeIntervalSinceReferenceDate
    outputQueueLock.lock()
    outputQueue.append(message)
    outputQueueLock.unlock()
    processQueues()
  }

  public func addToInputQueue(message: OpenLCBMessage) {
    message.timeStamp = Date.timeIntervalSinceReferenceDate
    inputQueueLock.lock()
    inputQueue.append(message)
    inputQueueLock.unlock()
    processQueues()
  }
  
  // MARK: OpenLCBNetworkLayerDelegate Methods
  
  public override func openLCBMessageReceived(message: OpenLCBMessage) {
 
    super.openLCBMessageReceived(message: message)
    
    if let sourceNodeId = message.sourceNodeId, !internalNodes.contains(sourceNodeId) {
      
      internalNodes.insert(sourceNodeId)
      
      let alias = OpenLCBTransportLayerAlias(nodeId: sourceNodeId)
      
      initNodeQueue.append(alias)
      
      getAlias()

    }

    if let destinationNodeId = message.destinationNodeId, internalNodes.contains(destinationNodeId) {
      return
    }
    
    switch message.messageTypeIndicator {
      
    case .producerConsumerEventReport:
      
      if let eventId = message.eventId {
        
        if !(message.isAutomaticallyRoutedEvent || externalConsumedEvents.contains(eventId)) {
          
          var found = false
          
          for range in externalConsumedEventRanges {
            if eventId >= range.startEventId && eventId <= range.endEventId {
              found = true
              break
            }
          }
          
          if !found {
            return
          }
          
        }
        
      }
      else {
        print("producerConsumerEventReport without eventId")
      }
      
    case .consumerIdentifiedAsCurrentlyValid, .consumerIdentifiedAsCurrentlyInvalid, .consumerIdentifiedWithValidityUnknown:
      
      internalConsumedEvents.insert(message.eventId!)
      
    case .consumerRangeIdentified:
      
      if let range = message.eventRange {
        
        var found = false
        
        for r in internalConsumedEventRanges {
          if r.startEventId == range.startEventId && r.endEventId == range.endEventId {
            found = true
            break
          }
        }
        
        if !found {
          internalConsumedEventRanges.append(range)
        }

      }
      
    default:
      break
    }
    
    addToOutputQueue(message: message)
    
  }

  // MARK: MTSerialPortDelegate Methods
  
  public func serialPort(_ serialPort: MTSerialPort, didReceive data: [UInt8]) {
    buffer.append(contentsOf: data)
    parseInput()
  }
  
  public func serialPortWasOpened(_ serialPort: MTSerialPort) {

    print("serial port was opened: \(serialPort.path)")
 
    internalNodes.insert(nodeId)
    
    let alias = OpenLCBTransportLayerAlias(nodeId: nodeId)
    
    initNodeQueue.append(alias)
    
    getAlias()

  }
  
  public func serialPortWasRemovedFromSystem(_ serialPort: MTSerialPort) {
    print("serial port was removed from system: \(serialPort.path)")
    self.serialPort = nil
  }
  
  public func serialPortWasClosed(_ serialPort: MTSerialPort) {
    print("serial port was closed: \(serialPort.path)")
    self.serialPort = nil
  }

  public func serialPortWasAdded(_ serialPort: MTSerialPort) {
    if !isOpen {
      resetReboot()
    }
  }

}
