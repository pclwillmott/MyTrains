//
//  NetworkController.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/11/2021.
//

import Foundation

@objc public protocol NetworkControllerDelegate {
  @objc optional func interfacesUpdated(interfaces:[Interface])
  @objc optional func networkControllerUpdated(netwokController:NetworkController)
  @objc optional func statusUpdated(networkController:NetworkController)
  @objc optional func switchBoardUpdated()
}

public class NetworkController : NSObject, InterfaceDelegate, NSUserNotificationCenterDelegate, MTSerialPortManagerDelegate {
  
  // MARK: Constructor
  
  override init() {
    
    super.init()
    
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
  
  private var controllerDelegates : [Int:NetworkControllerDelegate] = [:]
  
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
      for delegate in controllerDelegates {
        delegate.value.statusUpdated?(networkController: self)
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
      
      for kv in rollingStock {
        if let rs = kv.value as? Locomotive, rs.rollingStockType == .locomotive {
          result[rs.primaryKey] = rs
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
  
  public var commandStations : [Int:Interface] {
    get {
      
      var result : [Int:Interface] = [:]
      
      for (_, device) in locoNetDevices {
        if let info = device.locoNetProductInfo, info.attributes.contains(.CommandStation), let cs = device as? Interface {
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
  
  public var locoNetInterfaces : [Int:Interface] {
    get {
      
      var interfaces : [Int:Interface] = [:]
      
      for (_, interface) in interfaceDevices {
        if let info = interface.locoNetProductInfo, info.attributes.contains(.LocoNetInterface) {
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
      
      for (_, network) in networks {
        if network.layoutId == layoutId {
          for kv in locoNetInterfaces {
            let interface = kv.value
            if interface.primaryKey == network.interfaceId {
              interface.networkId = network.primaryKey
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
  
  public var sensors : [Int:LocoNetDevice] {
    get {
      
      var result : [Int:LocoNetDevice] = [:]
      
      for (_, device) in locoNetDevices {
        if device.isSensorDevice {
          result[device.primaryKey] = device
        }
      }

      return result
      
    }
  }
  
  public func ioFunctions(networkId:Int) -> [IOFunction] {
    
    var result : [IOFunction] = []
    
    for (_, device) in locoNetDevices {
      if let ioDevice = device as? IODevice, ioDevice.networkId == networkId {
        for ioChannel in ioDevice.ioChannels {
          for ioFunction in ioChannel.ioFunctions {
            result.append(ioFunction)
          }
        }
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
  
  private func networkControllerUpdated() {
    for kv in controllerDelegates {
      kv.value.networkControllerUpdated?(netwokController: self)
    }
  }
  
  @objc func checkPortsTimerAction() {
    MTSerialPortManager.checkPorts()
  }
  
  // MARK: Public Methods

  public func sensors(sensorTypes: Set<SensorType>) -> [Sensor] {
    
    var result : [Sensor] = []
    
    for (_, device) in sensors {
      
      for sensor in device.sensors {
        if sensorTypes.contains(sensor.sensorType) {
          result.append(sensor)
        }
      }
      
    }
    
    result.sort {$0.comboSortOrder < $1.comboSortOrder}
    
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
  
  public func commandStationInterface(commandStation:Interface) -> Interface? {
    if let network = networks[commandStation.networkId] {
      return network.interface
    }
    return nil
  }
  
  public func networkControllerStatusUpdated() {
    for (_, value) in controllerDelegates {
      value.statusUpdated?(networkController: self)
    }
  }
  
  public func switchBoardUpdated() {
    for (_, value) in controllerDelegates {
      value.switchBoardUpdated?()
    }
  }
  
  public func connect() {
    for interface in networkInterfaces {
      interface.initSensorLookup()
      interface.open()
    }
    connected = true
  }
  
  public func disconnect() {
    for interface in networkInterfaces {
      interface.close()
    }
    connected = false
  }
  
  public func powerOn() {
    for interface in networkInterfaces {
      interface.powerOn()
    }
  }
  
  public func powerOff() {
    for interface in networkInterfaces {
      interface.powerOff()
    }
  }

  public func powerIdle() {
    for interface in networkInterfaces {
      interface.powerIdle()
    }
  }

  public func addLayout(layout: Layout) {
    layouts[layout.primaryKey] = layout
    networkControllerUpdated()
  }
  
  public func removeLayout(primaryKey:Int) {
    layouts.removeValue(forKey: primaryKey)
    networkControllerUpdated()
  }
  
  public func addNetwork(network: Network) {
    networks[network.primaryKey] = network
    connected ? connect() : disconnect()
    networkControllerUpdated()
  }
  
  public func removeNetwork(primaryKey:Int) {
    networks.removeValue(forKey: primaryKey)
    connected ? connect() : disconnect()
    networkControllerUpdated()
  }
  
  public func addDevice(device: LocoNetDevice) {
    locoNetDevices[device.primaryKey] = device
    connected ? connect() : disconnect()
    networkControllerUpdated()
  }
  
  public func removeDevice(primaryKey:Int) {
    locoNetDevices.removeValue(forKey: primaryKey)
    connected ? connect() : disconnect()
    networkControllerUpdated()
  }
  
  public func addRollingStock(rollingStock: RollingStock) {
    self.rollingStock[rollingStock.primaryKey] = rollingStock
    networkControllerUpdated()
  }
  
  public func removeRollingStock(primaryKey: Int) {
    self.rollingStock.removeValue(forKey: primaryKey)
    networkControllerUpdated()
  }
  
  public func appendDelegate(delegate:NetworkControllerDelegate) -> Int {
    controllerDelegateLock.lock()
    let id = _nextControllerDelegateId
    _nextControllerDelegateId += 1
    controllerDelegates[id] = delegate
    controllerDelegateLock.unlock()
    delegate.networkControllerUpdated?(netwokController: self)
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
        if interface.devicePath == path {
          interface.open()
        }
      }
    }
    networkControllerStatusUpdated()
  }
  
  public func serialPortWasRemoved(path: String) {
    if connected {
      for interface in networkInterfaces {
        if interface.devicePath == path {
          interface.close()
        }
      }
    }
    networkControllerStatusUpdated()
  }
  
  // MARK: CommandStationDelegate Methods
  
  public func trackStatusChanged(commandStation: LocoNetDevice) {
    for delegate in controllerDelegates {
      delegate.value.statusUpdated?(networkController: self)
    }
  }

}
