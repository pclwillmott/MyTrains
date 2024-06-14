//
//  CDIGroupTabView.swift
//  MyTrains
//
//  Created by Paul Willmott on 31/12/2023.
//

import Foundation
import AppKit

class CDIGroupTabView : CDIGroupView {
  
  // MARK: Destructors
 
  deinit {
    buttonConstraints.removeAll()
    _tabViewItems.removeAll()
    for tab in _tabs {
      tab.target = nil
    }
    _tabs.removeAll()
    for view in tabSelectorView!.arrangedSubviews {
      tabSelectorView?.removeArrangedSubview(view)
    }
    tabSelectorView = nil
    tabButtonView?.subviews.removeAll()
    tabButtonView = nil
    tabContentView?.subviews.removeAll()
    tabContentView = nil
    btnPrevious = nil
    btnNext = nil
    subviews.removeAll()
  }
  
  // MARK: Drawing Stuff
  
  override func draw(_ dirtyRect: NSRect) {
    
    super.draw(dirtyRect)
    
    guard let btnNext, let btnPrevious, let tabButtonView else {
      return
    }
    
    NSLayoutConstraint.deactivate(buttonConstraints)
    
    buttonConstraints = []
    
    let startTab = currentPage * tabsToShow
    let endTab = min(startTab + tabsToShow, _tabs.count) - 1
    
    btnPrevious.isEnabled = currentPage != 0
    btnNext.isEnabled = currentPage < numberOfPages - 1

    tabButtonView.subviews.removeAll()
    
    var visibleButtons : [NSButton] = []
    
    for tab in _tabs {
      tab.isHidden = tab.tag < startTab || tab.tag > endTab
      tabViewItems[tab.tag].isHidden = tab.tag != currentTab
      if !tab.isHidden {
        tabButtonView.subviews.append(tab)
        visibleButtons.append(tab)
        tab.isBordered = tab.tag == currentTab
        buttonConstraints.append(tab.topAnchor.constraint(equalTo: tabButtonView.topAnchor))
        buttonConstraints.append(tabButtonView.heightAnchor.constraint(greaterThanOrEqualTo: tab.heightAnchor))
      }
    }

    let midPoint = visibleButtons.count / 2
    
    for index in 0 ... visibleButtons.count - 1 {
      
      let tab = visibleButtons[index]
      
      if index == midPoint {
        buttonConstraints.append(tab.centerXAnchor.constraint(equalTo: tabButtonView.centerXAnchor))
      }
      else if index < midPoint {
        if index + 1 < visibleButtons.count {
          buttonConstraints.append(tab.trailingAnchor.constraint(equalTo: visibleButtons[index + 1].leadingAnchor))
        }
      }
      else  if index > 0 {
        buttonConstraints.append(tab.leadingAnchor.constraint(equalTo: visibleButtons[index - 1].trailingAnchor))
        buttonConstraints.append(tabButtonView.trailingAnchor.constraint(greaterThanOrEqualTo: tab.trailingAnchor))
      }
      
    }

    NSLayoutConstraint.activate(buttonConstraints)

  }
  
  // MARK: Private & Internal Properties
  
  internal var _tabViewItems : [CDIStackView] = []
  
  internal var _tabs : [NSButton] = []
  
  internal var buttonConstraints : [NSLayoutConstraint] = []
  
  internal var _encodedReplicationName : String = "Tab"

  internal var currentPage : Int {
    guard tabsToShow > 0 else {
      return 0
    }
    return currentTab / tabsToShow
  }
  
  internal var currentTab : Int = 0 {
    didSet {
      needsDisplay = true
    }
  }
  
  internal var numberOfPages : Int {
    guard numberOfTabViewItems > 0 && tabsToShow > 0 else {
      return 0
    }
    return (numberOfTabViewItems - 1 ) / tabsToShow + 1
  }
  
  internal var tabsToShow : Int {
    
    var maxButtonWidth : CGFloat = 0.0
    
    for tab in _tabs {
      maxButtonWidth = max(maxButtonWidth, tab.fittingSize.width)
    }
      
    var result = max(1, Int(tabButtonView!.bounds.width / maxButtonWidth))
    
    if result % 2 == 0 {
      result -= 1
    }
    
    return result
    
  }

  internal var _replicationName : String {
    
    var encoded = _encodedReplicationName
    
    while !encoded.isEmpty {
      let cc = encoded.last!
      if cc >= "0" && cc <= "9" {
        encoded.removeLast()
      }
      else {
        break
      }
    }
    
    return encoded

  }
  
  internal var _noStartNumberSpecified : Bool {
    return _encodedReplicationName == _replicationName
  }
  
  internal var _replicationStartNumber : Int {
      
    let numberLength = _encodedReplicationName.count - _replicationName.count
    
    if numberLength == 0 {
      return 1
    }
    
    return Int(_encodedReplicationName.suffix(numberLength))!

  }
  
