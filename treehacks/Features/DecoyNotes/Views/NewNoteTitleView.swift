//
//  NewNoteTitleView.swift
//  treehacks
//
//  Created by Jacob Schuster on 2/14/26.
//

import SwiftUI

struct NewNoteTitleView: View {
    let onSubmit: (String) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                AppCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Title")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Theme.text)

                        TextField("Enter title", text: $title)
                            .disableAutocorrection(true)
                            .textFieldStyle(.plain)
                    }
                }
                .frame(maxWidth: .infinity)

                Spacer()
            }
            .padding(18)
            .themedBackground()
            .navigationTitle("New Note")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") { onSubmit(title.trimmingCharacters(in: .whitespacesAndNewlines)) }
                }
            }
        }
    }
}
