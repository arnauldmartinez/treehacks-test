import Foundation

final class RiskModel {
    private(set) var currentRisk: Double = 0
    private(set) var peakRisk: Double = 0

    private let decay = 0.88
    let incidentThreshold = 6.0
    let emergencyThreshold = 14.0

    func update(threatScore: Double) -> (risk: Double, save: Bool, emergency: Bool) {
        currentRisk = decay * currentRisk + threatScore
        peakRisk = max(peakRisk, currentRisk)
        return (currentRisk,
                peakRisk >= incidentThreshold,
                peakRisk >= emergencyThreshold)
    }

    func reset() {
        currentRisk = 0
        peakRisk = 0
    }
}
