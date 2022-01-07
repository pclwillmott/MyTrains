//
//  CVTableViewDS.swift
//  MyTrains
//
//  Created by Paul Willmott on 07/01/2022.
//

import Foundation
import Cocoa

public class CVTableViewDS : NSObject, NSTableViewDataSource, NSTableViewDelegate {

  // MARK: Private Enums
  
  fileprivate enum CellIdentifiers {
    static let CVNumberCell     = "CVNumberCellID"
    static let EnabledCell      = "EnabledCellID"
    static let DescriptionCell  = "DescriptionCellID"
    static let DefaultValueCell = "DefaultValueCellID"
    static let ValueCell        = "ValueCellID"
  }

  // MARK: Public Properties
  
  public var cvs = [LocomotiveCV]()
  
  // MARK: NSTableViewDataSource Delegate Methods
  
  // MARK: NSTableViewDelegate Methods
  
  // Returns the number of records managed for aTableView by the data source object.
   public func numberOfRows(in tableView: NSTableView) -> Int {
     return cvs.count
   }
  
  // Sets the data object for an item in the specified row and column.
  public func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
  }
  
  public func tableView(_ tableView: NSTableView,
                        viewFor tableColumn: NSTableColumn?,row: Int) -> NSView? {
    
    var text: String = ""
    var cellIdentifier: String = ""
    var isEditable = false

    let item = cvs[row]

    if tableColumn == tableView.tableColumns[0] {
      text = "\(item.cvNumber)"
      cellIdentifier = CellIdentifiers.CVNumberCell
    }
    else if tableColumn == tableView.tableColumns[1] {
      text = "\(item.isEnabled)"
      cellIdentifier = CellIdentifiers.EnabledCell
    }
    else if tableColumn == tableView.tableColumns[2] {
      text = item.displayString()
      cellIdentifier = CellIdentifiers.DescriptionCell
      isEditable = true
    }
    else if tableColumn == tableView.tableColumns[3] {
      text = "\(item.defaultValue)"
      cellIdentifier = CellIdentifiers.DefaultValueCell
      isEditable = true
    }
    else if tableColumn == tableView.tableColumns[4] {
      text = "\(item.cvValue)"
      cellIdentifier = CellIdentifiers.ValueCell
      isEditable = true
    }
/*
    if cellIdentifier == CellIdentifiers.OverrideCell {
      if let cell = tableView.makeView(withIdentifier:
      NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSButton {
       
        if isSinglesMode {
          if item.bestTrack == nil {
            cell.title = "Find"
          }
          else {
            cell.title = "Change"
          }
        }
        else {
          if item.bestAlbum == nil {
            cell.title = "Find"
          }
          else {
            cell.title = "Change"
          }
        }
        cell.tag = row
      //  cell.textField?.font = NSFont(name: "Menlo", size: 11)
       
       return cell
      }
    }
    else
 */
    
    if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
      
      cell.textField?.stringValue = text
      cell.textField?.isEditable = isEditable
  //    cell.textField?.font = NSFont(name: "Menlo", size: 11)
      
      return cell
      
    }
  
    return nil
    
  }

}

