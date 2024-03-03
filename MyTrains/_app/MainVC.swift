//
//  ViewController.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/10/2021. 
//

import Cocoa

class MainVC: NSViewController, MyTrainsControllerDelegate, LayoutDelegate, OpenLCBClockDelegate {

  override func viewWillAppear() {

    super.viewWillAppear()
    
    if appMode == .delegate {
      appMode = .master
    }
    
    scrollView.isHidden = true
    clockView.isHidden = true
    boxStatus.isHidden = true
    
    barProgress.translatesAutoresizingMaskIntoConstraints = false
    barProgress.isIndeterminate = true
    barProgress.usesThreadedAnimation = true
    barProgress.style = .spinning
    barProgress.startAnimation(self)

    view.addSubview(barProgress)
    
    NSLayoutConstraint.activate([
      barProgress.heightAnchor.constraint(equalToConstant: 30),
      barProgress.widthAnchor.constraint(equalToConstant: 30),
      barProgress.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      barProgress.centerYAnchor.constraint(equalTo: view.centerYAnchor),
    ])

    timeoutTimer = Timer.scheduledTimer(timeInterval: 0.0, target: self, selector: #selector(timeoutTimerAction), userInfo: nil, repeats: false)

    RunLoop.current.add(timeoutTimer!, forMode: .common)

  }
  
  override func viewWillDisappear() {
    super.viewWillDisappear()
//    myTrainsController.layout?.removeDelegate(delegateId: layoutDelegateId)
//    appDelegate.networkLayer!.fastClock!.removeObserver(observerId: fastClockObserverId)
//    myTrainsController.removeDelegate(id: controllerDelegateId)
  }

  private func resetToClean() {
    appNodeId = nil
    appMode = .initializing
    databasePath = nil
    eulaAccepted = false
  }
    
  // MARK: Private Properties
  
  private var cboLayoutDS : ComboBoxDBDS? = nil
  
  private var controllerDelegateId : Int = -1
  
  private var fastClockObserverId : Int = -1
  
  private var layoutDelegateId : Int = -1
  
  private var timeoutTimer : Timer?
  
  // MARK: Private Methods
    
  @objc func timeoutTimerAction() {


//    if let fastClock = appDelegate.networkLayer!.fastClock {
//      fastClockObserverId = fastClock.addObserver(observer: self)
//    }
    
//    switchBoardView.layout = myTrainsController.layout
    
    scrollView.documentView?.frame = NSMakeRect(0.0, 0.0, 2000.0, 2000.0)
    scrollView.allowsMagnification = true
    scrollView.magnification = mainSwitchboardMagnification

//    if let layout = myTrainsController.layout {
//      layoutDelegateId = layout.addDelegate(delegate: self)
//    }
    
    scrollView.isHidden = false
    clockView.isHidden = false
    boxStatus.isHidden = false
    barProgress.stopAnimation(self)
    barProgress.isHidden = true

  }
  
  // MARK: OpenLCBClockDelegate Methods
  
  func clockTick(clock: OpenLCBClock) {
    clockView.subState = clock.subState
    clockView.date = clock.date
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .full
    dateFormatter.timeStyle = .none
    lblFastClock.stringValue = dateFormatter.string(from: clock.date)
  }
  
  // MARK: LayoutDelegate Methods
  
  func needsDisplay() {
    switchBoardView.needsDisplay = true
  }
  
  // MARK: MyTrainsController Delegate Methods
  
  func switchBoardUpdated() {
    switchBoardView.needsDisplay = true
  }
  
  func myTrainsControllerUpdated(myTrainsController: MyTrainsController) {
    
    cboLayout.deselectItem(at: cboLayout.indexOfSelectedItem)
    
    cboLayoutDS = ComboBoxDBDS(tableName: TABLE.LAYOUT, codeColumn: LAYOUT.LAYOUT_ID, displayColumn: LAYOUT.LAYOUT_NAME, sortColumn: LAYOUT.LAYOUT_NAME)
    
    cboLayout.dataSource = cboLayoutDS
    
    if let index = cboLayoutDS!.indexOfItemWithCodeValue(code: myTrainsController.layoutId) {
      cboLayout.selectItem(at: index)
    }
    
  }
  
  // MARK: Outlets & Actions
  
  @IBOutlet weak var cboLayout: NSComboBox!
  
  @IBAction func cboLayoutAction(_ sender: NSComboBox) {
 //   myTrainsController.layoutId = cboLayoutDS!.codeForItemAt(index: cboLayout.indexOfSelectedItem) ?? -1
  }
  
  @IBOutlet weak var boxStatus: NSBox!
  
  @IBOutlet weak var scrollView: NSScrollView!
  
  @IBOutlet weak var switchBoardView: SwitchBoardOperationsView!
  
  @IBAction func btnZoomIn(_ sender: NSButton) {
    mainSwitchboardMagnification += 0.25
    scrollView.magnification = mainSwitchboardMagnification
  }
  
  @IBAction func btnZoomOut(_ sender: NSButton) {
    mainSwitchboardMagnification -= 0.25
    scrollView.magnification = mainSwitchboardMagnification
  }
  
  @IBAction func btnZoomToFit(_ sender: NSButton) {
    
    scrollView.magnification = 1.0

    let sWidth = scrollView.frame.width
    let sHeight = scrollView.frame.height
    let gWidth = switchBoardView.bounds.width
    let gHeight = switchBoardView.bounds.height

    var scale = 1.0

    if gWidth > gHeight {
      scale = sWidth / gWidth
    }
    else {
      scale = sHeight / gHeight
    }
    
    mainSwitchboardMagnification = scale
    scrollView.magnification = mainSwitchboardMagnification

  }
  
  @IBOutlet weak var lblFastClock: NSTextField!
  
  @IBOutlet weak var clockView: ClockView!
  
  // MARK: Controls
  
  let topView = NSView()
  
  let cboLayout2 = NSComboBox()
  
  let btnZoomIn2 = NSButton(image: NSImage(systemSymbolName: "pencil", accessibilityDescription: nil)!, target: nil, action: nil)
  
  let barProgress = NSProgressIndicator()
  
  // MARK: Temp Stuff
  
  @IBAction func btnConvertAction(_ sender: NSButton) {
    
    appDelegate.closeAllWindows()
    
    return
    /*
    if let layout = myTrainsController.layout, let networkLayer = appDelegate.networkLayer {
      
      for (_, node) in networkLayer.virtualNodeLookup {
        if node.isSwitchboardNode {
          networkLayer.deleteNode(nodeId: node.nodeId)
        }
      }

      for panel in layout.switchBoardPanels {
        panels.append(panel)
        networkLayer.createVirtualNode(virtualNodeType: .switchboardPanelNode, completion: newNodeCompletion(node:))
      }

      for (_, item) in layout.switchBoardItems {
        items.append(item)
        networkLayer.createVirtualNode(virtualNodeType: .switchboardItemNode, completion: newNodeCompletion(node:))
      }
 
    }
     */
  }
  
  var panels : [SwitchBoardPanel] = []
  
  var panelLookup : [Int:SwitchboardPanelNode] = [:]
  
  var items : [SwitchBoardItem] = []

  var nodes : [(node:SwitchboardItemNode, groupId:Int)] = []
  
  var groupLookup : [Int:SwitchboardItemNode] = [:]
  
  func newNodeCompletion(node:OpenLCBNodeVirtual) {
    
    node.hostAppNodeId = node.virtualNodeType == .applicationNode ? node.nodeId : appNodeId!
    
    switch node.virtualNodeType {
    case .layoutNode:
      node.layoutNodeId = node.nodeId
      node.saveMemorySpaces()
    case .switchboardPanelNode:
      if !panels.isEmpty, let panelNode = node as? SwitchboardPanelNode {
        let panel = panels.removeFirst()
        panelNode.layoutNodeId = appLayoutId!
        panelNode.userNodeName = panel.panelName
        panelNode.numberOfRows = UInt16(panel.numberOfRows)
        panelNode.numberOfColumns = UInt16(panel.numberOfColumns)
        panelNode.saveMemorySpaces()
        panelLookup[panel.panelId] = panelNode
        print("\(panelNode.nodeId.toHexDotFormat(numberOfBytes: 6)) - \"\(panelNode.userNodeName)\"")
      }
    case .switchboardItemNode:
      if !items.isEmpty, let itemNode = node as? SwitchboardItemNode {
        let item = items.removeFirst()
        itemNode.layoutNodeId = appLayoutId!
        itemNode.userNodeName = item.displayString().isEmpty ? "\(item.itemPartType.title)" : "\(item.itemPartType.title) - \(item.displayString())"
        itemNode.itemType = item.itemPartType
        itemNode.setDimension(routeNumber: 1, value: item.dimensionA)
        itemNode.setDimension(routeNumber: 2, value: item.dimensionB)
        itemNode.setDimension(routeNumber: 3, value: item.dimensionC)
        itemNode.setDimension(routeNumber: 4, value: item.dimensionD)
        itemNode.setDimension(routeNumber: 5, value: item.dimensionE)
        itemNode.setDimension(routeNumber: 6, value: item.dimensionF)
        itemNode.setDimension(routeNumber: 7, value: item.dimensionG)
        itemNode.setDimension(routeNumber: 8, value: item.dimensionH)
        itemNode.isCriticalSection = item.isCritical
        itemNode.orientation = item.orientation
        itemNode.isReverseShuntAllowed = item.allowShunt
        itemNode.trackElectrificationType = item.trackElectrificationType
        itemNode.directionality = item.blockDirection
        itemNode.xPos = UInt16(item.location.x)
        itemNode.yPos = UInt16(item.location.y)
        itemNode.trackGradient = 0.0
        itemNode.trackGauge = item.trackGauge
        if let panel = panelLookup[item.panelId] {
          itemNode.panelId = panel.nodeId
        }
        if itemNode.itemType.isGroup {
          groupLookup[item.groupId] = itemNode
        }
        itemNode.saveMemorySpaces()
        print("\(itemNode.nodeId.toHexDotFormat(numberOfBytes: 6)) - \"\(itemNode.userNodeName)\"")
        nodes.append((itemNode, item.groupId))
      }
    default:
      break
    }
    
    for (groupId, item) in groupLookup {
      if groupId > 0 {
        for node in nodes {
          if node.groupId == groupId {
            node.node.groupId = item.nodeId
            node.node.saveMemorySpaces()
          }
        }
      }
    }
    
  }
  
}

