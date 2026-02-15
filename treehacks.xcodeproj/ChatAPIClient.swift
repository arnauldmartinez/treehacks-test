import Foundation

struct APIChatMessage: Codable {
    let id: String
    let sender: String // "user" | "reviewer"
    let text: String
    let timestamp: String
}

struct WSChatEnvelope: Codable {
    let type: String
    let user_id: String
    let message: APIChatMessage
}

final class ChatAPIClient {
    private let restBase = URL(string: "http://10.19.176.173:8000")!
    private let wsURL = URL(string: "ws://10.19.176.173:8000/ws")!
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    // MARK: - REST

    func fetchHistory(userId: String) async throws -> [APIChatMessage] {
        let url = restBase.appending(path: "/users/\(userId)/chat")
        let (data, _) = try await session.data(from: url)
        let decoder = JSONDecoder()
        return try decoder.decode([APIChatMessage].self, from: data)
    }

    func send(userId: String, text: String) async throws {
        let url = restBase.appending(path: "/users/\(userId)/chat")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let payload: [String: Any] = [
            "text": text
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: payload)
        _ = try await session.data(for: req)
    }

    // MARK: - WebSocket

    func makeWebSocketTask() -> URLSessionWebSocketTask {
        session.webSocketTask(with: wsURL)
    }
}
