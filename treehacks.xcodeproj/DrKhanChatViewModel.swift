import Foundation
import Combine

@MainActor
final class DrKhanChatViewModel: ObservableObject {
    @Published private(set) var messages: [ChatsMessage] = []
    @Published var draft: String = ""
    @Published private(set) var isConnected: Bool = false

    private let api = ChatAPIClient()
    private var socket: URLSessionWebSocketTask?
    private var receiveLoopTask: Task<Void, Never>?

    let userId = "1"

    func onAppear() {
        Task { await loadHistory() }
        connectWebSocket()
    }

    func onDisappear() {
        disconnectWebSocket()
    }

    private func loadHistory() async {
        do {
            let history = try await api.fetchHistory(userId: userId)
            messages = history.map { apiMsg in
                ChatsMessage(role: apiMsg.sender == "user" ? .user : .assistant, content: apiMsg.text)
            }
        } catch {
            print("Failed to load history:", error)
        }
    }

    func send() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        // Optimistic append
        messages.append(ChatsMessage(role: .user, content: text))
        draft = ""

        Task {
            do { try await api.send(userId: userId, text: text) }
            catch { print("Send failed:", error) }
        }
    }

    // MARK: - WebSocket

    private func connectWebSocket() {
        let task = api.makeWebSocketTask()
        socket = task
        task.resume()
        isConnected = true

        receiveLoopTask = Task { [weak self] in
            guard let self else { return }
            await self.receiveLoop()
        }
    }

    private func disconnectWebSocket() {
        receiveLoopTask?.cancel()
        receiveLoopTask = nil
        socket?.cancel(with: .goingAway, reason: nil)
        socket = nil
        isConnected = false
    }

    private func receiveLoop() async {
        guard let socket else { return }
        while !Task.isCancelled {
            do {
                let message = try await socket.receive()
                switch message {
                case .string(let str):
                    if let data = str.data(using: .utf8) {
                        handleIncoming(data: data)
                    }
                case .data(let data):
                    handleIncoming(data: data)
                @unknown default:
                    break
                }
            } catch {
                print("WS receive error:", error)
                break
            }
        }
    }

    private func handleIncoming(data: Data) {
        do {
            let envelope = try JSONDecoder().decode(WSChatEnvelope.self, from: data)
            guard envelope.type == "chat", envelope.user_id == userId else { return }
            let apiMsg = envelope.message
            let role: ChatsMessage.Role = apiMsg.sender == "user" ? .user : .assistant
            messages.append(ChatsMessage(role: role, content: apiMsg.text))
        } catch {
            print("WS parse error:", error)
        }
    }
}
