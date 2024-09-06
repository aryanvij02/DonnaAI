//
//  ConfirmationWindowController.swift
//  OSai
//
//  Created by gill on 4/17/24.
//

import Foundation
import AppKit
import SwiftUI
class ConfirmationWindowController: NSWindowController {
    convenience init(onConfirm: @escaping () -> Void, onCancel: @escaping () -> Void) {
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 300, height: 200),
                              styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
                              backing: .buffered,
                              defer: false)
        window.center()
        window.title = "Privacy and Data Security"
        
        self.init(window: window)
        window.contentView = NSHostingView(rootView: ConfirmationPopupView(onConfirm: onConfirm, onCancel: onCancel))
    }
}
