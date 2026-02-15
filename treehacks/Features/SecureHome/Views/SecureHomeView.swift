import SwiftUI

struct SecureHomeView: View {
    @StateObject private var faceMonitor = FacePresenceMonitor()
    @State private var lockCountdown: Int = 0
    @State private var countdownTimer: Timer? = nil
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
                .padding(.top, 90)
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
            .overlay(alignment: .bottom) {
                if lockCountdown > 0 {
                    GeometryReader { geo in
                        VStack {
                            Spacer()
                            AppCard {
                                Text("Face not detected — auto-locking in \(lockCountdown)s")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(Theme.text)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.vertical, 4)
                            }
                            .frame(height: geo.size.height * 0.05) // 5% tall
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 18)
                            .padding(.bottom, 80) // keep it slightly above the exact bottom
                        }
                    }
                }
            }
        }
        .onAppear { faceMonitor.start() }
        .onDisappear { faceMonitor.stop() }
        .onChange(of: faceMonitor.facePresent) { present in
            if present {
                countdownTimer?.invalidate()
                countdownTimer = nil
                lockCountdown = 0
            } else {
                startCountdown()
            }
        }
    }
    
    private func startCountdown() {
        guard countdownTimer == nil else { return }
        lockCountdown = 3 // seconds
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if lockCountdown > 1 {
                lockCountdown -= 1
            } else {
                countdownTimer?.invalidate()
                countdownTimer = nil
                lockCountdown = 0
                appState.lockToDecoy()
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

