//
//  OpenLCBProgrammerToolNode.swift
//  MyTrains
//
//  Created by Paul Willmott on 01/08/2023.
//

import Foundation

public class OpenLCBProgrammerToolNode : OpenLCBNodeVirtual {
  
  // MARK: Constructors
  
  public override init(nodeId:UInt64) {
    
    self.programmerToolId = Int(nodeId & 0xff)

    super.init(nodeId: nodeId)

    virtualNodeType = MyTrainsVirtualNodeType.programmerToolNode
    
    isDatagramProtocolSupported = true

    if !memorySpacesInitialized {
      resetToFactoryDefaults()
    }

  }
  
  // MARK: Private Properties
  
  private var programmingTracks : [UInt64:String] = [:]
  
  private var dccTrainNodes : [UInt64:String] = [:]
  
  private var _delegate : OpenLCBProgrammerToolDelegate?
  
  // MARK: Public Properties
  
  public var programmerToolId : Int
  
  public var delegate : OpenLCBProgrammerToolDelegate? {
    get {
      return _delegate
    }
    set(value) {
      _delegate = value
      resetReboot()
    }
  }
  
  // MARK: Private Methods
  
  internal override func resetToFactoryDefaults() {

    acdiManufacturerSpaceVersion = 4
    
    manufacturerName    = virtualNodeType.manufacturerName
    nodeModelName       = virtualNodeType.name
    nodeHardwareVersion = "\(Bundle.main.releaseVersionNumberPretty)"
    nodeSoftwareVersion = "\(Bundle.main.releaseVersionNumberPretty)"

    acdiUserSpaceVersion = 2
    
    userNodeName        = ""
    userNodeDescription = ""
    
    saveMemorySpaces()
    
  }
  
  internal override func resetReboot() {
    programmingTracks = [0:"Programming on the Mainline"]
    networkLayer?.sendIdentifyProducer(sourceNodeId: nodeId, event: .nodeIsADCCProgrammingTrack)
    dccTrainNodes = [:]
    networkLayer?.sendIdentifyProducer(sourceNodeId: nodeId, event: .trainSearchDCCShortAddress)
    networkLayer?.sendIdentifyProducer(sourceNodeId: nodeId, event: .trainSearchDCCLongAddress)
  }

  // MARK: Public Methods
  
  // MARK: OpenLCBNetworkLayerDelegate Methods

  public override func openLCBMessageReceived(message: OpenLCBMessage) {
    
    super.openLCBMessageReceived(message: message)
  
    switch message.messageTypeIndicator {
    
    case .simpleNodeIdentInfoReply:
      
      if let _ = programmingTracks[message.sourceNodeId!] {
        
        let node = OpenLCBNode(nodeId: message.sourceNodeId!)
        
        node.encodedNodeInformation = message.payload
        
        programmingTracks[node.nodeId] = node.userNodeName
        
        _delegate?.programmingTracksUpdated?(programmerTool: self, programmingTracks: programmingTracks)
        
      }

      if let _ = dccTrainNodes[message.sourceNodeId!] {
        
        let node = OpenLCBNode(nodeId: message.sourceNodeId!)
        
        node.encodedNodeInformation = message.payload
        
        dccTrainNodes[node.nodeId] = node.userNodeName
        
        _delegate?.dccTrainsUpdated?(programmerTool: self, dccTrainNodes: dccTrainNodes)
      }

    case .producerIdentifiedAsCurrentlyValid, .producerIdentifiedAsCurrentlyInvalid, .producerIdentifiedWithValidityUnknown:
      
      if let event = OpenLCBWellKnownEvent(rawValue: message.eventId!) {
        
        switch event {
          
        case .nodeIsADCCProgrammingTrack:
          
          programmingTracks[message.sourceNodeId!] = ""
          
          networkLayer?.sendSimpleNodeInformationRequest(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!)
        
        case .trainSearchDCCShortAddress, .trainSearchDCCLongAddress:
          
          dccTrainNodes[message.sourceNodeId!] = ""
          
          networkLayer?.sendSimpleNodeInformationRequest(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!)

        default:
          break
        }
        
      }
      
    default:
      break
    }
    
  }

}
