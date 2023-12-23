//
//  CDIElementContainerView.swift
//  MyTrains
//
//  Created by Paul Willmott on 20/12/2023.
//

import Foundation
import AppKit

class CDIContainerView : NSView {
  
  // MARK: Drawing Stuff
  
  override func draw(_ dirtyRect: NSRect) {
  }
  
  // MARK: Private & Internal Properties
  
  internal var views : [NSView] = []
  
  internal var _scrollView : NSScrollView?
  
  internal var last : NSLayoutYAxisAnchor?
  
  internal var scrollView : NSScrollView {
    
    if _scrollView == nil {
      
      let scroll = NSScrollView()
      
      addSubview(scroll)

      let stackView = NSStackView()
      
      scroll.documentView = stackView
 
      scroll.translatesAutoresizingMaskIntoConstraints = false
      scroll.contentView.translatesAutoresizingMaskIntoConstraints = false

      stackView.orientation = .vertical
      stackView.translatesAutoresizingMaskIntoConstraints = false


      NSLayoutConstraint.activate([
        scroll.leadingAnchor.constraint(equalTo: self.leadingAnchor),
        scroll.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        scroll.topAnchor.constraint(equalTo: self.topAnchor),
        scroll.heightAnchor.constraint(equalTo: self.heightAnchor),
//        scroll.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -70),
   //     scroll.contentView.leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
   //     scroll.contentView.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
   //     scroll.contentView.topAnchor.constraint(equalTo: scroll.topAnchor),
   //     scroll.contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
   //     scroll.contentView.widthAnchor.constraint(equalTo: scroll.widthAnchor),
   //     scroll.contentView.heightAnchor.constraint(equalTo: scroll.heightAnchor),
      ])
      
      scroll.allowsMagnification = false
      scroll.autohidesScrollers = false
      scroll.hasVerticalScroller = true

      NSLayoutConstraint.activate([
        stackView.leadingAnchor.constraint(equalTo: scroll.leadingAnchor),
        stackView.trailingAnchor.constraint(equalTo: scroll.trailingAnchor),
   //     stackView.topAnchor.constraint(equalTo: scroll.topAnchor),
   //     stackView.bottomAnchor.constraint(equalTo: scroll.bottomAnchor),
        stackView.widthAnchor.constraint(equalTo: scroll.widthAnchor),
  //      scroll.documentView!.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
  //      scroll.documentView!.heightAnchor.constraint(equalTo: stackView.heightAnchor),
      ])

 //     stackView.distribution = .fill

      
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.addArrangedSubview(NSButton())
      stackView.alignment = .leading
      

      /*
      scroll.documentView = documentView
      scroll.documentView?.frame = NSMakeRect(0.0, 0.0, frame.width, 10.0)
*/


      /*
      NSLayoutConstraint.activate([
        documentView.widthAnchor.constraint(equalTo: scroll.widthAnchor),
        documentView.heightAnchor.constraint(equalTo: scroll.heightAnchor),
 //       documentView.leftAnchor.constraint(equalTo: scroll.leftAnchor),
 //       documentView.rightAnchor.constraint(equalTo: scroll.rightAnchor),
      ])
*/
      _scrollView = scroll
      
 //     last = _scrollView!.documentView!.topAnchor

    }
    
    return _scrollView!

  }
  
  // MARK: Private & Internal Methods
  
  // MARK: Public Methods
  
  public func append(view:NSView) {
    
    let _ = scrollView
    
    /*
    
    scrollView.documentView?.addSubview(view)

    scrollView.documentView?.frame = NSMakeRect(0.0, 0.0, frame.width, frame.height + view.frame.height)
    
    view.translatesAutoresizingMaskIntoConstraints = false
    
    views.append(view)
    
    NSLayoutConstraint.activate([
      view.topAnchor.constraint(equalTo: last!),
      view.leftAnchor.constraint(equalTo: scrollView.documentView!.leftAnchor),
      view.rightAnchor.constraint(equalTo: scrollView.documentView!.rightAnchor),
    ])

    last = view.bottomAnchor
    
    NSLayoutConstraint.activate([
      scrollView.documentView!.bottomAnchor.constraint(greaterThanOrEqualTo: view.bottomAnchor, constant: 20.0),
      ]
    )

     */
  }
  
}
