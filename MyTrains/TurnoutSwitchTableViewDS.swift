//
//  TurnoutSwitchTableViewDS.swift
//  MyTrains
//
//  Created by Paul Willmott on 31/07/2022.
//

import Foundation
import Cocoa

public class TurnoutSwitchTableViewDS : NSObject, NSTableViewDataSource, NSTableViewDelegate {

  // MARK: Public Properties
  
  public var turnoutSwitches = [TurnoutSwitch]()
  
  // MARK: NSTableViewDataSource Delegate Methods
  
  // MARK: NSTableViewDelegate Methods
  
  // Returns the number of records managed for aTableView by the data source object.
   public func numberOfRows(in tableView: NSTableView) -> Int {
     return turnoutSwitches.count
   }
  
  // Sets the data object for an item in the specified row and column.
  public func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
  }
  
  public func tableView(_ tableView: NSTableView,
                        viewFor tableColumn: NSTableColumn?,row: Int) -> NSView? {
    
    let item = turnoutSwitches[row]
    
    let columnName = tableColumn!.identifier.rawValue
    
    let cellIdentifier = "\(columnName)CellID"
    
    var text: String = ""
    
    let isEditable = false

    enum ColumnIdentifiers {
      static let SectionColumn = "Section"
      static let BlockColumn   = "Block"
    }

    switch columnName {
    case ColumnIdentifiers.SectionColumn:
      text = "\(item.switchAddress)"
    case ColumnIdentifiers.BlockColumn:
      
      let nib = NSNib(nibNamed: "TurnoutSwitchTCV", bundle: nil)
      tableView.register(nib, forIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier))
      if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? TurnoutSwitchTCV {
        cell.turnoutSwitch = item
        return cell
      }

    default:
      text = ""
    }

    if text != "" {
      if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
        if let textField = cell.subviews[0] as? NSTextField {
          textField.tag = row
          textField.stringValue = text
          textField.isEditable = isEditable
        }
        return cell
      }
    }
  
    return nil
    
  }
  
}
