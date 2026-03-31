//
//  MakeAlwaysOnTop.swift
//  MelodicStamp
//
//  Created by Xinshao_Air on 2025/1/2.
//

import SwiftUI

struct MakeAlwaysOnTop: NSViewRepresentable {
    @Binding var isAlwaysOnTop: Bool

    func makeNSView(context: Context) -> AlwaysOnTopView {
        let view = AlwaysOnTopView()
        view.isAlwaysOnTop = isAlwaysOnTop
        return view
    }

    func updateNSView(_ nsView: AlwaysOnTopView, context: Context) {
        nsView.isAlwaysOnTop = isAlwaysOnTop
        if let window = nsView.window {
            nsView.applyAlwaysOnTop(to: window)
        }
    }
}

class AlwaysOnTopView: NSView {
    var isAlwaysOnTop: Bool = true

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        guard let window else { return }
        applyAlwaysOnTop(to: window)
    }

    func applyAlwaysOnTop(to window: NSWindow) {
        window.level = isAlwaysOnTop ? .floating : .normal

        if isAlwaysOnTop {
            window.collectionBehavior.insert(.canJoinAllSpaces)
        } else {
            window.collectionBehavior.remove(.canJoinAllSpaces)
        }
    }
}
