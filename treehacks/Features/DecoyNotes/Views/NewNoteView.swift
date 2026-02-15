import SwiftUI

struct NewNoteView: View {
    let onSubmit: (String, String) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var bodyText: String = ""

    var body: some View {
        NavigationStack {

            ScrollView {
                VStack(spacing: 24) {

                    Spacer(minLength: 60)

                    AppCard {
                        VStack(alignment: .leading, spacing: 12) {

                            ZStack(alignment: .leading) {
                                if title.isEmpty {
                                    Text("Title")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundStyle(Theme.text)
                                }
                                TextField("", text: $title)
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(Theme.text)
                                    .textFieldStyle(.plain)
                                    .tint(Theme.text)
                            }

                            Rectangle()
                                .fill(Theme.line)
                                .frame(height: 1)

                            TextEditor(text: $bodyText)
                                .font(.system(size: 14))
                                .foregroundColor(Theme.text)
                                .foregroundStyle(Theme.text)
                                .tint(Theme.text)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                                .frame(minHeight: 260)
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 180)   // extra breathing room

                    Spacer(minLength: 60)
                }
            }
            .themedBackground()
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSubmit(title, bodyText)
                        dismiss()
                    }
                }
            }
        }
    }
}

