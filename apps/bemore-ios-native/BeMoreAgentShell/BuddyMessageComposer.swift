import MessageUI
import SwiftUI

struct BuddyMessageComposer: UIViewControllerRepresentable {
    let body: String
    @Environment(\.dismiss) private var dismiss

    final class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        let parent: BuddyMessageComposer

        init(parent: BuddyMessageComposer) {
            self.parent = parent
        }

        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            parent.dismiss()
        }
    }

    static var canSendText: Bool {
        MFMessageComposeViewController.canSendText()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let controller = MFMessageComposeViewController()
        controller.body = body
        controller.messageComposeDelegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {}
}
