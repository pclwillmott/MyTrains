//
//  SensorTCV.swift
//  MyTrains
//
//  Created by Paul Willmott on 04/07/2022.
//

import Cocoa

class SensorTCV: NSTableCellView {

  // MARK: View Control

  override func draw(_ dirtyRect: NSRect) {
      super.draw(dirtyRect)

      // Drawing code here.
  }

  override func prepareForReuse() {
    super.prepareForReuse()
  }
  
  // MARK: Private Properties
  
  private var cboBlockDS : ComboBoxDictDS = ComboBoxDictDS()
  
  // MARK: Public Properties
  
  public var sensor : Sensor? {
    didSet {
      if let s = sensor, let device = s.locoNetDevice, let layout = device.network?.layout {
        cboBlockDS.dictionary = layout.switchBoardBlocks
        cboBlock.dataSource = cboBlockDS
        cboBlock.deselectItem(at: cboBlock.indexOfSelectedItem)
        cboBlock.selectItem(at: cboBlockDS.indexWithKey(key: s.switchBoardItemId) ?? -1)
      }
    }
  }
  
  // MARK: Outlets & Actions
  
  @IBOutlet weak var cboBlock: NSComboBox!
  
  @IBAction func cboBlockAction(_ sender: NSComboBox) {
    if let item = cboBlockDS.editorObjectAt(index: cboBlock.indexOfSelectedItem) as? SwitchBoardItem {
      sensor?.nextSwitchBoardItemId = item.primaryKey
    }
  }
  
  @IBAction func btnClearAction(_ sender: NSButton) {
    cboBlock.deselectItem(at: cboBlock.indexOfSelectedItem)
    sensor?.nextSwitchBoardItemId = -1
  }
  
}
