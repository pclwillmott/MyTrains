//
//  LayoutNode.swift
//  MyTrains
//
//  Created by Paul Willmott on 11/01/2024.
//

import Foundation
import AppKit

public class LayoutNode : OpenLCBNodeVirtual {
  
  // MARK: Constructors & Destructors
  
  public override init(nodeId:UInt64) {
    
    super.init(nodeId: nodeId)
    
    var configurationSize = 0
    
    initSpaceAddress(&addressScale, 1, &configurationSize)
    initSpaceAddress(&addressLayoutState, 1, &configurationSize)
    initSpaceAddress(&addressCountryCode, 2, &configurationSize)
    initSpaceAddress(&addressUsesMultipleTrackGauges, 1, &configurationSize)
    initSpaceAddress(&addressDefaultTrackGuage, 1, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintType0, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintValue0, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintType1, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintValue1, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintType2, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintValue2, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintType3, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintValue3, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintType4, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintValue4, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintType5, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintValue5, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintType6, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintValue6, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintType7, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintValue7, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintType8, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintValue8, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintType9, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintValue9, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintType10, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintValue10, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintType11, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintValue11, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintType12, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintValue12, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintType13, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintValue13, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintType14, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintValue14, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintType15, 2, &configurationSize)
    initSpaceAddress(&addressSpeedConstraintValue15, 2, &configurationSize)

    configuration = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, defaultMemorySize: configurationSize, isReadOnly: false, description: "")
    
