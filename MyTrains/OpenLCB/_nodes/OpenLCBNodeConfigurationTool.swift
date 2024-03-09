//
//  OpenLCBNodeConfigurationTool.swift
//  MyTrains
//
//  Created by Paul Willmott on 26/05/2023.
//

import Foundation

public class OpenLCBNodeConfigurationTool : OpenLCBNodeVirtual {
  
  // MARK: Constructors
  
  public override init(nodeId:UInt64) {
    
    super.init(nodeId: nodeId)

    virtualNodeType = MyTrainsVirtualNodeType.configurationToolNode
    
    isDatagramProtocolSupported = true

    isFullProtocolRequired = true
    
    if !memorySpacesInitialized {
      resetToFactoryDefaults()
    }

  }
  
  // MARK: Public Properties
  
  public var delegate : OpenLCBConfigurationToolDelegate?
  
  // MARK: Private Methods
  
  internal override func resetToFactoryDefaults() {
    super.resetToFactoryDefaults()
    saveMemorySpaces()
  }
  
  // MARK: OpenLCBNetworkLayerDelegate Methods

  public override func openLCBMessageReceived(message: OpenLCBMessage) {
    super.openLCBMessageReceived(message: message)
    self.delegate?.openLCBMessageReceived?(message: message)
  }
  
}
