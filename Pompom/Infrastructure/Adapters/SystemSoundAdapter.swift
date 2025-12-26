import Foundation
import AppKit
import AVFoundation

final class SystemSoundAdapter: SoundPort {
    private var tickPlayer: AVAudioPlayer?
    private var ambientPlayer: AVAudioPlayer?
    
    func playSessionComplete() {
        NSSound(named: "Glass")?.play()
        playSuccessHaptic()
    }
    
    func playBreakComplete() {
        NSSound(named: "Ping")?.play()
        playSuccessHaptic()
    }
    
    func playTick() {
        NSSound(named: "Tink")?.play()
    }
    
    func playStartSound() {
        NSSound(named: "Pop")?.play()
    }
    
    func playPauseSound() {
        NSSound(named: "Blow")?.play()
    }
    
    func playSkipSound() {
        NSSound(named: "Morse")?.play()
    }
    
    func playGoalAchievedSound() {
        DispatchQueue.main.async {
            NSSound(named: "Fanfare")?.play()
        }
        playSuccessHaptic()
    }
    
    func playButtonClick() {
        NSSound(named: "Pop")?.play()
    }
    
    private func playSuccessHaptic() {
        NSHapticFeedbackManager.defaultPerformer.perform(
            .levelChange,
            performanceTime: .default
        )
    }
}

extension SoundPort {
    func playStartSound() {}
    func playPauseSound() {}
    func playSkipSound() {}
    func playGoalAchievedSound() {}
    func playButtonClick() {}
}
