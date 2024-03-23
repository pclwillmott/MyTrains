//
//  CDIDataView2.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/12/2023.
//

import Foundation
import AppKit

class CDIDataView: CDIView {
  
  // MARK: Destructors
 
  #if DEBUG
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    addInit()
  }
  
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    addInit()
  }
  #endif
  
  deinit {
    box?.subviews.removeAll()
    box = nil
    for view in stackView!.arrangedSubviews {
      stackView?.removeArrangedSubview(view)
    }
    stackView = nil
    dataButtonView?.subviews.removeAll()
    dataButtonView = nil
    writeButton?.target = nil
    writeButton = nil
    refreshButton?.target = nil
    refreshButton = nil
    copyButton?.target = nil
    copyButton = nil
    pasteButton?.target = nil
    pasteButton = nil
    newEventId?.target = nil
    newEventId = nil
    subviews.removeAll()
    #if DEBUG
    addDeinit()
    #endif
  }
  
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
      return box!.title
    }
    set(value) {
      box?.title = value
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
  
  public weak var delegate : CDIDataViewDelegate?

  // MARK: Private & Internal Methods
  
  internal func dataWasSet() {
  }
  
  internal func isValid(string:String) -> Bool {
    
    guard let elementType, let elementSize else {
      return false
    }
    
    switch elementType {
      
    case .int:
      
      if let uint = UInt64(string) {
        if uint > (UInt64(1) << (8 * elementSize)) - 1 {
          return false
        }
        if let max = maxValue, let maxUInt = UInt64(max), uint > maxUInt {
          return false
        }
        if let min = minValue, let minUInt = UInt64(min), uint < minUInt {
          return false
        }
      }
      else {
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
        
        let formatter = NumberFormatter()
        
        formatter.usesGroupingSeparator = true
        formatter.groupingSize = 3
        formatter.alwaysShowsDecimalSeparator = false
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 8

        switch elementSize {
        case 2:
          let word = UInt16(floatValue & 0xffff)
          let float16 : float16_t = float16_t(v: word)
          let float32 = Float(float16: float16)
          return formatter.string(from: float32 as NSNumber)!
        case 4:
          let dword = UInt32(floatValue & 0xffffffff)
          let float32 = Float32(bitPattern: dword)
          return formatter.string(from: float32 as NSNumber)!
        case 8:
          let float64 = Float64(bitPattern: floatValue)
          return formatter.string(from: float64 as NSNumber)!
        default:
          #if DEBUG
          debugLog("CDIDataView.setString: bad float size: \(elementSize)")
          #endif
        }
        
      }
      
    case .int:
      
      if let intValue = UInt64(bigEndianData: bigEndianData) {
        return "\(intValue)"
      }
      
    case .string:
      
      return String(cString: bigEndianData)

    default:
      #if DEBUG
      debugLog("CDIDataView.setString: unexpected element type: \(elementType)")
      #endif
    }

    return nil
    
  }
  
  internal func getData(string:String) -> [UInt8]? {
    
    guard let elementType, let elementSize else {
      return nil
    }

    switch elementType {
      
    case .int:
      
      if let uint = UInt64(string) {
        var data = uint.bigEndianData
        data.removeFirst(8 - elementSize)
        return data
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
        #if DEBUG
        debugLog("CDIDataView.getData: unexpected float size: \(elementSize)")
        #endif
      }
      
    case .string:
      
      return string.padWithNull(length: elementSize)
      
    case .eventid:
      
      if let eventId = UInt64(dotHex: string) {
        return eventId.bigEndianData
      }
      
    default:
      #if DEBUG
      debugLog("CDIDataView.getData: unexpected element type: \(elementType)")
      #endif
    }

    return nil

  }

  internal func addButtons(view:NSView) {
    
    guard elementType != nil, let dataButtonView, let writeButton, let refreshButton, let copyButton, let pasteButton, let newEventId else {
      return
    }
    
    dataButtonView.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(dataButtonView)

    cdiConstraints.append(contentsOf: [
      dataButtonView.topAnchor.constraint(equalTo: view.topAnchor),
      dataButtonView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      dataButtonView.heightAnchor.constraint(equalToConstant: 20.0),
    ])
    
      
    if needsRefreshWrite {
      
      dataButtonView.addSubview(writeButton)
      writeButton.title = "Write"
      writeButton.translatesAutoresizingMaskIntoConstraints = false
      
      dataButtonView.addSubview(refreshButton)
      refreshButton.title = "Refresh"
      refreshButton.translatesAutoresizingMaskIntoConstraints = false
      
      cdiConstraints.append(contentsOf: [
        writeButton.topAnchor.constraint(equalTo: dataButtonView.topAnchor),
        writeButton.trailingAnchor.constraint(equalTo: dataButtonView.trailingAnchor),
        refreshButton.topAnchor.constraint(equalTo: dataButtonView.topAnchor),
        refreshButton.trailingAnchor.constraint(equalTo: writeButton.leadingAnchor, constant:  -siblingGap),
      ])
      
      refreshButton.target = self
      refreshButton.action = #selector(self.btnRefreshAction(_:))
      
      if !needsCopyPaste {
        cdiConstraints.append(contentsOf: [
          dataButtonView.leadingAnchor.constraint(equalTo: refreshButton.leadingAnchor)
        ])
      }

      writeButton.target = self
      writeButton.action = #selector(self.btnWriteAction(_:))
      
    }
    
    if needsCopyPaste {
      
      dataButtonView.addSubview(pasteButton)
      pasteButton.title = String(localized: "Paste", comment: "Used for the title of a button that pastes from the clipboard")
      pasteButton.translatesAutoresizingMaskIntoConstraints = false
      
      dataButtonView.addSubview(copyButton)
      copyButton.title = String(localized: "Copy", comment: "Used for the title of a button copies to the clipboard")
      copyButton.translatesAutoresizingMaskIntoConstraints = false
      
      dataButtonView.addSubview(newEventId)
      newEventId.title = String(localized: "New Event ID", comment: "Used for the title of a button that creates a new event ID")
      newEventId.translatesAutoresizingMaskIntoConstraints = false
      
      cdiConstraints.append(contentsOf: [
        pasteButton.topAnchor.constraint(equalTo: dataButtonView.topAnchor),
        pasteButton.trailingAnchor.constraint(equalTo: refreshButton.leadingAnchor, constant: -siblingGap),
        copyButton.topAnchor.constraint(equalTo: dataButtonView.topAnchor),
        copyButton.trailingAnchor.constraint(equalTo: pasteButton.leadingAnchor, constant: -siblingGap),
        newEventId.topAnchor.constraint(equalTo: dataButtonView.topAnchor),
        newEventId.trailingAnchor.constraint(equalTo: copyButton.leadingAnchor, constant: -siblingGap),
        dataButtonView.leadingAnchor.constraint(equalTo: newEventId.leadingAnchor, constant: -siblingGap),
      ])
      
    }
    
//    NSLayoutConstraint.activate(constraints)

  }
  
  override internal func setup() {
    
    guard let box, let stackView else {
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

    cdiConstraints.append(contentsOf: [
      box.topAnchor.constraint(equalToSystemSpacingBelow: self.topAnchor, multiplier: 1.0),
      box.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 1.0),
      box.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -parentGap),
    ])
    
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.orientation = .vertical
    stackView.alignment = .leading
    
    box.addSubview(stackView)

    cdiConstraints.append(contentsOf:[
//      stackView.topAnchor.constraint(equalToSystemSpacingBelow: box.topAnchor, multiplier: 1.0),
      stackView.topAnchor.constraint(equalTo: box.topAnchor, constant: 36.0),
      stackView.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: parentGap),
      stackView.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -parentGap),
      box.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: parentGap),
      self.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: parentGap),
    ])

  }
  
  // MARK: Public Methods
    
  public func addDescription(description:[String]) {
    
    guard let stackView else {
      return
    }
    
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

        cdiConstraints.append(contentsOf: [
          field.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
          field.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
        ])

      }
      
    }
    
  }

  // MARK: Controls
  
  internal var box            : NSBox?       = NSBox()
  internal var writeButton    : NSButton?    = NSButton()
  internal var refreshButton  : NSButton?    = NSButton()
  internal var copyButton     : NSButton?    = NSButton()
  internal var pasteButton    : NSButton?    = NSButton()
  internal var stackView      : NSStackView? = NSStackView()
  internal var newEventId     : NSButton?    = NSButton()
  internal var dataButtonView : NSView?      = NSView()
  
  // MARK: Actions
  
  @IBAction func btnWriteAction(_ sender: NSButton) {
    delegate?.cdiDataViewWriteData?(self)
  }

  @IBAction func btnRefreshAction(_ sender: NSButton) {
    delegate?.cdiDataViewReadData?(self)
  }

}
