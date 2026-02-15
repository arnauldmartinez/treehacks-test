import Foundation
import SwiftUI
import Combine

@MainActor
final class ChatsViewModel: ObservableObject {
    @Published private(set) var conversations: [UUID: [ChatsMessage]] = [:] {
        didSet { save() }
    }

    private let storageKey = "chats_conversations_v1"

    init() {
        load()
    }

    func messages(for expertID: UUID) -> [ChatsMessage] {
        conversations[expertID] ?? []
    }

    func count(for expertID: UUID) -> Int {
        conversations[expertID]?.count ?? 0
    }

    func appendUser(text: String, to expertID: UUID) {
        let m = ChatsMessage(role: .user, content: text)
        var arr = conversations[expertID] ?? []
        arr.append(m)
        conversations[expertID] = arr
    }

    // MARK: - Persistence

    private func save() {
        do {
            let data = try JSONEncoder().encode(conversations)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Failed to save chats:", error)
        }
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([UUID: [ChatsMessage]].self, from: data)
        else {
            conversations = [:]
            return
        }
        conversations = decoded
    }
}

// MARK: - ChatsMessage Model (shared)

struct ChatsMessage: Identifiable, Codable, Hashable {
    enum Role: String, Codable {
        case user
        case assistant
        case system
    }

    let id: UUID
    let role: Role
    let content: String
    let createdAt: Date

    init(id: UUID = UUID(), role: Role, content: String, createdAt: Date = Date()) {
        self.id = id
        self.role = role
        self.content = content
        self.createdAt = createdAt
    }
}

