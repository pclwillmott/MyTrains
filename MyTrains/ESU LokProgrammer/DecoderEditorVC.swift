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

public let decoderInfoMasterFile = "/Users/paul/Documents/MyTrains/MyTrains/ESU LokProgrammer/DECODER_INFO.json"

class DecoderEditorVC : MyTrainsViewController, DecoderPropertyTableViewDSDelegate, DecoderProductIdTableViewDSDelegate, DecoderPhysicalOutputTableViewDSDelegate, OutputModeTableViewDSDelegate, DecoderVersionTableViewDSDelegate {
  
  
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
    propertyDataSource.delegate = self
    
    productIdsTableView.dataSource = productIdDataSource
    productIdsTableView.delegate = productIdDataSource
    productIdDataSource.delegate = self
    
    versionsTableView.dataSource = versionDataSource
    versionsTableView.delegate = versionDataSource
    versionDataSource.delegate = self
    
    mappingsTableView.dataSource = mappingsDataSource
    mappingsTableView.delegate = mappingsDataSource
    
    physicalOutputsTableView.dataSource = physicalOutputsDataSource
    physicalOutputsTableView.delegate = physicalOutputsDataSource
    physicalOutputsDataSource.delegate = self
    
    outputModeTableView.dataSource = outputModesDataSource
    outputModeTableView.delegate = outputModesDataSource
    outputModesDataSource.delegate = self
    
    DecoderType.populate(comboBox: cboDecoderType)
    
    ESUPhysicalOutputCVIndexOffsetMethod.populate(comboBox: cboOffsetMethod)
    
    DecoderEditorLoadType.populate(comboBox: cboLoadType)
    cboLoadType.selectItem(at: 0)
    cboLoadType.isEnabled = false
    btnLoad.isEnabled = false
    btnSave.isEnabled = false
    
    /*
     for decoderType in DecoderType.allCases {
     decoderTypes[decoderType] = decoderType.definition
     }
     
     let jsonEncoder = JSONEncoder()
     jsonEncoder.outputFormatting = .prettyPrinted
     
     do {
     let encodePerson = try jsonEncoder.encode(decoderTypes)
     let endcode = String(data: encodePerson, encoding: .utf8)!
     try endcode.write(toFile: decoderInfoMasterFile, atomically: true, encoding: .utf8)
     }
     catch {
     print(error.localizedDescription)
     }
     */
    
    do {
      let url = URL(fileURLWithPath: decoderInfoMasterFile)
      let json = try Data(contentsOf: url)
      
      let jsonDecoder = JSONDecoder()
      decoderTypes = try jsonDecoder.decode([DecoderType:DecoderDefinition].self, from: json)
    } catch {
      
    }
    /*
    for var (key, definition) in decoderTypes {
      definition.mapping = [:]
      decoderTypes[key] = definition
    }
    */
    /*
    for var (key, definition) in decoderTypes {
      
      let decoder = Decoder(decoderType: key)
      
      var outputModes : [ESUDecoderPhysicalOutput:Set<ESUPhysicalOutputMode>] = [:]
      
      for output in definition.esuPhysicalOutputs {
        
        outputModes[output] = ESUPhysicalOutputMode.applicableOutputModes(output: output, decoder: decoder)
        
      }
      
      definition.esuOutputModes = outputModes
      
      decoderTypes[key] = definition
      
    }
    */
    for property in ProgrammerToolSettingsProperty.allCases {
      properties.append(property)
    }
    
    propertyDataSource.properties = properties
    
    userSettings?.tableView = propertiesTableView
    userSettings?.tableView2 = cvsTableView
    userSettings?.splitView = splitView
    userSettings?.splitView2 = physicalOutputSplitView
    userSettings?.tableView3 = mappingsTableView
    userSettings?.tableView4 = physicalOutputsTableView
    userSettings?.tableView5 = outputModeTableView
    
