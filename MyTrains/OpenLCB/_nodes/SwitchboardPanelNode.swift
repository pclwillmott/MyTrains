//
//  SwitchboardPanelNode.swift
//  MyTrains
//
//  Created by Paul Willmott on 23/01/2024.
//

import Foundation

public class SwitchboardPanelNode : OpenLCBNodeVirtual {
 
  // MARK: Constructors
  
  public init(nodeId:UInt64, layoutNodeId:UInt64 = 0) {
    
    super.init(nodeId: nodeId)
    
    var configurationSize = 0
    initSpaceAddress(&addressNumberOfColumns, 2, &configurationSize)
    initSpaceAddress(&addressNumberOfRows, 2, &configurationSize)

    configuration = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, defaultMemorySize: configurationSize, isReadOnly: false, description: "")
    
    if let configuration {
      
      if layoutNodeId != 0 {
        self.layoutNodeId = layoutNodeId
      }
      
      virtualNodeType = MyTrainsVirtualNodeType.switchboardPanelNode
      
      eventsConsumed = [
        OpenLCBWellKnownEvent.identifyMyTrainsSwitchboardPanels.rawValue,
      ]
      
      eventsProduced = [
        OpenLCBWellKnownEvent.nodeIsASwitchboardPanel.rawValue,
      ]
      
      configuration.delegate = self
      
      memorySpaces[configuration.space] = configuration
      
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressNumberOfColumns)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressNumberOfRows)
      
      if !memorySpacesInitialized {
        resetToFactoryDefaults()
      }
      
      cdiFilename = "MyTrains Switchboard Panel"
      
    }
    
  }

  // MARK: Private Properties

  // Configuration varaible addresses
  
  internal var addressNumberOfColumns = 0
  internal var addressNumberOfRows    = 0

  // MARK: Public Properties
  
  public var numberOfColumns : UInt16 {
    get {
      return configuration!.getUInt16(address: addressNumberOfColumns)!
    }
    set(value) {
      configuration!.setUInt(address: addressNumberOfColumns, value: value)
    }
  }

  public var numberOfRows : UInt16 {
    get {
      return configuration!.getUInt16(address: addressNumberOfRows)!
    }
    set(value) {
      configuration!.setUInt(address: addressNumberOfRows, value: value)
    }
  }

  // MARK: Private Methods

  internal override func resetToFactoryDefaults() {

    configuration!.zeroMemory()
    
    super.resetToFactoryDefaults()
    
    numberOfColumns = 30
    numberOfRows    = 30
    
    saveMemorySpaces()

  }
  
  internal func sendNodeIsASwitchboardPanel() {
    sendWellKnownEvent(eventId: .nodeIsASwitchboardPanel, payload: layoutNodeId.nodeIdBigEndianData)
  }
  
  // MARK: OpenLCBNetworkLayerDelegate Methods
  
  public override func openLCBMessageReceived(message: OpenLCBMessage) {
    
    super.openLCBMessageReceived(message: message)
    
    switch message.messageTypeIndicator {
     
    case .producerConsumerEventReport:
      
      if let eventId = message.eventId, let event = OpenLCBWellKnownEvent(rawValue: eventId) {
          
        switch event {
        case .identifyMyTrainsSwitchboardPanels:
          sendNodeIsASwitchboardPanel()
        default:
          break
        }

      }
      
    default:
      break
    }
    
  }
  
}
