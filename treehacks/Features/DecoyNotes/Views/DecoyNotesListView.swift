//
//  DecoyNotesListView.swift
//  treehacks
//
//  Created by Jacob Schuster on 2/14/26.
//

import SwiftUI

struct DecoyNotesListView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var vm = DecoyNotesViewModel()

    @State private var path = NavigationPath()
    @State private var showingNewTitle = false

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                List {
                    Section(header: Text("\(vm.sortedNotes.count) Notes").foregroundStyle(Theme.sub)) {
                        ForEach(vm.sortedNotes) { note in
                            Button {
                                vm.openNote(note.id)
                                path.append(note.id)
                            } label: {
                                NoteRow(title: note.title, preview: note.body)
                            }
                            .buttonStyle(.plain)
                            .listRowBackground(Theme.card)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Theme.bg)
                .listStyle(.plain)
            }
            .themedBackground()
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingNewTitle = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewTitle) {
                NewNoteTitleView(
                    onSubmit: { title in
                        // if title matches passcode -> secure
                        if appState.verifyPasscode(title) {
                            showingNewTitle = false
                            appState.unlockSecure()
                            return
                        }

                        let id = vm.createNote(title: title.isEmpty ? "New Note" : title)
                        showingNewTitle = false
                        vm.openNote(id)
                        path.append(id)
                    }
                )
            }
            .navigationDestination(for: UUID.self) { noteID in
                NoteEditorView(noteID: noteID)
                    .environmentObject(vm)
            }
        }
    }
}

private struct NoteRow: View {
    let title: String
    let preview: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.text)
                .lineLimit(1)

            Text(preview.isEmpty ? " " : preview)
                .font(.system(size: 13))
                .foregroundStyle(Theme.sub)
                .lineLimit(1)
        }
        .padding(.vertical, 6)
    }
}
