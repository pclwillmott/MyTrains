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
    
  }
  
  // MARK: Public Variables
  
  public var node: OpenLCBNode?

  // MARK: Outlets & Actions
  
  @IBOutlet var textView: NSTextView!
  
}
