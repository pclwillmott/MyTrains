//
//  Layout.swift
//  MyTrains
//
//  Created by Paul Willmott on 27/12/2021.
//

import Foundation

@objc public protocol LayoutDelegate {
  @objc optional func needsDisplay()
}

public class Layout : EditorObject {
  
  // MARK: Constructors
  
  init(reader:SqliteDataReader) {
    
    super.init(primaryKey: -1)
    
    decode(sqliteDataReader: reader)
    
    revertToSaved()
    
  }
  
  init() {
    
    super.init(primaryKey: -1)
    
    for index in 0...15 {
      let panel = SwitchBoardPanel(layoutId: -1, panelId: index, panelName: "Panel #\(index + 1)", numberOfColumns: 20, numberOfRows: 20)
      switchBoardPanels.append(panel)
    }

  }
  
  // MARK: Private Properties
  
  private var delegates : [Int:LayoutDelegate] = [:]
  
  private var nextDelegateId = 1
  
  // MARK: Public Properties
  
  public func addDelegate(delegate:LayoutDelegate) -> Int {
    let id = nextDelegateId
    nextDelegateId += 1
    delegates[id] = delegate
    return id
  }
  
  public func needsDisplay() {
    for (_, delegate) in delegates {
      delegate.needsDisplay?()
    }
  }
  
  public func removeDelegate(delegateId:Int) {
    delegates[delegateId] = nil
  }
  
  override public func displayString() -> String {
    return layoutName
  }
  
  public var networks : [Network] {
    get {
      var networks : [Network] = []
      for kv in networkController.networks {
        let network = kv.value
        if network.layoutId == self.primaryKey {
          networks.append(network)
        }
        networks.sort {
          $0.networkName < $1.networkName
        }
      }
      return networks
    }
  }
  
  public var layoutName : String = "" {
    didSet {
      modified = true
    }
  }
  
  public var layoutDescription : String = "" {
    didSet {
      modified = true
    }
  }
  
  public var scale : Double = 1.0 {
    didSet {
      modified = true
    }
  }
  
  public var switchBoardItems : [Int:SwitchBoardItem] = [:] {
    didSet {
      modified = true
    }
  }
  
  public var switchBoardPanels : [SwitchBoardPanel] = [] {
    didSet {
      modified = true
    }
  }
  
  public var switchBoardBlocks : [Int:SwitchBoardItem] {
    get {
      var result : [Int:SwitchBoardItem] = [:]
      for (_, item) in switchBoardItems {
        if item.isBlock || item.isTurnout {
          result[item.primaryKey] = item
        }
      }
      return result
    }
  }
  
  public var switchBoardTurnouts : [Int:SwitchBoardItem] {
    get {
      var result : [Int:SwitchBoardItem] = [:]
      for (_, item) in switchBoardItems {
        if item.isTurnout {
          result[item.primaryKey] = item
        }
      }
      return result
    }
  }
  
  public var operationalBlocks : [Int:SwitchBoardItem] = [:]
  
  public var operationalGroups : [Int:[SwitchBoardItem]] = [:]
  
  public var operationalTurnouts : [Int:TurnoutSwitch] = [:]
  
  // MARK: Public Methods
  
  public func nextItemName(switchBoardItem:SwitchBoardItem) -> String {

    var prefix : String = ""
    
    if switchBoardItem.isBlock {
      prefix = "B"
    }
    else if switchBoardItem.isLink {
      prefix = "L"
    }
    else if switchBoardItem.isTurnout {
      prefix = "T"
    }
    else {
      return ""
    }
    
    var found = false
    
    var index : Int = 0
    
    var test : String = ""
    
    repeat {
      found = false
      index += 1
      test = "\(prefix)\(index)"
      for (_, item) in switchBoardItems {
        if item.blockName.trimmingCharacters(in: .whitespacesAndNewlines) == test {
          found = true
          break
        }
      }
    } while found
    
    return test
    
  }
  
