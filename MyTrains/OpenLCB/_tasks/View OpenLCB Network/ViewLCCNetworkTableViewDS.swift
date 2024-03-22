//
//  ViewLCCNetworkTableViewDS.swift
//  MyTrains
//
//  Created by Paul Willmott on 22/04/2023.
//

import Foundation
import AppKit

public class ViewLCCNetworkTableViewDS : NSObject, NSTableViewDataSource, NSTableViewDelegate {

  // MARK: Destructors
  
  public override init() {
    super.init()
    addInit()
  }
  
  deinit {
    _dictionary?.removeAll()
    _dictionary = nil
    nodes.removeAll()
    addDeinit()
  }
  
  // MARK: Private Properties
  
  private var _dictionary : [UInt64:OpenLCBNode]? = [:]
  
  // MARK: Public Properties
  
  public var nodes : [OpenLCBNode] = []
  
  public var dictionary : [UInt64:OpenLCBNode]? {
    get {
      return _dictionary!
    }
    set(value) {
      _dictionary = value
      nodes.removeAll()
      guard let _dictionary else {
        return
      }
      for (_, node) in _dictionary {
        nodes.append(node)
      }
      nodes.sort {$0.nodeId < $1.nodeId}
    }
  }
  
  // MARK: NSTableViewDelegate Methods
  
  // Returns the number of records managed for a TableView by the data source object.
   public func numberOfRows(in tableView: NSTableView) -> Int {
     return nodes.count
   }
  
  // Sets the data object for an item in the specified row and column.
  public func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
  }
  
  public func tableView(_ tableView: NSTableView,
                        viewFor tableColumn: NSTableColumn?,row: Int) -> NSView? {
    
    let item = nodes[row]
    
    let columnName = tableColumn!.identifier.rawValue
    
    let cellIdentifier = "\(columnName)CellID"
    
    var text: String = ""
    
    let isEditable = false
    
    let textColor : NSColor = .black

    enum ColumnIdentifiers {
      static let nodeId = "NodeID"
      static let manufacturer = "Manufacturer"
      static let modelName = "ModelName"
      static let hardwareVersion = "HardwareVersion"
      static let softwareVersion = "SoftwareVersion"
      static let userNodeName = "UserNodeName"
      static let userNodeDescription = "UserNodeDescription"
      static let configure = "Configure"
      static let updateFirmware = "UpdateFirmware"
      static let info = "Info"
      static let delete = "Delete"
    }

    switch columnName {
    
    case ColumnIdentifiers.nodeId:
      text = "\(item.nodeId.toHexDotFormat(numberOfBytes: 6))"
      
    case ColumnIdentifiers.manufacturer:
      text = "\(item.manufacturerName)"
     
    case ColumnIdentifiers.modelName:
      text = "\(item.nodeModelName)"
      
    case ColumnIdentifiers.hardwareVersion:
      text = "\(item.nodeHardwareVersion)"
      
    case ColumnIdentifiers.softwareVersion:
      text = "\(item.nodeSoftwareVersion)"
         
    case ColumnIdentifiers.userNodeName:
      text = "\(item.userNodeName)"
      
    case ColumnIdentifiers.userNodeDescription:
      text = "\(item.userNodeDescription)"
      
    case ColumnIdentifiers.configure:
      
      if let cell = tableView.makeView(withIdentifier:
                                        NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil), let button = cell.subviews[0] as? NSButton {
       
        button.title = String(localized: "Configure")
        
        button.tag = row
        
        button.isEnabled = item.isConfigurationDescriptionInformationProtocolSupported
        
        return cell
        
      }
      
    case ColumnIdentifiers.updateFirmware:
      
      if let cell = tableView.makeView(withIdentifier:
                                        NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil), let button = cell.subviews[0] as? NSButton {
        
        button.title = String(localized: "Update Firmware")
        
        button.tag = row
        
        button.isEnabled = item.isFirmwareUpgradeProtocolSupported
        
        return cell
      }
      
    case ColumnIdentifiers.info:
      
      if let cell = tableView.makeView(withIdentifier:
                                        NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil), let button = cell.subviews[0] as? NSButton {
        
        button.title = String(localized: "Info")
        
        button.tag = row
        
        button.isEnabled = true
        
        return cell
      }

    case ColumnIdentifiers.delete:
      
      if let cell = tableView.makeView(withIdentifier:
                                        NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil), let button = cell.subviews[0] as? NSButton {
        
        button.title = String(localized: "Delete")
        
        button.tag = row
        
        if appDelegate.networkLayer!.isInternalVirtualNode(nodeId: item.nodeId), let node = appDelegate.networkLayer!.virtualNodeLookup[item.nodeId] {
          
          let validNodesToDelete : Set<MyTrainsVirtualNodeType> = [
            .canGatewayNode,
            .clockNode,
            .digitraxBXP88Node,
            .layoutNode,
            .locoNetGatewayNode,
            .programmingTrackNode,
            .trainNode,
            .genericVirtualNode,
          ]
          
          button.isEnabled = validNodesToDelete.contains(node.virtualNodeType)
          
        }
        else {
          button.isEnabled = false
        }
        
        return cell
        
      }

    default:
      text = ""
    }

    if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
      if let textField = cell.subviews[0] as? NSTextField {
        textField.tag = row
        textField.stringValue = text
        textField.isEditable = isEditable
        textField.textColor = textColor
      }
      return cell
    }

    return nil
    
  }
  
}
