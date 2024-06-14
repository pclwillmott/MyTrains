//
//  OpenLCBDigitraxDS64Node.swift
//  MyTrains
//
//  Created by Paul Willmott on 05/06/2024.
//

import Foundation
import AppKit

private enum ConfigState {
  case idle
  case gettingOptionSwitches
  case settingOptionSwitches
  case settingSwitchAddresses
  case setSwitchState
}

private enum DS64OptionSwitches : Int, CaseIterable {
  
  // MARK: Enumeration
  
  case outputType = 1
  case pulseLength0 = 2
  case pulseLength1 = 3
  case pulseLength2 = 4
  case pulseLength3 = 5
  case powerUpToLastState = 6
  case startupDelay = 8
  case staticTimeout = 9
  case computerCommandsOnly = 10
  case routeCommandsFromLocalInputs = 11
  case sInputToggles = 12
  case allInputsAreSensors = 13
  case LocoNetCommandsPriority = 14
  case sensorMessagesOnly = 15
  case localRoutesEnabled = 16
  case crossingGate0FunctionEnabled = 17
  case crossingGate1FunctionEnabled = 18
  case crossingGate2FunctionEnabled = 19
  case crossingGate3FunctionEnabled = 20
  case locoNetMessageType = 21
  
}

public class OpenLCBDigitraxDS64Node : OpenLCBNodeVirtual, LocoNetGatewayDelegate {
  
  // MARK: Constructors
  
  public override init(nodeId:UInt64) {
    
    commandedState = [DCCSwitchState](repeating: .unknown, count: numberOfChannels)
    
    super.init(nodeId: nodeId)
    
    var configurationSize = 0
 
    initSpaceAddress(&addressLocoNetGateway, 8, &configurationSize)
    initSpaceAddress(&addressBoardId, 2, &configurationSize)
    initSpaceAddress(&addressWriteBoardId, 1, &configurationSize)
    initSpaceAddress(&addressWriteSwitchAddresses, 1, &configurationSize)
    initSpaceAddress(&addressReadSettings, 1, &configurationSize)
    initSpaceAddress(&addressWriteChanges, 1, &configurationSize)
    initSpaceAddress(&addressResetToDefaults, 1, &configurationSize)
    initSpaceAddress(&addressOutputType, 1, &configurationSize)
    initSpaceAddress(&addressPulseLength, 1, &configurationSize)
    initSpaceAddress(&addressPowerUpToLastState, 1, &configurationSize)
    initSpaceAddress(&addressRegularStartupDelay, 1, &configurationSize)
    initSpaceAddress(&addressStaticTimeout, 1, &configurationSize)
    initSpaceAddress(&addressComputerCommandsOnly, 1, &configurationSize)
    initSpaceAddress(&addressLocoNetCommandsPriority, 1, &configurationSize)
    initSpaceAddress(&addressRouteCommandsFromLocalInputs, 1, &configurationSize)
    initSpaceAddress(&addressLocalRoutesEnabled, 1, &configurationSize)
    initSpaceAddress(&addressLocoNetSensorMessageType, 1, &configurationSize)
    initSpaceAddress(&addressSInputToggles, 1, &configurationSize)
    initSpaceAddress(&addressAllInputsAreSensors, 1, &configurationSize)
    initSpaceAddress(&addressSensorMessagesOnly, 1, &configurationSize)

    initSpaceAddress(&addressASensorThrownEventId0, 8, &configurationSize)
    initSpaceAddress(&addressASensorClosedEventId0, 8, &configurationSize)
    initSpaceAddress(&addressSSensorThrownEventId0, 8, &configurationSize)
    initSpaceAddress(&addressSSensorClosedEventId0, 8, &configurationSize)
    initSpaceAddress(&addressSwitchAddress0, 2, &configurationSize)
    initSpaceAddress(&addressThrowEventId0, 8, &configurationSize)
    initSpaceAddress(&addressCommandedThrownEventId0, 8, &configurationSize)
    initSpaceAddress(&addressCloseEventId0, 8, &configurationSize)
    initSpaceAddress(&addressCommandedClosedEventId0, 8, &configurationSize)
    initSpaceAddress(&addressCrossingGateFeatureEnable0, 1, &configurationSize)

    var temp = 0
    for _ in 1 ... numberOfChannels - 1 {
      initSpaceAddress(&temp, 8, &configurationSize)
      initSpaceAddress(&temp, 8, &configurationSize)
      initSpaceAddress(&temp, 8, &configurationSize)
      initSpaceAddress(&temp, 8, &configurationSize)
      initSpaceAddress(&temp, 2, &configurationSize)
      initSpaceAddress(&temp, 8, &configurationSize)
      initSpaceAddress(&temp, 8, &configurationSize)
      initSpaceAddress(&temp, 8, &configurationSize)
      initSpaceAddress(&temp, 8, &configurationSize)
      initSpaceAddress(&temp, 1, &configurationSize)
    }
    
    configuration = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, defaultMemorySize: configurationSize, isReadOnly: false, description: "")
    