  public func linkSwitchBoardItems() {
    
    // Remove all links
    
    for (_, item) in switchBoardItems {
      for index in 0...7 {
        item.nodeLinks[index] = (switchBoardItem: nil, nodeId: -1, routes: [])
      }
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
    
    for (_, item1) in switchBoardItems {
      
      if item1.isEliminated {
        continue
      }
      
      let x = item1.location.x
      let y = item1.location.y
      
      for point1 in item1.itemPartType.pointsSet(orientation: item1.orientation) {
        
        if item1.nodeLinks[point1].switchBoardItem == nil {
          
          let look = lookup[point1]
          
          let test : SwitchBoardLocation = (x: x + look.dx, y: y + look.dy)
          
          if test.x >= 0 && test.y >= 0 {
            
            let key = SwitchBoardItem.createKey(panelId: item1.panelId, location: test, nextAction: .noAction)
            
            let point2 = look.point
            
            if let item2 = switchBoardItems[key], item2.itemPartType.pointsSet(orientation: item2.orientation).contains(point2) {
              if item1.trackGauge == item2.trackGauge {
                item1.nodeLinks[point1].switchBoardItem = item2
                item1.nodeLinks[point1].nodeId = point2
                item2.nodeLinks[point2].switchBoardItem = item1
                item2.nodeLinks[point2].nodeId = point1
              }
            }

          }
          
        }
        
      }
      
    }
    
    // Eliminate track items linked to turnouts and blocks
    
    for (_, item1) in switchBoardItems {
      
      if item1.isEliminated {
        continue
      }
      
      for point1 in item1.itemPartType.pointsSet(orientation: item1.orientation) {
        var nodeLink = item1.nodeLinks[point1]
        while let node = nodeLink.switchBoardItem, node.isTrack {
          let exits = node.exitPoint(entryPoint: nodeLink.nodeId)
          let exit = exits[0] // Track items only have one item
          item1.nodeLinks[point1] = exit
          if let item2 = exit.switchBoardItem {
            item2.nodeLinks[exit.nodeId].switchBoardItem = item1
            item2.nodeLinks[exit.nodeId].nodeId = point1
          }
          node.isEliminated = true
          nodeLink = item1.nodeLinks[point1]
        }

      }
      
    }
    
    // Eliminate track parts that are not connected to a block or a turnout
    
    for (_, item) in switchBoardItems {
      if item.isTrack {
        item.isEliminated = true
      }
    }
    
    // Now do inter-panel links
    
    for (_, item1) in switchBoardItems {
      if item1.isLink {
        for (_, item2) in switchBoardItems {
          if item1.linkItem == item2.primaryKey && item2.linkItem == item1.primaryKey {
            let point1 = item1.itemPartType.points(orientation: item1.orientation)[0]
            let point2 = item2.itemPartType.points(orientation: item2.orientation)[0]
            let node1 = item1.nodeLinks[point1]
            let node2 = item2.nodeLinks[point2]
            node1.switchBoardItem?.nodeLinks[node1.nodeId].switchBoardItem = node2.switchBoardItem
            node1.switchBoardItem?.nodeLinks[node1.nodeId].nodeId = node2.nodeId
            node2.switchBoardItem?.nodeLinks[node2.nodeId].switchBoardItem = node1.switchBoardItem
            node2.switchBoardItem?.nodeLinks[node2.nodeId].nodeId = node1.nodeId
            item1.isEliminated = true
            item2.isEliminated = true
          }
        }
      }
    }
    
    // Create Dictionaries
    
    operationalBlocks.removeAll()
    operationalGroups.removeAll()
    
    for (_, item) in switchBoardItems {
      
      if !item.isEliminated {
        operationalBlocks[item.primaryKey] = item
      }
      
      if item.groupId != -1 {
        
        if var group = operationalGroups[item.groupId] {
          group.append(item)
          operationalGroups[item.groupId] = group
        }
        else {
          var group : [SwitchBoardItem] = [item]
          operationalGroups[item.groupId] = group
        }
        
      }
      
    }
    
    for (_, block) in operationalBlocks {
      
      for connection in block.itemPartType.connections {
        
        let from = (connection.from + block.orientation.rawValue) % 8
        
        let to = (connection.to + block.orientation.rawValue) % 8
        
        if let fromNode = block.nodeLinks[from].switchBoardItem, let toNode = block.nodeLinks[to].switchBoardItem {
          
          var route : RoutePart = (block, from, toNode, block.nodeLinks[to].nodeId, connection.switchSettings)
          
          block.nodeLinks[from].routes.append(route)
          
          route = (block, to, fromNode, block.nodeLinks[from].nodeId, connection.switchSettings)
          
          block.nodeLinks[to].routes.append(route)

        }
        
      }
      /*
      print("\(block.blockName)")
      
      var index = 0
      for node in block.nodeLinks {
        
        if let item = node.switchBoardItem {
          for route in node.routes {
            print("  \(route.fromSwitchBoardItem.blockName) \(route.fromNodeId)  -> \(route.toSwitchBoardItem.blockName) \(route.toNodeId) \(route.switchSettings)")
          }
        }
        index += 1
      }
      */
      // Find Loops
      
    }
    
    findLoops()
    
    for loop in loops {
      for routePart in loop {
        print("\(routePart.fromSwitchBoardItem.blockName)", terminator: " ")
      }
      print("\n")
    }
    
//    print(loops)
    
    /*
    for (_, item) in switchBoardItems {
      
      if item.isEliminated {
        continue
      }
      
      print("\(item.itemPartType.partName) \(item.primaryKey) \(item.blockName)")
      
      for point in item.itemPartType.pointsSet(orientation: item.orientation) {
        let nodeLink = item.nodeLinks[point]
        if let node = nodeLink.switchBoardItem {
          print("  \(point): \(node.primaryKey) - \(nodeLink.nodeId)")
        }
      }
       
    }
    */
  }
  
  public typealias Route = [RoutePart]
  
  public var loops : [Route] = []
  
  public var loopNames : [String] = []
  
  private var routeSoFar : Route = []
  
  private var inLoop : Set<Int> = []
  
  func findLoopsFrom(startPos:Int, nodeId:Int, next:RoutePart) -> Bool {
    
    if startPos == next.toSwitchBoardItem.primaryKey && nodeId == next.toNodeId {
      var newRoute : Route = []
      for temp in routeSoFar {
        newRoute.append(temp)
      }
      loops.append(newRoute)
      return true
    }
    
    var found = false
    
    for route in next.toSwitchBoardItem.nodeLinks[next.toNodeId].routes {
      if !inLoop.contains(next.toSwitchBoardItem.primaryKey) {
        inLoop.insert(next.toSwitchBoardItem.primaryKey)
        routeSoFar.append(route)
        found = findLoopsFrom(startPos: startPos, nodeId: nodeId, next: route)
        routeSoFar.remove(at: routeSoFar.count-1)
        inLoop.remove(next.toSwitchBoardItem.primaryKey)
        if found {
          break
        }
      }
    }
    
    return found

  }
  
  func findLoops() {
    
    loops.removeAll()
    
    routeSoFar.removeAll()
    
    var found = false
    
    for (_, startBlock ) in operationalBlocks {
      for nodeLink in startBlock.nodeLinks {
        for route in nodeLink.routes {
          routeSoFar.append(route)
          found = findLoopsFrom(startPos: startBlock.primaryKey, nodeId: route.fromNodeId, next: route)
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
      
      var items : Set<Int> = []
      for rp in loops[index] {
        items.insert(rp.fromSwitchBoardItem.primaryKey)
      }
      
      var index2 = index + 1
      
      while index2 < numLoop {
        
        var items2 : Set<Int> = []
        for rp2 in loops[index2] {
          items2.insert(rp2.fromSwitchBoardItem.primaryKey)
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
    
    loopNames.removeAll()
    
    for loop in loops {
      var name = ""
      for item in loop {
        name += "\(item.fromSwitchBoardItem.blockName) "
      }
      loopNames.append(name.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
  }
  
  public func links(item:SwitchBoardItem) -> [Int:SwitchBoardItem] {
    var result : [Int:SwitchBoardItem] = [:]
    for (_, value) in switchBoardItems {
      if value.nextAction == .noAction && value.itemPartType == .link && item.primaryKey != value.primaryKey {
        result[value.primaryKey] = value
      }
    }
    return result
  }
  
  public func revertToSaved() {
    switchBoardPanels = _switchBoardPanels
    switchBoardItems = _switchBoardItems
    linkSwitchBoardItems()
  }
  
  // MARK: Database Methods
  
  private var _switchBoardItems : [Int:SwitchBoardItem] {
    
    get {
    
      let conn = Database.getConnection()
      
      let shouldClose = conn.state != .Open
       
      if shouldClose {
        _ = conn.open()
      }
       
      let cmd = conn.createCommand()
       
      cmd.commandText = "SELECT \(SwitchBoardItem.columnNames) FROM [\(TABLE.SWITCHBOARD_ITEM)] WHERE [\(SWITCHBOARD_ITEM.LAYOUT_ID)] = \(primaryKey) ORDER BY [\(SWITCHBOARD_ITEM.SWITCHBOARD_ITEM_ID)]"

      var result : [Int:SwitchBoardItem] = [:]
      
      if let reader = cmd.executeReader() {
           
        while reader.read() {
          let switchBoardItem = SwitchBoardItem(reader: reader)
          result[switchBoardItem.key] = switchBoardItem
        }
           
        reader.close()
           
      }
      
      if shouldClose {
        conn.close()
      }

      return result
      
    }
    
  }

  private var _switchBoardPanels : [SwitchBoardPanel] {
    
    get {
    
      let conn = Database.getConnection()
      
      let shouldClose = conn.state != .Open
       
      if shouldClose {
        _ = conn.open()
      }
       
      let cmd = conn.createCommand()
       
      cmd.commandText = "SELECT \(SwitchBoardPanel.columnNames) FROM [\(TABLE.SWITCHBOARD_PANEL)] WHERE [\(SWITCHBOARD_PANEL.LAYOUT_ID)] = \(primaryKey) ORDER BY [\(SWITCHBOARD_PANEL.PANEL_ID)]"

      var result : [SwitchBoardPanel] = []
      
      if let reader = cmd.executeReader() {
           
        while reader.read() {
          let switchBoardPanel = SwitchBoardPanel(reader: reader)
          result.append(switchBoardPanel)
        }
           
        reader.close()
           
      }
      
      if shouldClose {
        conn.close()
      }

      return result
      
    }
    
  }
  
  private func decode(sqliteDataReader:SqliteDataReader?) {
    
    if let reader = sqliteDataReader {
      
      primaryKey = reader.getInt(index: 0)!
      
      if !reader.isDBNull(index: 1) {
        layoutName = reader.getString(index: 1)!
      }
      
      if !reader.isDBNull(index: 2) {
        layoutDescription = reader.getString(index: 2)!
      }
      
      if !reader.isDBNull(index: 3) {
        scale = reader.getDouble(index: 3)!
      }

    }
    
    modified = false
    
  }

  public func save() {
    
    if modified {
      
      var sql = ""
      
      if primaryKey == -1 {
        sql = "INSERT INTO [\(TABLE.LAYOUT)] (" +
        "[\(LAYOUT.LAYOUT_ID)], " +
        "[\(LAYOUT.LAYOUT_NAME)], " +
        "[\(LAYOUT.LAYOUT_DESCRIPTION)]," +
        "[\(LAYOUT.LAYOUT_SCALE)]" +
        ") VALUES (" +
        "@\(LAYOUT.LAYOUT_ID), " +
        "@\(LAYOUT.LAYOUT_NAME), " +
        "@\(LAYOUT.LAYOUT_DESCRIPTION)," +
        "@\(LAYOUT.LAYOUT_SCALE)" +
        ")"
        primaryKey = Database.nextCode(tableName: TABLE.LAYOUT, primaryKey: LAYOUT.LAYOUT_ID)!
      }
      else {
        sql = "UPDATE [\(TABLE.LAYOUT)] SET " +
        "[\(LAYOUT.LAYOUT_NAME)] = @\(LAYOUT.LAYOUT_NAME), " +
        "[\(LAYOUT.LAYOUT_DESCRIPTION)] = @\(LAYOUT.LAYOUT_DESCRIPTION), " +
        "[\(LAYOUT.LAYOUT_SCALE)] = @\(LAYOUT.LAYOUT_SCALE) " +
        "WHERE [\(LAYOUT.LAYOUT_ID)] = @\(LAYOUT.LAYOUT_ID)"
      }

      let conn = Database.getConnection()
      
      let shouldClose = conn.state != .Open
       
      if shouldClose {
         _ = conn.open()
      }
       
      let cmd = conn.createCommand()
       
      cmd.commandText = sql
      
      cmd.parameters.addWithValue(key: "@\(LAYOUT.LAYOUT_ID)", value: primaryKey)
      cmd.parameters.addWithValue(key: "@\(LAYOUT.LAYOUT_NAME)", value: layoutName)
      cmd.parameters.addWithValue(key: "@\(LAYOUT.LAYOUT_DESCRIPTION)", value: description)
      cmd.parameters.addWithValue(key: "@\(LAYOUT.LAYOUT_SCALE)", value: scale)

      _ = cmd.executeNonQuery()

      if shouldClose {
        conn.close()
      }
      
      modified = false
      
    }
    
    for panel in switchBoardPanels {
      panel.layoutId = self.primaryKey
      panel.save()
    }
    
    for kv in switchBoardItems {
      let item = kv.value
      item.layoutId = primaryKey
      if item.itemPartType == .none {
        if item.isDatabaseItem {
          SwitchBoardItem.delete(primaryKey: item.primaryKey)
        }
        switchBoardItems[item.key] = nil
      }
      else {
        if item.nextAction == .delete {
          SwitchBoardItem.delete(primaryKey: item.primaryKey)
          switchBoardItems[item.key] = nil
        }
        else {
          item.save()
        }
      }
    }
    
    linkSwitchBoardItems()

  }

  // MARK: Class Properties
  
  public static var columnNames : String {
    get {
      return
        "[\(LAYOUT.LAYOUT_ID)], " +
        "[\(LAYOUT.LAYOUT_NAME)], " +
        "[\(LAYOUT.LAYOUT_DESCRIPTION)], " +
        "[\(LAYOUT.LAYOUT_SCALE)]" 
    }
  }
  
  public static var layouts : [Int:Layout] {
    
    get {
    
      let conn = Database.getConnection()
      
      let shouldClose = conn.state != .Open
       
      if shouldClose {
        _ = conn.open()
      }
       
      let cmd = conn.createCommand()
       
      cmd.commandText = "SELECT \(columnNames) FROM [\(TABLE.LAYOUT)] ORDER BY [\(LAYOUT.LAYOUT_NAME)]"

      var result : [Int:Layout] = [:]
      
      if let reader = cmd.executeReader() {
           
        while reader.read() {
          let layout = Layout(reader: reader)
          result[layout.primaryKey] = layout
        }
           
        reader.close()
           
      }
      
      if shouldClose {
        conn.close()
      }

      return result
      
    }
    
  }
  
  public static func delete(primaryKey: Int) {
    let sql : [String] = [
      "DELETE FROM [\(TABLE.LAYOUT)] WHERE [\(LAYOUT.LAYOUT_ID)] = \(primaryKey)",
      "DELETE FROM [\(TABLE.SWITCHBOARD_ITEM)] WHERE [\(SWITCHBOARD_ITEM.LAYOUT_ID)] = \(primaryKey)",
      "DELETE FROM [\(TABLE.SWITCHBOARD_PANEL)] WHERE [\(SWITCHBOARD_PANEL.LAYOUT_ID)] = \(primaryKey)",
    ]
    Database.execute(commands: sql)
  }
  
}
