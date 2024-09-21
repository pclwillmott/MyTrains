//
//  UserSettings.swift
//  MyTrains
//
//  Created by Paul Willmott on 15/04/2024.
//

import Foundation
import AppKit

public class UserSettings {
  
  // MARK: Constructors & Destructors
  
  init(window:NSWindow) {
    self.window = window
    autosave = window.frameAutosaveName
  }
  
  // MARK: Private Properties
  
  private var autosave : String
  
  public weak var window : NSWindow?
  
  public weak var splitView : NSSplitView? {
    didSet {
      update()
    }
  }
  
  public weak var splitView2 : NSSplitView? {
    didSet {
      update()
    }
  }

  public weak var splitView3 : NSSplitView? {
    didSet {
      update()
    }
  }

  public weak var tableView : NSTableView? {
    didSet {
      update()
    }
  }

  public weak var tableView2 : NSTableView? {
    didSet {
      update()
    }
  }

  public weak var tableView3 : NSTableView? {
    didSet {
      update()
    }
  }

  public weak var tableView4 : NSTableView? {
    didSet {
      update()
    }
  }

  public weak var tableView5 : NSTableView? {
    didSet {
      update()
    }
  }

  // MARK: Public Properties
  
  public weak var node : OpenLCBNodeVirtual? {
    didSet {
      update()
    }
  }
  
  // MARK: Private Methods
  
  private func update() {
    
    window?.setFrameAutosaveName(key())
    
    splitView?.autosaveName  = key(forKey: "SPLIT-VIEW")
    splitView2?.autosaveName = key(forKey: "SPLIT-VIEW2")
    splitView3?.autosaveName = key(forKey: "SPLIT-VIEW3")

    tableView?.autosaveTableColumns = true
    tableView?.autosaveName = key(forKey: "TABLE-VIEW7")
    tableView2?.autosaveTableColumns = true
    tableView2?.autosaveName = key(forKey: "TABLE-VIEW8")
    tableView3?.autosaveTableColumns = true
    tableView3?.autosaveName = key(forKey: "TABLE-VIEW12")
    tableView4?.autosaveTableColumns = true
    tableView4?.autosaveName = key(forKey: "TABLE-VIEW10")
    tableView5?.autosaveTableColumns = true
    tableView5?.autosaveName = key(forKey: "TABLE-VIEW11")
    
  }
  
  private func key(forKey:String? = nil) -> String {
    return "\(autosave)\(node == nil ? "" : "-\(node!.nodeId.dotHex(numberOfBytes: 6))")\(forKey == nil ? "" : "-\(forKey!)")"
  }
  
  // MARK: Public Methods
  
  /**
   -setObject:forKey: immediately stores a value (or removes the value if nil is passed as the value) for the provided key in the search list entry for the receiver's suite name in the current user and any host, then asynchronously stores the value persistently, where it is made available to other processes.
   */
  open func set(_ value:Any?, forKey:String) {
    UserDefaults.standard.set(value, forKey: key(forKey: forKey))
  }
    
  /**
   -objectForKey: will search the receiver's search list for a default with the key 'defaultName' and return it. If another process has changed defaults in the search list, NSUserDefaults will automatically update to the latest values. If the key in question has been marked as ubiquitous via a Defaults Configuration File, the latest value may not be immediately available, and the registered value will be returned instead.
   */
  open func object(forKey: String) -> Any? {
    return UserDefaults.standard.object(forKey: key(forKey: forKey))
  }
  
  /// -removeObjectForKey: is equivalent to -[... setObject:nil forKey:defaultName]
  open func removeObject(forKey: String) {
    UserDefaults.standard.removeObject(forKey: key(forKey: forKey))
  }
  
  /// -stringForKey: is equivalent to -objectForKey:. If a non-string is found, nil will be returned.
  open func string(forKey: String) -> String? {
    return UserDefaults.standard.object(forKey: key(forKey: forKey)) as? String
  }

  /// -arrayForKey: is equivalent to -objectForKey:, except that it will return nil if the value is not an NSArray.
  open func array(forKey: String) -> [Any]? {
    return UserDefaults.standard.array(forKey: key(forKey: forKey))
  }

  /// -dictionaryForKey: is equivalent to -objectForKey:, except that it will return nil if the value is not an NSDictionary.
  open func dictionary(forKey: String) -> [String : Any]? {
    return UserDefaults.standard.dictionary(forKey: key(forKey: forKey))
  }

  /// -dataForKey: is equivalent to -objectForKey:, except that it will return nil if the value is not an NSData.
  open func data(forKey: String) -> Data? {
    return UserDefaults.standard.data(forKey: key(forKey: forKey))
  }
  
