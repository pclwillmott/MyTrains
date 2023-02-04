//
//  IODeviceBXP88.swift
//  MyTrains
//
//  Created by Paul Willmott on 12/01/2023.
//

import Foundation
import AppKit

public class IODeviceBXP88 : IODevice {
  
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
        for ioFunction in ioChannel.ioFunctions {
          if let function = ioFunction as? IOFunctionBXP88Input {
            result.insert(function.address)
          }
        }
      }
      
      return result

    }
  }
  
  public var shortCircuitDetectionType : ShortCircuitDetectionType {
    get {
      return getNewState(switchNumber: 4) == .closed ? .slower : .normal
    }
    set(value) {
      setNewState(switchNumber: 4, value: value == .slower ? .closed : .thrown)
    }
  }

  public var isTranspondingEnabled : Bool {
    get {
      return getNewState(switchNumber: 5) == .closed
    }
    set(value) {
      setNewState(switchNumber: 5, value: value ? .closed : .thrown)
    }
  }

  public var isFastFindEnabled : Bool {
    get {
      return getNewState(switchNumber: 7) == .thrown
    }
    set(value) {
      setNewState(switchNumber: 7, value: value ? .thrown : .closed)
    }
  }

  public var isPowerManagerEnabled : Bool {
    get {
      return getNewState(switchNumber: 10) == .closed
    }
    set(value) {
      setNewState(switchNumber: 10, value: value ? .closed : .thrown)
    }
  }

  public var isPowerManagerReportingEnabled : Bool {
    get {
      return getNewState(switchNumber: 11) == .closed
    }
    set(value) {
      setNewState(switchNumber: 11, value: value ? .closed : .thrown)
    }
  }

  public var detectionSensitivity : DetectionSensitivity {
    get {
      return getNewState(switchNumber: 14) == .closed ? .high : .regular
    }
    set(value) {
      setNewState(switchNumber: 14, value: value == .high ? .closed : .thrown)
    }
  }

  public var sendOccupiedMessageWhenFaulted : Bool {
    get {
      return getNewState(switchNumber: 15) == .thrown
    }
    set(value) {
      setNewState(switchNumber: 15, value: value ? .thrown : .closed)
    }
  }

  public var isOpsModeReadbackEnabled : Bool {
    get {
      return getNewState(switchNumber: 33) == .thrown
    }
    set(value) {
      setNewState(switchNumber: 33, value: value ? .thrown : .closed)
    }
  }

  public var isSelectiveTranspondingEnabled : Bool {
    get {
      return getNewState(switchNumber: 50) == .thrown
    }
    set(value) {
      setNewState(switchNumber: 50, value: value ? .thrown : .closed)
    }
  }

  // MARK: Public Methods
  
  public func isOccupancyReportingEnabled(detectionSection:Int) -> Bool { // detectionSection: 1...8
    return getNewState(switchNumber: 40 + detectionSection) == .thrown
  }
  
  public func setOccupancyReportingEnabled(detectionSection:Int, isEnabled: Bool) {
    setNewState(switchNumber: 40 + detectionSection, value: isEnabled ? .thrown : .closed)
  }
  
  public func isTranspondingReportingEnabled(detectionSection:Int) -> Bool { // detectionSection: 1...8
    return getNewState(switchNumber: 50 + detectionSection) == .thrown
  }
  
  public func setTranspondingReportingEnabled(detectionSection:Int, isEnabled: Bool) {
    setNewState(switchNumber: 50 + detectionSection, value: isEnabled ? .thrown : .closed)
  }
  
  override public func setBoardId(newBoardId:Int) {

    if let network = network, let interface = network.interface {
      
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
    
    shortCircuitDetectionType = .normal
    
    isTranspondingEnabled = true
    
    isFastFindEnabled = true
    
    isPowerManagerEnabled = true
    
    isPowerManagerReportingEnabled = true
    
    detectionSensitivity = .regular
    
    sendOccupiedMessageWhenFaulted = true
    
    isSelectiveTranspondingEnabled = true
    
    for detectionSection in 1...8 {
      setOccupancyReportingEnabled(detectionSection: detectionSection, isEnabled: true)
      setTranspondingReportingEnabled(detectionSection: detectionSection, isEnabled: true)
    }
    
  }
  
  override public func decode(sqliteDataReader:SqliteDataReader?) {
    
    super.decode(sqliteDataReader: sqliteDataReader)

    for channelNumber in 1...8 {
      let ioChannel = IOChannelBXP88Input(ioDevice: self, ioChannelNumber: channelNumber)
      ioChannels.append(ioChannel)
      ioChannel.ioFunctions = IOFunction.functions(ioChannel: ioChannel)
    }

  }
  
  override public func save() {
    
    super.save()
    
    if ioChannels.count == 0 {
      
      for channelNumber in 1...8 {
        let ioChannel = IOChannelBXP88Input(ioDevice: self, ioChannelNumber: channelNumber)
        ioChannels.append(ioChannel)
        for function in 1...3 {
          let ioFunction = IOFunctionBXP88Input(ioChannel: ioChannel, ioFunctionNumber: function)
          switch ioFunction.ioFunctionNumber {
          case 1:
            ioFunction.sensorType = .occupancy
          case 2:
            ioFunction.sensorType = .transponder
          case 3:
            ioFunction.sensorType = .trackFault
          default:
            break
          }
          ioChannel.ioFunctions.append(ioFunction)
        }
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
    
    let x = ModalWindow.IODeviceBXP88PropertySheet
    let wc = x.windowController
    let vc = x.viewController(windowController: wc) as! IODeviceBXP88PropertySheetVC
    vc.ioDevice = self
    propertySheetDelegate = vc
    if let window = wc.window {
      NSApplication.shared.runModal(for: window)
      window.close()
    }

  }

}
