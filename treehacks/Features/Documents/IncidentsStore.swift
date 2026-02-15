import Foundation
import Combine

final class IncidentsStore: ObservableObject {
    @Published private(set) var incidents: [Incident] = []

    private let saveURL: URL

    init() {
        // Persist incidents metadata (NOT audio) to Application Support
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let dir = base.appendingPathComponent("Treehacks", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

        self.saveURL = dir.appendingPathComponent("incidents.json")
        load()
    }

    func addIncident(_ incident: Incident) {
        incidents.insert(incident, at: 0)
        save()
    }

    func deleteIncident(_ incident: Incident) {
        incidents.removeAll { $0.id == incident.id }
        save()
        // Optional: delete audio file too
        let url = URL(fileURLWithPath: incident.audioFilePath)
        try? FileManager.default.removeItem(at: url)
    }

    private func load() {
        guard let data = try? Data(contentsOf: saveURL) else { return }
        if let decoded = try? JSONDecoder().decode([Incident].self, from: data) {
            incidents = decoded
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(incidents) else { return }
        try? data.write(to: saveURL, options: [.atomic])
    }
}
