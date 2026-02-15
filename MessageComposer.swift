import SwiftUI
#if canImport(MessageUI)
import MessageUI
#endif

#if canImport(MessageUI)
struct MessageComposer: UIViewControllerRepresentable {
    let recipients: [String]
    let bodyText: String
    @Environment(\.presentationMode) private var presentationMode

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        let vc = MFMessageComposeViewController()
        vc.messageComposeDelegate = context.coordinator
        vc.recipients = recipients
        vc.body = bodyText
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {}

    final class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        var parent: MessageComposer

        init(_ parent: MessageComposer) {
            self.parent = parent
        }

        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
#else
// Fallback for platforms without MessageUI
struct MessageComposer: View {
    let recipients: [String]
    let bodyText: String
    var body: some View { Text("Messaging not available on this platform.") }
}
#endif
