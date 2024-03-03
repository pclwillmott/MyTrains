//
//  TextViewVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 27/01/2024.
//

import Foundation
import AppKit

class TextViewVC: MyTrainsViewController {
    
  // MARK: Window & View Control
  
  override func viewWillAppear() {
    
    super.viewWillAppear()
    
//    self.view.window?.title = viewTitle
    
    self.view.window?.makeKeyAndOrderFront(self)
    
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    textView.translatesAutoresizingMaskIntoConstraints = false
    scrollView.documentView?.translatesAutoresizingMaskIntoConstraints = false
    textView.isEditable = false
    
    textView.string = viewText
    
    view.addSubview(scrollView)
    
    scrollView.documentView = textView
    scrollView.hasVerticalScroller = true

    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: view.topAnchor),
      scrollView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1.0),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.0),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20.0),
      textView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
      textView.heightAnchor.constraint(equalToConstant: 1000),
    ])
    
  }

  // MARK: Public Properties

  public var viewTitle : String = ""
  
  public var viewText : String = ""
    
  // MARK: Controls
  
  var scrollView : NSScrollView = NSScrollView()
  
  var textView = NSTextView()
  
}

