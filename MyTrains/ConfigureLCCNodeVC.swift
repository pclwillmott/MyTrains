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
}

private typealias MemoryMapItem = (address: UInt64, size: Int, data: [UInt8])

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
    
    
    
  }
  
  // MARK: Private Properties
  
  private var networkLayer : LCCNetworkLayer?
  
  private var observerId : Int = -1
  
  private var nextCDIStartAddress : UInt32 = 0
  
  private var bytesToGo : UInt32 = 0
  
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
  
  // MARK: Public Properties
  
  public var node: OpenLCBNode?
  
  // MARK: Private Methods
  
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
        for replicationNumber in 1...childTemplate.replication {
          let child = childTemplate.clone()
          child.tag = currentTag
          currentTag += 1
          elementLookup[child.tag] = child
          child.childElements = makeChildren(template: childTemplate.childElements)
          if !child.repname.isEmpty {
            child.name = "\(child.repname) \(replicationNumber)"
          }
          result.append(child)
        }
      }
      else {
        let child = childTemplate.clone()
        child.tag = currentTag
        currentTag += 1
        elementLookup[child.tag] = child
       child.childElements = makeChildren(template: childTemplate.childElements)
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
          var memoryMapItem : MemoryMapItem = (address: child.sortAddress, size: child.size, data: [])
          memoryMap.append(memoryMapItem)
        }
        result.append(child)
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
      element.childElements = makeChildren(template: element.childElements)
      elementLookup[element.tag] = element
    }
    
    memoryMap.sort {$0.address < $1.address}
    
    var index = 0
    while index < memoryMap.count {
      if index + 1 < memoryMap.count {
        var current = memoryMap[index]
        var nextAddress = current.address + UInt64(current.size)
        var next = memoryMap[index + 1]
        var good = false
        for gap in 0...0 {
          if next.address == nextAddress + UInt64(gap) {
            memoryMap[index].size += next.size + gap
            good = true
            break
          }
        }
        if good {
          memoryMap.remove(at: index + 1)
        }
        else {
          index += 1
        }
      }
      else {
        index += 1
      }
    }
    
    var bytes = 0
    print("count: \(memoryMap.count)")
    for item in memoryMap {
      bytes += item.size
      print("0x\((item.address >> 32).toHex(numberOfDigits: 2)): \(item.address & 0xffffffff): \(item.size)")
    }
    print("bytes: \(bytes)")
    
    outlineViewDS = LCCCDITreeViewDS(root: currentElement!)
    outlineView.dataSource = outlineViewDS
    outlineView.delegate = outlineViewDS
//    printDataElement(dataElement: currentElement!, indent: "  ")
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
      case .datagram:
        
        if let node = self.node {
          
          network.sendDatagramReceivedOK(sourceNodeId: sourceNodeId, destinationNodeId: node.nodeId, replyPending: false, timeOut: 0.0)
          
          var data = message.otherContent
          
          if data[0] == 0x20 {
            
            switch data[1] {
            case 0x51:
              break
            case 0x52:
              break
            case 0x53:
              if state == .gettingCDI {
                
                let startAddress =
                (UInt32(data[2]) << 24) |
                (UInt32(data[3]) << 16) |
                (UInt32(data[4]) << 8) |
                (UInt32(data[5]))
                
                if startAddress == nextCDIStartAddress {
                  
                  data.removeFirst(6)
                  
                  var isLast = false
                  
                  for byte in data {
                    if byte == 0 {
                      isLast = true
                      break
                    }
                    CDI.append(byte)
                  }
                  
                  if !isLast {
                    nextCDIStartAddress += UInt32(data.count)
                    network.sendNodeMemoryReadRequest(sourceNodeId: sourceNodeId, destinationNodeId: node.nodeId, addressSpace: LCCNodeMemoryAddressSpace.CDI.rawValue, startAddress: nextCDIStartAddress, numberOfBytesToRead: 64)
                  }
                  else {
                    let newData : Data = Data(CDI)
                    xmlParser = XMLParser(data: newData)
                    xmlParser?.delegate = self
                    xmlParser?.parse()
                 //   print(String(decoding: CDI, as: UTF8.self))

                    state = .idle
                  }
                }
                else {
                  print("error: bad address - \(startAddress.toHex(numberOfDigits: 8))")
                  state = .idle
                }
                
              }
            case 0x50:
              break
            case 0x86, 0x87:
              let info = node.addAddressSpaceInformation(message: message)
              switch info.addressSpace {
              case 0xff:
                if state == .gettingAddressSpaceInfo {
                  state = .gettingCDI
                  nextCDIStartAddress = info.lowestAddress
                  bytesToGo = info.highestAddress - info.lowestAddress + 1
                  let numberOfBytes = UInt8(min(64, bytesToGo))
                  CDI = []
                  network.sendNodeMemoryReadRequest(sourceNodeId: sourceNodeId, destinationNodeId: node.nodeId, addressSpace: LCCNodeMemoryAddressSpace.CDI.rawValue, startAddress: nextCDIStartAddress, numberOfBytesToRead: numberOfBytes)
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
//    print("parserDidEndDocument")
    
//    printDataElement(dataElement: currentElement!, indent: "  ")
/*
    buildFieldList()
    
    tableViewDS.fields = fieldList
    tableView.dataSource = tableViewDS
    tableView.delegate = tableViewDS
    tableView.reloadData()
  */
    
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
    
  @IBAction func btnGetCDI(_ sender: NSButton) {
    
    if let network = networkLayer {
      state = .gettingAddressSpaceInfo
      network.sendGetMemorySpaceInformationRequest(sourceNodeId: sourceNodeId, destinationNodeId: node!.nodeId, addressSpace: 0xff)
    }
  }
  
  @IBOutlet weak var outlineView: NSOutlineView!
    
  @IBAction func outlineViewAction(_ sender: NSOutlineView) {

    let selectedIndex = outlineView.selectedRow
    
    if let node = outlineView.item(atRow: selectedIndex) as? LCCCDIElement {
      
      editElement = nil
      
      switch node.type {
      case .eventid:
        break
      case .float:
        break
      case .int:
        break
      case .string:
        break
      default:
        return
      }
      
      editElement = node
      
      lblName.stringValue = node.name
      
      lblDescription.stringValue = node.description
      
      if node.map.count > 0 {
        
        let map = LCCCDIMap(field: node)
        
        map.populate(comboBox: cboCombo)
        
      }
      
    }
  }
  
  @IBOutlet weak var lblName: NSTextField!
  
  @IBOutlet weak var cboCombo: NSComboBox!
  
  @IBAction func cboComboAction(_ sender: NSComboBox) {
  }
  
  @IBOutlet weak var lblDescription: NSTextField!
  
}

