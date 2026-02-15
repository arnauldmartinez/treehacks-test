import Foundation

final class OpenAIChatService {
    struct APIError: Error {}

    func reply(for messages: [ChatMessage], systemPrompt: String = "You are a helpful legal assistant.") async throws -> String {
        // Build OpenAI messages array from our chat history
        var openAIMessages: [[String: Any]] = [[
            "role": "system",
            "content": systemPrompt
        ]]

        for m in messages { // preserve order
            var contentParts: [[String: Any]] = []
            // Always include the text part (even if empty)
            if !m.content.isEmpty {
                contentParts.append([
                    "type": "text",
                    "text": m.content
                ])
            }
            // If there is an image, include it as an image_url part
            if let data = m.imageData, let base64 = data.base64EncodedString(options: .endLineWithLineFeed) as String? {
                let dataURL = "data:image/png;base64,\(base64)"
                contentParts.append([
                    "type": "image_url",
                    "image_url": ["url": dataURL]
                ])
            }

            // Fallback for content-only role if no parts (shouldn't happen)
            if contentParts.isEmpty {
                contentParts.append(["type": "text", "text": ""]) 
            }

            openAIMessages.append([
                "role": m.role.rawValue,
                "content": contentParts
            ])
        }

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": openAIMessages,
            "temperature": 0.2
        ]

        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(Secrets.openAIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)

        guard
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let choices = json["choices"] as? [[String: Any]],
            let message = choices.first?["message"] as? [String: Any]
        else {
            throw APIError()
        }

        // The response may be either a simple string or an array of content parts
        if let content = message["content"] as? String {
            return content
        } else if let parts = message["content"] as? [[String: Any]] {
            // Concatenate text parts
            let texts: [String] = parts.compactMap { part in
                if let type = part["type"] as? String, type == "text" {
                    return part["text"] as? String
                }
                return nil
            }
            return texts.joined(separator: "\n")
        } else {
            throw APIError()
        }
    }
}
