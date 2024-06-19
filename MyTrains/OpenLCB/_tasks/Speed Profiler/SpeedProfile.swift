//
//  SpeedProfile.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/06/2024.
//

import Foundation

public class SpeedProfile {
  
  // MARK: Constructors & Destructors
  
  init(nodeId:UInt64) {
    
    self.nodeId = nodeId
    
    var configurationSize = 0
    
    initSpaceAddress(&addressSamplesForward, 8, &configurationSize)
    initSpaceAddress(&addressSamplesReverse, 8, &configurationSize)
    
    var temp = 0
    for _ in 1 ... maxSamples {
      initSpaceAddress(&temp, 8, &configurationSize)
      initSpaceAddress(&temp, 8, &configurationSize)
    }
    
    initSpaceAddress(&addressTrackProtocol, 1, &configurationSize)
    initSpaceAddress(&addressLocoControlBasis, 1, &configurationSize)
    initSpaceAddress(&addressLocoFacingDirection, 1, &configurationSize)
    initSpaceAddress(&addressMaximumSpeed, 8, &configurationSize)
    initSpaceAddress(&addressLocoTravelDirection, 1, &configurationSize)
    initSpaceAddress(&addressNumberOfSamples, 2, &configurationSize)
    initSpaceAddress(&addressMinimumSamplePeriod, 1, &configurationSize)
    initSpaceAddress(&addressStartSampleNumber, 2, &configurationSize)
    initSpaceAddress(&addressStopSampleNumber, 2, &configurationSize)
    initSpaceAddress(&addressUseLightSensors, 1, &configurationSize)
    initSpaceAddress(&addressUseReedSwitches, 1, &configurationSize)
    initSpaceAddress(&addressUseRFIDReaders, 1, &configurationSize)
    initSpaceAddress(&addressUseOccupancyDetectors, 1, &configurationSize)
    initSpaceAddress(&addressBestFitMethod, 1, &configurationSize)
    initSpaceAddress(&addressShowTrendline, 1, &configurationSize)
    initSpaceAddress(&addressRouteType, 1, &configurationSize)
    initSpaceAddress(&addressStartBlockId, 8, &configurationSize)
    initSpaceAddress(&addressEndBlockId, 8, &configurationSize)
    initSpaceAddress(&addressRoute, 2, &configurationSize)
    initSpaceAddress(&addressTotalRouteLength, 8, &configurationSize)
    
    profile = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.speedProfile.rawValue, defaultMemorySize: configurationSize, isReadOnly: false, description: "")
    
    // Set Defaults
    
