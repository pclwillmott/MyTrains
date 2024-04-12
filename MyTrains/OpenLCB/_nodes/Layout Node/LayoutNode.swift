//
//  LayoutNode.swift
//  MyTrains
//
//  Created by Paul Willmott on 11/01/2024.
//

import Foundation

public class LayoutNode : OpenLCBNodeVirtual {
  
  // MARK: Constructors & Destructors
  
  public override init(nodeId:UInt64) {
    
    super.init(nodeId: nodeId)
    
    var configurationSize = 0
    
    initSpaceAddress(&addressScale, 1, &configurationSize)
    initSpaceAddress(&addressLayoutState, 1, &configurationSize)
    initSpaceAddress(&addressCountryCode, 2, &configurationSize)
    initSpaceAddress(&addressUsesMultipleTrackGauges, 1, &configurationSize)
    initSpaceAddress(&addressDefaultTrackGuage, 1, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintType0, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintValue0, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintType1, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintValue1, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintType2, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintValue2, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintType3, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintValue3, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintType4, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintValue4, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintType5, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintValue5, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintType6, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintValue6, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintType7, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintValue7, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintType8, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintValue8, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintType9, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintValue9, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintType10, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintValue10, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintType11, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintValue11, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintType12, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintValue12, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintType13, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintValue13, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintType14, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintValue14, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintType15, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintValue15, 2, &configurationSize)

    configuration = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, defaultMemorySize: configurationSize, isReadOnly: false, description: "")
    
