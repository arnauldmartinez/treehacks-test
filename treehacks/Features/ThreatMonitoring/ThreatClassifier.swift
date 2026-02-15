import Foundation

struct ThreatSignals {
    let threatScore: Double
    let veryHigh: Bool
}

final class ThreatClassifier {

    private let highThreat = [
        ("i will kill", 8.0),
        ("kill you", 7.0),
        ("strangle", 8.0),
        ("choke", 7.0),
        ("knife", 6.0),
        ("gun", 6.0),
        ("hurt you", 6.0)
    ]

    func evaluate(text: String) -> ThreatSignals {
        let lower = text.lowercased()
        var score = 0.0

        for (k, w) in highThreat where lower.contains(k) {
            score += w
        }

        let veryHigh = score >= 14
        return ThreatSignals(threatScore: score, veryHigh: veryHigh)
    }
}
