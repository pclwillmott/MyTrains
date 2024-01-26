//
//  CountryCode.swift
//  MyTrains
//
//  Created by Paul Willmott on 26/01/2024.
//

import Foundation
import AppKit

public enum CountryCode : UInt16 {
  
  case unitedStates  = 840
  case china         = 156
  case russia        = 643
  case india         = 356
  case canada        = 124
  case germany       = 276
  case argentina     = 32
  case australia     = 36
  case brazil        = 76
  case france        = 250
  case japan         = 392
  case mexico        = 484
  case southAfrica   = 710
  case romania       = 642
  case italy         = 380
  case poland        = 616
  case ukraine       = 804
  case iran          = 364
  case spain         = 724
  case unitedKingdom = 826
  
  // MARK: Public Properties
  
  public var title : String {
    return CountryCode.titles[self]!
  }
  
  // MARK: Private Class Properties
  
  private static let titles : [CountryCode:String] = [
    .unitedStates  : String(localized: "United States of America", comment: "This is the name of a country."),
    .china         : String(localized: "China", comment: "This is the name of a country."),
    .russia        : String(localized: "Russia", comment: "This is the name of a country."),
    .india         : String(localized: "India", comment: "This is the name of a country."),
    .canada        : String(localized: "Canada", comment: "This is the name of a country."),
    .germany       : String(localized: "Germany", comment: "This is the name of a country."),
    .argentina     : String(localized: "Argentina", comment: "This is the name of a country."),
    .australia     : String(localized: "Australia", comment: "This is the name of a country."),
    .brazil        : String(localized: "Brazil", comment: "This is the name of a country."),
    .france        : String(localized: "France", comment: "This is the name of a country."),
    .japan         : String(localized: "Japan", comment: "This is the name of a country."),
    .mexico        : String(localized: "Mexico", comment: "This is the name of a country."),
    .southAfrica   : String(localized: "South Africa", comment: "This is the name of a country."),
    .romania       : String(localized: "Romania", comment: "This is the name of a country."),
    .italy         : String(localized: "Italy", comment: "This is the name of a country."),
    .poland        : String(localized: "Poland", comment: "This is the name of a country."),
    .ukraine       : String(localized: "Ukraine", comment: "This is the name of a country."),
    .iran          : String(localized: "Iran", comment: "This is the name of a country."),
    .spain         : String(localized: "Spain", comment: "This is the name of a country."),
    .unitedKingdom : String(localized: "United Kingdom", comment: "This is the name of a country."),
  ]

  private static var map : String {
    
    var items : [CountryCode] = []
    
    for (code, _) in titles {
      items.append(code)
    }
    
    items.sort {$0.title < $1.title}
    
    var map = "<default>\(defaultValue.rawValue)</default>\n<map>\n"

    for item in items {
      map += "<relation><property>\(item.rawValue)</property><value>\(item.title)</value></relation>\n"
    }

    map += "</map>\n"
    
    return map
    
  }
  
  // MARK: Public Class Properties
  
  public static let defaultValue : CountryCode = .unitedStates

  public static let mapPlaceholder = CDI.COUNTRY_CODE

  // MARK: Public Class Methods

  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: mapPlaceholder, with: map)
  }

}
