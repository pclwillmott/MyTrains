//
//  IODevice.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/01/2023.
//

import Foundation
import AppKit

public class IODevice : LocoNetDevice, InterfaceDelegate {
  
  // MARK: Constructors & Destructors
  
  // MARK: Private Properties
  
  private var observerId : Int = -1
  
  private var selectedSwitches : Set<Int> = []
  
  private var opsSwTimer : Timer?
  
  private var isRead : Bool = true
  
  private var lastIndex : Int = 0
  
  private var noResponse : Bool = false
  
  private var lastMethod : OptionSwitchMethod = .OpMode
  
  private var inOpMode : Bool = false
  
  let series7CV : [Set<Int>] = [
    [ 1, 2, 3, 4, 5, 6, 7, 8],
    [ 9,10,11,12,13,14,15,16],
    [17,18,19,20,21,22,23,24],
    [25,26,27,28,29,30,31,32],
    [33,34,35,36,37,38,39,40],
    [41,42,43,44,45,46,47,48],
  ]
  
  
  // MARK: Public Properties
  
  public var propertySheetDelegate : IODevicePropertySheetDelegate?
  
  public var upDateDelegate : UpdateDelegate?
  
  public var hasPropertySheet : Bool {
    get {
      return false
    }
  }
  
  public var ioChannels : [IOChannel] = []
  
  public var sensorAddresses : Set<Int> {
    get {
      return []
    }
  }
  
  public var switchAddresses : Set<Int> {
    get {
      return []
    }
  }
  
  public var addressCollision : Bool {
    get {
      for ioFunction in networkController.ioFunctions(networkId: networkId) {
        let ioDevice = ioFunction.ioDevice
        if ioDevice != self {
          if !ioDevice.switchAddresses.intersection(self.switchAddresses).isEmpty || !ioDevice.sensorAddresses.intersection(self.sensorAddresses).isEmpty {
            return true
          }
        }
      }
      return false
    }
  }
  
  // MARK: Private Methods
  
  @objc func nextOpSw() {
    
    if noResponse {
      stopOpSwTimer()
      return
    }
    
    noResponse = true
    
    if let network = self.network, let interface = network.interface {
      
      if let method = methodForOpSw[.Series7], !method.intersection(selectedSwitches).isEmpty {
        
        lastIndex = 11
        
        for cv in series7CV {
          
          if !cv.intersection(selectedSwitches).isEmpty {
            
            lastMethod = .Series7
            
            if isRead {
              upDateDelegate?.displayUpdate?(update: "Reading CV\(lastIndex)")
              interface.getS7CV(device: self, cvNumber: lastIndex)
            }
            else {
              
              let value = newS7CV(cvNumber: lastIndex)
              
              upDateDelegate?.displayUpdate?(update: "Writing CV\(lastIndex)")
              interface.setS7CV(device: self, cvNumber: lastIndex, value: value)
              
              for opsw in cv {
                selectedSwitches.remove(opsw)
              }
              
              noResponse = false
              
            }
            
            return
            
          }
          
          lastIndex += 1
          
        }
        
      }
      
      else if let method = methodForOpSw[.OpSwDataAP1], !method.intersection(selectedSwitches).isEmpty {
        
        lastMethod = .OpSwDataAP1
        
        if isRead {
          upDateDelegate?.displayUpdate?(update: "Reading OpSw Data A")
          interface.getOpSwDataAP1()
        }
        else {
          
          upDateDelegate?.displayUpdate?(update: "Writing OpSw Data A")
          interface.setLocoSlotDataP1(slotData: newOpSwDataAP1)
          
          for switchNumber in 1...64 {
            if (switchNumber % 8) != 0 {
              selectedSwitches.remove(switchNumber)
            }
          }
          
        }
        
      }
      
      else if let method = methodForOpSw[.OpSwDataBP1], !method.intersection(selectedSwitches).isEmpty {
        
        lastMethod = .OpSwDataBP1
        
        if isRead {
          upDateDelegate?.displayUpdate?(update: "Reading OpSw Data B")
          interface.getOpSwDataBP1()
        }
        else {
          
          upDateDelegate?.displayUpdate?(update: "Writing OpSw Data B")
          interface.setLocoSlotDataP1(slotData: newOpSwDataBP1)
          
          for switchNumber in 65...128 {
            if (switchNumber % 8) != 0 {
              selectedSwitches.remove(switchNumber)
            }
          }
          
        }
        
      }
      
      else if let method = methodForOpSw[.BrdOpSw], !method.intersection(selectedSwitches).isEmpty {
        
        let intersect = method.intersection(selectedSwitches)
        
        lastIndex = intersect.first!
        
        lastMethod = .BrdOpSw
        
        if isRead {
          upDateDelegate?.displayUpdate?(update: "Reading OpSw #\(lastIndex)")
          interface.getBrdOpSwState(device: self, switchNumber: lastIndex) // TODO: Check that lastIndex is correct see wrrite code
        }
        else {
          if let opsw = optionSwitchDictionary[lastIndex] {
            upDateDelegate?.displayUpdate?(update: "Writing OpSw #\(opsw.switchNumber)")
            interface.setBrdOpSwState(device: self, switchNumber: opsw.switchNumber, state: opsw.newState)
            selectedSwitches.remove(lastIndex)
          }
        }
        
      }
      
      else if let method = methodForOpSw[.OpMode], !method.intersection(selectedSwitches).isEmpty {
        
        if !inOpMode, let message = OptionSwitch.enterOptionSwitchModeInstructions[locoNetProductId] {
          
          let alert = NSAlert()
          
          alert.messageText = message
          alert.informativeText = ""
          alert.addButton(withTitle: "OK")
          alert.alertStyle = .informational
          
          alert.runModal()
          
          inOpMode = true
          
        }
        
        let intersect = method.intersection(selectedSwitches)
        
        lastIndex = intersect.first!
        
        lastMethod = .OpMode
        
        if isRead {
          upDateDelegate?.displayUpdate?(update: "Reading OpSw #\(lastIndex)")
          interface.getSwState(switchNumber: lastIndex)
        }
        else {
          if let opsw = optionSwitchDictionary[lastIndex] {
            upDateDelegate?.displayUpdate?(update: "Writing OpSw #\(lastIndex)")
            interface.setSw(switchNumber: lastIndex, state: opsw.newState)
            selectedSwitches.remove(lastIndex)
          }
          noResponse = false
        }
        
      }
      
      else {
        stopOpSwTimer()
      }
      
    }
    
  }
  
