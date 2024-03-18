//
//  MyTrainsViewController.swift
//  MyTrains
//
//  Created by Paul Willmott on 02/03/2024.
//

import Foundation
import AppKit

public class MyTrainsViewController: NSViewController, NSWindowDelegate {
  
  // MARK: View Control
  
  public override func viewDidLoad() {

    super.viewDidLoad()

    #if DEBUG
    debugLog("viewDidLoad")
    #endif
    
    // The override function sets the view type.

  }
  
  public override func viewWillAppear() {

    super.viewWillAppear()
    
    #if DEBUG
    debugLog("viewWillAppear")
    #endif

    view.window?.delegate = self
    
  }
  
  public override func viewDidAppear() {
    
    super.viewDidAppear()
    
    #if DEBUG
    debugLog("viewDidAppear")
    #endif
    
    if let viewType {
      appNode?.setViewState(type: viewType, isOpen: true)
    }
    
  }
  
  public func windowShouldClose(_ sender: NSWindow) -> Bool {
    
    #if DEBUG
    debugLog("windowShouldClose")
    #endif
    
    return true
    
  }
  
  public func windowWillClose(_ notification: Notification) {
    
    #if DEBUG
    debugLog("windowWillClose")
    #endif
    
    appDelegate.removeViewController(self)

    if let viewType, isManualClose {
      appNode?.setViewState(type: viewType, isOpen: false)
    }
    
  }
  
  public override func viewWillDisappear() {
    
    super.viewWillDisappear()
    
    #if DEBUG
    debugLog("viewWillDisappear")
    #endif
    
    removeAllViews(view: view)
    
  }

  public override func viewDidDisappear() {
    
    super.viewWillDisappear()
    
    #if DEBUG
    debugLog("viewDidDisappear")
    #endif
    
  }
  
  // MARK: Public Properties
  
  public var objectIdentifier : ObjectIdentifier?
  
  public var viewType : MyTrainsViewType?
  
  public var isManualClose = true

  // MARK: Private Methods
  
  private func removeAllViews(view:NSView) {
    
    if let stackView = view as? NSStackView {
      for v in stackView.arrangedSubviews {
        removeAllViews(view: v)
        stackView.removeArrangedSubview(v)
      }
    }
    else if let scrollView = view as? NSScrollView {
      scrollView.documentView = nil
    }
    else {
      for view in view.subviews {
        removeAllViews(view: view)
      }
      view.subviews.removeAll(keepingCapacity: false)
    }
  }
  
  // MARK: Public Methods
  
  public func showWindow() {
    view.window?.windowController?.showWindow(nil)
  }
  
  public func closeWindow() {
    isManualClose = false
    view.window?.close()
  }
  
  public func refreshRequired() {
  }
  
}
