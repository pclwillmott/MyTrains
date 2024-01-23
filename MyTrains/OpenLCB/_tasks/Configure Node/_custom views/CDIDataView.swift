//
//  CDIDataView2.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/12/2023.
//

import Foundation
import AppKit

class CDIDataView: CDIView {
  
  // MARK: Private & Internal properties
  
  internal var needsRefreshWrite : Bool {
    guard let elementType else {
      return false
    }
    let needs : Set<OpenLCBCDIElementType> = [.eventid, .float, .int, .string]
    return needs.contains(elementType)
  }

  internal var needsCopyPaste : Bool {
    guard let elementType else {
      return false
    }
    let needs : Set<OpenLCBCDIElementType> = [.eventid]
    return needs.contains(elementType)
  }
  
  // MARK: Public Properties
  
  public var getData : [UInt8] {
    return []
  }

  public var name : String {
    get {
      return box.title
    }
    set(value) {
      box.title = value
    }
  }
  
  public var elementType : OpenLCBCDIElementType?
  
  public var space : UInt8 = 0
  
  public var address : Int = 0
  
  public var sortAddress : UInt64 {
    return (UInt64(space) << 32) | UInt64(address)
  }
  
  public var elementSize : Int?
  
  public var bigEndianData : [UInt8] = [] {
    didSet {
      dataWasSet()
    }
  }
  
  public var minValue : String?
  
  public var maxValue : String?
  
  public var defaultValue : String?
  
  public var floatFormat : String?
  
  public var delegate : CDIDataViewDelegate?

  // MARK: Private & Internal Methods
  
  internal func dataWasSet() {
  }
  
  internal func isValid(string:String) -> Bool {
    
    guard let elementType, let elementSize else {
      return false
    }
    
    switch elementType {
      
    case .int:
      
      switch elementSize {
      case 1:
        if let uint8 = UInt8(string) {
          if let max = maxValue, let maxUInt8 = UInt8(max), uint8 > maxUInt8 {
            return false
          }
          if let min = minValue, let minUInt8 = UInt8(min), uint8 < minUInt8 {
            return false
          }
        }
        else {
          return false
        }
      case 2:
        if let uint16 = UInt16(string) {
          if let max = maxValue, let maxUInt16 = UInt16(max), uint16 > maxUInt16 {
            return false
          }
          if let min = minValue, let minUInt16 = UInt16(min), uint16 < minUInt16 {
            return false
          }
       }
        else {
          return false
        }
      case 4:
        if let uint32 = UInt32(string) {
          if let max = maxValue, let maxUInt32 = UInt32(max), uint32 > maxUInt32 {
            return false
          }
          if let min = minValue, let minUInt32 = UInt32(min), uint32 < minUInt32 {
            return false
          }
        }
        else {
          return false
        }
      case 8:
        if let uint64 = UInt64(string) {
          if let max = maxValue, let maxUInt64 = UInt64(max), uint64 > maxUInt64 {
            return false
          }
          if let min = minValue, let minUInt64 = UInt64(min), uint64 < minUInt64 {
            return false
          }
        }
        else {
          return false
        }
      default:
        return false
      }
      
    case .float:
      
      switch elementSize {
      case 2:
        if let float32 = Float32(string) {
          if let max = maxValue, let maxFloat32 = Float32(max), float32 > maxFloat32 {
            return false
          }
          if let min = minValue, let minFloat32 = Float32(min), float32 < minFloat32 {
            return false
          }
        }
        else {
          return false
        }
      case 4:
        if let float32 = Float32(string) {
          if let max = maxValue, let maxFloat32 = Float32(max), float32 > maxFloat32 {
            return false
          }
          if let min = minValue, let minFloat32 = Float32(min), float32 < minFloat32 {
            return false
          }
        }
        else {
          return false
        }
      case 8:
        if let float64 = Float64(string) {
          if let max = maxValue, let maxFloat64 = Float64(max), float64 > maxFloat64 {
            return false
          }
          if let min = minValue, let minFloat64 = Float64(min), float64 < minFloat64 {
            return false
          }
        }
        else {
          return false
        }
      default:
        return false
      }
      
    case .string:
      
      if string.count >= elementSize {
        return false
      }
      if let max = maxValue, string > max {
        return false
      }
      if let min = minValue, string < min {
        return false
      }

    case .eventid:
      
      if UInt64(dotHex: string) == nil {
        return false
      }
      
    default:
      return false
    }

    return true
    
  }
  
