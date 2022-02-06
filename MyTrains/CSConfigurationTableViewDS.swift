//
//  CSConfigurationTableViewDS.swift
//  MyTrains
//
//  Created by Paul Willmott on 05/02/2022.
//

import Foundation
import Cocoa

public class CSConfigurationTableViewDS : NSObject, NSTableViewDataSource, NSTableViewDelegate {

  // MARK: Public Properties
  
  public var options = [CommandStationOptionSwitch]()
  
  public var isConfigurationSlotMode : Bool = true
  
  // MARK: NSTableViewDataSource Delegate Methods
  
  // MARK: NSTableViewDelegate Methods
  
  // Returns the number of records managed for aTableView by the data source object.
   public func numberOfRows(in tableView: NSTableView) -> Int {
     return options.count
   }
  
  // Sets the data object for an item in the specified row and column.
  public func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
  }
  
  public func tableView(_ tableView: NSTableView,
                        viewFor tableColumn: NSTableColumn?,row: Int) -> NSView? {
    
    let item = options[row]
    
    let columnName = tableColumn!.identifier.rawValue
    
    let cellIdentifier = "\(columnName)CellID"
    
    var text: String = ""
    
    let isEditable = false

    enum ColumnIdentifiers {
      static let OpSwNumberColumn = "OpSwNumber"
      static let SettingsColumn   = "Settings"
    }

    switch columnName {
    case ColumnIdentifiers.OpSwNumberColumn:
      text = "\(item.switchNumber)"
    case ColumnIdentifiers.SettingsColumn:
      
      if item.switchDefinition.definitionType == .standard {
        let nib = NSNib(nibNamed: "OpSwTCV", bundle: nil)
        tableView.register(nib, forIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier))
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? OpSwTCV {
          cell.isConfigurationSlotMode = isConfigurationSlotMode
          cell.optionSwitch = item
          return cell
        }
      }
      else {
        let nib = NSNib(nibNamed: "OpSwDecoderType", bundle: nil)
        let cellIdentifier = "OpSwDecoderCellID"
        tableView.register(nib, forIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier))
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? OpSwDecoderView {
          cell.optionSwitch = item
          return cell
        }

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
