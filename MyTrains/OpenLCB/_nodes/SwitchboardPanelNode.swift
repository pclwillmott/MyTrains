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
    initSpaceAddress(&addressPanelIsVisible, 1, &configurationSize)

    configuration = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, defaultMemorySize: configurationSize, isReadOnly: false, description: "")
    
    if let configuration {
      
      if layoutNodeId != 0 {
        self.layoutNodeId = layoutNodeId
      }
      
      virtualNodeType = MyTrainsVirtualNodeType.switchboardPanelNode
      
      eventsConsumed = [
      ]
      
      eventsProduced = [
      ]
      
      configuration.delegate = self
      
      memorySpaces[configuration.space] = configuration
      
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressNumberOfColumns)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressNumberOfRows)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressPanelIsVisible)

      if !memorySpacesInitialized {
        resetToFactoryDefaults()
      }
      
    }
    
    #if DEBUG
    addInit()
    #endif
    
  }
  
  #if DEBUG
  deinit {
    addDeinit()
  }
  #endif

  // MARK: Private Properties

  // Configuration varaible addresses
  
  internal var addressNumberOfColumns = 0
  internal var addressNumberOfRows    = 0
  internal var addressPanelIsVisible  = 0
  
  // MARK: Public Properties
  
  public override var isPassiveNode: Bool {
    return true
  }
  
  public var switchboardItems : [UInt64:SwitchboardItemNode] {
    
    var result : [UInt64:SwitchboardItemNode] = [:]
    
    guard let appNode else {
      return result
    }
    
    for (key, item) in appNode.switchboardItemList {
      if item.panelId == nodeId {
        result[key] = item
      }
    }
    
    return result
    
  }
  
  public var switchboardBlocks : [UInt64:SwitchboardItemNode] {
    
    var result : [UInt64:SwitchboardItemNode] = [:]
    
    for (key, item) in switchboardItems {
      if item.itemType.isGroup {
        result[key] = item
      }
    }
    
    return result
    
  }
  
  public func findSwitchboardItem(location:SwitchBoardLocation) -> SwitchboardItemNode? {
    for (_, item) in switchboardItems {
      if item.location == location {
        return item
      }
    }
    return nil
  }
  
  public func bounds() -> NSRect? {
    var minX : UInt16?
    var maxX : UInt16?
    var minY : UInt16?
    var maxY : UInt16?
    for (_, item) in appNode!.switchboardItemList {
      if minX == nil || item.xPos < minX! {
        minX = item.xPos
      }
      if maxX == nil || item.xPos > maxX! {
        maxX = item.xPos
      }
      if minY == nil || item.yPos < minY! {
        minY = item.yPos
      }
      if maxY == nil || item.yPos > maxY! {
        maxY = item.yPos
      }
    }
    if let minX, let maxX, let minY, let maxY {
      return NSRect(x: 0.0, y: 0.0, width: CGFloat(maxX - minX + 1), height: CGFloat(maxY - minY + 1))
    }
    return nil
  }

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

  public var panelIsVisible : Bool {
    get {
      return configuration!.getUInt8(address: addressPanelIsVisible)! != 0
    }
    set(value) {
      configuration!.setUInt(address: addressPanelIsVisible, value: value ? UInt8(1) : UInt8(0))
      saveMemorySpaces()
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
  
  // MARK: Public Methods
  
  public func setValue(property:PanelProperty, string:String) {
    
    switch property {
    case .panelName:
      userNodeName = string
    case .panelDescription:
      userNodeDescription = string
    case .numberOfRows:
      numberOfRows = UInt16(string)!
    case .numberOfColumns:
      numberOfColumns = UInt16(string)!
    default:
      break
    }
    
  }
  
}
