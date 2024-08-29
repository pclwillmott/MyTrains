// -----------------------------------------------------------------------------
// DecoderPropertyTableViewDS.swift
// MyTrains
//
// Copyright © 2024 Paul C. L. Willmott. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy 
// of this software and associated documentation files (the “Software”), to deal 
// in the Software without restriction, including without limitation the rights 
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
// copies of the Software, and to permit persons to whom the Software is 
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in 
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
// SOFTWARE.
// -----------------------------------------------------------------------------
//
// Revision History:
//
//     29/08/2024  Paul Willmott - DecoderPropertyTableViewDS.swift created
// -----------------------------------------------------------------------------

import Foundation
import AppKit

public class DecoderPropertyTableViewDS : NSObject, NSTableViewDataSource, NSTableViewDelegate {

  // MARK: Public Properties
  
  public var definition : DecoderDefinition? {
    didSet {
      supportedProperties = []
      if let definition {
        for property in definition.properties {
          supportedProperties.insert(property)
        }
      }
      modified = false
    }
  }
  
  public var modifiedProperties : [ProgrammerToolSettingsProperty] {
    
    var newProperties : [ProgrammerToolSettingsProperty] = []
    
    for property in properties {
      if supportedProperties.contains(property) {
        newProperties.append(property)
      }
    }
    
    return newProperties
    
  }
  private var supportedProperties : Set<ProgrammerToolSettingsProperty> = []
  
  public var properties : [ProgrammerToolSettingsProperty] = []
  
  // MARK: NSTableViewDataSource Delegate Methods
  
  // MARK: NSTableViewDelegate Methods
  
  // Returns the number of records managed for aTableView by the data source object.
   public func numberOfRows(in tableView: NSTableView) -> Int {
     return properties.count
   }
  
  // Sets the data object for an item in the specified row and column.
  public func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
  }
  
  public func tableView(_ tableView: NSTableView,
                        viewFor tableColumn: NSTableColumn?,row: Int) -> NSView? {
    
    guard definition != nil else {
      return nil
    }
    
    let item = properties[row]
    
    let columnName = tableColumn!.identifier.rawValue
    
    let cellIdentifier = "\(columnName)CellID"
    
    var text: String = ""
    
    let isEditable = false

    switch columnName {
    case "CheckBox":
      break
    case "Title":
      text = "\(item.definition.title)"
    case "Property":
      text = "\(item)"
    case "CV":
      text = ""
      if let cv = item.definition.cv, !cv.isEmpty {
        text = "\(cv[0])"
        if cv.count > 1 {
          text += " ..."
        }
      }
    default:
      break
    }

    if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
      if let textField = cell.subviews[0] as? NSTextField {
        textField.tag = row
        textField.stringValue = text
        textField.isEditable = isEditable
        textField.font = NSFont(name: "Menlo", size: 12)
      }
      else if let checkBox = cell.subviews[0] as? NSButton {
        checkBox.state = supportedProperties.contains(item) ? .on : .off
        checkBox.tag = row
        checkBox.target = self
        checkBox.action = #selector(checkBoxAction(_:))
      }
      return cell
    }

    return nil
    
  }
  
  public var modified = false
  
  @objc func checkBoxAction(_ sender:NSButton) {
    let property = properties[sender.tag]
    if sender.state == .on {
      supportedProperties.insert(property)
    }
    else {
      supportedProperties.remove(property)
    }
    modified = true
  }
  
  public func tableViewSelectionDidChange(_ notification: Notification) {

    let tableView = notification.object as! NSTableView

    if let identifier = tableView.identifier {
      print("\(tableView.selectedRow)")
    }


  }

}
