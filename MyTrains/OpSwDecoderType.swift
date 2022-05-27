//
//  OpSwDecoderType.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/02/2022.
//

import Foundation
import Cocoa

class OpSwDecoderView: NSTableCellView {

  // MARK: View Control
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    // Drawing code here.
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
  }
  
  // MARK: Private Properties
  
  private var _optionSwitch : OptionSwitch?
  
  // MARK: Public Properties
  
  public var defaultDecoderType : SpeedSteps {
    get {
      switch cboDecoderType.indexOfSelectedItem {
      case 0:
        return .dcc14
      case 1:
        return .dcc28
      case 2:
        return .dcc28A
      case 3:
        return .dcc128
      case 4:
        return .dcc128A
      case 5:
        return .dcc28T
      default:
        return .unknown
      }
    }
    set(value) {
      switch value {
      case .dcc14:
        cboDecoderType.selectItem(at: 0)
      case .dcc28:
        cboDecoderType.selectItem(at: 1)
      case .dcc28A:
        cboDecoderType.selectItem(at: 2)
      case .dcc128:
        cboDecoderType.selectItem(at: 3)
      case .dcc128A:
        cboDecoderType.selectItem(at: 4)
      case .dcc28T:
        cboDecoderType.selectItem(at: 5)
      default:
        break
      }
    }
  }
  
  public var optionSwitch : OptionSwitch? {
    get {
      return _optionSwitch
    }
    set(value) {
      _optionSwitch = value
      if let opsw = _optionSwitch {
        defaultDecoderType = opsw.defaultDecoderType
      }
    }
  }

  // MARK: Outlets & Actions
  
  @IBOutlet weak var cboDecoderType: NSComboBox!
  
  @IBAction func cboDecoderTypeAction(_ sender: NSComboBox) {
    optionSwitch?.newDefaultDecoderType = defaultDecoderType
  }
  
}

