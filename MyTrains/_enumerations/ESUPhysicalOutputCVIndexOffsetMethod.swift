// -----------------------------------------------------------------------------
// ESUPhysicalOutputCVIndexOffsetMethod.swift
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
//     03/09/2024  Paul Willmott - ESUPhysicalOutputCVIndexOffsetMethod.swift created
// -----------------------------------------------------------------------------

import Foundation
import AppKit

public enum ESUPhysicalOutputCVIndexOffsetMethod : Int, Codable, CaseIterable {
  
  // MARK: Enumeration
  
  case none = 0
  case lok5 = 1
  case lok4 = 2
  case lok3 = 3
  
  // MARK: Constructors
  
  init?(title:String) {
    for temp in ESUPhysicalOutputCVIndexOffsetMethod.allCases {
      if temp.title == title {
        self = temp
        return
      }
    }
    return nil
  }

  // MARK: Public Properties
  
  public var title : String {
    return ESUPhysicalOutputCVIndexOffsetMethod.titles[self]!
  }

  // MARK: Public Class Properties
  
  public static let titles : [ESUPhysicalOutputCVIndexOffsetMethod:String] = [
    .none : String(localized:"None"),
    .lok5 : String(localized:"Lok 5"),
    .lok4 : String(localized:"Lok 4"),
    .lok3 : String(localized:"Lok 3"),
  ]

  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    for item in ESUPhysicalOutputCVIndexOffsetMethod.allCases {
      comboBox.addItem(withObjectValue: item.title)
    }
  }

}
