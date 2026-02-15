import Foundation
import AVFoundation

final class RMSGate {

    private var noiseFloor: Float = 0.01
    private let alpha: Float = 0.02

    private let startFactor: Float = 4.0
    private let speechFactor: Float = 1.8

    private(set) var lastRMS: Float = 0
    private(set) var startThreshold: Float = 0.05
    private(set) var speechThreshold: Float = 0.02

    func update(rms: Float) {
        lastRMS = rms
        if rms < noiseFloor * 2 {
            noiseFloor = (1 - alpha) * noiseFloor + alpha * rms
        }

        startThreshold = max(0.05, noiseFloor * startFactor)
        speechThreshold = max(0.02, noiseFloor * speechFactor)
    }

    func shouldStart() -> Bool {
        lastRMS >= startThreshold
    }

    func isSpeechLikely() -> Bool {
        lastRMS >= speechThreshold
    }
}
