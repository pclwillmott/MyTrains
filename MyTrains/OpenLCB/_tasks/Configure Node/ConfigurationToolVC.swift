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
    
//    containerView.translatesAutoresizingMaskIntoConstraints = false
 /*
    NSLayoutConstraint.activate([
      containerView.topAnchor.constraint(equalTo: self.view.topAnchor),
      containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -50),
//      containerView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
      containerView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
      containerView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
    ])
    */
    var text1 = CDIStringView()
    text1.stringValue = "text 1"
    containerView.append(view: text1)
/*
    var text2 = CDIStringView()
    text2.stringValue = "text 2"
    containerView.append(view: text2)

    var text3 = CDIStringView()
    text3.name = "Events"
    text3.addDescription(description: "This is descriptive text. This is descriptive text. This is descriptive text. This is descriptive text. This is descriptive text. ")
    text3.addDescription(description: "This is descriptive text. This is descriptive text. This is descriptive text. This is descriptive text. This is descriptive text. With different words. ")
    containerView.append(view: text3)
    text3.stringValue = "text 3"

    var text4 = CDIEventIdView()
    text4.name = "Events"
    text4.addDescription(description: "This is descriptive text. This is descriptive text. This is descriptive text. This is descriptive text. This is descriptive text. ")
    containerView.append(view: text4)
    text4.eventIdValue = 0xffffff

    var text5 = CDIUIntView()
    text5.name = "Integers"
    text5.addDescription(description: "This is descriptive text. This is descriptive text. This is descriptive text. This is descriptive text. This is descriptive text. ")
    containerView.append(view: text5)
    text5.elementSize = 4
    text5.unsignedIntegerValue = 1234
*/
  }
  
  // Outlets & Actions
  
  @IBOutlet weak var containerView: CDIContainerView!
  
}
