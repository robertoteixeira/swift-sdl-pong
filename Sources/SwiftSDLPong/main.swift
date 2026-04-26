import Darwin
import CSDL3

let screenWidth: Int32 = 800
let screenHeight: Int32 = 600

guard SDL_Init(SDL_INIT_VIDEO) else {
    let error = String(cString: SDL_GetError())
    print("SDL_Init failed: \(error)")
    exit(1)
}

defer {
    SDL_Quit()
}

let window = SDL_CreateWindow(
    "Swfit SDL Pong",
    screenWidth,
    screenHeight,
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
    print("SDL_CreateRenderer \(error)")
    exit(1)
}

defer {
    SDL_DestroyRenderer(renderer)
}

let paddleWidth: Float = 15
let paddleHeight: Float = 100
let ballSize: Float = 15

var leftPaddle = SDL_FRect(
    x: 40,
    y: Float(screenHeight) / 2 - paddleHeight / 2,
    w: paddleWidth,
    h: paddleHeight
)

var rightPaddle = SDL_FRect(
    x: Float(screenWidth) - 40 - paddleWidth,
    y: Float(screenHeight) / 2 - paddleHeight / 2,
    w: paddleWidth,
    h: paddleHeight
)

var ball = SDL_FRect(
    x: Float(screenWidth) / 2 - ballSize / 2,
    y: Float(screenHeight) / 2 - paddleHeight / 2,
    w: ballSize,
    h: ballSize
)

var isRunning = true
var event = SDL_Event()

while isRunning {
    while SDL_PollEvent(&event) {
        if event.type == SDL_EVENT_QUIT.rawValue {
            isRunning = false
        }
    }    

    SDL_SetRenderDrawColor(renderer, 20, 20, 20, 255)
    SDL_RenderClear(renderer)

    SDL_SetRenderDrawColor(renderer, 240, 240, 240, 255)

    SDL_RenderFillRect(renderer, &leftPaddle)
    SDL_RenderFillRect(renderer, &rightPaddle)
    SDL_RenderFillRect(renderer, &ball)

    SDL_RenderPresent(renderer)
}