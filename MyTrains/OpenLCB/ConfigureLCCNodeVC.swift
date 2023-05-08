//
//  ConfigureLCCNodeVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 22/04/2023.
//

import Foundation
import Cocoa

private enum State {
  case idle
  case gettingAddressSpaceInfo
  case gettingCDI
  case readingMemory
  case refreshElement
  case writingMemory
}

private typealias MemoryMapItem = (sortAddress:UInt64, space:UInt8, address: Int, size: Int, data: [UInt8], modified: Bool)

class ConfigureLCCNodeVC: NSViewController, NSWindowDelegate, LCCNetworkLayerDelegate, XMLParserDelegate {
  
  // MARK: Window & View Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }
  
  func windowWillClose(_ notification: Notification) {
    if observerId != -1 {
      networkLayer?.removeObserver(observerId: observerId)
      observerId = -1
    }
  }
  
  override func viewWillAppear() {
    
    self.view.window?.delegate = self
    
    networkLayer = networkController.lccNetworkLayer
    
    if let network = self.networkLayer {
      observerId = network.addObserver(observer: self)
    }
    
    self.view.window?.title = "Configure \(node!.manufacturerName) - \(node!.nodeModelName) (\(node!.nodeId.toHexDotFormat(numberOfBytes: 6)))"
    
    sourceNodeId = networkController.lccNodeId
    
    safeTextTop = txtValue.frame.origin.y
    
    lblDescription.isHidden = true
    cboCombo.isHidden = true
    txtValue.isHidden = true
    boxBox.title = ""
    barProgress.isHidden = true
    btnRefresh.isEnabled = false
    btnWrite.isEnabled = false

    if let network = networkLayer {
      
      state = .gettingAddressSpaceInfo
      
      network.sendGetMemorySpaceInformationRequest(sourceNodeId: sourceNodeId, destinationNodeId: node!.nodeId, addressSpace: 0xff)

      lblStatus.stringValue = "Reading Configuration Description Information - \(totalBytesRead) bytes"
      
    }

  }
  
  // MARK: Private Properties
  
  private var networkLayer : LCCNetworkLayer?
  
  private var observerId : Int = -1
  
  private var nextCDIStartAddress : Int = 0
  
  //private var bytesToGo : UInt32 = 0
  
  private var CDI : [UInt8] = []
  
  private var sourceNodeId : UInt64 = 0
  
  private var state : State = .idle
  
  private var xmlParser : XMLParser?
  
  private var currentElement : LCCCDIElement?
  
  private var currentElementType : LCCCDIElementType = .int
  
  private var groupStack : [LCCCDIElement] = []
  
  private var relationProperty : String?
  
  private var relationValue : String?
  
  private var fieldTree : LCCCDIElement?
  
  private var currentSpace : UInt8 = 0
  
  private var currentAddress : Int = 0
  
  private var currentTag : Int = 0
  
  private var elementLookup : [Int:LCCCDIElement] = [:]
  
  private var tableViewDS = LCCCDITableViewDS()
  
  private var outlineViewDS : LCCCDITreeViewDS?
  
  private var editElement : LCCCDIElement?
  
  private var memoryMap : [MemoryMapItem] = []
  
  private var currentMemoryBlock : Int = 0
  
  private var totalBytesRead = 0
  
  private var dataBytesToRead = 0
  
  private var refreshMemoryBlock : Int = 0
  
  private var safeTextTop : CGFloat = 0.0
  
  private var timer : Timer?
  
  var dataToWrite : [(space: UInt8, address:Int, data:[UInt8])] = []
  
  // MARK: Public Properties
  
  public var node: OpenLCBNode?
  
  // MARK: Private Methods
  
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
  
  private func displayErrorMessage(message: String) {
    
    let alert = NSAlert()

    alert.messageText = "Error"
    alert.informativeText = message
    alert.addButton(withTitle: "OK")
 // alert.addButton(withTitle: "Cancel")
    alert.alertStyle = .critical

    let _ = alert.runModal() // == NSAlertFirstButtonReturn

  }
  
