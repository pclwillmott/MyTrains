//
//  DBEditorView.swift
//  MyTrains
//
//  Created by Paul Willmott on 20/12/2021.
//

import Cocoa

class DBEditorView: NSView {

  @IBOutlet var contentView: DBEditorView!
  
  override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)!
      initSubviews()
  }

  override init(frame: CGRect) {
      super.init(frame: frame)
      initSubviews()
  }

  func initSubviews() {
    // standard initialization logic
    if let nib = NSNib(nibNamed: "DBEditorView", bundle: nil) {
      nib.instantiate(withOwner: self, topLevelObjects: nil)
      contentView.frame = bounds
      addSubview(contentView)
    }

      // custom initialization logic
    
  }

    
}
