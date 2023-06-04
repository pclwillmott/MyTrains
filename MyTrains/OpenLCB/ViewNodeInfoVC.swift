//
//  ViewNodeInfoVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 13/05/2023.
//

import Foundation
import Cocoa

class ViewNodeInfoVC: NSViewController, NSWindowDelegate {
  
  // MARK: Window & View Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }
  
  func windowWillClose(_ notification: Notification) {
  }
  
  override func viewWillAppear() {
    
    self.view.window?.delegate = self
    
    self.view.window?.title = "\(node!.manufacturerName) - \(node!.nodeModelName) (\(node!.nodeId.toHexDotFormat(numberOfBytes: 6)))"

    textView.string = node!.supportedProtocolsAsString
    
    txtAvailableCommands.string = node!.configurationOptions.availableCommandsAsString
    
    txtWriteLengths.string = node!.configurationOptions.writeLengthsAsString
    
    lblLowestAddressSpace.stringValue = "0x\(node!.configurationOptions.lowestAddressSpace.toHex(numberOfDigits: 2))"
    
    lblHighestAddressSpace.stringValue = "0x\(node!.configurationOptions.highestAddressSpace.toHex(numberOfDigits: 2))"
    
    lblName.stringValue = node!.configurationOptions.name
    
    tableViewDS.addressSpaceInformation = node!.addressSpaceInformation
    tableView.dataSource = tableViewDS
    tableView.delegate = tableViewDS
    tableView.reloadData()

  }
  
  // MARK: Private Properties
  
  private var tableViewDS = ViewNodeInfoMemorySpaceInfoTVDS()
  
  // MARK: Public Properties
  
  public var node: OpenLCBNode?

  // MARK: Outlets & Actions
  
  @IBOutlet var textView: NSTextView!
  
  @IBOutlet var txtAvailableCommands: NSTextView!
  
  @IBOutlet var txtWriteLengths: NSTextView!
  
  @IBOutlet weak var lblHighestAddressSpace: NSTextField!
  
  @IBOutlet weak var lblLowestAddressSpace: NSTextField!
  
  @IBOutlet weak var lblName: NSTextField!
  
  @IBOutlet weak var tableView: NSTableView!
  
}
