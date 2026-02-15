import SwiftUI
import PhotosUI

struct AISupportPlaceholderView: View {
    @State private var inputText: String = ""
    @FocusState private var inputFocused: Bool
    @State private var messages: [ChatMessage] = []
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var attachedImageData: Data? = nil
    private let chatService = OpenAIChatService()
    private let legalContext: String = """
    You are a trauma‑informed legal assistant. Purpose: provide general information about emotional and physical abuse, safety planning, and legal options. You are not a lawyer; your responses are educational and not legal advice. Encourage contacting local counsel or domestic‑violence advocates. If the user indicates imminent danger, instruct them to call local emergency services immediately.

    Definitions (jurisdiction‑neutral):
    - Emotional/psychological abuse: threats, intimidation, humiliation, isolation, stalking, monitoring, financial control, coercion, repeated insults.
    - Physical abuse: hitting, slapping, choking/strangulation, restraint, use of weapons, blocking exits, property destruction.

    Evidence suggestions (if safe): keep a dated log, save messages/voicemails, preserve photos of injuries/damaged property, seek medical care; consider backing up to a secure location.

    Common legal options (names vary by jurisdiction): protective/restraining orders, emergency orders, no‑contact orders, custody/visitation adjustments, criminal complaints, victim services.

    Response style:
    - Be empathetic and concise.
    - First assess safety; suggest emergency help if needed.
    - If the user shares an image, consider whether it may depict injuries, damage, or evidence; describe what you can and cannot infer.
    - Offer next steps and resources; ask clarifying questions if needed.
    - Remind the user that laws vary and they should consult local professionals.
    """

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                // Scrollable chat list growing from the top
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(messages) { message in
                                ChatBubble(message: message)
                                    .padding(.horizontal, 18)
                            }

                            // Bottom spacer ensures bubbles never render within the bottom 20%/input region
                            Color.clear
                                .frame(height: max(geo.size.height * 0.20, geo.size.height * 0.15 + 100))
                                .id("bottom")
                        }
                        .padding(.top, 90)
                        .mask(
                            Rectangle()
                                .padding(.bottom, geo.size.height * 0.20)
                        )
                    }
                    .onChange(of: messages.count) { _ in
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

                // Input bar positioned about 15% from the bottom
                HStack(alignment: .center, spacing: 12) {
                    if let data = attachedImageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 28, height: 28)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Theme.tileStroke, lineWidth: 1)
                            )
                    }

                    TextField("Type a message…", text: $inputText)
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
                        .focused($inputFocused)

                    PhotosPicker(selection: $selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Theme.accent)
                            )
                    }

                    Button {
                        send()
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
                .padding(.bottom, geo.size.height * 0.15)
                .onChange(of: selectedPhotoItem) { item in
                    guard let item = item else {
                        attachedImageData = nil
                        return
                    }
                    Task {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            attachedImageData = data
                        }
                    }
                }
            }
        }
        .themedBackground()
        .navigationTitle("AI Support")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private func send() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        // Append user message (right side)
        messages.append(ChatMessage(role: .user, content: text, imageData: attachedImageData))

        // Clear input immediately
        inputText = ""
        attachedImageData = nil
        selectedPhotoItem = nil

        Task {
            do {
                let reply = try await chatService.reply(for: messages, systemPrompt: legalContext)
                await MainActor.run {
                    messages.append(ChatMessage(role: .assistant, content: reply))
                }
            } catch {
                await MainActor.run {
                    messages.append(ChatMessage(role: .assistant, content: "Sorry, I couldn't get a response right now."))
                }
            }
        }
    }
}

private struct ChatBubble: View {
    let message: ChatMessage
    var body: some View {
        HStack(spacing: 0) {
            if message.role == .assistant {
                bubble
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.72, alignment: .leading)
                Spacer(minLength: 0)
            } else {
                Spacer(minLength: 0)
                bubble
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.72, alignment: .trailing)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var bubble: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(message.content)
                .font(.system(size: 15))
                .foregroundStyle(Theme.text)

            if let data = message.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(message.role == .assistant ? Theme.tileFill : Theme.accent)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Theme.tileStroke, lineWidth: 1)
                )
                .shadow(color: Theme.tileShadow, radius: 6, x: 0, y: 2)
        )
    }
}

