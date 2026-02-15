import SwiftUI

struct EmergencyPlaceholderView: View {
    @Environment(\.openURL) private var openURL

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
                    sendSilentCall()
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
        .themedBackground()
        .navigationTitle("Emergency")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func sendSilentCall() {
        guard let url = URL(string: "http://10.19.180.135:8000/users/1/silent_call") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        URLSession.shared.dataTask(with: request).resume()
        print("📡 Silent notify POST issued")
    }
}

