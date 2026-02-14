import SwiftUI

struct NewEventView: View {

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

                            TextField("Event Title", text: $title)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(Theme.text)
                                .textFieldStyle(.plain)

                            Rectangle()
                                .fill(Theme.line)
                                .frame(height: 1)

                            TextEditor(text: $bodyText)
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
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        onSubmit(title, bodyText)
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                }
            }
        }
    }
}
