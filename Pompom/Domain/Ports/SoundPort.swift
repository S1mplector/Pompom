import Foundation

protocol SoundPort {
    func playSessionComplete()
    func playBreakComplete()
    func playTick()
}
