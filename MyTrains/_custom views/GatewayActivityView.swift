//
//  GatewayActivityView.swift
//  MyTrains
//
//  Created by Paul Willmott on 14/03/2024.
//

import Foundation
import AppKit

class GatewayActivityView : NSView {

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    createControls()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  // MARK: Private Properties

  private let gatewayNumberLabel = NSTextField(labelWithString: "")

  private let gatewayName = NSTextField(labelWithString: "")
 
  private let gatewayNodeId = NSTextField(labelWithString: "")

  private let rxLED = LEDView()

  private let txLED = LEDView()

  private let rxPacketCount = NSTextField(labelWithString: "0")

  private let txPacketCount = NSTextField(labelWithString: "0")

  private let rxLabel = NSTextField(labelWithString: String(localized: "RX", comment: "This is an abbreviation of Receive used for an LED label"))

  private let txLabel = NSTextField(labelWithString: String(localized: "TX", comment: "This is an abbreviation of Transmit used for an LED label"))

  private var rxCount : UInt64 = 0
  
  private var txCount : UInt64 = 0
  
  private let formatter = NumberFormatter()
  
  // MARK: Public Properties
  
  public var gatewayNumber : Int {
    get {
      return gatewayNumberLabel.integerValue
    }
    set(value) {
      gatewayNumberLabel.integerValue = value
    }
  }
  
  public var name : String {
    get {
      return gatewayName.stringValue
    }
    set(value) {
      gatewayName.stringValue = value
    }
  }
  
  public var nodeId : UInt64 {
    get {
      return UInt64(dotHex: gatewayNodeId.stringValue)!
    }
    set(value) {
      gatewayNodeId.stringValue = value.toHexDotFormat(numberOfBytes: 6)
    }
  }
  
  // MARK: Private Methods
  
  private func createControls() {
    
    self.translatesAutoresizingMaskIntoConstraints = false
    
    gatewayNumberLabel.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(gatewayNumberLabel)
    gatewayNumberLabel.font = NSFont(name: "Menlo", size: 12)

    gatewayName.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(gatewayName)
    gatewayName.font = NSFont(name: "Menlo", size: 12)

    gatewayNodeId.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(gatewayNodeId)
    gatewayNodeId.font = NSFont(name: "Menlo", size: 10)

    rxLED.translatesAutoresizingMaskIntoConstraints = false
    rxLED.fillColor = .orange
    rxLED.strokeColor = .orange
    self.addSubview(rxLED)

    txLED.translatesAutoresizingMaskIntoConstraints = false
    txLED.fillColor = .blue
    txLED.strokeColor = .blue
    self.addSubview(txLED)
    
    rxPacketCount.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(rxPacketCount)
    rxPacketCount.font = NSFont(name: "Menlo", size: 12)
    rxPacketCount.alignment = .right

    txPacketCount.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(txPacketCount)
    txPacketCount.font = NSFont(name: "Menlo", size: 12)
    txPacketCount.alignment = .right
    
    rxLabel.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(rxLabel)
    rxLabel.font = NSFont(name: "Menlo", size: 12)

    txLabel.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(txLabel)
    txLabel.font = NSFont(name: "Menlo", size: 12)
    
    NSLayoutConstraint.activate([
      gatewayNumberLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 1.0),
      gatewayNumberLabel.topAnchor.constraint(equalTo: self.topAnchor),
      gatewayName.topAnchor.constraint(equalTo: gatewayNumberLabel.topAnchor),
      gatewayName.leadingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: gatewayNumberLabel.trailingAnchor, multiplier: 1.0),
      gatewayNodeId.topAnchor.constraint(equalToSystemSpacingBelow: gatewayName.bottomAnchor, multiplier: 1.0),
      gatewayNodeId.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 1.0),
      rxLED.topAnchor.constraint(equalToSystemSpacingBelow: gatewayNodeId.bottomAnchor, multiplier: 1.0),
      rxLED.leadingAnchor.constraint(equalToSystemSpacingAfter: self.leadingAnchor, multiplier: 1.0),
      rxLED.heightAnchor.constraint(equalToConstant: 10.0),
      rxLED.widthAnchor.constraint(equalToConstant: 10.0),
      rxLabel.leadingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: rxLED.trailingAnchor, multiplier: 1.0),
      rxLabel.centerYAnchor.constraint(equalTo: rxLED.centerYAnchor),
      rxPacketCount.centerYAnchor.constraint(equalTo: rxLED.centerYAnchor),
      rxPacketCount.leadingAnchor.constraint(equalToSystemSpacingAfter: rxLabel.trailingAnchor, multiplier: 1.0),
      txLED.topAnchor.constraint(equalToSystemSpacingBelow: rxLED.bottomAnchor, multiplier: 1.0),
      txLED.leadingAnchor.constraint(equalTo: rxLED.leadingAnchor),
      txLED.heightAnchor.constraint(equalToConstant: 10.0),
      txLED.widthAnchor.constraint(equalToConstant: 10.0),
      txLabel.leadingAnchor.constraint(equalTo: rxLabel.leadingAnchor),
      txLabel.centerYAnchor.constraint(equalTo: txLED.centerYAnchor),
      rxLabel.widthAnchor.constraint(greaterThanOrEqualTo: txLabel.widthAnchor),
      txLabel.widthAnchor.constraint(greaterThanOrEqualTo: rxLabel.widthAnchor),
      txPacketCount.centerYAnchor.constraint(equalTo: txLED.centerYAnchor),
      txPacketCount.leadingAnchor.constraint(equalTo: rxPacketCount.leadingAnchor),
      rxPacketCount.widthAnchor.constraint(greaterThanOrEqualTo: txPacketCount.widthAnchor),
      txPacketCount.widthAnchor.constraint(greaterThanOrEqualTo: rxPacketCount.widthAnchor),
      self.widthAnchor.constraint(equalTo: gatewayNodeId.widthAnchor, multiplier: 1.5),
      self.bottomAnchor.constraint(equalToSystemSpacingBelow: txLED.bottomAnchor, multiplier: 1.0),
    ])
    
    formatter.numberStyle = .decimal
    formatter.usesGroupingSeparator = true

  }
  
  // MARK: Public Methods
  
  public func rxPacket() {
    rxLED.state = true
    rxCount += 1
    rxPacketCount.stringValue = formatter.string(from: rxCount as NSNumber)!
    needsDisplay = true
  }
  
  public func txPacket() {
    txLED.state = true
    txCount += 1
    txPacketCount.stringValue = formatter.string(from: txCount as NSNumber)!
    needsDisplay = true
  }
  
}
