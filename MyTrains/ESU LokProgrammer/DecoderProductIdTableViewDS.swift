// -----------------------------------------------------------------------------
// DecoderProductIdTableViewDS.swift
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
//     30/08/2024  Paul Willmott - DecoderProductIdTableViewDS.swift created
// -----------------------------------------------------------------------------

import Foundation
import AppKit

public protocol DecoderProductIdTableViewDSDelegate {
  func productIdChanged(productIds:[UInt32])
}

public class DecoderProductIdTableViewDS : NSObject, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate, NSControlTextEditingDelegate {

  // MARK: Public Properties
  
  public var definition : DecoderDefinition?
  
  public var delegate : DecoderProductIdTableViewDSDelegate?
  
  // MARK: NSTableViewDataSource Delegate Methods
  
  // MARK: NSTableViewDelegate Methods
  
  // Returns the number of records managed for aTableView by the data source object.
   public func numberOfRows(in tableView: NSTableView) -> Int {
     guard let definition else {
       return 0
     }
     return definition.esuProductIds.count
   }
  
  // Sets the data object for an item in the specified row and column.
  public func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
  }
  
  public func tableView(_ tableView: NSTableView,
                        viewFor tableColumn: NSTableColumn?,row: Int) -> NSView? {
    
    guard let definition else {
      return nil
    }
    
    let item = definition.esuProductIds[row]
    
    let columnName = tableColumn!.identifier.rawValue
    
    let cellIdentifier = "\(columnName)CellID"
    
    var text: String = ""
    
    let isEditable = true

    switch columnName {
    case "ProductId":
      text = "\(item.toHex(numberOfDigits: 8))"
    default:
      break
    }

    if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
      if let textField = cell.subviews[0] as? NSTextField {
        textField.tag = row
        textField.stringValue = text
        textField.isEditable = isEditable
        textField.font = NSFont(name: "Menlo", size: 12)
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        let constraints : [NSLayoutConstraint] = [
          textField.centerYAnchor.constraint(equalTo: cell.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
      }
      return cell
    }

    return nil
    
  }
  
  
  public func tableViewSelectionDidChange(_ notification: Notification) {
  }

  // MARK: NSTextFieldDelegate, NSControlTextEditingDelegate Methods
  
  /// This is called when the user presses return.
  @objc public func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
    
    guard definition != nil else {
      return true
    }
    
    var isValid = true
    
    if let textField = control as? NSTextField {
      
      let trimmed = textField.stringValue.trimmingCharacters(in: .whitespaces)
      
      if let id = UInt32(hex: trimmed) {
        definition?.esuProductIds[textField.tag] = id
        delegate?.productIdChanged(productIds: definition!.esuProductIds)
      }
      else {
        isValid = false
      }

    }
    
    return isValid
    
  }
  
}