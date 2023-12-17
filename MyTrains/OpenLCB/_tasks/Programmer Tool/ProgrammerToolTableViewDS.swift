//
//  ProgrammerToolTableViewDS.swift
//  MyTrains
//
//  Created by Paul Willmott on 04/08/2023.
//

import Foundation
import Cocoa

public class ProgrammerToolTableViewDS : NSObject, NSTableViewDataSource, NSTableViewDelegate {

  // MARK: Private Properties
  
  // MARK: Public Properties
  
  public var programmerTool : OpenLCBProgrammerToolNode?
  
  // MARK: NSTableViewDataSource Delegate Methods
  
  // MARK: NSTableViewDelegate Methods
  
  // Returns the number of records managed for aTableView by the data source object.
   public func numberOfRows(in tableView: NSTableView) -> Int {
     return min(programmerTool!.cvs.count, 1024)
   }
  
  // Sets the data object for an item in the specified row and column.
  public func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
  }
  
  public func tableView(_ tableView: NSTableView,
                        viewFor tableColumn: NSTableColumn?,row: Int) -> NSView? {
    
    let columnName = tableColumn!.identifier.rawValue
    
    let cellIdentifier = "\(columnName)CellID"
    
    let numberBase = NumberBase(rawValue: Int(programmerTool!.getNumberBase(cvNumber: row)!)) ?? NumberBase.defaultValue
    
    let defaultOffset = 1024
    
    var text: String = ""
    
    var isEditable = false

    enum ColumnIdentifiers {
      static let CVNumberColumn      = "CVNumber"
      static let DescriptionColumn   = "Description"
      static let NumberBaseColumn    = "NumberBase"
      static let DefaultColumn       = "Default"
      static let DefaultStatusColumn = "DefaultStatus"
      static let GetDefaultColumn    = "GetDefault"
      static let SetDefaultColumn    = "SetDefault"
      static let ValueColumn         = "Value"
      static let ValueStatusColumn   = "ValueStatus"
      static let GetValueColumn      = "GetValue"
      static let SetValueColumn      = "SetValue"
      static let SetToDefaultColumn  = "SetToDefault"
    }

    switch columnName {
      
    case ColumnIdentifiers.CVNumberColumn:
      if row > 255 && row < 512 {
        text = "\(programmerTool!.cvs[30]).\(programmerTool!.cvs[31]).\(row + 1)"
      }
      else {
        text = "\(row + 1)"
      }
      
    case ColumnIdentifiers.DescriptionColumn:
      text = NMRA.cvDescription(cv: row + 1)
      
    case ColumnIdentifiers.NumberBaseColumn:
      if let cell = tableView.makeView(withIdentifier:
        NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
        if let cbo = cell.subviews[0] as? NSComboBox {
          cbo.tag = row
          NumberBase.populate(comboBox: cbo)
          NumberBase.select(comboBox: cbo, value: numberBase)
        }
       return cell
      }

    case ColumnIdentifiers.DefaultColumn:
      if programmerTool!.isDefaultSupported {
        text = "\(numberBase.toString(value: programmerTool!.cvs[defaultOffset + row]))"
        isEditable = true
      }
      
    case ColumnIdentifiers.DefaultStatusColumn:
      if programmerTool!.isDefaultSupported {
        text = (programmerTool!.isDefaultClean(cvNumber: row)) ? "✓" : "?"
      }
      
    case ColumnIdentifiers.GetDefaultColumn:
      if let cell = tableView.makeView(withIdentifier:
        NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
        if let button = cell.subviews[0] as? NSButton {
          button.tag = row
          button.isEnabled = programmerTool!.isDefaultSupported
        }
        return cell
      }
      
    case ColumnIdentifiers.SetDefaultColumn:
      if let cell = tableView.makeView(withIdentifier:
        NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
        if let button = cell.subviews[0] as? NSButton {
          button.tag = row
          button.isEnabled = programmerTool!.isDefaultSupported
        }
        return cell
      }
      
    case ColumnIdentifiers.ValueColumn:
      text = "\(numberBase.toString(value: programmerTool!.cvs[row]))"
      isEditable = true

    case ColumnIdentifiers.ValueStatusColumn:
      if programmerTool!.isDefaultSupported {
        text = (programmerTool!.isValueClean(cvNumber: row)) ? "✓" : "?"
        if programmerTool!.isValueWriteFailure(cvNumber: row) {
          text += "🔒"
        }
      }
      
    case ColumnIdentifiers.GetValueColumn:
      if let cell = tableView.makeView(withIdentifier:
        NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
        if let button = cell.subviews[0] as? NSButton {
          button.tag = row
        }
        return cell
      }
      
    case ColumnIdentifiers.SetValueColumn:
      if let cell = tableView.makeView(withIdentifier:
        NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
        if let button = cell.subviews[0] as? NSButton {
          button.tag = row
        }
        return cell
      }
      
    case ColumnIdentifiers.SetToDefaultColumn:
      if let cell = tableView.makeView(withIdentifier:
        NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
        if let button = cell.subviews[0] as? NSButton {
          button.tag = row
          button.isEnabled = programmerTool!.isDefaultSupported
        }
        return cell
      }
      
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