  /// -stringForKey: is equivalent to -objectForKey:, except that it will return nil if the value is not an NSArray<NSString *>. Note that unlike -stringForKey:, NSNumbers are not converted to NSStrings.
  open func stringArray(forKey: String) -> [String]? {
    return UserDefaults.standard.stringArray(forKey: key(forKey: forKey))
  }
  
  /**
   -integerForKey: is equivalent to -objectForKey:, except that it converts the returned value to an NSInteger. If the value is an NSNumber, the result of -integerValue will be returned. If the value is an NSString, it will be converted to NSInteger if possible. If the value is a boolean, it will be converted to either 1 for YES or 0 for NO. If the value is absent or can't be converted to an integer, 0 will be returned.
   */
  open func integer(forKey: String) -> Int {
    return UserDefaults.standard.integer(forKey: key(forKey: forKey))
  }

  /// -stateForKey: is equivalent to -objectForKey:.
  open func state(forKey: String) -> NSControl.StateValue {
    return NSControl.StateValue(rawValue: UserDefaults.standard.integer(forKey: key(forKey: forKey)))
  }

  /// -uInt64ForKey: is equivalent to -objectForKey:. If a non-UInt64 is found, nil will be returned.
  open func uInt64(forKey: String) -> UInt64? {
    return UserDefaults.standard.object(forKey: key(forKey: forKey)) as? UInt64
  }

  /// -cgFloatForKey: is equivalent to -objectForKey:. If a non-CGFloat is found, nil will be returned.
  open func cgFloat(forKey: String) -> CGFloat? {
    return UserDefaults.standard.object(forKey: key(forKey: forKey)) as? CGFloat
  }

  /// -floatForKey: is similar to -integerForKey:, except that it returns a float, and boolean values will not be converted.
  open func float(forKey: String) -> Float {
    return UserDefaults.standard.float(forKey: key(forKey: forKey))
  }
  
  /// -doubleForKey: is similar to -integerForKey:, except that it returns a double, and boolean values will not be converted.
  open func double(forKey: String) -> Double {
    return UserDefaults.standard.double(forKey: key(forKey: forKey))
  }

  /**
   -boolForKey: is equivalent to -objectForKey:, except that it converts the returned value to a BOOL. If the value is an NSNumber, NO will be returned if the value is 0, YES otherwise. If the value is an NSString, values of "YES" or "1" will return YES, and values of "NO", "0", or any other string will return NO. If the value is absent or can't be converted to a BOOL, NO will be returned.
   */
  open func bool(forKey: String) -> Bool {
    return UserDefaults.standard.bool(forKey: key(forKey: forKey))
  }

  /**
   -URLForKey: is equivalent to -objectForKey: except that it converts the returned value to an NSURL. If the value is an NSString path, then it will construct a file URL to that path. If the value is an archived URL from -setURL:forKey: it will be unarchived. If the value is absent or can't be converted to an NSURL, nil will be returned.
   */
  open func url(forKey: String) -> URL? {
    return UserDefaults.standard.url(forKey: key(forKey: forKey))
  }

  /// -setInteger:forKey: is equivalent to -setObject:forKey: except that the value is converted from an NSInteger to an NSNumber.
  open func set(_ value: Int, forKey: String) {
    UserDefaults.standard.set(value, forKey: key(forKey: forKey))
  }

  /// -setStateValue:forKey: is equivalent to -setObject:forKey: except that the value is converted from a StateValue to an NSNumber, where 1 = .on and 0 = .off.
  open func set(_ value: NSControl.StateValue, forKey: String) {
    UserDefaults.standard.set(value.rawValue, forKey: key(forKey: forKey))
  }

  /// -setFloat:forKey: is equivalent to -setObject:forKey: except that the value is converted from a float to an NSNumber.
  open func set(_ value: Float, forKey: String) {
    UserDefaults.standard.set(value, forKey: key(forKey: forKey))
  }

  /// -setDouble:forKey: is equivalent to -setObject:forKey: except that the value is converted from a double to an NSNumber.
  open func set(_ value: Double, forKey: String) {
    UserDefaults.standard.set(value, forKey: key(forKey: forKey))
  }

  /// -setBool:forKey: is equivalent to -setObject:forKey: except that the value is converted from a BOOL to an NSNumber.
  open func set(_ value: Bool, forKey: String) {
    UserDefaults.standard.set(value, forKey: key(forKey: forKey))
  }

  /// -setURL:forKey is equivalent to -setObject:forKey: except that the value is archived to an NSData. Use -URLForKey: to retrieve values set this way.
  open func set(_ url: URL?, forKey: String) {
    UserDefaults.standard.set(url, forKey: key(forKey: forKey))
  }

  // MARK: Public Class Methods
  
}
