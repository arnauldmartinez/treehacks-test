import SwiftUI

struct ThreatMonitorTestView: View {

    @StateObject private var monitor = ThreatMonitor()

    var body: some View {
        ZStack {

            VStack(spacing: 20) {

                Toggle("Monitoring", isOn: $monitor.isMonitoring)
                    .onChange(of: monitor.isMonitoring) { value in
                        monitor.toggleMonitoring(value)
                    }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Stage: \(monitor.stage.rawValue)")
                    Text("RMS: \(String(format: "%.4f", monitor.currentRMS))")

                    if !monitor.lastIncidentFileName.isEmpty {
                        Text("Last Saved: \(monitor.lastIncidentFileName)")
                            .font(.caption)
                    }
                }

                ScrollView {
                    Text(monitor.transcriptLive)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
                .frame(height: 160)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)

                Spacer()
            }
            .padding()
            .themedBackground()

            // 🔥 Decision Overlay
            if let decision = monitor.lastDecisionMessage {
                VStack {
                    Spacer()

                    Text(decision)
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.bottom, 40)
                        .transition(.opacity)

                }
                .animation(.easeInOut, value: decision)
            }
        }
    }
}
