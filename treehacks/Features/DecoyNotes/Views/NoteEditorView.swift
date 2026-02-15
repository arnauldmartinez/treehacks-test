import SwiftUI

struct NoteEditorView: View {
    @EnvironmentObject private var vm: DecoyNotesViewModel
    let noteID: UUID

    var body: some View {
        ScrollView {

            VStack(spacing: 24) {

                Spacer(minLength: 24)   // ← push content below nav title

                AppCard {
                    VStack(alignment: .leading, spacing: 12) {
                        TextField("Title", text: vm.bindingTitle(for: noteID))
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Theme.text)

                        Divider().opacity(0.2)

                        TextEditor(text: vm.bindingBody(for: noteID))
                            .font(.system(size: 15))
                            .foregroundStyle(Theme.text)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .frame(minHeight: 280)
                    }
                }
                .padding(.horizontal, 18)

                Spacer(minLength: 40)
            }
            .padding(.top, 180)   // extra breathing room
        }
        .scrollContentBackground(.hidden)
        .themedBackground()
        .navigationTitle(vm.bindingTitle(for: noteID).wrappedValue)
        .navigationBarTitleDisplayMode(.inline)
    }
}