    if let configuration {
      
      virtualNodeType = .layoutNode
      
      eventsConsumed = [
      ]
      
      eventsProduced = [
        OpenLCBWellKnownEvent.nodeIsAMyTrainsLayout.rawValue,
      ]
      
      eventsToSendAtStartup = [
        OpenLCBWellKnownEvent.nodeIsAMyTrainsLayout.rawValue,
      ]
      
      configuration.delegate = self
      
      memorySpaces[configuration.space] = configuration
      
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressScale)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressLayoutState)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressCountryCode)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressUsesMultipleTrackGauges)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressDefaultTrackGuage)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintType0)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintValue0)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintType1)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintValue1)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintType2)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintValue2)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintType3)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintValue3)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintType4)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintValue4)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintType5)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintValue5)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintType6)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintValue6)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintType7)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintValue7)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintType8)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintValue8)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintType9)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintValue9)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintType10)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintValue10)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintType11)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintValue11)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintType12)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintValue12)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintType13)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintValue13)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintType14)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintValue14)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintType15)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintValue15)
      
      configuration.registerUnitConversion(address: addressSpeedConstraintValue0, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintValue1, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintValue2, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintValue3, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintValue4, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintValue5, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintValue6, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintValue7, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintValue8, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintValue9, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintValue10, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintValue11, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintValue12, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintValue13, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintValue14, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintValue15, unitConversionType: .scaleSpeed2)
      
      if !memorySpacesInitialized {
        resetToFactoryDefaults()
      }
      
      cdiFilename = "MyTrains Layout"
      
    }
    
    #if DEBUG
    addInit()
    #endif
    
  }
  
  #if DEBUG
  deinit {
    addDeinit()
  }
  #endif
  
  // MARK: Private Properties
  
  // Configuration variable addresses
  
  internal var addressScale                   = 0
  internal var addressLayoutState             = 0
  internal var addressCountryCode             = 0
  internal var addressUsesMultipleTrackGauges = 0
  internal var addressDefaultTrackGuage       = 0
  internal var addressSpeedConstraintType0    = 0
  internal var addressSpeedConstraintValue0   = 0
  internal var addressSpeedConstraintType1    = 0
  internal var addressSpeedConstraintValue1   = 0
  internal var addressSpeedConstraintType2    = 0
  internal var addressSpeedConstraintValue2   = 0
  internal var addressSpeedConstraintType3    = 0
  internal var addressSpeedConstraintValue3   = 0
  internal var addressSpeedConstraintType4    = 0
  internal var addressSpeedConstraintValue4   = 0
  internal var addressSpeedConstraintType5    = 0
  internal var addressSpeedConstraintValue5   = 0
  internal var addressSpeedConstraintType6    = 0
  internal var addressSpeedConstraintValue6   = 0
  internal var addressSpeedConstraintType7    = 0
  internal var addressSpeedConstraintValue7   = 0
  internal var addressSpeedConstraintType8    = 0
  internal var addressSpeedConstraintValue8   = 0
  internal var addressSpeedConstraintType9    = 0
  internal var addressSpeedConstraintValue9   = 0
  internal var addressSpeedConstraintType10   = 0
  internal var addressSpeedConstraintValue10  = 0
  internal var addressSpeedConstraintType11   = 0
  internal var addressSpeedConstraintValue11  = 0
  internal var addressSpeedConstraintType12   = 0
  internal var addressSpeedConstraintValue12  = 0
  internal var addressSpeedConstraintType13   = 0
  internal var addressSpeedConstraintValue13  = 0
  internal var addressSpeedConstraintType14   = 0
  internal var addressSpeedConstraintValue14  = 0
  internal var addressSpeedConstraintType15   = 0
  internal var addressSpeedConstraintValue15  = 0

  // MARK: Public Properties
  
  public var scale : Scale {
    get {
      return Scale(rawValue: configuration!.getUInt8(address: addressScale)!)!
    }
    set(value) {
      configuration!.setUInt(address: addressScale, value: value.rawValue)
      configuration!.save()
    }
  }

  public var layoutState : LayoutState {
    get {
      return LayoutState(rawValue: configuration!.getUInt8(address: addressLayoutState)!)!
    }
    set(value) {
      configuration!.setUInt(address: addressLayoutState, value: value.rawValue)
      configuration!.save()
    }
  }

  public var countryCode : CountryCode {
    get {
      return CountryCode(rawValue: configuration!.getUInt16(address: addressCountryCode)!)!
    }
    set(value) {
      configuration!.setUInt(address: addressCountryCode, value: value.rawValue)
    }
  }

  public var usesMultipleTrackGauges : Bool {
    get {
      return configuration!.getUInt8(address: addressUsesMultipleTrackGauges)! == 1
    }
    set(value) {
      configuration!.setUInt(address: addressUsesMultipleTrackGauges, value: value ? UInt8(1) : UInt8(0))
    }
  }

  public var defaultTrackGuage : TrackGauge {
    get {
      return TrackGauge(rawValue: configuration!.getUInt8(address: addressDefaultTrackGuage)!)!
    }
    set(value) {
      configuration!.setUInt(address: addressDefaultTrackGuage, value: value.rawValue)
    }
  }

  // MARK: Private Methods

  internal override func resetToFactoryDefaults() {
    
    super.resetToFactoryDefaults()
    
    countryCode = .unitedStates
    scale = .scale1to87dot1
    usesMultipleTrackGauges = false
    defaultTrackGuage = .ho
    
    saveMemorySpaces()
    
  }
  
  internal override func customizeDynamicCDI(cdi:String) -> String {
    var result = cdi
    result = Scale.insertMap(cdi: result)
    result = LayoutState.insertMap(cdi: result)
    result = CountryCode.insertMap(cdi: result)
    result = YesNo.insertMap(cdi: result)
    result = TrackGauge.insertMap(cdi: result)
    result = SpeedConstraintType.insertMap(cdi: result)
    result = result.replacingOccurrences(of: CDI.SCALE_SPEED_UNITS, with: appNode!.unitsScaleSpeed.symbol)
    return result
  }

  // MARK: OpenLCBNetworkLayerDelegate Methods
  
  public override func openLCBMessageReceived(message: OpenLCBMessage) {
    
    super.openLCBMessageReceived(message: message)
    
    switch message.messageTypeIndicator {
    default:
      break
    }
    
  }
  
}
