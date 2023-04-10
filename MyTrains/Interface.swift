//
//  Interface.swift
//  MyTrains
//
//  Created by Paul Willmott on 30/12/2021.
//

import Foundation
import Cocoa
import AVFoundation

enum InterfaceState {
  case idle
  case spacing
  case waitingForResponse
}

public class Interface : LocoNetDevice, MTSerialPortDelegate {
  
  // MARK: Constructors
  
  // MARK: Destructors
  
  deinit {
    close()
  }
  
  // MARK: Private Properties
  
  private var serialPort : MTSerialPort?
  
  private var buffer : [UInt8] = [UInt8](repeating: 0x00, count:1024)
  
  private var readPtr : Int = 0
  
  private var writePtr : Int = 0
  
  private var bufferCount : Int = 0
  
  private var bufferLock : NSLock = NSLock()
  
  private var outputQueue : [NetworkOutputQueueItem] = []
  
  private var outputQueueLock : NSLock = NSLock()
  
  private var outputTimer : Timer?
  
  private var observers : [Int:InterfaceDelegate] = [:]
  
  private var nextObserverKey : Int = 0
  
  private var nextObserverKeyLock : NSLock = NSLock()
  
  private var interfaceState : InterfaceState = .idle
  
  private var lastTimeStamp : TimeInterval = Date.timeIntervalSinceReferenceDate

  internal var _locoSlots : [Int:LocoSlotData] = [:]
  
  // MARK: Public Properties
  
  public var generalSensorLookup : [Int:IOFunction] = [:] // Key is address
  
  public var transponderSensorLookup : [Int:IOFunction] = [:] // Key is address
  
  public var trackFaultSensorLookup : [Int:IOFunction] = [:] // Key is address
  
  public var turnoutLookup : [Int:TurnoutSwitch] = [:]
  
  public var opSwBankA : NetworkMessage?
  
  public var opSwBankB : NetworkMessage?
  
  public var globalSystemTrackStatus : UInt8?
  
  public var isEdit : Bool = false
  
  public var commandStation : Interface? {
    get {
      return network?.commandStation
    }
  }
  
  public var isConnected : Bool {
    get {
      return serialPort != nil
    }
  }
  
  public var isOpen : Bool {
    if let port = serialPort {
      return port.isOpen
    }
    return false
  }
  
  public var partialSerialNumberLow : Int = -1
  
  public var partialSerialNumberHigh : Int = -1
  
  // MARK: Private Methods
  
  private func slotsUpdated() {
    for kv in observers {
      kv.value.slotsUpdated?(interface: self)
    }
  }
  
  @objc func lccCANFrameReceived(frame:LCCCANFrame) {

  }

