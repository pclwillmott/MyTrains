//
//  OpenLCBDigitraxBXP88Node.swift
//  MyTrains
//
//  Created by Paul Willmott on 26/08/2023.
//

import Foundation
import AppKit

private enum ConfigState {
  case idle
  case waitingForDeviceData
  case gettingOptionSwitches
  case settingOptionSwitches
}

private enum BXP88OptionSwitches : UInt16 {
  
  case shortCircuitDetection          = 4
  case transpondingState              = 5
  case fastFindState                  = 7
  case powerManagerState              = 10
  case powerManagerReportingState     = 11
  case detectionSensitivity           = 14
  case occupiedWhenFaulted            = 15
  case operationsModeReadback         = 33
  case setFactoryDefaults             = 40
  case occupancyReportSection1        = 41
  case occupancyReportSection2        = 42
  case occupancyReportSection3        = 43
  case occupancyReportSection4        = 44
  case occupancyReportSection5        = 45
  case occupancyReportSection6        = 46
  case occupancyReportSection7        = 47
  case occupancyReportSection8        = 48
  case selectiveTranspondingDisabling = 50
  case transpondingReportSection1     = 51
  case transpondingReportSection2     = 52
  case transpondingReportSection3     = 53
  case transpondingReportSection4     = 54
  case transpondingReportSection5     = 55
  case transpondingReportSection6     = 56
  case transpondingReportSection7     = 57
  case transpondingReportSection8     = 58

}

public class OpenLCBDigitraxBXP88Node : OpenLCBNodeVirtual, LocoNetDelegate {
  
  // MARK: Constructors
  
  public override init(nodeId:UInt64) {
    
    super.init(nodeId: nodeId)
    
    var configurationSize = 0
 
    initSpaceAddress(&addressLocoNetGateway, 8, &configurationSize)
    initSpaceAddress(&addressBoardId, 2, &configurationSize)
    initSpaceAddress(&addressWriteBoardId, 1, &configurationSize)
    initSpaceAddress(&addressReadSettings, 1, &configurationSize)
    initSpaceAddress(&addressWriteChanges, 1, &configurationSize)
    initSpaceAddress(&addressResetToDefaults, 1, &configurationSize)
    initSpaceAddress(&addressPowerManagerStatus, 1, &configurationSize)
    initSpaceAddress(&addressPowerManagerReporting, 1, &configurationSize)
    initSpaceAddress(&addressShortCircuitDetectionType, 1, &configurationSize)
    initSpaceAddress(&addressOccupiedWhenFaulted, 1, &configurationSize)
    initSpaceAddress(&addressDetectionSensitivity, 1, &configurationSize)
    initSpaceAddress(&addressTranspondingState, 1, &configurationSize)
    initSpaceAddress(&addressFastFind, 1, &configurationSize)
    initSpaceAddress(&addressOperationsModeFeedback, 1, &configurationSize)
    initSpaceAddress(&addressSelectiveTransponding, 1, &configurationSize)
    
    initSpaceAddress(&addressHardwareOccupancyDetection0, 1, &configurationSize)
    initSpaceAddress(&addressTranspondingReporting0, 1, &configurationSize)
    initSpaceAddress(&addressEnterOccupancyEventId0, 8, &configurationSize)
    initSpaceAddress(&addressExitOccupancyEventId0, 8, &configurationSize)
    initSpaceAddress(&addressLocationServicesEventId0, 8, &configurationSize)
    initSpaceAddress(&addressTrackFaultEventId0, 8, &configurationSize)
    initSpaceAddress(&addressTrackFaultClearedEventId0, 8, &configurationSize)

    var temp = 0
    for _ in 1 ... numberOfChannels - 1 {
      initSpaceAddress(&temp, 1, &configurationSize)
      initSpaceAddress(&temp, 1, &configurationSize)
      initSpaceAddress(&temp, 8, &configurationSize)
      initSpaceAddress(&temp, 8, &configurationSize)
      initSpaceAddress(&temp, 8, &configurationSize)
      initSpaceAddress(&temp, 8, &configurationSize)
      initSpaceAddress(&temp, 8, &configurationSize)
    }
    
    configuration = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, defaultMemorySize: configurationSize, isReadOnly: false, description: "")
    
