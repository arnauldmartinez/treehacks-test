import SwiftUI
import Combine
import Foundation

@MainActor
final class SecureEventsViewModel: ObservableObject {

    // Notification for external updates so any active view models can reload
    static let eventsUpdatedNotification = Notification.Name("secure_events_updated")

    @Published private(set) var events: [SecureEvent] = [] {
        didSet {
            save()
        }
    }

    private let storageKey = "secure_events_storage"
    private var externalUpdatesObserver: NSObjectProtocol?

    // MARK: - File Storage (Documents directory)
    private var documentsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private func saveDataToDocuments(_ data: Data, preferredName: String, fileExtension: String) throws -> String {
        let base = preferredName.replacingOccurrences(of: " ", with: "_")
        let suffix = String(UUID().uuidString.prefix(8))
        let filename = base + "_" + suffix + "." + fileExtension
        let url = documentsURL.appendingPathComponent(filename)
        try data.write(to: url, options: .atomic)
        return filename
    }

    private func removeFile(named filename: String) {
        let url = documentsURL.appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: url)
    }

    init() {
        load()
        externalUpdatesObserver = NotificationCenter.default.addObserver(forName: Self.eventsUpdatedNotification, object: nil, queue: .main) { [weak self] _ in
            print("[SecureEvents] Received external update notification — reloading from disk")
            self?.load()
        }
    }

    deinit {
        if let token = externalUpdatesObserver {
            NotificationCenter.default.removeObserver(token)
        }
    }

    var sortedEvents: [SecureEvent] {
        events.sorted { $0.updatedAt > $1.updatedAt }
    }

    // MARK: - Create

    func createEvent(title: String, body: String, photoDatas: [Data] = [], audioDatas: [Data] = []) {
        let now = Date()

        var photoNames: [String] = []
        for data in photoDatas {
            if let name = try? saveDataToDocuments(data, preferredName: "photo", fileExtension: "jpg") {
                photoNames.append(name)
            }
        }

        var audioNames: [String] = []
        for data in audioDatas {
            if let name = try? saveDataToDocuments(data, preferredName: "audio", fileExtension: "m4a") {
                audioNames.append(name)
            }
        }

        let event = SecureEvent(
            id: UUID(),
            title: title,
            body: body,
            updatedAt: now,
            photoFileNames: photoNames,
            audioFileNames: audioNames
        )
        events.insert(event, at: 0)
    }

    // MARK: - Delete

    func deleteEvent(_ id: UUID) {
        events.removeAll { $0.id == id }
    }

    // MARK: - Bindings (for editing)

    func bindingTitle(for id: UUID) -> Binding<String> {
        Binding(
            get: {
                self.events.first(where: { $0.id == id })?.title ?? ""
            },
            set: { newValue in
                guard let index = self.events.firstIndex(where: { $0.id == id }) else { return }
                self.events[index].title = newValue
                self.events[index].updatedAt = Date()
            }
        )
    }

    func bindingBody(for id: UUID) -> Binding<String> {
        Binding(
            get: {
                self.events.first(where: { $0.id == id })?.body ?? ""
            },
            set: { newValue in
                guard let index = self.events.firstIndex(where: { $0.id == id }) else { return }
                self.events[index].body = newValue
                self.events[index].updatedAt = Date()
            }
        )
    }

    // MARK: - Attachments

    func addPhoto(_ data: Data, to id: UUID) {
        guard let index = events.firstIndex(where: { $0.id == id }) else { return }
        do {
            let name = try saveDataToDocuments(data, preferredName: "photo", fileExtension: "jpg")
            events[index].photoFileNames.append(name)
            events[index].updatedAt = Date()
        } catch {
            print("Failed to save photo:", error)
        }
    }

    func addAudio(_ data: Data, to id: UUID) {
        guard let index = events.firstIndex(where: { $0.id == id }) else { return }
        do {
            let name = try saveDataToDocuments(data, preferredName: "audio", fileExtension: "m4a")
            events[index].audioFileNames.append(name)
            events[index].updatedAt = Date()
        } catch {
            print("Failed to save audio:", error)
        }
    }

    func removePhoto(named filename: String, from id: UUID) {
        guard let index = events.firstIndex(where: { $0.id == id }) else { return }
        events[index].photoFileNames.removeAll { $0 == filename }
        removeFile(named: filename)
        events[index].updatedAt = Date()
    }

    func removeAudio(named filename: String, from id: UUID) {
        guard let index = events.firstIndex(where: { $0.id == id }) else { return }
        events[index].audioFileNames.removeAll { $0 == filename }
        removeFile(named: filename)
        events[index].updatedAt = Date()
    }

    func urlForAttachment(named filename: String) -> URL {
        documentsURL.appendingPathComponent(filename)
    }

    // MARK: - Persistence

    private func save() {
        do {
            let data = try JSONEncoder().encode(events)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Failed to save secure events:", error)
        }
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([SecureEvent].self, from: data)
        else {
            events = []
            return
        }

        events = decoded
    }

    // MARK: - Static helpers for background saves
    /// Load events directly from persistent storage (UserDefaults)
    private static func loadEventsFromDisk() -> [SecureEvent] {
        guard
            let data = UserDefaults.standard.data(forKey: "secure_events_storage"),
            let decoded = try? JSONDecoder().decode([SecureEvent].self, from: data)
        else {
            return []
        }
        return decoded
    }

    /// Save events directly to persistent storage (UserDefaults)
    private static func saveEventsToDisk(_ events: [SecureEvent]) {
        do {
            let data = try JSONEncoder().encode(events)
            UserDefaults.standard.set(data, forKey: "secure_events_storage")
        } catch {
            print("Failed to save secure events:", error)
        }
    }

    /// Append a generic incident with a custom title, transcript and timestamp.
    static func appendIncident(title: String, transcript: String, timestamp: Date = Date()) {
        var events = loadEventsFromDisk()
        let beforeCount = events.count

        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        let when = formatter.string(from: timestamp)

        let body = "Timestamp: \(when)\n\nTranscript:\n\(transcript)"

        let newEvent = SecureEvent(
            id: UUID(),
            title: title,
            body: body,
            updatedAt: timestamp,
            photoFileNames: [],
            audioFileNames: []
        )

        events.insert(newEvent, at: 0)
        saveEventsToDisk(events)

        print("[SecureEvents] Appended incident '", title, "' (transcript length: \(transcript.count)). Events before: \(beforeCount), after: \(events.count)")
        NotificationCenter.default.post(name: eventsUpdatedNotification, object: nil)
        print("[SecureEvents] Posted eventsUpdatedNotification")
    }

    /// Append a verbal abuse incident as a new event with transcript and timestamp.
    static func appendVerbalAbuseIncident(transcript: String, timestamp: Date = Date()) {
        appendIncident(title: "Verbal Abuse Incident", transcript: transcript, timestamp: timestamp)
    }
}

