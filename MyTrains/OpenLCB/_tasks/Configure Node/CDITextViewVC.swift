//
//  CDITextViewVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/01/2024.
//

import Foundation
import AppKit

class CDITextViewVC: NSViewController, NSWindowDelegate {
  
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
    
  }
  
  // MARK: Public Properties
  
  public var cdiText : String = "" {
    didSet {
      textView.string = cdiText
    }
  }
  
  public var cdiInfo : String = "" {
    didSet {
      lblCDIInfo.stringValue = cdiInfo
    }
  }
    
  public var name : String = "" {
    didSet {
      self.view.window?.title = name
    }
  }
  
  // MARK: Outlets & Actions
  
  @IBOutlet var textView: NSTextView!
  
  @IBOutlet weak var lblCDIInfo: NSTextField!
  
}