    if let configuration {
      
      virtualNodeType = .layoutNode
      
      eventsConsumed = [
      ]
      
      eventsProduced = [
        OpenLCBWellKnownEvent.nodeIsAMyTrainsLayout.rawValue,
      ]
      
      eventsToSendAtStartup = [
        OpenLCBWellKnownEvent.nodeIsAMyTrainsLayout.rawValue,
      ]
      
      configuration.delegate = self
      
      memorySpaces[configuration.space] = configuration
      
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressScale)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressLayoutState)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressCountryCode)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressUsesMultipleTrackGauges)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressDefaultTrackGuage)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintType0)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintValue0)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintType1)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintValue1)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintType2)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintValue2)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintType3)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintValue3)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintType4)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintValue4)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintType5)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintValue5)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintType6)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintValue6)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintType7)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintValue7)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintType8)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintValue8)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintType9)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintValue9)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintType10)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintValue10)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintType11)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintValue11)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintType12)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintValue12)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintType13)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintValue13)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintType14)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintValue14)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintType15)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSpeedConstraintValue15)
      
      configuration.registerUnitConversion(address: addressSpeedConstraintValue0, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintValue1, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintValue2, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintValue3, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintValue4, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintValue5, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintValue6, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintValue7, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintValue8, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintValue9, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintValue10, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintValue11, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintValue12, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintValue13, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintValue14, unitConversionType: .scaleSpeed2)
      configuration.registerUnitConversion(address: addressSpeedConstraintValue15, unitConversionType: .scaleSpeed2)
      
      if !memorySpacesInitialized {
        resetToFactoryDefaults()
      }
      
      cdiFilename = "MyTrains Layout"
      
    }
    
  }
  
  // MARK: Private Properties
  
  // Configuration variable addresses
  
  internal var addressScale                   = 0
  internal var addressLayoutState             = 0
  internal var addressCountryCode             = 0
  internal var addressUsesMultipleTrackGauges = 0
  internal var addressDefaultTrackGuage       = 0
  internal var addressSpeedConstraintType0    = 0
  internal var addressSpeedConstraintValue0   = 0
  internal var addressSpeedConstraintType1    = 0
  internal var addressSpeedConstraintValue1   = 0
  internal var addressSpeedConstraintType2    = 0
  internal var addressSpeedConstraintValue2   = 0
  internal var addressSpeedConstraintType3    = 0
  internal var addressSpeedConstraintValue3   = 0
  internal var addressSpeedConstraintType4    = 0
  internal var addressSpeedConstraintValue4   = 0
  internal var addressSpeedConstraintType5    = 0
  internal var addressSpeedConstraintValue5   = 0
  internal var addressSpeedConstraintType6    = 0
  internal var addressSpeedConstraintValue6   = 0
  internal var addressSpeedConstraintType7    = 0
  internal var addressSpeedConstraintValue7   = 0
  internal var addressSpeedConstraintType8    = 0
  internal var addressSpeedConstraintValue8   = 0
  internal var addressSpeedConstraintType9    = 0
  internal var addressSpeedConstraintValue9   = 0
  internal var addressSpeedConstraintType10   = 0
  internal var addressSpeedConstraintValue10  = 0
  internal var addressSpeedConstraintType11   = 0
  internal var addressSpeedConstraintValue11  = 0
  internal var addressSpeedConstraintType12   = 0
  internal var addressSpeedConstraintValue12  = 0
  internal var addressSpeedConstraintType13   = 0
  internal var addressSpeedConstraintValue13  = 0
  internal var addressSpeedConstraintType14   = 0
  internal var addressSpeedConstraintValue14  = 0
  internal var addressSpeedConstraintType15   = 0
  internal var addressSpeedConstraintValue15  = 0

  // MARK: Public Properties
  
  public var scale : Scale {
    get {
      return Scale(rawValue: configuration!.getUInt8(address: addressScale)!)!
    }
    set(value) {
      configuration!.setUInt(address: addressScale, value: value.rawValue)
      configuration!.save()
    }
  }

  public var layoutState : LayoutState {
    get {
      return LayoutState(rawValue: configuration!.getUInt8(address: addressLayoutState)!)!
    }
    set(value) {
      configuration!.setUInt(address: addressLayoutState, value: value.rawValue)
      configuration!.save()
    }
  }

  public var countryCode : CountryCode {
    get {
      return CountryCode(rawValue: configuration!.getUInt16(address: addressCountryCode)!)!
    }
    set(value) {
      configuration!.setUInt(address: addressCountryCode, value: value.rawValue)
    }
  }

  public var usesMultipleTrackGauges : Bool {
    get {
      return configuration!.getUInt8(address: addressUsesMultipleTrackGauges)! == 1
    }
    set(value) {
      configuration!.setUInt(address: addressUsesMultipleTrackGauges, value: value ? UInt8(1) : UInt8(0))
    }
  }

  public var defaultTrackGuage : TrackGauge {
    get {
      return TrackGauge(rawValue: configuration!.getUInt8(address: addressDefaultTrackGuage)!)!
    }
    set(value) {
      configuration!.setUInt(address: addressDefaultTrackGuage, value: value.rawValue)
    }
  }
  
  public var operationalBlocks : [UInt64:SwitchboardItemNode] = [:]
  
  public var operationalGroups : [UInt64:[SwitchboardItemNode]] = [:]
  
  // MARK: Private Methods

  internal override func resetToFactoryDefaults() {
    
    super.resetToFactoryDefaults()
    
    countryCode = .unitedStates
    scale = .scale1to87dot1
    usesMultipleTrackGauges = false
    defaultTrackGuage = .ho
    
    saveMemorySpaces()
    
  }
  
  internal override func customizeDynamicCDI(cdi:String) -> String {
    var result = cdi
    result = Scale.insertMap(cdi: result)
    result = LayoutState.insertMap(cdi: result)
    result = CountryCode.insertMap(cdi: result)
    result = YesNo.insertMap(cdi: result)
    result = TrackGauge.insertMap(cdi: result)
    result = SpeedConstraintType.insertMap(cdi: result)
    result = result.replacingOccurrences(of: CDI.SCALE_SPEED_UNITS, with: appNode!.unitsScaleSpeed.symbol)
    return result
  }
  
  // MARK: Public Methods
  
  public func linkSwitchboardItems() {
    
    guard let appNode else {
      return
    }
    
    let switchboardItems = appNode.switchboardItemList
    
    let panels = appNode.panelList
    
    // Remove all links
    
    for (_, item) in switchboardItems {
      item.nodeLinks = [SWBNodeLink](repeating: (nil, -1, []), count: 8)
      item.isEliminated = item.isScenic
    }
    
    let lookup : [(dx:Int, dy:Int, point:Int)] = [
      (dx: -1, dy: +1, point: 4),
      (dx:  0, dy: +1, point: 5),
      (dx: +1, dy: +1, point: 6),
      (dx: +1, dy:  0, point: 7),
      (dx: +1, dy: -1, point: 0),
      (dx:  0, dy: -1, point: 1),
      (dx: -1, dy: -1, point: 2),
      (dx: -1, dy:  0, point: 3),
    ]
    
    // Link the nodes
    
    for (_, item1) in switchboardItems {
      
      if item1.isEliminated {
        continue
      }
      
      let x = Int(item1.xPos)
      let y = Int(item1.yPos)
      
      for point1 in item1.itemType.pointsSet(orientation: item1.orientation) {
        
        if item1.nodeLinks[point1].switchboardItem == nil {
          
          let look = lookup[point1]
          
          let test : SwitchboardLocation = (x: x + look.dx, y: y + look.dy)
          
          if test.x >= 0 && test.y >= 0 {
            
            let point2 = look.point
            
            if let panel = panels[item1.panelId], let item2 = panel.findSwitchboardItem(location: test), item2.itemType.pointsSet(orientation: item2.orientation).contains(point2) {
              if item1.trackGauge == item2.trackGauge {
                item1.nodeLinks[point1].switchboardItem = item2
                item1.nodeLinks[point1].connectionPointId = point2
                item2.nodeLinks[point2].switchboardItem = item1
                item2.nodeLinks[point2].connectionPointId = point1
              }
            }

          }
          
        }
        
      }
      
    }
    
    // Eliminate track items linked to turnouts and blocks
    
    for (_, item1) in switchboardItems {
      
      if item1.isEliminated {
        continue
      }
      
      for point1 in item1.itemType.pointsSet(orientation: item1.orientation) {
        var nodeLink = item1.nodeLinks[point1]
        while let node = nodeLink.switchboardItem, node.isTrack {
          let exits = node.exitPoint(entryPoint: nodeLink.connectionPointId)
          let exit = exits[0] // Track items only have one item
          item1.nodeLinks[point1] = exit
          if let item2 = exit.switchboardItem {
            item2.nodeLinks[exit.connectionPointId].switchboardItem = item1
            item2.nodeLinks[exit.connectionPointId].connectionPointId = point1
          }
          node.isEliminated = true
          nodeLink = item1.nodeLinks[point1]
        }

      }
      
    }
    
    // Eliminate track parts that are not connected to a block or a turnout
    
    for (_, item) in switchboardItems {
      if item.isTrack {
        item.isEliminated = true
      }
    }
    
    // Now do inter-panel links
    
    for (_, item1) in switchboardItems {
      if item1.isLink {
        for (_, item2) in switchboardItems {
          if item1.linkId == item2.nodeId && item2.linkId == item1.nodeId {
            let point1 = item1.itemType.points(orientation: item1.orientation)[0]
            let point2 = item2.itemType.points(orientation: item2.orientation)[0]
            let node1 = item1.nodeLinks[point1]
            let node2 = item2.nodeLinks[point2]
            node1.switchboardItem?.nodeLinks[node1.connectionPointId].switchboardItem = node2.switchboardItem
            node1.switchboardItem?.nodeLinks[node1.connectionPointId].connectionPointId = node2.connectionPointId
            node2.switchboardItem?.nodeLinks[node2.connectionPointId].switchboardItem = node1.switchboardItem
            node2.switchboardItem?.nodeLinks[node2.connectionPointId].connectionPointId = node1.connectionPointId
            item1.isEliminated = true
            item2.isEliminated = true
          }
        }
      }
    }
    
    // Create Dictionaries
    
    operationalBlocks.removeAll()
    operationalGroups.removeAll()
    
    for (_, item) in switchboardItems {
      
      if !item.isEliminated {
        operationalBlocks[item.nodeId] = item
      }
      
      if item.groupId != -1 {
        
        if var group = operationalGroups[item.groupId] {
          group.append(item)
          operationalGroups[item.groupId] = group
        }
        else {
          let group : [SwitchboardItemNode] = [item]
          operationalGroups[item.groupId] = group
        }
        
      }
      
    }
    
    for (_, block) in operationalBlocks {
      
      var index : Int = 0
      
      for connection in block.itemType.connections {
        
        let from = (connection.from + Int(block.orientation.rawValue)) % 8
        
        let to = (connection.to + Int(block.orientation.rawValue)) % 8
        
        if let fromNode = block.nodeLinks[from].switchboardItem, let toNode = block.nodeLinks[to].switchboardItem {
          
          var route : SWBRoutePart = (block, from, toNode, block.nodeLinks[to].connectionPointId, index, distance: block.getDimension(routeNumber: index + 1)!, routeDirection: .next)
          
          block.nodeLinks[from].routes.append(route)
          
          if fromNode.isTurnout || fromNode.directionality == .bidirectional {
          
            route = (block, to, fromNode, block.nodeLinks[from].connectionPointId, index, distance: block.getDimension(routeNumber: index + 1)!, routeDirection: .previous)
            
            block.nodeLinks[to].routes.append(route)

          }

        }
        
        index += 1
        
      }
            
    }
    
    findLoops()
    
    /*
    for (_, item) in switchboardItems {
      
      if item.isEliminated {
        continue
      }
      
      debugLog("\(item.itemType.title) \(item.nodeId.toHexDotFormat(numberOfBytes: 6)) \(item.userNodeName)")
      
      for point in item.itemType.pointsSet(orientation: item.orientation) {
        let nodeLink = item.nodeLinks[point]
        if let node = nodeLink.switchboardItem {
          debugLog("  \(point): \(node.nodeId.toHexDotFormat(numberOfBytes: 6)) - \(node.userNodeName)")
        }
      }
       
    }
     
     */
    
  }
  
  public func loopSet(containing:UInt64) -> Set<UInt16> {
    
    var result : Set<UInt16> = []
    
    var index : UInt16 = 0
    
    while index < loopNodes.count {
      if loopNodes[Int(index)].contains(containing) {
        result.insert(index + 1)
      }
      index += 1
    }
    
    return result
    
  }
  
  public func loops(containing:UInt64) -> [Int] {
    
    var result : [Int] = []
    
    var index = 0
    
    while index < loopNodes.count {
      if loopNodes[index].contains(containing) {
        result.append(index)
      }
      index += 1
    }
    
    return result
    
  }
  
  public func populateLoop(comboBox:NSComboBox, startBlockId:UInt64) {
    
    comboBox.removeAllItems()
    for loop in loops(containing: startBlockId) {
      comboBox.addItem(withObjectValue: "\(loop + 1)")
    }
    
  }

  public var loops : [SWBRoute] = []
  
  public var loopLengths : [Double] = []
  
  public var loopNodes : [Set<UInt64>] = []
  
  private var routeSoFar : SWBRoute = []
  
  private var inLoop : Set<UInt64> = []
  
  func findLoopsFrom(startPos:UInt64, connectionPointId:Int, next:SWBRoutePart) -> Bool {
  
    if startPos == next.toSwitchboardItem.nodeId && connectionPointId == next.toConnectionPointId {
      
      var newRoute : SWBRoute = []
      
      for temp in routeSoFar {
        newRoute.append(temp)
      }
      
      loops.append(newRoute)
      
      return true
      
    }
      
    var found = false

    for route in next.toSwitchboardItem.nodeLinks[next.toConnectionPointId].routes {
      if !inLoop.contains(next.toSwitchboardItem.nodeId) {
        inLoop.insert(next.toSwitchboardItem.nodeId)
        routeSoFar.append(route)
        found = findLoopsFrom(startPos: startPos, connectionPointId: connectionPointId, next: route)
        routeSoFar.remove(at: routeSoFar.count - 1)
        inLoop.remove(next.toSwitchboardItem.nodeId)
        if found {
          break
        }
      }
    }

    return found
    
  }
  
  func findLoops() {
  
    var blocks : [SwitchboardItemNode] = []
    
    for (_, block) in operationalBlocks {
      blocks.append(block)
    }
    
    blocks.sort {$0.userNodeName.sortValue < $1.userNodeName.sortValue}
    
    loops.removeAll()
    
    routeSoFar.removeAll()
    
    var found = false
    
    for startBlock in blocks {
      for nodeLink in startBlock.nodeLinks {
        for route in nodeLink.routes {
          routeSoFar.append(route)
          found = findLoopsFrom(startPos: startBlock.nodeId, connectionPointId: route.fromConnectionPointId, next: route)
          routeSoFar.remove(at: routeSoFar.count-1)
          if found {
            break
          }
        }
      }
    }
    
    var numLoop = loops.count
    
    var index = 0
    
    while index < numLoop {
    
    var items : Set<UInt64> = []
    for rp in loops[index] {
      items.insert(rp.fromSwitchboardItem.nodeId)
    }
    
    var index2 = index + 1
    
    while index2 < numLoop {
    
      var items2 : Set<UInt64> = []
      for rp2 in loops[index2] {
        items2.insert(rp2.fromSwitchboardItem.nodeId)
      }
      
      if items == items2 {
        loops.remove(at: index2)
        numLoop -= 1
      }
      else {
        index2 += 1
      }
      
      }
      
      index += 1

    }
    
    loopLengths.removeAll()
    loopNodes.removeAll()
    
    for loop in loops {
      var length : Double = 0.0
      var nodes : Set<UInt64> = []
      for item in loop {
        length += item.distance
        nodes.insert(item.fromSwitchboardItem.nodeId)
      }
      loopLengths.append(length)
      loopNodes.append(nodes)
    }

  }
  
  /*
  public func findRouteFrom(locomotive:Locomotive, origin:SwitchBoardItem, destination:SwitchBoardItem, routeDirection:RouteDirection, routeSoFar: inout Route, inLoop: inout Set<Int>, next:RoutePart) -> Route? {
  
  if next.fromSwitchBoardItem.validLocomotiveTypes.contains(locomotive.locomotiveType) {
  
  if destination == next.toSwitchBoardItem {
  
  let routePart : RoutePart = (
  fromSwitchBoardItem: next.toSwitchBoardItem,
  fromNodeId: next.toNodeId,
  toSwitchBoardItem: next.toSwitchBoardItem,
  toNodeId: next.toNodeId,
  turnoutConnection: 0,
  distance: destination.stopPositionInCM(routeDirection: next.routeDirection),
  routeDirection: next.routeDirection
  )
  
  routeSoFar.append(routePart)
  
  return routeSoFar
  
  }
  
  for routePart in next.toSwitchBoardItem.nodeLinks[next.toNodeId].routes {
  if !inLoop.contains(next.toSwitchBoardItem.primaryKey) {
  if next.toSwitchBoardItem.isTurnout || routePart.routeDirection == routeDirection {
  inLoop.insert(next.toSwitchBoardItem.primaryKey)
  routeSoFar.append(routePart)
  if let temp = findRouteFrom(locomotive: locomotive, origin: origin, destination: destination, routeDirection: routeDirection, routeSoFar: &routeSoFar, inLoop: &inLoop, next: routePart) {
  return temp
  }
  routeSoFar.remove(at: routeSoFar.count-1)
  inLoop.remove(next.toSwitchBoardItem.primaryKey)
  }
  }
  
  }
  
  }
  
  return nil
  
  }
  
  
  
  public func findRoute(locomotive:Locomotive, origin:SwitchBoardItem, originPosition: Double, destination:SwitchBoardItem, routeDirection:RouteDirection) -> Route? {
  
  if origin.validLocomotiveTypes.contains(locomotive.locomotiveType) && destination.validLocomotiveTypes.contains(locomotive.locomotiveType) {
  
  var routeSoFar : Route = []
  
  var inLoop : Set<Int> = []
  
  inLoop.insert(origin.primaryKey)
  
  for nodeLink in origin.nodeLinks {
  
  for routePart in nodeLink.routes {
  
  var newRoutePart = routePart
  
  newRoutePart.distance -= originPosition
  
  routeSoFar.append(newRoutePart)
  
  if let temp = findRouteFrom(locomotive: locomotive, origin: origin, destination: destination, routeDirection: routeDirection, routeSoFar: &routeSoFar, inLoop: &inLoop, next: routePart) {
  return temp
  }
  
  routeSoFar.remove(at: routeSoFar.count-1)
  
  }
  
  }
  
  }
  
  return nil
  
  }

   */
  
}
