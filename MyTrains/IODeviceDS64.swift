//
//  IODeviceDS64.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/01/2023.
//

import Foundation
import AppKit

public class IODeviceDS64 : IODevice {
  
  // MARK: Private Properties
  
  private var timer : Timer?
  
  private var nextAddr : Int = 0
  
  // MARK: Public Properties
 
  public var baseSensorAddress : Int {
    get {
      return (boardId - 1) * 8 + 1
    }
  }

  override public var sensorAddresses : Set<Int> {
    get {
      
      var result : Set<Int> = []

      for ioChannel in ioChannels {
        if ioChannel.ioFunctions.count > 0, let ioFunction = ioChannel.ioFunctions[0] as? IOFunctionDS64Input {
          result.insert(ioFunction.address)
        }
      }
      
      return result

    }
  }

  override public var switchAddresses : Set<Int> {
    get {

      var result : Set<Int> = []

      for ioChannel in ioChannels {
        if ioChannel.ioFunctions.count > 0, let ioFunction = ioChannel.ioFunctions[0] as? IOFunctionDS64Output {
          result.insert(ioFunction.address)
        }
      }
      
      return result
      
    }
  }
  
  public var outputType : TurnoutMotorType {
    get {
      return getNewState(switchNumber: 1) == .closed ? .slowMotion : .solenoid
    }
    set(value) {
      setNewState(switchNumber: 1, value: value == .slowMotion ? .closed : .thrown)
    }
  }
  
  public var timing : Int {
    get {
      var result : Int = 0
      result |= ((getNewState(switchNumber: 2) == .closed) ? 0b0001 : 0)
      result |= ((getNewState(switchNumber: 3) == .closed) ? 0b0010 : 0)
      result |= ((getNewState(switchNumber: 4) == .closed) ? 0b0100 : 0)
      result |= ((getNewState(switchNumber: 5) == .closed) ? 0b1000 : 0)
      return result
    }
    set(value) {
      let x = value & 0x0f
      setNewState(switchNumber: 2, value: (x & 0b0001) == 0b0001 ? .closed : .thrown)
      setNewState(switchNumber: 3, value: (x & 0b0010) == 0b0010 ? .closed : .thrown)
      setNewState(switchNumber: 4, value: (x & 0b0100) == 0b0100 ? .closed : .thrown)
      setNewState(switchNumber: 5, value: (x & 0b1000) == 0b1000 ? .closed : .thrown)
    }
  }
  
  public var outputsPowerUpAtPowerOn : Bool {
    get {
      return getNewState(switchNumber: 6) == .thrown
    }
    set(value) {
      setNewState(switchNumber: 6, value: value ? .thrown : .closed)
    }
  }
  
  public var isLongStartUpDelay : Bool {
    get {
      return getNewState(switchNumber: 8) == .closed
    }
    set(value) {
      setNewState(switchNumber: 8, value: value ? .closed : .thrown)
    }
  }
  
  public var outputsDoNotShutOff : Bool {
    get {
      return getNewState(switchNumber: 8) == .thrown
    }
    set(value) {
      setNewState(switchNumber: 8, value: value ? .thrown : .closed)
    }
  }
  
  public var sensorMessageType : SensorMessageType {
    get {
      return getState(switchNumber: 21) == .thrown ? .generalSensorReport : .turnoutSensorState
    }
    set(value) {
      setNewState(switchNumber: 21, value: value == .generalSensorReport ? .thrown : .closed)
    }
  }
  
  public var isCrossingGate1Enabled : Bool {
    get {
      return getState(switchNumber: 17) == .closed
    }
    set(value) {
      setNewState(switchNumber: 17, value: value ? .closed : .thrown)
    }
  }
  
  public var isCrossingGate2Enabled : Bool {
    get {
      return getState(switchNumber: 18) == .closed
    }
    set(value) {
      setNewState(switchNumber: 18, value: value ? .closed : .thrown)
    }
  }
  
  public var isCrossingGate3Enabled : Bool {
    get {
      return getState(switchNumber: 19) == .closed
    }
    set(value) {
      setNewState(switchNumber: 19, value: value ? .closed : .thrown)
    }
  }
  
  public var isCrossingGate4Enabled : Bool {
    get {
      return getState(switchNumber: 20) == .closed
    }
    set(value) {
      setNewState(switchNumber: 20, value: value ? .closed : .thrown)
    }
  }

  public var obeySwitchCommandsFromTrackOnly : Bool {
    get {
      return getState(switchNumber: 14) == .closed
    }
    set(value) {
      setNewState(switchNumber: 14, value: value ? .closed : .thrown)
    }
  }

  public var isLocalRoutesEnabled : Bool {
    get {
      return getState(switchNumber: 16) == .thrown
    }
    set(value) {
      setNewState(switchNumber: 16, value: value ? .thrown : .closed)
    }
  }

  public var localRoutesUsingInputsEnabled : Bool {
    get {
      return getState(switchNumber: 11) == .closed
    }
    set(value) {
      setNewState(switchNumber: 11, value: value ? .closed : .thrown)
    }
  }

  public var ignoreSetSwCommands : Bool {
    get {
      return getState(switchNumber: 10) == .closed
    }
    set(value) {
      setNewState(switchNumber: 10, value: value ? .closed : .thrown)
    }
  }

  public var inputsForSensorMessagesOnly : Bool {
    get {
      return getState(switchNumber: 15) == .closed
    }
    set(value) {
      setNewState(switchNumber: 15, value: value ? .closed : .thrown)
    }
  }

  public var forcedOutputOnHigh : Bool {
    get {
      return getState(switchNumber: 12) == .closed
    }
    set(value) {
      setNewState(switchNumber: 12, value: value ? .closed : .thrown)
    }
  }

