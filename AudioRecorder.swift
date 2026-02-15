import Foundation
import AVFoundation

class LegacyAudioRecorderHelper: NSObject, AVAudioRecorderDelegate {
    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?
    private(set) var recordedData: Data?

    func startRecording() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
        try session.setActive(true)

        let tempDir = FileManager.default.temporaryDirectory
        let fileName = UUID().uuidString + ".m4a"
        recordingURL = tempDir.appendingPathComponent(fileName)

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        guard let recordingURL = recordingURL else { return }

        audioRecorder = try AVAudioRecorder(url: recordingURL, settings: settings)
        audioRecorder?.delegate = self
        audioRecorder?.record()
    }

    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil

        guard let recordingURL = recordingURL else { return }
        recordedData = try? Data(contentsOf: recordingURL)

        try? AVAudioSession.sharedInstance().setActive(false)
    }
}
