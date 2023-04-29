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

private enum XMLState {
  case idle
  case name
  case relation
  case property
  case value
  case description
  case repname
  case min
  case max
  case defaultValue
  case manufacturer
  case model
  case hardwareVersion
  case softwareVersion
}

private enum ElementName : String {
  
  case cdi             = "cdi"
  case name            = "name"
  case description     = "description"
  case repname         = "repname"
  case group           = "group"
  case string          = "string"
  case int             = "int"
  case eventid         = "eventid"
  case float           = "float"
  case map             = "map"
  case min             = "min"
  case max             = "max"
  case defaultValue    = "default"
  case relation        = "relation"
  case property        = "property"
  case value           = "value"
  case identification  = "identification"
  case manufacturer    = "manufacturer"
  case model           = "model"
  case hardwareVersion = "hardwareVersion"
  case softwareVersion = "softwareVersion"
  case acdi            = "acdi"
  case segment         = "segment"
  
}

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
  
  private var elements : [LCCCDIElement] = []
  
  private var currentElement : LCCCDIElement?
  
  private var currentDataElement : LCCCDIDataElement?
  
  private var groupStack : [LCCCDIDataElement] = []
  
  private var xmlState : XMLState = .idle
  
  private var relationProperty : String?
  
  private var relationValue : String?
  
  // MARK: Public Properties
  
  public var node: OpenLCBNode?
  
  // MARK: Private Methods
  
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
    elements.removeAll()
    currentElement = nil
    currentDataElement = nil
  }

  func parserDidEndDocument(_ parser: XMLParser) {
//    print("parserDidEndDocument")
    
    for element in elements {
      print("\(element.type) \(element.name) \(element.space.toHex(numberOfDigits: 2))")
      
      for dataElement in element.dataElements {
        printDataElement(dataElement: dataElement, indent: "  ")
      }
    }
    
    
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

    if let elementType = ElementName(rawValue: elementName) {
      
      switch elementType {
      case .name:
        xmlState = .name
      case .description:
        xmlState = .description
      case .repname:
        xmlState = .repname
      case .property:
        xmlState = .property
      case .value:
        xmlState = .value
      case .min:
        xmlState = .min
      case .max:
        xmlState = .max
      case .defaultValue:
        xmlState = .defaultValue
      case .relation:
        relationProperty = nil
        relationValue = nil
      case .group, .eventid, .string, .int, .float:
        var dataElementType : LCCCDIDataElementType
        switch elementType {
        case .group:
          dataElementType = .group
        case .eventid:
          dataElementType = .eventid
        case .string:
          dataElementType = .string
        case .float:
          dataElementType = .float
        default:
          dataElementType = .int
        }
        let dataElement = LCCCDIDataElement(parentElement: currentElement!, parentDataElement: currentDataElement, type: dataElementType)
        if let offset = attributeDict["offset"] {
          dataElement.offset = Int(offset) ?? 0
        }
        if let replication = attributeDict["replication"] {
          dataElement.replication = Int(replication) ?? 1
        }
        if let size = attributeDict["size"] {
          dataElement.size = Int(size) ?? 0
        }
        else if dataElementType == .eventid {
          dataElement.size = 8
        }
        if let currentDataElement = self.currentDataElement {
          currentDataElement.dataElements.append(dataElement)
          groupStack.append(currentDataElement)
        }
        else {
          currentElement?.dataElements.append(dataElement)
        }
        currentDataElement = dataElement
      case .map:
        currentDataElement?.map.removeAll()
      case .identification, .acdi, .segment:
        var type : LCCCDIElementType
        switch elementType {
        case .acdi:
          type = .acdi
        case .identification:
          type = .identification
        default:
          type = .segment
        }
        let element = LCCCDIElement(type: type)
        if let space = attributeDict["space"] {
          element.space = UInt8(space) ?? 0
        }
        if let origin = attributeDict["origin"] {
          element.origin = Int(origin) ?? 0
        }
        elements.append(element)
        currentElement = element
      case .manufacturer, .model, .softwareVersion, .hardwareVersion:
        switch elementType {
        case .manufacturer:
          xmlState = .manufacturer
        case .model:
          xmlState = .model
        case .softwareVersion:
          xmlState = .softwareVersion
        case .hardwareVersion:
          xmlState = .hardwareVersion
        default:
          break
        }
        let dataElement = LCCCDIDataElement(parentElement: currentElement!, parentDataElement: nil, type: .string)
        dataElement.name = elementName
        currentElement?.dataElements.append(dataElement)
        currentDataElement = dataElement
      default:
        break
      }
    }
    else {
      print("UNKNOWN ELEMENT TYPE: \"\(elementName)\"")
    }
    
  }

  func printDataElement(dataElement:LCCCDIDataElement, indent:String) {
    print("\(indent)name: \"\(dataElement.name)\" type: \(dataElement.type) size: \(dataElement.size) description: \"\(dataElement.description)\" replication: \(dataElement.replication) repname: \"\(dataElement.repname)\" stringValue: \"\(dataElement.stringValue)\"")
    if dataElement.map.count > 0 {
      print("\(indent) map:")
      for relation in dataElement.map {
        print("\(indent)  property: \"\(relation.property)\" value: \"\(relation.stringValue)\"")
      }
    }
    for child in dataElement.dataElements {
      printDataElement(dataElement: child, indent: indent + "  ")
    }
  }
  
  func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    if let elementType = ElementName(rawValue: elementName) {
      switch elementType {
      case .group, .string, .int, .float, .eventid, .hardwareVersion, .softwareVersion, .model, .manufacturer:
        if let last = groupStack.last {
          currentDataElement = last
          groupStack.removeLast()
        }
        else {
          currentDataElement = nil
        }
      case .relation:
        if let property = relationProperty, let value = relationValue {
          let relation = LCCCDIMapRelation(property: property, stringValue: value)
          currentDataElement?.map.append(relation)
        }
      default:
        break
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
    switch xmlState {
    case .name:
      if let dataElement = currentDataElement {
        dataElement.name = string
      }
      else {
        currentElement?.name = string
      }
    case .relation:
      relationProperty = nil
      relationValue = nil
    case .property:
      relationProperty = string
    case .value:
      relationValue = string
      break
    case .description:
      if let dataElement = currentDataElement {
        dataElement.description = string
      }
      else {
        currentElement?.description = string
      }
    case .repname:
      if let dataElement = currentDataElement {
        dataElement.repname = string
      }
    case .min:
      if let dataElement = currentDataElement {
        dataElement.min = string
      }
    case .max:
      if let dataElement = currentDataElement {
        dataElement.max = string
      }
    case .defaultValue:
      if let dataElement = currentDataElement {
        dataElement.defaultValue = string
      }
    case .manufacturer, .model, .softwareVersion, .hardwareVersion:
      if let dataElement = currentDataElement {
        dataElement.stringValue = string
      }
    default:
      break
    }
    xmlState = .idle
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
  
}