  // MARK: Public Properties
  
  public var replicationName : String {
    
    get {
      return _encodedReplicationName
    }
    
    set(value) {
      _encodedReplicationName = value
      for tab in _tabs {
        tab.title = tabTitle(tabItem: tab.tag)
      }
    }
    
  }
  
  public var tabViewItems : [CDIStackView] {
    return _tabViewItems
  }
  
  public var numberOfTabViewItems : Int {
    
    get {
      return _tabViewItems.count
    }
    
    set(value) {
      
      guard let tabContentView else {
        return
      }
      
      while _tabViewItems.count > value {
        _tabViewItems.removeLast()
        _tabs.removeLast()
      }
      
      while _tabViewItems.count < value {
        let stackView = CDIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.isHidden = true
        _tabViewItems.append(stackView)
        tabContentView.addSubview(stackView)
        cdiConstraints.append(contentsOf:[
          stackView.topAnchor.constraint(equalTo: tabContentView.topAnchor),
          stackView.leadingAnchor.constraint(equalTo: tabContentView.leadingAnchor),
          stackView.trailingAnchor.constraint(equalTo: tabContentView.trailingAnchor),
          tabContentView.bottomAnchor.constraint(greaterThanOrEqualTo: stackView.bottomAnchor),
        ])
        let tab = NSButton(title: tabTitle(tabItem: _tabs.count), target: nil, action: nil)
        tab.translatesAutoresizingMaskIntoConstraints = false
        tab.tag = _tabs.count
        tab.isHidden = true
        tab.target = self
        tab.action = #selector(self.tabAction(_:))
        _tabs.append(tab)
      }
      
    }
    
  }
  
  // MARK: Private & Internal Methods
  
  override internal func setup() {
    
    guard let tabSelectorView, let tabButtonView, let btnPrevious, let btnNext, let tabContentView else {
      return
    }
    
    super.setup()
    
    tabSelectorView.translatesAutoresizingMaskIntoConstraints = false
    tabSelectorView.orientation = .horizontal
    tabSelectorView.alignment = .centerY

    addArrangedSubview(tabSelectorView)

    tabButtonView.translatesAutoresizingMaskIntoConstraints = false

    btnPrevious.translatesAutoresizingMaskIntoConstraints = false
    btnPrevious.showsBorderOnlyWhileMouseInside = true
    btnPrevious.target = self
    btnPrevious.action = #selector(self.previousPageAction(_:))
    btnNext.translatesAutoresizingMaskIntoConstraints = false
    btnNext.showsBorderOnlyWhileMouseInside = true
    btnNext.target = self
    btnNext.action = #selector(self.nextPageAction(_:))

    tabSelectorView.addArrangedSubview(btnPrevious)
    tabSelectorView.addArrangedSubview(tabButtonView)
    tabSelectorView.addArrangedSubview(btnNext)
    
    cdiConstraints.append(contentsOf:[
      tabSelectorView.arrangedSubviews[0].widthAnchor.constraint(equalTo: btnPrevious.widthAnchor),
      tabSelectorView.arrangedSubviews[2].widthAnchor.constraint(equalTo: btnNext.widthAnchor),
    ])
    
    btnPrevious.setButtonType(.momentaryPushIn)
    btnNext.setButtonType(.momentaryPushIn)

    tabContentView.translatesAutoresizingMaskIntoConstraints = false
    
    addArrangedSubview(tabContentView)
    
  }
  
  internal func setTabTitles() {
    
    for tab in _tabs {
      tab.title = tabTitle(tabItem: tab.tag)
    }
    
    needsDisplay = true
    
  }
  
  internal func tabTitle(tabItem:Int) -> String {
    return "\(_replicationName)\(_noStartNumberSpecified ? " " : "")\(_replicationStartNumber + tabItem)"
  }
  
  // MARK: Controls
  
  internal var tabSelectorView : NSStackView? = NSStackView()
  
  internal var tabButtonView : NSView? = NSView()
  
  internal var tabContentView : NSView? = NSView()
  
  internal var btnPrevious : NSButton? = NSButton(title: "⇦", target: nil, action: nil)
  
  internal var btnNext : NSButton? = NSButton(title: "⇨", target: nil, action: nil)

  // MARK: Actions
  
  @IBAction func tabAction(_ sender: NSButton) {
    currentTab = sender.tag
  }

  @IBAction func nextPageAction(_ sender: NSButton) {
    currentTab = min((currentPage + 1) * tabsToShow, numberOfTabViewItems - 1)
  }

  @IBAction func previousPageAction(_ sender: NSButton) {
    currentTab = max(0, (currentPage - 1) * tabsToShow)
  }

}
