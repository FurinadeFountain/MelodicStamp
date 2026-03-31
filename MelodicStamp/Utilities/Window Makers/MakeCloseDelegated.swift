//
//  MakeCloseDelegated.swift
//  Melodic Stamp
//
//  Created by KrLite on 2025/1/26.
//

import SwiftUI

struct MakeCloseDelegated: NSViewRepresentable {
    var shouldClose: Bool = false
    var onClose: (NSWindow, Bool) -> ()

    func makeNSView(context: Context) -> CloseDelegatedView {
        let view = CloseDelegatedView()
        view.delegate = CloseDelegatedWindowDelegate(parent: self)
        return view
    }

    func updateNSView(_ nsView: CloseDelegatedView, context: Context) {
        nsView.delegate.parent = self
    }
}

class CloseDelegatedView: NSView {
    var delegate = CloseDelegatedWindowDelegate(parent: MakeCloseDelegated(onClose: { _, _ in }))

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        guard let window else { return }
        installDelegate(on: window)
    }

    private func installDelegate(on window: NSWindow) {
        if !(window.delegate is CloseDelegatedWindowDelegate) {
            delegate.originalDelegate = window.delegate
            window.delegate = delegate
        }
    }
}

class CloseDelegatedWindowDelegate: NSObject, NSWindowDelegate {
    weak var originalDelegate: NSWindowDelegate?
    var parent: MakeCloseDelegated

    init(parent: MakeCloseDelegated) {
        self.parent = parent
    }

    func windowShouldClose(_ window: NSWindow) -> Bool {
        parent.onClose(window, parent.shouldClose)
        return parent.shouldClose
    }

    override func responds(to aSelector: Selector!) -> Bool {
        super.responds(to: aSelector) || (originalDelegate?.responds(to: aSelector) ?? false)
    }

    override func forwardingTarget(for _: Selector!) -> Any? {
        originalDelegate
    }
}