    txtInfo.font = NSFont(name: "Menlo", size: 12.0)
    
  }
  
  private func cvList(filename:String) -> [(cv: CV, defaultValue:UInt8)] {
    
    var result : [(cv: CV, defaultValue:UInt8)] = []
    
    do {
      
      var text = try String(contentsOfFile: "\(filename)", encoding: String.Encoding.utf8)
      
      text = text.replacingOccurrences(of: "\r", with: "")
      
      let lines = text.split(separator: "\n")
      
      var cv31 : UInt8 = 0
      
      var cv32 : UInt8 = 0
      
      var index = 2
      
      while index < lines.count {
        
        let line = lines[index].trimmingCharacters(in: .whitespaces)
        
        if !line.isEmpty && line != "--------------------------------" {
          
          if line.prefix(7) == "Index: " {
            
            let parts = line.suffix(line.count - 7).split(separator: "(")
            
            let pageIndex = UInt32(parts[0].trimmingCharacters(in: .whitespaces))!
            
            cv31 = UInt8(pageIndex / 256)
            cv32 = UInt8(pageIndex % 256)
            
          }
          else {
            
            let parts = line.split(separator: "=")
            
            var cvName = String(parts[0].trimmingCharacters(in: .whitespaces).replacingOccurrences(of: " ", with: ""))
            cvName.removeFirst(2)
            
            let cv = UInt16(cvName)!
            
            if let cvConstant = CV(cv31: cv31, cv32: cv32, cv: cv, indexMethod: .cv3132), let cvValue = UInt8(parts[1].trimmingCharacters(in: .whitespaces)) {
              
              
              result.append((cvConstant, cvValue))
              
            }
            else {
              debugLog("CV Not Found: CV31:\(cv31) CV32:\(cv32) CV:\(cv) \"\(parts[1])\"")
            }
            
          }
          
        }
        
        index += 1
        
      }
      
    }
    catch {
      debugLog("error: \(filename)")
    }
    
    return result
    
  }
  
  
  private let cvDataSource = DecoderCVTableViewDS()
  
  private let propertyDataSource = DecoderPropertyTableViewDS()
  
  private let productIdDataSource = DecoderProductIdTableViewDS()
  
  private let versionDataSource = DecoderVersionTableViewDS()
  
  private let mappingsDataSource = DecoderMappingTableViewDS()
  
  private let physicalOutputsDataSource = PhysicalOutputTableViewDS()
  
  private let outputModesDataSource = OutputModeTableViewDS()
  
  private var definition : DecoderDefinition?
  
  private var properties : [ProgrammerToolSettingsProperty] = []
  
  // MARK: Outlets & Actions
  
  @IBOutlet weak var cboDecoderType: NSComboBox!
  
  @IBAction func cboDecoderTypeAction(_ sender: NSComboBox) {
    
    if let decoderType = DecoderType(title: sender.stringValue) {
      
      definition = decoderTypes[decoderType]
      
      if definition == nil {
        definition = DecoderDefinition(decoderType: decoderType, firmwareVersion: [], esuProductIds: [], cvs: [], defaultValues: [], mapping: [:], properties: [], esuPhysicalOutputs: [], offsetMethod: .none, esuOutputModes: [:])
      }
      
      cvDataSource.definition = definition
      propertyDataSource.definition = definition
      productIdDataSource.definition = definition
      mappingsDataSource.definition = definition
      physicalOutputsDataSource.definition = definition
      outputModesDataSource.definition = definition
      versionDataSource.definition = definition
      
      cboOffsetMethod.selectItem(withObjectValue: definition!.offsetMethod.title)

      cvsTableView.reloadData()
      propertiesTableView.reloadData()
      productIdsTableView.reloadData()
      mappingsTableView.reloadData()
      physicalOutputsTableView.reloadData()
      versionsTableView.reloadData()
      cboLoadType.isEnabled = true
      btnLoad.isEnabled = true
      
    }
    
  }
  
  public var physicalOutput : ESUDecoderPhysicalOutput? {
    didSet {
      outputModesDataSource.physicalOutput = physicalOutput
      outputModeTableView.reloadData()
    }
  }
  
  @IBOutlet weak var cvsTableView: NSTableView!
  
  @IBOutlet weak var propertiesTableView: NSTableView!
  
  @IBOutlet weak var productIdsTableView: NSTableView!
  
  @IBOutlet weak var btnClearMappings: NSButton!
  
  @IBAction func btnClearMappingsAction(_ sender: NSButton) {
    
    guard let decoderType = DecoderType(title: cboDecoderType.stringValue) else {
      return
    }
    
    self.definition!.mapping = [:]
    
    decoderTypes[decoderType] = self.definition!
    
    mappingsDataSource.definition = self.definition
    
    mappingsTableView.reloadData()
    
    isModified = true

  }
  
  func propertySelectionChanged(property:ProgrammerToolSettingsProperty) {
    txtInfo.string = property.info
  }
  
  func requiredPropertiesChanged(properties: Set<ProgrammerToolSettingsProperty>) {
    
    guard let decoderType = DecoderType(title: cboDecoderType.stringValue) else {
      return
    }
    
    definition?.properties = properties
    
    decoderTypes[decoderType] = definition!
    
    isModified = true
    
  }
  
  func firmwareVersionChanged(firmwareVersion: [[Int]]) {
    
    guard let decoderType = DecoderType(title: cboDecoderType.stringValue) else {
      return
    }
    
    definition?.firmwareVersion = firmwareVersion
    
    decoderTypes[decoderType] = definition!
    
    isModified = true
    
  }

  func outputSelectionChanged(output: ESUDecoderPhysicalOutput) {
    physicalOutput = output
  }
  
  func supportedPhysicalOutputsChanged(outputs: Set<ESUDecoderPhysicalOutput>) {
    
    guard let decoderType = DecoderType(title: cboDecoderType.stringValue) else {
      return
    }
    
    definition?.esuPhysicalOutputs = outputs
    
    for output in outputs {
      if !definition!.esuOutputModes.keys.contains(output) {
        definition?.esuOutputModes[output] = []
      }
    }
    
    decoderTypes[decoderType] = definition!
    
    outputModesDataSource.definition = definition
    outputModesDataSource.physicalOutput = physicalOutput
    outputModeTableView.reloadData()
    
    isModified = true

  }

  func productIdChanged(productIds: [UInt32]) {
    
    guard let decoderType = DecoderType(title: cboDecoderType.stringValue) else {
      return
    }
    
    var sorted = productIds
    
    sorted.sort {$0 < $1}
    
    self.definition!.esuProductIds = sorted
    
    decoderTypes[decoderType] = self.definition!
    
    isModified = true
    
  }
  
  @IBOutlet var txtInfo: NSTextView!
  
  @IBOutlet weak var splitView: NSSplitView!
  
  @IBAction func btnLoadAction(_ sender: NSButton) {
    
    guard let decoderType = DecoderType(title: cboDecoderType.stringValue) else {
      return
    }
    
    let dialog = NSOpenPanel();
    
    let fm = FileManager()

    var path = userSettings?.string(forKey: "DecoderEditorLoadDirectory") ?? fm.homeDirectoryForCurrentUser.path
    
    if !fm.fileExists(atPath: path) {
      path = fm.homeDirectoryForCurrentUser.path
    }

    dialog.showsResizeIndicator    = true
    dialog.showsHiddenFiles        = false
    dialog.canChooseDirectories    = true
    dialog.canCreateDirectories    = true
    dialog.allowsMultipleSelection = false
    dialog.allowedContentTypes     = [.text, .plainText, .utf8PlainText]
    dialog.directoryURL            = URL(string: path)
    
    if dialog.runModal() == NSApplication.ModalResponse.OK, let url = dialog.url, let loadType = DecoderEditorLoadType(title: cboLoadType.stringValue), let definition {
      
      userSettings?.set(dialog.directoryURL!.path, forKey: "DecoderEditorLoadDirectory")
      
      switch loadType {
      case .cvsAndDefaults:
        
        var cvs : [CV] = []
        var defaultValues : [UInt8] = []
        
        for cv in cvList(filename: url.path) {
          cvs.append(cv.cv)
          defaultValues.append(cv.defaultValue)
        }
        
        self.definition?.cvs = cvs
        self.definition?.defaultValues = defaultValues
        
      default:
        
        for cv in cvList(filename: url.path) {
          
          var ok = true
          
          switch loadType {
          case .cvMapping0000:
            ok = cv.cv <= .cv_000_000_224 || cv.cv > .cv_000_000_256
          case .cvMapping00E0:
            ok = cv.cv > .cv_000_000_224
          default:
            ok = cv.cv > .cv_000_000_256
          }
          
          if ok && cv.defaultValue != 0 {
            
            let address = loadType.rawValue + Int(cv.defaultValue) - 1
            
            var mapping : Set<CV> = []
            
            if var temp = self.definition?.mapping[address] {
              mapping = temp
            }
            
            mapping.insert(cv.cv)
            
            self.definition?.mapping[address] = mapping
             
          }
          
        }
        
      }
      
      decoderTypes[decoderType] = self.definition!
      
      isModified = true
      
      cvDataSource.definition = self.definition
      cvsTableView.reloadData()
      
      mappingsDataSource.definition = self.definition
      mappingsTableView.reloadData()
      
    }
    
  }
  
  private var isModified = false {
    didSet {
      btnSave.isEnabled = isModified
    }
  }
  
  @IBOutlet weak var cboLoadType: NSComboBox!
  
  @IBAction func cboLoadTypeAction(_ sender: NSComboBox) {
  }
  
  @IBOutlet weak var btnLoad: NSButton!
  
  
  @IBOutlet weak var btnSave: NSButton!
  
  @IBAction func btnSaveAction(_ sender: NSButton) {
    
    let jsonEncoder = JSONEncoder()
    jsonEncoder.outputFormatting = .prettyPrinted
    
    do {
      let encodePerson = try jsonEncoder.encode(decoderTypes)
      let endcode = String(data: encodePerson, encoding: .utf8)!
      try endcode.write(toFile: decoderInfoMasterFile, atomically: true, encoding: .utf8)
      isModified = false
    }
    catch {
      print(error.localizedDescription)
    }

  }

  @IBOutlet weak var versionsTableView: NSTableView!
  
  
  @IBOutlet weak var btnAddVersion: NSButton!
  
  @IBAction func btnAddVersionAction(_ sender: NSButton) {
    
    guard let decoderType = DecoderType(title: cboDecoderType.stringValue), definition != nil else {
      return
    }
    
    definition?.firmwareVersion.append([0,0,0])
    
    versionDataSource.definition = definition
    
    decoderTypes[decoderType] = definition
    
    isModified = true
    
    versionsTableView.reloadData()

  }
  
  @IBOutlet weak var btnRemoveVersion: NSButton!
  
  @IBAction func btnRemoveVersionAction(_ sender: NSButton) {
    
    guard let decoderType = DecoderType(title: cboDecoderType.stringValue), definition != nil else {
      return
    }
    
    if versionsTableView.selectedRow != -1 {

      definition?.firmwareVersion.remove(at: versionsTableView.selectedRow)
      
      versionDataSource.definition = definition
      
      decoderTypes[decoderType] = definition
      
      isModified = true
      
      versionsTableView.reloadData()

    }

  }
  
  @IBAction func btnAddAction(_ sender: NSButton) {
    
    guard let decoderType = DecoderType(title: cboDecoderType.stringValue), definition != nil else {
      return
    }
    
    definition?.esuProductIds.append(0)
    
    productIdDataSource.definition = definition
    
    decoderTypes[decoderType] = definition
    
    isModified = true
    
    productIdsTableView.reloadData()
    
  }
  @IBOutlet weak var mappingsTableView: NSTableView!
  
  @IBAction func btnRemoveAction(_ sender: NSButton) {

    guard let decoderType = DecoderType(title: cboDecoderType.stringValue), definition != nil else {
      return
    }
    
    if productIdsTableView.selectedRow != -1 {

      definition?.esuProductIds.remove(at: productIdsTableView.selectedRow)
      
      productIdDataSource.definition = definition
      
      decoderTypes[decoderType] = definition
      
      isModified = true
      
      productIdsTableView.reloadData()

    }

  }
  
  @IBOutlet weak var physicalOutputsTableView: NSTableView!
  
  @IBAction func physicalOutputsTableViewAction(_ sender: NSTableView) {
  }
  
  @IBOutlet weak var outputModeTableView: NSTableView!
  
  @IBAction func outputModeTableViewAction(_ sender: NSTableView) {
  }
  
  @IBOutlet weak var physicalOutputSplitView: NSSplitView!
  
  @IBOutlet weak var cboOffsetMethod: NSComboBox!
  
  @IBAction func cboOffsetMethodAction(_ sender: NSComboBox) {
    
    guard definition != nil else {
      return
    }
    
    if let decoderType = DecoderType(title: cboDecoderType.stringValue) {
      
      if let offsetMethod = ESUPhysicalOutputCVIndexOffsetMethod(title: sender.stringValue) {
        
        definition?.offsetMethod = offsetMethod
        
        decoderTypes[decoderType] = definition!
        
        physicalOutputsDataSource.definition = definition
        
        physicalOutputsTableView.reloadData()
        
        isModified = true
        
      }
      
      
    }
    
  }
  
  func supportedOutputModesChanged(outputs: [ESUDecoderPhysicalOutput : Set<ESUPhysicalOutputMode>]) {
 
    if let decoderType = DecoderType(title: cboDecoderType.stringValue) {
      
      definition?.esuOutputModes = outputs
      
      decoderTypes[decoderType] = definition
      
      isModified = true
      
    }
  }
  

}
