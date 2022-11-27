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
      if let sensor = self.sensor {
        SensorType.populate(comboBox: cboSensorType)
        SensorType.select(comboBox: cboSensorType, value: sensor.sensorType)
        txtAddress.integerValue = sensor.sensorAddress
        txtDelayOn.integerValue = sensor.delayOn
        txtDelayOff.integerValue = sensor.delayOff
        chkInverted.boolValue = sensor.inverted
      }
    }
  }
  
  // MARK: Outlets & Actions
  
  @IBOutlet weak var txtAddress: NSTextField!
  
  @IBAction func txtAddressAction(_ sender: NSTextField) {
    if let sensor = self.sensor {
      sensor.nextSensorAddress = sender.integerValue
    }
  }
  
  @IBOutlet weak var cboSensorType: NSComboBox!
  
  @IBAction func cboSensorTypeAction(_ sender: NSComboBox) {
    if let sensor = self.sensor {
      sensor.nextSensorType = SensorType.selected(comboBox: cboSensorType)
    }
  }
  
  @IBOutlet weak var txtDelayOn: NSTextField!
  
  @IBAction func txtDelayOnAction(_ sender: NSTextField) {
    if let sensor = self.sensor {
      sensor.nextDelayOn = sender.integerValue
    }
  }
  
  @IBOutlet weak var txtDelayOff: NSTextField!
  
  @IBAction func txtDelayOffAction(_ sender: NSTextField) {
    if let sensor = self.sensor {
      sensor.nextDelayOff = sender.integerValue
    }
  }
  
  @IBOutlet weak var chkInverted: NSButton!
  
  @IBAction func chkInvertedAction(_ sender: NSButton) {
    if let sensor = self.sensor {
      sensor.nextInverted = sender.boolValue
    }
  }
  
}
