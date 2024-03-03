//
//  CDITextViewVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/01/2024.
//

import Foundation
import AppKit

class CDITextViewVC: MyTrainsViewController {
  
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
