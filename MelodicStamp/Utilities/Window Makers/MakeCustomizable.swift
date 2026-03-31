//
//  MakeCustomizable.swift
//  MelodicStamp
//
//  Created by KrLite on 2025/1/5.
//

import SwiftUI

struct MakeCustomizable: NSViewRepresentable {
    var customization: ((NSWindow) -> ())?
    var willAppear: ((NSWindow) -> ())?
    var didAppear: ((NSWindow) -> ())?
    var willDisappear: ((NSWindow) -> ())?
    var didDisappear: ((NSWindow) -> ())?

    func makeNSView(context: Context) -> WindowAccessorView {
        let view = WindowAccessorView()
        view.customization = customization
        view.willAppearHandler = willAppear
        view.didAppearHandler = didAppear
        view.willDisappearHandler = willDisappear
        view.didDisappearHandler = didDisappear
        return view
    }

    func updateNSView(_ nsView: WindowAccessorView, context: Context) {
        nsView.customization = customization
        nsView.willAppearHandler = willAppear
        nsView.didAppearHandler = didAppear
        nsView.willDisappearHandler = willDisappear
        nsView.didDisappearHandler = didDisappear
        if let window = nsView.window {
            customization?(window)
        }
    }
}

class WindowAccessorView: NSView {
    var customization: ((NSWindow) -> ())?
    var willAppearHandler: ((NSWindow) -> ())?
    var didAppearHandler: ((NSWindow) -> ())?
    var willDisappearHandler: ((NSWindow) -> ())?
    var didDisappearHandler: ((NSWindow) -> ())?

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        guard let window else { return }
        customization?(window)
        didAppearHandler?(window)
    }

    override func viewWillMove(toWindow newWindow: NSWindow?) {
        super.viewWillMove(toWindow: newWindow)
        if let window, newWindow == nil {
            willDisappearHandler?(window)
        } else if let newWindow, window == nil {
            willAppearHandler?(newWindow)
        }
    }

    override func removeFromSuperview() {
        if let window {
            didDisappearHandler?(window)
        }
        super.removeFromSuperview()
    }
}
