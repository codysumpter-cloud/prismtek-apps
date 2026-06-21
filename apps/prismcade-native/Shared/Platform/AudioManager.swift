import AVFoundation

/// Background-music manager: one looping track at a time, mute-friendly, and safe if a file is
/// missing (never crashes, just plays nothing). Event SFX stay on `SKAction.playSoundFileNamed`
/// in each scene; this only owns the looping BGM.
final class AudioManager {
    static let shared = AudioManager()

    private var bgm: AVAudioPlayer?
    private(set) var current: String?
    var muted = false {
        didSet { if muted { bgm?.pause() } else { bgm?.play() } }
    }

    private init() {
        #if os(iOS)
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
        #endif
    }

    /// Loop a bundled track. No-op if already playing it, muted, or the file is absent.
    func playBGM(_ name: String, ext: String = "m4a", volume: Float = 0.45) {
        guard !muted else { return }
        if current == name, bgm?.isPlaying == true { return }
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else { current = nil; return }
        bgm?.stop()
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            player.volume = volume
            player.prepareToPlay()
            player.play()
            bgm = player
            current = name
        } catch {
            current = nil
        }
    }

    func stopBGM() {
        bgm?.stop()
        bgm = nil
        current = nil
    }
}
