//
//  SpeedProfilerVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 01/08/2022.
//

import Foundation
import Cocoa

class SpeedProfilerVC: NSViewController, NSWindowDelegate, InterfaceDelegate {
 
  // MARK: Window & View Control
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }

  func windowWillClose(_ notification: Notification) {
    if observerId != -1 {
      interface?.removeObserver(id: observerId)
    }
  }
  
  override func viewWillAppear() {
    
    self.view.window?.delegate = self
    
    cboProfilerMode.selectItem(at: 0)
    
    UnitSpeed.populate(comboBox: cboUnits)
    
    SpeedProfileResultsType.populate(comboBox: cboResultsType)
    
    cboLocomotiveDS.dictionary = networkController.locomotives
    
    cboLocomotive.dataSource = cboLocomotiveDS
    
    BestFitMethod.populate(comboBox: cboBestFitMethod)
    
    UnitLength.populate(comboBox: cboLengthUnits)
    
    cboLocomotiveDirection.selectItem(at: 0)
    
    if cboLocomotive.numberOfItems > 0 {
      cboLocomotive.selectItem(at: 0)
    }
    
    cboRoute.removeAllItems()
    if let layout = networkController.layout {
      for loopName in layout.loopNames {
        cboRoute.addItem(withObjectValue: loopName)
      }
    }
    if cboRoute.numberOfItems > 0 {
      cboRoute.selectItem(at: 0)
      cboRouteAction(cboRoute)
    }
    
    setupLoco()
    
  }
  
  // MARK: Private Properties
  
  private enum Mode {
    case idle
    case gettingUptoSpeed
    case doingTiming
    case setupNextRun
  }
  
  private var mode : Mode = .idle {
    didSet {
      lblStatus.stringValue = "\(mode) \(currentStep) \(locomotiveDirection)"
    }
  }
  
  private var cboLocomotiveDS = ComboBoxDictDS()
  
  private var tableViewDS = SpeedProfileTableViewDS()
  
  private var locomotive : Locomotive?
  
  private var interface : Interface?
  
  private var observerId : Int = -1
  
  private var lastBlockIndex : Int = -1
  
  private var triggerCount : Int = 0
  
  private var currentStep : Int = 40
  
  private var locomotiveDirection : LocomotiveDirection = .forward
  
  private var totalDistance : Double = 0.0
  
  private var startTime : TimeInterval = 0.0
  
  private var route : Route = []
  
  private var routeDirection : LocomotiveDirection = .forward
  
  // MARK: Private Methods
  
  private func setupLoco() {
    
    scrollView.isHidden = true
    lblStatus.isHidden = true
    
    tableViewDS.speedProfile = nil
    tableView.dataSource = nil
    tableView.delegate = nil
    
    if cboLocomotive.indexOfSelectedItem != -1 {
      
      if let locomotive = cboLocomotiveDS.editorObjectAt(index: cboLocomotive.indexOfSelectedItem) as? Locomotive {
        
        self.locomotive = locomotive
        
        tableViewDS.unitSpeed = UnitSpeed.selected(comboBox: cboUnits)
        
        tableViewDS.resultsType = SpeedProfileResultsType.selected(comboBox: cboResultsType)
        
        resultsView.speedUnits = tableViewDS.unitSpeed

        tableViewDS.speedProfile = locomotive.speedProfile
        
        cboBestFitMethod.selectItem(at: locomotive.newBestFitMethod.rawValue)
        
        tableView.dataSource = tableViewDS
        tableView.delegate = tableViewDS
        
        scrollView.isHidden = false
        lblStatus.isHidden = false
        
        resultsView.locomotive = locomotive
        resultsView.needsDisplay = true

      }

    }
    
    tableView.reloadData()

  }
  
  // MARK: InterfaceDelegate Methods
  
  @objc func networkMessageReceived(message:NetworkMessage) {
    
    switch message.messageType {
    case .sensRepGenIn:
      
      locomotive?.targetSpeed = (speed: currentStep, direction:locomotiveDirection)

      if mode == .idle || mode == .setupNextRun {
        return
      }
      
      if let block = interface?.sensorLookup[message.sensorAddress], message.sensorState {
        
        var newIndex : Int = -1
        
        var temp = 0
        while temp < route.count {
          if block == route[temp].fromSwitchBoardItem {
            newIndex = temp
            break
          }
          temp += 1
        }
        
        if newIndex != -1 {
          
          if mode == .gettingUptoSpeed {
            triggerCount += 1
            if triggerCount == 3 {
              mode = .setupNextRun
              totalDistance = 0.0
              startTime = message.timeStamp
              triggerCount = 0
              mode = .doingTiming
            }
          }
          else if mode == .doingTiming {
            
            if routeDirection == locomotiveDirection {
              var temp = lastBlockIndex
              while temp != newIndex {
                totalDistance += route[lastBlockIndex].distance
                temp += 1
                if temp == route.count {
                  temp = 0
                }
              }
            }
            else {
              var temp = lastBlockIndex
              while temp != newIndex {
                totalDistance += route[lastBlockIndex].distance
                temp -= 1
                if temp < 0 {
                  temp = route.count - 1
                }
              }

            }
            
            triggerCount += 1
            
            if triggerCount == route.count * 2 {
              
              mode = .setupNextRun
              
              let totalTime = message.timeStamp - startTime
              
              var speed : Double = 0.0
              
              if totalTime != 0.0 {
                speed = totalDistance / totalTime
              }
              
              if locomotiveDirection == .forward {
                tableViewDS.speedProfile![currentStep].newSpeedForward = speed
              }
              else {
                tableViewDS.speedProfile![currentStep].newSpeedReverse = speed
              }
              
              tableView.reloadData()
              
              resultsView.needsDisplay = true
              
              currentStep += 1
              
              if currentStep == 127 {
                currentStep = txtStartStep.integerValue
                if cboLocomotiveDirection.indexOfSelectedItem == 2 && locomotiveDirection == .forward {
                  locomotiveDirection = .reverse
                }
                else {
                  currentStep = 0
                  mode = .idle
                }
              }

              locomotive!.targetSpeed = (speed: currentStep, direction:locomotiveDirection)
              
              triggerCount = 0
              
              mode = .gettingUptoSpeed

            }
            
          }
          
          lastBlockIndex = newIndex
          
        }
                
      }

    default:
      break
    }
  }

  
  // MARK: Outlets & Actions
  
  @IBOutlet weak var cboProfilerMode: NSComboBox!
  
  @IBAction func cboProfilerModeAction(_ sender: NSComboBox) {
  }
  
  @IBOutlet weak var cboRoute: NSComboBox!
  
  @IBAction func cboRouteAction(_ sender: NSComboBox) {
    
    lblRouteLength.stringValue = ""
    
    if let layout = networkController.layout {
      let units = UnitLength.selected(comboBox: cboLengthUnits)
      lblRouteLength.stringValue = String(format: "%.1f", layout.loopLengths[cboRoute.indexOfSelectedItem] * units.fromCM)
    }
    
  }
  
  @IBOutlet weak var cboLocomotive: NSComboBox!
  
  @IBAction func cboLocomotiveAction(_ sender: NSComboBox) {
    setupLoco()
  }
  
  @IBOutlet weak var tableView: NSTableView!
  
  @IBOutlet weak var lblStatus: NSTextField!
  
  @IBOutlet weak var cboUnits: NSComboBox!
  
  @IBAction func cboUnitsAction(_ sender: NSComboBox) {
    tableViewDS.unitSpeed = UnitSpeed.selected(comboBox: cboUnits)
    tableView.reloadData()
    resultsView.speedUnits = tableViewDS.unitSpeed
  }
  
  @IBOutlet weak var btnStartProfiler: NSButton!
  
  @IBAction func btnStartProfilerAction(_ sender: NSButton) {
    
    if mode == .idle {
      
      if observerId != -1 {
        interface?.removeObserver(id: observerId)
        observerId = -1
      }
      
      if let locomotive = self.locomotive, let layout = networkController.layout, cboRoute.indexOfSelectedItem != -1 {
        
        btnStartProfiler.title = "Stop Profiler"
        route = layout.loops[cboRoute.indexOfSelectedItem]
        lastBlockIndex = -1
        locomotive.isInUse = true
        locomotive.isInertial = false
        resultsView.locomotive = locomotive
        
        locomotiveDirection = cboLocomotiveDirection.indexOfSelectedItem == 1 ? .reverse : .forward

        for profile in tableViewDS.speedProfile! {
          if cboLocomotiveDirection.indexOfSelectedItem == 0 || cboLocomotiveDirection.indexOfSelectedItem == 2 {
            profile.newSpeedForward = 0.0
          }
          if cboLocomotiveDirection.indexOfSelectedItem == 1 || cboLocomotiveDirection.indexOfSelectedItem == 2 {
            profile.newSpeedReverse = 0.0
          }
        }
        
        tableView.reloadData()
        
        locomotive.targetSpeed = (speed: 20, direction:locomotiveDirection)
        
        if let interface = locomotive.network?.interface {
          self.interface = interface
          observerId = interface.addObserver(observer: self)
        }
        
        let alert = NSAlert()

        alert.messageText = "In which direction is the locomotive travelling relative to the order of the blocks in the selected route?"
        alert.informativeText = ""
        alert.addButton(withTitle: "Forward")
        alert.addButton(withTitle: "Reverse")
        alert.alertStyle = .informational

        if alert.runModal() == .alertFirstButtonReturn {
          routeDirection = .forward
        }
        else {
          routeDirection = .reverse
        }

        triggerCount = 0
        
        currentStep = txtStartStep.integerValue

        mode = .gettingUptoSpeed
        
        locomotive.targetSpeed = (speed: currentStep, direction:locomotiveDirection)
        
      }
    }
    else {
      btnStartProfiler.title = "Start Profiler"
      mode = .idle
      if let locomotive = self.locomotive {
        locomotive.targetSpeed = (speed: 0, direction:.forward)
     //   locomotive.isInUse = false
        locomotive.isInertial = false
      }
    }
    
  }
  
  @IBOutlet weak var btnSave: NSButton!
  
  @IBAction func btnSaveAction(_ sender: NSButton) {
    locomotive?.save()
  }
  
  @IBOutlet weak var scrollView: NSScrollView!
  
  @IBOutlet weak var btnSetRoute: NSButton!
  
  @IBAction func btnSetRouteAction(_ sender: NSButton) {
    
    if let layout = networkController.layout, cboRoute.indexOfSelectedItem != -1 {
      layout.setRoute(route: layout.loops[cboRoute.indexOfSelectedItem])
    }
    
  }
  
  @IBOutlet weak var resultsView: SpeedResultsView!
  
  @IBOutlet weak var cboBestFitMethod: NSComboBox!
  
  @IBAction func cboBestFitMethodAction(_ sender: NSComboBox) {
    locomotive?.newBestFitMethod = BestFitMethod.selected(comboBox: sender)
    tableView.reloadData()
  }
  
  @IBOutlet weak var cboResultsType: NSComboBox!
  
  @IBAction func cboResultsType(_ sender: NSComboBox) {
    tableViewDS.resultsType = SpeedProfileResultsType.selected(comboBox: cboResultsType)
    tableView.reloadData()
  }
  
  @IBOutlet weak var lblRouteLength: NSTextField!
  
  @IBOutlet weak var cboLengthUnits: NSComboBox!
  
  @IBAction func cboLengthUnitsAction(_ sender: NSComboBox) {
    cboRouteAction(cboRoute)
  }
  
  @IBOutlet weak var cboLocomotiveDirection: NSComboBox!
  
  @IBAction func cboLocomotiveDirectionAction(_ sender: NSComboBox) {
  }
  
  @IBOutlet weak var txtStartStep: NSTextField!
  
  @IBAction func txtStartStepAction(_ sender: NSTextField) {
  }
  
}

