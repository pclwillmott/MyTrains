//
//  NetworkController.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/11/2021.
//

import Foundation
import ORSSerial

public protocol NetworkControllerDelegate {
  func messengersUpdated(messengers:[NetworkMessenger])
  func networkControllerUpdated(netwokController:NetworkController)
}

public class NetworkController : NSObject, NetworkInterfaceDelegate, NSUserNotificationCenterDelegate, NetworkMessengerDelegate {
  
  // MARK: Constructor
  
  override init() {
    
    super.init()
    
    let nc = NotificationCenter.default
      nc.addObserver(self, selector: #selector(serialPortsWereConnected(_:)), name: NSNotification.Name.ORSSerialPortsWereConnected, object: nil)
      nc.addObserver(self, selector: #selector(serialPortsWereDisconnected(_:)), name: NSNotification.Name.ORSSerialPortsWereDisconnected, object: nil)
      
      NSUserNotificationCenter.default.delegate = self

      findPorts()
  }
  
  // MARK: Destructor
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: Private Properties
  
  private var controllerDelegates : [Int:NetworkControllerDelegate] = [:]
  
  private var _nextControllerDelegateId : Int = 0
  
  private var controllerDelegateLock : NSLock = NSLock()
  
  private var _layoutId : Int = -1
  
  private var locomotivesByName    : [String:Locomotive] = [:]
  
  private var locomotivesByAddress : [UInt16:Locomotive] = [:]
  
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
  
  private var candidates : [String:NetworkMessenger] = [:]
  
  private var _networkMessengers : [String:NetworkMessenger] = [:]
  
  private var _observerIds : [String:Int] = [:]
  
  // MARK: Private Methods
  
  private func findPorts() {
    for port in ORSSerialPortManager.shared().availablePorts {
      let candidate = NetworkMessenger(id: nextMessengerId, path: port.path)
      var duplicate = false
      for messenger in networkMessengers {
        if candidate.devicePath == messenger.devicePath {
          duplicate = true
          break
        }
      }
      if !duplicate {
        candidate.networkInterfaceDelegate = self
        candidates[candidate.id] = candidate
      }
    }
  }
  
  // MARK: Public Properties
  
  public var networks : [Int:Network] = Network.networks
  
  public var layouts : [Int:Layout] = Layout.layouts
  
  public var locomotives : [Int:Locomotive] = Locomotive.locomotives
  
  public var commandStations : [Int:CommandStation] = [:]
  
  public var layoutId : Int {
    get {
      _layoutId = UserDefaults.standard.integer(forKey: DEFAULT.MAIN_CURRENT_LAYOUT_ID)
      
      return _layoutId == 0 ? -1 : _layoutId
    }
    set(value) {
      if value != layoutId {
        _layoutId = value
        UserDefaults.standard.set(_layoutId, forKey: DEFAULT.MAIN_CURRENT_LAYOUT_ID)
      }
    }
  }
  
  public var layout : Layout? {
    get {
      return layouts[layoutId]
    }
  }
  
  public var networkMessengers : [NetworkMessenger] {
    get {
      var messengers : [NetworkMessenger] = []
      for messenger in _networkMessengers {
        messengers.append(messenger.value)
      }
      return messengers.sorted {
        $0.id < $1.id
      }
    }
  }
  
  // MARK: Public Methods

  public func addLayout(layout: Layout) {
    layouts[layout.primaryKey] = layout
    for kv in controllerDelegates {
      kv.value.networkControllerUpdated(netwokController: self)
    }
  }
  
  public func removeLayout(primaryKey:Int) {
    layouts.removeValue(forKey: primaryKey)
    for kv in controllerDelegates {
      kv.value.networkControllerUpdated(netwokController: self)
    }
  }
  
  public func addNetwork(network: Network) {
    networks[network.primaryKey] = network
    for kv in controllerDelegates {
      kv.value.networkControllerUpdated(netwokController: self)
    }
  }
  
  public func removeNetwork(primaryKey:Int) {
    networks.removeValue(forKey: primaryKey)
    for kv in controllerDelegates {
      kv.value.networkControllerUpdated(netwokController: self)
    }
  }
  
  public func appendDelegate(delegate:NetworkControllerDelegate) -> Int {
    controllerDelegateLock.lock()
    let id = _nextControllerDelegateId
    _nextControllerDelegateId += 1
    controllerDelegates[id] = delegate
    controllerDelegateLock.unlock()
    delegate.networkControllerUpdated(netwokController: self)
    return id
  }
  
  public func removeDelegate(id:Int) {
    controllerDelegateLock.lock()
    controllerDelegates.removeValue(forKey: id)
    controllerDelegateLock.unlock()
  }
  
  public func interfaceNotIdentified(messenger: NetworkMessenger) {
    candidates.removeValue(forKey: messenger.id)
  }
  
  public func interfaceIdentified(messenger: NetworkMessenger) {
    
    _networkMessengers[messenger.id] = messenger
    _observerIds[messenger.id] = messenger.addObserver(observer: self)
    
    candidates.removeValue(forKey: messenger.id)
    for delegate in controllerDelegates {
      delegate.value.messengersUpdated(messengers: networkMessengers)
      delegate.value.networkControllerUpdated(netwokController: self)
    }
    
    let message = NetworkMessage(interfaceId: messenger.id, data: [NetworkMessageOpcode.OPC_PEER_XFER.rawValue,
      0x14, 0x0f, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
      ], appendCheckSum: true)
    
    messenger.addToQueue(message: message, delay: TIMING.DISCOVER, response: [], delegate: nil, retryCount: 1)
    
  }
  
  public func networkMessageReceived(message: NetworkMessage) {
    
    switch message.messageType {
    case .iplDevData:
      
      let devData = IPLDevData(interfaceId: message.interfaceId, data: message.message)
      
      let pc = devData.productCode
      
      if pc == .DCS210 || pc == .DCS210Plus || pc == .DCS210 || pc == .DCS240 {
        
        if let cs = commandStations[devData.serialNumber] {
          cs.addInterface(interface: _networkMessengers[message.interfaceId]!)
        }
        else {
          let cs = CommandStation(message: devData)
          commandStations[cs.serialNumber] = cs
          cs.addInterface(interface: _networkMessengers[message.interfaceId]!)
          for delegate in controllerDelegates {
            delegate.value.networkControllerUpdated(netwokController: self)
          }
        }
        
      }
      
      break
    default:
      break
    }
    
  }
  
  public func networkTimeOut(message: NetworkMessage) {
  }
  
  public func messengerRemoved(id: String) {
  }
  
  public func interfaceRemoved(messenger: NetworkMessenger) {
    let id = messenger.id
    candidates.removeValue(forKey: id)
    _networkMessengers.removeValue(forKey: id)
    for delegate in controllerDelegates {
      delegate.value.messengersUpdated(messengers: networkMessengers)
      delegate.value.networkControllerUpdated(netwokController: self)
    }
  }
      
  // MARK: - NSUserNotifcationCenterDelegate
    
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
        findPorts()
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
