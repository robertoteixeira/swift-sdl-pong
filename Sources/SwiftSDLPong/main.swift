import Darwin
import CSDL3

let configuration = GameConfiguration()

guard SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO) else {
    let error = String(cString: SDL_GetError())
    print("SDL_Init failed: \(error)")
    exit(1)
}

defer {
    SDL_Quit()
}

let window = SDL_CreateWindow(
    "Swift SDL Pong",
    configuration.screenWidth,
    configuration.screenHeight,
    0
)

guard let window else {
    let error = String(cString: SDL_GetError())
    print("SDL_CreateWindow failed: \(error)")
    exit(1)
}

defer {
    SDL_DestroyWindow(window)
}

let renderer = SDL_CreateRenderer(window, nil)

guard let renderer else {
    let error = String(cString: SDL_GetError())
    print("SDL_CreateRenderer failed: \(error)")
    exit(1)
}

defer {
    SDL_DestroyRenderer(renderer)
}

var game = Game(configuration: configuration)
let audioPlayer = AudioPlayer()

var isRunning = true
var event = SDL_Event()
var lastFrameTime = SDL_GetTicks()
var fpsTimer = SDL_GetTicks()
var frameCount: UInt32 = 0

while isRunning {
    let currentFrameTime = SDL_GetTicks()
    let deltaTime = Float(currentFrameTime - lastFrameTime) / 1000.0
    lastFrameTime = currentFrameTime

    while SDL_PollEvent(&event) {
        if event.type == SDL_EVENT_QUIT.rawValue {
            isRunning = false
        }

        if event.type == SDL_EVENT_KEY_DOWN.rawValue {
            switch event.key.scancode {
            case SDL_SCANCODE_SPACE:
                game.start()

            case SDL_SCANCODE_P:
                game.togglePause()

            case SDL_SCANCODE_R:
                if game.state == .gameOver {
                    game.restart()
                }

            case SDL_SCANCODE_M:
                audioPlayer?.toggleMute()

            case SDL_SCANCODE_ESCAPE:
                isRunning = false

            default:
                break
            }
        }
    }

    let keyboardState = SDL_GetKeyboardState(nil)
    let events = game.update(deltaTime: deltaTime, keyboardState: keyboardState)

    for event in events {
        switch event {
            case .wallHit:
                audioPlayer?.playWallHit()
            case .paddleHit:
                audioPlayer?.playPaddleHit()
            case .score:
                audioPlayer?.playScore()
        }
    }

    renderGame(renderer: renderer, game: &game)

    let frameDuration = SDL_GetTicks() - currentFrameTime
    let targetFrameDuration = UInt64(1000 / configuration.targetFPS)

    if frameDuration < targetFrameDuration {
        let delay = targetFrameDuration - frameDuration
        SDL_Delay(UInt32(delay))
    }

    frameCount += 1
    let fpsElapsedTime = SDL_GetTicks() - fpsTimer

    if fpsElapsedTime >= 1000 {
        SDL_SetWindowTitle(window, "Swift SDL Pong - \(frameCount) FPS")
        frameCount = 0
        fpsTimer = SDL_GetTicks()
    }
}