//
//  Scale.swift
//  MyTrains
//
//  Created by Paul Willmott on 11/01/2024.
//

import Foundation

public enum Scale : UInt8 {
  
  case scale1to450     = 1
  case scale1to300     = 2
  case scale1to220     = 3
  case scale1to180     = 4
  case scale1to160     = 5
  case scale1to152     = 6
  case scale1to148     = 7
  case scale1to150     = 8
  case scale1to120     = 9
  case scale1to110     = 10
  case scale1to102     = 11
  case scale1to87dot1  = 12
  case scale1to87      = 13
  case scale1to80      = 14
  case scale1to76dot2  = 0
  case scale1to76      = 15
  case scale1to64      = 16
  case scale1to60      = 17
  case scale1to50      = 18
  case scale1to48      = 19
  case scale1to45      = 20
  case scale1to43dot5  = 21
  case scale1to35      = 22
  case scale1to32      = 23
  case scale1to30      = 24
  case scale1to27      = 25
  case scale1to22dot6  = 26
  case scale1to22dot5  = 27
  case scale1to20dot32 = 28
  case scale1to20dot3  = 29
  case scale1to16      = 30
  case scale1to12      = 31
  case scale1to11      = 32
  case scale1to8       = 33
  case scale1to7dot5   = 34
  case scale1to5dot5   = 35

  // MARK: Public Properties
  
  public var ratio : Double {
    
    switch self {
    case .scale1to450:
      return 450.0
    case .scale1to300:
      return 300.0
    case .scale1to220:
      return 220.0
    case .scale1to180:
      return 180.0
    case .scale1to160:
      return 160.0
    case .scale1to152:
      return 152.0
    case .scale1to148:
      return 148.0
    case .scale1to150:
      return 150.0
    case .scale1to120:
      return 120.0
    case .scale1to110:
      return 110.0
    case .scale1to102:
      return 102.0
    case .scale1to87dot1:
      return 87.1
    case .scale1to87:
      return 87.0
    case .scale1to80:
      return 80.0
    case .scale1to76dot2:
      return 76.2
    case .scale1to76:
      return 76.0
    case .scale1to64:
      return 64.0
    case .scale1to60:
      return 60.0
    case .scale1to50:
      return 50.0
    case .scale1to48:
      return 48.0
    case .scale1to45:
      return 45.0
    case .scale1to43dot5:
      return 43.5
    case .scale1to35:
      return 35.0
    case .scale1to32:
      return 32.0
    case .scale1to30:
      return 30.0
    case .scale1to27:
      return 27.0
    case .scale1to22dot6:
      return 22.6
    case .scale1to22dot5:
      return 22.5
    case .scale1to20dot32:
      return 20.32
    case .scale1to20dot3:
      return 20.3
    case .scale1to16:
      return 16.0
    case .scale1to12:
      return 12.0
    case .scale1to11:
      return 11.0
    case .scale1to8:
      return 8.0
    case .scale1to7dot5:
      return 7.5
    case .scale1to5dot5:
      return 5.5
    }
    
  }
  
  public var title : String {
    
    let formatter = NumberFormatter()
    
    formatter.usesGroupingSeparator = true
    formatter.groupingSize = 3

    formatter.alwaysShowsDecimalSeparator = false
    formatter.minimumFractionDigits = 0
    formatter.maximumFractionDigits = 2

    return String(localized: "1 : \(formatter.string(from: self.ratio as NSNumber)!)", comment: "This is a ratio used for layout scale, e.g. 1 : 76.2")

  }

  
  // MARK: Private Class Properties
  
  private static var map : String {
    
    var scales : [Scale] = [
      scale1to450,
      scale1to300,
      scale1to220,
      scale1to180,
      scale1to160,
      scale1to152,
      scale1to148,
      scale1to150,
      scale1to120,
      scale1to110,
      scale1to102,
      scale1to87dot1,
      scale1to87,
      scale1to80,
      scale1to76dot2,
      scale1to76,
      scale1to64,
      scale1to60,
      scale1to50,
      scale1to48,
      scale1to45,
      scale1to43dot5,
      scale1to35,
      scale1to32,
      scale1to30,
      scale1to27,
      scale1to22dot6,
      scale1to22dot5,
      scale1to20dot32,
      scale1to20dot3,
      scale1to16,
      scale1to12,
      scale1to11,
      scale1to8,
      scale1to7dot5,
      scale1to5dot5,
    ]
    
    scales.sort {$0.ratio > $1.ratio}
    
    var map = "<default>\(defaultValue.rawValue)</default>\n<map>\n"
    
    for scale in scales {
      map += "<relation><property>\(scale.rawValue)</property><value>\(scale.title)</value></relation>\n"
    }

    map += "</map>\n"

    return map

  }
  
  // MARK: Public Class Properties
  
  public static let defaultValue : Scale = .scale1to76dot2
  
  public static let mapPlaceholder = CDI.LAYOUT_SCALE
  
  // MARK: Public Class Methods
  
  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: mapPlaceholder, with: map)
  }
  
}
