//
//  LocomotiveRosterTableViewDS.swift
//  MyTrains
//
//  Created by Paul Willmott on 07/10/2022.
//

import Foundation
import Cocoa

public class LocomotiveRosterTableViewDS : NSObject, NSTableViewDataSource, NSTableViewDelegate {

  // MARK: Public Properties
  
  public var locomotiveRoster : [AliasEntry] = []

  // MARK: NSTableViewDataSource Delegate Methods
  
  // MARK: NSTableViewDelegate Methods
  
  // Returns the number of records managed for aTableView by the data source object.
   public func numberOfRows(in tableView: NSTableView) -> Int {
     return locomotiveRoster.count
   }
  
  // Sets the data object for an item in the specified row and column.
  public func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
  }
  
  public func tableView(_ tableView: NSTableView,
                        viewFor tableColumn: NSTableColumn?,row: Int) -> NSView? {
    
    let item = locomotiveRoster[row]
    
    let columnName = tableColumn!.identifier.rawValue
    
    let cellIdentifier = "\(columnName)CellID"
    
    var text: String = ""
    
    var isEditable = false

    enum ColumnIdentifiers {
      static let EntryNumberColumn     = "EntryNumber"
      static let ExtendedAddressColumn = "ExtendedAddress"
      static let PrimaryAddressColumn  = "PrimaryAddress"
      static let LocomotiveColumn      = "Locomotive"
    }

    switch columnName {
    case ColumnIdentifiers.EntryNumberColumn:
      text = "\(item.index)"
    case ColumnIdentifiers.ExtendedAddressColumn:
      text = "\(item.extendedAddress)"
      isEditable = true
    case ColumnIdentifiers.PrimaryAddressColumn:
      text = "\(item.primaryAddress)"
      isEditable = true
    case ColumnIdentifiers.LocomotiveColumn:
      text = ""
    default:
      break
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

