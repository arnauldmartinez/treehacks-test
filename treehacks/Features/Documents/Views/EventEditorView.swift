//
//  EventEditorView.swift
//  treehacks
//
//  Created by Arnauld Martinez on 2/14/26.
//

import SwiftUI

struct EventEditorView: View {

    let eventID: UUID
    @EnvironmentObject private var vm: SecureEventsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                Spacer(minLength: 60)

                AppCard {
                    VStack(alignment: .leading, spacing: 12) {

                        TextField(
                            "Title",
                            text: vm.bindingTitle(for: eventID)
                        )
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Theme.text)
                        .textFieldStyle(.plain)

                        Rectangle()
                            .fill(Theme.line)
                            .frame(height: 1)

                        TextEditor(
                            text: vm.bindingBody(for: eventID)
                        )
                        .font(.system(size: 16))
                        .foregroundStyle(Theme.text)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                        .frame(minHeight: 300)
                    }
                }
                .padding(.horizontal, 18)

                Spacer(minLength: 60)
            }
        }
        .themedBackground()
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    vm.deleteEvent(eventID)
                    dismiss()
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                }
            }
        }
    }
}
