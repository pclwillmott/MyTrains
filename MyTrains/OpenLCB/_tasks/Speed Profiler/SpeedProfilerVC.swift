//
//  SpeedProfilerVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 01/08/2022.
//

import Foundation
import Cocoa

class SpeedProfilerVC: MyTrainsViewController {
 
  // MARK: Window & View Control
  
  override func windowWillClose(_ notification: Notification) {
    if observerId != -1 {
//      interface?.removeObserver(id: observerId)
    }
    super.windowWillClose(notification)
  }
  
  override func viewWillAppear() {
    
    super.viewWillAppear()
    
    cboProfilerMode.selectItem(at: 0)
    
    UnitSpeed.populate(comboBox: cboUnits)
    
    SpeedProfileResultsType.populate(comboBox: cboResultsType)
    
//    cboLocomotiveDS.dictionary = myTrainsController.locomotives
    
 //   cboLocomotive.dataSource = cboLocomotiveDS
    
    BestFitMethod.populate(comboBox: cboBestFitMethod)
    
    UnitLength.populate(comboBox: cboLengthUnits)
    
    SamplePeriod.populate(comboBox: cboSampleSize)
    cboSampleSize.selectItem(at: UserDefaults.standard.integer(forKey: DEFAULT.SPEED_PROFILER_SAMPLE_SIZE))
    
    cboLocomotiveDirection.selectItem(at: 0)
    
    if cboLocomotive.numberOfItems > 0 {
      cboLocomotive.selectItem(at: 0)
    }
    
    cboRoute.removeAllItems()
//    if let layout = myTrainsController.layout {
//      for loopName in layout.loopNames {
//        cboRoute.addItem(withObjectValue: loopName)
//      }
//    }
    if cboRoute.numberOfItems > 0 {
      cboRoute.selectItem(at: 0)
      cboRouteAction(cboRoute)
    }
    
    txtStartStep.integerValue = UserDefaults.standard.integer(forKey: DEFAULT.SPEED_PROFILER_START_STEP)
    txtStartStep.integerValue = txtStartStep.integerValue == 0 ? 1 : txtStartStep.integerValue
    
    txtStopStep.integerValue = UserDefaults.standard.integer(forKey: DEFAULT.SPEED_PROFILER_STOP_STEP)
    txtStopStep.integerValue = txtStopStep.integerValue == 0 ? 126 : txtStopStep.integerValue
    
    chkShowTrendline.state = NSControl.StateValue(rawValue: UserDefaults.standard.integer(forKey: DEFAULT.SPEED_PROFILER_TRENDLINE))

    cboLengthUnits.selectItem(at: UserDefaults.standard.integer(forKey: DEFAULT.SPEED_PROFILER_LENGTH_UNITS))
    
    cboResultsType.selectItem(at: UserDefaults.standard.integer(forKey: DEFAULT.SPEED_PROFILER_RESULTS_TYPE))
    
    cboUnits.selectItem(at: UserDefaults.standard.integer(forKey: DEFAULT.SPEED_PROFILER_SPEED_UNITS))

    setupLoco()
    
  }
  
  // MARK: Private Properties
  
  private enum Mode : Int {
    case idle = 0
    case gettingUptoSpeed = 1
    case doingTiming = 2
    case setupNextRun = 3
    
    public var title : String {
      get {
        return Mode.titles[self.rawValue]
      }
    }
    
    private static let titles = [
      "Idle",
      "Getting up to speed",
      "Doing timing",
      "Setting up",
    ]

  }
  
  private var mode : Mode = .idle {
    didSet {
      if mode == .idle {
        lblStatus.stringValue = "\(mode.title)"
      }
      else {
        lblStatus.stringValue = "\(mode.title) for \(locomotiveDirection.title) Step \(currentStep)"
      }
    }
  }
  
//  private var cboLocomotiveDS = ComboBoxDictDS()
  
  private var tableViewDS = SpeedProfileTableViewDS()
  
//  private var locomotive : Locomotive?
  
//  private var interface : InterfaceLocoNet?
  
