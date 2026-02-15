import Foundation

struct Incident: Identifiable, Codable, Equatable {
    let id: UUID
    let createdAt: Date
    let transcript: String
    let audioFilePath: String
    let peakRisk: Double

    init(id: UUID = UUID(),
         createdAt: Date = Date(),
         transcript: String,
         audioFilePath: String,
         peakRisk: Double) {
        self.id = id
        self.createdAt = createdAt
        self.transcript = transcript
        self.audioFilePath = audioFilePath
        self.peakRisk = peakRisk
    }
}
