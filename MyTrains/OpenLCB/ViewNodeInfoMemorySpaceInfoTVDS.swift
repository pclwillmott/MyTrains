//
//  ViewNodeInfoMemorySpaceInfoTVDS.swift
//  MyTrains
//
//  Created by Paul Willmott on 04/06/2023.
//

import Foundation
import Cocoa

public class ViewNodeInfoMemorySpaceInfoTVDS : NSObject, NSTableViewDataSource, NSTableViewDelegate {

  // MARK: Constructors
  
  override public init() {
    
    super.init()
    
  }
  
  // MARK: Private Properties
  
  private var _addressSpaceInformation : [UInt8:OpenLCBNodeAddressSpaceInformation] = [:]
  
  private var items : [OpenLCBNodeAddressSpaceInformation] = []
  
  // MARK: Public Properties
  
  public var addressSpaceInformation : [UInt8:OpenLCBNodeAddressSpaceInformation] {
    get {
      return _addressSpaceInformation
    }
    set(value) {
      _addressSpaceInformation = value
      items.removeAll()
      for (_, item) in _addressSpaceInformation {
        items.append(item)
      }
      items.sort {$0.addressSpace < $1.addressSpace}
    }
  }
  
  // MARK: NSTableViewDataSource Delegate Methods
  
  // MARK: NSTableViewDelegate Methods
  
  // Returns the number of records managed for aTableView by the data source object.
   public func numberOfRows(in tableView: NSTableView) -> Int {
     return items.count
   }
  
  // Sets the data object for an item in the specified row and column.
  public func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
  }
  

  
  public func tableView(_ tableView: NSTableView,
                        viewFor tableColumn: NSTableColumn?,row: Int) -> NSView? {
    
    let item = items[row]
    
    let columnName = tableColumn!.identifier.rawValue
    
    let cellIdentifier = "\(columnName)CellID"
    
    var text: String = ""
    
    var isEditable = false
    
    var textColor : NSColor = .black
    
    var alignment : NSTextAlignment = .left

    enum ColumnIdentifiers {
      static let addressSpace   = "AddressSpace"
      static let lowestAddress  = "LowestAddress"
      static let highestAddress = "HighestAddress"
      static let size           = "Size"
      static let isReadOnly     = "IsReadOnly"
      static let description    = "Description"
    }

    switch columnName {
      
    case ColumnIdentifiers.addressSpace:
      text = "0x\(item.addressSpace.toHex(numberOfDigits: 2))"
      alignment = .center
      
    case ColumnIdentifiers.lowestAddress:
      text = "0x\(item.lowestAddress.toHex(numberOfDigits: 8))"
      alignment = .right
    
    case ColumnIdentifiers.highestAddress:
      text = "0x\(item.highestAddress.toHex(numberOfDigits: 8))"
      alignment = .right
      
    case ColumnIdentifiers.size:
      text = "\(item.size)"
      alignment = .right
      
    case ColumnIdentifiers.isReadOnly:
      text = item.isReadOnly ? "Read Only" : "Read/Write"
      alignment = .center
    case ColumnIdentifiers.description:
      text = item.description
      alignment = .left
    default:
      text = ""
    }

    if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
      if let textField = cell.subviews[0] as? NSTextField {
        textField.tag = row
        textField.stringValue = text
        textField.isEditable = isEditable
        textField.textColor = textColor
        textField.alignment = alignment
        textField.font = NSFont(name: "Menlo", size: 11.0)
   
      }
      return cell
    }

    return nil

  }
  
}
