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

                    Spacer(minLength: 60)   // ← slightly lower than before

                    AppCard {
                        VStack(alignment: .leading, spacing: 12) {

                            TextField("Title", text: $title)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Theme.text)
                                .textFieldStyle(.plain)

                            Rectangle()
                                .fill(Theme.line)
                                .frame(height: 1)

                            TextEditor(text: $bodyText)
                                .font(.system(size: 15))
                                .foregroundStyle(Theme.text)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                                .frame(minHeight: 260)
                        }
                    }
                    .padding(.horizontal, 18)

                    Spacer(minLength: 40)
                }
                .padding(.top, 12)
            }
            .themedBackground()
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { onSubmit(title, bodyText) }
                }
            }
        }
    }
}
