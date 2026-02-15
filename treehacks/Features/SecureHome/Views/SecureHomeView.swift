import SwiftUI

struct SecureHomeView: View {
    @EnvironmentObject private var appState: AppState

    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]

    var body: some View {
        NavigationStack {

            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {

                    SecureTile(title: "Documents", systemImage: "doc.text") {
                        DocumentsView()
                    }

                    SecureTile(title: "AI Support", systemImage: "brain.head.profile") {
                        AISupportPlaceholderView()
                    }

                    SecureTile(title: "Forums", systemImage: "person.3") {
                        ForumsPlaceholderView()
                    }

                    SecureTile(title: "Emergency", systemImage: "exclamationmark.triangle") {
                        EmergencyPlaceholderView()
                    }

                    SecureTile(title: "Chats", systemImage: "bubble.left.and.bubble.right") {
                        ChatsPlaceholderView()
                    }
                    
                    SecureTile(title: "Threat Test", systemImage: "waveform.path.ecg") {
                        ThreatMonitorTestView()
                    }
                    
                    
                }
                .padding(.horizontal, 18)
                .padding(.top, 60)
                .padding(.bottom, 60)
            }
            .themedBackground()
            .navigationTitle("Secure")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Lock") {
                        appState.lockToDecoy()
                    }
                }
            }
        }
    }
}

private struct SecureTile<Destination: View>: View {
    let title: String
    let systemImage: String
    let destination: Destination

    init(title: String, systemImage: String, @ViewBuilder destination: () -> Destination) {
        self.title = title
        self.systemImage = systemImage
        self.destination = destination()
    }

    var body: some View {
        NavigationLink {
            destination
                .themedBackground()
        } label: {
            AppCard {
                VStack(spacing: 12) {
                    Image(systemName: systemImage)
                        .font(.system(size: 28))
                        .foregroundStyle(Theme.text)

                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.text)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .buttonStyle(.plain)
    }
}
