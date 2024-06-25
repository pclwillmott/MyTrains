//
//  SpeedProfile.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/06/2024.
//

import Foundation

public class SpeedProfile : NSObject {
  
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
    
    profile = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.speedProfile.rawValue, defaultMemorySize: configurationSize, isReadOnly: false, description: "")

    super.init()
    
    // Set Defaults
    
    if numberOfSamples == 0 {
      trackProtocol = .dcc128
      numberOfSamples = trackProtocol.numberOfSamples
      startSampleNumber = 1
      stopSampleNumber = numberOfSamples - 1
      locomotiveControlBasis = .defaultValues
      locomotiveFacingDirection = .next
      locomotiveTravelDirection = .bothDirections
      minimumSamplePeriod = .sec30
      maximumSpeed = UnitSpeed.convert(fromValue: 126.0, fromUnits: .milesPerHour, toUnits: .defaultValueScaleSpeed)
      useLightSensors = true
      useReedSwitches = true
      useRFIDReaders = true
      useOccupancyDetectors = true
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
  
  // MARK: Public Properties
  
  public var nodeId : UInt64
  
  public let maxSamples = 512
  
  public var name : String {
    guard let appNode, let name = appNode.locomotiveList[nodeId] else {
      return "UNKNOWN"
    }
    return name
  }
  
  public weak var delegate : SpeedProfileDelegate?
  
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
      delegate?.inspectorNeedsUpdate?(profile: self)
    }
  }
  
  public var startBlock : SwitchboardItemNode? {
    if startBlockId == 0 {
      return nil
    }
    return appNode?.speedProfilerBlocks[startBlockId]
  }
  
  public var endBlockId : UInt64 {
    get {
      return profile.getUInt64(address: addressEndBlockId)!
    }
    set(value) {
      profile.setUInt(address: addressEndBlockId, value: value)
      delegate?.inspectorNeedsUpdate?(profile: self)
    }
  }
  
  public var endBlock : SwitchboardItemNode? {
    if endBlockId == 0 {
      return nil
    }
    return appNode?.speedProfilerBlocks[endBlockId]
  }
  
  public var route : UInt16 {
    get {
      let id = profile.getUInt16(address: addressRoute)!
      if let layout = appNode?.layout, layout.loopSet(containing: startBlockId).contains(id) {
        return id
      }
      return 0
    }
    set(value) {
      profile.setUInt(address: addressRoute, value: value)
    }
  }
  
  public var routeSetNext : SWBRoute? {
    guard let layout = appNode?.layout, route != 0 else {
      return nil
    }
    return layout.getLoop(loopNumber: route, startBlock: startBlockId, direction: .next)
  }
  
  public var routeSetPrevious : SWBRoute? {
    guard let layout = appNode?.layout, route != 0 else {
      return nil
    }
    return layout.getLoop(loopNumber: route, startBlock: startBlockId, direction: .previous)
  }
  
  public var routeLength : Double {
    
    guard let appNode, let layout = appNode.layout else {
      return 0.0
    }
    
    switch routeType {
    case .loop:
      if route > 0 {
        return layout.loopLengths[Int(route - 1)]
      }
    case .straight:
      break
    }
    
    return 0.0
    
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
  
  public func setSampleTable(sampleTable:[[Double]]) {
    
    for index in 0 ... sampleTable.count - 1 {
      
      let row = sampleTable[index]
      
      setForwardSpeed(sampleNumber: UInt16(index), speed: row[1])
      setReverseSpeed(sampleNumber: UInt16(index), speed: row[2])
      
    }
    
    save()
    
  }
  
  public func getValue(property:SpeedProfilerInspectorProperty) -> String {
    
    switch property {
    case .locomotiveId:
      return "\(nodeId.toHexDotFormat(numberOfBytes: 6))"
    case .locomotiveName:
      return name
    case .trackProtocol:
      return trackProtocol.title
    case .locomotiveControlBasis:
      return locomotiveControlBasis.title
    case .locomotiveFacingDirection:
      return locomotiveFacingDirection.title
    case .maximumSpeed, .maximumSpeedLabel:
      
      let formatter = NumberFormatter()
      formatter.alwaysShowsDecimalSeparator = true
      formatter.maximumFractionDigits = 3
      formatter.minimumFractionDigits = 3
      formatter.numberStyle = .decimal

      let value = UnitSpeed.convert(fromValue: maximumSpeed, fromUnits: .defaultValueScaleSpeed, toUnits: appNode!.unitsScaleSpeed)
      
      return formatter.string(from: NSNumber(value: value)) ?? ""
      
    case .locomotiveTravelDirectionToSample:
      return locomotiveTravelDirection.title
    case .numberOfSamples, .numberOfSamplesLabel:
      return "\(numberOfSamples)"
    case .minimumSamplePeriod:
      return minimumSamplePeriod.title
    case .startSampleNumber:
      return "\(startSampleNumber)"
    case .stopSampleNumber:
      return "\(stopSampleNumber)"
    case .useLightSensors:
      return useLightSensors ? "true" : "false"
    case .useReedSwitches:
      return useReedSwitches ? "true" : "false"
    case .useRFIDReaders:
      return useRFIDReaders ? "true" : "false"
    case .useOccupancyDetectors:
      return useOccupancyDetectors ? "true" : "false"
    case .bestFitMethod:
      return bestFitMethod.title
    case .showTrendline:
      return showTrendline ? "true" : "false"
    case .routeType:
      return routeType.title
    case .startBlockId:
      if let startBlock {
        return startBlock.userNodeName
      }
      else {
        return ""
      }
        
    case .endBlockId:
      if let endBlock {
        return endBlock.userNodeName
      }
      else {
        return ""
      }
    case .route:
      return route == 0 ? "" : "\(route)"
    case .totalRouteLength:
      
      return "\(UnitLength.convert(fromValue: routeLength, fromUnits: .defaultValueActualLength, toUnits: appNode!.unitsActualLength))"
    case .routeSegments:
      return ""
    }
    
  }
  
  public func isValid(property:SpeedProfilerInspectorProperty, string:String) -> Bool {

    switch property {
    case .maximumSpeed:
      guard let value = Double(string), value > 0.0 else {
        return false
      }
    case .numberOfSamples:
      guard let value = UInt16(string), value > 0 && value <= 512 else {
        return false
      }
    case .startSampleNumber:
      guard let value = UInt16(string), value >= 0 && value < numberOfSamples else {
        return false
      }
    case .stopSampleNumber:
      guard let value = UInt16(string), value >= startSampleNumber && value < numberOfSamples else {
        return false
      }
    default:
      break
    }
    
    return true
    
  }
  
  public func setValue(property: SpeedProfilerInspectorProperty, string: String) {
    
    var inspectorNeedsUpdate = false
    var chartNeedsUpdate = false
    var tableNeedsReset = false
    
    switch property {
    case .trackProtocol:
      let temp = TrackProtocol(title: string)!
      if temp != trackProtocol {
        trackProtocol = temp
        if trackProtocol != .openLCB {
          numberOfSamples = trackProtocol.numberOfSamples
        }
        startSampleNumber = 0
        stopSampleNumber = numberOfSamples - 1
        tableNeedsReset = true
        inspectorNeedsUpdate = true
      }
    case .locomotiveControlBasis:
      locomotiveControlBasis = LocomotiveControlBasis(title: string)!
    case .locomotiveFacingDirection:
      locomotiveFacingDirection = RouteDirection(title: string)!
    case .maximumSpeed:
      let temp = UnitSpeed.convert(fromValue: Double(string)!, fromUnits: appNode!.unitsScaleSpeed, toUnits: .defaultValueScaleSpeed)
      if temp != maximumSpeed {
        maximumSpeed = temp
        tableNeedsReset = true
      }
    case .locomotiveTravelDirectionToSample:
      locomotiveTravelDirection = SamplingDirection(title: string)!
    case .numberOfSamples:
      let temp = UInt16(string)!
      if temp != numberOfSamples {
        numberOfSamples = temp
        tableNeedsReset = true
      }
    case .minimumSamplePeriod:
      minimumSamplePeriod = SamplePeriod(title: string)!
    case .startSampleNumber:
      startSampleNumber = UInt16(string)!
    case .stopSampleNumber:
      stopSampleNumber = UInt16(string)!
    case .useLightSensors:
      useLightSensors = string == "true"
    case .useReedSwitches:
      useReedSwitches = string == "true"
    case .useRFIDReaders:
      useRFIDReaders = string == "true"
    case .useOccupancyDetectors:
      useOccupancyDetectors = string == "true"
    case .bestFitMethod:
      bestFitMethod = BestFitMethod(title: string)!
      chartNeedsUpdate = true
    case .showTrendline:
      showTrendline = string == "true"
      chartNeedsUpdate = true
    case .routeType:
      routeType = SamplingRouteType(title: string)!
      if routeType == .loop {
        endBlockId = startBlockId
      }
      inspectorNeedsUpdate = true
    case .startBlockId:
      if let nodeId = appNode?.selectedSpeedProfilerBlock(title: string)?.nodeId {
        startBlockId = nodeId
      }
      else {
        startBlockId = 0
      }
      if routeType == .loop {
        endBlockId = startBlockId
      }
    case .endBlockId:
      if let nodeId = appNode?.selectedSpeedProfilerBlock(title: string)?.nodeId {
        endBlockId = nodeId
      }
      else {
        endBlockId = 0
      }
    case .route:
      route = string.trimmingCharacters(in: .whitespaces).isEmpty ? 0 : UInt16(string)!
    default:
      break
    }
    
    save()
    
    if inspectorNeedsUpdate {
      delegate?.inspectorNeedsUpdate?(profile: self)
    }
    
    if tableNeedsReset {
      resetTable()
    }
    
    if chartNeedsUpdate {
      delegate?.chartNeedsUpdate?(profile: self)
    }
    
  }
  
  public func save() {
    profile.save()
  }
  
  public func resetTable() {
    
    for index : UInt16 in 0 ... 511 {
      setForwardSpeed(sampleNumber: index, speed: 0.0)
      setReverseSpeed(sampleNumber: index, speed: 0.0)
    }
    
    save()
    
    delegate?.reloadSamples?(profile: self)
    
  }
  
}

