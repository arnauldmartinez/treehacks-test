import SwiftUI
import Combine

#if canImport(UIKit)
import UIKit
#endif

// MARK: - ContentView (entry view used by your App file)

struct ContentView: View {
    var body: some View {
        Root()
    }
}

// MARK: - Model

struct Note: Identifiable, Hashable {
    let id: UUID
    var title: String
    var preview: String
    var updatedAt: Date
}

// MARK: - Store

@MainActor
final class NotesStore: ObservableObject {
    @Published var query: String = ""
    @Published var notes: [Note] = NotesStore.seed()
    @Published var selectedID: UUID?

    var filtered: [Note] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return notes }
        return notes.filter { ("\($0.title) \($0.preview)").lowercased().contains(q) }
    }

    var selected: Note? {
        guard let selectedID else { return nil }
        return notes.first(where: { $0.id == selectedID })
    }

    func ensureSelection() {
        if selectedID == nil { selectedID = notes.first?.id }
    }

    private static func seed() -> [Note] {
        let now = Date()
        func daysAgo(_ n: Int) -> Date {
            Calendar.current.date(byAdding: .day, value: -n, to: now) ?? now
        }
        return [
            .init(id: UUID(), title: "Groceries",  preview: "eggs, rice, spinach, peanut butter", updatedAt: daysAgo(1)),
            .init(id: UUID(), title: "Class notes", preview: "office hours, problem set, quiz topics", updatedAt: daysAgo(3)),
            .init(id: UUID(), title: "To do",      preview: "laundry, email advisor, call mom", updatedAt: daysAgo(6)),
            .init(id: UUID(), title: "Recipes",    preview: "pasta sauce: garlic + tomato paste + basil", updatedAt: daysAgo(10))
        ]
    }
}

// MARK: - Palette / Formatting

enum P {
    static let bg   = Color(white: 0.965)
    static let card = Color.white
    static let line = Color(white: 0.90)
    static let text = Color(white: 0.11)
    static let sub  = Color(white: 0.56)
    static let tint = Color(red: 0.95, green: 0.90, blue: 0.65)
}

enum Fmt {
    static func when(_ date: Date) -> String {
        let now = Date()
        let delta = now.timeIntervalSince(date)

        if delta < 24 * 60 * 60 {
            let f = DateFormatter()
            f.locale = .current
            f.timeStyle = .short
            f.dateStyle = .none
            return f.string(from: date)
        }
        if delta < 48 * 60 * 60 { return "Yesterday" }

        let f = DateFormatter()
        f.locale = .current
        f.setLocalizedDateFormatFromTemplate("MMM d")
        return f.string(from: date)
    }

    static func full(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = .current
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: date)
    }
}

// MARK: - Platform helpers

enum Platform {
    static var shouldUseSplit: Bool {
        #if os(macOS)
        return true
        #else
        #if canImport(UIKit)
        return UIDevice.current.userInterfaceIdiom == .pad
        #else
        return false
        #endif
        #endif
    }
}

// MARK: - UI

struct Root: View {
    @StateObject private var store = NotesStore()

    var body: some View {
        NavigationStack {
            NotesList()
                .environmentObject(store)
        }
        .onAppear { store.ensureSelection() }
    }
}

struct NotesList: View {
    @EnvironmentObject private var store: NotesStore

    var body: some View {
        ZStack {
            P.bg.ignoresSafeArea()

            if Platform.shouldUseSplit {
                split
            } else {
                phone
            }
        }
        .navigationTitle("Notes")
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Text("Last synced: 3 days ago")
                    .font(.footnote)
                    .foregroundStyle(P.sub)
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(P.sub)

            TextField("Search", text: $store.query)
                #if !os(macOS)
                .textInputAutocapitalization(.never)
                #endif
                .disableAutocorrection(true)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(P.card)
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(P.line, lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.top, 6)
        .padding(.bottom, 10)
    }

    private var phone: some View {
        VStack(spacing: 0) {
            searchBar

            List {
                Section(header: Text("\(store.filtered.count) Notes")) {
                    ForEach(store.filtered) { note in
                        NavigationLink {
                            NoteDetail(note: note)
                        } label: {
                            Row(note: note)
                        }
                        .listRowBackground(P.card)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(P.bg)
            .listStyle(.plain)
        }
    }

    private var split: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                searchBar

                List(selection: $store.selectedID) {
                    Section(header: Text("\(store.filtered.count) Notes")) {
                        ForEach(store.filtered) { note in
                            Row(note: note)
                                .tag(note.id as UUID?)
                                .listRowBackground((store.selectedID == note.id) ? P.tint : P.card)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(P.bg)
                .listStyle(.plain)
            }
            .frame(minWidth: 320, idealWidth: 360, maxWidth: 420)
            .overlay(alignment: .trailing) { Rectangle().fill(P.line).frame(width: 1) }

            DetailPane()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct Row: View {
    let note: Note

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                Text(note.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(P.text)
                    .lineLimit(1)

                Spacer(minLength: 8)

                Text(Fmt.when(note.updatedAt))
                    .font(.system(size: 12))
                    .foregroundStyle(P.sub)
            }

            Text(note.preview)
                .font(.system(size: 13))
                .foregroundStyle(P.sub)
                .lineLimit(1)
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }
}

struct NoteDetail: View {
    let note: Note

    var body: some View {
        ZStack {
            P.bg.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    Text(note.title)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(P.text)

                    Text(Fmt.full(note.updatedAt))
                        .font(.system(size: 12))
                        .foregroundStyle(P.sub)

                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(P.card)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(P.line, lineWidth: 1)
                        )
                        .frame(minHeight: 180)
                        .overlay(alignment: .topLeading) {
                            Text(note.preview + "\n\n(This is just a style mock. No editing yet.)")
                                .font(.system(size: 14))
                                .foregroundStyle(P.text)
                                .padding(14)
                        }
                        .padding(.top, 8)

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 18)
                .padding(.top, 14)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("")
        #if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct DetailPane: View {
    @EnvironmentObject private var store: NotesStore

    var body: some View {
        ZStack {
            P.bg.ignoresSafeArea()

            if let note = store.selected {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(note.title)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(P.text)

                        Text(Fmt.full(note.updatedAt))
                            .font(.system(size: 12))
                            .foregroundStyle(P.sub)

                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(P.card)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(P.line, lineWidth: 1)
                            )
                            .frame(minHeight: 240)
                            .overlay(alignment: .topLeading) {
                                Text(note.preview + "\n\n(This is just a style mock. No editing yet.)")
                                    .font(.system(size: 14))
                                    .foregroundStyle(P.text)
                                    .padding(14)
                            }
                            .padding(.top, 8)

                        Spacer(minLength: 24)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 14)
                    .padding(.bottom, 24)
                }
            } else {
                Text("No note selected.")
                    .foregroundStyle(P.sub)
                    .font(.system(size: 14))
            }
        }
    }
}
