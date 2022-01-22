//
//  LocoSlotTableViewDS.swift
//  MyTrains
//
//  Created by Paul Willmott on 22/01/2022.
//

import Foundation
import Cocoa

public class SlotTableViewDS : NSObject, NSTableViewDataSource, NSTableViewDelegate {

  // MARK: Public Properties
  
  public var slots = [LocoSlotData]()
  
  // MARK: NSTableViewDataSource Delegate Methods
  
  // MARK: NSTableViewDelegate Methods
  
  // Returns the number of records managed for aTableView by the data source object.
   public func numberOfRows(in tableView: NSTableView) -> Int {
     return slots.count
   }
  
  // Sets the data object for an item in the specified row and column.
  public func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
  }
  
  public func tableView(_ tableView: NSTableView,
                        viewFor tableColumn: NSTableColumn?,row: Int) -> NSView? {
    
    let item = slots[row]
    
    let columnName = tableColumn!.identifier.rawValue
    
    let cellIdentifier = "\(columnName)CellID"
    
    var text: String = ""
    
    let isEditable = false

    enum ColumnIdentifiers {
      static let SlotNumberColumn = "SlotNumber"
      static let StatusColumn     = "Status"
      static let DecoderColumn    = "Decoder"
      static let AddressColumn    = "Address"
      static let SpeedColumn      = "Speed"
      static let DirectionColumn  = "Direction"
      static let ThrottleColumn   = "Throttle"
    }

    switch columnName {
    case ColumnIdentifiers.SlotNumberColumn:
      text = "\(item.displaySlotNumber)"
    case ColumnIdentifiers.StatusColumn:
      text = "\(item.slotState)"
    case ColumnIdentifiers.DecoderColumn:
      text = "\(item.mobileDecoderType)"
    case ColumnIdentifiers.AddressColumn:
      text = "\(item.address)"
    case ColumnIdentifiers.SpeedColumn:
      text = "\(item.speed)"
    case ColumnIdentifiers.DirectionColumn:
      text = "\(item.direction)"
    case ColumnIdentifiers.ThrottleColumn:
      text = "\(item.throttleID)"
    // The remaining ones are function keys
    default:
      if let fn = Int(String(columnName.suffix(columnName.count-1))) {
        text = "\(item.displayFunctionState(functionNumber: fn))"
      }
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