  internal func setString() -> String? {
    
    guard let elementType, let elementSize else {
      return nil
    }
    
    switch elementType {
      
    case .eventid:
      
      if let eventId = UInt64(bigEndianData: bigEndianData) {
        return eventId.toHexDotFormat(numberOfBytes: 8)
      }
      
    case .float:
      
      if let floatValue = UInt64(bigEndianData:bigEndianData) {
        
        let format = floatFormat ?? "%f"

        switch elementSize {
        case 2:
          let word = UInt16(floatValue & 0xffff)
          let float16 : float16_t = float16_t(v: word)
          let float32 = Float(float16: float16)
          return String(format: format, float32)
        case 4:
          let dword = UInt32(floatValue & 0xffffffff)
          let float32 = Float32(bitPattern: dword)
          return String(format: format, float32)
        case 8:
          let float64 = Float64(bitPattern: floatValue)
          return String(format: format, float64)
        default:
          print("CDIDataView.setString: bad float size: \(elementSize)")
        }
        
      }
      
    case .int:
      
      if let intValue = UInt64(bigEndianData: bigEndianData) {
        
        switch elementSize {
        case 1:
          let byte = UInt8(intValue & 0xff)
          return "\(byte)"
        case 2:
          let word = UInt16(intValue & 0xffff)
          return "\(word)"
        case 4:
          let dword = UInt32(intValue & 0xffffffff)
          return "\(dword)"
        case 8:
          return "\(intValue)"
        default:
          print("CDIDataView.setString: bad int size: \(elementSize)")
        }
        
      }
      
    case .string:
      
      return String(cString: bigEndianData)

    default:
      print("CDIDataView.setString: unexpected element type: \(elementType)")
    }

    return nil
    
  }
  
  internal func getData(string:String) -> [UInt8]? {
    
    guard let elementType, let elementSize else {
      return nil
    }

    switch elementType {
      
    case .int:
      
      switch elementSize {
      case 1:
        if let uint8 = UInt8(string) {
          return uint8.bigEndianData
        }
      case 2:
        if let uint16 = UInt16(string) {
          return uint16.bigEndianData
        }
      case 4:
        if let uint32 = UInt32(string) {
          return uint32.bigEndianData
        }
      case 8:
        if let uint64 = UInt64(string) {
          return uint64.bigEndianData
        }
      default:
        print("CDIDataView.getData: unexpected integer size: \(elementSize)")
      }
      
    case .float:
      
      switch elementSize {
      case 2:
        if let float32 = Float32(string) {
          let word = float32.float16.v
          return word.bigEndianData
        }
      case 4:
        if let float32 = Float32(string) {
          return float32.bitPattern.bigEndianData
        }
      case 8:
        if let float64 = Float64(string) {
          return float64.bitPattern.bigEndianData
        }
      default:
        print("CDIDataView.getData: unexpected float size: \(elementSize)")
      }
      
    case .string:
      
      return string.padWithNull(length: elementSize)
      
    case .eventid:
      
      if let eventId = UInt64(dotHex: string) {
        return eventId.bigEndianData
      }
      
    default:
      print("CDIDataView.getData: unexpected element type: \(elementType)")
    }

    return nil

  }

  internal func addButtons(view:NSView) {
    
    guard elementType != nil else {
      return
    }
    
    dataButtonView.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(dataButtonView)

    var constraints : [NSLayoutConstraint] = []
    
    constraints.append(contentsOf: [
      dataButtonView.topAnchor.constraint(equalTo: view.topAnchor),
      dataButtonView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      dataButtonView.heightAnchor.constraint(equalToConstant: 20.0),
    ])
    
    var trailingAnchor = dataButtonView.trailingAnchor

    if needsCopyPaste {
      
      dataButtonView.addSubview(pasteButton)
      pasteButton.title = "Paste"
      pasteButton.translatesAutoresizingMaskIntoConstraints = false
      
      dataButtonView.addSubview(copyButton)
      copyButton.title = "Copy"
      copyButton.translatesAutoresizingMaskIntoConstraints = false
      
      constraints.append(contentsOf: [
        pasteButton.topAnchor.constraint(equalTo: dataButtonView.topAnchor),
        pasteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -gap),
        copyButton.topAnchor.constraint(equalTo: dataButtonView.topAnchor),
        copyButton.trailingAnchor.constraint(equalTo: pasteButton.leadingAnchor, constant: -gap),
      ])
      
      trailingAnchor = copyButton.leadingAnchor

    }

