import CSDL3
import Darwin

final class AudioPlayer {
    private let stream: OpaquePointer?

    private let sampleRate: Int32 = 48_000
    private let channels: Int32 = 1

    init?() {
        var spec = SDL_AudioSpec()
        spec.format = SDL_AUDIO_F32
        spec.channels = channels
        spec.freq = sampleRate

        stream = SDL_OpenAudioDeviceStream(
            SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK,
            &spec,
            nil, 
            nil
        )

        guard let stream else {
            let error = String(cString: SDL_GetError())
            print("SDL_OpenAudioDeviceStream failed: \(error)")
            return nil
        }

        SDL_ResumeAudioStreamDevice(stream)
    }

    deinit {
        if let stream{
            SDL_DestroyAudioStream(stream)
        }
    }

    func playPaddleHit() {
        playBeep(frequency: 720, duration: 0.06, volume: 0.25)
    }

    func playWallHit() {
        playBeep(frequency: 460, duration: 0.05, volume: 0.20)
    }

    func playScore() {
        playBeep(frequency: 220, duration: 0.14, volume: 0.30)
    }

    private func playBeep(frequency: Float, duration: Float, volume: Float) {
        guard let stream else { return }

        let sampleCount = Int(Float(sampleRate) * duration)
        let twoPi = Float.pi * 2

        var samples = [Float]()
        samples.reserveCapacity(sampleCount)

        for index in 0..<sampleCount {
            let time = Float(index) / Float(sampleRate)
            let rawSample = sin(twoPi * frequency * time)

            // Small fade-out to aovid harsh clicks when the beep ends.
            let progress = Float(index) / Float(sampleCount)
            let fadeOut = 1.0 - progress

            samples.append(rawSample * volume * fadeOut)
        }

        samples.withUnsafeBytes { buffer in
            guard let baseAddress = buffer.baseAddress else {
                return
            }

            SDL_PutAudioStreamData(
                stream, 
                baseAddress, 
                Int32(buffer.count)
            )
        }
    }

}