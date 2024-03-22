//
//  ComboBoxDBDS.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/12/2021.
//

import Foundation
import Cocoa

class ComboBoxDBDS : NSObject, NSComboBoxDataSource, NSComboBoxDelegate {
  
  // MARK: Constructors
  
  init(tableName: String, codeColumn: String, displayColumn: String, sortColumn:String) {
    
    self._tableName     = tableName
    self._codeColumn    = codeColumn
    self._displayColumn = displayColumn
    self._sortColumn    = sortColumn
    
    super.init()
    
    reloadData()
    
    addInit()
    
  }
  
  init(tableName: String, codeColumn: String, displayColumn: String, sortColumn:String, groupItems: Bool) {
    
    self._tableName     = tableName
    self._codeColumn    = codeColumn
    self._displayColumn = displayColumn
    self._sortColumn    = sortColumn
    self._groupItems    = groupItems
    
    super.init()
    
    reloadData()
    
    addInit()
    
  }
  
  deinit {
    _items.removeAll()
    addDeinit()
  }
  
  // MARK: Private Properties
  
  
  private var _tableName : String
  
  private var _displayColumn : String
  
  private var _codeColumn : String
  
  private var _sortColumn : String
  
  private var _groupItems : Bool = false
  
  private var _items : [ComboItem] = []
  
  // MARK: Public Methods
  
  public func reloadData() {
    
    let conn = Database.getConnection()
    
    let shouldClose = conn.state != .Open
     
    if shouldClose {
       _ = conn.open()
    }
     
    let cmd = conn.createCommand()
     
    var sql : String = ""
    
    if _groupItems {
      sql = "SELECT [\(_sortColumn)] FROM [\(_tableName)] GROUP BY [\(_sortColumn)]"
    }
    else {
      sql = "SELECT [\(_codeColumn)], [\(_displayColumn)] FROM [\(_tableName)] ORDER BY [\(_sortColumn)]"
    }
    
    cmd.commandText = sql

    if let reader = cmd.executeReader() {
         
     _items.removeAll()
     
      while reader.read() {
        var code : Int = 0
        var title : String = ""
        if _groupItems {
          if !reader.isDBNull(index: 0) {
            title = reader.getString(index: 0) ?? ""
          }
        }
        else {
          code = reader.getInt(index: 0)!
          if !reader.isDBNull(index: 1) {
            title = reader.getString(index: 1)!
          }

        }
       _items.append(ComboItem(code: code, title: title))
      }
         
      reader.close()
         
    }
    
    if shouldClose {
      conn.close()
    }

  }

  // MARK: NSComboBoxDataSource Methods

  // Returns the first item from the pop-up list that starts with the text the user has typed.

  public func comboBox(_ comboBox: NSComboBox, completedString string: String) -> String? {
    if string.count > 1 {
      for item in _items {
        if item.title.prefix(string.count) == string {
          return item.title
        }
      }
    }
    return nil
  }
  
  // Returns the index of the combo box item matching the specified string.

  public func comboBox(_ comboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
    var index = 0
    for item in _items {
      if item.title == string {
        return index
      }
      index += 1
    }
    return -1
  }
 
  //  Returns the object that corresponds to the item at the specified index in the combo box.

  public func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
    if index < 0 || index >= _items.count {
      return nil
    }
    return _items[index].title
  }

  //  Returns the row code that corresponds to the item at the specified index in the combo box.
  
  public func comboBox(_ comboBox: NSComboBox, codeForItemAt index: Int) -> Int? {
    if index < 0 || index >= _items.count {
      return nil
    }
    return _items[index].code
  }

  public func codeForItemAt(index: Int) -> Int? {
    if index < 0 || index >= _items.count {
      return nil
    }
    return _items[index].code
  }

  // Returns the number of items that the data source manages for the combo box.

  public func numberOfItems(in comboBox: NSComboBox) -> Int {
    return _items.count
  }
  
  // Returns the code of the combo box item matching the specified string.

   public func codeOfItemWithStringValue(string: String) -> Int {
     var index = 0
     for item in _items {
       if item.title == string {
        return item.code
       }
       index += 1
     }
     return -1
   }
  
  // Returns the index of the combo box item matching the specified code.

   public func indexOfItemWithCodeValue(code: Int) -> Int? {
     var index = 0
     while index < _items.count {
       if _items[index].code == code {
        return index
       }
       index += 1
     }
     return nil
   }
  
}

class ComboItem {
  
  public var code : Int
  public var title : String
  
  init(code:Int, title:String) {
    self.code = code
    self.title = title
    addInit()
  }
  
  deinit {
    addDeinit()
  }
  
}
