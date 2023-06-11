//
//  RouteManagerVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 08/10/2022.
//

import Foundation
import Cocoa

public typealias SwitchRoute = (switchNumber: Int, switchState:TurnoutSwitchState)

class RouteManagerVC : NSViewController, NSWindowDelegate, InterfaceDelegate {
  
  // MARK: Window & View Control
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }
  
  func windowWillClose(_ notification: Notification) {
    interface?.removeObserver(id: observerId)
    observerId = -1
  }
  
  override func viewWillAppear() {
    
    self.view.window?.delegate = self
    
    cboHostDS.dictionary = networkController.routeHosts
    
    cboHost.dataSource = cboHostDS
    
    tableViewDS.route = route
    tableView.dataSource = tableViewDS
    tableView.delegate = tableViewDS
    tableView.reloadData()
    
    if cboHost.numberOfItems > 0 {
      
      let key = UserDefaults.standard.integer(forKey: DEFAULT.ROUTE_MANAGER_HOST)
      
      if let index = cboHostDS.indexWithKey(key: key), let host = cboHostDS.editorObjectAt(index: index) as? LocoNetDevice {
        cboHost.selectItem(at: index)
        self.host = host
      }
      else if let host = cboHostDS.editorObjectAt(index: 0) as? LocoNetDevice {
        cboHost.selectItem(at: 0)
        self.host = host
      }
      
      setupHost()
      
    }

  }
  
  // MARK: Private Properties
  
  private var cboHostDS : ComboBoxDictDS = ComboBoxDictDS()
  
  private var tableViewDS = RouteManagerTableViewDS()

  var observerId : Int = -1
  
  var interface : Interface?
  
  var route : [SwitchRoute] = []
  
  var host : LocoNetDevice?
  
  var numberOfRoutes : Int = 0
  
  var switchesPerRoute : Int = 0
  
  var numberOfPages : Int = 0
  
  var currentPage : Int = 0
  
  // MARK: Private Methods
  
  private func setupHost() {
    
    interface?.removeObserver(id: observerId)
    observerId = -1

    route = []
    
    tableViewDS.route = route
    tableView.dataSource = tableViewDS
    tableView.delegate = tableViewDS
    tableView.reloadData()
    
    cboRouteNumber.removeAllItems()

    if let host = self.host, let interface = host.network?.interface {
      self.interface = interface
      observerId = interface.addObserver(observer: self)
      interface.getRouteTableInfoA()
    }
    
  }
  
  // MARK: InterfaceDelegate Methods
  
  @objc func networkMessageReceived(message: NetworkMessage) {
    
    switch message.messageType {
    case .routeTableInfoA:
      switchesPerRoute = Int(message.message[8])
      numberOfPages =  switchesPerRoute / 4
      numberOfRoutes = switchesPerRoute << 2
      for index in 1...numberOfRoutes {
        cboRouteNumber.addItem(withObjectValue: "\(index)")
      }
      cboRouteNumber.selectItem(at: 0)
      route = []
      
      tableViewDS.route = route
      tableView.reloadData()

      if let interface = self.interface, numberOfPages > 0 {
        
        currentPage = 0
        
        interface.getRouteTablePage(routeNumber: cboRouteNumber.integerValue, pageNumber: currentPage, pagesPerRoute: numberOfPages)

      }
      
    case .routeTablePage:
      
      var combined = Int(message.message[4])
      combined |= ((message.message[5] & 0b1) == 0b1) ? 0b10000000 : 0
  //    let pageNumber = combined & (numberOfPages - 1)
  //    let routeNumber = (combined >> (numberOfPages / 2)) + 1
      
      for index in 0...3 {
  //      var entryNumber = pageNumber * 4 + index + 1
        var switchNumber = Int(message.message[7 + index * 2]) + 1
        switchNumber |= (Int(message.message[8 + index * 2]) & 0x0f)
        var switchState : TurnoutSwitchState = (message.message[8 + index * 2] & 0b100000) == 0 ? .thrown : .closed
        
        if message.message[7 + index * 2] == 0x7f && message.message[8 + index * 2] == 0x7f {
          switchNumber = 0x7f
          switchState = .unknown
        }
        let sr : SwitchRoute = (switchNumber: switchNumber, switchState:switchState)
        
        route.append(sr)
      }
      
      tableViewDS.route = route
      tableView.reloadData()
      
      currentPage += 1
      if currentPage < numberOfPages {
        interface?.getRouteTablePage(routeNumber: cboRouteNumber.integerValue, pageNumber: currentPage, pagesPerRoute: numberOfPages)
      }
      
    case .routesDisabled:
      break
    default:
      break
    }
    
  }
  
  // MARK: Outlets & Actions
  
  @IBOutlet weak var cboHost: NSComboBox!
  
  @IBAction func cboHostAction(_ sender: NSComboBox) {
    if let host = cboHostDS.editorObjectAt(index: cboHost.indexOfSelectedItem) as? LocoNetDevice {
      self.host = host
      UserDefaults.standard.set(host.primaryKey, forKey: DEFAULT.ROUTE_MANAGER_HOST)
      setupHost()
    }
  }
  
  @IBOutlet weak var cboRouteNumber: NSComboBox!
  
  @IBAction func cboRouteNumberAction(_ sender: NSComboBox) {
    
    route = []
    
    tableViewDS.route = route
    tableView.reloadData()

    if let interface = self.interface, numberOfPages > 0 {
      
      currentPage = 0
      
      interface.getRouteTablePage(routeNumber: cboRouteNumber.integerValue, pageNumber: currentPage, pagesPerRoute: numberOfPages)

    }
    
  }
  
  @IBOutlet weak var btnLoadRoute: NSButton!
  
  @IBAction func btnLoadRouteAction(_ sender: NSButton) {
    
    route = []
    
    tableViewDS.route = route
    tableView.reloadData()

    if let interface = self.interface, numberOfPages > 0 {
      
      currentPage = 0
      
      interface.getRouteTablePage(routeNumber: cboRouteNumber.integerValue, pageNumber: currentPage, pagesPerRoute: numberOfPages)

    }
    
  }
  @IBOutlet weak var btnSaveRoute: NSButton!
  
  @IBAction func btnSaveRouteAction(_ sender: NSButton) {
    if route.count > 0 {
      interface?.setRouteTablePages(routeNumber: cboRouteNumber.integerValue, route: route, pagesPerRoute: numberOfPages)
    }
  }
  
  @IBOutlet weak var tableView: NSTableView!
  
  @IBAction func tableViewAction(_ sender: NSTableView) {
  }
  
  @IBAction func txtSwitchAddressAction(_ sender: NSTextField) {
    let entryNumber = sender.tag
    if sender.stringValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      route[entryNumber].switchNumber = 0x7f
      route[entryNumber].switchState = .unknown
    }
    else {
      route[entryNumber].switchNumber = sender.integerValue
    }
    tableViewDS.route = route
    tableView.reloadData()
  }
  
  @IBAction func cboSwitchStateAction(_ sender: NSComboBox) {
    let entryNumber = sender.tag
    let switchState = TurnoutSwitchState.selected(comboBox: sender)
    if switchState == .unknown {
      route[entryNumber].switchNumber = 0x7f
      route[entryNumber].switchState = .unknown
    }
    else {
      route[entryNumber].switchState = switchState
    }
    tableViewDS.route = route
    tableView.reloadData()
  }
  
}

