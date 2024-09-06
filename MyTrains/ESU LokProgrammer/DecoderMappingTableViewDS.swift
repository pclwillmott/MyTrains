// -----------------------------------------------------------------------------
// DecoderMappingTableViewDS.swift
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
//     31/08/2024  Paul Willmott - DecoderMappingTableViewDS.swift created
// -----------------------------------------------------------------------------

import Foundation
import AppKit

public class DecoderMappingTableViewDS : NSObject, NSTableViewDataSource, NSTableViewDelegate {
  
  // MARK: Public Properties
  
  public var definition : DecoderDefinition? {
    didSet {
      
      guard let definition else {
        return
      }
      
      mappings = []
      
      if !definition.mapping.isEmpty {
        
        var maxAddress = 0
        
        for address in definition.mapping.keys {
          maxAddress = max(maxAddress, address)
        }
        
        mappings = [Set<CV>?](repeating: nil, count: maxAddress + 1)
        
        for (address, cv) in definition.mapping {
          mappings[address] = cv
        }
        
        var count = 0
        
        for cv in definition.cvs {
          var found = false
          for (key, mapping) in definition.mapping {
            if mapping.contains(cv) {
              found = true
              break
            }
          }
          if !found {
            if cv.isIndexed {
              print("not found: \(cv.title)")
              count += 1
            }
          }
        }
        
        print("count: \(count)")
        
      }
      
    }
    
  }
  
  // MARK: NSTableViewDataSource Delegate Methods
  
  // MARK: NSTableViewDelegate Methods
  
  private var mappings : [Set<CV>?] = []
  
  // Returns the number of records managed for aTableView by the data source object.
  public func numberOfRows(in tableView: NSTableView) -> Int {
    return mappings.count
  }
  
  // Sets the data object for an item in the specified row and column.
  public func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
  }
  
  public func tableView(_ tableView: NSTableView,
                        viewFor tableColumn: NSTableColumn?,row: Int) -> NSView? {
    
    let item = mappings[row]
    
    let columnName = tableColumn!.identifier.rawValue
    
    let cellIdentifier = "\(columnName)CellID"
    
    var text: String = ""
    
    let isEditable = false
    
    switch columnName {
    case "Address":
      let address = UInt32(row)
      text = "\(address.toHex(numberOfDigits: 8))"
    case "CV":
      if let item {
        text = ""
        for cv in item {
          if !text.isEmpty {
            text += ", "
          }
          text += "\(cv.title)"
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
        textField.translatesAutoresizingMaskIntoConstraints = false
        let constraints : [NSLayoutConstraint] = [
          textField.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
          textField.widthAnchor.constraint(equalTo: cell.widthAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
      }
      return cell
    }
    
    return nil
    
  }
  
}
