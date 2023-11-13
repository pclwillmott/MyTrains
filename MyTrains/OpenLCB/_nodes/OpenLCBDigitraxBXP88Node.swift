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

private enum BXP88OptionSwitches : Int {
  
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

private enum LocoNetEventType : UInt8 {
  case none = 0
  case locomotiveReport = 1
  case shortCircuitReport = 2
  case shortCircuitClearedReport = 3
  case locomotiveEnteredTranspondingZone = 4
  case locomotiveExitedTranspondingZone = 5
  case locomotiveEnteredDetectionZone = 6
  case locomotiveExitedDetectionZone = 7
}

private enum EventPayloadType : UInt8 {
  case none = 0
  case dccAddress = 1
  case nodeId = 2
}

public class OpenLCBDigitraxBXP88Node : OpenLCBNodeVirtual, LocoNetDelegate {
  
  // MARK: Constructors
  
  public override init(nodeId:UInt64) {
    
    let configSize = 1319
    
    configuration = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, defaultMemorySize: configSize, isReadOnly: false, description: "")
    
    super.init(nodeId: nodeId)
    
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
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressResetToDefaults)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressWriteChanges)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressPowerManagerStatus)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressPowerManagerReporting)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressShortCircuitDetection)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressDetectionSensitivity)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressOccupiedWhenFaulted)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressTranspondingState)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressFastFind)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressOperationsModeFeedback)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSelectiveTransponding)
    
    for zone in 0 ... 7 {

      let baseAddress = baseAddress(zone: zone, event: 0)
      
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressOccupancyReporting + baseAddress)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressTranspondingReporting + baseAddress)

      for event in 0 ... 15 {
        
        let eventBaseAddress = self.baseAddress(zone: zone, event: event)
        
        registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressLocoNetEventType + eventBaseAddress)
        registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressIndicatorEventId + eventBaseAddress)
        registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressPayloadType + eventBaseAddress)

      }
      
    }
    
    if !memorySpacesInitialized {
      resetToFactoryDefaults()
    }
    
    initCDI(filename: "Digitrax BXP88", manufacturer: manufacturerName, model: nodeModelName)
    
  }
  
  deinit {
    locoNet = nil
  }
  
  // MARK: Private Properties
  
  internal var configuration : OpenLCBMemorySpace
  
  internal let addressLocoNetGateway         : Int = 0
  internal let addressBoardId                : Int = 8
  internal let addressWriteBoardId           : Int = 10
  internal let addressReadSettings           : Int = 11
  internal let addressResetToDefaults        : Int = 12
  internal let addressWriteChanges           : Int = 13
  internal let addressPowerManagerStatus     : Int = 14
  internal let addressPowerManagerReporting  : Int = 15
  internal let addressShortCircuitDetection  : Int = 16
  internal let addressDetectionSensitivity   : Int = 17
  internal let addressOccupiedWhenFaulted    : Int = 18
  internal let addressTranspondingState      : Int = 19
  internal let addressFastFind               : Int = 20
  internal let addressOperationsModeFeedback : Int = 21
  internal let addressSelectiveTransponding  : Int = 22
  internal let addressOccupancyReporting     : Int = 23
  internal let addressTranspondingReporting  : Int = 24
  internal let addressLocoNetEventType       : Int = 25
  internal let addressIndicatorEventId       : Int = 26
  internal let addressPayloadType            : Int = 34

  private var locoNet : LocoNet?
  
  private var locoNetGateways : [UInt64:String] = [:]
  
  private var configState : ConfigState = .idle
  
  private var trainNodeIdLookup : [Int:UInt64] = [:]
  
  private var eventQueue : [(dccAddress:Int, eventId:UInt64, searchEventId:UInt64)] = []
  
  private var lastDetectionSectionShorted : [Bool] = []
  
  private var timeoutTimer : Timer?
  
  private var activeEvents : [UInt64] {
    
    var result : [UInt64] = []
    
    for zone in 0 ... 7 {
      for event in 0 ... 15 {
        if let et = locoNetEventType(zone: zone, event: event), et != .none, let eventId = indicatorEventId(zone: zone, event: event) {
          result.append(eventId)
        }
      }
    }
    
    return result
    
  }
  
  private var boardId : UInt16 {
    get {
      return configuration.getUInt16(address: addressBoardId)!
    }
    set(value) {
      configuration.setUInt(address: addressBoardId, value: value)
    }
  }
  
  private var isShortCircuitDetectionNormal : Bool {
    get {
      return configuration.getUInt8(address: addressShortCircuitDetection)! == 0
    }
    set(value) {
      configuration.setUInt(address: addressShortCircuitDetection, value: UInt8(value ? 0 : 1))
    }
  }
  
  private var isTranspondingEnabled : Bool {
    get {
      return configuration.getUInt8(address: addressTranspondingState)! != 0
    }
    set(value) {
      configuration.setUInt(address: addressTranspondingState, value: UInt8(value ? 1 : 0))
    }
  }
  
  private var isFastFindEnabled : Bool {
    get {
      return configuration.getUInt8(address: addressFastFind)! == 0
    }
    set(value) {
      configuration.setUInt(address: addressFastFind, value: UInt8(value ? 0 : 1))
    }
  }
  
  private var isPowerManagerEnabled : Bool {
    get {
      return configuration.getUInt8(address: addressPowerManagerStatus)! != 0
    }
    set(value) {
      configuration.setUInt(address: addressPowerManagerStatus, value: UInt8(value ? 1 : 0))
    }
  }
  
  private var isPowerManagerReportingEnabled : Bool {
    get {
      return configuration.getUInt8(address: addressPowerManagerReporting)! != 0
    }
    set(value) {
      configuration.setUInt(address: addressPowerManagerReporting, value: UInt8(value ? 1 : 0))
    }
  }
  
  private var isDetectionSensitivityRegular : Bool {
    get {
      return configuration.getUInt8(address: addressDetectionSensitivity) == 0
    }
    set(value) {
      configuration.setUInt(address: addressDetectionSensitivity, value: UInt8(value ? 0 : 1))
    }
  }
  
  private var isOccupiedMessageSentWhenFaulted : Bool {
    get {
      return configuration.getUInt8(address: addressOccupiedWhenFaulted) == 0
    }
    set(value) {
      configuration.setUInt(address: addressOccupiedWhenFaulted, value: UInt8(value ? 0 : 1))
    }
  }
  
  private var isOperationsModeReadbackEnabled : Bool {
    get {
      return configuration.getUInt8(address: addressOperationsModeFeedback) == 0
    }
    set(value) {
      configuration.setUInt(address: addressOperationsModeFeedback, value: UInt8(value ? 0 : 1))
    }
  }
  
  private var isSelectiveTranspondingDisablingAllowed : Bool {
    get {
      return configuration.getUInt8(address: addressSelectiveTransponding) == 0
    }
    set(value) {
      configuration.setUInt(address: addressSelectiveTransponding, value: UInt8(value ? 0 : 1))
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
  
  public let productCode : ProductCode = .BXP88
  
  public var locoNetGatewayNodeId : UInt64 {
    get {
      return configuration.getUInt64(address: addressLocoNetGateway)!
    }
    set(value) {
      configuration.setUInt(address: addressLocoNetGateway, value: value)
    }
  }

  // MARK: Private Methods
  
  private func setOccupancyReportingState(zone:Int, value:Bool) {
    let baseAddress = baseAddress(zone: zone, event: 0)
    configuration.setUInt(address: addressOccupancyReporting + baseAddress, value: UInt8(value ? 0 : 1))
  }
  
  private func getOccupancyReportingState(zone:Int) -> Bool {
    let baseAddress = baseAddress(zone: zone, event: 0)
    return configuration.getUInt8(address: addressOccupancyReporting + baseAddress) == 0
  }
  
  private func setTranspondingReportingState(zone:Int, value:Bool) {
    let baseAddress = baseAddress(zone: zone, event: 0)
    configuration.setUInt(address: addressTranspondingReporting + baseAddress, value: UInt8(value ? 0 : 1))
  }
  
  private func getTranspondingReportingState(zone:Int) -> Bool {
    let baseAddress = baseAddress(zone: zone, event: 0)
    return configuration.getUInt8(address: addressTranspondingReporting + baseAddress) == 0
  }
  
  private func setOpSw() {
    
    if let opSw = optionSwitchesToDo.first {
      
      var state : OptionSwitchState?
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
        state = getOccupancyReportingState(zone: 0) ? .thrown : .closed
      case .occupancyReportSection2:
        state = getOccupancyReportingState(zone: 1) ? .thrown : .closed
      case .occupancyReportSection3:
        state = getOccupancyReportingState(zone: 2) ? .thrown : .closed
      case .occupancyReportSection4:
        state = getOccupancyReportingState(zone: 3) ? .thrown : .closed
      case .occupancyReportSection5:
        state = getOccupancyReportingState(zone: 4) ? .thrown : .closed
      case .occupancyReportSection6:
        state = getOccupancyReportingState(zone: 5) ? .thrown : .closed
      case .occupancyReportSection7:
        state = getOccupancyReportingState(zone: 6) ? .thrown : .closed
      case .occupancyReportSection8:
        state = getOccupancyReportingState(zone: 7) ? .thrown : .closed
      case .selectiveTranspondingDisabling:
        state = getTranspondingReportingState(zone: 0) ? .thrown : .closed
      case .transpondingReportSection1:
        state = getTranspondingReportingState(zone: 1) ? .thrown : .closed
      case .transpondingReportSection2:
        state = getTranspondingReportingState(zone: 2) ? .thrown : .closed
      case .transpondingReportSection3:
        state = getTranspondingReportingState(zone: 3) ? .thrown : .closed
      case .transpondingReportSection4:
        state = getTranspondingReportingState(zone: 4) ? .thrown : .closed
      case .transpondingReportSection5:
        state = getTranspondingReportingState(zone: 5) ? .thrown : .closed
      case .transpondingReportSection6:
        state = getTranspondingReportingState(zone: 6) ? .thrown : .closed
      case .transpondingReportSection7:
        state = getTranspondingReportingState(zone: 7) ? .thrown : .closed
      case .transpondingReportSection8:
        state = getTranspondingReportingState(zone: 8) ? .thrown : .closed
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
  
  private func baseAddress(zone:Int, event:Int) -> Int {
    return zone * 162 + event * 10
  }
  
  private func locoNetEventType(zone:Int, event:Int) -> LocoNetEventType? {
    let baseAddress = baseAddress(zone: zone, event: event)
    if let et = configuration.getUInt8(address: addressLocoNetEventType + baseAddress) {
      return LocoNetEventType(rawValue: et)
    }
    return nil
  }
  
  private func indicatorEventId(zone:Int, event:Int) -> UInt64? {
    let baseAddress = baseAddress(zone: zone, event: event)
    return configuration.getUInt64(address: addressIndicatorEventId + baseAddress)
  }
  
  private func eventPayloadType(zone:Int, event:Int) -> EventPayloadType? {
    let baseAddress = baseAddress(zone: zone, event: event)
    if let pt = configuration.getUInt8(address: addressPayloadType + baseAddress) {
      return EventPayloadType(rawValue: pt)
    }
    return nil
  }
  
  private func processEvents(zone:Int, eventType:LocoNetEventType, dccAddress:Int?, trainNodeId:UInt64?) {
    
    guard let networkLayer, eventType != .none else {
      return
    }
    
    for event in 0 ... 15 {
      if locoNetEventType(zone: zone, event: event) == eventType, let eventId = indicatorEventId(zone: zone, event: event), let payloadType = eventPayloadType(zone: zone, event: event) {
        
        switch eventType {
        case .locomotiveReport, .locomotiveEnteredTranspondingZone, .locomotiveExitedTranspondingZone:
          if let dccAddress {
            switch payloadType {
            case .none:
              networkLayer.sendEvent(sourceNodeId: nodeId, eventId: eventId)
           case .dccAddress:
              var payload : [UInt8] = []
              if dccAddress < 128 {
                let address = UInt8(dccAddress & 0x7f)
                payload.append(contentsOf: [OpenLCBEventWithPayloadFormat.dccPrimaryAddress.rawValue, address])
              }
              else {
                payload.append(contentsOf: [OpenLCBEventWithPayloadFormat.dccExtendedAddress.rawValue])
                let address = UInt16(dccAddress)
                payload.append(contentsOf: address.bigEndianData)
              }
              networkLayer.sendEventWithPayload(sourceNodeId: nodeId, eventId: eventId, payload: payload)
            case .nodeId:
              if let trainNodeId = trainNodeIdLookup[dccAddress] {
                var payload : [UInt8] = []
                payload.append(contentsOf: [OpenLCBEventWithPayloadFormat.openLCBNodeId.rawValue])
                var id = trainNodeId.bigEndianData
                id.removeFirst(2)
                payload.append(contentsOf: id)
                networkLayer.sendEventWithPayload(sourceNodeId: nodeId, eventId: eventId, payload: payload)
              }
              else {
                let searchEventId = networkLayer.makeTrainSearchEventId(searchString: "\(dccAddress)", searchType: .searchExistingNodes, searchMatchType: .exactMatch, searchMatchTarget: .matchAddressOnly, trackProtocol: .anyTrackProtocol)
                eventQueue.append((dccAddress:dccAddress, eventId:eventId, searchEventId:searchEventId))
                networkLayer.sendIdentifyProducer(sourceNodeId: nodeId, eventId: searchEventId)
              }
            }
          }

        default:
          networkLayer.sendEvent(sourceNodeId: nodeId, eventId: eventId)
        }
        
      }
    }
    
  }
  
  internal override func resetToFactoryDefaults() {

    super.resetToFactoryDefaults()
    
    acdiManufacturerSpaceVersion = 4
    
    manufacturerName    = virtualNodeType.manufacturerName
    nodeModelName       = virtualNodeType.name
    nodeHardwareVersion = "\(Bundle.main.releaseVersionNumberPretty)"
    nodeSoftwareVersion = "\(Bundle.main.releaseVersionNumberPretty)"

    acdiUserSpaceVersion = 2
    
    userNodeName = virtualNodeType.defaultUserNodeName(nodeId: nodeId)
    userNodeDescription = ""
    
    configuration.zeroMemory()
    
    boardId = 1
    
    isTranspondingEnabled = true
    
    isPowerManagerEnabled = true
    
    isPowerManagerReportingEnabled = true
    
    var eventId = nodeId << 16
    for zone in 0 ... 7 {
      for event in 0 ... 15 {
        let baseAddress = baseAddress(zone: zone, event: event)
        configuration.setUInt(address: addressIndicatorEventId + baseAddress, value: eventId)
        eventId += 1
      }
    }
    
    saveMemorySpaces()
    
  }

  internal override func resetReboot() {
    
    super.resetReboot()
    
    networkLayer?.sendConsumerIdentified(sourceNodeId: nodeId, wellKnownEvent: .nodeIsALocoNetGateway, validity: .unknown)
    
    networkLayer?.sendIdentifyProducer(sourceNodeId: nodeId, event: .nodeIsALocoNetGateway)
    
    for eventId in activeEvents {
      networkLayer?.sendProducerIdentified(sourceNodeId: nodeId, eventId: eventId, validity: .unknown)
    }
    
    guard locoNetGatewayNodeId != 0 else {
      return
    }
    
    locoNet = LocoNet(gatewayNodeId: locoNetGatewayNodeId, virtualNode: self)
    
    locoNet?.delegate = self
    
  }
  
  private func enterOpSwMode() {
    
    if let message = OptionSwitch.enterOptionSwitchModeInstructions[productCode.locoNetProductId!] {
      
      let alert = NSAlert()
      
      alert.messageText = message
      alert.informativeText = ""
      alert.addButton(withTitle: "OK")
      alert.alertStyle = .informational
      
      alert.runModal()
    }
    
  }
  
  private func exitOpSwMode() {
    
    if let message = OptionSwitch.exitOptionSwitchModeInstructions[productCode.locoNetProductId!] {
      
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
  
  public func reloadCDI() {
    memorySpaces.removeValue(forKey: OpenLCBNodeMemoryAddressSpace.cdi.rawValue)
    initCDI(filename: "Digitrax BXP88", manufacturer: manufacturerName, model: nodeModelName)
  }

  public override func initCDI(filename:String, manufacturer:String, model:String) {
    
    if let filepath = Bundle.main.path(forResource: filename, ofType: "xml") {
      do {
        
        var contents = try String(contentsOfFile: filepath)
        
        contents = contents.replacingOccurrences(of: "%%MANUFACTURER%%", with: manufacturer)
        contents = contents.replacingOccurrences(of: "%%MODEL%%", with: model)
        
        var sorted : [(nodeId:UInt64, name:String)] = []
        
        for (key, name) in locoNetGateways {
          sorted.append((nodeId:key, name:name))
        }
        
        sorted.sort {$0.name < $1.name}
        
        var gateways = "<relation><property>00.00.00.00.00.00.00.00</property><value>No Gateway Selected</value></relation>\n"
        
        for gateway in sorted {
          gateways += "<relation><property>\(gateway.nodeId.toHexDotFormat(numberOfBytes: 8))</property><value>\(gateway.name)</value></relation>\n"
        }

        contents = contents.replacingOccurrences(of: "%%LOCONET_GATEWAYS%%", with: gateways)

        let memorySpace = OpenLCBMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.cdi.rawValue, isReadOnly: true, description: "")
        memorySpace.memory = [UInt8]()
        memorySpace.memory.append(contentsOf: contents.utf8)
        memorySpace.memory.append(contentsOf: [UInt8](repeating: 0, count: 64))
        memorySpaces[memorySpace.space] = memorySpace
        
        isConfigurationDescriptionInformationProtocolSupported = true
        
        setupConfigurationOptions()
        
      }
      catch {
      }
    }
    
  }
  
  public override func variableChanged(space:OpenLCBMemorySpace, address:Int) {
    
    switch address {
    case addressReadSettings:
      if configuration.getUInt8(address: addressReadSettings) != 0 {
        configuration.setUInt(address: addressReadSettings, value: UInt8(0))
        configuration.save()
        configState = .waitingForDeviceData
        startTimeoutTimer(timeInterval: 3.0)
        locoNet?.iplDiscover(productCode: productCode)
      }
    case addressWriteChanges:
      if configuration.getUInt8(address: addressWriteChanges) != 0 {
        configuration.setUInt(address: addressWriteChanges, value: UInt8(0))
        configuration.save()
        enterOpSwMode()
        optionSwitchesToDo = allDataOptionSwitches
        setOpSw()
      }
    case addressWriteBoardId:
      if configuration.getUInt8(address: addressWriteBoardId) != 0 {
        configuration.setUInt(address: addressWriteBoardId, value: UInt8(0))
        configuration.save()
        setBoardId()
      }
    case addressResetToDefaults:
      if configuration.getUInt8(address: addressResetToDefaults) != 0 {
        configuration.setUInt(address: addressResetToDefaults, value: UInt8(0))
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
    
    if let message = OptionSwitch.enterSetBoardIdModeInstructions[productCode.locoNetProductId!] {
      
      let alert = NSAlert()

      alert.messageText = message
      alert.informativeText = ""
      alert.addButton(withTitle: "OK")
      alert.alertStyle = .informational

      alert.runModal()
      
      while true {
        
        locoNet.setSw(switchNumber: Int(boardId), state: .closed)
        
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
    
    switch message.messageTypeIndicator {
    
    case .producerIdentifiedAsCurrentlyValid, .producerIdentifiedAsCurrentlyInvalid, .producerIdentifiedWithValidityUnknown, .producerConsumerEventReport:
      
      if let event = OpenLCBWellKnownEvent(rawValue: message.eventId!) {
        
        switch event {
        case .nodeIsALocoNetGateway:
          
          locoNetGateways[message.sourceNodeId!] = ""
          networkLayer?.sendSimpleNodeInformationRequest(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!)
          
        default:
          break
        }
        
      }
      else {
        
        var index = 0
        while index < eventQueue.count {
          let item = eventQueue[index]
          if item.searchEventId == message.eventId! {
            trainNodeIdLookup[item.dccAddress] = message.sourceNodeId!
            eventQueue.remove(at: index)
            var payload : [UInt8] = []
            payload.append(contentsOf: [OpenLCBEventWithPayloadFormat.openLCBNodeId.rawValue])
            var id = message.sourceNodeId!.bigEndianData
            id.removeFirst(2)
            payload.append(contentsOf: id)
            networkLayer?.sendEventWithPayload(sourceNodeId: nodeId, eventId: item.eventId, payload: payload)
          }
          else {
            index += 1
          }
        }
        
      }

    case .simpleNodeIdentInfoReply:
      
      if let _ = locoNetGateways[message.sourceNodeId!] {
        let node = OpenLCBNode(nodeId: message.sourceNodeId!)
        node.encodedNodeInformation = message.payload
        locoNetGateways[node.nodeId] = node.userNodeName
        reloadCDI()
      }

    case .identifyProducer:
      
      guard let networkLayer else {
        return
      }
      
      for eventId in activeEvents {
        if message.eventId == eventId {
          networkLayer.sendProducerIdentified(sourceNodeId: nodeId, eventId: eventId, validity: .unknown)
        }
      }
      
    default:
      break
    }
    
  }
  
  // MARK: LocoNetDelegate Methods
  
  @objc public func locoNetInitializationComplete() {
    
    guard let locoNet else {
      return
    }
    
  }
  
  @objc public func locoNetMessageReceived(message:LocoNetMessage) {
    
    switch message.messageType {
      
    case .sensRepGenIn:
      if let sensorAddres = message.sensorAddress {
        let id = (sensorAddres - 1) / 8 + 1
        if id == boardId, let sensorState = message.sensorState {
          let zone = (sensorAddres - 1) % 8
          processEvents(zone: zone, eventType: sensorState ? .locomotiveEnteredDetectionZone : .locomotiveExitedDetectionZone, dccAddress: nil, trainNodeId: nil)
        }
      }
      
    case .transRep:
      let id = message.transponderZone! / 8 + 1
      if id == boardId, let transponderZone = message.transponderZone, let locomotiveAddress = message.locomotiveAddress {
        let zone = transponderZone % 8
        processEvents(zone: zone, eventType: message.sensorState! ? .locomotiveEnteredTranspondingZone : .locomotiveExitedTranspondingZone, dccAddress: locomotiveAddress, trainNodeId: 0)
      }
      
    case .pmRepBXP88:
      if let id = message.boardId, id == boardId, let shorted = message.detectionSectionShorted {
        if lastDetectionSectionShorted.isEmpty {
          for zone in 0...7 {
            lastDetectionSectionShorted.append(!shorted[zone])
          }
        }
        for zone in 0...7 {
          if lastDetectionSectionShorted[zone] != shorted[zone] {
            processEvents(zone: zone, eventType: shorted[zone] ? .shortCircuitReport : .shortCircuitClearedReport, dccAddress: nil, trainNodeId: nil)
          }
        }
        lastDetectionSectionShorted = shorted
      }
    
    case .locoRep:
      let id = message.transponderZone! / 8 + 1
       if id == boardId, let locomotiveAddress = message.locomotiveAddress, let transponderZone = message.transponderZone {
        let zone = transponderZone % 8
        processEvents(zone: zone, eventType: .locomotiveReport, dccAddress: locomotiveAddress, trainNodeId: 0)
      }
      
    case .iplDevData:
      if configState == .waitingForDeviceData, let prod = message.productCode, prod == .BXP88, let id = message.boardId, id == boardId {
        stopTimeoutTimer()
        if userNodeName == virtualNodeType.defaultUserNodeName(nodeId: nodeId) {
          userNodeName = "Digitrax BXP88 S/N: \(message.serialNumber!)"
        }
        nodeSoftwareVersion = "v\(message.softwareVersion!)"
        acdiUserSpace.save()
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
          setOccupancyReportingState(zone: 0, value: state == .thrown)
        case .occupancyReportSection2:
          setOccupancyReportingState(zone: 1, value: state == .thrown)
        case .occupancyReportSection3:
          setOccupancyReportingState(zone: 2, value: state == .thrown)
        case .occupancyReportSection4:
          setOccupancyReportingState(zone: 3, value: state == .thrown)
        case .occupancyReportSection5:
          setOccupancyReportingState(zone: 4, value: state == .thrown)
        case .occupancyReportSection6:
          setOccupancyReportingState(zone: 5, value: state == .thrown)
        case .occupancyReportSection7:
          setOccupancyReportingState(zone: 6, value: state == .thrown)
        case .occupancyReportSection8:
          setOccupancyReportingState(zone: 7, value: state == .thrown)
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
          configuration.save()
          exitOpSwMode()
        }
      }
      
    default:
      break
    }
    
  }
  
}

