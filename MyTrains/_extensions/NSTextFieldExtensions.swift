//
//  NSTextFieldExtensions.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/04/2024.
//

import Foundation
import AppKit

  extension NSControl {
    
    public var fontSize : CGFloat? {
      get {
        return font?.pointSize
      }
      set(value) {
        font = NSFont(name: font!.familyName!, size: value!)
      }
    }

}