  private var observerId : Int = -1
  
  private var lastBlockIndex : Int = -1
  
  private var blocksToIgnore : Set<Int> = []
  
  private var triggerCount : Int = 0
  
  private var currentStep : Int = 40
  
  private var locomotiveDirection : LocomotiveDirection = .forward
  
  private var totalDistance : Double = 0.0
  
  private var startTime : TimeInterval = 0.0
  
//  private var route : Route = []
  
  private var routeDirection : LocomotiveDirection = .forward
  
  private var startDirection : LocomotiveDirection = .forward
  
  // MARK: Private Methods
  
  private func setupLoco() {
    
    scrollView.isHidden = true
    lblStatus.isHidden = true
    
//    tableViewDS.speedProfile = nil
    tableView.dataSource = nil
    tableView.delegate = nil
    
    if cboLocomotive.indexOfSelectedItem != -1 {
      
      /*
      if let locomotive = cboLocomotiveDS.editorObjectAt(index: cboLocomotive.indexOfSelectedItem) as? Locomotive {
        
        self.locomotive = locomotive
        
        tableViewDS.unitSpeed = UnitSpeed.selected(comboBox: cboUnits)
        
        tableViewDS.resultsType = SpeedProfileResultsType.selected(comboBox: cboResultsType)
        
        resultsView.speedUnits = tableViewDS.unitSpeed
        
        resultsView.showTrendline = chkShowTrendline.state == .on
        
        resultsView.dataSet = cboLocomotiveDirection.indexOfSelectedItem

        tableViewDS.speedProfile = locomotive.speedProfile
        
        cboBestFitMethod.selectItem(at: locomotive.newBestFitMethod.rawValue)
        
        tableView.dataSource = tableViewDS
        tableView.delegate = tableViewDS
        
        scrollView.isHidden = false
        lblStatus.isHidden = false
        
        resultsView.locomotive = locomotive
        resultsView.needsDisplay = true

      }
*/
    }
    
    tableView.reloadData()

  }
  
  // MARK: InterfaceDelegate Methods
  