    if let configuration {
      
      virtualNodeType = MyTrainsVirtualNodeType.digitraxDS64Node
      
      isDatagramProtocolSupported = true
      
      isIdentificationSupported = true
      
      isSimpleNodeInformationProtocolSupported = true
      
      configuration.delegate = self
      
      memorySpaces[configuration.space] = configuration
      
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressLocoNetGateway)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressBoardId)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressWriteBoardId)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressWriteSwitchAddresses)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressReadSettings)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressWriteChanges)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressResetToDefaults)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressOutputType)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressPulseLength)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressPowerUpToLastState)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressRegularStartupDelay)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressStaticTimeout)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressComputerCommandsOnly)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressLocoNetCommandsPriority)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressRouteCommandsFromLocalInputs)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressLocalRoutesEnabled)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressLocoNetSensorMessageType)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSInputToggles)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressAllInputsAreSensors)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSensorMessagesOnly)

      userConfigEventProducedAddresses = []
      userConfigEventConsumedAddresses = []

      for index in 0 ... numberOfChannels - 1 {
        
        let offset = index * zoneBlockSize
        
        registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressASensorThrownEventId0 + offset)
        registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressASensorClosedEventId0 + offset)
        registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSSensorThrownEventId0 + offset)
        registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSSensorClosedEventId0 + offset)
        registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSwitchAddress0 + offset)
        registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressThrowEventId0 + offset)
        registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressCommandedThrownEventId0 + offset)
        registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressCloseEventId0 + offset)
        registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressCommandedClosedEventId0 + offset)
        registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressCrossingGateFeatureEnable0 + offset)

        
        userConfigEventProducedAddresses.insert(addressASensorThrownEventId0 + offset)
        userConfigEventProducedAddresses.insert(addressASensorClosedEventId0 + offset)
        userConfigEventProducedAddresses.insert(addressSSensorThrownEventId0 + offset)
        userConfigEventProducedAddresses.insert(addressSSensorClosedEventId0 + offset)
        userConfigEventProducedAddresses.insert(addressCommandedThrownEventId0 + offset)
        userConfigEventProducedAddresses.insert(addressCommandedClosedEventId0 + offset)

        userConfigEventConsumedAddresses.insert(addressThrowEventId0 + offset)
        userConfigEventConsumedAddresses.insert(addressCloseEventId0 + offset)

      }
      
      if !memorySpacesInitialized {
        resetToFactoryDefaults()
      }
      
      cdiFilename = "Digitrax DS64"
      
      makeLookups()
      
    }
    
  }
  
  deinit {
    
    timeoutTimer?.invalidate()
    timeoutTimer = nil
    
  }
  
  // MARK: Private Properties
  
  internal var addressLocoNetGateway               = 0
  internal var addressBoardId                      = 0
  internal var addressWriteBoardId                 = 0
  internal var addressWriteSwitchAddresses         = 0
  internal var addressReadSettings                 = 0
  internal var addressWriteChanges                 = 0
  internal var addressResetToDefaults              = 0
  internal var addressOutputType                   = 0
  internal var addressPulseLength                  = 0
  internal var addressPowerUpToLastState           = 0
  internal var addressRegularStartupDelay          = 0
  internal var addressStaticTimeout                = 0
  internal var addressComputerCommandsOnly         = 0
  internal var addressLocoNetCommandsPriority      = 0
  internal var addressRouteCommandsFromLocalInputs = 0
  internal var addressLocalRoutesEnabled           = 0
  internal var addressLocoNetSensorMessageType     = 0
  internal var addressSInputToggles                = 0
  internal var addressAllInputsAreSensors          = 0
  internal var addressSensorMessagesOnly           = 0

  /// Repeats 4 times

  internal var addressASensorThrownEventId0      = 0 // 8
  internal var addressASensorClosedEventId0      = 0 // 8 16
  internal var addressSSensorThrownEventId0      = 0 // 8
  internal var addressSSensorClosedEventId0      = 0 // 8 32
  internal var addressSwitchAddress0             = 0 // 2 34
  internal var addressThrowEventId0              = 0 // 8 42
  internal var addressCommandedThrownEventId0    = 0 // 8 50
  internal var addressCloseEventId0              = 0 // 8 58
  internal var addressCommandedClosedEventId0    = 0 // 8 66
  internal var addressCrossingGateFeatureEnable0 = 0 // 1 -> 67

  internal var zoneBlockSize = 67

  internal var numberOfChannels : Int = 4
  
  private var configState : ConfigState = .idle
  
  private var optionSwitchesToDo : [DS64OptionSwitches] = []
  
  private var switchToWrite : Int = 0
  
  private var timeoutTimer : Timer?
  
  private var switchQueue : [(switchNumber:Int, state:DCCSwitchState, confirmEventId:UInt64?)] = []
  
  private var commandedState : [DCCSwitchState]
  
  private var turnoutLookup : [UInt64:(turnoutNumber:Int, state:DCCSwitchState, ackEventId:UInt64?)] = [:]
  
  private var boardId : UInt16 {
    get {
      return configuration!.getUInt16(address: addressBoardId)!
    }
    set(value) {
      configuration!.setUInt(address: addressBoardId, value: value)
    }
  }
  
  private var outputType : TurnoutMotorType {
    get {
      return configuration!.getUInt8(address: addressOutputType)! == 0 ? .solenoid : .slowMotion
    }
    set(value) {
      configuration!.setUInt(address: addressOutputType, value: UInt8(value == .solenoid ? 0 : 1))
    }
  }
  
  private var pulseLength : UInt8 {
    get {
      return configuration!.getUInt8(address: addressPulseLength)!
    }
    set(value) {
      configuration!.setUInt(address: addressPulseLength, value: value)
    }
  }
  
  private var willPowerUpToLastState : Bool {
    get {
      return configuration!.getUInt8(address: addressPowerUpToLastState)! == 0
    }
    set(value) {
      configuration!.setUInt(address: addressPowerUpToLastState, value: UInt8(value ? 0 : 1))
    }
  }
  
  private var isRegularStartupDelay : Bool {
    get {
      return configuration!.getUInt8(address: addressRegularStartupDelay)! == 0
    }
    set(value) {
      configuration!.setUInt(address: addressRegularStartupDelay, value: UInt8(value ? 0 : 1))
    }
  }
  
  private var willOutputsShutOff : Bool {
    get {
      return configuration!.getUInt8(address: addressStaticTimeout)! == 1
    }
    set(value) {
      configuration!.setUInt(address: addressStaticTimeout, value: UInt8(value ? 1 : 0))
    }
  }
  
  private var obeyComputerCommandsOnly : Bool {
    get {
      return configuration!.getUInt8(address: addressComputerCommandsOnly) == 1
    }
    set(value) {
      configuration!.setUInt(address: addressComputerCommandsOnly, value: UInt8(value ? 1 : 0))
    }
  }
  
  private var isLocoNetCommandsPriority : Bool {
    get {
      return configuration!.getUInt8(address: addressLocoNetCommandsPriority) == 0
    }
    set(value) {
      configuration!.setUInt(address: addressLocoNetCommandsPriority, value: UInt8(value ? 0 : 1))
    }
  }
  
  private var isRouteCommandsFromLocalInputs : Bool {
    get {
      return configuration!.getUInt8(address: addressRouteCommandsFromLocalInputs) == 1
    }
    set(value) {
      configuration!.setUInt(address: addressRouteCommandsFromLocalInputs, value: UInt8(value ? 1 : 0))
    }
  }
  
  private var isLocalRoutesEnabled : Bool {
    get {
      return configuration!.getUInt8(address: addressLocalRoutesEnabled) == 0
    }
    set(value) {
      configuration!.setUInt(address: addressLocalRoutesEnabled, value: UInt8(value ? 0 : 1))
    }
  }
  
  private var isMessageTypeGeneralSensor : Bool {
    get {
      return configuration!.getUInt8(address: addressLocoNetSensorMessageType) == 0
    }
    set(value) {
      configuration!.setUInt(address: addressLocoNetSensorMessageType, value: UInt8(value ? 0 : 1))
    }
  }

  private var isSInputToggles : Bool {
    get {
      return configuration!.getUInt8(address: addressSInputToggles) == 0
    }
    set(value) {
      configuration!.setUInt(address: addressSInputToggles, value: UInt8(value ? 0 : 1))
    }
  }

  private var isAllInputsAreSensors : Bool {
    get {
      return configuration!.getUInt8(address: addressAllInputsAreSensors) == 1
    }
    set(value) {
      configuration!.setUInt(address: addressAllInputsAreSensors, value: UInt8(value ? 1 : 0))
    }
  }

  private var isSensorMessagesOnly : Bool {
    get {
      return configuration!.getUInt8(address: addressSensorMessagesOnly) == 1
    }
    set(value) {
      configuration!.setUInt(address: addressSensorMessagesOnly, value: UInt8(value ? 1 : 0))
    }
  }
  
  private var _locoNetGateway : LocoNetGateway?

  // MARK: Public Properties
  
  public var locoNetGatewayNodeId : UInt64 {
    get {
      return configuration!.getUInt64(address: addressLocoNetGateway)!
    }
    set(value) {
      configuration!.setUInt(address: addressLocoNetGateway, value: value)
      _locoNetGateway = nil
    }
  }
  
  public var locoNetGateway : LocoNetGateway? {
    if let gateway = _locoNetGateway {
      return gateway
    }
    _locoNetGateway = appNode?.locoNetGateways[locoNetGatewayNodeId]
    return _locoNetGateway
  }

  // MARK: Private Methods
  
  private func makeLookups() {
  
    turnoutLookup.removeAll()
    
    for turnoutNumber in 0 ... 3 {
      
      if let eventId = getThrowEventId(zone: turnoutNumber) {
        turnoutLookup[eventId] = (turnoutNumber, .thrown, getCommandedThrownEventId(zone: turnoutNumber))
      }
      
      if let eventId = getCloseEventId(zone: turnoutNumber) {
        turnoutLookup[eventId] = (turnoutNumber, .closed, getCommandedClosedEventId(zone: turnoutNumber))
      }
      
    }
    
  }
  
  private func baseAddress(zone:Int) -> Int {
    return zone * zoneBlockSize
  }
  
  private func getASensorThrownEventId(zone:Int) -> UInt64? {
    if let eventId = configuration!.getUInt64(address: addressASensorThrownEventId0 + baseAddress(zone: zone)), eventId != 0 {
      return eventId
    }
    return nil
  }
  
  private func setASensorThrownEventId(zone:Int, eventId:UInt64?) {
    configuration!.setUInt(address: addressASensorThrownEventId0 + baseAddress(zone: zone), value: eventId ?? 0)
  }

  private func getASensorClosedEventId(zone:Int) -> UInt64? {
    if let eventId = configuration!.getUInt64(address: addressASensorClosedEventId0 + baseAddress(zone: zone)), eventId != 0 {
      return eventId
    }
    return nil
  }

  private func setASensorClosedEventId(zone:Int, eventId:UInt64?) {
    configuration!.setUInt(address: addressASensorClosedEventId0 + baseAddress(zone: zone), value: eventId ?? 0)
  }

  private func getSSensorThrownEventId(zone:Int) -> UInt64? {
    if let eventId = configuration!.getUInt64(address: addressSSensorThrownEventId0 + baseAddress(zone: zone)), eventId != 0 {
      return eventId
    }
    return nil
  }

  private func setSSensorThrownEventId(zone:Int, eventId:UInt64?) {
    configuration!.setUInt(address: addressSSensorThrownEventId0 + baseAddress(zone: zone), value: eventId ?? 0)
  }

  private func getSSensorClosedEventId(zone:Int) -> UInt64? {
    if let eventId = configuration!.getUInt64(address: addressSSensorClosedEventId0 + baseAddress(zone: zone)), eventId != 0 {
      return eventId
    }
    return nil
  }

  private func setSSensorClosedEventId(zone:Int, eventId:UInt64?) {
    configuration!.setUInt(address: addressSSensorClosedEventId0 + baseAddress(zone: zone), value: eventId ?? 0)
  }

  private func getSwitchAddress(zone:Int) -> UInt16 {
    return configuration!.getUInt16(address: addressSwitchAddress0 + baseAddress(zone: zone))!
  }

  private func setSwitchAddress(zone:Int, address:UInt16) {
    configuration!.setUInt(address: addressSwitchAddress0 + baseAddress(zone: zone), value: address)
  }

  private func setThrowEventId(zone:Int, eventId:UInt64?) {
    configuration!.setUInt(address: addressThrowEventId0 + baseAddress(zone: zone), value: eventId ?? 0)
    makeLookups()
  }

  private func getThrowEventId(zone:Int) -> UInt64? {
    if let eventId = configuration!.getUInt64(address: addressThrowEventId0 + baseAddress(zone: zone)), eventId != 0 {
      return eventId
    }
    return nil
  }

  private func setCommandedThrownEventId(zone:Int, eventId:UInt64?) {
    configuration!.setUInt(address: addressCommandedThrownEventId0 + baseAddress(zone: zone), value: eventId ?? 0)
  }

  private func getCommandedThrownEventId(zone:Int) -> UInt64? {
    if let eventId = configuration!.getUInt64(address: addressCommandedThrownEventId0 + baseAddress(zone: zone)), eventId != 0 {
      return eventId
    }
    return nil
  }

  private func setCloseEventId(zone:Int, eventId:UInt64?) {
    configuration!.setUInt(address: addressCloseEventId0 + baseAddress(zone: zone), value: eventId ?? 0)
    makeLookups()
  }

  private func getCloseEventId(zone:Int) -> UInt64? {
    if let eventId = configuration!.getUInt64(address: addressCloseEventId0 + baseAddress(zone: zone)), eventId != 0 {
      return eventId
    }
    return nil
  }

  private func setCommandedClosedEventId(zone:Int, eventId:UInt64?) {
    configuration!.setUInt(address: addressCommandedClosedEventId0 + baseAddress(zone: zone), value: eventId ?? 0)
  }

  private func getCommandedClosedEventId(zone:Int) -> UInt64? {
    if let eventId = configuration!.getUInt64(address: addressCommandedClosedEventId0 + baseAddress(zone: zone)), eventId != 0 {
      return eventId
    }
    return nil
  }
  
  private func getCrossingGateFeatureEnabledState(zone:Int) -> Bool {
    return configuration!.getUInt16(address: addressCrossingGateFeatureEnable0 + baseAddress(zone: zone))! == 1
  }

  private func setCrossGateFeatureEnabledState(zone:Int, isEnabled:Bool) {
    configuration!.setUInt(address: addressSwitchAddress0 + baseAddress(zone: zone), value: UInt8(isEnabled ? 1 : 0))
  }

  private func setOpSw() {
    
    if let opSw = optionSwitchesToDo.first {
      
      var state : DCCSwitchState?
      
      switch opSw {
      case .outputType:
        state = outputType == .solenoid ? .thrown : .closed
      case .pulseLength0:
        state = (pulseLength & 0b0001) != 0 ? .closed : .thrown
      case .pulseLength1:
        state = (pulseLength & 0b0010) != 0 ? .closed : .thrown
      case .pulseLength2:
        state = (pulseLength & 0b0100) != 0 ? .closed : .thrown
      case .pulseLength3:
        state = (pulseLength & 0b1000) != 0 ? .closed : .thrown
      case .powerUpToLastState:
        state = willPowerUpToLastState ? .thrown : .closed
      case .startupDelay:
        state = isRegularStartupDelay ? .thrown : .closed
      case .staticTimeout:
        state = willOutputsShutOff ? .closed : .thrown
      case .computerCommandsOnly:
        state = obeyComputerCommandsOnly ? .closed : .thrown
      case .routeCommandsFromLocalInputs:
        state = isRouteCommandsFromLocalInputs ? .closed : .thrown
      case .sInputToggles:
        state = isSInputToggles ? .thrown : .closed
      case .allInputsAreSensors:
        state = isAllInputsAreSensors ? .closed : .thrown
      case .LocoNetCommandsPriority:
        state = isLocoNetCommandsPriority ? .thrown : .closed
      case .sensorMessagesOnly:
        state = isSensorMessagesOnly ? .closed : .thrown
      case .localRoutesEnabled:
        state = isLocalRoutesEnabled ? .thrown : .closed
      case .crossingGate0FunctionEnabled:
        state = getCrossingGateFeatureEnabledState(zone: 0) ? .closed : .thrown
      case .crossingGate1FunctionEnabled:
        state = getCrossingGateFeatureEnabledState(zone: 1) ? .closed : .thrown
      case .crossingGate2FunctionEnabled:
        state = getCrossingGateFeatureEnabledState(zone: 2) ? .closed : .thrown
      case .crossingGate3FunctionEnabled:
        state = getCrossingGateFeatureEnabledState(zone: 3) ? .closed : .thrown
      case .locoNetMessageType:
        state = isMessageTypeGeneralSensor ? .thrown : .closed
      }
      
      if let state, let locoNetGateway {
        configState = .settingOptionSwitches
        startTimeoutTimer(timeInterval: 1.0)
        locoNetGateway.setBrdOpSwState(locoNetDeviceId: .DS64, boardId: boardId, switchNumber: opSw.rawValue, state: state)
      }
    }
    else {
      configState = .idle
    }
    
  }
  
  internal override func customizeDynamicCDI(cdi:String) -> String {
    
    var result = cdi
    
    if let appNode {
      result = appNode.insertLocoNetGatewayMap(cdi: result)
    }
    
    return result
    
  }
  
  internal override func resetToFactoryDefaults() {

    configuration!.zeroMemory()
    
    super.resetToFactoryDefaults()
    
    boardId = 1
    
    for zone in 0 ... 3 {
      setSwitchAddress(zone: zone, address: UInt16(zone) + 1)
    }
    
    saveMemorySpaces()
    
  }

  internal override func resetReboot() {
    
    super.resetReboot()
    
    guard locoNetGatewayNodeId != 0 else {
      return
    }
    
    locoNetGateway?.addObserver(observer: self)
    
  }
  
  private func enterSwitchAddressMode() {
    
    if let message = OptionSwitch.enterSetSwitchAddressModeInstructions[.DS64] {
      
      let alert = NSAlert()
      
      alert.messageText = message
      alert.informativeText = ""
      alert.addButton(withTitle: "OK")
      alert.alertStyle = .informational
      
      alert.runModal()
    }
    
  }
  
  private func enterOpSwMode() {
    
    if let message = OptionSwitch.enterOptionSwitchModeInstructions[.DS64] {
      
      let alert = NSAlert()
      
      alert.messageText = message
      alert.informativeText = ""
      alert.addButton(withTitle: "OK")
      alert.alertStyle = .informational
      
      alert.runModal()
    }
    
  }
  
  private func exitOpSwMode() {
    
    if let message = OptionSwitch.exitOptionSwitchModeInstructions[.DS64] {
      
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
//      exitOpSwMode()
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
  
  private func processSwitchQueue() {
    
    guard !switchQueue.isEmpty, configState == .idle, let item = switchQueue.first else {
      return
    }
    
    configState = .setSwitchState
    
    locoNetGateway?.setSwWithAck(switchNumber: getSwitchAddress(zone: item.switchNumber), state: item.state)

  }
  
  // MARK: Public Methods
  
  internal override func setValidity(eventAddress:Int, validity: inout OpenLCBValidity) {
    
    for zone in 0 ... numberOfChannels - 1 {
      let state = commandedState[zone]
      let offset = baseAddress(zone: zone)
      let thrownAddress = addressCommandedThrownEventId0 + offset
      let closedAddress = addressCommandedClosedEventId0 + offset
      switch eventAddress {
      case thrownAddress:
        validity = state == .thrown ? .valid : state == .closed ? .invalid : .unknown
      case closedAddress:
        validity = state == .closed ? .valid : state == .thrown ? .invalid : .unknown
      default:
        break
      }
    }
    
  }

  public override func variableChanged(space:OpenLCBMemorySpace, address:Int) {
    
    switch address {
    case addressReadSettings:
      if configuration!.getUInt8(address: addressReadSettings) != 0 {
        configuration!.setUInt(address: addressReadSettings, value: UInt8(0))
        configuration!.save()
        configState = .gettingOptionSwitches
        optionSwitchesToDo.removeAll()
        for opsw in DS64OptionSwitches.allCases {
          optionSwitchesToDo.append(opsw)
        }
        startTimeoutTimer(timeInterval: 1.0)
        locoNetGateway?.getBrdOpSwState(locoNetDeviceId: .DS64, boardId: boardId, switchNumber: optionSwitchesToDo.first!.rawValue)
      }
    case addressWriteChanges:
      if configuration!.getUInt8(address: addressWriteChanges) != 0 {
        configuration!.setUInt(address: addressWriteChanges, value: UInt8(0))
        configuration!.save()
        optionSwitchesToDo.removeAll()
        for opsw in DS64OptionSwitches.allCases {
          optionSwitchesToDo.append(opsw)
        }
        setOpSw()
      }
    case addressWriteBoardId:
      if configuration!.getUInt8(address: addressWriteBoardId) != 0 {
        configuration!.setUInt(address: addressWriteBoardId, value: UInt8(0))
        configuration!.save()
        setBoardId()
      }
    case addressWriteSwitchAddresses:
      if configuration!.getUInt8(address: addressWriteSwitchAddresses) != 0 {
        configuration!.setUInt(address: addressWriteSwitchAddresses, value: UInt8(0))
        configuration!.save()
        configState = .settingSwitchAddresses
        switchToWrite = 0
        enterSwitchAddressMode()
        locoNetGateway?.setSwWithAck(switchNumber: getSwitchAddress(zone: switchToWrite), state: .closed)
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

    guard let locoNetGateway else {
      return
    }
    
    if let message = OptionSwitch.enterSetBoardIdModeInstructions[.DS64] {
      
      let alert = NSAlert()

      alert.messageText = message
      alert.informativeText = ""
      alert.addButton(withTitle: "OK")
      alert.alertStyle = .informational

      alert.runModal()
      
      while true {
        
        locoNetGateway.setSw(switchNumber: boardId, state: .closed)
        
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
    
    switch message.messageTypeIndicator {
      
    case .producerConsumerEventReport:
      
      if let eventId = message.eventId, let turnout = turnoutLookup[eventId] {
        switchQueue.append((turnout.turnoutNumber, turnout.state, turnout.ackEventId))
        processSwitchQueue()
      }
      
    default:
      super.openLCBMessageReceived(message: message)
    }
    
  }
  
  // MARK: LocoNetGatewayDelegate Methods
  
  @objc public func locoNetMessageReceived(message:LocoNetMessage) {
 
    let interestingMessages : Set<LocoNetMessageType> = [
      .sensRepGenIn,
      .setBrdOpSwOK,
      .setSwWithAckAccepted,
      .brdOpSwState,
    ]
    
    guard interestingMessages.contains(message.messageType) else {
      return
    }
    

    switch message.messageType {
      
    case .sensRepGenIn:
      
      if let sensorAddress = message.sensorAddress {
        
        let id = (sensorAddress - 1) / (numberOfChannels << 1) + 1
 
        if id == boardId, let sensorState = message.sensorState {
          
          let x = ((sensorAddress - 1) % 8)
          
          let zone = x >> 1
          
          if x % 2 == 0 {
    //        print(" \(userNodeName) \(sensorAddress) \(x) \(sensorState ? "A closed" : "A thrown") id: \(id) zone: \(zone + 1) ")
            if sensorState, let eventId = getASensorClosedEventId(zone: zone) {
              sendEvent(eventId: eventId)
            }
            if !sensorState, let eventId = getASensorThrownEventId(zone: zone) {
              sendEvent(eventId: eventId)
            }
          }
          else {
  //          print(" \(userNodeName) \(sensorAddress) \(x) \(sensorState ? "S closed" : "S thrown") id: \(id) zone: \(zone + 1) ")
            if sensorState, let eventId = getSSensorClosedEventId(zone: zone) {
              sendEvent(eventId: eventId)
            }
            if !sensorState, let eventId = getSSensorThrownEventId(zone: zone) {
              sendEvent(eventId: eventId)
            }
          }
          
        }
        
      }
      
    case .setBrdOpSwOK:
      if configState == .settingOptionSwitches {
        stopTimeoutTimer()
        optionSwitchesToDo.removeFirst()
        if optionSwitchesToDo.isEmpty {
          configState = .idle
        }
        else {
          setOpSw()
        }
      }
      
    case .setSwWithAckAccepted:
      
      switch configState {
        
      case .settingSwitchAddresses:
        
        switchToWrite += 1
        
        if switchToWrite == numberOfChannels {
          configState = .idle
        }
        else {
          locoNetGateway?.setSwWithAck(switchNumber: getSwitchAddress(zone: switchToWrite), state: .closed)
        }
        
      case .setSwitchState:
        
        let item = switchQueue.removeFirst()
          
        if let eventId = item.confirmEventId {
          commandedState[item.switchNumber] = item.state
          sendEvent(eventId: eventId)
        }
        
        configState = .idle
        
        processSwitchQueue()
        
      default:
        break
      }
      
    case .brdOpSwState:
      
      if configState == .gettingOptionSwitches, let opSw = optionSwitchesToDo.first, let state = message.swState {
        
        configState = .idle

        stopTimeoutTimer()
        
        switch opSw {
        case .outputType:
          outputType = state == .thrown ? .solenoid : .slowMotion
        case .pulseLength0:
          let mask : UInt8 = 0b0001
          pulseLength = pulseLength & ~mask
          pulseLength |= state == .closed ? mask : 0
        case .pulseLength1:
          let mask : UInt8 = 0b0010
          pulseLength = pulseLength & ~mask
          pulseLength |= state == .closed ? mask : 0
        case .pulseLength2:
          let mask : UInt8 = 0b0100
          pulseLength = pulseLength & ~mask
          pulseLength |= state == .closed ? mask : 0
        case .pulseLength3:
          let mask : UInt8 = 0b1000
          pulseLength = pulseLength & ~mask
          pulseLength |= state == .closed ? mask : 0
        case .powerUpToLastState:
          willPowerUpToLastState = state == .thrown
        case .startupDelay:
          isRegularStartupDelay = state == .thrown
        case .staticTimeout:
          willOutputsShutOff = state == .closed
        case .computerCommandsOnly:
          obeyComputerCommandsOnly = state == .closed
        case .routeCommandsFromLocalInputs:
          isRouteCommandsFromLocalInputs = state == .closed
        case .sInputToggles:
          isSInputToggles = state == .thrown
        case .allInputsAreSensors:
          isAllInputsAreSensors = state == .closed
        case .LocoNetCommandsPriority:
          isLocoNetCommandsPriority = state == .thrown
        case .sensorMessagesOnly:
          isSensorMessagesOnly = state == .closed
        case .localRoutesEnabled:
          isLocalRoutesEnabled = state == .thrown
        case .crossingGate0FunctionEnabled:
          setCrossGateFeatureEnabledState(zone: 0, isEnabled: state == .closed)
        case .crossingGate1FunctionEnabled:
          setCrossGateFeatureEnabledState(zone: 1, isEnabled: state == .closed)
        case .crossingGate2FunctionEnabled:
          setCrossGateFeatureEnabledState(zone: 2, isEnabled: state == .closed)
        case .crossingGate3FunctionEnabled:
          setCrossGateFeatureEnabledState(zone: 3, isEnabled: state == .closed)
        case .locoNetMessageType:
          isMessageTypeGeneralSensor = state == .thrown
        }
        
        optionSwitchesToDo.removeFirst()
        if let opSw = optionSwitchesToDo.first {
          configState = .gettingOptionSwitches
          startTimeoutTimer(timeInterval: 1.0)
          locoNetGateway?.getBrdOpSwState(locoNetDeviceId: .DS64, boardId: boardId, switchNumber: opSw.rawValue)
        }
        else {
          configuration!.save()
        }
      }
      
    default:
      break
    }
    
  }
  
}

