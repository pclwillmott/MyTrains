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
    
    configuration = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, defaultMemorySize: 4, isReadOnly: false, description: "")
    
    super.init(nodeId: nodeId)
    
    virtualNodeType = .layoutNode

    configuration.delegate = self

    memorySpaces[configuration.space] = configuration

    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressScale)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressLayoutState)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressCountryCode)

    if !memorySpacesInitialized {
      resetToFactoryDefaults()
    }

    cdiFilename = "MyTrains Layout"
    
  }
  
  // MARK: Private Properties
  
  // Configuration variable addresses
  
  internal let addressScale       : Int =  0
  internal let addressLayoutState : Int =  1
  internal let addressCountryCode : Int =  2

  // MARK: Public Properties
  
  public var configuration : OpenLCBMemorySpace

  public var countryCode : CountryCode {
    get {
      return CountryCode(rawValue: configuration.getUInt16(address: addressCountryCode)!)!
    }
    set(value) {
      configuration.setUInt(address: addressCountryCode, value: value.rawValue)
    }
  }

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
      return LayoutState(rawValue: configuration.getUInt8(address: addressLayoutState)!)!
    }
    set(value) {
      configuration.setUInt(address: addressLayoutState, value: value.rawValue)
      configuration.save()
    }
  }

  // MARK: Private Methods

  internal override func resetToFactoryDefaults() {
    super.resetToFactoryDefaults()
    countryCode = .unitedStates
    saveMemorySpaces()
  }
  
  internal override func resetReboot() {
    
    super.resetReboot()
    
    networkLayer?.sendIdentifyConsumer(sourceNodeId: nodeId, event: .myTrainsLayoutActivated)

    networkLayer?.sendIdentifyConsumer(sourceNodeId: nodeId, event: .myTrainsLayoutDeactivated)

    networkLayer?.sendIdentifyConsumer(sourceNodeId: nodeId, event: .myTrainsLayoutDeleted)

    networkLayer?.sendIdentifyProducer(sourceNodeId: nodeId, event: .identifyMyTrainsLayouts)
    
    networkLayer?.sendWellKnownEvent(sourceNodeId: nodeId, eventId: layoutState == .activated ? .myTrainsLayoutActivated : .myTrainsLayoutDeactivated, payload: appNodeId!.bigEndianData)
    
  }
  
  public override func variableChanged(space: OpenLCBMemorySpace, address: Int) {
    
    guard let networkLayer else {
      return
    }
    
    if space.space == configuration.space {
      
      switch address {
      case addressLayoutState:
        if layoutState == .activated {
          networkLayer.sendWellKnownEvent(sourceNodeId: nodeId, eventId: .myTrainsLayoutActivated, payload: appNodeId!.bigEndianData)
        }
        else if networkLayer.layoutNodeId == nodeId {
          networkLayer.sendWellKnownEvent(sourceNodeId: nodeId, eventId: .myTrainsLayoutDeactivated, payload: appNodeId!.bigEndianData)
        }
      default:
        break
      }
      
    }
    
  }
  
  override internal func willDelete() {
    
    if layoutState == .activated {
      networkLayer?.sendWellKnownEvent(sourceNodeId: nodeId, eventId: .myTrainsLayoutDeactivated, payload: appNodeId!.bigEndianData)
    }
    
    networkLayer?.sendWellKnownEvent(sourceNodeId: nodeId, eventId: .myTrainsLayoutDeleted)

  }

  internal override func customizeDynamicCDI(cdi:String) -> String {
    var result = cdi
    result = Scale.insertMap(cdi: result)
    result = LayoutState.insertMap(cdi: result)
    return result
  }

  // MARK: OpenLCBNetworkLayerDelegate Methods
  
  public override func openLCBMessageReceived(message: OpenLCBMessage) {
    
    super.openLCBMessageReceived(message: message)
    
    switch message.messageTypeIndicator {
   
    case .identifyConsumer:
      
      if let event = OpenLCBWellKnownEvent(rawValue: message.eventId!) {
        
        switch event {
          
        case .identifyMyTrainsLayouts:
          
          networkLayer?.sendConsumerIdentified(sourceNodeId: nodeId, wellKnownEvent: .identifyMyTrainsLayouts, validity: .valid)
          
        default:
          break
        }
        
      }

    case .identifyProducer:
      
      if let event = OpenLCBWellKnownEvent(rawValue: message.eventId!) {
        
        switch event {
          
        case .myTrainsLayoutDeleted:
          
          networkLayer?.sendProducerIdentified(sourceNodeId: nodeId, wellKnownEvent: .myTrainsLayoutDeleted, validity: .invalid)
          
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
