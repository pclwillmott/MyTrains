//
//  NetworkController.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/11/2021.
//

import Foundation
import ORSSerial

@objc public protocol NetworkControllerDelegate {
  @objc optional func interfacesUpdated(interfaces:[Interface])
  @objc optional func networkControllerUpdated(netwokController:NetworkController)
  @objc optional func statusUpdated(networkController:NetworkController)
}

public class NetworkController : NSObject, InterfaceDelegate, NSUserNotificationCenterDelegate, CommandStationDelegate {
  
  // MARK: Constructor
  
  override init() {
    
    super.init()
    
    let nc = NotificationCenter.default
    
    nc.addObserver(self, selector: #selector(serialPortsWereConnected(_:)), name: NSNotification.Name.ORSSerialPortsWereConnected, object: nil)

    nc.addObserver(self, selector: #selector(serialPortsWereDisconnected(_:)), name: NSNotification.Name.ORSSerialPortsWereDisconnected, object: nil)

    NSUserNotificationCenter.default.delegate = self

  }
  
  // MARK: Destructor
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: Private Properties
  
  private var controllerDelegates : [Int:NetworkControllerDelegate] = [:]
  
  private var _nextControllerDelegateId : Int = 0
  
  private var controllerDelegateLock : NSLock = NSLock()
  
  private var _nextMessengerId : Int = 1
  
  private var _nextIdLock : NSLock = NSLock()
  
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
  
  public var networks : [Int:Network] = Network.networks

  public var layouts : [Int:Layout] = Layout.layouts

  public var locomotives : [Int:Locomotive] = [:] // Locomotive.locomotives

  public var commandStations : [Int:CommandStation] = [:] // CommandStation.commandStationsDictionary
  
  public var locoNetDevices : [Int:LocoNetDevice] = LocoNetDevice.locoNetDevices
  
  public var interfaceDevices : [Int:Interface] {
    
    get {
      
      var result : [Int:Interface] = [:]
      
      for kv in locoNetDevices {
        
        let device = Interface(device: kv.value)
        if let info = device.locoNetProductInfo, info.attributes.contains(.ComputerInterface) {
          result[device.primaryKey] = device
        }
        
      }
      
      return result
      
    }
    
  }

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
  
  public var networkInterfaces : [Interface] {
    get {
      var interfaces : [Interface] = []
      
      for kv in networks {
        let network = kv.value
        if network.layoutId == layoutId {
          for kv in interfaceDevices {
            let interface = kv.value
            if interface.primaryKey == network.locoNetDeviceId {
              interfaces.append(interface)
            }
          }
        }
      }
      return interfaces.sorted {
        $0.interfaceName < $1.interfaceName
      }
    }
  }
  
  public var softwareThrottleID : Int? {
    get {
  //    return 0
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
  
  // MARK: Public Methods

  public func connect() {
    if !connected {
      for interface in networkInterfaces {
        interface.open()
      }
      connected = true
    }
  }
  
  public func disconnect() {
    if connected {
      for interface in networkInterfaces {
        interface.close()
      }
      connected = false
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
    networkControllerUpdated()
  }
  
  public func removeNetwork(primaryKey:Int) {
    networks.removeValue(forKey: primaryKey)
    networkControllerUpdated()
  }
  
  public func addDevice(device: LocoNetDevice) {
    locoNetDevices[device.primaryKey] = device
    networkControllerUpdated()
  }
  
  public func removeDevice(primaryKey:Int) {
    locoNetDevices.removeValue(forKey: primaryKey)
    networkControllerUpdated()
  }
  
  public func addLocomotive(locomotive: Locomotive) {
    locomotives[locomotive.primaryKey] = locomotive
    networkControllerUpdated()
  }
  
  public func removeLocomotive(primaryKey: Int) {
    locomotives.removeValue(forKey: primaryKey)
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
  
  // MARK: CommandStationDelegate Methods
  
  public func trackStatusChanged(commandStation: CommandStation) {
    for delegate in controllerDelegates {
      delegate.value.statusUpdated?(networkController: self)
    }
  }

  // MARK: - NSUserNotificationCenterDelegate
    
  public func userNotificationCenter(_ center: NSUserNotificationCenter, didDeliver notification: NSUserNotification) {
    let popTime = DispatchTime.now() + Double(Int64(3.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: popTime) { () -> Void in
      center.removeDeliveredNotification(notification)
    }
  }
  
  public func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
    return true
  }

  @objc func serialPortsWereConnected(_ notification: Notification) {
    if let userInfo = notification.userInfo {
      let connectedPorts = userInfo[ORSConnectedSerialPortsKey] as! [ORSSerialPort]
      self.postUserNotificationForConnectedPorts(connectedPorts)
    }
  }
  
  @objc func serialPortsWereDisconnected(_ notification: Notification) {
    if let userInfo = notification.userInfo {
      let disconnectedPorts: [ORSSerialPort] = userInfo[ORSDisconnectedSerialPortsKey] as! [ORSSerialPort]
      self.postUserNotificationForDisconnectedPorts(disconnectedPorts)
    }
  }
  
  func postUserNotificationForConnectedPorts(_ connectedPorts: [ORSSerialPort]) {
    let unc = NSUserNotificationCenter.default
    for port in connectedPorts {
      let userNote = NSUserNotification()
      userNote.title = NSLocalizedString("Serial Port Connected", comment: "Serial Port Connected")
      userNote.informativeText = "Serial Port \(port.name) was connected to your Mac."
      userNote.soundName = nil;
      unc.deliver(userNote)
    }
  }
  
  func postUserNotificationForDisconnectedPorts(_ disconnectedPorts: [ORSSerialPort]) {
    let unc = NSUserNotificationCenter.default
    for port in disconnectedPorts {
      let userNote = NSUserNotification()
      userNote.title = NSLocalizedString("Serial Port Disconnected", comment: "Serial Port Disconnected")
      userNote.informativeText = "Serial Port \(port.name) was disconnected from your Mac."
      userNote.soundName = nil;
      unc.deliver(userNote)
    }

  }

}
