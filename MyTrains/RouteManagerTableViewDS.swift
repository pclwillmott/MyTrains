//
//  RouteManagerTableViewDS.swift
//  MyTrains
//
//  Created by Paul Willmott on 08/10/2022.
//

import Foundation
import Cocoa

public class RouteManagerTableViewDS : NSObject, NSTableViewDataSource, NSTableViewDelegate {

  // MARK: Public Properties
  
  public var route : [SwitchRoute] = []

  // MARK: NSTableViewDataSource Delegate Methods
  
  // MARK: NSTableViewDelegate Methods
  
  // Returns the number of records managed for aTableView by the data source object.
   public func numberOfRows(in tableView: NSTableView) -> Int {
     return route.count
   }
  
  // Sets the data object for an item in the specified row and column.
  public func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
  }
  
  public func tableView(_ tableView: NSTableView,
                        viewFor tableColumn: NSTableColumn?,row: Int) -> NSView? {
    
    let item = route[row]
    
    let columnName = tableColumn!.identifier.rawValue
    
    let cellIdentifier = "\(columnName)CellID"

    var text: String = ""
    
    var isEditable = false

    enum ColumnIdentifiers {
      static let Index        = "Index"
      static let SwitchNumber = "SwitchNumber"
      static let SwitchState  = "SwitchState"
      static let Turnout      = "Turnout"
    }
    
    let isEmpty = item.switchNumber == 0x7f && item.switchState == .unknown
    
    switch columnName {
    case ColumnIdentifiers.Index:
      text = "\(row)"
    case ColumnIdentifiers.SwitchNumber:
      text = isEmpty ? "" : "\(item.switchNumber)"
      isEditable = true
    case ColumnIdentifiers.SwitchState:
      text = isEmpty ? "" : "\(item.switchState.title)"
      isEditable = false
      if let cell = tableView.makeView(withIdentifier:
        NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
        if let cbo = cell.subviews[0] as? NSComboBox {
          cbo.tag = row
          cbo.isEditable = false
          TurnoutSwitchState.populate(comboBox: cbo)
          TurnoutSwitchState.select(comboBox: cbo, value: item.switchState)
        }
       return cell
      }
    default:
      break
    }
    
    if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
      if let textField = cell.subviews[0] as? NSTextField {
        textField.tag = row
        textField.stringValue = text
        textField.isEditable = isEditable
      }
      return cell
    }

    return nil

  }

}

