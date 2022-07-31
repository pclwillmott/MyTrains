//
//  TurnoutSwitchTCV.swift
//  MyTrains
//
//  Created by Paul Willmott on 31/07/2022.
//

import Foundation
import Cocoa

class TurnoutSwitchTCV: NSTableCellView {

  // MARK: View Control

  override func draw(_ dirtyRect: NSRect) {
      super.draw(dirtyRect)

      // Drawing code here.
  }

  override func prepareForReuse() {
    super.prepareForReuse()
  }
  
  // MARK: Private Properties
  
  private var cboTurnoutDS : ComboBoxDictDS = ComboBoxDictDS()
  
  // MARK: Public Properties
  
  public var turnoutSwitch : TurnoutSwitch? {
    didSet {
      if let t = turnoutSwitch, let device = t.locoNetDevice, let layout = device.network?.layout {
        cboTurnoutDS.dictionary = layout.switchBoardTurnouts
        cboTurnout.dataSource = cboTurnoutDS
        cboTurnout.deselectItem(at: cboTurnout.indexOfSelectedItem)
        cboTurnout.selectItem(at: cboTurnoutDS.indexWithKey(key: t.switchBoardItemId) ?? -1)
        cboTurnoutIndex.deselectItem(at: cboTurnoutIndex.indexOfSelectedItem)
        cboTurnoutIndex.selectItem(at: t.turnoutIndex - 1)
        TurnoutFeedbackType.populate(comboBox: cboFeedbackType)
        cboFeedbackType.selectItem(at: t.feedbackType.rawValue)
      }
    }
  }
  
  // MARK: Outlets & Actions
  
  @IBOutlet weak var cboTurnout: NSComboBox!
  
  @IBAction func cboTurnoutAction(_ sender: NSComboBox) {
    if let item = cboTurnoutDS.editorObjectAt(index: cboTurnout.indexOfSelectedItem) as? SwitchBoardItem {
      turnoutSwitch?.nextSwitchBoardItemId = item.primaryKey
    }
  }
  
  @IBOutlet weak var cboTurnoutIndex: NSComboBox!
  
  @IBAction func cboTurnoutIndexAction(_ sender: NSComboBox) {
    turnoutSwitch?.nextTurnoutIndex = cboTurnoutIndex.indexOfSelectedItem + 1
  }
  
  @IBOutlet weak var cboFeedbackType: NSComboBox!
  
  @IBAction func cboFeedbackTypeAction(_ sender: NSComboBox) {
    turnoutSwitch?.nextFeedbackType = TurnoutFeedbackType(rawValue: cboFeedbackType.indexOfSelectedItem) ?? .none
  }
  
  @IBAction func btnReset(_ sender: NSButton) {
    cboTurnout.deselectItem(at: cboTurnout.indexOfSelectedItem)
    turnoutSwitch?.nextSwitchBoardItemId = -1
    cboTurnoutIndex.selectItem(at: 0)
    turnoutSwitch?.nextTurnoutIndex = 1
    cboFeedbackType.selectItem(at: 0)
    turnoutSwitch?.nextFeedbackType = .none
  }
  
}