  private func networkMessageReceived(message: NetworkMessage) {
    
    let printOpSw = true

    switch message.messageType {
      
    case .iplDevData:
      
      let iplDevData = IPLDevData(message: message)
      
      var newDevice = true
      
      for kv in networkController.locoNetDevices {
        
        let device = kv.value
        
        if let info = device.locoNetProductInfo, info.productCode == iplDevData.productCode &&
            device.serialNumber == iplDevData.serialNumber {
  
          newDevice = false
          
          device.softwareVersion = iplDevData.softwareVersion
          device.boardId = iplDevData.boardId + 1
   //       device.networkId = message.networkId
          
          device.save()
          
          if info.attributes.contains(.CommandStation) {

            if let net = network {
              net.commandStationId = device.primaryKey
              net.save()
            }
          }
          
        }
        
      }
      
      if newDevice {
        
        if let info = iplDevData.productCode.product() {
          
          var dev : LocoNetDevice?
          
          if info.attributes.intersection([.ComputerInterface, .CommandStation]).isEmpty {
            dev = LocoNetDevice(primaryKey: -1)
          }
          else if info.productCode == .BXP88 {
            dev = IODeviceBXP88(primaryKey: -1)
          }
          else {
            dev = Interface(primaryKey: -1)
          }
          
          if let device = dev {
            
            device.networkId = message.networkId
            device.boardId = iplDevData.boardId + 1
            device.softwareVersion = iplDevData.softwareVersion
            device.serialNumber = iplDevData.serialNumber
            device.locoNetProductId = info.id
            device.deviceName = device.iplName
            
            if !isEdit {
              
              device.save()
              
              networkController.addDevice(device: device)
              
              if let net = network, info.attributes.contains(.CommandStation) {
                net.commandStationId = device.primaryKey
                net.save()
              }
              
            }

          }
          
        }
        
      }
      
      networkController.networkControllerStatusUpdated()

    case .opSwDataAP1:
      
      commandStation?.opSwBankA = message
      commandStation?.globalSystemTrackStatus = message.message[7]
      
      if printOpSw {
        
 //       <E7 0E 7F 00 03 30 02 47 01 08 00 1A 60 6C>
 //       <E7 0E 7E 11 00 22 00 47 33 00 44 00 60 0B>
        
        var opSw = 1
        var byte = 3
        
        var mess : [UInt8] = message.message
    //    mess = [0xE7, 0x0E, 0x7F, 0x00, 0x03, 0x30, 0x02, 0x47, 0x01, 0x08, 0x00, 0x1A, 0x60, 0x6C]

    //    print("DCS210+")
        
        while byte < 12 {
          
          for shift in 0...7 {
            let mask : UInt8 = 1 << shift
            let opSwState : Bool = (mess[byte] & mask) == mask
            if opSw % 8 != 0 {
        //      print("\(opSw)\t\(opSwState ? "Closed" : "Thrown")")
            }
            opSw += 1
          }
          
          byte += 1
          if byte == 7 {
            byte += 1
          }
          
        }
        
 //       print("----------------")
        
      }
      
    case .opSwDataBP1:
      
      commandStation?.opSwBankB = message
      commandStation?.globalSystemTrackStatus = message.message[7]
      
      if printOpSw {
        
        var opSw = 65
        var byte = 3
        
        var mess : [UInt8] = message.message
//        mess = [0xE7, 0x0E, 0x7E, 0x11, 0x00, 0x22, 0x00, 0x47, 0x33, 0x00, 0x44, 0x00, 0x60, 0x0B]
        
  //      print("DCS210+")
 
        while byte < 12 {
          
          for shift in 0...7 {
            let mask : UInt8 = 1 << shift
            let opSwState : Bool = (mess[byte] & mask) == mask
            if opSw % 8 != 0 {
         //     print("\(opSw)\t\(opSwState ? "Closed" : "Thrown")")
            }
            opSw += 1
          }
          
          byte += 1
          if byte == 7 {
            byte += 1
          }
          
        }
        
    //    print("----------------")
        
      }

     
    case .fastClockData:
      commandStation?.globalSystemTrackStatus = message.message[7]
      
    case .locoSlotDataP1:
      commandStation?.globalSystemTrackStatus = message.message[7]
      let slot = LocoSlotData(locoSlotDataP1: LocoSlotDataP1(networkId: self.networkId, data: message.message))
      _locoSlots[slot.slotID] = slot
      slotsUpdated()

    case .locoSlotDataP2:
      commandStation?.globalSystemTrackStatus = message.message[7]
      let slot = LocoSlotData(locoSlotDataP2: LocoSlotDataP2(networkId: self.networkId, data: message.message))
      _locoSlots[slot.slotID] = slot
      slotsUpdated()

//    case .sensRepTurnIn:
  //    print("sensRepTurnIn: \(message.turnoutReportAddress) \(message.sensorState)")
      
//    case .sensRepTurnOut:
  //    print("sensRepTurnOut: \(message.turnoutReportAddress) \(message.sensorState)")
    
    case .transRep:
      
      if let sensor = transponderSensorLookup[message.transponderAddress] {
       
    
      }
      
    case .pmRepBXP88:
      
      for address in message.detectionSectionsSet.notSet {
      
        if let sensor = trackFaultSensorLookup[address] {

          for item in sensor.switchBoardItems {
            item.isTrackFault = false
          }
          
        }
        
      }

      for address in message.detectionSectionsSet.set {
      
        if let sensor = trackFaultSensorLookup[address] {

          for item in sensor.switchBoardItems {
            item.isTrackFault = true
          }
          
        }
        
      }
      

  
    case .sensRepGenIn:
      
   //   print("sensRepGenIn: \(message.sensorAddress) \(message.sensorState)")
      
      if let sensor = generalSensorLookup[message.sensorAddress], let layout = network?.layout {
        
        let state = sensor.inverted ? !message.sensorState : message.sensorState
        
        for item in sensor.switchBoardItems {
          switch sensor.sensorType {
          case .position:
            item.isOccupied = state
            break
          case .turnoutState:
            if item.sw1Sensor1 == sensor {
              item.sw1?.state = state ? .thrown : item.sw1Sensor2 == nil ? .closed : .unknown
            }
            else if item.sw1Sensor2 == sensor {
              item.sw1?.state = state ? .closed : item.sw1Sensor1 == nil ? .thrown : .unknown
            }
            else if item.sw2Sensor1 == sensor {
              item.sw2?.state = state ? .thrown : item.sw2Sensor2 == nil ? .closed : .unknown
            }
            else if item.sw2Sensor2 == sensor {
              item.sw2?.state = state ? .closed : item.sw2Sensor1 == nil ? .thrown : .unknown
            }
            break
          case .occupancy:
            item.isOccupied = state
          default:
            break
          }
        }
        
        layout.needsDisplay()
        
      }
    default:
      break
    }
    
    var newSlot = false
    
    for slotNumber in message.slotsChanged {
      if let slot = _locoSlots[slotNumber] {
        slot.isDirty = true
      }
      else {
        let slot = LocoSlotData(slotID: slotNumber)
        _locoSlots[slotNumber] = slot
        newSlot = true
      }
    }
    
    if newSlot {
      slotsUpdated()
    }

  }
  
