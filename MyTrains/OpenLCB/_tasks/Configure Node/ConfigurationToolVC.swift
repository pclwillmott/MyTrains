//
//  ConfigurationToolVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 23/12/2023.
//

import Foundation
import AppKit

private enum State {
  case idle
  case gettingCDI
  case readingMemory
  case refreshElement
  case writingMemory
}

private typealias MemoryMapItem = (sortAddress:UInt64, space:UInt8, address: Int, size: Int, data: [UInt8], modified: Bool)

class ConfigurationToolVC: NSViewController, NSWindowDelegate, OpenLCBConfigurationToolDelegate, XMLParserDelegate {
  
  // MARK: Window & View Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }
  
  func windowWillClose(_ notification: Notification) {
    
    guard let networkLayer, let configurationTool else {
      return
    }
    
    configurationTool.delegate = nil
    networkLayer.releaseConfigurationTool(configurationTool: configurationTool)

  }
  
  override func viewWillAppear() {
    
    self.view.window?.delegate = self

    containerView.translatesAutoresizingMaskIntoConstraints = false
    btnWriteAll.translatesAutoresizingMaskIntoConstraints = false
    btnRefreshAll.translatesAutoresizingMaskIntoConstraints = false
    btnResetToDefaults.translatesAutoresizingMaskIntoConstraints = false
    btnReboot.translatesAutoresizingMaskIntoConstraints = false
    lblStatus.translatesAutoresizingMaskIntoConstraints = false
    barProgress.translatesAutoresizingMaskIntoConstraints = false
    stackView.translatesAutoresizingMaskIntoConstraints = false
    buttonView.translatesAutoresizingMaskIntoConstraints = false
    progressView.translatesAutoresizingMaskIntoConstraints = false
    statusView.translatesAutoresizingMaskIntoConstraints = false
    
    self.view.addSubview(stackView)
 
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: gap),
      stackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: gap),
      stackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -gap),
      self.view.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: gap),
    ])

    stackView.orientation = .vertical
    stackView.alignment = .leading
    
    stackView.addArrangedSubview(containerView)
    stackView.addArrangedSubview(statusView)
    stackView.addArrangedSubview(progressView)
    stackView.addArrangedSubview(buttonView)

    NSLayoutConstraint.activate([
      containerView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
      statusView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
      statusView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
      progressView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
      progressView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
      buttonView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
      buttonView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
      buttonView.heightAnchor.constraint(equalToConstant: 20)
    ])
    
    statusView.addSubview(lblStatus)
    lblStatus.alignment = .center

    NSLayoutConstraint.activate([
      lblStatus.topAnchor.constraint(equalTo: statusView.topAnchor),
      lblStatus.leadingAnchor.constraint(equalTo: statusView.leadingAnchor),
      lblStatus.trailingAnchor.constraint(equalTo: statusView.trailingAnchor),
    ])
    
    isStatusViewHidden = false

    progressView.addSubview(barProgress)

    NSLayoutConstraint.activate([
      barProgress.topAnchor.constraint(equalTo: progressView.topAnchor),
      barProgress.leadingAnchor.constraint(equalTo: progressView.leadingAnchor, constant: gap),
      barProgress.trailingAnchor.constraint(equalTo: progressView.trailingAnchor, constant: -gap),
    ])
      
    isProgressViewHidden = false

    buttonView.addSubview(btnWriteAll)
    buttonView.addSubview(btnRefreshAll)
    buttonView.addSubview(btnResetToDefaults)
    buttonView.addSubview(btnReboot)

    btnWriteAll.title = "Write All"
    btnRefreshAll.title = "Refresh All"
    btnResetToDefaults.title = "Reset to Defaults"
    btnReboot.title = "Reboot"
      
    NSLayoutConstraint.activate([
      btnRefreshAll.leadingAnchor.constraint(equalTo: buttonView.leadingAnchor, constant: gap),
      btnWriteAll.leadingAnchor.constraint(equalTo: btnRefreshAll.trailingAnchor, constant: gap),
      btnResetToDefaults.trailingAnchor.constraint(equalTo: buttonView.trailingAnchor, constant: -gap),
      btnReboot.trailingAnchor.constraint(equalTo: btnResetToDefaults.leadingAnchor, constant: -gap),
    ])
    
    isButtonViewHidden = false

    networkLayer = configurationTool!.networkLayer
    
    nodeId = configurationTool!.nodeId
    
    let title = node!.userNodeName == "" ? "\(node!.manufacturerName) - \(node!.nodeModelName)" : node!.userNodeName
    
    self.view.window?.title = "Configure \(title) (\(node!.nodeId.toHexDotFormat(numberOfBytes: 6)))"
    
    if let network = networkLayer {

      isStatusViewHidden = false
      
      lblStatus.stringValue = "Getting CDI"
      
      state = .gettingCDI
      
      totalBytesRead = 0
      
      nextCDIStartAddress = 0
      
      CDI = []
      
      network.sendNodeMemoryReadRequest(sourceNodeId: nodeId, destinationNodeId: node!.nodeId, addressSpace: OpenLCBNodeMemoryAddressSpace.cdi.rawValue, startAddress: nextCDIStartAddress, numberOfBytesToRead: 64)

    }

  }
  
  // MARK: Private Properties
  
  private var networkLayer : OpenLCBNetworkLayer?

  private var nodeId : UInt64 = 0
  
  private var CDI : [UInt8] = []
  
  private var state : State = .idle
  
  private var xmlParser : XMLParser?
  
  private var nextCDIStartAddress : Int = 0
  
  private var totalBytesRead = 0
  
  private var timer : Timer?
  
  private var dataToWrite : [(space: UInt8, address:Int, data:[UInt8])] = []
  
  private var memoryMap : [MemoryMapItem] = []
  
  private var currentMemoryBlock : Int = 0
  
  private var editElement : LCCCDIElement?
  
  private var currentElement : LCCCDIElement?
  
  private var currentElementType : OpenLCBCDIElementType = .int
  
  private var groupStack : [LCCCDIElement] = []
  
  private var elementLookup : [Int:LCCCDIElement] = [:]
  
  private var currentSpace : UInt8 = 0
  
  private var currentAddress : Int = 0
  
  private var currentTag : Int = 0
  
  private var dataBytesToRead = 0
  
  private var relationProperty : String?
  
  private var relationValue : String?
  
  private let gap : CGFloat = 5.0
  
  private var progressViewHeightConstraint : NSLayoutConstraint?
  
  private var isProgressViewHidden : Bool {
    get {
      return progressView.isHidden
    }
    set(value) {
      progressViewHeightConstraint?.isActive = false
      progressView.isHidden = value
      progressViewHeightConstraint = progressView.heightAnchor.constraint(equalToConstant: value ? 0.0 : 18.0)
      progressViewHeightConstraint?.isActive = true
    }
  }

  private var statusViewHeightConstraint : NSLayoutConstraint?
  
  private var isStatusViewHidden : Bool {
    get {
      return statusView.isHidden
    }
    set(value) {
      statusViewHeightConstraint?.isActive = false
      statusView.isHidden = value
      statusViewHeightConstraint = statusView.heightAnchor.constraint(equalToConstant: value ? 0.0 : 18.0)
      statusViewHeightConstraint?.isActive = true
    }
  }

  private var buttonViewHeightConstraint : NSLayoutConstraint?
  
  private var isButtonViewHidden : Bool {
    get {
      return buttonView.isHidden
    }
    set(value) {
      buttonViewHeightConstraint?.isActive = false
      buttonView.isHidden = value
      buttonViewHeightConstraint = statusView.heightAnchor.constraint(equalToConstant: value ? 0.0 : 18.0)
      buttonViewHeightConstraint?.isActive = true
    }
  }

  // MARK: Public Properties
  
  public var node: OpenLCBNode?
  
  public var configurationTool : OpenLCBNodeConfigurationTool?
  
  // MARK: Private Methods
 
  private func displayErrorMessage(message: String) {
    
    let alert = NSAlert()

    alert.messageText = "Error"
    alert.informativeText = message
    alert.addButton(withTitle: "OK")
    alert.alertStyle = .critical

    let _ = alert.runModal()

  }

  @objc func timeOutTimer() {
    stopTimer()
    displayErrorMessage(message: "TimeOut: - write failed")
    state = .idle
  }
  
  func startTimer(timeInterval:TimeInterval) {
    timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(timeOutTimer), userInfo: nil, repeats: false)
    RunLoop.current.add(timer!, forMode: .common)
  }
  
  func stopTimer() {
    timer?.invalidate()
    timer = nil
  }
  
  private func xmakeChildren(template:[LCCCDIElement]) -> [LCCCDIElement] {
    
    var result : [LCCCDIElement] = []
    
    for childTemplate in template {
      
      if childTemplate.type == .group {
        currentAddress += childTemplate.offset
        let group = childTemplate.clone()
        group.tag = currentTag
        currentTag += 1
        elementLookup[group.tag] = group
        result.append(group)
        if !group.description.isEmpty {
          group.name = "\(group.name) - \(group.description)"
        }
        if childTemplate.replication == 1 {
          group.childElements = xmakeChildren(template: childTemplate.childElements)
        }
        else {
          for replicationNumber in 1...childTemplate.replication {
            let child = childTemplate.clone()
            child.tag = currentTag
            currentTag += 1
            elementLookup[child.tag] = child
            group.childElements.append(child)
            if !child.repname.isEmpty {
              child.name = "\(child.repname) \(replicationNumber)"
              // TODO: Add f0 case
            }
            child.childElements = xmakeChildren(template: childTemplate.childElements)
          }
        }
      }
      else {
        let child = childTemplate.clone()
        child.tag = currentTag
        currentTag += 1
        elementLookup[child.tag] = child
        result.append(child)
        if child.type == .segment {
          currentSpace = child.space
          currentAddress = child.origin
        }
        else {
          currentAddress += child.offset
        }
        if child.type.isData {
          child.space = currentSpace
          child.address = currentAddress
          currentAddress += child.size
          let memoryMapItem : MemoryMapItem = (sortAddress: child.sortAddress, space: child.space, address: child.address, size: child.size, data: [], modified: false)
          memoryMap.append(memoryMapItem)
        }
        child.childElements = xmakeChildren(template: childTemplate.childElements)
      }
      
    }
    
    return result
    
  }
  
  private func makeInterface(container:CDIView?, element:LCCCDIElement) {
    
    element.tag = currentTag
    currentTag += 1
    elementLookup[element.tag] = element
    
    print(element.type)
    
    var nextContainer = container
    let stackView = container as? CDIStackViewManagerDelegate
    
    if element.map.count > 0 {
      let map = CDIMapView()
      stackView?.addArrangedSubview?(map)
      map.name = element.name
      map.elementSize = element.size
      map.map = LCCCDIMap(field: element)
    }
    else {
      switch element.type {
      case .cdi:
        for childElement in element.childElements {
          makeInterface(container: nextContainer, element: childElement)
        }
      case .int:
        let uInt = CDIUIntView()
        stackView?.addArrangedSubview?(uInt)
        uInt.name = element.name
        uInt.elementSize = element.size
        uInt.maxValue = element.max
        uInt.minValue = element.min
        uInt.unsignedIntegerValue = 0
      case .eventid:
        let eventId = CDIEventIdView()
        stackView?.addArrangedSubview?(eventId)
        eventId.name = element.name
        eventId.elementSize = element.size
        eventId.eventIdValue = 0
      case .string:
        let string = CDIStringView()
        stackView?.addArrangedSubview?(string)
        string.name = element.name
        string.elementSize = element.size
        string.stringValue = ""
      case .identification:
        let identification = CDISegmentView()
        containerView.addArrangedSubview(identification)
        identification.name = "Identification"
        nextContainer = identification
        for childElement in element.childElements {
          makeInterface(container: nextContainer, element: childElement)
        }
      case .hardwareVersion:
        let item = CDIIdentificationItemView()
        stackView?.addArrangedSubview?(item)
        item.name = "Hardware Version:"
        item.value = ""
      case .softwareVersion:
        let item = CDIIdentificationItemView()
        stackView?.addArrangedSubview?(item)
        item.name = "Software Version:"
        item.value = ""
      case .manufacturer:
        let item = CDIIdentificationItemView()
        stackView?.addArrangedSubview?(item)
        item.name = "Manufacturer:"
        item.value = ""
      case .model:
        let item = CDIIdentificationItemView()
        stackView?.addArrangedSubview?(item)
        item.name = "Model:"
        item.value = ""
      case .acdi:
        let item = CDISegmentView()
        containerView.addArrangedSubview(item)
        item.name = "ACDI"
      case .segment:
        let segment = CDISegmentView()
        containerView.addArrangedSubview(segment)
        segment.name = element.name
        nextContainer = segment
        for childElement in element.childElements {
          makeInterface(container: nextContainer, element: childElement)
        }
      case .group:
        
        if element.replication == 1 {
          let group = CDIGroupView()
          stackView?.addArrangedSubview?(group)
          group.name = element.name
          if !element.description.isEmpty {
            group.addDescription(description: element.description)
          }
          nextContainer = group
          for childElement in element.childElements {
            makeInterface(container: nextContainer, element: childElement)
          }
        }
        else {
          let group = CDIGroupTabView()
          stackView?.addArrangedSubview?(group)
          group.name = element.name
          group.addDescription(description: element.description)
          group.replicationName = element.repname
          group.numberOfTabViewItems = element.replication
          for index in 0 ... element.replication - 1 {
            for childElement in element.childElements {
              makeInterface(container: group.tabViewItems[index], element: childElement)
            }
          }
        }
        
      default:
        break
      }
      
      
    }
    
  }
  
  private func expandTree() {
  
    elementLookup.removeAll()
    
    currentSpace = 0
    currentAddress = 0
    currentTag = 0
    
    memoryMap.removeAll()
    
    guard let currentElement else {
      return
    }
    
    makeInterface(container: nil, element: currentElement)

  }
  
  private func xexpandTree() {
    
    elementLookup.removeAll()
    currentSpace = 0
    currentAddress = 0
    currentTag = 0
    memoryMap.removeAll()
    if let element = currentElement {
      element.tag = currentTag
      currentTag += 1
      elementLookup[element.tag] = element
      element.childElements = xmakeChildren(template: element.childElements)
    }
    
//    outlineViewDS = LCCCDITreeViewDS(root: currentElement!)
//    outlineView.dataSource = outlineViewDS
//    outlineView.delegate = outlineViewDS
        
    memoryMap.sort {$0.sortAddress < $1.sortAddress}

    /*
    for map in memoryMap {
      print("expandTree: \(map.address) \(map.space) \(map.size)")
    }
    */
    
    // Combine adjacent blocks
    
    var index = 0
    while index < memoryMap.count - 1 {
      if memoryMap[index + 1].sortAddress == memoryMap[index].sortAddress + UInt64(memoryMap[index].size) {
        memoryMap[index].size += memoryMap[index + 1].size
        memoryMap.remove(at: index + 1)
      }
      else {
        index += 1
      }
    }
    /*
    print()
    for map in memoryMap {
      print("expandTree: \(map.address) \(map.space) \(map.size)")
    }
*/

    dataBytesToRead = 0
    for map in memoryMap {
      dataBytesToRead += map.size
    }
    
    barProgress.minValue = 0.0
    barProgress.maxValue = Double(dataBytesToRead)
    barProgress.doubleValue = 0.0
    barProgress.isHidden = false

    totalBytesRead = 0
    
    lblStatus.stringValue = "Reading Variables - \(totalBytesRead) bytes"

    if let node, let networkLayer {

      state = .readingMemory

      currentMemoryBlock = 0
      
      nextCDIStartAddress = memoryMap[currentMemoryBlock].address
      
      let bytesToRead = UInt8(min(64, memoryMap[currentMemoryBlock].size))
      
      networkLayer.sendNodeMemoryReadRequest(sourceNodeId: nodeId, destinationNodeId: node.nodeId, addressSpace: memoryMap[currentMemoryBlock].space, startAddress: nextCDIStartAddress, numberOfBytesToRead: bytesToRead)
      
    }
    
  }

  private func getMemoryBlockIndex(sortAddress: UInt64) -> Int? {
    
    var L = 0
    
    var R = memoryMap.count - 1
    
    while L <= R {
      let m = Int(floor(Double(L + R) / 2.0))
      if memoryMap[m].sortAddress + UInt64(memoryMap[m].size) - 1 < sortAddress {
        L = m + 1
      }
      else if memoryMap[m].sortAddress > sortAddress {
        R = m - 1
      }
      else {
        return m
      }
    }
    
    return nil
    
  }
  
  private func getMemoryBlock(sortAddress: UInt64, size:Int) -> [UInt8]? {
    
    if let index = getMemoryBlockIndex(sortAddress: sortAddress) {
      
      var result : [UInt8] = []
      
      var offset = Int(sortAddress - memoryMap[index].sortAddress)
      
      for _ in 1 ... size {
        result.append(memoryMap[index].data[offset])
        offset += 1
      }
      
      return result
      
    }
    
    return nil
    
  }
  /*
  private func displayEditElement(element:LCCCDIElement) {
    
    editElement = nil
    
    if !element.type.isData {
      return
    }

    if let data = getMemoryBlock(sortAddress: element.sortAddress, size: element.size) {
      
      editElement = element
      
      boxBox.title = element.name
      
      lblDescription.stringValue = element.description

      var property : String = ""
      
      txtValue.stringValue = ""
      
      switch element.type {
      case .eventid:
        var eventId : UInt64 = 0
        for byte in data {
          eventId <<= 8
          eventId |= UInt64(byte)
        }
        txtValue.stringValue = eventId.toHexDotFormat(numberOfBytes: 8)
      case .float:
        var floatValue : UInt64 = 0
        for byte in data {
          floatValue <<= 8
          floatValue |= UInt64(byte)
        }
        var floatFormat = "%f"
        if let format = element.floatFormat {
          floatFormat = format
        }
        switch element.size {
        case 2:
          let word = UInt16(floatValue & 0xffff)
          let float16 : float16_t = float16_t(v: word)
          let float32 = Float(float16: float16)
          txtValue.stringValue = String(format: floatFormat, float32)
        case 4:
          let dword = UInt32(floatValue & 0xffffffff)
          let float32 = Float32(bitPattern: dword)
          txtValue.stringValue = String(format: floatFormat, float32)
        case 8:
          let float64 = Float64(bitPattern: floatValue)
          txtValue.stringValue = String(format: floatFormat, float64)
        default:
          print("displayEditElement: bad float size: \(element.size)")
        }
      case .int:
        var intValue : UInt64 = 0
        for byte in data {
          intValue <<= 8
          intValue |= UInt64(byte)
        }
        switch element.size {
        case 1:
          let byte = UInt8(intValue & 0xff)
          txtValue.stringValue = "\(byte)"
        case 2:
          let word = UInt16(intValue & 0xffff)
          txtValue.stringValue = "\(word)"
        case 4:
          let dword = UInt32(intValue & 0xffffffff)
          txtValue.stringValue = "\(dword)"
        case 8:
          txtValue.stringValue = "\(intValue)"
        default:
          print("displayEditElement: bad integer size: \(element.size)")
        }
      case .string:
        txtValue.stringValue = String(cString: data)
        break
      default:
        print("displayEditElement: unexpected element type: \(element.type)")
      }

      property = txtValue.stringValue

      cboCombo.removeAllItems()
      
      if element.map.count > 0 {
        
        let map = LCCCDIMap(field: element)
        
        map.populate(comboBox: cboCombo)
        
        map.selectItem(comboBox: cboCombo, property: property)
        
      }
      
      cboCombo.isHidden = cboCombo.numberOfItems == 0
      
      txtValue.frame.origin.y = safeTextTop

      if cboCombo.isHidden {
        txtValue.frame.origin.y = cboCombo.frame.origin.y
      }

      txtValue.isHidden = cboCombo.numberOfItems > 0

      lblDescription.isHidden = lblDescription.stringValue.isEmpty
      
      btnRefresh.isEnabled = true
      btnWrite.isEnabled = true

    }

  }
*/
  // MARK: OpenLCBConfigurationToolDelegate Methods
  
  func openLCBMessageReceived(message: OpenLCBMessage) {
    
    guard message.destinationNodeId == nodeId && message.sourceNodeId == node!.nodeId else {
      return
    }
    
    if let network = networkLayer {
      
      switch message.messageTypeIndicator {
       
      case .datagramRejected:
        break
      case .datagramReceivedOK:
        
        if let node = self.node {
          
          if state == .writingMemory {
            
            if !message.payload.isEmpty {
              
              let flags = message.payload[0]
              
              let exponent = flags & 0x0f
              
              if exponent > 0 {
                
                let delay : TimeInterval = pow(2.0, Double(exponent))
                
                startTimer(timeInterval: delay)
                
              }
              
            }
            else {
              
              dataToWrite.removeFirst()
              
              if !dataToWrite.isEmpty {
                network.sendNodeMemoryWriteRequest(sourceNodeId: nodeId, destinationNodeId: node.nodeId, addressSpace: dataToWrite[0].space, startAddress: dataToWrite[0].address, dataToWrite: dataToWrite[0].data)
              }
              else {
                state = .idle
                stopTimer()
              }
              
            }
            
          }
          
        }
        
      case .datagram:
        
        if let node = self.node {
          
          network.sendDatagramReceivedOK(sourceNodeId: nodeId, destinationNodeId: node.nodeId, timeOut: .ok)
          
          var data = message.payload
          
          if let datagramType = message.datagramType {
            
            switch datagramType {
              
            case .writeReplyGeneric, .writeReply0xFD, .writeReply0xFE, .writeReply0xFF:
              
              if state == .writingMemory {
                
                dataToWrite.removeFirst()
                
                if !dataToWrite.isEmpty {
                  network.sendNodeMemoryWriteRequest(sourceNodeId: nodeId, destinationNodeId: node.nodeId, addressSpace: dataToWrite[0].space, startAddress: dataToWrite[0].address, dataToWrite: dataToWrite[0].data)
                }
                else {
                  stopTimer()
                  state = .idle
                }

              }
              
            case .writeReplyFailureGeneric, .writeReplyFailure0xFD, .writeReplyFailure0xFE, .writeReplyFailure0xFF:

              stopTimer()
              
              state = .idle

              displayErrorMessage(message: "Write failed")
            
            case .readReplyGeneric, .readReply0xFD, .readReply0xFE:
              
              if state == .readingMemory || state == .refreshElement {
                
                let startAddress =
                (UInt32(data[2]) << 24) |
                (UInt32(data[3]) << 16) |
                (UInt32(data[4]) << 8) |
                (UInt32(data[5]))
                
                var thisSpace : UInt8
                var prefixToRemove : Int = 6
                
                switch data[1] {
                case 0x51:
                  thisSpace = 0xfd
                case 0x52:
                  thisSpace = 0xfe
                default:
                  thisSpace = data[6]
                  prefixToRemove += 1
                }
              
                if thisSpace == memoryMap[currentMemoryBlock].space && startAddress == nextCDIStartAddress {
                  
                  data.removeFirst(prefixToRemove)
                  
                  totalBytesRead += data.count
                  
                  lblStatus.stringValue = "Reading Variables - \(totalBytesRead) bytes"
                  
                  barProgress.doubleValue = Double(totalBytesRead)

                  memoryMap[currentMemoryBlock].data.append(contentsOf: data)
                  
                  let bytesToRead = UInt8(min(64, memoryMap[currentMemoryBlock].size - memoryMap[currentMemoryBlock].data.count))
                  
                  if bytesToRead > 0 {
                    
                    nextCDIStartAddress += data.count
                    
                    network.sendNodeMemoryReadRequest(sourceNodeId: nodeId, destinationNodeId: node.nodeId, addressSpace: memoryMap[currentMemoryBlock].space, startAddress: nextCDIStartAddress, numberOfBytesToRead: bytesToRead)

                  }
                  else {
                    
                    currentMemoryBlock += 1
                    
                    if state == .readingMemory && currentMemoryBlock < memoryMap.count {
                      
                      nextCDIStartAddress = memoryMap[currentMemoryBlock].address
                      
                      let bytesToRead = UInt8(min(64, memoryMap[currentMemoryBlock].size))
                      
                      network.sendNodeMemoryReadRequest(sourceNodeId: nodeId, destinationNodeId: node.nodeId, addressSpace: memoryMap[currentMemoryBlock].space, startAddress: nextCDIStartAddress, numberOfBytesToRead: bytesToRead)
                      
                    }
                    else {
                      
                      if state == .refreshElement {
                   //     displayEditElement(element: editElement!)
                      }
                      
                      barProgress.isHidden = true
                      
                      lblStatus.stringValue = ""
                      
                      btnRefreshAll.isHidden = false
                      btnReboot.isHidden = false
                      btnResetToDefaults.isHidden = false

                      state = .idle
                      
                    }
                    
                  }
                }
                else {
                  print("error: bad space or address - 0x\(thisSpace.toHex(numberOfDigits: 2))  0x\(startAddress.toHex(numberOfDigits: 8))")
                  state = .idle
                }
                
              }
              
            case .readReply0xFF:
              
              if state == .gettingCDI {
                
                let startAddress =
                (UInt32(data[2]) << 24) |
                (UInt32(data[3]) << 16) |
                (UInt32(data[4]) << 8) |
                (UInt32(data[5]))
                
                if startAddress == nextCDIStartAddress {
                  
                  data.removeFirst(6)
                  
                  totalBytesRead += data.count
                  lblStatus.stringValue = "Reading Configuration Description Information - \(totalBytesRead) bytes"

                  var isLast = false
                  
                  for byte in data {
                    if byte == 0 {
                      isLast = true
                      break
                    }
                    CDI.append(byte)
                  }
                  
                  var test = CDI
                  test.append(0x00)
                  let str = String(cString: test)
             //     print(str)
             //     print(CDI)
                  
                  if !isLast {
                    
                    nextCDIStartAddress += data.count
                    
                    network.sendNodeMemoryReadRequest(sourceNodeId: nodeId, destinationNodeId: node.nodeId, addressSpace: OpenLCBNodeMemoryAddressSpace.cdi.rawValue, startAddress: nextCDIStartAddress, numberOfBytesToRead: 64)
                    
                  }
                  else {
                    
                    state = .idle
                    
                    let newData : Data = Data(CDI)
                    
                    xmlParser = XMLParser(data: newData)
                    xmlParser?.delegate = self
                    xmlParser?.parse()

                  }
                  
                }
                
                else {
                  print("error: bad address - \(startAddress.toHex(numberOfDigits: 8))")
                  state = .idle
                }
                
              }

            case .readReplyFailure0xFF:
              
              if state == .gettingCDI {

                state = .idle
                
                let newData : Data = Data(CDI)
                
                xmlParser = XMLParser(data: newData)
                xmlParser?.delegate = self
                xmlParser?.parse()
                
              }
              
            default:
              break
            }
            
          }
          
        }
      
      default:
        break
      }
      
    }
    
  }

  // MARK: XMLParserDelegate Methods
  
  func parserDidStartDocument(_ parser: XMLParser) {
//    print("parserDidStartDocument")
    currentElement = nil
  }

  func parserDidEndDocument(_ parser: XMLParser) {
    expandTree()
  }

  func parser(_ parser: XMLParser, foundNotationDeclarationWithName name: String, publicID: String?, systemID: String?) {
    print("parseFoundNotationDeclarationWithName: \(name)")
  }

  func parser(_ parser: XMLParser, foundUnparsedEntityDeclarationWithName name: String, publicID: String?, systemID: String?, notationName: String?) {
    print("parseFoundUnparsedEntityDeclarationWithName: \(name)")
  }

  func parser(_ parser: XMLParser, foundAttributeDeclarationWithName attributeName: String, forElement elementName: String, type: String?, defaultValue: String?) {
    print("parseFoundAttributeDeclarationWithName: \(attributeName)")
  }

  func parser(_ parser: XMLParser, foundElementDeclarationWithName elementName: String, model: String) {
    print("parseFoundElementDeclarationWithName: \(elementName)")
  }

  func parser(_ parser: XMLParser, foundInternalEntityDeclarationWithName name: String, value: String?) {
    print("parseFoundInternalEntityDeclarationWithName: \(name)")
  }

  
  func parser(_ parser: XMLParser, foundExternalEntityDeclarationWithName name: String, publicID: String?, systemID: String?) {
    print("parseFoundExternalEntityDeclarationWithName: \(name)")
  }

  
  func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {

    if let elementType = OpenLCBCDIElementType(rawValue: elementName) {
      
      currentElementType = elementType
      
      if elementType.isNode {
        
        let element = LCCCDIElement(type: elementType)
        
        if let currentElement = self.currentElement {
          currentElement.childElements.append(element)
          groupStack.append(currentElement)
        }
        
        if let space = attributeDict["space"] {
          element.space = UInt8(space) ?? 0
        }
        if let origin = attributeDict["origin"] {
          element.origin = Int(origin) ?? 0
        }
        if let offset = attributeDict["offset"] {
          element.offset = Int(offset) ?? 0
        }
        if let replication = attributeDict["replication"] {
          element.replication = Int(replication) ?? 1
        }
        if let floatFormat = attributeDict["floatFormat"] {
          element.floatFormat = floatFormat
        }
        if let size = attributeDict["size"] {
          element.size = Int(size) ?? 0
        }
        else if elementType == .eventid {
          element.size = 8
        }

        currentElement = element
        
      }
      
    }
    else {
      print("UNKNOWN ELEMENT TYPE: \"\(elementName)\"")
    }
    
  }

  func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    
    if let elementType = OpenLCBCDIElementType(rawValue: elementName) {
      
      if elementType.isNode {
        if let last = groupStack.last {
          currentElement = last
          groupStack.removeLast()
        }
      }
      else if elementType == .relation {
        if let property = relationProperty, let value = relationValue {
          let relation = LCCCDIMapRelation(property: property, stringValue: value)
          currentElement?.map.append(relation)
        }
        relationProperty = nil
        relationValue = nil
      }
      
    }
    
  }
  
  func parser(_ parser: XMLParser, didStartMappingPrefix prefix: String, toURI namespaceURI: String) {
    print("parseDidStartMappingPrefix: \(prefix)")
  }

  func parser(_ parser: XMLParser, didEndMappingPrefix prefix: String) {
    print("parseDidEndMappingPrefix: \(prefix)")
  }

  func parser(_ parser: XMLParser, foundCharacters string: String) {
    if let element = currentElement {
      switch currentElementType {
      case .name:
        element.name = string
      case .relation:
        relationProperty = nil
        relationValue = nil
      case .property:
        relationProperty = string
      case .value:
        relationValue = string
      case .description:
        element.description = string
      case .repname:
        element.repname = string
      case .min:
        element.min = string
      case .max:
        element.max = string
      case .defaultValue:
        element.defaultValue = string
      case .manufacturer, .model, .softwareVersion, .hardwareVersion:
        element.stringValue = string
      default:
        break
      }
    }
    currentElementType = .none
  }

  func parser(_ parser: XMLParser, foundIgnorableWhitespace whitespaceString: String) {
    print("foundIgnorableWhiteSpace: \(whitespaceString)")
  }

  func parser(_ parser: XMLParser, foundProcessingInstructionWithTarget target: String, data: String?) {
    print("parseFoundProcessingInstructionWithTarget: \(target)")
  }

  func parser(_ parser: XMLParser, foundComment comment: String) {
    print("parseFoundComment: \(comment)")
  }

  func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
    print("parseFoundCDATA")
  }

  func parser(_ parser: XMLParser, resolveExternalEntityName name: String, systemID: String?) -> Data? {
    return nil
  }

  func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
    print("parseErrorOccurred: \(parseError)")
  }

  func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
    print("validationErrorOccurred: \(validationError)")
  }
  
  // MARK: Controls
  
  private var btnRefreshAll = NSButton()
  
  private var btnWriteAll = NSButton()
  
  private var btnResetToDefaults = NSButton()
  
  private var btnReboot = NSButton()
  
  private var barProgress = NSProgressIndicator()
  
  private var lblStatus = NSTextField(labelWithString: "Status")
  
  private var containerView = ScrollVerticalStackView()
  
  private var stackView = NSStackView()
  
  private var statusView = NSView()
  
  private var progressView = NSView()
    
  private var buttonView = NSView()
  
  // MARK: Actions
  
}
