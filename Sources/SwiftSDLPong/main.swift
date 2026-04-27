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
let paddleSpeed: Float = 1

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

var ballVelocityX: Float = 0.4
var ballVelocityY: Float = 0.3

func intersects(_ a: SDL_FRect, _ b: SDL_FRect) -> Bool {
    a.x < b.x + b.w &&
    a.x + a.w > b.x &&
    a.y < b.y + b.h &&
    a.y + a.h > b.y
}

while isRunning {
    while SDL_PollEvent(&event) {
        if event.type == SDL_EVENT_QUIT.rawValue {
            isRunning = false
        }
    }    

    let keyboardState = SDL_GetKeyboardState(nil)

    if let keyboardState {
        if keyboardState[Int(SDL_SCANCODE_W.rawValue)] {
            leftPaddle.y -= paddleSpeed
        }

        if keyboardState[Int(SDL_SCANCODE_S.rawValue)] {
            leftPaddle.y += paddleSpeed
        }

        if keyboardState[Int(SDL_SCANCODE_UP.rawValue)] {
            rightPaddle.y -= paddleSpeed
        }

        if keyboardState[Int(SDL_SCANCODE_DOWN.rawValue)] {
            rightPaddle.y += paddleSpeed
        }
    }

    leftPaddle.y = max(0, min(leftPaddle.y, Float(screenHeight) - leftPaddle.h))
    rightPaddle.y = max(0, min(rightPaddle.y, Float(screenHeight) - rightPaddle.h))

    ball.x += ballVelocityX
    ball.y += ballVelocityY

    if ball.y <= 0 {
        ball.y = 0
        ballVelocityY *= -1
    }

    if ball.y + ball.h > Float(screenHeight) {
        ball.y = Float(screenHeight) - ball.h
        ballVelocityY *= -1
    }

    if intersects(ball, leftPaddle), ballVelocityX < 0 {
        ball.x = leftPaddle.x + leftPaddle.w
        ballVelocityX *= -1
    }

    if intersects(ball, rightPaddle), ballVelocityX > 0 {
        ball.x = rightPaddle.x - rightPaddle.w
        ballVelocityX *= -1
    }

    SDL_SetRenderDrawColor(renderer, 20, 20, 20, 255)
    SDL_RenderClear(renderer)

    SDL_SetRenderDrawColor(renderer, 240, 240, 240, 255)

    SDL_RenderFillRect(renderer, &leftPaddle)
    SDL_RenderFillRect(renderer, &rightPaddle)
    SDL_RenderFillRect(renderer, &ball)

    SDL_RenderPresent(renderer)
}