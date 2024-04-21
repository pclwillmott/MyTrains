//
//  NSScrollViewExtensions.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/04/2024.
//

import Foundation
import AppKit

extension NSScrollView {
  
  /// This must be done after the auto-sizing has completed.
  public func scrollToTop() {
    guard let documentView else {
      return
    }
    if !isFlipped {
      contentView.scroll(to: .zero)
    }
    else {
      contentView.scroll(NSPoint(x: 0, y: documentView.bounds.height))
    }
  }

  /// This must be done after the auto-sizing has completed.
  public func scrollToBottom() {
    guard let documentView else {
      return
    }
    if !isFlipped {
      contentView.scroll(NSPoint(x: 0, y: documentView.bounds.height))
    }
    else {
      contentView.scroll(to: .zero)
    }
  }

}
