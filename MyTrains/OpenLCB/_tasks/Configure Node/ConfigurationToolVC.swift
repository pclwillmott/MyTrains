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
  case decodingCDI
  case refreshMemory
  case writingMemory
  case refreshElement
  case writingElement
}

private typealias MemoryMapItem = (sortAddress:UInt64, space:UInt8, address: Int, size: Int, data: [UInt8], modified: Bool)

class ConfigurationToolVC: NSViewController, NSWindowDelegate, OpenLCBConfigurationToolDelegate, XMLParserDelegate, CDIDataViewDelegate {
  
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
    containerView.scrollView.contentView.translatesAutoresizingMaskIntoConstraints = false
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
      containerView.topAnchor.constraint(equalTo: stackView.topAnchor),
      containerView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
      statusView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
      statusView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
      progressView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
      progressView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
      buttonView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
      buttonView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
    ])
    
    statusView.addSubview(lblStatus)
    lblStatus.alignment = .center

    NSLayoutConstraint.activate([
      lblStatus.topAnchor.constraint(equalTo: statusView.topAnchor),
      lblStatus.leadingAnchor.constraint(equalTo: statusView.leadingAnchor),
      lblStatus.trailingAnchor.constraint(equalTo: statusView.trailingAnchor),
    ])
    
    progressView.addSubview(barProgress)

    NSLayoutConstraint.activate([
      barProgress.topAnchor.constraint(equalTo: progressView.topAnchor),
      barProgress.leadingAnchor.constraint(equalTo: progressView.leadingAnchor, constant: gap),
      barProgress.trailingAnchor.constraint(equalTo: progressView.trailingAnchor, constant: -gap),
    ])
      
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
    
    btnResetToDefaults.target = self
    btnResetToDefaults.action = #selector(self.btnResetToDefaultsAction(_:))

    btnReboot.target = self
    btnReboot.action = #selector(self.btnRebootAction(_:))

    btnRefreshAll.target = self
    btnRefreshAll.action = #selector(self.btnRefreshAllAction(_:))

    btnWriteAll.target = self
    btnWriteAll.action = #selector(self.btnWriteAllAction(_:))

    networkLayer = configurationTool!.networkLayer
    
    nodeId = configurationTool!.nodeId
    
    let title = node!.userNodeName == "" ? "\(node!.manufacturerName) - \(node!.nodeModelName)" : node!.userNodeName
    
    self.view.window?.title = "Configure \(title) (\(node!.nodeId.toHexDotFormat(numberOfBytes: 6)))"
    
    if let network = networkLayer {

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
  
  private var state : State = .idle {
    didSet {
      switch state {
      case .idle:
        isStatusViewHidden = true
        isProgressViewHidden = true
        isButtonViewHidden = false
      case .gettingCDI:
        isStatusViewHidden = false
        isProgressViewHidden = true
        isButtonViewHidden = true
      case .decodingCDI:
        isStatusViewHidden = false
        isProgressViewHidden = false
        isButtonViewHidden = true
      case .refreshMemory:
        isStatusViewHidden = false
        isProgressViewHidden = false
        isButtonViewHidden = true
      case .writingMemory:
        isStatusViewHidden = false
        isProgressViewHidden = false
        isButtonViewHidden = true
      case .refreshElement:
        isStatusViewHidden = false
        isProgressViewHidden = false
        isButtonViewHidden = false
      case .writingElement:
        isStatusViewHidden = false
        isProgressViewHidden = false
        isButtonViewHidden = false
      }
    }
  }
  
  private var xmlParser : XMLParser?
  
  private var nextCDIStartAddress : Int = 0
  
  private var totalBytesRead = 0
  
  private var timer : Timer?
  
  private var dataToWrite : [(space: UInt8, address:Int, data:[UInt8])] = []
  
  private var memoryMap : [MemoryMapItem] = []
  
  private var dataViews : [CDIDataView] = []
  
  private var refreshDataView : CDIDataView?
  
  private var currentMemoryBlock : Int = 0
  
  private var editElement : CDIElement?
  
  private var currentElement : CDIElement?
  
  private var currentElementType : OpenLCBCDIElementType = .int
  
  private var groupStack : [CDIElement] = []
  
  private var currentSpace : UInt8 = 0
  
  private var currentAddress : Int = 0
  
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
      buttonViewHeightConstraint = buttonView.heightAnchor.constraint(equalToConstant: value ? 0.0 : 18.0)
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

  private func makeInterface(stackView:CDIStackViewManagerDelegate, element:CDIElement) {
    
    currentAddress += element.offset

    switch element.type {
      
    case .cdi:
      
      for childElement in element.childElements {
        makeInterface(stackView: stackView, element: childElement)
      }
      
    case .identification, .segment, .group, .acdi:
      
      if element.replication == 1 {
        
        let group = CDIGroupView()
        
        stackView.addArrangedSubview?(group)
        
        switch element.type {
        case .identification:
          group.name = "Identification"
        case .acdi:
          group.name = "ACDI"
        case .segment:
          currentSpace = element.space
          currentAddress = element.origin
          fallthrough
        default:
          group.name = element.name
          break
        }
        
        group.addDescription(description: element.description)
        
        for childElement in element.childElements {
          makeInterface(stackView: group, element: childElement)
        }
        
      }
      else {
        
        let group = CDIGroupTabView()
        
        stackView.addArrangedSubview?(group)
        
        group.name = element.name
        
        group.addDescription(description: element.description)
        
        group.replicationName = element.repname
        
        group.numberOfTabViewItems = element.replication
        
        for index in 0 ... element.replication - 1 {
          for childElement in element.childElements {
            makeInterface(stackView: group.tabViewItems[index], element: childElement)
          }
        }
        
      }

    case .manufacturer, .model, .hardwareVersion, .softwareVersion:
      
      let item = CDIIdentificationItemView()
      
      stackView.addArrangedSubview?(item)
      
      item.name = element.name
      
      item.value = element.stringValue

    default:
      
      let dataView : CDIDataView = element.isMap ? CDIMapView() : CDITextView()
 
      dataViews.append(dataView)

      dataView.elementType = element.type
      dataView.elementSize = element.size
      dataView.name = element.name
      dataView.delegate = self
      dataView.space = currentSpace
      dataView.address = currentAddress
      dataView.minValue = element.min
      dataView.maxValue = element.max
      dataView.defaultValue = element.defaultValue
      dataView.floatFormat = element.floatFormat

      stackView.addArrangedSubview?(dataView)

      dataView.addDescription(description: element.description)
      
      (dataView as? CDIMapView)?.map = CDIMap(field: element)
      
      (dataView as? CDITextView)?.addTextField()

      let memoryMapItem : MemoryMapItem = (sortAddress: dataView.sortAddress, space: dataView.space, address: dataView.address, size: dataView.elementSize!, data: [], modified: false)
      
      memoryMap.append(memoryMapItem)

      currentAddress += element.size
      
    }
    
  }
  
  private func expandTree() {
      
    currentSpace = 0
    currentAddress = 0
    
    memoryMap.removeAll()
    
    dataViews.removeAll()
    
    guard let currentElement else {
      return
    }
    
    makeInterface(stackView: containerView, element: currentElement)

    memoryMap.sort {$0.sortAddress < $1.sortAddress}

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
    
    refreshAll()
    
    barProgress.stopAnimation(self)
    
  }
  
  private func refreshAll() {
    
    dataBytesToRead = 0
    var index = 0
    while index < memoryMap.count {
      dataBytesToRead += memoryMap[index].size
      memoryMap[index].data.removeAll()
      index += 1
    }
    
    barProgress.isIndeterminate = false
    barProgress.minValue = 0.0
    barProgress.maxValue = Double(dataBytesToRead)
    barProgress.doubleValue = 0.0

    totalBytesRead = 0
    
    lblStatus.stringValue = "Reading Variables - \(totalBytesRead) bytes"

    if let node, let networkLayer {

      state = .refreshMemory

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

  private func setMemoryBlock(sortAddress: UInt64, data: [UInt8]) {
    
    if let index = getMemoryBlockIndex(sortAddress: sortAddress) {
      
      var offset = Int(sortAddress - memoryMap[index].sortAddress)
      
      for byte in data {
        memoryMap[index].data[offset] = byte
        offset += 1
      }
      
      memoryMap[index].modified = true
      
    }
    
  }
  
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
          
          if state == .writingElement || state == .writingMemory {
            
            if !message.payload.isEmpty {
              
              let flags = message.payload[0]
              
              let exponent = flags & 0x0f
              
              if exponent > 0 {
                
                let delay : TimeInterval = pow(2.0, Double(exponent))
                
                startTimer(timeInterval: delay)
                
              }
              
            }
            else {
              
              totalBytesRead += dataToWrite[0].data.count
              
              lblStatus.stringValue = "Writing Variables - \(totalBytesRead) bytes"
              barProgress.doubleValue = Double(totalBytesRead)
              
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
              
              if state == .writingElement || state == .writingMemory {
                
                totalBytesRead += dataToWrite[0].data.count
                
                lblStatus.stringValue = "Writing Variables - \(totalBytesRead) bytes"
                barProgress.doubleValue = Double(totalBytesRead)

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
              
              if state == .refreshMemory || state == .refreshElement {
                
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
                    
                    if state == .refreshMemory && currentMemoryBlock < memoryMap.count {
                      
                      nextCDIStartAddress = memoryMap[currentMemoryBlock].address
                      
                      let bytesToRead = UInt8(min(64, memoryMap[currentMemoryBlock].size))
                      
                      network.sendNodeMemoryReadRequest(sourceNodeId: nodeId, destinationNodeId: node.nodeId, addressSpace: memoryMap[currentMemoryBlock].space, startAddress: nextCDIStartAddress, numberOfBytesToRead: bytesToRead)
                      
                    }
                    else {
                      
                      if state == .refreshMemory {
                        for dataView in dataViews {
                          if let data = getMemoryBlock(sortAddress: dataView.sortAddress, size: dataView.elementSize!) {
                            dataView.bigEndianData = data
                          }
                        }
                      }
                      else if state == .refreshElement {
                        if let refreshDataView, let data = getMemoryBlock(sortAddress: refreshDataView.sortAddress, size: refreshDataView.elementSize!) {
                          refreshDataView.bigEndianData = data
                        }
                        refreshDataView = nil
                      }
 
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
                  barProgress.doubleValue += Double(totalBytesRead)
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
             //     let str = String(cString: test)
             //     print(str)
             //     print(CDI)
                  
                  if !isLast {
                    
                    nextCDIStartAddress += data.count
                    
                    network.sendNodeMemoryReadRequest(sourceNodeId: nodeId, destinationNodeId: node.nodeId, addressSpace: OpenLCBNodeMemoryAddressSpace.cdi.rawValue, startAddress: nextCDIStartAddress, numberOfBytesToRead: 64)
                    
                  }
                  else {
                    
                    state = .idle
                    
                    state = .decodingCDI
                    
                    barProgress.isIndeterminate = true
                    barProgress.startAnimation(self)
                    lblStatus.stringValue = "Decoding CDI and building user interface"

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
                
                state = .decodingCDI
                
                barProgress.isIndeterminate = true
                barProgress.startAnimation(self)
                lblStatus.stringValue = "Decoding CDI and building user interface"

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
    state = .decodingCDI
    lblStatus.stringValue = "Decoding CDI and building user interface"
    currentElement = nil
    barProgress.isIndeterminate = true
    barProgress.startAnimation(self)
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

        let element = CDIElement(type: elementType)
        
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
          let relation = CDIMapRelation(property: property, stringValue: value)
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
        element.description.append(string)
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
  
  // MARK: CDIDataViewDelegate Methods
  
  @objc func cdiDataViewReadData(_ dataView:CDIDataView) {
    
    guard let node, let networkLayer else {
      return
    }

    if let index = getMemoryBlockIndex(sortAddress: dataView.sortAddress) {
      
      refreshDataView = dataView
 
      state = .refreshElement
      
      memoryMap[index].data.removeAll()
      
      barProgress.minValue = 0.0
      barProgress.maxValue = Double(memoryMap[index].size)
      barProgress.doubleValue = 0.0
      totalBytesRead = 0
      
      lblStatus.stringValue = "Reading Variables - \(totalBytesRead) bytes"
            
      currentMemoryBlock = index
      
      nextCDIStartAddress = memoryMap[currentMemoryBlock].address
      
      let bytesToRead = UInt8(min(64, memoryMap[currentMemoryBlock].size))
      
      networkLayer.sendNodeMemoryReadRequest(sourceNodeId: nodeId, destinationNodeId: node.nodeId, addressSpace: memoryMap[currentMemoryBlock].space, startAddress: nextCDIStartAddress, numberOfBytesToRead: bytesToRead)

    }
  
  }
  
  @objc func cdiDataViewWriteData(_ dataView:CDIDataView) {
    
    guard let node, let networkLayer else {
      return
    }

    if let index = getMemoryBlockIndex(sortAddress: dataView.sortAddress) {

      var data = dataView.getData
      
      setMemoryBlock(sortAddress: dataView.sortAddress, data: data)
      
      state = .writingElement
      
      dataToWrite.removeAll()
      
      var address = dataView.address
      while !data.isEmpty {
        let numberToWrite = min(64, data.count)
        var block : [UInt8] = []
        for _ in 1...numberToWrite {
          block.append(data.removeFirst())
        }
        dataToWrite.append((space: memoryMap[index].space, address: address, data: block))
        address += block.count
      }
      
      networkLayer.sendNodeMemoryWriteRequest(sourceNodeId: nodeId, destinationNodeId: node.nodeId, addressSpace: dataToWrite[0].space, startAddress: dataToWrite[0].address, dataToWrite: dataToWrite[0].data)

    }

  }
  
  @objc func cdiDataViewSetWriteAllEnabledState(_ isEnabled:Bool) {
    btnWriteAll.isEnabled = isEnabled
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
  
  @IBAction func btnRebootAction(_ sender: NSButton) {
    if let network = networkLayer {
      network.sendRebootCommand(sourceNodeId: nodeId, destinationNodeId: node!.nodeId)
    }
  }
  
  @IBAction func btnResetToDefaultsAction(_ sender: NSButton) {
    
    let alert = NSAlert()

    alert.messageText = "Are you sure that you wish to reset this node to factory defaults?"
    alert.informativeText = ""
    alert.addButton(withTitle: "No")
    alert.addButton(withTitle: "Yes")
    alert.alertStyle = .warning

    if alert.runModal() == NSApplication.ModalResponse.alertSecondButtonReturn {
      if let network = networkLayer {
        network.sendResetToDefaults(sourceNodeId: nodeId, destinationNodeId: node!.nodeId)
      }
    }

  }
  
  @IBAction func btnRefreshAllAction(_ sender: NSButton) {
    refreshAll()
  }

  @IBAction func btnWriteAllAction(_ sender: NSButton) {
    
    guard let node, let networkLayer else {
      return
    }

    for dataView in dataViews {
      setMemoryBlock(sortAddress: dataView.sortAddress, data: dataView.getData)
    }
    
    dataToWrite.removeAll()
    
    var index = 0
    dataBytesToRead = 0
    while index < memoryMap.count {
      var data = memoryMap[index].data
      var address = memoryMap[index].address
      while !data.isEmpty {
        let numberToWrite = min(64, data.count)
        var block : [UInt8] = []
        for _ in 1...numberToWrite {
          block.append(data.removeFirst())
          dataBytesToRead += 1
        }
        dataToWrite.append((space: memoryMap[index].space, address: address, data: block))
        address += block.count
      }
      index += 1
    }
    
    barProgress.minValue = 0.0
    barProgress.maxValue = Double(dataBytesToRead)
    barProgress.doubleValue = 0.0

    totalBytesRead = 0
    
    lblStatus.stringValue = "Writing Variables - \(totalBytesRead) bytes"
    
    state = .writingMemory
    
    networkLayer.sendNodeMemoryWriteRequest(sourceNodeId: nodeId, destinationNodeId: node.nodeId, addressSpace: dataToWrite[0].space, startAddress: dataToWrite[0].address, dataToWrite: dataToWrite[0].data)

  }

}
