import SwiftUI
#if canImport(MessageUI)
import MessageUI
#endif

struct EmergencyPlaceholderView: View {
    @Environment(\.openURL) private var openURL
    @State private var showSMSComposer = false
    @State private var showSMSError = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Top button: Call Authorities
                Button(action: {
                    if let url = URL(string: "tel://8572189851") {
                        openURL(url)
                    }
                }) {
                    AppCard {
                        Text("Call Authorities")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Theme.text)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 12)
                    }
                }
                .buttonStyle(.plain)

                // Bottom button: Silently Notify Authorities
                Button(action: {
                    #if canImport(MessageUI)
                    if MFMessageComposeViewController.canSendText() {
                        showSMSComposer = true
                    } else {
                        showSMSError = true
                    }
                    #else
                    showSMSError = true
                    #endif
                }) {
                    AppCard {
                        Text("Silently Notify Authorities")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(Theme.text)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 12)
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 18)
            .padding(.top, 90)
            .padding(.bottom, 60)
        }
        .sheet(isPresented: $showSMSComposer) {
            MessageComposer(
                recipients: ["8572189851"],
                bodyText: "User is threatened, call authorities"
            )
        }
        .alert("Messaging not available", isPresented: $showSMSError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("This device is not configured to send text messages.")
        }
        .themedBackground()
        .navigationTitle("Emergency")
        .navigationBarTitleDisplayMode(.inline)
    }
}

