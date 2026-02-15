import SwiftUI

struct ChatsPlaceholderView: View {
    @StateObject private var vm = ChatsViewModel()
    @State private var experts: [Expert] = Expert.sample
    @State private var selected: Expert? = nil
    @State private var draft: String = ""
    @State private var isSidebarCollapsed: Bool = false

    var body: some View {
        NavigationStack {
            HStack(spacing: 0) {
                if !isSidebarCollapsed {
                    // Left sidebar with expert tiles
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(experts) { expert in
                                Button {
                                    selected = expert
                                } label: {
                                    ExpertTile(expert: expert, isSelected: selected?.id == expert.id)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.bottom, 12)
                        .padding(.top, 80)
                    }
                    .frame(width: 280)
                    .background(.ultraThinMaterial)

                    Divider()
                }

                // Main chat area
                Group {
                    if let expert = selected {
                        VStack(spacing: 0) {
                            // Header
                            HStack {
                                Text(expert.displayName)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(Theme.text)
                                Spacer()
                                Text(expert.degree)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(Theme.sub)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .padding(.top, isSidebarCollapsed ? 60 : 0)

                            Divider()

                            // Chat messages (grow from top) with protected bottom 10%
                            GeometryReader { chatGeo in
                                ScrollViewReader { proxy in
                                    ScrollView {
                                        LazyVStack(alignment: .leading, spacing: 12) {
                                            ForEach(vm.messages(for: expert.id)) { msg in
                                                ChatBubbleRow(message: msg)
                                                    .padding(.horizontal, 18)
                                            }

                                            // Bottom spacer ensures bubbles never render within the bottom 10% region
                                            Color.clear
                                                .frame(height: chatGeo.size.height * 0.10)
                                                .id("bottom")
                                        }
                                        .padding(.top, 12)
                                        .padding(.bottom, 12)
                                    }
                                    // Hide the bottom 10% of the scroll content visually
                                    .mask(
                                        LinearGradient(
                                            stops: [
                                                .init(color: .black, location: 0.0),
                                                .init(color: .black, location: 0.90),
                                                .init(color: .clear, location: 1.0)
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .onChange(of: vm.count(for: expert.id)) { _ in
                                        withAnimation(.easeOut(duration: 0.2)) {
                                            proxy.scrollTo("bottom", anchor: .bottom)
                                        }
                                    }
                                    .onAppear {
                                        DispatchQueue.main.async {
                                            proxy.scrollTo("bottom", anchor: .bottom)
                                        }
                                    }
                                }
                            }

                            // Input bar (non-functional for now except clearing text)
                            HStack(spacing: 12) {
                                TextField("Type a message…", text: $draft)
                                    .textFieldStyle(.plain)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Color.white.opacity(0.85))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Theme.tileStroke, lineWidth: 1)
                                    )

                                Button {
                                    let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
                                    guard !text.isEmpty, let expert = selected else { return }
                                    vm.appendUser(text: text, to: expert.id)
                                    draft = ""
                                } label: {
                                    Image(systemName: "paperplane.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(.white)
                                        .padding(10)
                                        .background(Circle().fill(Theme.accent))
                                }
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 10)
                            .background(.ultraThinMaterial)
                            .padding(.bottom, 80)
                        }
                    } else {
                        VStack(spacing: 10) {
                            Text("Select an expert to start a chat")
                                .font(.system(size: 16))
                                .foregroundStyle(Theme.sub)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .themedBackground()
            .navigationTitle("Chats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isSidebarCollapsed.toggle()
                        }
                    } label: {
                        Image(systemName: isSidebarCollapsed ? "sidebar.right" : "sidebar.left")
                    }
                    .accessibilityLabel(isSidebarCollapsed ? "Show sidebar" : "Hide sidebar")
                }
            }
        }
    }
}
// MARK: - Expert Model

private struct Expert: Identifiable, Hashable {
    let id = UUID()
    let firstName: String
    let lastName: String
    let degree: String

    var displayName: String { "Dr. \(lastName)" }

    static let sample: [Expert] = [
        Expert(firstName: "Amelia", lastName: "Cooper", degree: "M.D."),
        Expert(firstName: "Jacob", lastName: "Schuster", degree: "J.D."),
        Expert(firstName: "Arnauld", lastName: "Martinez", degree: "Ph.D."),
        Expert(firstName: "Priya", lastName: "Patel", degree: "J.D."),
        Expert(firstName: "Minh", lastName: "Nguyen", degree: "M.D."),
        Expert(firstName: "Lena", lastName: "Khan", degree: "L.C.S.W."),
    ]
}

// MARK: - Tile View

private struct ExpertTile: View {
    let expert: Expert
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Theme.accent)
                .frame(width: 32, height: 32)
                .overlay(
                    Text(String(expert.lastName.prefix(1)))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(expert.displayName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.text)
                Text(expert.degree)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.sub)
            }
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Theme.tileFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Theme.accent : Theme.tileStroke, lineWidth: isSelected ? 2 : 1)
                )
                .shadow(color: Theme.tileShadow, radius: 6, x: 0, y: 2)
        )
    }
}

private struct ChatBubbleRow: View {
    let message: ChatsMessage
    var body: some View {
        HStack(spacing: 0) {
            Spacer(minLength: 0)
            bubble
                .frame(maxWidth: UIScreen.main.bounds.width * 0.72, alignment: .trailing)
        }
        .frame(maxWidth: .infinity)
    }

    private var bubble: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(message.content)
                .font(.system(size: 15))
                .foregroundStyle(Theme.text)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Theme.accent)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Theme.tileStroke, lineWidth: 1)
                )
                .shadow(color: Theme.tileShadow, radius: 6, x: 0, y: 2)
        )
    }
}

