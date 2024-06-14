//
//  SwitchboardEditorViewDelegate.swift
//  MyTrains
//
//  Created by Paul Willmott on 20/04/2024.
//

import Foundation

@objc protocol SwitchboardEditorViewDelegate {
  @objc optional func selectedItemChanged(_ switchboardEditorView:SwitchboardEditorView)
  @objc optional func groupChanged(_ switchboardEditorView:SwitchboardEditorView)
}
