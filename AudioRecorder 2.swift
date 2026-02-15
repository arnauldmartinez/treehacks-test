import Foundation
import Combine
import AVFoundation

@MainActor
final class AudioRecorder: NSObject, ObservableObject, AVAudioRecorderDelegate {
    @Published private(set) var isRecording: Bool = false

    private var recorder: AVAudioRecorder?
    private var tempURL: URL?

    func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    func start() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
        try session.setActive(true)

        let tempDir = URL(fileURLWithPath: NSTemporaryDirectory())
        let url = tempDir.appendingPathComponent("rec_\(UUID().uuidString).m4a")
        self.tempURL = url

        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        let recorder = try AVAudioRecorder(url: url, settings: settings)
        recorder.delegate = self
        recorder.prepareToRecord()
        recorder.record()
        self.recorder = recorder
        self.isRecording = true
    }

    func stop() -> Data? {
        guard let recorder = recorder else { return nil }
        recorder.stop()
        self.isRecording = false
        self.recorder = nil
        guard let url = tempURL else { return nil }
        let data = try? Data(contentsOf: url)
        try? FileManager.default.removeItem(at: url)
        self.tempURL = nil
        return data
    }
}