  func startOpsSwTimer() {
    opsSwTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(nextOpSw), userInfo: nil, repeats: true)
    noResponse = false
    RunLoop.current.add(opsSwTimer!, forMode: .common)
  }
  
  func stopOpSwTimer() {
    
    opsSwTimer?.invalidate()
    opsSwTimer = nil
    
    if let network = self.network {
      network.interface?.removeObserver(id: observerId)
      observerId = -1
    }
    
    optionSwitchesOK = true
    
    save()
    
    if inOpMode, let message = OptionSwitch.exitOptionSwitchModeInstructions[locoNetProductId] {
      
      let alert = NSAlert()
      
      alert.messageText = message
      alert.informativeText = ""
      alert.addButton(withTitle: "OK")
      alert.alertStyle = .informational
      
      alert.runModal()
      
    }
    
    inOpMode = false
 
    let OK = selectedSwitches.count == 0
    
    upDateDelegate?.displayUpdate?(update: !OK ? "Timeout" : "Completed")
    upDateDelegate?.updateCompleted?(success: OK)

    propertySheetDelegate?.reloadData?()
    
  }
  
  
  // MARK: Public Methods
  
  public func propertySheet() {
  }
  
  public func setDefaults() {
  }
  
  public func setBoardId(newBoardId:Int) {
  }
  
  public func readOptionSwitches() {
    
    if let network = self.network, let interface = network.interface {
      if observerId != -1 {
        interface.removeObserver(id: observerId)
      }
      observerId = interface.addObserver(observer: self)
    }
    
    selectedSwitches.removeAll()
    
    selectedSwitches = optionSwitchSet
    
    if selectedSwitches.count > 0 {
      
      isRead = true
      
      startOpsSwTimer()
      
    }
    
  }
  
  public func writeOptionSwitches() {
    
    if let network = self.network, let interface = network.interface {
      if observerId != -1 {
        interface.removeObserver(id: observerId)
      }
      observerId = interface.addObserver(observer: self)
    }

    selectedSwitches.removeAll()
    
    selectedSwitches = optionSwitchesChangedSet
    
    if selectedSwitches.count > 0 {
      
      isRead = false
      
      startOpsSwTimer()
      
    }
    
  }
  
  // MARK: InterfaceDelegate Methods
  
  public func networkMessageReceived(message:NetworkMessage) {
    
    switch message.messageType {
      
    case .opSwDataAP1:
      
      guard lastMethod == .OpSwDataAP1 else {
        return
      }
      
      setState(opswDataAP1: message)
      
      for switchNumber in 1...64 {
        if (switchNumber % 8) != 0 {
          selectedSwitches.remove(switchNumber)
        }
      }
      
      noResponse = false
      
    case .opSwDataBP1:
      
      guard lastMethod == .OpSwDataBP1 else {
        return
      }
      
      setState(opswDataBP1: message)
      
      for switchNumber in 65...128 {
        if (switchNumber % 8) != 0 {
          selectedSwitches.remove(switchNumber)
        }
      }
      
      noResponse = false
      
    case .setSwAccepted:
      
      noResponse = false
      
    case .swState:
      
      guard lastMethod == .OpMode else {
        return
      }
      
      if let opsw = optionSwitchDictionary[lastIndex] {
        
        let mask : UInt8 = 0b00100000
        
        opsw.state = (message.message[2] & mask) == mask ? .closed : .thrown
        
        selectedSwitches.remove(lastIndex)
        
        noResponse = false
        
      }
      
    case .brdOpSwState:
      
      guard lastMethod == .BrdOpSw else {
        return
      }
      
      if let opsw = optionSwitchDictionary[lastIndex] {
        
        let mask : UInt8 = 0b00100000
        
        opsw.state = (message.message[2] & mask) == mask ? .closed : .thrown
        
        selectedSwitches.remove(lastIndex)
        
        noResponse = false
        
      }
      
    case .routesDisabled, .s7CVState, .immPacketBufferFull:
      
      guard lastMethod == .Series7 && isRead else {
        return
      }
      
      setState(cvNumber: lastIndex, s7CVState: message)
      
      let baseSwitchNumber = (lastIndex - 11) * 8 + 1
      
      for index in 0...7 {
        selectedSwitches.remove(baseSwitchNumber + index)
      }
      
      noResponse = false
      
    default:
      break
    }
    
  }

}
