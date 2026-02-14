import SwiftUI

struct DecoyNotesListView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var vm = DecoyNotesViewModel()

    @State private var path = NavigationPath()
    @State private var showingNewNote = false

    private static let ddMMyyFormatter: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "dd/MM/yy"
        return f
    }()

    var body: some View {
        NavigationStack(path: $path) {

            GeometryReader { geo in
                ScrollView {
                    LazyVStack(spacing: 16) {

                        ForEach(vm.sortedNotes) { note in
                            Button {
                                vm.openNote(note.id)
                                path.append(note.id)
                            } label: {
                                AppCard {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack(alignment: .firstTextBaseline) {
                                            Text(note.title)
                                                .font(.system(size: 17, weight: .semibold))
                                                .foregroundStyle(Theme.text)
                                                .lineLimit(1)

                                            Spacer(minLength: 8)

                                            Text(Self.ddMMyyFormatter.string(from: note.updatedAt))
                                                .font(.system(size: 12))
                                                .foregroundStyle(Theme.sub)
                                        }

                                        Text(note.body.isEmpty ? "No additional text" : note.body)
                                            .font(.system(size: 14))
                                            .foregroundStyle(Theme.sub)
                                            .lineLimit(3)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, geo.size.height * 0.10)
                    .padding(.bottom, 60)
                }
            }
            .themedBackground()
            .navigationTitle("Notes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingNewNote = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 22))
                            .foregroundStyle(Theme.accent)
                    }
                    .buttonStyle(.plain)
                }
            }
            .tint(Theme.accent)
            .sheet(isPresented: $showingNewNote) {
                NewNoteView { title, body in
                    let cleaned = title.trimmingCharacters(in: .whitespacesAndNewlines)

                    if appState.verifyPasscode(cleaned) {
                        showingNewNote = false
                        appState.unlockSecure()
                        return
                    }

                    let id = vm.createNote(title: cleaned.isEmpty ? "New Note" : cleaned)
                    vm.bindingBody(for: id).wrappedValue = body

                    showingNewNote = false   // ← returns to main page
                }
            }
            .navigationDestination(for: UUID.self) { noteID in
                NoteEditorView(noteID: noteID)
                    .environmentObject(vm)
            }
        }
    }
}

