// -----------------------------------------------------------------------------
// DecoderEditorVC.swift
// MyTrains
//
// Copyright © 2024 Paul C. L. Willmott. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy 
// of this software and associated documentation files (the “Software”), to deal 
// in the Software without restriction, including without limitation the rights 
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
// copies of the Software, and to permit persons to whom the Software is 
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in 
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
// SOFTWARE.
// -----------------------------------------------------------------------------
//
// Revision History:
//
//     29/08/2024  Paul Willmott - DecoderEditorVC.swift created
// -----------------------------------------------------------------------------

import Foundation
import AppKit

class DecoderEditorVC : MyTrainsViewController {
  
  // MARK: Window & View Control
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewType = .decoderEditor
  }
  
  override func windowWillClose(_ notification: Notification) {
    
    super.windowWillClose(notification)
    
    
  }

  var decoderTypes : [DecoderType:DecoderDefinition] = [:]
  

  override func viewWillAppear() {
    
    super.viewWillAppear()
    
    cvsTableView.dataSource = cvDataSource
    cvsTableView.delegate = cvDataSource
    
    propertiesTableView.dataSource = propertyDataSource
    propertiesTableView.delegate = propertyDataSource
    
    DecoderType.populate(comboBox: cboDecoderType)
    
    /*
    for decoderType in DecoderType.allCases {
      decoderTypes[decoderType] = decoderType.definition
    }
    
    let jsonEncoder = JSONEncoder()
    jsonEncoder.outputFormatting = .prettyPrinted

    do {
      let encodePerson = try jsonEncoder.encode(decoderTypes)
      let endcode = String(data: encodePerson, encoding: .utf8)!
      try endcode.write(toFile: "/Users/paul/Desktop/DECODER_INFO.json", atomically: true, encoding: .utf8)
    } catch {
        print(error.localizedDescription)
    }
    */
    
    do {
      let url = URL(fileURLWithPath: "/Users/paul/Desktop/DECODER_INFO.json")
      let json = try Data(contentsOf: url)
      
      let jsonDecoder = JSONDecoder()
      decoderTypes = try jsonDecoder.decode([DecoderType:DecoderDefinition].self, from: json)
    } catch {
      
    }
    
    for property in ProgrammerToolSettingsProperty.allCases {
      properties.append(property)
    }
    propertyDataSource.properties = properties
    
    userSettings?.tableView = propertiesTableView

  }
  
  private let cvDataSource = DecoderCVTableViewDS()
  
  private let propertyDataSource = DecoderPropertyTableViewDS()
  
  private var definition : DecoderDefinition?
  
  private var properties : [ProgrammerToolSettingsProperty] = []
  
  // MARK: Outlets & Actions
  
  @IBOutlet weak var cboDecoderType: NSComboBox!
  
  @IBAction func cboDecoderTypeAction(_ sender: NSComboBox) {
    
    if let decoderType = DecoderType(title: sender.stringValue) {
      definition = decoderTypes[decoderType]
      if let definition {
        cvDataSource.definition = definition
        propertyDataSource.definition = definition
      }
      else {
        cvDataSource.definition = nil
        propertyDataSource.definition = nil
      }
      cvsTableView.reloadData()
      propertiesTableView.reloadData()
    }
    
  }
  
  @IBOutlet weak var cvsTableView: NSTableView!
  
  @IBOutlet weak var propertiesTableView: NSTableView!
  
  @IBOutlet weak var productIdsTableView: NSTableView!
  
  
  
  
  
  
}


