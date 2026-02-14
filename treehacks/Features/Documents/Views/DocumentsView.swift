import SwiftUI

struct DocumentsView: View {

    @StateObject private var vm = SecureEventsViewModel()
    @State private var showingNewEvent = false
    @State private var path = NavigationPath()

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

                        ForEach(vm.sortedEvents) { event in
                            Button {
                                path.append(event.id)
                            } label: {
                                AppCard {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack(alignment: .firstTextBaseline) {
                                            Text(event.title)
                                                .font(.system(size: 17, weight: .semibold))
                                                .foregroundStyle(Theme.text)
                                                .lineLimit(1)

                                            Spacer(minLength: 8)

                                            Text(Self.ddMMyyFormatter.string(from: event.updatedAt))
                                                .font(.system(size: 12))
                                                .foregroundStyle(Theme.sub)
                                        }

                                        Text(event.body.isEmpty ? "No additional text" : event.body)
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
            .navigationTitle("Events")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingNewEvent = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 22))
                            .foregroundStyle(Theme.accent)
                    }
                    .buttonStyle(.plain)
                }
            }
            .tint(Theme.accent)
            .sheet(isPresented: $showingNewEvent) {
                NewEventView { title, body in
                    let cleaned = title.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    vm.createEvent(
                        title: cleaned.isEmpty ? "Untitled Event" : cleaned,
                        body: body
                    )
                }
            }
            .navigationDestination(for: UUID.self) { eventID in
                EventEditorView(eventID: eventID)
                    .environmentObject(vm)
            }
        }
    }
}
