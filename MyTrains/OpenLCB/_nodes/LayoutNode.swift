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
    
    configuration = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, defaultMemorySize: 1, isReadOnly: false, description: "")
    
    super.init(nodeId: nodeId)
    
    virtualNodeType = .layoutNode

    configuration.delegate = self

    memorySpaces[configuration.space] = configuration

    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressScale)

    if !memorySpacesInitialized {
      resetToFactoryDefaults()
    }

    cdiFilename = "MyTrains Layout"
    
    saveMemorySpaces()

  }
  
  // MARK: Private Properties
  
  // Configuration variable addresses
  
  internal let addressScale : Int =  0

  // MARK: Public Properties
  
  public var configuration : OpenLCBMemorySpace

  public var scale : Scale {
    get {
      return Scale(rawValue: configuration.getUInt8(address: addressScale)!)!
    }
    set(value) {
      configuration.setUInt(address: addressScale, value: value.rawValue)
    }

  }
  
  // MARK: Private Methods

  internal override func resetToFactoryDefaults() {
    super.resetToFactoryDefaults()
    saveMemorySpaces()
  }

}
