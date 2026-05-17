import CSDL3

struct Game {
    let screenWidth: Int32
    let screenHeight: Int32

    let paddleWidth: Float = 15
    let paddleHeight: Float = 100
    let ballSize: Float = 15
    let paddleSpeed: Float = 400
    let winningScore = 5

    var leftPaddle: SDL_FRect
    var rightPaddle: SDL_FRect
    var ball: SDL_FRect

    var ballVelocityX: Float = 260
    var ballVelocityY: Float = 180

    var leftScore = 0
    var rightScore = 0

    var state: GameState = .waitingToStart

    init(screenWidth: Int32, screenHeight: Int32) {
        self.screenWidth = screenWidth
        self.screenHeight = screenHeight

        self.leftPaddle = SDL_FRect(
            x: 40,
            y: Float(screenHeight) / 2 - paddleHeight / 2,
            w: paddleWidth,
            h: paddleHeight
        )

        self.rightPaddle = SDL_FRect(
            x: Float(screenWidth) - 40 - paddleWidth,
            y: Float(screenHeight) / 2 - paddleHeight / 2,
            w: paddleWidth,
            h: paddleHeight
        )

        self.ball = SDL_FRect(
            x: Float(screenWidth) / 2 - ballSize / 2,
            y: Float(screenHeight) / 2 - ballSize / 2,
            w: ballSize,
            h: ballSize
        )

        resetBall(towardsLeft: Bool.random())
        print("Press Space to start")
    }

    mutating func start() {
        guard state == .waitingToStart else { return }

        state = .playing
        print("Game started")
    }

    mutating func togglePause() {
        if state == .playing {
            state = .paused
            print("Paused")
        } else if state == .paused {
            state = .playing
            print("Resumed")
        }
    }

    mutating func restart() {
        leftScore = 0
        rightScore = 0

        leftPaddle.y = Float(screenHeight) / 2 - leftPaddle.h / 2
        rightPaddle.y = Float(screenHeight) / 2 - rightPaddle.h / 2

        resetBall(towardsLeft: Bool.random())

        state = .waitingToStart
        print("Press Space to start")
    }

    mutating func update(deltaTime: Float, keyboardState: UnsafePointer<Bool>?) {
        guard state == .playing else { return }

        handleInput(deltaTime: deltaTime, keyboardState: keyboardState)
        clampPaddles()
        updateBall(deltaTime: deltaTime)
        handleWallCollision()
        handlePaddleCollision()
        handleScoring()
    }

    private mutating func handleInput(deltaTime: Float, keyboardState: UnsafePointer<Bool>?) {
        guard let keyboardState else { return }

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

    private mutating func clampPaddles() {
        leftPaddle.y = max(0, min(leftPaddle.y, Float(screenHeight) - leftPaddle.h))
        rightPaddle.y = max(0, min(rightPaddle.y, Float(screenHeight) - rightPaddle.h))
    }

    private mutating func updateBall(deltaTime: Float) {
        ball.x += ballVelocityX * deltaTime
        ball.y += ballVelocityY * deltaTime
    }

    private mutating func handleWallCollision() {
        if ball.y <= 0 {
            ball.y = 0
            ballVelocityY *= -1
        }

        if ball.y + ball.h > Float(screenHeight) {
            ball.y = Float(screenHeight) - ball.h
            ballVelocityY *= -1
        }
    }

    private mutating func handlePaddleCollision() {
        if intersects(ball, leftPaddle), ballVelocityX < 0 {
            ball.x = leftPaddle.x + leftPaddle.w
            applyPaddleBounce(paddle: leftPaddle, movingRight: true)
        }

        if intersects(ball, rightPaddle), ballVelocityX > 0 {
            ball.x = rightPaddle.x - ball.w
            applyPaddleBounce(paddle: rightPaddle, movingRight: false)
        }
    }

    private mutating func handleScoring() {
        if ball.x + ball.w < 0 {
            rightScore += 1
            print("Left \(leftScore) - \(rightScore) Right")

            if rightScore >= winningScore {
                state = .gameOver
                print("Right player wins. Press R to restart.")
            } else {
                resetBall(towardsLeft: false)
            }
        }

        if ball.x > Float(screenWidth) {
            leftScore += 1
            print("Left \(leftScore) - \(rightScore) Right")

            if leftScore >= winningScore {
                state = .gameOver
                print("Left player wins. Press R to restart.")
            } else {
                resetBall(towardsLeft: true)
            }
        }
    }

    private mutating func resetBall(towardsLeft: Bool) {
        ball.x = Float(screenWidth) / 2 - ball.w / 2
        ball.y = Float(screenHeight) / 2 - ball.h / 2

        ballVelocityX = towardsLeft ? -260 : 260
        ballVelocityY = Bool.random() ? -180 : 180
    }

    private mutating func applyPaddleBounce(paddle: SDL_FRect, movingRight: Bool) {
        let ballCenterY = ball.y + ball.h / 2
        let paddleCenterY = paddle.y + paddle.h / 2

        let distanceFromCenter = ballCenterY - paddleCenterY
        let normalizedDistance = distanceFromCenter / (paddle.h / 2)

        let ballSpeedX: Float = 300
        let maxBallSpeedY: Float = 280

        ballVelocityX = movingRight ? ballSpeedX : -ballSpeedX
        ballVelocityY = normalizedDistance * maxBallSpeedY
    }
}