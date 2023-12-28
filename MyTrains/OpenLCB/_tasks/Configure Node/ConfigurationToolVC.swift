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
    
//    var dataI = CDIDataView()
    
 //   var text2 = CDIStringView()
 //   text2.stringValue = "text 2"
 //   containerView.addArrangedSubview(dataI)


    var text3 = CDIStringView(frame: .zero)
    containerView.addArrangedSubview(text3)
    text3.name = "Events"
    text3.addDescription(description: "This is descriptive text. This is descriptive text. This is descriptive text. This is descriptive text. This is descriptive text. ")
    text3.addDescription(description: "This is descriptive text. This is descriptive text. This is descriptive text. This is descriptive text. This is descriptive text. With different words. ")
    text3.stringValue = "text 3"

    var text4 = CDIEventIdView(frame: .zero)
    containerView.addArrangedSubview(text4)
    text4.name = "Events"
    text4.addDescription(description: "This is descriptive text. This is descriptive text. This is descriptive text. This is descriptive text. This is descriptive text. ")
    text4.eventIdValue = 0xffffff

    
    var segment1 = CDISegmentView()
    containerView.addArrangedSubview(segment1)
    segment1.name = "Segment 1"

    
    var text5 = CDIUIntView(frame: .zero)
    containerView.addArrangedSubview(text5)
    text5.name = "Integers"
    text5.addDescription(description: "This is descriptive text. This is descriptive text. This is descriptive text. This is descriptive text. This is descriptive text. ")
    text5.elementSize = 4
    text5.unsignedIntegerValue = 1234

  }
  
  // Outlets & Actions
  
  @IBOutlet weak var containerView: ScrollVerticalStackView!
}
