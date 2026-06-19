import CSDL3

struct FrameTimer {
    private let targetFPS: Uint32

    private var lastFrameTime: UInt64
    private var currentFrameTime: UInt64

    private var fpsTimer: UInt64
    private var frameCount: Uint32 = 0

    init(targetFPS: UInt32) {
        self.targetFPS = targetFPS

        let now = SDL_GetTicks()
        self.lastFrameTime = now
        self.currentFrameTime = now
        self.fpsTimer = now
    }

    mutating func beginFrame() -> Float {
        currentFrameTime = SDL_GetTicks()

        let deltaTime = Float(currentFrameTime - lastFrameTime) / 1000.0
        lastFrameTime = currentFrameTime

        return deltaTime
    }

    mutating func endFrame() -> UInt32?{
        capFrameRate()
        return updateFPSCounter()
    }

    private func capFrameRate() {
        let frameDuration = SDL_GetTicks() - currentFrameTime
        let targetFrameDuration = UInt64(1000 / targetFPS)

        if frameDuration < targetFrameDuration {
            let delay = targetFrameDuration - frameDuration
            SDL_Delay(UInt32(delay))
        }        
    }

    private mutating func updateFPSCounter() -> Uint32? {
        frameCount += 1

        let elapsedTime = SDL_GetTicks() - fpsTimer

        if elapsedTime >= 1000 {
            let fps = frameCount

            frameCount = 0
            fpsTimer = SDL_GetTicks()

            return fps
        }
        
        return nil
    }
}