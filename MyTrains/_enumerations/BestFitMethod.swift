//
//  BestFitMethod.swift
//  MyTrains
//
//  Created by Paul Willmott on 03/08/2022.
//

import Foundation
import AppKit

public enum BestFitMethod : UInt8, CaseIterable {
  
  // MARK: Enumeration
  
  case straightLine         = 0
  case centralMovingAverage = 1

  // MARK: Constructors
  
  init?(title:String) {
    for temp in BestFitMethod.allCases {
      if temp.title == title {
        self = temp
        return
      }
    }
    return nil
  }

  // MARK: Public Properties
  
  public var title : String {
    
    let titles : [BestFitMethod:String] = [
      .straightLine: String(localized: "Straight Line", comment: "Used by combobox to select curve fitting method)"),
      .centralMovingAverage: String(localized: "Moving Average", comment: "Used by combobox to select curve fitting method)"),
    ]
    
    return titles[self]!
    
  }
  
  // MARK: Public Methods
  
  public func fit(sampleTable:[[Double]], dataSet:Int) -> [[Double]] {
    
    var result : [[Double]] = []
    
    switch self {
    case .straightLine:

      // https://stackoverflow.com/questions/5083465/fast-efficient-least-squares-fit-algorithm-in-c
      
      let n = Double(sampleTable.count)
      
      var sumx  : Double = 0.0  /* sum of x     */
      var sumx2 : Double = 0.0  /* sum of x**2  */
      var sumxy : Double = 0.0  /* sum of x * y */
      var sumy  : Double = 0.0  /* sum of y     */
      var sumy2 : Double = 0.0  /* sum of y**2  */

      for row in sampleTable {
        let x = row[0]
        let y = row[dataSet]
          sumx  += x
          sumx2 += x * x
          sumxy += x * y
          sumy  += y
          sumy2 += y * y
      }
      
      let denom = (n * sumx2 - sumx * sumx)
      
      var m : Double?
      var b : Double?
      var r : Double?
      
      if (denom != 0.0) {
        m = (n * sumxy  -  sumx * sumy) / denom;
        b = (sumy * sumx2  -  sumx * sumxy) / denom;
        r = (sumxy - sumx * sumy / n) /    /* compute correlation coeff */
                sqrt((sumx2 - sumx * sumx / n) *
                (sumy2 - sumy * sumy / n))
      }
      
      // y = m * x + b

      if let m, let b {
        for row in sampleTable {
          let x = row[0]
          let y = m * x + b
          result.append([x, y])
        }
      }

    case .centralMovingAverage:
      
      for row in sampleTable {
        result.append([row[0], 0.0])
      }
      
      for index in 1 ... sampleTable.count - 2 {
        result[index][1] = (sampleTable[index - 1][dataSet] + sampleTable[index][dataSet] + sampleTable[index + 1][dataSet]) / 3.0
      }
      result[sampleTable.count - 1][1] = (sampleTable[sampleTable.count - 2][dataSet] + sampleTable[sampleTable.count - 1][dataSet] ) / 2.0

    }
    
    return result
    
  }
  
  // MARK: Public Class Properties
  
  public static let defaultValue : BestFitMethod = .straightLine
  
  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    for item in BestFitMethod.allCases {
      comboBox.addItem(withObjectValue: item.title)
    }
    select(comboBox: comboBox, value: .defaultValue)
  }
  
  public static func select(comboBox:NSComboBox, value:BestFitMethod) {
    comboBox.selectItem(at: Int(value.rawValue))
  }
  
  public static func selected(comboBox: NSComboBox) -> BestFitMethod {
    return BestFitMethod(rawValue: UInt8(comboBox.indexOfSelectedItem)) ?? defaultValue
  }
  
}