    if numberOfSamples == 0 {
      trackProtocol = .dcc128
      numberOfSamples = trackProtocol.numberOfSamples
      locomotiveControlBasis = .defaultValues
      locomotiveFacingDirection = .next
      locomotiveTravelDirection = .forward
      maximumSpeed = UnitSpeed.convert(fromValue: 126.0, fromUnits: .milesPerHour, toUnits: .metersPerSecond)
      profile.save()
    }
    
  }
  
  // MARK: Private Properties
  
  private var profile : OpenLCBMemorySpace
  
  private let sampleBlockSize = 16
  
  private var addressSamplesForward        = 0
  private var addressSamplesReverse        = 0
  private var addressTrackProtocol         = 0
  private var addressLocoControlBasis      = 0
  private var addressLocoFacingDirection   = 0
  private var addressMaximumSpeed          = 0
  private var addressLocoTravelDirection   = 0
  private var addressNumberOfSamples       = 0
  private var addressMinimumSamplePeriod   = 0
  private var addressStartSampleNumber     = 0
  private var addressStopSampleNumber      = 0
  private var addressUseLightSensors       = 0
  private var addressUseReedSwitches       = 0
  private var addressUseRFIDReaders        = 0
  private var addressUseOccupancyDetectors = 0
  private var addressBestFitMethod         = 0
  private var addressShowTrendline         = 0
  private var addressRouteType             = 0
  private var addressStartBlockId          = 0
  private var addressEndBlockId            = 0
  private var addressRoute                 = 0
  private var addressTotalRouteLength      = 0
  
  // MARK: Public Properties
  
  public var nodeId : UInt64
  
  public let maxSamples = 512
  
  public var name : String {
    guard let appNode, let name = appNode.locomotiveList[nodeId] else {
      return "UNKNOWN"
    }
    return name
  }
  
  public var trackProtocol : TrackProtocol {
    get {
      return TrackProtocol(rawValue: profile.getUInt8(address: addressTrackProtocol)!)!
    }
    set(value) {
      profile.setUInt(address: addressTrackProtocol, value: value.rawValue)
    }
  }
  
  public var locomotiveControlBasis : LocomotiveControlBasis {
    get {
      return LocomotiveControlBasis(rawValue: profile.getUInt8(address: addressLocoControlBasis)!)!
    }
    set(value) {
      profile.setUInt(address: addressLocoControlBasis, value: value.rawValue)
    }
  }
  
  public var locomotiveFacingDirection : RouteDirection {
    get {
      return RouteDirection(rawValue: profile.getUInt8(address: addressLocoFacingDirection)!)!
    }
    set(value) {
      profile.setUInt(address: addressLocoFacingDirection, value: value.rawValue)
    }
  }
  
  public var maximumSpeed : Double {
    get {
      return profile.getDouble(address: addressMaximumSpeed)!
    }
    set(value) {
      profile.setDouble(address: addressMaximumSpeed, value: value)
    }
  }
  
  public var locomotiveTravelDirection : SamplingDirection {
    get {
      return SamplingDirection(rawValue: profile.getUInt8(address: addressLocoTravelDirection)!)!
    }
    set(value) {
      profile.setUInt(address: addressLocoTravelDirection, value: value.rawValue)
    }
  }
  
  public var numberOfSamples : UInt16 {
    get {
      return profile.getUInt16(address: addressNumberOfSamples)!
    }
    set(value) {
      profile.setUInt(address: addressNumberOfSamples, value: value)
    }
  }
  
  public var minimumSamplePeriod : SamplePeriod {
    get {
      return SamplePeriod(rawValue: profile.getUInt8(address: addressMinimumSamplePeriod)!)!
    }
    set(value) {
      profile.setUInt(address: addressMinimumSamplePeriod, value: value.rawValue)
    }
  }
  
  public var startSampleNumber : UInt16 {
    get {
      return profile.getUInt16(address: addressStartSampleNumber)!
    }
    set(value) {
      profile.setUInt(address: addressStartSampleNumber, value: value)
    }
  }
  
  public var stopSampleNumber : UInt16 {
    get {
      return profile.getUInt16(address: addressStopSampleNumber)!
    }
    set(value) {
      profile.setUInt(address: addressStopSampleNumber, value: value)
    }
  }
  
  public var useLightSensors : Bool {
    get {
      return profile.getUInt8(address: addressUseLightSensors)! != 0
    }
    set(value) {
      profile.setUInt(address: addressUseLightSensors, value: value ? UInt8(1) : UInt8(0))
    }
  }
  
  public var useReedSwitches : Bool {
    get {
      return profile.getUInt8(address: addressUseReedSwitches)! != 0
    }
    set(value) {
      profile.setUInt(address: addressUseReedSwitches, value: value ? UInt8(1) : UInt8(0))
    }
  }
  
  public var useRFIDReaders : Bool {
    get {
      return profile.getUInt8(address: addressUseRFIDReaders)! != 0
    }
    set(value) {
      profile.setUInt(address: addressUseRFIDReaders, value: value ? UInt8(1) : UInt8(0))
    }
  }
  
  public var useOccupancyDetectors : Bool {
    get {
      return profile.getUInt8(address: addressUseOccupancyDetectors)! != 0
    }
    set(value) {
      profile.setUInt(address: addressUseOccupancyDetectors, value: value ? UInt8(1) : UInt8(0))
    }
  }
  
  public var bestFitMethod : BestFitMethod {
    get {
      return BestFitMethod(rawValue: profile.getUInt8(address: addressBestFitMethod)!)!
    }
    set(value) {
      profile.setUInt(address: addressBestFitMethod, value: value.rawValue)
    }
  }
  
  public var showTrendline : Bool {
    get {
      return profile.getUInt8(address: addressShowTrendline)! != 0
    }
    set(value) {
      profile.setUInt(address: addressShowTrendline, value: value ? UInt8(1) : UInt8(0))
    }
  }
  
  public var routeType : SamplingRouteType {
    get {
      return SamplingRouteType(rawValue: profile.getUInt8(address: addressRouteType)!)!
    }
    set(value) {
      profile.setUInt(address: addressRouteType, value: value.rawValue)
    }
  }
  
  public var startBlockId : UInt64 {
    get {
      return profile.getUInt64(address: addressStartBlockId)!
    }
    set(value) {
      profile.setUInt(address: addressStartBlockId, value: value)
    }
  }
  
  public var endBlockId : UInt64 {
    get {
      return profile.getUInt64(address: addressEndBlockId)!
    }
    set(value) {
      profile.setUInt(address: addressEndBlockId, value: value)
    }
  }
  
  public var route : UInt16 {
    get {
      return profile.getUInt16(address: addressRoute)!
    }
    set(value) {
      profile.setUInt(address: addressRoute, value: value)
    }
  }
  
  public var routeLength : Double {
    get {
      return profile.getDouble(address: addressTotalRouteLength)!
    }
    set(value) {
      profile.setDouble(address: addressTotalRouteLength, value: value)
    }
  }
  
  // MARK: Public Methods
  
  public func getForwardSpeed(sampleNumber:UInt16) -> Double? {
    guard sampleNumber < maxSamples else {
      return nil
    }
    return profile.getDouble(address: addressSamplesForward + Int(sampleNumber) * sampleBlockSize)!
  }
  
  public func setForwardSpeed(sampleNumber:UInt16, speed:Double) {
    guard sampleNumber < maxSamples else {
      return
    }
    profile.setDouble(address: addressSamplesForward + Int(sampleNumber) * sampleBlockSize, value: speed)
  }
  
  public func getReverseSpeed(sampleNumber:UInt16) -> Double? {
    guard sampleNumber < maxSamples else {
      return nil
    }
    return profile.getDouble(address: addressSamplesReverse + Int(sampleNumber) * sampleBlockSize)!
  }

  public func setReverseSpeed(sampleNumber:UInt16, speed:Double) {
    guard sampleNumber < maxSamples else {
      return
    }
    profile.setDouble(address: addressSamplesReverse + Int(sampleNumber) * sampleBlockSize, value: speed)
  }
  
  public func getSampleTable() -> [[Double]] {
    
    var result : [[Double]] = []
    
    let increment = maximumSpeed
    
    for row in 0 ... numberOfSamples - 1 {
      result.append([
        increment * Double(row) / Double(numberOfSamples - 1),
        getForwardSpeed(sampleNumber: row)!,
        getReverseSpeed(sampleNumber: row)!,
      ])
    }
    
    return result
    
  }
  
}