  private func displayEditElement(element:LCCCDIElement) {
    
    editElement = nil
    
    if !element.type.isData {
      lblDescription.isHidden = true
      cboCombo.isHidden = true
      txtValue.isHidden = true
      boxBox.title = ""
      btnRefresh.isEnabled = false
      btnWrite.isEnabled = false
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
        switch element.size {
        case 2:
          // TODO: Add custom data type for Float16
          print("displayEditElement: float16 found!")
        case 4:
          let word = UInt32(floatValue & 0xffffffff)
          let float32 = Float32(bitPattern: word)
          txtValue.stringValue = "\(float32)"
        case 8:
          let float64 = Float64(bitPattern: floatValue)
          txtValue.stringValue = "\(float64)"
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
          let int8 = Int8(bitPattern: byte)
          txtValue.stringValue = "\(int8)"
        case 2:
          let word = UInt16(intValue & 0xffff)
          let int16 = Int16(bitPattern: word)
          txtValue.stringValue = "\(int16)"
        case 4:
          let dword = UInt32(intValue & 0xffffffff)
          let int32 = Int32(bitPattern: dword)
          txtValue.stringValue = "\(int32)"
        case 8:
          let int64 = Int64(bitPattern: intValue)
          txtValue.stringValue = "\(int64)"
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

  private func printDataElement(dataElement:LCCCDIElement, indent:String) {
    print("\(indent) space: 0x\(dataElement.space.toHex(numberOfDigits: 2)) address: \(dataElement.address) name: \"\(dataElement.name)\" type: \(dataElement.type) size: \(dataElement.size) description: \"\(dataElement.description)\" replication: \(dataElement.replication) repname: \"\(dataElement.repname)\" stringValue: \"\(dataElement.stringValue)\"")
    if dataElement.map.count > 0 {
      print("\(indent) map:")
      for relation in dataElement.map {
        print("\(indent)  property: \"\(relation.property)\" value: \"\(relation.stringValue)\"")
      }
    }
    for child in dataElement.childElements {
      printDataElement(dataElement: child, indent: indent + "  ")
    }
  }

  private func makeChildren(template:[LCCCDIElement]) -> [LCCCDIElement] {
    
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
          group.childElements = makeChildren(template: childTemplate.childElements)
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
            child.childElements = makeChildren(template: childTemplate.childElements)
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
          var memoryMapItem : MemoryMapItem = (sortAddress: child.sortAddress, space: child.space, address: child.address, size: child.size, data: [], modified: false)
          memoryMap.append(memoryMapItem)
        }
        child.childElements = makeChildren(template: childTemplate.childElements)
      }
      
    }
    
    return result
    
  }
  
