//
//  MyTrainsController.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/11/2021.
//

import Foundation

public class MyTrainsController : NSObject, InterfaceDelegate, NSUserNotificationCenterDelegate, MTSerialPortManagerDelegate {
  
  // MARK: Constructor
  
  override init() {
    
    super.init()
    
    openLCBNetworkLayer = OpenLCBNetworkLayer(nodeId: openLCBNodeId)
    
    MTSerialPortManager.delegate = self
    
    checkPortsTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkPortsTimerAction), userInfo: nil, repeats: true)
    
    RunLoop.current.add(checkPortsTimer!, forMode: .common)
    
  }
  
  // MARK: Destructor
  
  deinit {
    checkPortsTimer?.invalidate()
    checkPortsTimer = nil
  }
  
  // MARK: Private Properties
  
  private var controllerDelegates : [Int:MyTrainsControllerDelegate] = [:]
  
  private var _nextControllerDelegateId : Int = 0
  
  private var controllerDelegateLock : NSLock = NSLock()
  
  private var _nextMessengerId : Int = 1
  
  private var _nextIdLock : NSLock = NSLock()
  
  private var checkPortsTimer : Timer?
  
  private var nextMessengerId : String {
    get {
      _nextIdLock.lock()
      let id = _nextMessengerId
      _nextMessengerId += 1
      _nextIdLock.unlock()
      return "id\(id)"
    }
  }
  
  private var _observerIds : [String:Int] = [:]
  
  private var throttles : [Int:ProductCode] = [:]
  
  // MARK: Public Properties
  
  public var fastClock : FastClock = FastClock()
  
  public var networks : [Int:Network] = Network.networks

  public var layouts : [Int:Layout] = Layout.layouts

  public var rollingStock : [Int:RollingStock] = RollingStock.rollingStock

  public var locoNetDevices : [Int:LocoNetDevice] = LocoNetDevice.locoNetDevices
  
  public var openLCBNodeId : UInt64 {
    get {
      return 0x050101017b00 // Paul Willmott's Start of range
    }
  }
  
  public var openLCBNetworkLayer : OpenLCBNetworkLayer?
    
  public var layoutId : Int {
    get {
      let id = UserDefaults.standard.integer(forKey: DEFAULT.MAIN_CURRENT_LAYOUT_ID)
      return id == 0 ? -1 : id
    }
    set(value) {
      UserDefaults.standard.set(value, forKey: DEFAULT.MAIN_CURRENT_LAYOUT_ID)
    }
  }
  
  public var layout : Layout? {
    get {
      return layouts[layoutId]
    }
  }
  
  public var connected : Bool = false {
    didSet {
      for (_, delegate) in controllerDelegates {
        delegate.statusUpdated?(myTrainsController: self)
      }
    }
  }
  
  public var tc64s : [Int:LocoNetDevice] {
    get {
      
      var result : [Int:LocoNetDevice] = [:]
      
      for (_, device) in locoNetDevices {
        if let info = device.locoNetProductInfo, info.id == .TowerControllerMarkII {
          result[device.primaryKey] = device
        }
      }
      
      return result
      
    }
  }
  
  public var locomotives : [Int:Locomotive] {
    get {
      
      var result : [Int:Locomotive] = [:]
      
      for (k, v) in rollingStock {
        if let rs = v as? Locomotive {
          result[k] = rs
        }
      }
      
      return result
      
    }
  }
  
  public var rollingStockWithDecoders : [Int:RollingStock] {
    get {
      
      var result : [Int:RollingStock] = [:]
      
      for (_, rs) in rollingStock {
        if rs.mDecoderInstalled || rs.aDecoderInstalled {
          result[rs.primaryKey] = rs
        }
      }
      
      return result
      
    }
  }
  
  public var commandStations : [Int:InterfaceLocoNet] {
    get {
      
      var result : [Int:InterfaceLocoNet] = [:]
      
      for (_, device) in locoNetDevices {
        if let info = device.locoNetProductInfo, info.attributes.contains(.CommandStation), let cs = device as? InterfaceLocoNet {
          result[cs.primaryKey] = cs
        }
      }
      
      return result
      
    }
  }
  
  public var routeHosts : [Int:LocoNetDevice] {
    get {
      
      var result : [Int:LocoNetDevice] = [:]
      
      for (_, device) in locoNetDevices {
        if let info = device.locoNetProductInfo, info.attributes.contains(.RouteHost) {
          result[device.primaryKey] = device
        }
      }
      
      return result
      
    }
  }
  
  public var interfaceDevices : [Int:Interface] {
    get {
      
      var result : [Int:Interface] = [:]
      
      for (_, device) in locoNetDevices {
        if let info = device.locoNetProductInfo, info.attributes.contains(.ComputerInterface), let interface = device as? Interface {
          result[interface.primaryKey] = interface
        }
      }
      
      return result
      
    }
  }
  
  public var locoNetInterfaces : [Int:InterfaceLocoNet] {
    get {
      
      var interfaces : [Int:InterfaceLocoNet] = [:]
      
      for (_, device) in interfaceDevices {
        if let interface = device as? InterfaceLocoNet, let info = interface.locoNetProductInfo, info.attributes.contains(.LocoNetInterface) {
          interfaces[interface.primaryKey] = interface
        }
      }

      return interfaces
      
    }
  }

  public var openLCBInterfaces : [Int:InterfaceOpenLCBCAN] {
    get {
      
      var interfaces : [Int:InterfaceOpenLCBCAN] = [:]
      
      for (_, device) in interfaceDevices {
        if let interface = device as? InterfaceOpenLCBCAN {
          interfaces[interface.primaryKey] = interface
        }
      }

      return interfaces
      
    }
  }

  public var networksForCurrentLayout : [Int:Network] {
    get {
      var result : [Int:Network] = [:]
      for (_, network) in networks {
        if network.layoutId == self.layoutId {
          result[network.primaryKey] = network
        }
      }
      return result
    }
  }
  
  public var networkInterfaces : [Interface] {
    get {
      
      var interfaces : [Interface] = []
      
      for (networkId, network) in networks {
        if network.layoutId == layoutId {
          for (interfaceId, interface) in locoNetInterfaces {
            if interfaceId == network.interfaceId {
              interface.networkId = networkId
              interfaces.append(interface)
            }
          }
          for (interfaceId, interface) in openLCBInterfaces {
            if interfaceId == network.interfaceId {
              interface.networkId = networkId
              interfaces.append(interface)
            }
          }
        }
      }
      
      return interfaces.sorted {
        $0.deviceName < $1.deviceName
      }
      
    }
  }

  public var networkLCCInterfaces : [Int:Interface] {
    get {
      
      var interfaces : [Int:Interface] = [:]
      
      for (networkId, network) in networks {
        if network.layoutId == layoutId {
          for (interfaceId, interface) in openLCBInterfaces {
            if interfaceId == network.interfaceId {
              interface.networkId = networkId
              interfaces[interface.primaryKey] = interface
            }
          }
        }
      }
      
      return interfaces
      
    }
  }

  public var sensors : [Int:IOFunction] {
    get {
      
      var result : [Int:IOFunction] = [:]
      
      for (_, device) in locoNetDevices {
        if let ioDevice = device as? IODevice {
          for ioFunction in ioDevice.ioFunctions {
            if ioFunction.ioChannel.channelType == .input {
              result[ioFunction.primaryKey] = ioFunction
            }
          }
        }
      }

      return result
      
    }
  }
  
  public func ioFunctions(networkId:Int) -> [IOFunction] {
    
    var result : [IOFunction] = []
    
    for (_, device) in locoNetDevices {
      if let ioDevice = device as? IODevice, ioDevice.networkId == networkId {
        result.append(contentsOf: ioDevice.ioFunctions)
      }
    }
    
    result.sort() {$0.sortString() < $1.sortString()}
    
    return result
    
  }
  
  public var turnoutSwitches : [TurnoutSwitch] {
    
    get {
      
      var result : [TurnoutSwitch] = []
      
      for (_, device) in stationaryDecoders {
        
        for turnoutSwitch in device.turnoutSwitches {
          result.append(turnoutSwitch)
        }
        
      }
      
      result.sort {$0.comboSortOrder < $1.comboSortOrder}
      
      return result
      
    }
    
  }
  
  public var stationaryDecoders : [Int:LocoNetDevice] {
  
    get {
      
      var result : [Int:LocoNetDevice] = [:]
      
      for (_, device) in locoNetDevices {
        if device.isStationaryDecoder {
          result[device.primaryKey] = device
        }
      }

      return result
      
    }
 
  }
  
  public var programmers : [Int:Interface] {
    
    var progs : [Int:Interface] = [:]
    
    for interface in networkInterfaces {
      if let info = interface.locoNetProductInfo, info.attributes.contains(.Programmer) {
        progs[interface.primaryKey] = interface
      }
    }
    
    for kv in networks {
      let network = kv.value
      if network.layoutId == layoutId, let cs = network.commandStation {
        progs[cs.primaryKey] = cs
      }
    }
    
    return progs

  }
  
  public var softwareThrottleID : Int? {
    get {
      for id in 1...0x7f {
        if let pc = throttles[id] {
          if pc == .softwareThrottle {
            return id
          }
        }
        else {
          throttles[id] = .softwareThrottle
          return id
        }
      }
      return nil
    }
  }
  
