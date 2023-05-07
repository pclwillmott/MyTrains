//
//  LCCCDITableViewDS.swift
//  MyTrains
//
//  Created by Paul Willmott on 30/04/2023.
//

import Foundation
import Cocoa

public class LCCCDITableViewDS : NSObject, NSTableViewDataSource, NSTableViewDelegate {

  // MARK: Constructors
  
  override public init() {
    
    super.init()
    
  }
  
  // MARK: Private Properties
  
  // MARK: Public Properties
  
  public var fields : [LCCCDIElement]?
  
  // MARK: NSTableViewDataSource Delegate Methods
  
  // MARK: NSTableViewDelegate Methods
  
  // Returns the number of records managed for aTableView by the data source object.
   public func numberOfRows(in tableView: NSTableView) -> Int {
     return fields!.count
   }
  
  // Sets the data object for an item in the specified row and column.
  public func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
  }
  

  
  public func tableView(_ tableView: NSTableView,
                        viewFor tableColumn: NSTableColumn?,row: Int) -> NSView? {
    
    let item = fields![row]
    
    let columnName = tableColumn!.identifier.rawValue
    
    let cellIdentifier = "\(columnName)CellID"
    
    var text: String = ""
    
    var isEditable = false
    
    var textColor : NSColor = .black

    enum ColumnIdentifiers {
      static let element = "Element"
      static let refresh = "Refresh"
      static let write = "Write"
    }

    switch columnName {
                
    case ColumnIdentifiers.element:
      
//      print(item.map)
      
      if item.map.count == 0 {
        let nib = NSNib(nibNamed: "LCCCDITableCellViewString", bundle: nil)
        tableView.register(nib, forIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier))
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? LCCCDITableCellViewStringVC {
          
          cell.field = item
          
          return cell
          
        }
      }
      else {
        let nib = NSNib(nibNamed: "LCCCDITableCellViewIntCombo", bundle: nil)
        tableView.register(nib, forIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier))
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? LCCCDITableCellViewIntComboVC {
          
          cell.field = item
          
          return cell
          
        }
      }
    case ColumnIdentifiers.refresh:
      
      if let cell = tableView.makeView(withIdentifier:
                                        NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil), let button = cell.subviews[0] as? NSButton {
       
        button.title = "Refresh"
        
        button.tag = row
        
        return cell
        
      }
      
    case ColumnIdentifiers.write:
      
      if let cell = tableView.makeView(withIdentifier:
      NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil), let button = cell.subviews[0] as? NSButton {
       
        button.title = "Write"
        
        button.tag = row
        
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
