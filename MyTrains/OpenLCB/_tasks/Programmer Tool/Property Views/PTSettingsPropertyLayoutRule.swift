//
//  PTSettingsPropertyLayoutRule.swift
//  MyTrains
//
//  Created by Paul Willmott on 26/07/2024.
//

import Foundation

public typealias PTSettingsPropertyLayoutRule = (
  property1      : ProgrammerToolSettingsProperty,
  testType1      : PTLayoutRuleTestType,
  testValue1     : String,
  operator       : PTLayoutRuleOperator?,
  property2      : ProgrammerToolSettingsProperty?,
  testType2      : PTLayoutRuleTestType?,
  testValue2     : String?,
  actionProperty : Set<ProgrammerToolSettingsProperty>,
  actionType     : PTLayoutRuleActionType
)

public enum PTLayoutRuleTestType {
  
  // MARK: Enumeration
  
  case equal
  case notEqual
  
}

public enum PTLayoutRuleActionType {
  
  // MARK: Enumeration
  
  case setIsHiddenToTestResult
  case setIsExtantToTestResult
  
}

public enum PTLayoutRuleOperator {
  
  // MARK: Enumeration
  
  case and
  case or
  
}

