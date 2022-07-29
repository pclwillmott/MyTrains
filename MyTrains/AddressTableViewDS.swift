//
//  AddressTableViewDS.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/07/2022.
//

import Foundation
import Cocoa

public class AddressTableViewDS : NSObject, NSTableViewDataSource, NSTableViewDelegate {

  // MARK: Public Properties
  
  public var devices : [LocoNetDevice]?
  
  // MARK: NSTableViewDataSource Delegate Methods
  
  // MARK: NSTableViewDelegate Methods
  
  // Returns the number of records managed for aTableView by the data source object.
   public func numberOfRows(in tableView: NSTableView) -> Int {
     return devices!.count
   }
  
  // Sets the data object for an item in the specified row and column.
  public func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
  }
  

  
  public func tableView(_ tableView: NSTableView,
                        viewFor tableColumn: NSTableColumn?,row: Int) -> NSView? {
    
    let item = devices![row]
    
    let columnName = tableColumn!.identifier.rawValue
    
    let cellIdentifier = "\(columnName)CellID"
    
    var text: String = ""
    
    var isEditable = false
    
    var textColor : NSColor = .black

    enum ColumnIdentifiers {
      static let DeviceName   = "DeviceName"
      static let BoardID      = "BoardID"
      static let BaseAddress  = "BaseAddress"
      static let Addresses    = "Addresses"
      static let Action       = "Action"
      static let DeviceType   = "Type"
      static let SerialNumber = "SerialNumber"
    }

    textColor = item.baseAddressOK ? .black : .orange

    switch columnName {
    case ColumnIdentifiers.DeviceName:
      text = "\(item.deviceName)"
      
    case ColumnIdentifiers.BoardID:
      if !item.isSeries7 {
        text = "\(item.boardId)"
        isEditable = true
      }
      
    case ColumnIdentifiers.BaseAddress:
      text = "\(item.baseAddress)"
      isEditable = item.isSeries7
      textColor = item.isAddressClash ? .red : .black
      
    case ColumnIdentifiers.Addresses:
      text = "\(item.baseAddress + item.numberOfAddresses - 1)"
      
    case ColumnIdentifiers.DeviceType:
      if let info = item.locoNetProductInfo {
        text = "\(info.productName)"
      }
      
    case ColumnIdentifiers.SerialNumber:
      if item.serialNumber > 0 {
        text = "\(item.serialNumber)"
      }
      
    case ColumnIdentifiers.Action:
      
      if let cell = tableView.makeView(withIdentifier:
      NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSButton {
       
        cell.title = "Set"
        cell.tag = row
        
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
