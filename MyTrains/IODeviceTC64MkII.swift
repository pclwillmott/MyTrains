//
//  IODeviceTC64MkII.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/01/2023.
//

import Foundation
import AppKit

public class IODeviceTC64MkII : IODevice {
  
  // MARK: Public Properties
  
  public var firmwareVersion : Int {
    get {
      return cvs[6].nextCVValue
    }
  }
  
  public var manufacturerId : Int {
    get {
      return cvs[7].nextCVValue
    }
  }
  
  public var hardwareId : Int {
    get {
      return cvs[8].nextCVValue
    }
  }
  
  public var isPortStateEnabled : Bool {
    get {
      let cv112 = cvs[111]
      let mask : Int = 0b00000001
      return (cv112.nextCVValue & mask) == mask
    }
    set(value) {
      let cv112 = cvs[111]
      let mask : Int = 0b00000001
      cv112.nextCVValue = (cv112.nextCVValue & ~mask) | (value ? mask : 0)
    }
  }
  
  public var isOpsModeEnabled : Bool {
    get {
      let cv112 = cvs[111]
      let mask : Int = 0b00000010
      return (cv112.nextCVValue & mask) == mask
    }
    set(value) {
      let cv112 = cvs[111]
      let mask : Int = 0b00000010
      cv112.nextCVValue = (cv112.nextCVValue & ~mask) | (value ? mask : 0)
    }
  }
  
  public var isInterrogatePwrOnEnabled : Bool {
    get {
      let cv112 = cvs[111]
      let mask : Int = 0b00000100
      return (cv112.nextCVValue & mask) == mask
    }
    set(value) {
      let cv112 = cvs[111]
      let mask : Int = 0b00000100
      cv112.nextCVValue = (cv112.nextCVValue & ~mask) | (value ? mask : 0)
    }
  }
  
  public var isInterrogateInputs : Bool {
    get {
      let cv112 = cvs[111]
      let mask : Int = 0b00001000
      return (cv112.nextCVValue & mask) == mask
    }
    set(value) {
      let cv112 = cvs[111]
      let mask : Int = 0b00001000
      cv112.nextCVValue = (cv112.nextCVValue & ~mask) | (value ? mask : 0)
    }
  }

  public var isInterrogateOutputs : Bool {
    get {
      let cv112 = cvs[111]
      let mask : Int = 0b00010000
      return (cv112.nextCVValue & mask) == mask
    }
    set(value) {
      let cv112 = cvs[111]
      let mask : Int = 0b00010000
      cv112.nextCVValue = (cv112.nextCVValue & ~mask) | (value ? mask : 0)
    }
  }
  
  public var isMasterModeEnabled : Bool {
    get {
      let cv112 = cvs[111]
      let mask : Int = 0b10000000
      return (cv112.nextCVValue & mask) == mask
    }
    set(value) {
      let cv112 = cvs[111]
      let mask : Int = 0b10000000
      cv112.nextCVValue = (cv112.nextCVValue & ~mask) | (value ? mask : 0)
    }
  }
  
  public var flashRewriteCount : Int {
    get {
      let cv113 : Int = cvs[112].nextCVValue
      let cv114 : Int = cvs[113].nextCVValue
      let cv115 : Int = cvs[114].nextCVValue
      return cv113 | (cv114 << 8) | (cv115 << 16)
    }
  }

  // MARK: Public Methods
  
  public func readDeviceCVs() {
    var selectedCVs : Set<Int> = [7, 8, 9, 17, 18, 112, 113, 114, 115]
    readCVs(selectedCVs: selectedCVs)
  }
  
  public func writeDeviceCVs() {
    var selectedCVs : Set<Int> = [17, 18, 112]
    writeCVs(selectedCVs: selectedCVs)
  }

  public func readChannelCVs(ioChannelNumber:Int) {
    var selectedCVs : Set<Int> = []
    let baseCV = 129 + (ioChannelNumber - 1) * 8
    for cvNumber in baseCV...baseCV + 7 {
      selectedCVs.insert(cvNumber)
    }
    readCVs(selectedCVs: selectedCVs)
  }

  public func writeChannelCVs(ioChannelNumber:Int) {
    var selectedCVs : Set<Int> = []
    let baseCV = 129 + (ioChannelNumber - 1) * 8
    for cvNumber in baseCV...baseCV + 7 {
      selectedCVs.insert(cvNumber)
    }
    writeCVs(selectedCVs: selectedCVs)
  }

  override public func decode(sqliteDataReader:SqliteDataReader?) {
    
    super.decode(sqliteDataReader: sqliteDataReader)

    for channelNumber in 1...64 {
      let ioChannel = IOChannelTC64MkII(ioDevice: self, ioChannelNumber: channelNumber)
      ioChannels.append(ioChannel)
      ioChannel.ioFunctions = IOFunction.functions(ioChannel: ioChannel)
    }

  }
  
  override public func save() { 
    
    super.save()
    
    if ioChannels.count == 0 {
      
      for channelNumber in 1...64 {
        let ioChannel = IOChannelTC64MkII(ioDevice: self, ioChannelNumber: channelNumber)
        ioChannels.append(ioChannel)
        for functionNumber in 1...3 {
          let ioFunction = IOFunctionTC64MkII(ioChannel: ioChannel, ioFunctionNumber: functionNumber)
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
    
    let x = ModalWindow.IODeviceTC64MkIIPropertySheet
    let wc = x.windowController
    let vc = x.viewController(windowController: wc) as! IODeviceTC64MkIIPropertySheetVC
    vc.ioDevice = self
    propertySheetDelegate = vc
    if let window = wc.window {
      NSApplication.shared.runModal(for: window)
      window.close()
    }

  }

}
