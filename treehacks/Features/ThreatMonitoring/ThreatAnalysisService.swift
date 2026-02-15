import Foundation

protocol ThreatAnalysisService {
    func analyze(transcript: String) async throws -> ThreatAssessment
}