  public var inputsForSensorMessagesEnabled : Bool {
    get {
      return getState(switchNumber: 13) == .closed
    }
    set(value) {
      setNewState(switchNumber: 13, value: value ? .closed : .thrown)
    }
  }

  // MARK: Private Methods
  
  @objc func next() {
    
    if let network = self.network, let interface = network.interface as? InterfaceLocoNet {
      
      if nextAddr == 4 {
        
        stopTimer()
        
        upDateDelegate?.displayUpdate?(update: "Completed")
        
        upDateDelegate?.updateCompleted?(success: true)

        return
        
      }
      
      interface.setSw(switchNumber: ioChannels[8 + nextAddr].ioFunctions[0].address, state: .closed)
      
      nextAddr += 1
      
    }
    
  }
  
  func startTimer() {
    timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(next), userInfo: nil, repeats: true)
    RunLoop.current.add(timer!, forMode: .common)
  }
  
  func stopTimer() {
    timer?.invalidate()
    timer = nil
  }


  // MARK: Public Methods
  
  public func setSwitchAddresses() {
  
    if let message = OptionSwitch.enterSetSwitchAddressModeInstructions[locoNetProductId] {

      let alert = NSAlert()

      alert.messageText = message
      alert.informativeText = ""
      alert.addButton(withTitle: "OK")
      alert.alertStyle = .informational

      alert.runModal()
      
      upDateDelegate?.displayUpdate?(update: "Updating Switch Addresses")
      
      nextAddr = 0
      
      startTimer()
      
    }

  }
  
  override public func setBoardId(newBoardId:Int) {

    if let network = network, let interface = network.interface as? InterfaceLocoNet {
      
      if let message = OptionSwitch.enterSetBoardIdModeInstructions[locoNetProductId] {
        
        let alert = NSAlert()

        alert.messageText = message
        alert.informativeText = ""
        alert.addButton(withTitle: "OK")
        alert.alertStyle = .informational

        alert.runModal()
        
        upDateDelegate?.displayUpdate?(update: "Updating")
        
        while true {
          
          interface.setSw(switchNumber: newBoardId, state: .closed)
          
          let alertCheck = NSAlert()
          
          alertCheck.messageText = "Has the set Board ID command been accepted?"
          alertCheck.informativeText = "The LEDs should no longer be alternating between red and green."
          alertCheck.addButton(withTitle: "No")
          alertCheck.addButton(withTitle: "Yes")
          alertCheck.alertStyle = .informational
          
          if alertCheck.runModal() == NSApplication.ModalResponse.alertSecondButtonReturn {
            break
          }
          
        }
        
        boardId = newBoardId
        
        save()
        
      }
      
    }
    
  }
  
  override public func setDefaults() {
    
    outputType = .solenoid
    
    timing = 0
    
    outputsPowerUpAtPowerOn = true
    
    isLongStartUpDelay = false
    
    outputsDoNotShutOff = true
    
    ignoreSetSwCommands = false
    
    localRoutesUsingInputsEnabled = false
    
    forcedOutputOnHigh = false
    
    inputsForSensorMessagesEnabled = false
    
    obeySwitchCommandsFromTrackOnly = false
    
    inputsForSensorMessagesOnly = false
    
    isLocalRoutesEnabled = true
    
    isCrossingGate1Enabled = false
    
    isCrossingGate2Enabled = false
    
    isCrossingGate3Enabled = false
    
    isCrossingGate4Enabled = false
    
    sensorMessageType = .generalSensorReport
    
  }
  
  override public func decode(sqliteDataReader:SqliteDataReader?) {
    
    super.decode(sqliteDataReader: sqliteDataReader)

    for channelNumber in 1...8 {
      let ioChannel = IOChannelInput(ioDevice: self, ioChannelNumber: channelNumber)
      ioChannels.append(ioChannel)
      ioChannel.ioFunctions = IOFunction.functions(ioChannel: ioChannel)
    }

    for channelNumber in 9...12 {
      let ioChannel = IOChannelDS64Output(ioDevice: self, ioChannelNumber: channelNumber)
      ioChannels.append(ioChannel)
      ioChannel.ioFunctions = IOFunction.functions(ioChannel: ioChannel)
    }

  }
  
  override public func save() {
    
    super.save()
  
    if ioChannels.count == 0 {
      
      for channelNumber in 1...8 {
        let ioChannel = IOChannelInput(ioDevice: self, ioChannelNumber: channelNumber)
        ioChannels.append(ioChannel)
        let ioFunction = IOFunctionDS64Input(ioChannel: ioChannel, ioFunctionNumber: 1)
        ioChannel.ioFunctions.append(ioFunction)
      }

      for channelNumber in 9...12 {
        let ioChannel = IOChannelDS64Output(ioDevice: self, ioChannelNumber: channelNumber)
        ioChannels.append(ioChannel)
        let ioFunction = IOFunctionDS64Output(ioChannel: ioChannel, ioFunctionNumber: 1)
        ioFunction.address = channelNumber - 8
        ioChannel.ioFunctions.append(ioFunction)
      }

    }
    
    for ioChannel in ioChannels {
      ioChannel.save()
    }
    
  }
  
  override public var hasPropertySheet: Bool {
    get {
      return true
    }
  }
  
  override public func propertySheet() {
    
    let x = ModalWindow.IODeviceDS64PropertySheet
    let wc = x.windowController
    let vc = x.viewController(windowController: wc) as! IODeviceDS64PropertySheetVC
    vc.ioDevice = self
    propertySheetDelegate = vc
    if let window = wc.window {
      NSApplication.shared.runModal(for: window)
      window.close()
    }

  }
  
}
