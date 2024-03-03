//
//  AboutVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 27/01/2024.
//

import Foundation
import AppKit

class AboutVC: MyTrainsViewController {
  
  // MARK: Window & View Control
  
  override func viewWillAppear() {
    
    super.viewWillAppear()
    
    self.view.window?.title = ""
    
    lblTitle.translatesAutoresizingMaskIntoConstraints = false
    lblVersion.translatesAutoresizingMaskIntoConstraints = false
    lblCopyright.translatesAutoresizingMaskIntoConstraints = false
    imgIcon.translatesAutoresizingMaskIntoConstraints = false
    btnAck.translatesAutoresizingMaskIntoConstraints = false
    btnEULA.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(lblTitle)
    view.addSubview(lblVersion)
    view.addSubview(lblCopyright)
    view.addSubview(imgIcon)
    view.addSubview(btnAck)
    view.addSubview(btnEULA)
    
    imgIcon.image = NSImage(named: "AppIcon")
    imgIcon.imageScaling = .scaleProportionallyUpOrDown
    
    lblTitle.stringValue = "MyTrains"
    lblTitle.font = NSFont(name: "\(lblTitle.font!.familyName!)", size: 28.0)
    
    lblVersion.stringValue = appVersion
    lblVersion.font = NSFont(name: "\(lblTitle.font!.familyName!)", size: 16.0)
    lblVersion.textColor = .gray
    
    lblCopyright.stringValue = appCopyright
    lblCopyright.font = NSFont(name: "\(lblTitle.font!.familyName!)", size: 10.0)
    lblCopyright.textColor = .gray
    
    lblCopyright.maximumNumberOfLines = 0
    lblCopyright.preferredMaxLayoutWidth = 250.0
    lblCopyright.lineBreakMode = .byWordWrapping

    btnAck.title = String(localized: "Acknowledgements")
    btnEULA.title = String(localized: "License Agreement")
    view.window?.backgroundColor = .white
    
    btnAck.target = self
    btnAck.action = #selector(self.btnAckAction(_:))
    btnEULA.target = self
    btnEULA.action = #selector(self.btnEULAAction(_:))

    NSLayoutConstraint.activate([
      imgIcon.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1.0),
      imgIcon.heightAnchor.constraint(equalToConstant: 170),
      imgIcon.widthAnchor.constraint(equalToConstant: 170),
      imgIcon.topAnchor.constraint(equalTo: lblVersion.topAnchor),
      lblTitle.leadingAnchor.constraint(equalToSystemSpacingAfter: imgIcon.trailingAnchor, multiplier: 3.0),
      lblTitle.topAnchor.constraint(equalTo: view.topAnchor),
      lblVersion.leadingAnchor.constraint(equalToSystemSpacingAfter: imgIcon.trailingAnchor, multiplier: 3.0),
      lblVersion.topAnchor.constraint(equalToSystemSpacingBelow: lblTitle.bottomAnchor, multiplier: 1.0),
      lblCopyright.topAnchor.constraint(equalToSystemSpacingBelow: lblVersion.bottomAnchor, multiplier: 3.0),
      lblCopyright.leadingAnchor.constraint(equalToSystemSpacingAfter: imgIcon.trailingAnchor, multiplier: 3.0),
      btnAck.leadingAnchor.constraint(equalToSystemSpacingAfter: imgIcon.trailingAnchor, multiplier: 3.0),
      btnEULA.leadingAnchor.constraint(equalToSystemSpacingAfter: btnAck.trailingAnchor, multiplier: 1.0),
      btnAck.topAnchor.constraint(equalToSystemSpacingBelow: imgIcon.bottomAnchor, multiplier: 1.0),
      btnEULA.topAnchor.constraint(equalTo: btnAck.topAnchor),
      view.trailingAnchor.constraint(equalToSystemSpacingAfter: btnEULA.trailingAnchor, multiplier: 1.0),
      view.bottomAnchor.constraint(equalToSystemSpacingBelow: btnEULA.bottomAnchor, multiplier: 1.0),
    ])
    
  }
  
  // MARK: Controls
  
  let lblTitle = NSTextField(labelWithString: "MyTrains")
  
  let lblVersion = NSTextField(labelWithString: "")
  
  let lblCopyright = NSTextField(labelWithString: "")
  
  let imgIcon = NSImageView()
  
  let btnAck = NSButton()
  
  let btnEULA = NSButton()
  
  // MARK: Actions
  
  @IBAction func btnAckAction(_ sender: NSButton) {
    
    let vc = MyTrainsWindow.textView.viewController as! TextViewVC
    vc.viewTitle = String(localized: "Acknowledgements")
    
    if let filepath = Bundle.main.path(forResource: "Acknowledgements", ofType: "txt") {
      do {
        vc.viewText = try String(contentsOfFile: filepath)
      }
      catch {
      }
    }

    vc.showWindow()

  }
  
  @IBAction func btnEULAAction(_ sender: NSButton) {
    
    let vc = MyTrainsWindow.textView.viewController as! TextViewVC
    vc.viewTitle = String(localized: "End User License Agreement")
    
    if let filepath = Bundle.main.path(forResource: "License", ofType: "txt") {
      do {
        vc.viewText = try String(contentsOfFile: filepath).replacingOccurrences(of: "%%COPYRIGHT%%", with: appCopyright)
      }
      catch {
      }
    }

    vc.showWindow()

  }

}

