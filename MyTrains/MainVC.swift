//
//  ViewController.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/10/2021. 
//

import Cocoa
import ORSSerial

class MainVC: NSViewController, NetworkControllerDelegate {

  // MARK: View Control
  
  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
 
  }

  override var representedObject: Any? {
    didSet {
    // Update the view, if already loaded.
    }
  }
  
  override func viewWillAppear() {
    
    networkController.appendDelegate(delegate: self)
    
    let label: NSTextField = NSTextField()
    label.frame = NSRect(x: 0, y: 0, width: 200, height: 21)
    label.backgroundColor = NSColor.black
    label.textColor = NSColor.white
    label.stringValue = "test label"
    label.isEditable = false
    label.isBezeled = false
    label.sizeToFit()

    boxStatus.contentView?.addSubview(label)
  

  }
  
  // MARK: Private Properties
  
  private var cboLayoutDS : ComboBoxDBDS? = nil

  // MARK: Outlets & Actions
  
  @IBOutlet weak var cboLayout: NSComboBox!
  
  @IBAction func cboLayoutAction(_ sender: NSComboBox) {
    
    networkController.layoutId = cboLayoutDS!.codeForItemAt(index: cboLayout.indexOfSelectedItem) ?? -1
    
  }
  
  @IBOutlet weak var boxStatus: NSBox!
  
  // MARK: NetworkController Delegate Methods
  
  func messengersUpdated(messengers: [NetworkMessenger]) {
  }
  
  func networkControllerUpdated(netwokController: NetworkController) {
    
    cboLayout.deselectItem(at: cboLayout.indexOfSelectedItem)
    
    cboLayoutDS = ComboBoxDBDS(tableName: TABLE.LAYOUT, codeColumn: LAYOUT.LAYOUT_ID, displayColumn: LAYOUT.LAYOUT_NAME, sortColumn: LAYOUT.LAYOUT_NAME)
    
    cboLayout.dataSource = cboLayoutDS
    
    if let index = cboLayoutDS!.indexOfItemWithCodeValue(code: networkController.layoutId) {
      cboLayout.selectItem(at: index)
    }
    
  }
  
}

