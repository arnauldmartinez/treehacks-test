import Foundation

final class OpenAIThreatAnalyzer: ThreatAnalysisService {

    func analyze(transcript: String) async throws -> ThreatAssessment {

        let prompt = """
        You are a safety classification system.

        Classify the following transcript into one of:

        - no_concern
        - verbal_abuse
        - imminent_threat

        imminent_threat means credible threat of physical harm.

        Return STRICT JSON ONLY in this format:

        {
          "classification": "no_concern | verbal_abuse | imminent_threat",
          "confidence": 0.0-1.0,
          "policeLevel": 0-10,
          "evidenceSpans": ["quoted phrase"]
        }

        Transcript:
        \(transcript)
        """

        let body: [String: Any] = [
            "model": "gpt-4.1-mini",
            "messages": [
                ["role": "system", "content": "You are a strict JSON classifier."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.0
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
            let message = choices.first?["message"] as? [String: Any],
            let content = message["content"] as? String,
            let jsonData = content.data(using: .utf8)
        else {
            throw NSError(domain: "OpenAI", code: 1)
        }

        let decoder = JSONDecoder()
        return try decoder.decode(ThreatAssessment.self, from: jsonData)
    }
}
