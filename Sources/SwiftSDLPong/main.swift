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
let paddleSpeed: Float = 400

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
    y: Float(screenHeight) / 2 - ballSize / 2,
    w: ballSize,
    h: ballSize
)

var isRunning = true
var event = SDL_Event()

var ballVelocityX: Float = 260
var ballVelocityY: Float = 180

var leftScore = 0
var rightScore = 0

var gameState: GameState = .waitingToStart
let winningScore = 5

let digitSegments: [Int: [Int]] = [
    0: [0, 1, 2, 3, 4, 5],
    1: [1, 2],
    2: [0, 1, 6, 4, 3],
    3: [0, 1, 6, 2, 3],
    4: [5, 6, 1, 2],
    5: [0, 5, 6, 2, 3],
    6: [0, 5, 6, 4, 2, 3],
    7: [0, 1, 2],
    8: [0, 1, 2, 3, 4, 5, 6],
    9: [0, 1, 2, 3, 5, 6]
]

func intersects(_ a: SDL_FRect, _ b: SDL_FRect) -> Bool {
    a.x < b.x + b.w &&
    a.x + a.w > b.x &&
    a.y < b.y + b.h &&
    a.y + a.h > b.y
}

@MainActor
func resetBall(towardsLeft: Bool) {
    ball.x = Float(screenWidth) / 2 - ball.w / 2
    ball.y = Float(screenHeight) / 2 - ball.h / 2

    ballVelocityX = towardsLeft ? -260 : 260
    ballVelocityY = Bool.random() ? -180 : 180
}

@MainActor
func applyPaddleBounce(ball: SDL_FRect, paddle: SDL_FRect, movingRight: Bool) {
    let ballCenterY = ball.y + ball.h / 2
    let paddleCenterY = paddle.y + paddle.h / 2

    let distanceFromCenter = ballCenterY - paddleCenterY
    let normalizedDistance = distanceFromCenter / (paddle.h / 2)

    let ballSpeedX: Float = 300
    let maxBallSpeedY: Float = 280

    ballVelocityX = movingRight ? ballSpeedX : -ballSpeedX
    ballVelocityY = normalizedDistance * maxBallSpeedY
}

func renderCenterLine(renderer: OpaquePointer?) {
    let dashWidth: Float = 6
    let dashHeight: Float = 24
    let dashGap: Float = 16

    let x: Float = Float(screenWidth) / 2 - dashWidth / 2
    var y: Float = 0

    while y < Float(screenHeight) {
        var dash = SDL_FRect(
            x: x,
            y: y,
            w: dashWidth,
            h: dashHeight
        )
        SDL_RenderFillRect(renderer, &dash)
        y += dashHeight + dashGap
    }
}

func renderDigit(_ digit: Int, x: Float, y: Float, scale: Float, renderer: OpaquePointer?) {
    guard let segments = digitSegments[digit] else { return }

    let thickness = scale
    let width = scale * 6
    let height = scale * 10

    let segmentRects: [SDL_FRect] = [
        SDL_FRect(x: x + thickness, y: y, w: width - 2 * thickness, h: thickness),
        SDL_FRect(x: x + width - thickness, y: y + thickness, w: thickness, h: height / 2 - thickness),
        SDL_FRect(x: x + width - thickness, y: y + height / 2, w: thickness, h: height / 2 - thickness),
        SDL_FRect(x: x + thickness, y: y + height - thickness, w: width - 2 * thickness, h: thickness),
        SDL_FRect(x: x, y: y + height / 2, w: thickness, h: height / 2 - thickness),
        SDL_FRect(x: x, y: y + thickness, w: thickness, h: height / 2 - thickness),
        SDL_FRect(x: x + thickness, y: y + height / 2 - thickness / 2, w: width - 2 * thickness, h: thickness)
    ]

    for index in segments {
        var rect = segmentRects[index]
        SDL_RenderFillRect(renderer, &rect)
    }
}

