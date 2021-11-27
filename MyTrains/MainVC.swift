//
//  ViewController.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/10/2021. 
//

import Cocoa
import ORSSerial

class MainVC: NSViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
 
  }

  override var representedObject: Any? {
    didSet {
    // Update the view, if already loaded.
    }
  }

  @IBOutlet weak var serialPorts: NSComboBox!
  
  @IBOutlet weak var onButton: NSButton!
  
  @IBAction func selectSerialPort(_ sender: NSComboBox) {
  }
  @IBAction func onOffAction(_ sender: NSButton) {
    
    sender.title = sender.title == "On" ? "Off" : "On"

  }
  
}

