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
    print("parserDidStartDocument")
  }

  
  func parserDidEndDocument(_ parser: XMLParser) {
    print("parserDidEndDocument")
  }

  
  func parser(_ parser: XMLParser, foundNotationDeclarationWithName name: String, publicID: String?, systemID: String?) {
    
  }

  
  func parser(_ parser: XMLParser, foundUnparsedEntityDeclarationWithName name: String, publicID: String?, systemID: String?, notationName: String?) {
    
  }

  
  func parser(_ parser: XMLParser, foundAttributeDeclarationWithName attributeName: String, forElement elementName: String, type: String?, defaultValue: String?) {
    
  }

  
  func parser(_ parser: XMLParser, foundElementDeclarationWithName elementName: String, model: String) {
    
  }

  
  func parser(_ parser: XMLParser, foundInternalEntityDeclarationWithName name: String, value: String?) {
    
  }

  
  func parser(_ parser: XMLParser, foundExternalEntityDeclarationWithName name: String, publicID: String?, systemID: String?) {
    
  }

  
  func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
    print("didStartElement: \(elementName) \(attributeDict)")
  }

  
  func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    print("didEndElement: \(elementName)")
  }

  
  func parser(_ parser: XMLParser, didStartMappingPrefix prefix: String, toURI namespaceURI: String) {
    
  }

  
  func parser(_ parser: XMLParser, didEndMappingPrefix prefix: String) {
    
  }

  
  func parser(_ parser: XMLParser, foundCharacters string: String) {
    print("foundCharacters: \(string)")
  }

  
  func parser(_ parser: XMLParser, foundIgnorableWhitespace whitespaceString: String) {
    print("foundIgnorableWhiteSpace: \(whitespaceString)")
  }

  
  func parser(_ parser: XMLParser, foundProcessingInstructionWithTarget target: String, data: String?) {
    
  }

  
  func parser(_ parser: XMLParser, foundComment comment: String) {
    print("foundComment: \(comment)")
  }

  
  func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
    
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

