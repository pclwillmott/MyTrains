//
//  SwitchboardPanelNode.swift
//  MyTrains
//
//  Created by Paul Willmott on 23/01/2024.
//

import Foundation

public class SwitchboardPanelNode : OpenLCBNodeVirtual {
 
  // MARK: Constructors
  
  public override init(nodeId:UInt64) {
    
    configuration = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, defaultMemorySize: 4, isReadOnly: false, description: "")
    
    super.init(nodeId: nodeId)
    
    virtualNodeType = MyTrainsVirtualNodeType.switchboardPanelNode
    
    configuration.delegate = self

    memorySpaces[configuration.space] = configuration

    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressNumberOfColumns)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressNumberOfRows)

    if !memorySpacesInitialized {
      resetToFactoryDefaults()
    }

    cdiFilename = "MyTrains Switchboard Panel"

  }

  // MARK: Private Properties

  // Configuration varaible addresses
  
  internal let addressNumberOfColumns  : Int =  0
  internal let addressNumberOfRows     : Int =  2

  private var configuration : OpenLCBMemorySpace

  // MARK: Public Properties
  
  public var numberOfColumns : UInt16 {
    get {
      return configuration.getUInt16(address: addressNumberOfColumns)!
    }
    set(value) {
      configuration.setUInt(address: addressNumberOfColumns, value: value)
    }
  }

  public var numberOfRows : UInt16 {
    get {
      return configuration.getUInt16(address: addressNumberOfRows)!
    }
    set(value) {
      configuration.setUInt(address: addressNumberOfRows, value: value)
    }
  }

  // MARK: Private Methods

  internal override func resetToFactoryDefaults() {

    super.resetToFactoryDefaults()
    
    numberOfColumns = 30
    numberOfRows    = 30
    
    saveMemorySpaces()

  }
  
  public override func variableChanged(space: OpenLCBMemorySpace, address: Int) {
    
    if space.space == configuration.space {
      
      switch address {
      default:
        break
      }

    }

  }
  
  internal override func resetReboot() {
    
    super.resetReboot()
    
    networkLayer?.sendIdentifyProducer(sourceNodeId: nodeId, event: .identifyMyTrainsSwitchboardPanels)
    
    networkLayer?.sendIdentifyConsumer(sourceNodeId: nodeId, event: .nodeIsASwitchboardPanel)
    
    var payload = layoutNodeId.bigEndianData
    payload.removeFirst(2)
    
    networkLayer?.sendWellKnownEvent(sourceNodeId: nodeId, eventId: .nodeIsASwitchboardPanel, payload: payload)

  }

 // MARK: Public Methods
  
  public override func start() {
    super.start()
  }
  
  public override func stop() {
    super.stop()
  }

  // MARK: OpenLCBNetworkLayerDelegate Methods
  
  public override func openLCBMessageReceived(message: OpenLCBMessage) {
    
    super.openLCBMessageReceived(message: message)
    
    switch message.messageTypeIndicator {
     
    case .identifyProducer:
      
      if let eventId = message.eventId {
        
        if let event = OpenLCBWellKnownEvent(rawValue: eventId) {
          
          switch event {
            
          case .nodeIsASwitchboardPanel:
            
            networkLayer?.sendProducerIdentified(sourceNodeId: nodeId, wellKnownEvent: .nodeIsASwitchboardPanel, validity: .valid)
            
          default:
            break
          }
          
        }
        
      }

   case .identifyConsumer:
      
      if let eventId = message.eventId {
        
        if let event = OpenLCBWellKnownEvent(rawValue: eventId) {
          
          switch event {
            
          case .identifyMyTrainsSwitchboardPanels:
            
            networkLayer?.sendConsumerIdentified(sourceNodeId: nodeId, wellKnownEvent: .identifyMyTrainsSwitchboardPanels, validity: .valid)
            
          default:
            break
          }
          
        }
        
      }

    case .producerConsumerEventReport:
      
      if let eventId = message.eventId {
        
        if let event = OpenLCBWellKnownEvent(rawValue: eventId) {
          
          switch event {
            
          case .identifyMyTrainsSwitchboardPanels:
            
            var payload = layoutNodeId.bigEndianData
            payload.removeFirst(2)
            
            networkLayer?.sendWellKnownEvent(sourceNodeId: nodeId, eventId: .nodeIsASwitchboardPanel, payload: payload)

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
