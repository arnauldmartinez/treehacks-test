import Foundation
import AVFoundation

final class AmplitudeGate {
    
    // Slightly stricter threshold
    private let rmsThreshold: Float = 0.06
    
    // Require more consecutive loud frames
    private let triggerFramesRequired: Int = 8
    
    private var aboveThresholdCount: Int = 0
    
    private(set) var lastRMS: Float = 0
    
    func process(buffer: AVAudioPCMBuffer) -> Bool {
        guard let channelData = buffer.floatChannelData else { return false }
        
        let channel = channelData[0]
        let frameLength = Int(buffer.frameLength)
        
        var sum: Float = 0
        for i in 0..<frameLength {
            let sample = channel[i]
            sum += sample * sample
        }
        
        let rms = sqrt(sum / Float(frameLength))
        lastRMS = rms
        
        if rms > rmsThreshold {
            aboveThresholdCount += 1
        } else {
            aboveThresholdCount = max(0, aboveThresholdCount - 1)
        }
        
        if aboveThresholdCount >= triggerFramesRequired {
            aboveThresholdCount = 0
            return true
        }
        
        return false
    }
}
