import SwiftUI

struct DocumentsView: View {
    @EnvironmentObject private var incidentsStore: IncidentsStore

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                ForEach(incidentsStore.incidents) { incident in
                    AppCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(incident.createdAt.formatted())
                                .font(.caption)
                                .foregroundStyle(Theme.text.opacity(0.7))

                            Text(incident.transcript)
                                .foregroundStyle(Theme.text)

                            Text("Peak Risk: \(String(format: "%.1f", incident.peakRisk))")
                                .font(.caption)
                                .foregroundStyle(Theme.text.opacity(0.6))
                        }
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 40)
        }
        .themedBackground()
        .navigationTitle("Documents")
        .navigationBarTitleDisplayMode(.inline)
    }
}
