//
//  NoteEditorView.swift
//  treehacks
//
//  Created by Jacob Schuster on 2/14/26.
//

import SwiftUI

struct NoteEditorView: View {
    @EnvironmentObject private var vm: DecoyNotesViewModel
    let noteID: UUID

    var body: some View {
        VStack(spacing: 12) {
            AppCard {
                TextEditor(text: vm.bindingBody(for: noteID))
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.text)
                    .frame(minHeight: 260)
            }
            .padding(.horizontal, 18)
            .padding(.top, 14)

            Spacer()
        }
        .themedBackground()
        .navigationTitle(vm.bindingTitle(for: noteID).wrappedValue)
        .navigationBarTitleDisplayMode(.inline)
    }
}
