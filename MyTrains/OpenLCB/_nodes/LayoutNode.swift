//
//  LayoutNode.swift
//  MyTrains
//
//  Created by Paul Willmott on 11/01/2024.
//

import Foundation

public class LayoutNode : OpenLCBNodeVirtual {
  
  // MARK: Constructors & Destructors
  
  public override init(nodeId:UInt64) {
    
    configuration = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, defaultMemorySize: 2, isReadOnly: false, description: "")
    
    super.init(nodeId: nodeId)
    
    virtualNodeType = .layoutNode

    configuration.delegate = self

    memorySpaces[configuration.space] = configuration

    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressScale)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressLayoutState)

    if !memorySpacesInitialized {
      resetToFactoryDefaults()
    }

    cdiFilename = "MyTrains Layout"
    
    saveMemorySpaces()

  }
  
  // MARK: Private Properties
  
  // Configuration variable addresses
  
  internal let addressScale       : Int =  0
  internal let addressLayoutState : Int =  1

  // MARK: Public Properties
  
  public var configuration : OpenLCBMemorySpace

  public var scale : Scale {
    get {
      return Scale(rawValue: configuration.getUInt8(address: addressScale)!)!
    }
    set(value) {
      configuration.setUInt(address: addressScale, value: value.rawValue)
      configuration.save()
    }
  }

  public var layoutState : LayoutState {
    get {
      return LayoutState(rawValue: configuration.getUInt8(address: addressScale)!)!
    }
    set(value) {
      configuration.setUInt(address: addressLayoutState, value: value.rawValue)
      configuration.save()
    }
  }

  // MARK: Private Methods

  internal override func resetToFactoryDefaults() {
    super.resetToFactoryDefaults()
    saveMemorySpaces()
  }
  
  internal override func resetReboot() {
    
    super.resetReboot()
    
    networkLayer?.sendWellKnownEvent(sourceNodeId: nodeId, eventId: layoutState == .activated ? .myTrainsLayoutActivated : .myTrainsLayoutDeactivated, payload: appNodeId!.bigEndianData)
    
    networkLayer?.sendIdentifyConsumer(sourceNodeId: nodeId, event: .myTrainsLayoutActivated)

    networkLayer?.sendIdentifyConsumer(sourceNodeId: nodeId, event: .myTrainsLayoutDeactivated)

    networkLayer?.sendIdentifyProducer(sourceNodeId: nodeId, event: .identifyMyTrainsLayouts)
    
  }
  
  public override func variableChanged(space: OpenLCBMemorySpace, address: Int) {
    
    if space.space == configuration.space {
      
      switch address {
      case addressLayoutState:
        networkLayer?.sendWellKnownEvent(sourceNodeId: nodeId, eventId: layoutState == .activated ? .myTrainsLayoutActivated : .myTrainsLayoutDeactivated, payload: appNodeId!.bigEndianData)
      default:
        break
      }
      
    }
    
  }
  
  // MARK: OpenLCBNetworkLayerDelegate Methods
  
  public override func openLCBMessageReceived(message: OpenLCBMessage) {
    
    super.openLCBMessageReceived(message: message)
    
    switch message.messageTypeIndicator {
   
    case .identifyProducer:
      
      if let event = OpenLCBWellKnownEvent(rawValue: message.eventId!) {
        
        switch event {
          
        case .myTrainsLayoutActivated:
          
          networkLayer?.sendProducerIdentified(sourceNodeId: nodeId, wellKnownEvent: .myTrainsLayoutActivated, validity: layoutState == .activated ? .valid : .invalid)
          
        case .myTrainsLayoutDeactivated:
          
          networkLayer?.sendProducerIdentified(sourceNodeId: nodeId, wellKnownEvent: .myTrainsLayoutDeactivated, validity: layoutState == .deactivated ? .valid : .invalid)
          
        default:
          break
        }
        
      }

    case .producerConsumerEventReport:
      
      if let event = OpenLCBWellKnownEvent(rawValue: message.eventId!) {
        
        switch event {
        case .identifyMyTrainsLayouts:
          
          networkLayer?.sendWellKnownEvent(sourceNodeId: nodeId, eventId: layoutState == .activated ? .myTrainsLayoutActivated : .myTrainsLayoutDeactivated, payload: appNodeId!.bigEndianData)

        default:
          break
        }
        
      }
      
    default:
      break
    }
  }
  
}
