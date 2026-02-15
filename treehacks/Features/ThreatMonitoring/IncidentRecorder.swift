import Foundation
import AVFoundation

final class IncidentRecorder {

    private var file: AVAudioFile?
    private(set) var url: URL?

    func start(format: AVAudioFormat) {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let dir = base.appendingPathComponent("Treehacks/Incidents", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

        let newURL = dir.appendingPathComponent("incident_\(Int(Date().timeIntervalSince1970)).caf")
        url = newURL
        file = try? AVAudioFile(forWriting: newURL, settings: format.settings)
    }

    func append(_ buffer: AVAudioPCMBuffer) {
        try? file?.write(from: buffer)
    }

    func stop() {
        file = nil
    }
}
