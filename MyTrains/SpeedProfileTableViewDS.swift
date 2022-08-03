//
//  SpeedProfileTableViewDS.swift
//  MyTrains
//
//  Created by Paul Willmott on 01/08/2022.
//

import Foundation
import Cocoa

public class SpeedProfileTableViewDS : NSObject, NSTableViewDataSource, NSTableViewDelegate {

  // MARK: Public Properties
  
  public var speedProfile : [SpeedProfile]?
  
  public var unitSpeed : UnitSpeed = .centimetersPerSecond 
  
  public var resultsType : SpeedProfileResultsType = .actual
  
  // MARK: NSTableViewDataSource Delegate Methods
  
  // MARK: NSTableViewDelegate Methods
  
  // Returns the number of records managed for aTableView by the data source object.
   public func numberOfRows(in tableView: NSTableView) -> Int {
     return speedProfile!.count
   }
  
  // Sets the data object for an item in the specified row and column.
  public func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
  }
  

  
  public func tableView(_ tableView: NSTableView,
                        viewFor tableColumn: NSTableColumn?,row: Int) -> NSView? {
    
    let item = speedProfile![row]
    
    let columnName = tableColumn!.identifier.rawValue
    
    let cellIdentifier = "\(columnName)CellID"
    
    var text: String = ""
    
    enum ColumnIdentifiers {
      static let Step    = "Step"
      static let Forward = "Forward"
      static let Reverse = "Reverse"
    }

    switch columnName {
    case ColumnIdentifiers.Step:
      text = "\(item.stepNumber)"
      
    case ColumnIdentifiers.Forward:
      let value = resultsType == .actual ? item.newSpeedForward : item.bestFitForward
      text = String(format: "%.1f", value * unitSpeed.fromCMS)
      
    case ColumnIdentifiers.Reverse:
      let value = resultsType == .actual ? item.newSpeedReverse : item.bestFitReverse
      text = String(format: "%.1f", value * unitSpeed.fromCMS)

    default:
      text = ""
    }

    if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
      if let textField = cell.subviews[0] as? NSTextField {
        textField.tag = row
        textField.stringValue = text
        textField.isEditable = false
      }
      return cell
    }

    return nil
    
  }
  
}
