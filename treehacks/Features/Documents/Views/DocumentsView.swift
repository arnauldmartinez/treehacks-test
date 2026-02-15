import SwiftUI

struct DocumentsView: View {

    @StateObject private var vm = SecureEventsViewModel()
    @State private var goToNewEvent = false

    private static let ddMMyyFormatter: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "dd/MM/yy"
        return f
    }()

    var body: some View {
        ZStack {

            GeometryReader { geo in
                ScrollView {
                    LazyVStack(spacing: 16) {

                        ForEach(vm.sortedEvents) { event in
                            NavigationLink {
                                EventEditorView(eventID: event.id)
                                    .environmentObject(vm)
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

                                        HStack(spacing: 12) {
                                            if !event.photoFileNames.isEmpty {
                                                Label("\(event.photoFileNames.count)", systemImage: "photo")
                                                    .font(.system(size: 12))
                                                    .foregroundStyle(Theme.sub)
                                            }
                                            if !event.audioFileNames.isEmpty {
                                                Label("\(event.audioFileNames.count)", systemImage: "waveform")
                                                    .font(.system(size: 12))
                                                    .foregroundStyle(Theme.sub)
                                            }
                                        }
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
            NavigationLink(isActive: $goToNewEvent) {
                NewEventView { title, body, photos, audios in
                    let cleaned = title.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    vm.createEvent(
                        title: cleaned.isEmpty ? "Untitled Event" : cleaned,
                        body: body,
                        photoDatas: photos,
                        audioDatas: audios
                    )
                }
            } label: { EmptyView() }
            .hidden()
        }
        .themedBackground()
        .navigationTitle("Events")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    goToNewEvent = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 22))
                        .foregroundStyle(Theme.accent)
                }
                .buttonStyle(.plain)
            }
        }
        .tint(Theme.accent)
    }
}
