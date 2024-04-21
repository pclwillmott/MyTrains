//
//  FlippedView.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/04/2024.
//

import Foundation
import AppKit

class FlippedView: NSView {
    override var isFlipped: Bool { return true }
}

class FlippedNSClipView: NSClipView {
    override var isFlipped: Bool { return true }
}

