import SpriteKit
import SwiftUI

#if os(macOS)
struct SpriteKitContainer: NSViewRepresentable {
    let scene: SKScene

    func makeNSView(context: Context) -> SKView {
        let view = SKView()
        view.ignoresSiblingOrder = true
        view.allowsTransparency = false
        view.preferredFramesPerSecond = 60
        view.presentScene(scene)
        return view
    }

    func updateNSView(_ view: SKView, context: Context) {
        if view.scene !== scene {
            view.presentScene(scene)
        }
        view.isPaused = false
        scene.isPaused = false
    }
}
#else
struct SpriteKitContainer: UIViewRepresentable {
    let scene: SKScene

    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        view.ignoresSiblingOrder = true
        view.allowsTransparency = false
        view.preferredFramesPerSecond = 60
        view.presentScene(scene)
        return view
    }

    func updateUIView(_ view: SKView, context: Context) {
        if view.scene !== scene {
            view.presentScene(scene)
        }
        view.isPaused = false
        scene.isPaused = false
    }
}
#endif