  private func sendMessage() {
    
    var startTimer = false
    
    var delay : TimeInterval = 0.0
    
    var timeout : NetworkMessage?
    
    outputQueueLock.lock()
    
    if outputQueue.count > 0 && interfaceState == .idle {
        
      let item = outputQueue[0]
      
      if item.retryCount > 0 {
      
        send(data: item.message.message)
        
        if item.responseExpected {
          interfaceState = .waitingForResponse
        }
        else {
          interfaceState = .spacing
          outputQueue.remove(at: 0)
        }
        
        item.retryCount -= 1
          
        delay = item.delay
        
        startTimer = true
        
      }
      else {
        
        if item.timeoutCode != .none {
          timeout = NetworkMessage(networkId: networkId, timeoutCode: item.timeoutCode)
        }
        
        outputQueue.remove(at: 0)

      }

    }
    
    outputQueueLock.unlock()
    
    if let timeoutMessage = timeout {
      for observer in observers {
        observer.value.networkMessageReceived?(message: timeoutMessage)
        observer.value.progMessageReceived?(message: timeoutMessage)
      }
    }
    
    if startTimer {
      startSpacingTimer(timeInterval: delay)
    }
    
  }
 
  @objc func spacingTimer() {
    stopSpacingTimer()
    outputQueueLock.lock()
    interfaceState = .idle
    outputQueueLock.unlock()
    sendMessage()
  }
  
