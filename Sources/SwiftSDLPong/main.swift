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
let textRenderer = TextRenderer(
    fontPath: "Assets/Fonts/PressStart2P-Regular.ttf",
    pointSize: 16
)

var isRunning = true
var event = SDL_Event()
var frameTimer = FrameTimer(targetFPS: configuration.targetFPS)

while isRunning {
    let currentFrameTime = SDL_GetTicks()
    let deltaTime = frameTimer.beginFrame()

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

            case SDL_SCANCODE_T:
                game.toggleGameMode()

            case SDL_SCANCODE_ESCAPE:
                isRunning = false

            case SDL_SCANCODE_1:
                game.setAIDifficulty(.easy)

            case SDL_SCANCODE_2:
                game.setAIDifficulty(.normal)

            case SDL_SCANCODE_3:
                game.setAIDifficulty(.hard)
            
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

    renderGame(renderer: renderer, game: &game, textRenderer: textRenderer)

    let frameDuration = SDL_GetTicks() - currentFrameTime
    let targetFrameDuration = UInt64(1000 / configuration.targetFPS)

    if frameDuration < targetFrameDuration {
        let delay = targetFrameDuration - frameDuration
        SDL_Delay(UInt32(delay))
    }

    if let fps = frameTimer.endFrame() {
        let title = "Swift SDL Pong - \(fps) FPS"
        title.withCString { cTitle in
            SDL_SetWindowTitle(window, cTitle)
        }
    }
}