@MainActor
func renderScore(renderer: OpaquePointer?) {
    let scale: Float = 6
    let y: Float = 40

    renderDigit(leftScore % 10, x: Float(screenWidth) / 2 - 80, y: y, scale: scale, renderer: renderer)
    renderDigit(rightScore % 10, x: Float(screenWidth) / 2 + 45, y: y, scale: scale, renderer: renderer)
}

@MainActor 
func restartGame() {
    leftScore = 0
    rightScore = 0

    leftPaddle.y = Float(screenHeight) / 2 - leftPaddle.h / 2
    rightPaddle.y = Float(screenHeight) / 2 - rightPaddle.h / 2

    gameState = .waitingToStart
    print("Press Space to start")
}

var lastFrameTime = SDL_GetTicks()

resetBall(towardsLeft: Bool.random())
print("Press Space to start")

while isRunning {
    let currentFrameTime = SDL_GetTicks()
    let deltaTime = Float(currentFrameTime - lastFrameTime) / 1000
    lastFrameTime = currentFrameTime

    while SDL_PollEvent(&event) {
        if event.type == SDL_EVENT_QUIT.rawValue {
            isRunning = false
        }

        if event.type == SDL_EVENT_KEY_DOWN.rawValue {
            switch event.key.scancode {
                case SDL_SCANCODE_SPACE:
                    if gameState == .waitingToStart {
                        gameState = .playing
                        print("Game Started")
                    }
                case SDL_SCANCODE_P:
                    if gameState == .playing {
                        gameState = .paused
                        print("Paused")
                    } else if gameState == .paused {
                        gameState = .playing
                        print("Resumed")
                    }
                case SDL_SCANCODE_R:
                    if gameState == .gameOver {
                        restartGame()
                    }
                case SDL_SCANCODE_ESCAPE:
                    isRunning = false
                default:
                    break
            }
        }
    }    

    if gameState == .playing {
        let keyboardState = SDL_GetKeyboardState(nil)

        if let keyboardState {
            if keyboardState[Int(SDL_SCANCODE_W.rawValue)] {
                leftPaddle.y -= paddleSpeed * deltaTime
            }

            if keyboardState[Int(SDL_SCANCODE_S.rawValue)] {
                leftPaddle.y += paddleSpeed * deltaTime
            }

            if keyboardState[Int(SDL_SCANCODE_UP.rawValue)] {
                rightPaddle.y -= paddleSpeed * deltaTime
            }

            if keyboardState[Int(SDL_SCANCODE_DOWN.rawValue)] {
                rightPaddle.y += paddleSpeed * deltaTime
            }
        }
    
        leftPaddle.y = max(0, min(leftPaddle.y, Float(screenHeight) - leftPaddle.h))
        rightPaddle.y = max(0, min(rightPaddle.y, Float(screenHeight) - rightPaddle.h))

        ball.x += ballVelocityX * deltaTime
        ball.y += ballVelocityY * deltaTime

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
            applyPaddleBounce(ball: ball, paddle: leftPaddle, movingRight: true)
        }

        if intersects(ball, rightPaddle), ballVelocityX > 0 {
            ball.x = rightPaddle.x - ball.w
            applyPaddleBounce(ball: ball, paddle: rightPaddle, movingRight: false)
        }

        if ball.x + ball.w < 0 {
            rightScore += 1
            print("Left \(leftScore) - \(rightScore) Right")
            resetBall(towardsLeft: false)
        }

        if ball.x > Float(screenWidth) {
            leftScore += 1
            print("Left \(leftScore) - \(rightScore) Right")
            resetBall(towardsLeft: true)
        }
    }

    SDL_SetRenderDrawColor(renderer, 20, 20, 20, 255)
    SDL_RenderClear(renderer)

    SDL_SetRenderDrawColor(renderer, 240, 240, 240, 255)

    renderCenterLine(renderer: renderer)
    renderScore(renderer: renderer)

    SDL_RenderFillRect(renderer, &leftPaddle)
    SDL_RenderFillRect(renderer, &rightPaddle)
    SDL_RenderFillRect(renderer, &ball)

    SDL_RenderPresent(renderer)
}