  @objc func networkMessageReceived(message:LocoNetMessage) {
    
    switch message.messageType {
    case .sensRepGenIn:
      
   //   locomotive?.targetSpeed = (speed: UInt8(currentStep), direction:locomotiveDirection)

      if mode == .idle || mode == .setupNextRun {
        return
      }
      /*
      if let block = interface?.generalSensorLookup[message.sensorAddress], message.sensorState {
        
        var newIndex : Int = -1
        
        var temp = 0
        while temp < route.count {
          if block == route[temp].fromSwitchBoardItem {
            newIndex = temp
            break
          }
          temp += 1
        }
        
        if newIndex != -1 && !blocksToIgnore.contains(newIndex) {

          blocksToIgnore.removeAll()
          blocksToIgnore.insert(newIndex)
          
          var extraDistance : Double = 0.0
          
          let goForward = (routeDirection == .forward && locomotiveDirection == startDirection) ||
          (routeDirection == .reverse && locomotiveDirection != startDirection)
          
          if goForward {
            
            var temp = lastBlockIndex
            
            if mode == .doingTiming {
              while temp != newIndex {
                extraDistance += route[temp].distance
                temp += 1
                if temp == route.count {
                  temp = 0
                }
              }
            }
            
            var distance : Double = 0.0
            
            temp = newIndex - 1
            if temp < 0 {
              temp = route.count - 1
            }
            
            while distance < locomotive!.length {
              
              distance += route[temp].distance
              
              blocksToIgnore.insert(temp)
              
              temp = newIndex - 1
              if temp < 0 {
                temp = route.count - 1
              }
              
            }
            
          }
          else {
            
            var temp = lastBlockIndex
            
            if mode == .doingTiming {
              while temp != newIndex {
                extraDistance += route[temp].distance
                temp -= 1
                if temp < 0 {
                  temp = route.count - 1
                }
              }
            }

            var distance : Double = 0.0
            
            temp = newIndex + 1
            if temp == route.count {
              temp = 0
            }
            
            while distance < locomotive!.length {
              
              distance += route[temp].distance
              
              blocksToIgnore.insert(temp)
              
              temp = newIndex + 1
              if temp == route.count {
                temp = 0
              }

            }

          }
          
          let totalTime = message.timeStamp - startTime
        
          if mode == .gettingUptoSpeed {
            
            triggerCount += 1
            
            if totalTime > 2.0 {
              mode = .setupNextRun
              totalDistance = 0.0
              startTime = message.timeStamp
              triggerCount = 0
              mode = .doingTiming
            }
          }
          else if mode == .doingTiming {
            
            totalDistance += extraDistance
            
            triggerCount += 1
            
            let samplePeriod = SamplePeriod.selected(comboBox: cboSampleSize)
            
            if totalTime > samplePeriod.samplePeriod {
              
              mode = .setupNextRun
              
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
              
              if currentStep == txtStopStep.integerValue + 1 {
                currentStep = txtStartStep.integerValue
                if cboLocomotiveDirection.indexOfSelectedItem == 2 && locomotiveDirection == .forward {
                  locomotiveDirection = .reverse
                }
                else {
                  btnStartProfilerAction(btnStartProfiler)
                  return
                }
              }

              locomotive!.targetSpeed = (speed: currentStep, direction:locomotiveDirection)
              
              triggerCount = 0
              
              startTime = message.timeStamp
              
              mode = .gettingUptoSpeed

            }
            
          }
          
          lastBlockIndex = newIndex
          
        }
                
      }
*/
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
    
//    if let layout = myTrainsController.layout {
//      let units = UnitLength.selected(comboBox: cboLengthUnits)
  //    lblRouteLength.stringValue = String(format: "%.1f", layout.loopLengths[cboRoute.indexOfSelectedItem] * units.fromCM)
 //   }
    
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
    UserDefaults.standard.set(cboUnits.indexOfSelectedItem, forKey: DEFAULT.SPEED_PROFILER_SPEED_UNITS)
  }
  
  @IBOutlet weak var btnStartProfiler: NSButton!
  
  @IBAction func btnStartProfilerAction(_ sender: NSButton) {
    
    if mode == .idle {
      
      if observerId != -1 {
   //     interface?.removeObserver(id: observerId)
        observerId = -1
      }
      /*
      if let locomotive = self.locomotive, let layout = myTrainsController.layout, cboRoute.indexOfSelectedItem != -1 {
        
        btnStartProfiler.title = "Stop Profiler"
        route = layout.loops[cboRoute.indexOfSelectedItem]
        lastBlockIndex = -1
        locomotive.isInUse = true
        locomotive.isInertial = false
        resultsView.locomotive = locomotive
        
        locomotiveDirection = cboLocomotiveDirection.indexOfSelectedItem == 1 ? .reverse : .forward
        
        startDirection = locomotiveDirection

        tableView.reloadData()
        
        locomotive.targetSpeed = (speed: 20, direction:locomotiveDirection)
        
        
        if let interface = locomotive.network?.interface as? InterfaceLocoNet {
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
        
        blocksToIgnore.removeAll()
        
        currentStep = txtStartStep.integerValue

        mode = .gettingUptoSpeed
        
        locomotive.targetSpeed = (speed: UInt8(currentStep), direction:locomotiveDirection)
        
 //       locomotive.forceRefresh = true
        
      } */
    }
    else {
      btnStartProfiler.title = "Start Profiler"
      mode = .idle
      /*
      if let locomotive = self.locomotive {
        locomotive.targetSpeed = (speed: 0, direction:.forward)
        locomotive.isInUse = false
      }
       */
    }
    
  }
  
  @IBOutlet weak var btnSave: NSButton!
  
  @IBAction func btnSaveAction(_ sender: NSButton) {
//    locomotive?.save()
//    self.view.window?.close()
  }
  
  @IBOutlet weak var scrollView: NSScrollView!
  
  @IBOutlet weak var btnSetRoute: NSButton!
  
  @IBAction func btnSetRouteAction(_ sender: NSButton) {
    
//    if let layout = myTrainsController.layout, cboRoute.indexOfSelectedItem != -1 {
//      layout.setRoute(route: layout.loops[cboRoute.indexOfSelectedItem])
//    }
    
  }
  
  @IBOutlet weak var resultsView: SpeedResultsView!
  
  @IBOutlet weak var cboBestFitMethod: NSComboBox!
  
  @IBAction func cboBestFitMethodAction(_ sender: NSComboBox) {
    /*
    locomotive?.newBestFitMethod = BestFitMethod.selected(comboBox: sender)
    locomotive?.doBestFit()
    tableView.reloadData()
    resultsView.needsDisplay = true
     */
  }
  
  @IBOutlet weak var cboResultsType: NSComboBox!
  
  @IBAction func cboResultsType(_ sender: NSComboBox) {
    tableViewDS.resultsType = SpeedProfileResultsType.selected(comboBox: cboResultsType)
    tableView.reloadData()
    UserDefaults.standard.set(cboResultsType.indexOfSelectedItem, forKey: DEFAULT.SPEED_PROFILER_RESULTS_TYPE)
  }
  
  @IBOutlet weak var lblRouteLength: NSTextField!
  
  @IBOutlet weak var cboLengthUnits: NSComboBox!
  
  @IBAction func cboLengthUnitsAction(_ sender: NSComboBox) {
    cboRouteAction(cboRoute)
    UserDefaults.standard.set(cboLengthUnits.indexOfSelectedItem, forKey: DEFAULT.SPEED_PROFILER_LENGTH_UNITS)
  }
  
  @IBOutlet weak var cboLocomotiveDirection: NSComboBox!
  
  @IBAction func cboLocomotiveDirectionAction(_ sender: NSComboBox) {
    resultsView.dataSet = sender.indexOfSelectedItem
  }
  
  @IBOutlet weak var txtStartStep: NSTextField!
  
  @IBAction func txtStartStepAction(_ sender: NSTextField) {
    UserDefaults.standard.set(txtStartStep.integerValue, forKey: DEFAULT.SPEED_PROFILER_START_STEP)
  }
  
  @IBOutlet weak var chkShowTrendline: NSButton!
  
  @IBAction func chkShowTrendlineAction(_ sender: NSButton) {
    resultsView.showTrendline = sender.state == .on
    UserDefaults.standard.set(chkShowTrendline.state.rawValue, forKey: DEFAULT.SPEED_PROFILER_TRENDLINE)
  }
  
  @IBAction func btnResetResultsAction(_ sender: NSButton) {
    /*
    for profile in tableViewDS.speedProfile! {
      if cboLocomotiveDirection.indexOfSelectedItem == 0 || cboLocomotiveDirection.indexOfSelectedItem == 2 {
        profile.newSpeedForward = 0.0
      }
      if cboLocomotiveDirection.indexOfSelectedItem == 1 || cboLocomotiveDirection.indexOfSelectedItem == 2 {
        profile.newSpeedReverse = 0.0
      }
    }
     */
    tableView.reloadData()
    resultsView.needsDisplay = true
  }
  
  @IBAction func btnDiscardResultsAction(_ sender: NSButton) {
    /*
    for profile in tableViewDS.speedProfile! {
      profile.newSpeedForward = profile.speedForward
      profile.newSpeedReverse = profile.speedReverse
    }
     */
//    self.view.window?.close()
  }
  
  @IBOutlet weak var cboSampleSize: NSComboBox!
  
  @IBAction func cboSampleSizeAction(_ sender: NSComboBox) {
    UserDefaults.standard.set(cboSampleSize.indexOfSelectedItem, forKey: DEFAULT.SPEED_PROFILER_SAMPLE_SIZE)
  }
  
  @IBOutlet weak var txtStopStep: NSTextField!
  
  @IBAction func txtStopStepAction(_ sender: NSTextField) {
    UserDefaults.standard.set(txtStopStep.integerValue, forKey: DEFAULT.SPEED_PROFILER_STOP_STEP)
  }
  
}

