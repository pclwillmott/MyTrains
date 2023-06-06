//
//  OpenLCBNodeRollingStock.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/05/2023.
//

import Foundation

public class OpenLCBNodeRollingStock : OpenLCBNodeVirtual {
  
  // MARK: Constructors
  
  public init(rollingStock:RollingStock) {
    
    let nodeId = 0x0801000d0000 + UInt64(rollingStock.primaryKey)
    
    _rollingStock = rollingStock
    
    super.init(nodeId: nodeId)

    isDatagramProtocolSupported = true
    
    isIdentificationSupported = true
    
    isSimpleNodeInformationProtocolSupported = true
    
    isTractionControlProtocolSupported = true
    
    isSimpleTrainNodeInformationProtocolSupported = true

    if !memorySpacesInitialized {
      resetToFactoryDefaults()
    }
    
  }
  
  // MARK: Private Properties
  
  private var _rollingStock : RollingStock
  
  // MARK: Public Properties
  
  public var rollingStock : RollingStock {
    get {
      return _rollingStock
    }
  }
  
  // MARK: Private Methods
  
  internal override func resetToFactoryDefaults() {
    
    acdiManufacturerSpaceVersion = 4
    
    manufacturerName     = NMRA.manufacturerName(code: _rollingStock.manufacturerId)
    nodeModelName        = _rollingStock.rollingStockName
    nodeHardwareVersion  = ""
    nodeSoftwareVersion  = ""

    acdiUserSpaceVersion = 2
    
    userNodeName         = ""
    userNodeDescription  = ""
    
    saveMemorySpaces()
    
  }
 
  // MARK: Public Methods
  
  // MARK: OpenLCBMemorySpaceDelegate Methods
  
  // MARK: OpenLCBNetworkLayerDelegate Methods
    
}
