import Foundation
import AVFoundation
import Vision
import Combine

@MainActor
final class FacePresenceMonitor: NSObject, ObservableObject {
    @Published private(set) var facePresent: Bool = true

    private let session = AVCaptureSession()
    private let output = AVCaptureVideoDataOutput()
    private let videoQueue = DispatchQueue(label: "face.presence.video.queue")

    private var lastFaceTime: Date = .distantPast
    private var watchdogTimer: Timer?

    func start() {
        // Request camera access, then configure and start
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            guard let self = self else { return }
            DispatchQueue.main.async {
                guard granted else {
                    // If no permission, treat as not present so caller can decide what to do
                    self.facePresent = false
                    return
                }
                self.configureSessionIfNeeded()
                if !self.session.isRunning {
                    self.videoQueue.async { self.session.startRunning() }
                }
                self.startWatchdog()
            }
        }
    }

    func stop() {
        watchdogTimer?.invalidate()
        watchdogTimer = nil
        if session.isRunning {
            videoQueue.async { [weak self] in self?.session.stopRunning() }
        }
    }

    private func configureSessionIfNeeded() {
        guard session.inputs.isEmpty else { return }
        session.beginConfiguration()
        session.sessionPreset = .medium

        // Front camera
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            session.commitConfiguration()
            return
        }
        session.addInput(input)

        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(self, queue: videoQueue)
        if session.canAddOutput(output) { session.addOutput(output) }

        session.commitConfiguration()
    }

    private func startWatchdog() {
        watchdogTimer?.invalidate()
        lastFaceTime = Date() // assume present at start to avoid immediate lock
        watchdogTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let elapsed = Date().timeIntervalSince(self.lastFaceTime)
            let present = elapsed < 2.0 // 2s grace period
            if present != self.facePresent {
                self.facePresent = present
            }
        }
    }
}

extension FacePresenceMonitor: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let request = VNDetectFaceRectanglesRequest { [weak self] req, _ in
            guard let self = self else { return }
            let faces = (req.results as? [VNFaceObservation]) ?? []
            if !faces.isEmpty {
                // Update last seen time on any face
                self.lastFaceTime = Date()
            }
        }
        // Front camera in portrait is typically leftMirrored
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .leftMirrored)
        try? handler.perform([request])
    }
}
