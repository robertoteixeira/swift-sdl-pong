import Darwin
import CSDL3

let configuration = GameConfiguration()

guard SDL_Init(SDL_INIT_VIDEO) else {
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

var isRunning = true
var event = SDL_Event()
var lastFrameTime = SDL_GetTicks()

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

            case SDL_SCANCODE_ESCAPE:
                isRunning = false

            default:
                break
            }
        }
    }

    let keyboardState = SDL_GetKeyboardState(nil)
    game.update(deltaTime: deltaTime, keyboardState: keyboardState)

    SDL_SetRenderDrawColor(renderer, 20, 20, 20, 255)
    SDL_RenderClear(renderer)

    SDL_SetRenderDrawColor(renderer, 240, 240, 240, 255)

    renderCenterLine(
        renderer: renderer,
        screenWidth: game.screenWidth,
        screenHeight: game.screenHeight
    )

    renderScore(
        renderer: renderer,
        screenWidth: game.screenWidth,
        leftScore: game.leftScore,
        rightScore: game.rightScore
    )

    renderGame(renderer: renderer, game: &game)
}