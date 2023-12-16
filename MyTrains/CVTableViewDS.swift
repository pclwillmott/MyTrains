//
//  CVTableViewDS.swift
//  MyTrains
//
//  Created by Paul Willmott on 07/01/2022.
//

import Foundation
import Cocoa

public class CVTableViewDS : NSObject, NSTableViewDataSource, NSTableViewDelegate {

  // MARK: Public Properties
  
//  public var cvs = [DecoderCV]()
  
  // MARK: NSTableViewDataSource Delegate Methods
  
  // MARK: NSTableViewDelegate Methods
  
  // Returns the number of records managed for aTableView by the data source object.
   public func numberOfRows(in tableView: NSTableView) -> Int {
     return 0 // cvs.count
   }
  
  // Sets the data object for an item in the specified row and column.
  public func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
  }
  
  public func tableView(_ tableView: NSTableView,
                        viewFor tableColumn: NSTableColumn?,row: Int) -> NSView? {
    
 //   let item = cvs[row]
    
    let columnName = tableColumn!.identifier.rawValue
    
    let cellIdentifier = "\(columnName)CellID"
    
    var text: String = ""
    
    var isEditable = false

    enum ColumnIdentifiers {
      static let CVNumberColumn     = "CVNumber"
      static let EnabledColumn      = "Enabled"
      static let DescriptionColumn  = "Description"
      static let NumberBaseColumn   = "NumberBase"
      static let DefaultValueColumn = "DefaultValue"
      static let ValueColumn        = "Value"
      static let NewValueColumn     = "NewValue"
    }

    switch columnName {
    case ColumnIdentifiers.CVNumberColumn:
   //   text = "\(item.displayCVNumber)"
      break
    case ColumnIdentifiers.EnabledColumn:
      if let cell = tableView.makeView(withIdentifier:
        NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
        if let button = cell.subviews[0] as? NSButton {
          button.tag = row
       //   button.state = item.isEnabled ? .on : .off
        }
        return cell
      }
    case ColumnIdentifiers.DescriptionColumn:
   //   text = item.displayString()
      isEditable = true
    case ColumnIdentifiers.NumberBaseColumn:
      if let cell = tableView.makeView(withIdentifier:
        NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
        if let cbo = cell.subviews[0] as? NSComboBox {
          cbo.tag = row
     //     cbo.selectItem(at: item.customNumberBase.rawValue)
        }
       return cell
      }
    case ColumnIdentifiers.DefaultValueColumn:
  //    text = "\(item.displayDefaultValue)"
      isEditable = true
    case ColumnIdentifiers.ValueColumn:
 //     text = "\(item.displayCVValue)"
      isEditable = true
    case ColumnIdentifiers.NewValueColumn:
 //     text = "\(item.newValue)"
      isEditable = true
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