    if needsRefreshWrite {
      
      dataButtonView.addSubview(writeButton)
      writeButton.title = "Write"
      writeButton.translatesAutoresizingMaskIntoConstraints = false
      
      dataButtonView.addSubview(refreshButton)
      refreshButton.title = "Refresh"
      refreshButton.translatesAutoresizingMaskIntoConstraints = false
      
      constraints.append(contentsOf: [
        writeButton.topAnchor.constraint(equalTo: dataButtonView.topAnchor),
        writeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -gap),
        refreshButton.topAnchor.constraint(equalTo: dataButtonView.topAnchor),
        refreshButton.trailingAnchor.constraint(equalTo: writeButton.leadingAnchor, constant:  -gap),
        dataButtonView.leadingAnchor.constraint(equalTo: refreshButton.leadingAnchor)
      ])
      
      writeButton.target = self
      writeButton.action = #selector(self.btnWriteAction(_:))

      refreshButton.target = self
      refreshButton.action = #selector(self.btnRefreshAction(_:))

    }

    NSLayoutConstraint.activate(constraints)
    
  }
  
  override internal func setup() {
    
    guard needsInit else {
      return
    }
    
    super.setup()
    
    addSubview(box)
    
    box.boxType = .primary
    box.fillColor = .windowBackgroundColor
    box.translatesAutoresizingMaskIntoConstraints = false
    box.cornerRadius = 5.0
    box.titlePosition = .atTop
    box.titleFont = NSFont(name: box.titleFont.familyName!, size: 13.0)!

    NSLayoutConstraint.activate([
 //     box.topAnchor.constraint(equalToSystemSpacingBelow: self.topAnchor, multiplier: 1.0),
      box.topAnchor.constraint(equalTo: self.topAnchor, constant: gap),
 //     box.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 1.0),
      box.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      box.trailingAnchor.constraint(equalTo: self.trailingAnchor),
    ])
    
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.orientation = .vertical
    stackView.alignment = .leading
    
    box.addSubview(stackView)

    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: box.topAnchor, constant: 23.0),
      stackView.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: gap),
      stackView.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -gap),
      box.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: gap),
      self.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: gap),
    ])

    needsInit = false

  }
  
  // MARK: Public Methods
    
  public func addDescription(description:[String]) {
    
    for desc in description {
      
      if !desc.trimmingCharacters(in: .whitespaces).isEmpty {
        
        let field = NSTextField(labelWithString: desc)
        
        field.translatesAutoresizingMaskIntoConstraints = false
        
        field.lineBreakMode = .byWordWrapping
        field.isEditable = false
        field.isBordered = false
        field.drawsBackground = false
        field.font = NSFont(name: field.font!.familyName!, size: 11.0)
        field.maximumNumberOfLines = 0
        field.preferredMaxLayoutWidth = 500.0
        
        stackView.addArrangedSubview(field)

        NSLayoutConstraint.activate([
          field.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: gap),
          field.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -gap),
        ])

      }
      
    }
    
  }

  // MARK: Controls
  
  internal var box = NSBox()
  
  internal var stackView = NSStackView()
  
  internal var refreshButton = NSButton()
  
  internal var writeButton = NSButton()
  
  internal var copyButton = NSButton()
  
  internal var pasteButton = NSButton()
  
  internal var dataButtonView = NSView()
  
  // MARK: Actions
  
  @IBAction func btnWriteAction(_ sender: NSButton) {
    delegate?.cdiDataViewWriteData?(self)
  }

  @IBAction func btnRefreshAction(_ sender: NSButton) {
    delegate?.cdiDataViewReadData?(self)
  }

}
