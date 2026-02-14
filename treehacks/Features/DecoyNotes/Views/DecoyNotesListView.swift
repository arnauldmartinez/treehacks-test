import SwiftUI

struct DecoyNotesListView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var vm = DecoyNotesViewModel()

    @State private var path = NavigationPath()
    @State private var showingNewNote = false

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
                                        Text(note.title)
                                            .font(.system(size: 17, weight: .semibold))
                                            .foregroundStyle(Theme.text)

                                        Text(note.body.isEmpty ? "No additional text" : note.body)
                                            .font(.system(size: 14))
                                            .foregroundStyle(Theme.sub)
                                            .lineLimit(3)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, geo.size.height * 0.10)   // ← 1/10th of screen
                    .padding(.bottom, 40)
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
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                    }
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
                    showingNewNote = false
                    vm.openNote(id)
                    path.append(id)
                }
            }
            .navigationDestination(for: UUID.self) { noteID in
                NoteEditorView(noteID: noteID)
                    .environmentObject(vm)
            }
        }
    }
}
