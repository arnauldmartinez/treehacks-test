import Foundation
import AVFoundation

/// Stores the most recent N seconds of audio as copied PCM buffers.
/// Thread-safety: callers should call from a single queue (ThreatMonitor uses a serial queue).
final class AudioRingBuffer {
    private var buffers: [AVAudioPCMBuffer] = []
    private var totalFrames: AVAudioFrameCount = 0

    private let maxFrames: AVAudioFrameCount
    private let format: AVAudioFormat

    init(seconds: Double, format: AVAudioFormat) {
        self.format = format
        let frames = seconds * format.sampleRate
        self.maxFrames = AVAudioFrameCount(max(1, frames.rounded(.down)))
    }

    func appendCopy(of buffer: AVAudioPCMBuffer) {
        guard buffer.frameLength > 0 else { return }
        let copied = buffer.deepCopy()
        buffers.append(copied)
        totalFrames += copied.frameLength
        trimIfNeeded()
    }

    func snapshot() -> [AVAudioPCMBuffer] {
        buffers
    }

    func reset() {
        buffers.removeAll()
        totalFrames = 0
    }

    private func trimIfNeeded() {
        while totalFrames > maxFrames, let first = buffers.first {
            totalFrames -= first.frameLength
            buffers.removeFirst()
        }
    }
}

private extension AVAudioPCMBuffer {
    /// Deep-copies the audio samples so the ring buffer isn't holding references to reused memory.
    func deepCopy() -> AVAudioPCMBuffer {
        let copy = AVAudioPCMBuffer(pcmFormat: self.format, frameCapacity: self.frameCapacity)!
        copy.frameLength = self.frameLength

        if let src = self.floatChannelData, let dst = copy.floatChannelData {
            let channels = Int(self.format.channelCount)
            let frames = Int(self.frameLength)
            for ch in 0..<channels {
                memcpy(dst[ch], src[ch], frames * MemoryLayout<Float>.size)
            }
        } else if let src = self.int16ChannelData, let dst = copy.int16ChannelData {
            let channels = Int(self.format.channelCount)
            let frames = Int(self.frameLength)
            for ch in 0..<channels {
                memcpy(dst[ch], src[ch], frames * MemoryLayout<Int16>.size)
            }
        } else {
            // For formats not covered above, do a fallback: write via AVAudioFile later (not needed for this MVP).
            // Most iOS mic formats delivered to taps are float.
        }

        return copy
    }
}
