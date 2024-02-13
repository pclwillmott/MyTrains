//
//  CDIDataViewDelegate.swift
//  MyTrains
//
//  Created by Paul Willmott on 03/01/2024.
//

import Foundation
import AppKit

@objc protocol CDIDataViewDelegate {
  @objc optional func cdiDataViewReadData(_ dataView:CDIDataView)
  @objc optional func cdiDataViewWriteData(_ dataView:CDIDataView)
  @objc optional func cdiDataViewSetWriteAllEnabledState(_ isEnabled:Bool)
  @objc optional func cdiDataViewGetNewEventId(textField:NSTextField)
}
