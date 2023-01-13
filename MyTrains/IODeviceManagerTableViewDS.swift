//
//  IODeviceManagerTableViewDS.swift
//  MyTrains
//
//  Created by Paul Willmott on 12/01/2023.
//

import Foundation
import Cocoa

public class IODeviceManagerTableViewDS : NSObject, NSTableViewDataSource, NSTableViewDelegate {

  // MARK: Constructors
  
  override public init() {
    
    super.init()
    
    cboNetworkDS.dictionary = networkController.networksForCurrentLayout

  }
  
  // MARK: Private Properties
  
  private var cboNetworkDS : ComboBoxDictDS = ComboBoxDictDS()

  // MARK: Public Properties
  
  public var ioFunctions : [IOFunction]?
  
  // MARK: NSTableViewDataSource Delegate Methods
  
  // MARK: NSTableViewDelegate Methods
  
  // Returns the number of records managed for aTableView by the data source object.
   public func numberOfRows(in tableView: NSTableView) -> Int {
     return ioFunctions!.count
   }
  
  // Sets the data object for an item in the specified row and column.
  public func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
  }
  

  
  public func tableView(_ tableView: NSTableView,
                        viewFor tableColumn: NSTableColumn?,row: Int) -> NSView? {
    
    let item = ioFunctions![row]
    
    let columnName = tableColumn!.identifier.rawValue
    
    let cellIdentifier = "\(columnName)CellID"
    
    var text: String = ""
    
    var isEditable = false
    
    var textColor : NSColor = .black

    enum ColumnIdentifiers {
      static let ioDevice = "IODevice"
      static let boardID = "BoardID"
      static let editIODevice = "EditIODevice"
      static let deleteIODevice = "DeleteIODevice"
      static let channel = "Channel"
      static let editChannel = "EditChannel"
      static let function = "Function"
      static let editFunction = "EditFunction"
      static let network = "Network"
      static let channelType = "ChannelType"
    }

    switch columnName {
    
    case ColumnIdentifiers.ioDevice:
      text = "\(item.ioDevice.deviceName)"
      isEditable = true
      
    case ColumnIdentifiers.boardID:
      textColor = !item.ioDevice.addressCollision ? .black : .orange
      text = "\(item.ioDevice.boardId)"
      isEditable = true
     
    case ColumnIdentifiers.channel:
      text = "\(item.ioChannel.ioChannelNumber)"
      
    case ColumnIdentifiers.function:
      text = "\(item.displayString())"
            
    case ColumnIdentifiers.network:


      if let cell = tableView.makeView(withIdentifier:
                                        NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil), let combo = cell.subviews[0] as? NSComboBox {
          
        combo.tag = row

        combo.dataSource = cboNetworkDS
        
        combo.selectItem(at: cboNetworkDS.indexWithKey(key: item.ioDevice.networkId) ?? -1)

        return cell
        
      }
      
    case ColumnIdentifiers.channelType:


      if let cell = tableView.makeView(withIdentifier:
                                        NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil), let combo = cell.subviews[0] as? NSComboBox {
          
        combo.tag = row

        InputOutput.populate(comboBox: combo, fromSet: item.ioChannel.allowedChannelTypes)
        
        InputOutput.select(comboBox: combo, value: item.ioChannel.channelType)
        
        return cell
        
      }
      
    case ColumnIdentifiers.editIODevice:
      
      if let cell = tableView.makeView(withIdentifier:
                                        NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil), let button = cell.subviews[0] as? NSButton {
       
        button.title = "Edit"
        
        button.tag = row
        
        button.isEnabled = item.ioDevice.hasPropertySheet
        
        return cell
        
      }
      
    case ColumnIdentifiers.deleteIODevice:
      
      if let cell = tableView.makeView(withIdentifier:
      NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil), let button = cell.subviews[0] as? NSButton {
       
        button.title = "Delete"
        
        button.tag = row
        
        return cell
        
      }
      
    case ColumnIdentifiers.editChannel:
      
      if let cell = tableView.makeView(withIdentifier:
      NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil), let button = cell.subviews[0] as? NSButton {
       
        button.title = "Edit"
        
        button.tag = row
        
        button.isEnabled = item.ioChannel.hasPropertySheet
        
        return cell
        
      }
      
   case ColumnIdentifiers.editFunction:
      
      if let cell = tableView.makeView(withIdentifier:
      NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil), let button = cell.subviews[0] as? NSButton {
       
        button.title = "Edit"
        
        button.tag = row
        
        button.isEnabled = item.hasPropertySheet
        
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
