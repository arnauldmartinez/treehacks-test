import SwiftUI
import Combine

struct DecoyNote: Identifiable, Hashable {
    let id: UUID
    var title: String
    var body: String
    var updatedAt: Date
    var lastOpenedAt: Date
}

@MainActor
final class DecoyNotesViewModel: ObservableObject {
    @Published private(set) var notes: [DecoyNote]

    init() {
        self.notes = Self.seed()
    }

    var sortedNotes: [DecoyNote] {
        notes.sorted { $0.lastOpenedAt > $1.lastOpenedAt }
    }

    func createNote(title: String) -> UUID {
        let now = Date()
        let note = DecoyNote(id: UUID(), title: title, body: "", updatedAt: now, lastOpenedAt: now)
        notes.insert(note, at: 0)
        return note.id
    }

    func openNote(_ id: UUID) {
        guard let idx = notes.firstIndex(where: { $0.id == id }) else { return }
        notes[idx].lastOpenedAt = Date()
    }

    func bindingTitle(for id: UUID) -> Binding<String> {
        Binding(
            get: { self.notes.first(where: { $0.id == id })?.title ?? "" },
            set: { newValue in
                guard let idx = self.notes.firstIndex(where: { $0.id == id }) else { return }
                self.notes[idx].title = newValue
                self.notes[idx].updatedAt = Date()
            }
        )
    }

    func bindingBody(for id: UUID) -> Binding<String> {
        Binding(
            get: { self.notes.first(where: { $0.id == id })?.body ?? "" },
            set: { newValue in
                guard let idx = self.notes.firstIndex(where: { $0.id == id }) else { return }
                self.notes[idx].body = newValue
                self.notes[idx].updatedAt = Date()
            }
        )
    }

    private static func seed() -> [DecoyNote] {
        let now = Date()
        func daysAgo(_ n: Int) -> Date {
            Calendar.current.date(byAdding: .day, value: -n, to: now) ?? now
        }
        return [
            DecoyNote(id: UUID(), title: "Groceries", body: "eggs, rice, spinach, peanut butter", updatedAt: daysAgo(1), lastOpenedAt: daysAgo(1)),
            DecoyNote(id: UUID(), title: "Class notes", body: "office hours, problem set, quiz topics", updatedAt: daysAgo(3), lastOpenedAt: daysAgo(3)),
            DecoyNote(id: UUID(), title: "To do", body: "laundry, email advisor, call mom", updatedAt: daysAgo(6), lastOpenedAt: daysAgo(2))
        ]
    }
}
