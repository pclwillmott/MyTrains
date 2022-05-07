//
//  FNTableViewDS.swift
//  MyTrains
//
//  Created by Paul Willmott on 16/01/2022.
//

import Foundation
import Cocoa

public class FNTableViewDS : NSObject, NSTableViewDataSource, NSTableViewDelegate {

  // MARK: Private Enums
  
  fileprivate enum CellIdentifiers {
    static let FunctionNumberCell = "FunctionNumberCellID"
    static let EnabledCell        = "EnabledCellID"
    static let DescriptionCell    = "DescriptionCellID"
    static let MomentaryCell      = "MomentaryCellID"
    static let DurationCell       = "DurationCellID"
    static let InvertedCell       = "InvertedCellID"
  }
  
  // MARK: Private Properties

  private var _fns = [DecoderFunction]()
  
  private var cboDescriptionDS = ComboBoxDBDS(tableName: TABLE.DECODER_FUNCTION, codeColumn: DECODER_FUNCTION.FUNCTION_DESCRIPTION, displayColumn: DECODER_FUNCTION.FUNCTION_DESCRIPTION, sortColumn: DECODER_FUNCTION.FUNCTION_DESCRIPTION, groupItems: true)
  
  // MARK: Public Properties
  
  public var fns : [DecoderFunction] {
    get {
      return _fns
    }
    set(value) {
      _fns = value
    }
  }
  
  // MARK: Public Methods
  
  // MARK: NSTableViewDataSourceDelegate Methods
  
  // MARK: NSTableViewDelegate Methods
  
  // Returns the number of records managed for aTableView by the data source object.
   public func numberOfRows(in tableView: NSTableView) -> Int {
     return fns.count
   }
  
  // Sets the data object for an item in the specified row and column.
  public func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
  }
  
  public func tableView(_ tableView: NSTableView,
                        viewFor tableColumn: NSTableColumn?,row: Int) -> NSView? {
    
    var text: String = ""
    var cellIdentifier: String = ""
    var isEditable = false

    let item = fns[row]

    if tableColumn == tableView.tableColumns[0] {
      text = "\(item.functionNumber)"
      cellIdentifier = CellIdentifiers.FunctionNumberCell
    }
    else if tableColumn == tableView.tableColumns[1] {
      text = ""
      cellIdentifier = CellIdentifiers.EnabledCell
    }
    else if tableColumn == tableView.tableColumns[2] {
      text = item.functionDescription
      cellIdentifier = CellIdentifiers.DescriptionCell
      isEditable = true
    }
    else if tableColumn == tableView.tableColumns[3] {
      text = ""
      cellIdentifier = CellIdentifiers.MomentaryCell
      isEditable = true
    }
    else if tableColumn == tableView.tableColumns[4] {
      text = "\(item.duration)"
      cellIdentifier = CellIdentifiers.DurationCell
      isEditable = true
    }
    else if tableColumn == tableView.tableColumns[5] {
      text = ""
      cellIdentifier = CellIdentifiers.InvertedCell
      isEditable = true
    }

    if cellIdentifier == CellIdentifiers.EnabledCell {
      if let cell = tableView.makeView(withIdentifier:
        NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
       
        if let button = cell.subviews[0] as? NSButton {
          button.tag = row
          button.state = item.isEnabled ? .on : .off
        }

       return cell
      }
    }
    
    if cellIdentifier == CellIdentifiers.DescriptionCell {
      if let cell = tableView.makeView(withIdentifier:
        NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
        if let combo = cell.subviews[0] as? NSComboBox {
          combo.dataSource = cboDescriptionDS
          combo.tag = row
          combo.stringValue = item.functionDescription
       }

       return cell
      }
    }
    

    if cellIdentifier == CellIdentifiers.MomentaryCell {
      if let cell = tableView.makeView(withIdentifier:
        NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
       
        if let button = cell.subviews[0] as? NSButton {
          button.tag = row
          button.state = item.isMomentary ? .on : .off
        }

       return cell
      }
    }
    
    if cellIdentifier == CellIdentifiers.InvertedCell {
      if let cell = tableView.makeView(withIdentifier:
        NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
       
        if let button = cell.subviews[0] as? NSButton {
          button.tag = row
          button.state = item.isInverted ? .on : .off
        }

       return cell
      }
    }
    
    if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
      
  //    cell.textField?.stringValue = text
  //    cell.textField?.isEditable = isEditable

      if let textField = cell.subviews[0] as? NSTextField {
        textField.tag = row
        textField.stringValue = text
        textField.isEditable = isEditable
      }

  //    cell.textField?.font = NSFont(name: "Menlo", size: 11)
      
      return cell
      
    }
  
    return nil
    
  }

}

