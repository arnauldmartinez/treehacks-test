import SwiftUI
import Combine

@MainActor
final class SecureEventsViewModel: ObservableObject {

    @Published private(set) var events: [SecureEvent] = [] {
        didSet {
            save()
        }
    }

    private let storageKey = "secure_events_storage"

    init() {
        load()
    }

    var sortedEvents: [SecureEvent] {
        events.sorted { $0.updatedAt > $1.updatedAt }
    }

    // MARK: - Create

    func createEvent(title: String, body: String) {
        let now = Date()
        let event = SecureEvent(
            id: UUID(),
            title: title,
            body: body,
            updatedAt: now
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
}
