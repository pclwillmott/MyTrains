//
//  ConfigurationToolVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 23/12/2023.
//

import Foundation
import AppKit

class ConfigurationToolVC: NSViewController, NSWindowDelegate {
  
  // MARK: Window & View Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }
  
  func windowWillClose(_ notification: Notification) {
    
  }
  
  override func viewWillAppear() {
    
    self.view.window?.delegate = self

    containerView.translatesAutoresizingMaskIntoConstraints = false
    btnWriteAll.translatesAutoresizingMaskIntoConstraints = false
    btnRefreshAll.translatesAutoresizingMaskIntoConstraints = false
    btnResetToDefaults.translatesAutoresizingMaskIntoConstraints = false
    btnReboot.translatesAutoresizingMaskIntoConstraints = false
    lblStatus.translatesAutoresizingMaskIntoConstraints = false
    barProgress.translatesAutoresizingMaskIntoConstraints = false
    stackView.translatesAutoresizingMaskIntoConstraints = false
    buttonView.translatesAutoresizingMaskIntoConstraints = false
    progressView.translatesAutoresizingMaskIntoConstraints = false
    statusView.translatesAutoresizingMaskIntoConstraints = false
    
    self.view.addSubview(stackView)
 
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: gap),
      stackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: gap),
      stackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -gap),
      self.view.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: gap),
    ])

    stackView.orientation = .vertical
    stackView.alignment = .leading
    
    stackView.addArrangedSubview(containerView)
    stackView.addArrangedSubview(statusView)
    stackView.addArrangedSubview(progressView)
    stackView.addArrangedSubview(buttonView)

    NSLayoutConstraint.activate([
      containerView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
      statusView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
      statusView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
      progressView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
      progressView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
      buttonView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
      buttonView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
      buttonView.heightAnchor.constraint(equalToConstant: 20)
    ])
    
    statusView.addSubview(lblStatus)
    lblStatus.alignment = .center

    NSLayoutConstraint.activate([
      lblStatus.topAnchor.constraint(equalTo: statusView.topAnchor),
      lblStatus.leadingAnchor.constraint(equalTo: statusView.leadingAnchor),
      lblStatus.trailingAnchor.constraint(equalTo: statusView.trailingAnchor),
    ])
    
    isStatusViewHidden = true

    progressView.addSubview(barProgress)

    NSLayoutConstraint.activate([
      barProgress.topAnchor.constraint(equalTo: progressView.topAnchor),
      barProgress.leadingAnchor.constraint(equalTo: progressView.leadingAnchor, constant: gap),
      barProgress.trailingAnchor.constraint(equalTo: progressView.trailingAnchor, constant: -gap),
    ])
      
    isProgressViewHidden = true

    buttonView.addSubview(btnWriteAll)
    buttonView.addSubview(btnRefreshAll)
    buttonView.addSubview(btnResetToDefaults)
    buttonView.addSubview(btnReboot)

    btnWriteAll.title = "Write All"
    btnRefreshAll.title = "Refresh All"
    btnResetToDefaults.title = "Reset to Defaults"
    btnReboot.title = "Reboot"
      
    NSLayoutConstraint.activate([
      btnRefreshAll.leadingAnchor.constraint(equalTo: buttonView.leadingAnchor, constant: gap),
      btnWriteAll.leadingAnchor.constraint(equalTo: btnRefreshAll.trailingAnchor, constant: gap),
      btnResetToDefaults.trailingAnchor.constraint(equalTo: buttonView.trailingAnchor, constant: -gap),
      btnReboot.trailingAnchor.constraint(equalTo: btnResetToDefaults.leadingAnchor, constant: -gap),
    ])
    
    isButtonViewHidden = true

    var segment1 = CDISegmentView()
    containerView.addArrangedSubview(segment1)
    segment1.name = "Segment 1"

    var text2 = CDIStringView()
    text2.addDescription(description: "description")
    text2.stringValue = "text 2"
    segment1.addArrangedSubview(text2)

    var text4 = CDIEventIdView(frame: .zero)
    segment1.addArrangedSubview(text4)
    text4.name = "Events"
    text4.addDescription(description: "This is descriptive text. This is descriptive text. This is descriptive text. This is descriptive text. This is descriptive text. ")
    text4.eventIdValue = 0xffffff

    var group1 = CDIGroupView()
    segment1.addArrangedSubview(group1)
    group1.name = "Group 1"
    group1.addDescription(description: "This is descriptive text. This is descriptive text. This is descriptive text. This is descriptive text. This is descriptive text. ")

    var text5 = CDIUIntView()
    group1.addArrangedSubview(text5)
    text5.name = "Integer"
    text5.addDescription(description: "This is descriptive text. This is descriptive text. This is descriptive text. This is descriptive text. This is descriptive text. ")
    text5.elementSize = 8
    text5.unsignedIntegerValue = 0xffffff


  }
  
  // MARK: Private Properties
  
  private let gap : CGFloat = 5.0
  
  private var progressViewHeightConstraint : NSLayoutConstraint?
  
  private var isProgressViewHidden : Bool {
    get {
      return progressView.isHidden
    }
    set(value) {
      progressViewHeightConstraint?.isActive = false
      progressView.isHidden = value
      progressViewHeightConstraint = progressView.heightAnchor.constraint(equalToConstant: value ? 0.0 : 18.0)
      progressViewHeightConstraint?.isActive = true
    }
  }

  private var statusViewHeightConstraint : NSLayoutConstraint?
  
  private var isStatusViewHidden : Bool {
    get {
      return statusView.isHidden
    }
    set(value) {
      statusViewHeightConstraint?.isActive = false
      statusView.isHidden = value
      statusViewHeightConstraint = statusView.heightAnchor.constraint(equalToConstant: value ? 0.0 : 18.0)
      statusViewHeightConstraint?.isActive = true
    }
  }

  private var buttonViewHeightConstraint : NSLayoutConstraint?
  
  private var isButtonViewHidden : Bool {
    get {
      return buttonView.isHidden
    }
    set(value) {
      buttonViewHeightConstraint?.isActive = false
      buttonView.isHidden = value
      buttonViewHeightConstraint = statusView.heightAnchor.constraint(equalToConstant: value ? 0.0 : 18.0)
      buttonViewHeightConstraint?.isActive = true
    }
  }

  // MARK: Controls
  
  private var btnRefreshAll = NSButton()
  
  private var btnWriteAll = NSButton()
  
  private var btnResetToDefaults = NSButton()
  
  private var btnReboot = NSButton()
  
  private var barProgress = NSProgressIndicator()
  
  private var lblStatus = NSTextField(labelWithString: "Status")
  
  private var containerView = ScrollVerticalStackView()
  
  private var stackView = NSStackView()
  
  private var statusView = NSView()
  
  private var progressView = NSView()
    
  private var buttonView = NSView()
  
  // MARK: Actions
  
}
