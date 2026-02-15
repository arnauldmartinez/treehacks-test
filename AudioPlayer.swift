import Foundation
import AVFoundation
import Combine

@MainActor
final class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published private(set) var isPlaying: Bool = false
    @Published private(set) var currentID: String?

    private var player: AVAudioPlayer?

    func play(url: URL, id: String) {
        if currentID == id && isPlaying {
            stop()
            return
        }
        stop()
        do {
            let p = try AVAudioPlayer(contentsOf: url)
            p.delegate = self
            p.prepareToPlay()
            p.play()
            self.player = p
            self.isPlaying = true
            self.currentID = id
        } catch {
            print("AudioPlayer failed to play url:", error)
        }
    }

    func play(data: Data, id: String) {
        if currentID == id && isPlaying {
            stop()
            return
        }
        stop()
        do {
            let p = try AVAudioPlayer(data: data)
            p.delegate = self
            p.prepareToPlay()
            p.play()
            self.player = p
            self.isPlaying = true
            self.currentID = id
        } catch {
            print("AudioPlayer failed to play data:", error)
        }
    }

    func stop() {
        player?.stop()
        player = nil
        isPlaying = false
        currentID = nil
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        currentID = nil
        self.player = nil
    }
}
