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
      var isEnabled : Bool = true
      SensorType.populate(comboBox: cboSensorType)
      txtAddress.stringValue = ""
      txtDelayOn.stringValue = ""
      txtDelayOff.stringValue = ""
      chkInverted.boolValue = false
      if let sensor = self.sensor {
    //    isEnabled = sensor.isEnabled
        if isEnabled {
          SensorType.select(comboBox: cboSensorType, value: sensor.nextSensorType)
     //     txtAddress.stringValue = "\(sensor.sensorAddressOverride)"
          txtDelayOn.integerValue = sensor.nextDelayOn
          txtDelayOff.integerValue = sensor.nextDelayOff
          chkInverted.boolValue = sensor.nextInverted
        }
      }
      cboSensorType.isEnabled = isEnabled
      txtAddress.isEnabled = isEnabled
      txtDelayOn.isEnabled = isEnabled
      txtDelayOff.isEnabled = isEnabled
      chkInverted.isEnabled = isEnabled
    }
  }
  
  // MARK: Outlets & Actions
  
  @IBOutlet weak var txtAddress: NSTextField!
  
  @IBAction func txtAddressAction(_ sender: NSTextField) {
    if let sensor = self.sensor {
 //     sensor.sensorAddressOverride = sender.integerValue
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
  
  @IBOutlet weak var lblAddress: NSTextField!
  
  @IBOutlet weak var lblSensorType: NSTextField!
  
  @IBOutlet weak var lblDelayOn: NSTextField!
  
  @IBOutlet weak var lblDelayOff: NSTextField!
  
}
