//
//  Layout.swift
//  MyTrains
//
//  Created by Paul Willmott on 27/12/2021.
//

import Foundation

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
  
  // MARK: Public properties
  
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
  
  // MARK: Public Methods
  
  public func linkSwitchBoardItems() {
    
    // Remove all links
    
    for (_, item) in switchBoardItems {
      for index in 0...7 {
        item.nodeLinks[index] = (switchBoardItem: nil, nodeId: -1)
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
              item1.nodeLinks[point1].switchBoardItem = item2
              item1.nodeLinks[point1].nodeId = point2
              item2.nodeLinks[point2].switchBoardItem = item1
              item2.nodeLinks[point2].nodeId = point1
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
    
    for (_, item) in switchBoardItems {
      
      if item.isEliminated {
        continue
      }
      
      print("\(item.itemPartType.partName) \(item.primaryKey)")
      
      for point in item.itemPartType.pointsSet(orientation: item.orientation) {
        let nodeLink = item.nodeLinks[point]
        if let node = nodeLink.switchBoardItem {
          print("  \(point): \(node.primaryKey) - \(nodeLink.nodeId)")
        }
      }
    }
    
  }
  
  public func links(item:SwitchBoardItem) -> [Int:SwitchBoardItem] {
    var result : [Int:SwitchBoardItem] = [:]
    for (_, value) in switchBoardItems {
      if value.itemPartType == .link && item.primaryKey != value.primaryKey {
        result[item.primaryKey] = item
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
      if item.nextAction == .delete {
        SwitchBoardItem.delete(primaryKey: item.primaryKey)
        switchBoardItems[item.primaryKey] = nil
      }
      else {
        item.save()
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