// MARK: Private Methods
  
  private func myTrainsControllerUpdated() {
    for (_, delegate) in controllerDelegates {
      delegate.myTrainsControllerUpdated?(myTrainsController: self)
    }
  }
  
  @objc func checkPortsTimerAction() {
    MTSerialPortManager.checkPorts()
  }
  
  // MARK: Public Methods

  public func ioFunction(primaryKey: Int) -> IOFunction? {
    
    for (_, device) in locoNetDevices {
      if let ioDevice = device as? IODevice {
        for ioFunction in ioDevice.ioFunctions {
          if ioFunction.primaryKey == primaryKey {
            return ioFunction
          }
        }
      }
    }

    return nil
    
  }
  
  public func sensors(sensorTypes: Set<SensorType>) -> [IOFunction] {
    
    var result : [IOFunction] = []
    
    for (_, sensor) in sensors {
      
      if sensorTypes.contains(sensor.sensorType) {
        result.append(sensor)
      }
    
    }
    
    result.sort {$0.sortString() < $1.sortString()}
    
    return result
    
  }

  public func deviceForQuerySlot(productCode:ProductCode, serialNumber: Int) -> LocoNetDevice? {
    
    for (_, device) in locoNetDevices {
      if let info = device.locoNetProductInfo, info.productCode == productCode && (device.serialNumber & 0b0011111111111111) == serialNumber {
        return device
      }
    }
    return nil
  }
  
  public func devicesWithAddresses(networkId:Int) -> [LocoNetDevice] {
    
    var result : [LocoNetDevice] = []
    
    for (_, device) in locoNetDevices {
      if device.networkId == networkId && device.hasAddresses {
        result.append(device)
      }
    }
    
    result.sort {$0.baseAddress < $1.baseAddress}
    
    return result
    
  }
  
  public func locoNetDevicesForNetwork(networkId: Int) -> [Int:LocoNetDevice] {
    
    var result : [Int:LocoNetDevice] = [:]
    
    for (_, device) in locoNetDevices {
      if device.networkId == networkId {
        result[device.primaryKey] = device
      }
    }
    
    return result
    
  }
  
  public func locoNetDevicesForNetworkWithAttributes(networkId: Int, attributes: LocoNetDeviceAttributes) -> [Int:LocoNetDevice] {
    
    var result : [Int:LocoNetDevice] = [:]
    
    for (_, device) in locoNetDevicesForNetwork(networkId: networkId) {
      if let info = device.locoNetProductInfo, info.attributes.intersection(attributes) == attributes {
        result[device.primaryKey] = device
      }
    }
    
    return result
  }
  
  public func commandStationInterface(commandStation:Interface) -> InterfaceLocoNet? {
    if let network = networks[commandStation.networkId] {
      return network.interface as? InterfaceLocoNet
    }
    return nil
  }
  
  public func networkControllerStatusUpdated() {
    for (_, value) in controllerDelegates {
      value.statusUpdated?(myTrainsController: self)
    }
  }
  
  public func switchBoardUpdated() {
    for (_, value) in controllerDelegates {
      value.switchBoardUpdated?()
    }
  }
  
  public func connect() {
    openLCBNetworkLayer?.start()
    for interface in networkInterfaces {
      if let locoNetInterface = interface as? InterfaceLocoNet {
        locoNetInterface.open()
      }
    }
    connected = true
  }
  
  public func disconnect() {
    openLCBNetworkLayer?.stop()
    for interface in networkInterfaces {
      if let locoNetInterface = interface as? InterfaceLocoNet {
        locoNetInterface.close()
      }
    }
    connected = false
  }
  
  public func powerOn() {
    for (_, interface) in locoNetInterfaces {
      interface.powerOn()
    }
  }
  
  public func powerOff() {
    for (_, interface) in locoNetInterfaces {
      interface.powerOff()
    }
  }

  public func powerIdle() {
    for (_, interface) in locoNetInterfaces {
      interface.powerIdle()
    }
  }

  public func addLayout(layout: Layout) {
    layouts[layout.primaryKey] = layout
    myTrainsControllerUpdated()
  }
  
  public func removeLayout(primaryKey:Int) {
    layouts.removeValue(forKey: primaryKey)
    myTrainsControllerUpdated()
  }
  
  public func addNetwork(network: Network) {
    networks[network.primaryKey] = network
    connected ? connect() : disconnect()
    myTrainsControllerUpdated()
  }
  
  public func removeNetwork(primaryKey:Int) {
    networks.removeValue(forKey: primaryKey)
    connected ? connect() : disconnect()
    myTrainsControllerUpdated()
  }
  
  public func addDevice(device: LocoNetDevice) {
    locoNetDevices[device.primaryKey] = device
    connected ? connect() : disconnect()
    myTrainsControllerUpdated()
  }
  
  public func removeDevice(primaryKey:Int) {
    locoNetDevices.removeValue(forKey: primaryKey)
    connected ? connect() : disconnect()
    myTrainsControllerUpdated()
  }
  
  public func addRollingStock(rollingStock: RollingStock) {
    self.rollingStock[rollingStock.primaryKey] = rollingStock
    myTrainsControllerUpdated()
  }
  
  public func removeRollingStock(primaryKey: Int) {
    self.rollingStock.removeValue(forKey: primaryKey)
    myTrainsControllerUpdated()
  }
  
  public func appendDelegate(delegate:MyTrainsControllerDelegate) -> Int {
    controllerDelegateLock.lock()
    let id = _nextControllerDelegateId
    _nextControllerDelegateId += 1
    controllerDelegates[id] = delegate
    controllerDelegateLock.unlock()
    delegate.myTrainsControllerUpdated?(myTrainsController: self)
    return id
  }
  
  public func removeDelegate(id:Int) {
    controllerDelegateLock.lock()
    controllerDelegates.removeValue(forKey: id)
    controllerDelegateLock.unlock()
  }
  
  // MARK: MTSerialPortManagerDelegate Methods
  
  public func serialPortWasAdded(path: String) {
    if connected {
      for interface in networkInterfaces {
        if interface.devicePath == path && !interface.isOpen {
          interface.open()
        }
      }
    }
    networkControllerStatusUpdated()
  }
  
  public func serialPortWasRemoved(path: String) {
    if connected {
      for interface in networkInterfaces {
        if interface.devicePath == path && interface.isOpen {
          interface.close()
        }
      }
    }
    networkControllerStatusUpdated()
  }
  
  // MARK: CommandStationDelegate Methods
  
  public func trackStatusChanged(commandStation: LocoNetDevice) {
    for (_, delegate) in controllerDelegates {
      delegate.statusUpdated?(myTrainsController: self)
    }
  }

}