    if let configuration {
      
      virtualNodeType = MyTrainsVirtualNodeType.digitraxBXP88Node
      
      isDatagramProtocolSupported = true
      
      isIdentificationSupported = true
      
      isSimpleNodeInformationProtocolSupported = true
      
      configuration.delegate = self
      
      memorySpaces[configuration.space] = configuration
      
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressLocoNetGateway)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressBoardId)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressWriteBoardId)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressReadSettings)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressWriteChanges)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressResetToDefaults)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressPowerManagerStatus)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressPowerManagerReporting)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressShortCircuitDetectionType)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressOccupiedWhenFaulted)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressDetectionSensitivity)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressTranspondingState)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressFastFind)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressOperationsModeFeedback)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSelectiveTransponding)
      
      userConfigEventProducedAddresses = []
      userConfigEventConsumedAddresses = []

      for index in 0 ... numberOfChannels - 1 {
        
        let offset = index * zoneBlockSize
        
        registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressHardwareOccupancyDetection0 + offset)
        
        registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressTranspondingReporting0 + offset)
        
        registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressEnterOccupancyEventId0 + offset)
        
        registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressExitOccupancyEventId0 + offset)
        
        registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressLocationServicesEventId0 + offset)
        
        registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressTrackFaultEventId0 + offset)
        
        registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressTrackFaultClearedEventId0 + offset)
        
        userConfigEventProducedAddresses.insert(addressEnterOccupancyEventId0 + offset)
        userConfigEventProducedAddresses.insert(addressExitOccupancyEventId0 + offset)
        userConfigEventProducedAddresses.insert(addressLocationServicesEventId0 + offset)
        userConfigEventProducedAddresses.insert(addressTrackFaultEventId0 + offset)
        userConfigEventProducedAddresses.insert(addressTrackFaultClearedEventId0 + offset)

      }
      
      if !memorySpacesInitialized {
        resetToFactoryDefaults()
      }
      
      cdiFilename = "Digitrax BXP88"
      
    }
    
    #if DEBUG
    addInit()
    #endif
    
  }
  
  deinit {
    
    locoNet = nil
    
    trainNodeIdLookup.removeAll()
    
    eventQueue.removeAll()
    
    lastDetectionSectionShorted.removeAll()
    
    timeoutTimer?.invalidate()
    timeoutTimer = nil
    
    #if DEBUG
    addDeinit()
    #endif
    
  }
  
  // MARK: Private Properties
  
  internal var addressLocoNetGateway                       = 0
  internal var addressBoardId                              = 0
  internal var addressWriteBoardId                         = 0
  internal var addressReadSettings                         = 0
  internal var addressWriteChanges                         = 0
  internal var addressResetToDefaults                      = 0
  internal var addressPowerManagerStatus                   = 0
  internal var addressPowerManagerReporting                = 0
  internal var addressShortCircuitDetectionType            = 0
  internal var addressOccupiedWhenFaulted                  = 0
  internal var addressDetectionSensitivity                 = 0
  internal var addressTranspondingState                    = 0
  internal var addressFastFind                             = 0
  internal var addressOperationsModeFeedback               = 0
  internal var addressSelectiveTransponding                = 0
  
  /// Repeats 8 times
  ///
  internal var addressHardwareOccupancyDetection0          = 0 // 1
  internal var addressTranspondingReporting0               = 0 // 1
  internal var addressEnterOccupancyEventId0               = 0 // 8
  internal var addressExitOccupancyEventId0                = 0 // 8
  internal var addressLocationServicesEventId0             = 0 // 8
  internal var addressTrackFaultEventId0                   = 0 // 8
  internal var addressTrackFaultClearedEventId0            = 0 // 8 -> Total: 42
  
  internal var zoneBlockSize = 42

  internal var numberOfChannels : Int = 8
  
  private var locoNet : LocoNet?
  
  private var configState : ConfigState = .idle
  
  private var trainNodeIdLookup : [Int:UInt64] = [:]
  
  private var eventQueue : [(message:LocoNetMessage, eventId:UInt64, searchEventId:UInt64)] = []
  
  private var lastDetectionSectionShorted : [Bool] = []
  
  private var timeoutTimer : Timer?
  
  private var boardId : UInt16 {
    get {
      return configuration!.getUInt16(address: addressBoardId)!
    }
    set(value) {
      configuration!.setUInt(address: addressBoardId, value: value)
    }
  }
  
  private var isShortCircuitDetectionNormal : Bool {
    get {
      return configuration!.getUInt8(address: addressShortCircuitDetectionType)! == 0
    }
    set(value) {
      configuration!.setUInt(address: addressShortCircuitDetectionType, value: UInt8(value ? 0 : 1))
    }
  }
  
  private var isTranspondingEnabled : Bool {
    get {
      return configuration!.getUInt8(address: addressTranspondingState)! == 0
    }
    set(value) {
      configuration!.setUInt(address: addressTranspondingState, value: UInt8(value ? 0 : 1))
    }
  }
  
  private var isFastFindEnabled : Bool {
    get {
      return configuration!.getUInt8(address: addressFastFind)! == 0
    }
    set(value) {
      configuration!.setUInt(address: addressFastFind, value: UInt8(value ? 0 : 1))
    }
  }
  
  private var isPowerManagerEnabled : Bool {
    get {
      return configuration!.getUInt8(address: addressPowerManagerStatus)! == 0
    }
    set(value) {
      configuration!.setUInt(address: addressPowerManagerStatus, value: UInt8(value ? 0 : 1))
    }
  }
  
  private var isPowerManagerReportingEnabled : Bool {
    get {
      return configuration!.getUInt8(address: addressPowerManagerReporting)! == 0
    }
    set(value) {
      configuration!.setUInt(address: addressPowerManagerReporting, value: UInt8(value ? 0 : 1))
    }
  }
  
  private var isDetectionSensitivityRegular : Bool {
    get {
      return configuration!.getUInt8(address: addressDetectionSensitivity) == 0
    }
    set(value) {
      configuration!.setUInt(address: addressDetectionSensitivity, value: UInt8(value ? 0 : 1))
    }
  }
  
  private var isOccupiedMessageSentWhenFaulted : Bool {
    get {
      return configuration!.getUInt8(address: addressOccupiedWhenFaulted) == 0
    }
    set(value) {
      configuration!.setUInt(address: addressOccupiedWhenFaulted, value: UInt8(value ? 0 : 1))
    }
  }
  
  private var isOperationsModeReadbackEnabled : Bool {
    get {
      return configuration!.getUInt8(address: addressOperationsModeFeedback) == 0
    }
    set(value) {
      configuration!.setUInt(address: addressOperationsModeFeedback, value: UInt8(value ? 0 : 1))
    }
  }
  
  private var isSelectiveTranspondingDisablingAllowed : Bool {
    get {
      return configuration!.getUInt8(address: addressSelectiveTransponding) == 0
    }
    set(value) {
      configuration!.setUInt(address: addressSelectiveTransponding, value: UInt8(value ? 0 : 1))
    }
  }
  
  private var allDataOptionSwitches : [BXP88OptionSwitches] {
    
    let result : [BXP88OptionSwitches] = [
      .shortCircuitDetection,
      .transpondingState,
      .fastFindState,
      .powerManagerState,
      .powerManagerReportingState,
      .detectionSensitivity,
      .occupiedWhenFaulted,
      .operationsModeReadback,
      .occupancyReportSection1,
      .occupancyReportSection2,
      .occupancyReportSection3,
      .occupancyReportSection4,
      .occupancyReportSection5,
      .occupancyReportSection6,
      .occupancyReportSection7,
      .occupancyReportSection8,
      .selectiveTranspondingDisabling,
      .transpondingReportSection1,
      .transpondingReportSection2,
      .transpondingReportSection3,
      .transpondingReportSection4,
      .transpondingReportSection5,
      .transpondingReportSection6,
      .transpondingReportSection7,
      .transpondingReportSection8,
    ]
    
    return result
    
  }
  
  private var optionSwitchesToDo : [BXP88OptionSwitches] = []
  
  // MARK: Public Properties
  
  public let productCode : DigitraxProductCode = .BXP88
  
  public var locoNetGatewayNodeId : UInt64 {
    get {
      return configuration!.getUInt64(address: addressLocoNetGateway)!
    }
    set(value) {
      configuration!.setUInt(address: addressLocoNetGateway, value: value)
    }
  }

  // MARK: Private Methods
  
  private func setHardwareOccupancyDetectionState(zone:Int, value:Bool) {
    let baseAddress = baseAddress(zone: zone)
    configuration!.setUInt(address: addressHardwareOccupancyDetection0 + baseAddress, value: UInt8(value ? 0 : 1))
  }
  
  private func getHardwareOccupancyDetectionState(zone:Int) -> Bool {
    let baseAddress = baseAddress(zone: zone)
    return configuration!.getUInt8(address: addressHardwareOccupancyDetection0 + baseAddress) == 0
  }

  private func setTranspondingReportingState(zone:Int, value:Bool) {
    let baseAddress = baseAddress(zone: zone)
    configuration!.setUInt(address: addressTranspondingReporting0 + baseAddress, value: UInt8(value ? 0 : 1))
  }
  
  private func getTranspondingReportingState(zone:Int) -> Bool {
    let baseAddress = baseAddress(zone: zone)
    return configuration!.getUInt8(address: addressTranspondingReporting0 + baseAddress) == 0
  }

  private func setOpSw() {
    
    if let opSw = optionSwitchesToDo.first {
      
      var state : DCCSwitchState?
      
      switch opSw {
      case .shortCircuitDetection:
        state = isShortCircuitDetectionNormal ? .thrown : .closed
      case .transpondingState:
        state = isTranspondingEnabled ? .closed : .thrown
      case .fastFindState:
        state = isFastFindEnabled ? .thrown : .closed
      case .powerManagerState:
        state = isPowerManagerEnabled ? .closed : .thrown
      case .powerManagerReportingState:
        state = isPowerManagerReportingEnabled ? .closed : .thrown
      case .detectionSensitivity:
        state = isDetectionSensitivityRegular ? .thrown : .closed
      case .occupiedWhenFaulted:
        state = isOccupiedMessageSentWhenFaulted ? .thrown : .closed
      case .operationsModeReadback:
        state = isOperationsModeReadbackEnabled ? .thrown : .closed
      case .occupancyReportSection1:
        state = getHardwareOccupancyDetectionState(zone: 0) ? .thrown : .closed
      case .occupancyReportSection2:
        state = getHardwareOccupancyDetectionState(zone: 1) ? .thrown : .closed
      case .occupancyReportSection3:
        state = getHardwareOccupancyDetectionState(zone: 2) ? .thrown : .closed
      case .occupancyReportSection4:
        state = getHardwareOccupancyDetectionState(zone: 3) ? .thrown : .closed
      case .occupancyReportSection5:
        state = getHardwareOccupancyDetectionState(zone: 4) ? .thrown : .closed
      case .occupancyReportSection6:
        state = getHardwareOccupancyDetectionState(zone: 5) ? .thrown : .closed
      case .occupancyReportSection7:
        state = getHardwareOccupancyDetectionState(zone: 6) ? .thrown : .closed
      case .occupancyReportSection8:
        state = getHardwareOccupancyDetectionState(zone: 7) ? .thrown : .closed
      case .selectiveTranspondingDisabling:
        state = isSelectiveTranspondingDisablingAllowed ? .thrown : .closed
      case .transpondingReportSection1:
        state = getTranspondingReportingState(zone: 0) ? .thrown : .closed
      case .transpondingReportSection2:
        state = getTranspondingReportingState(zone: 1) ? .thrown : .closed
      case .transpondingReportSection3:
        state = getTranspondingReportingState(zone: 2) ? .thrown : .closed
      case .transpondingReportSection4:
        state = getTranspondingReportingState(zone: 3) ? .thrown : .closed
      case .transpondingReportSection5:
        state = getTranspondingReportingState(zone: 4) ? .thrown : .closed
      case .transpondingReportSection6:
        state = getTranspondingReportingState(zone: 5) ? .thrown : .closed
      case .transpondingReportSection7:
        state = getTranspondingReportingState(zone: 6) ? .thrown : .closed
      case .transpondingReportSection8:
        state = getTranspondingReportingState(zone: 7) ? .thrown : .closed
      default:
        break
      }
      if let state, let locoNet {
        configState = .settingOptionSwitches
        startTimeoutTimer(timeInterval: 1.0)
        locoNet.setSwWithAck(switchNumber: opSw.rawValue, state: state)
      }
    }
    else {
      configState = .idle
    }
    
  }
  
  private func baseAddress(zone:Int) -> Int {
    return zone * zoneBlockSize
  }
  
  private func enterOccupancyEventId(zone:Int) -> UInt64? {
    if let eventId = configuration!.getUInt64(address: addressEnterOccupancyEventId0 + baseAddress(zone: zone)), eventId != 0 {
      return eventId
    }
    return nil
  }

  private func exitOccupancyEventId(zone:Int) -> UInt64? {
    if let eventId = configuration!.getUInt64(address: addressExitOccupancyEventId0 + baseAddress(zone: zone)), eventId != 0 {
      return eventId
    }
    return nil
  }

  private func locationServicesEventId(zone:Int) -> UInt64? {
    if let eventId = configuration!.getUInt64(address: addressLocationServicesEventId0 + baseAddress(zone: zone)), eventId != 0 {
      return eventId
    }
    return nil
  }

  private func trackFaultEventId(zone:Int) -> UInt64? {
    if let eventId = configuration!.getUInt64(address: addressTrackFaultEventId0 + baseAddress(zone: zone)), eventId != 0 {
      return eventId
    }
    return nil
  }

  private func trackFaultClearedEventId(zone:Int) -> UInt64? {
    if let eventId = configuration!.getUInt64(address: addressTrackFaultClearedEventId0 + baseAddress(zone: zone)), eventId != 0 {
      return eventId
    }
    return nil
  }

  internal override func customizeDynamicCDI(cdi:String) -> String {
    
    var result = cdi
    
    if let appNode {
      result = appNode.insertLocoNetGatewayMap(cdi: result)
    }
    
    result = EnableState.insertMap(cdi: result)

    return result
    
  }
  
  internal override func resetToFactoryDefaults() {

    configuration!.zeroMemory()
    
    super.resetToFactoryDefaults()
    
    boardId = 1
    
    saveMemorySpaces()
    
  }

  internal override func resetReboot() {
    
    super.resetReboot()
    
    guard locoNetGatewayNodeId != 0 else {
      return
    }
    
    locoNet = LocoNet(gatewayNodeId: locoNetGatewayNodeId, node: self)
    locoNet?.start()
    locoNet?.delegate = self
    
  }
  
  private func enterOpSwMode() {
    
    if let message = OptionSwitch.enterOptionSwitchModeInstructions[productCode.locoNetDeviceId!] {
      
      let alert = NSAlert()
      
      alert.messageText = message
      alert.informativeText = ""
      alert.addButton(withTitle: "OK")
      alert.alertStyle = .informational
      
      alert.runModal()
    }
    
  }
  
  private func exitOpSwMode() {
    
    if let message = OptionSwitch.exitOptionSwitchModeInstructions[productCode.locoNetDeviceId!] {
      
      let alert = NSAlert()
      
      alert.messageText = message
      alert.informativeText = ""
      alert.addButton(withTitle: "OK")
      alert.alertStyle = .informational
      
      alert.runModal()
    }
    
  }
  
  @objc func timeoutTimerAction() {
    
    stopTimeoutTimer()
    
    let alert = NSAlert()

    alert.messageText = "The attempted operation failed due to a timeout."
    alert.informativeText = ""
    alert.addButton(withTitle: "OK")
    alert.alertStyle = .informational

    alert.runModal()
    
    if configState == .gettingOptionSwitches || configState == .settingOptionSwitches {
      exitOpSwMode()
    }

    configState = .idle
    
  }
  
  func startTimeoutTimer(timeInterval:TimeInterval) {
    
    timeoutTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(timeoutTimerAction), userInfo: nil, repeats: false)
    
    RunLoop.current.add(timeoutTimer!, forMode: .common)
    
  }
  
  func stopTimeoutTimer() {
    timeoutTimer?.invalidate()
    timeoutTimer = nil
  }
  
  // MARK: Public Methods
  
  public override func variableChanged(space:OpenLCBMemorySpace, address:Int) {
    
    switch address {
    case addressReadSettings:
      if configuration!.getUInt8(address: addressReadSettings) != 0 {
        configuration!.setUInt(address: addressReadSettings, value: UInt8(0))
        configuration!.save()
        configState = .waitingForDeviceData
        startTimeoutTimer(timeInterval: 3.0)
        locoNet?.iplDiscover(productCode: productCode)
      }
    case addressWriteChanges:
      if configuration!.getUInt8(address: addressWriteChanges) != 0 {
        configuration!.setUInt(address: addressWriteChanges, value: UInt8(0))
        configuration!.save()
        enterOpSwMode()
        optionSwitchesToDo = allDataOptionSwitches
        setOpSw()
      }
    case addressWriteBoardId:
      if configuration!.getUInt8(address: addressWriteBoardId) != 0 {
        configuration!.setUInt(address: addressWriteBoardId, value: UInt8(0))
        configuration!.save()
        setBoardId()
      }
    case addressResetToDefaults:
      if configuration!.getUInt8(address: addressResetToDefaults) != 0 {
        configuration!.setUInt(address: addressResetToDefaults, value: UInt8(0))
        resetToFactoryDefaults()
      }
    default:
      break
    }
    
  }
  
  public func setBoardId() {

    guard let locoNet else {
      return
    }
    
    if let message = OptionSwitch.enterSetBoardIdModeInstructions[productCode.locoNetDeviceId!] {
      
      let alert = NSAlert()

      alert.messageText = message
      alert.informativeText = ""
      alert.addButton(withTitle: "OK")
      alert.alertStyle = .informational

      alert.runModal()
      
      while true {
        
        locoNet.setSw(switchNumber: boardId, state: .closed)
        
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
        
    }

  }

  // MARK: OpenLCBNetworkLayerDelegate Methods
  
  public override func openLCBMessageReceived(message: OpenLCBMessage) {
    super.openLCBMessageReceived(message: message)
    locoNet?.openLCBMessageReceived(message: message)
  }
  
  // MARK: LocoNetDelegate Methods
  
  @objc public func locoNetMessageReceived(message:LocoNetMessage) {
    
    switch message.messageType {
      
    case .sensRepGenIn:
      
      if let sensorAddress = message.sensorAddress {
        
        let id = (sensorAddress - 1) / numberOfChannels + 1
 
        if id == boardId, let sensorState = message.sensorState {
          
          let zone = (sensorAddress - 1) % numberOfChannels
          
   //       print(" \(userNodeName) \(sensorState ? "enter" : "exit") id: \(id) zone: \(zone + 1) ")
          
          if sensorState, let eventId = enterOccupancyEventId(zone: zone) {
            sendEvent(eventId: eventId)
          }
          
          if !sensorState, let eventId = exitOccupancyEventId(zone: zone) {
            sendEvent(eventId: eventId)
          }

        }
        
      }
      
    case .transRep:
      
      let id = message.transponderZone! / numberOfChannels + 1
      
      if id == boardId, let transponderZone = message.transponderZone, let locomotiveAddress = message.locomotiveAddress, let trainNodeId = OpenLCBNodeRollingStock.mapDCCAddressToID(address: locomotiveAddress), let sensorState = message.sensorState {
        
        let zone = transponderZone % numberOfChannels
        
        if let eventId = locationServicesEventId(zone: zone) {
//          sendLocationServiceEvent(eventId: eventId, trainNodeId: trainNodeId, entryExit: sensorState ? .entryWithState : .exit, motionRelative: .unknown, motionAbsolute: .unknown, contentFormat: .occupancyInformationOnly, content: nil)
        }
        
      }
      
    case .pmRepBXP88:
      
      if let id = message.boardId, id == boardId, let shorted = message.detectionSectionShorted {
        if lastDetectionSectionShorted.isEmpty {
          for zone in 0...numberOfChannels - 1 {
            lastDetectionSectionShorted.append(!shorted[zone])
          }
        }
        for zone in 0...numberOfChannels - 1 {
          if lastDetectionSectionShorted[zone] != shorted[zone] {
 //           print("\(shorted[zone] ? "short" : "short cleared") \(userNodeName) id: \(id) zone: \(zone + 1)")
            if shorted[zone], let eventId = trackFaultEventId(zone: zone) {
              sendEvent(eventId: eventId)
            }
            if !shorted[zone], let eventId = trackFaultClearedEventId(zone: zone) {
              sendEvent(eventId: eventId)
            }
          }
        }
        lastDetectionSectionShorted = shorted
      }
    
    case .locoRep:
      /*
      let id = message.transponderZone! / numberOfChannels + 1
       if id == boardId, let locomotiveAddress = message.locomotiveAddress, let transponderZone = message.transponderZone {
        let zone = transponderZone % numberOfChannels
  //      processEvents(zone: zone, eventType: .locomotiveReport, dccAddress: locomotiveAddress, trainNodeId: 0)
      }
      */
      break
      
    case .iplDevData:
      if configState == .waitingForDeviceData, let prod = message.productCode, prod == .BXP88, let id = message.boardId, id == boardId {
        stopTimeoutTimer()
        if userNodeName == virtualNodeType.defaultUserNodeName {
          userNodeName = "Digitrax BXP88 S/N: \(message.serialNumber!)"
        }
        nodeSoftwareVersion = "v\(message.softwareVersion!)"
        acdiUserSpace?.save()
        // Read Option Switches
        enterOpSwMode()
        configState = .gettingOptionSwitches
        optionSwitchesToDo = allDataOptionSwitches
        startTimeoutTimer(timeInterval: 1.0)
        locoNet?.getSwState(switchNumber: optionSwitchesToDo.first!.rawValue)
      }
      
    case .setSwWithAckAccepted:
      if configState == .settingOptionSwitches {
        stopTimeoutTimer()
        optionSwitchesToDo.removeFirst()
        if optionSwitchesToDo.isEmpty {
          configState = .idle
          exitOpSwMode()
        }
        else {
          setOpSw()
        }
      }
      
    case .setSwWithAckRejected:
      if configState == .settingOptionSwitches {
        stopTimeoutTimer()
        setOpSw()
      }
      
    case .swState:
      
      if configState == .gettingOptionSwitches, let opSw = optionSwitchesToDo.first, let state = message.swState {
        
        stopTimeoutTimer()
        
        switch opSw {
        case .shortCircuitDetection:
          isShortCircuitDetectionNormal = state == .thrown
        case .transpondingState:
          isTranspondingEnabled = state == .closed
        case .fastFindState:
          isFastFindEnabled = state == .thrown
        case .powerManagerState:
          isPowerManagerEnabled = state == .closed
        case .powerManagerReportingState:
          isPowerManagerReportingEnabled = state == .closed
        case .detectionSensitivity:
          isDetectionSensitivityRegular = state == .thrown
        case .occupiedWhenFaulted:
          isOccupiedMessageSentWhenFaulted = state == .thrown
        case .operationsModeReadback:
          isOperationsModeReadbackEnabled = state == .thrown
        case .occupancyReportSection1:
          setHardwareOccupancyDetectionState(zone: 0, value: state == .thrown)
        case .occupancyReportSection2:
          setHardwareOccupancyDetectionState(zone: 1, value: state == .thrown)
        case .occupancyReportSection3:
          setHardwareOccupancyDetectionState(zone: 2, value: state == .thrown)
        case .occupancyReportSection4:
          setHardwareOccupancyDetectionState(zone: 3, value: state == .thrown)
        case .occupancyReportSection5:
          setHardwareOccupancyDetectionState(zone: 4, value: state == .thrown)
        case .occupancyReportSection6:
          setHardwareOccupancyDetectionState(zone: 5, value: state == .thrown)
        case .occupancyReportSection7:
          setHardwareOccupancyDetectionState(zone: 6, value: state == .thrown)
        case .occupancyReportSection8:
          setHardwareOccupancyDetectionState(zone: 7, value: state == .thrown)
        case .selectiveTranspondingDisabling:
          isSelectiveTranspondingDisablingAllowed = state == .thrown
        case .transpondingReportSection1:
          setTranspondingReportingState(zone: 0, value: state == .thrown)
        case .transpondingReportSection2:
          setTranspondingReportingState(zone: 1, value: state == .thrown)
        case .transpondingReportSection3:
          setTranspondingReportingState(zone: 2, value: state == .thrown)
        case .transpondingReportSection4:
          setTranspondingReportingState(zone: 3, value: state == .thrown)
        case .transpondingReportSection5:
          setTranspondingReportingState(zone: 4, value: state == .thrown)
        case .transpondingReportSection6:
          setTranspondingReportingState(zone: 5, value: state == .thrown)
        case .transpondingReportSection7:
          setTranspondingReportingState(zone: 6, value: state == .thrown)
        case .transpondingReportSection8:
          setTranspondingReportingState(zone: 7, value: state == .thrown)
        default:
          break
        }
        optionSwitchesToDo.removeFirst()
        if let opSw = optionSwitchesToDo.first {
          startTimeoutTimer(timeInterval: 1.0)
          locoNet?.getSwState(switchNumber: opSw.rawValue)
        }
        else {
          configState = .idle
          configuration!.save()
          exitOpSwMode()
        }
      }
      
    default:
      break
    }
    
  }
  
}