  func startSpacingTimer(timeInterval:TimeInterval) {
    outputTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(spacingTimer), userInfo: nil, repeats: false)
    RunLoop.current.add(outputTimer!, forMode: .common)
  }
  
  func stopSpacingTimer() {
    outputTimer?.invalidate()
    outputTimer = nil
    outputQueueLock.lock()
    interfaceState = .idle
    outputQueueLock.unlock()
  }

  // MARK: Public Methods
      
  public func initSensorLookup() {
    
    generalSensorLookup.removeAll()
    transponderSensorLookup.removeAll()
    trackFaultSensorLookup.removeAll()

    for (_, ioFunction) in networkController.sensors {
      ioFunction.switchBoardItems.removeAll()
      switch ioFunction.sensorType {
      case .trackFault:
        trackFaultSensorLookup[ioFunction.address] = ioFunction
      case .transponder:
        transponderSensorLookup[ioFunction.address] = ioFunction
      case .occupancy, .position:
        generalSensorLookup[ioFunction.address] = ioFunction
      default:
        break
      }
    }
     
    turnoutLookup.removeAll()
    
    if let layout = networkController.layout {
      
      layout.operationalTurnouts.removeAll()
      
      for (_, item) in layout.switchBoardItems {
        
        if item.isBlock || item.isFeedback || item.isTurnout {
          
          if let sensor = item.generalSensor {
            sensor.switchBoardItems.append(item)
          }
          
          if let sensor = item.transponderSensor {
            sensor.switchBoardItems.append(item)
          }
          
          if let sensor = item.trackFaultSensor {
            sensor.switchBoardItems.append(item)
          }
          
        }
        else if item.isTurnout {
          if let sensor = item.sw1Sensor1 {
            sensor.switchBoardItems.append(item)
          }
          if let sensor = item.sw1Sensor2 {
            sensor.switchBoardItems.append(item)
          }
   //       if let sensor = item.sw2Sensor1 {
   //         sensor.switchBoardItems.append(item)
   //       }
   //       if let sensor = item.sw2Sensor2 {
   //         sensor.switchBoardItems.append(item)
   //       }
        }
        
      }
      
    }
    
  }
  
  public func addObserver(observer:InterfaceDelegate) -> Int {
    nextObserverKeyLock.lock()
    let id : Int = nextObserverKey
    nextObserverKey += 1
    nextObserverKeyLock.unlock()
    observers[id] = observer
    return id
  }
  
  public func removeObserver(id:Int) {
    observers.removeValue(forKey: id)
  }
  
  public func addToQueue(message:NetworkMessage, delay:TimeInterval, responses: Set<NetworkMessageType>, retryCount: Int, timeoutCode: TimeoutCode) {
    
    let item = NetworkOutputQueueItem(message: message, delay: delay, responses: responses, retryCount: retryCount, timeoutCode: timeoutCode)
    
    outputQueueLock.lock()
    outputQueue.append(item)
    outputQueueLock.unlock()
    
    sendMessage()
    
  }
  
  public func addToQueue(message:NetworkMessage, delay:TimeInterval) {
    addToQueue(message: message, delay: delay, responses: [], retryCount: 0, timeoutCode: .none)
  }
  
  public func open() {
    
    close()
    
    if let port = MTSerialPort(path: devicePath) {
      port.baudRate = baudRate
 //     port.baudRate = .br115200
      port.numberOfDataBits = 8
      port.numberOfStopBits = 1
      port.parity = .none
      port.usesRTSCTSFlowControl = flowControl == .rtsCts
      port.delegate = self
      port.open()
      serialPort = port
 //     print("open: \(self.deviceName)")
    }

  }
  
  public func close() {
    if let transportLayer = lccCANTransportLayer, let networkLayer = networkController.lccNetworkLayer {
      networkLayer.removeTransportLayer(transportLayer: transportLayer)
      lccCANTransportLayer = nil
    }
    serialPort?.close()
    serialPort = nil
  }
  
  public func send(data: [UInt8]) {
    serialPort?.write(data:data)
  }

  public func send(data:String) {
    print(data)
    serialPort?.write(data:[UInt8](data.utf8))
  }

  // MARK: MTSerialPortDelegate Methods
  
  public func serialPort(_ serialPort: MTSerialPort, didReceive data: [UInt8]) {

    // Handle LCC
 
    bufferLock.lock()
    bufferCount += data.count
    for x in data {
      buffer[writePtr] = x
      writePtr = (writePtr + 1) & 0xff
    }
    bufferLock.unlock()

    let minFrameSize = 13
    
    var doAgain : Bool = bufferCount >= minFrameSize
    
    if network!.networkType == .LCC {
      
      while doAgain {
        
        enum SearchState {
          case searchingForColon
          case searchingForSemiColon
        }
        
        var state : SearchState = .searchingForColon
          
        bufferLock.lock()

        var index = readPtr
        
        var tempCount = bufferCount
        
        var frame : String = ""

        bufferLock.unlock()
        
        while tempCount > 0 {
          
          let char = String(format: "%C", buffer[index])
          
          switch state {
            
          case .searchingForColon:
            
            if char == ":" {
              frame += char
              state = .searchingForSemiColon
            }
            else {
              bufferLock.lock()
              readPtr = (readPtr + 1) & 0xff
              bufferCount -= 1
              bufferLock.unlock()
            }
            
          case .searchingForSemiColon:
            
            frame += char
            
            if char == ":" {
              let increment = frame.count
              bufferLock.lock()
              readPtr = (readPtr + increment) & 0xff
              bufferCount -= increment
              bufferLock.unlock()
              frame = char
            }
            else if char == "\n" || char == "\r" {
              let increment = frame.count
              bufferLock.lock()
              readPtr = (readPtr + increment) & 0xff
              bufferCount -= increment
              bufferLock.unlock()
              frame = ""
              state = .searchingForColon
            }
            else if char == ";" {
              
              state = .searchingForColon
              
              let increment = frame.count
              
              bufferLock.lock()
              readPtr = (readPtr + increment) & 0xff
              bufferCount -= increment
              bufferLock.unlock()
              
              if let frame = LCCCANFrame(networkId: networkId, message: frame) {
                
                frame.timeStamp = Date.timeIntervalSinceReferenceDate
                frame.timeSinceLastMessage = frame.timeStamp - lastTimeStamp
                lastTimeStamp = frame.timeStamp
                
                for (_, observer) in observers {
                  observer.lccCANFrameReceived?(frame: frame)
                }
                
              }

            }
            
          }
          
          index = (index + 1) & 0xff
          tempCount -= 1
          
        }
        
        doAgain = bufferCount >= minFrameSize
        
      }
      
      return

    }

    // LocoNet from here onwards
    

    while doAgain {
      
      doAgain = false
      
      // find the start of a message
      
      var opCodeFound : Bool
      
      opCodeFound = false
      
      bufferLock.lock()
      while bufferCount > 0 {
        let cc = buffer[readPtr]
        if ((cc & 0x80) != 0) {
          opCodeFound = true
          break
        }
        readPtr = (readPtr + 1) & 0xff
        bufferCount -= 1
      }
      bufferLock.unlock()
      
      if opCodeFound {
        
       var length = (buffer[readPtr] & 0b01100000) >> 5
        
        switch length {
        case 0b00 :
          length = 2
          break
        case 0b01 :
          length = 4
          break
        case 0b10 :
          length = 6
          break
        default :
          length = bufferCount > 1 ? buffer[(readPtr+1) & 0xff] : 0xff
          break
        }
        
        if length < 0xff && bufferCount >= length {
          
         var message : [UInt8] = [UInt8](repeating: 0x00, count:Int(length))
          
          var restart : Bool = false
          
          bufferLock.lock()
          
          var index : Int = 0
          
          while index < length {
            
            let cc = buffer[readPtr]
            
            // check that there are no high bits set in the data bytes
            
            if index > 0 && ((cc & 0x80) != 0x00) {
              restart = true
              break
            }
            
            message[index] = cc
            
            readPtr = (readPtr + 1) & 0xff
            index += 1
            bufferCount -= 1
            
          }
          
          // Do another loop if there are at least 2 bytes in the buffer
          
          doAgain = bufferCount > 1
          
          bufferLock.unlock()
          
          // Process message if no high bits set in data
          
          if !restart {
          
            let networkMessage = NetworkMessage(networkId: networkId, data: message)
            
            networkMessage.timeStamp = Date.timeIntervalSinceReferenceDate
            networkMessage.timeSinceLastMessage = networkMessage.timeStamp - lastTimeStamp
            lastTimeStamp = networkMessage.timeStamp
            
            if networkMessage.checkSumOK && networkMessage.messageType != .busy {
              
              var stopTimer = false
              
              outputQueueLock.lock()
              
              if interfaceState == .waitingForResponse &&
                outputQueue[0].isValidResponse(messageType: networkMessage.messageType) {
                
          //      if networkMessage.messageType != .programmerBusy {
                  
                  outputQueue.remove(at: 0)
                  
                  interfaceState = .spacing
                  
                  stopTimer = true
                  
            //    }
              
              }
              
              outputQueueLock.unlock()
              
              if stopTimer {
                stopSpacingTimer()
              }

              networkMessageReceived(message: networkMessage)
              
              let _ = networkMessage.messageType // Force slot update
              
              for observer in observers {
                
                observer.value.networkMessageReceived?(message: networkMessage)
                
                let progMessages : Set<NetworkMessageType> = [.progCmdAccepted, .progSlotDataP1, .progCmdAcceptedBlind]
                
                if progMessages.contains(networkMessage.messageType) {
                  observer.value.progMessageReceived?(message: networkMessage)
                }
                
              }
              
              if stopTimer {
                sendMessage()
              }
              
            }

          }
          
        }

      }

    }
  }
  
  public func serialPortWasRemovedFromSystem(_ serialPort: MTSerialPort) {
    
  }
  
  public var lccCANTransportLayer : LCCCANTransportLayer?
  
  public func serialPortWasOpened(_ serialPort: MTSerialPort) {
    self.serialPort = serialPort
    for observer in observers {
      observer.value.interfaceWasOpened?(interface: self)
    }
    if let network = self.network, network.networkType == .LCC, let networkLayer = networkController.lccNetworkLayer {
      lccCANTransportLayer = LCCCANTransportLayer(interface: self, nodeId: networkLayer.nodeId)
      networkLayer.addTransportLayer(transportLayer: lccCANTransportLayer!)
    }
    else if !isEdit {
      iplDiscover()
    }
  }
  
  public func serialPortWasClosed(_ serialPort: MTSerialPort) {
    self.serialPort = nil
    for observer in observers {
      observer.value.interfaceWasClosed?(interface: self)
    }
  }

}