  private func expandTree() {
    
    elementLookup.removeAll()
    currentSpace = 0
    currentAddress = 0
    currentTag = 0
    memoryMap.removeAll()
    if let element = currentElement {
      element.tag = currentTag
      currentTag += 1
      elementLookup[element.tag] = element
      element.childElements = makeChildren(template: element.childElements)
    }
    
    outlineViewDS = LCCCDITreeViewDS(root: currentElement!)
    outlineView.dataSource = outlineViewDS
    outlineView.delegate = outlineViewDS
        
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

    if let node = self.node, let network = networkLayer {

      state = .readingMemory

      currentMemoryBlock = 0
      
      nextCDIStartAddress = memoryMap[currentMemoryBlock].address
      
      let bytesToRead = UInt8(min(64, memoryMap[currentMemoryBlock].size))
      
      network.sendNodeMemoryReadRequest(sourceNodeId: sourceNodeId, destinationNodeId: node.nodeId, addressSpace: memoryMap[currentMemoryBlock].space, startAddress: nextCDIStartAddress, numberOfBytesToRead: bytesToRead)
      
    }
    
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

  // MARK: LCCNetworkLayerDelegate Methods
  
  func networkLayerStateChanged(networkLayer: LCCNetworkLayer) {
    
  }
  
  func openLCBMessageReceived(message: OpenLCBMessage) {
    
    guard message.destinationNodeId == sourceNodeId && message.sourceNodeId == node!.nodeId else {
      return
    }
    
    if let network = networkLayer {
      
      switch message.messageTypeIndicator {
       
      case .datagramReceivedOK:
        
        if let node = self.node {
          
          if state == .writingMemory {
            
            if !message.otherContent.isEmpty {
              
              let flags = message.otherContent[0]
              
              let replyPending = (flags & 0x80) == 0x80
              
              let exponent = flags & 0x0f
              
              if exponent > 0 {
                
                let delay : TimeInterval = pow(2.0, Double(exponent))
                
                startTimer(timeInterval: delay)
                
              }
              
            }
            else {
              
              dataToWrite.removeFirst()
              
              if !dataToWrite.isEmpty {
                network.sendNodeMemoryWriteRequest(sourceNodeId: sourceNodeId, destinationNodeId: node.nodeId, addressSpace: dataToWrite[0].space, startAddress: dataToWrite[0].address, dataToWrite: dataToWrite[0].data)
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
          
          network.sendDatagramReceivedOK(sourceNodeId: sourceNodeId, destinationNodeId: node.nodeId, replyPending: false, timeOut: 0.0)
          
          var data = message.otherContent
          
          if data[0] == 0x20 {

            switch data[1] {
              
            case 0x10, 0x11, 0x12, 0x13:
              
              if state == .writingMemory {
                
                dataToWrite.removeFirst()
                
                if !dataToWrite.isEmpty {
                  network.sendNodeMemoryWriteRequest(sourceNodeId: sourceNodeId, destinationNodeId: node.nodeId, addressSpace: dataToWrite[0].space, startAddress: dataToWrite[0].address, dataToWrite: dataToWrite[0].data)
                }
                else {
                  stopTimer()
                  state = .idle
                }

              }
            case 0x18, 0x19, 0x1a, 0x1b:
              
              stopTimer()
              
              state = .idle

              displayErrorMessage(message: "Write failed")
              
            case 0x50, 0x51, 0x52:

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
                    
                    network.sendNodeMemoryReadRequest(sourceNodeId: sourceNodeId, destinationNodeId: node.nodeId, addressSpace: memoryMap[currentMemoryBlock].space, startAddress: nextCDIStartAddress, numberOfBytesToRead: bytesToRead)

                  }
                  else {
                    
                    currentMemoryBlock += 1
                    
                    if state == .readingMemory && currentMemoryBlock < memoryMap.count {
                      
                      nextCDIStartAddress = memoryMap[currentMemoryBlock].address
                      
                      let bytesToRead = UInt8(min(64, memoryMap[currentMemoryBlock].size))
                      
                      network.sendNodeMemoryReadRequest(sourceNodeId: sourceNodeId, destinationNodeId: node.nodeId, addressSpace: memoryMap[currentMemoryBlock].space, startAddress: nextCDIStartAddress, numberOfBytesToRead: bytesToRead)
                      
                    }
                    else {
                      
                      if state == .refreshElement {
                        displayEditElement(element: editElement!)
                      }
                      
                      barProgress.isHidden = true
                      
                      lblStatus.stringValue = ""
                      
                      state = .idle
                      
                    }
                    
                  }
                }
                else {
                  print("error: bad space or address - 0x\(thisSpace.toHex(numberOfDigits: 2))  0x\(startAddress.toHex(numberOfDigits: 8))")
                  state = .idle
                }
                
              }
            case 0x53:
              
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
                  
                  if !isLast {
                    
                    nextCDIStartAddress += data.count
                    
                    network.sendNodeMemoryReadRequest(sourceNodeId: sourceNodeId, destinationNodeId: node.nodeId, addressSpace: LCCNodeMemoryAddressSpace.CDI.rawValue, startAddress: nextCDIStartAddress, numberOfBytesToRead: 64)
                    
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
            case 0x86, 0x87:
              let info = node.addAddressSpaceInformation(message: message)
              switch info.addressSpace {
              case 0xff:
                if state == .gettingAddressSpaceInfo {
                  state = .gettingCDI
                  totalBytesRead = 0
                  nextCDIStartAddress = info.lowestAddress
                  CDI = []
                  network.sendNodeMemoryReadRequest(sourceNodeId: sourceNodeId, destinationNodeId: node.nodeId, addressSpace: LCCNodeMemoryAddressSpace.CDI.rawValue, startAddress: nextCDIStartAddress, numberOfBytesToRead: 64)
                }
              case 0xfe:
                break
              case 0xfd:
                break
              default:
                break
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

    if let elementType = LCCCDIElementType(rawValue: elementName) {
      
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
    
    if let elementType = LCCCDIElementType(rawValue: elementName) {
      
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

  
  // MARK: Outlets & Actions
    
  @IBOutlet weak var outlineView: NSOutlineView!
    
  @IBAction func outlineViewAction(_ sender: NSOutlineView) {

    let selectedIndex = outlineView.selectedRow
    
    if let node = outlineView.item(atRow: selectedIndex) as? LCCCDIElement {
      
      displayEditElement(element: node)
    }
    
  }
  
  @IBOutlet weak var cboCombo: NSComboBox!
  
  @IBAction func cboComboAction(_ sender: NSComboBox) {
  }
  
  @IBOutlet weak var lblDescription: NSTextField!
  
  @IBOutlet weak var txtValue: NSTextField!
  
  @IBOutlet weak var boxBox: NSBox!
  
  @IBOutlet weak var lblStatus: NSTextField!
  
  @IBOutlet weak var barProgress: NSProgressIndicator!
  
  @IBOutlet weak var btnRefresh: NSButton!
  
  @IBAction func btnRefreshAction(_ sender: NSButton) {
    
    if let element = editElement, let index = getMemoryBlockIndex(sortAddress: element.sortAddress) {
 
      memoryMap[index].data.removeAll()
      
      barProgress.minValue = 0.0
      barProgress.maxValue = Double(memoryMap[index].size)
      barProgress.doubleValue = 0.0
      barProgress.isHidden = false
      
      totalBytesRead = 0
      
      lblStatus.stringValue = "Reading Variables - \(totalBytesRead) bytes"
      
      if let node = self.node, let network = networkLayer {
        
        state = .refreshElement
        
        currentMemoryBlock = index
        
        nextCDIStartAddress = memoryMap[currentMemoryBlock].address
        
        let bytesToRead = UInt8(min(64, memoryMap[currentMemoryBlock].size))
        
        network.sendNodeMemoryReadRequest(sourceNodeId: sourceNodeId, destinationNodeId: node.nodeId, addressSpace: memoryMap[currentMemoryBlock].space, startAddress: nextCDIStartAddress, numberOfBytesToRead: bytesToRead)
        
      }
    }
    
  }
  
  @IBOutlet weak var btnWrite: NSButton!
  
  @IBAction func btnWriteAction(_ sender: NSButton) {
    
    if let element = editElement, let index = getMemoryBlockIndex(sortAddress: element.sortAddress) {
      
      if element.map.count == 0 {

        // Check that numbers are OK for the data type and size
       
        var data : [UInt8] = []
        
        switch element.type {
          
        case .int:
          
          switch element.size {
          case 1:
            if let int8 = Int8(txtValue.stringValue) {
              if let max = element.max, let maxInt8 = Int8(max), int8 > maxInt8 {
                displayErrorMessage(message: "The value is greater than the maximum value of \(max).")
                return
              }
              if let min = element.min, let minInt8 = Int8(min), int8 < minInt8 {
                displayErrorMessage(message: "The value is greater than the minimum value of \(min).")
                return
              }
              data = int8.bigEndianData
            }
            else {
              displayErrorMessage(message: "Integer value expected.")
              return
            }
          case 2:
            if let int16 = Int16(txtValue.stringValue) {
              if let max = element.max, let maxInt16 = Int16(max), int16 > maxInt16 {
                displayErrorMessage(message: "The value is greater than the maximum value of \(max).")
                return
              }
              if let min = element.min, let minInt16 = Int16(min), int16 < minInt16 {
                displayErrorMessage(message: "The value is greater than the minimum value of \(min).")
                return
              }
              data = int16.bigEndianData
           }
            else {
              displayErrorMessage(message: "Integer value expected.")
              return
            }
          case 4:
            if let int32 = Int32(txtValue.stringValue) {
              if let max = element.max, let maxInt32 = Int32(max), int32 > maxInt32 {
                displayErrorMessage(message: "The value is greater than the maximum value of \(max).")
                return
              }
              if let min = element.min, let minInt32 = Int32(min), int32 < minInt32 {
                displayErrorMessage(message: "The value is greater than the minimum value of \(min).")
                return
              }
              data = int32.bigEndianData
            }
            else {
              displayErrorMessage(message: "Integer value expected.")
              return
            }
          case 8:
            if let int64 = Int64(txtValue.stringValue) {
              if let max = element.max, let maxInt64 = Int64(max), int64 > maxInt64 {
                displayErrorMessage(message: "The value is greater than the maximum value of \(max).")
                return
              }
              if let min = element.min, let minInt64 = Int64(min), int64 < minInt64 {
                displayErrorMessage(message: "The value is greater than the minimum value of \(min).")
                return
              }
              data = int64.bigEndianData
            }
            else {
              displayErrorMessage(message: "Integer value expected.")
              return
            }
          default:
            print("btnWriteAction: unexpected integer size: \(element.size)")
            return
          }
          
        case .float:
          
          switch element.size {
          case 2:
            print("btnWriteAction: float16 found!")
            return
          case 4:
            if let float32 = Float32(txtValue.stringValue) {
              if let max = element.max, let maxFloat32 = Float32(max), float32 > maxFloat32 {
                displayErrorMessage(message: "The value is greater than the maximum value of \(max).")
                return
              }
              if let min = element.min, let minFloat32 = Float32(min), float32 < minFloat32 {
                displayErrorMessage(message: "The value is greater than the minimum value of \(min).")
                return
              }
              data = float32.bitPattern.bigEndianData
            }
            else {
              displayErrorMessage(message: "Float value expected.")
              return
            }
          case 8:
            if let float64 = Float64(txtValue.stringValue) {
              if let max = element.max, let maxFloat64 = Float64(max), float64 > maxFloat64 {
                displayErrorMessage(message: "The value is greater than the maximum value of \(max).")
                return
              }
              if let min = element.min, let minFloat64 = Float64(min), float64 < minFloat64 {
                displayErrorMessage(message: "The value is greater than the minimum value of \(min).")
                return
              }
              data = float64.bitPattern.bigEndianData
            }
            else {
              displayErrorMessage(message: "Float value expected.")
              return
            }
          default:
            print("btnWriteAction: unexpected float size: \(element.size)")
            return
          }
          
        case .string:
          
          let stringValue = txtValue.stringValue
          
          if stringValue.count >= element.size {
            displayErrorMessage(message: "Text has too many characters. The maximum length is \(element.size - 1) characters.")
            return
          }
          
          data = stringValue.padWithNull(length: element.size)
          
        case .eventid:
          
          if let eventId = UInt64(dotHex: txtValue.stringValue) {
            data = eventId.bigEndianData
          }
          else {
            displayErrorMessage(message: "Invalid event ID.")
            return
          }
          
        default:
          print("btnWriteAction: unexpected element type: \(element.type)")
          return
        }

        setMemoryBlock(sortAddress: element.sortAddress, data: data)

        if let node = self.node, let network = networkLayer {

          state = .writingMemory

          dataToWrite.removeAll()
          
          var item = 0
          var address = element.address
          while item < data.count {
            let numberToWrite = min(64, data.count)
            var block : [UInt8] = []
            for _ in 1...numberToWrite {
              block.append(data.first!)
              data.removeFirst()
              item += 1
            }
            dataToWrite.append((space: memoryMap[index].space, address: address, data: block))
            address += data.count
          }
          
          network.sendNodeMemoryWriteRequest(sourceNodeId: sourceNodeId, destinationNodeId: node.nodeId, addressSpace: dataToWrite[0].space, startAddress: dataToWrite[0].address, dataToWrite: dataToWrite[0].data)
          
        }

      }
      
      // TODO: MAPPINGS!
      
      else {
        
      }
      
    }
    
  }
  
}

