import Foundation
import AVFoundation
import Speech
import Combine

final class ThreatMonitor: NSObject, ObservableObject {

    enum MonitoringStage: String {
        case amplitudeMonitoring = "Monitoring RMS"
        case escalationActive = "Escalation Active"
        case savingIncident = "Saving Incident"
    }

    // MARK: Audio + Speech

    private let audioEngine = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer()

    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    // MARK: Services

    private let amplitudeGate = AmplitudeGate()
    private let recorder = IncidentRecorder()
    private let analyzer: ThreatAnalysisService = OpenAIThreatAnalyzer()

    // MARK: Timers

    private var silenceTimer: DispatchSourceTimer?
    private let silenceTimeout: Double = 4.0

    private var transcriptBuffer: String = ""
    private var lastLLMCheckTime: Date = .distantPast

    // MARK: Episode Flags

    private var episodeContainsAbuse = false
    private var episodeContainsThreat = false
    private var hasSentThreatToServer = false

    // MARK: UI State

    @Published var isMonitoring: Bool = true
    @Published var stage: MonitoringStage = .amplitudeMonitoring
    @Published var currentRMS: Float = 0
    @Published var transcriptLive: String = ""
    @Published var lastIncidentFileName: String = ""

    // 🔥 NEW: transient decision display
    @Published var lastDecisionMessage: String? = nil

    override init() {
        super.init()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.startMonitoring()
        }
    }

    func toggleMonitoring(_ enabled: Bool) {
        enabled ? startMonitoring() : stopMonitoring()
    }

    private func startMonitoring() {
        guard !audioEngine.isRunning else { return }
        requestPermissions()
    }

    private func requestPermissions() {
        SFSpeechRecognizer.requestAuthorization { status in
            guard status == .authorized else { return }

            DispatchQueue.main.async {
                self.setupAudioSession()
                self.startAudioEngine()
            }
        }
    }

    private func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord,
                                 mode: .default,
                                 options: [.mixWithOthers])
        try? session.setActive(true)
    }

    private func startAudioEngine() {

        let inputNode = audioEngine.inputNode
        inputNode.removeTap(onBus: 0)

        let format = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0,
                             bufferSize: 1024,
                             format: format) { buffer, _ in

            let triggered = self.amplitudeGate.process(buffer: buffer)

            DispatchQueue.main.async {
                self.currentRMS = self.amplitudeGate.lastRMS
            }

            if self.stage == .amplitudeMonitoring && triggered {
                DispatchQueue.main.async {
                    self.startEscalation(format: format)
                }
            }

            if self.stage == .escalationActive {
                self.recognitionRequest?.append(buffer)
                self.recorder.append(buffer)
            }
        }

        audioEngine.prepare()
        try? audioEngine.start()
    }

    private func startEscalation(format: AVAudioFormat) {

        stage = .escalationActive

        transcriptBuffer = ""
        transcriptLive = ""

        episodeContainsAbuse = false
        episodeContainsThreat = false
        hasSentThreatToServer = false

        recorder.start(format: format)

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest!) { result, _ in

            if let result = result {

                let text = result.bestTranscription.formattedString

                self.transcriptLive = text
                self.transcriptBuffer = text

                self.evaluateWithLLMIfNeeded(text: text)
            }
        }

        resetSilenceTimer()
    }

    private func evaluateWithLLMIfNeeded(text: String) {

        let now = Date()
        guard now.timeIntervalSince(lastLLMCheckTime) > 2.0 else { return }
        lastLLMCheckTime = now

        Task {
            do {
                let assessment = try await analyzer.analyze(transcript: text)

                DispatchQueue.main.async {
                    self.handleAssessment(assessment)
                }

            } catch {
                print("LLM error:", error)
            }
        }
    }

    private func handleAssessment(_ assessment: ThreatAssessment) {

        switch assessment.classification {

        case .noConcern:
            showDecision("No Threat Detected")
            break

        case .verbalAbuse:
            episodeContainsAbuse = true
            showDecision("Verbal Abuse — Will Save")
            
        case .imminentThreat:
            episodeContainsAbuse = true
            episodeContainsThreat = true

            showDecision("🚨 IMMINENT THREAT — Escalated")

            if !hasSentThreatToServer {
                hasSentThreatToServer = true
                sendToServerNow(transcript: transcriptBuffer)
            }
        }

        resetSilenceTimer()
    }

    private func showDecision(_ message: String) {

        lastDecisionMessage = message

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.lastDecisionMessage = nil
        }
    }

    private func sendToServerNow(transcript: String) {

        guard let url = URL(string: "http://10.19.178.83:8000/report") else { return }

        let payload: [String: Any] = [
            "transcript": transcript,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request).resume()

        print("🚨 Threat sent to server")
    }

    private func resetSilenceTimer() {

        silenceTimer?.cancel()

        let timer = DispatchSource.makeTimerSource(queue: .global())
        timer.schedule(deadline: .now() + silenceTimeout)

        timer.setEventHandler { [weak self] in
            DispatchQueue.main.async {
                self?.endEscalation()
            }
        }

        timer.resume()
        silenceTimer = timer
    }

    private func endEscalation() {

        guard stage == .escalationActive else { return }

        silenceTimer?.cancel()
        silenceTimer = nil

        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recorder.stop()

        if episodeContainsAbuse {

            if let url = recorder.url {
                lastIncidentFileName = url.lastPathComponent
                print("Saved incident: \(url)")
            }

        } else {

            if let url = recorder.url {
                try? FileManager.default.removeItem(at: url)
                print("Discarded non-threat recording")
            }
        }

        stage = .amplitudeMonitoring
    }

    private func stopMonitoring() {

        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)

        recognitionTask?.cancel()
        silenceTimer?.cancel()

        stage = .amplitudeMonitoring
    }
}
