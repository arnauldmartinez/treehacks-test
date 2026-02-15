import Foundation
import Combine

enum ChatRole: String, Codable { case user, assistant }

struct ChatMessage: Identifiable, Codable, Hashable {
    let id: UUID
    let role: ChatRole
    let content: String
    let createdAt: Date
    let imageData: Data?

    init(id: UUID = UUID(), role: ChatRole, content: String, createdAt: Date = Date(), imageData: Data? = nil) {
        self.id = id
        self.role = role
        self.content = content
        self.createdAt = createdAt
        self.imageData = imageData
    }
}

@MainActor
final class AISupportViewModel: ObservableObject {
    @Published private(set) var messages: [ChatMessage] = []

    func startNewChat() {
        messages = []
        // Optional: seed system prompt or intro message
        messages.append(ChatMessage(role: .assistant, content: "Hi! I'm your AI legal assistant. How can I help today?"))
    }

    func sendUser(text: String) {
        messages.append(ChatMessage(role: .user, content: text))

        // Stub a delayed assistant response for now
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 400_000_000)
            let reply = ChatMessage(role: .assistant, content: "Thanks for your question. I'll review your secure documents context and get back with legal guidance.")
            messages.append(reply)
        }
    }
}

