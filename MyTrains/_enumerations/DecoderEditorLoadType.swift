// -----------------------------------------------------------------------------
// DecoderEditorLoadType.swift
// MyTrains
//
// Copyright © 2024 Paul C. L. Willmott. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy 
// of this software and associated documentation files (the “Software”), to deal 
// in the Software without restriction, including without limitation the rights 
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
// copies of the Software, and to permit persons to whom the Software is 
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in 
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
// SOFTWARE.
// -----------------------------------------------------------------------------
//
// Revision History:
//
//     30/08/2024  Paul Willmott - DecoderEditorLoadType.swift created
// -----------------------------------------------------------------------------

import Foundation
import AppKit

public enum DecoderEditorLoadType : Int, CaseIterable {
  
  // MARK: Enumeration
  
  case cvsAndDefaults = 0xffffffff
  case lastWrite      = 0xfffffffe
  case cvMapping0000  = 0x00000000
  case cvMapping00E0  = 0x000000e0
  case cvMapping01C0  = 0x000001c0
  case cvMapping02A0  = 0x000002a0
  case cvMapping0380  = 0x00000380
  case cvMapping0460  = 0x00000460
  case cvMapping0540  = 0x00000540
  case cvMapping0620  = 0x00000620
  case cvMapping0700  = 0x00000700
  case cvMapping07E0  = 0x000007e0
  case cvMapping08C0  = 0x000008c0
  case cvMapping09A0  = 0x000009a0

  // MARK: Constructors
  
  init?(title:String) {
    for temp in DecoderEditorLoadType.allCases {
      if temp.title == title {
        self = temp
        return
      }
    }
    return nil
  }

  // MARK: Public Properties
  
  public var title : String {
    return DecoderEditorLoadType.titles[self]!
  }

  // MARK: Public Class Properties
  
  public static let titles : [DecoderEditorLoadType:String] = [
    .cvsAndDefaults : String(localized:"CVs and Default Values"),
    .lastWrite      : String(localized:"Last Write"),
    .cvMapping0000  : String(localized:"CV Mapping - 0x0000"),
    .cvMapping00E0  : String(localized:"CV Mapping - 0x00E0"),
    .cvMapping01C0  : String(localized:"CV Mapping - 0x01C0"),
    .cvMapping02A0  : String(localized:"CV Mapping - 0x02A0"),
    .cvMapping0380  : String(localized:"CV Mapping - 0x0380"),
    .cvMapping0460  : String(localized:"CV Mapping - 0x0460"),
    .cvMapping0540  : String(localized:"CV Mapping - 0x0540"),
    .cvMapping0620  : String(localized:"CV Mapping - 0x0620"),
    .cvMapping0700  : String(localized:"CV Mapping - 0x0700"),
    .cvMapping07E0  : String(localized:"CV Mapping - 0x07E0"),
    .cvMapping08C0  : String(localized:"CV Mapping - 0x08C0"),
    .cvMapping09A0  : String(localized:"CV Mapping - 0x09A0"),
  ]

  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    for item in DecoderEditorLoadType.allCases {
      comboBox.addItem(withObjectValue: item.title)
    }
  }

}
