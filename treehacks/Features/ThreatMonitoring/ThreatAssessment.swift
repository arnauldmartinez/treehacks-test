import Foundation

enum ThreatLevel: String, Codable {
    case noConcern = "no_concern"
    case verbalAbuse = "verbal_abuse"
    case imminentThreat = "imminent_threat"
}

struct ThreatAssessment: Codable {
    let classification: ThreatLevel
    let confidence: Double
    let policeLevel: Int
    let evidenceSpans: [String]
}
